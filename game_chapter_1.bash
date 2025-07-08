#!/bin/bash

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

# Variables globales
player_name=""

# Fonction pour centrer le texte
print_centered() {
    local text="$1"
    IFS=$'\n' read -rd '' -a lines <<<"$text"
    local height=${#lines[@]}
    
    local rows=$(tput lines)
    local cols=$(tput cols)
    local start_row=$(( (rows - height) / 2 ))
    
    for i in "${!lines[@]}"; do
        local line="${lines[$i]}"
        local col=$(( (cols - ${#line}) / 2 ))
        tput cup $((start_row + i)) $col
        echo "$line"
    done
}

# Fonction de chronométrage visuel simple
show_countdown() {
    local seconds=4
    # Positionnement du chronomètre en haut de l'écran
    for i in $(seq $seconds -1 1); do
        tput cup 2 $(( ($(tput cols) - 15) / 2 ))
        if [ "$i" -le 2 ]; then
            echo -ne "${RED}Time left: $i ${RESET}"
        else
            echo -ne "${GREEN}Time left: $i ${RESET}"
        fi
        sleep 1
    done
    tput cup 2 $(( ($(tput cols) - 15) / 2 ))
    echo -ne "${RED}TIME UP!     ${RESET}"
}

# Fonction pour lire avec timeout - VERSION SIMPLIFIÉE
ask_question() {
    local question="$1"
    local correct_answer="$2"
    local user_answer=""
    
    clear
    echo -e "${GREEN}"
    print_centered "$question"
    echo -e "${RESET}"
    
    # Lancer le countdown en arrière-plan
    show_countdown &
    local countdown_pid=$!
    
    # Positionner le curseur pour la saisie en bas de l'écran
    local rows=$(tput lines)
    local cols=$(tput cols)
    tput cup $((rows - 3)) $(( (cols - 16) / 2 ))  # Centrer "Type your answer:"
    echo -n "Type your answer: "
    
    # Lire la réponse avec timeout
    read -t 4 user_answer
    local read_status=$?
    
    # Arrêter le countdown
    kill $countdown_pid 2>/dev/null
    wait $countdown_pid 2>/dev/null
    
    # Nettoyer la ligne du chronomètre
    tput cup 2 0
    tput el
    
    # Vérifier le résultat
    if [ $read_status -ne 0 ]; then
        # Timeout
        tput cup $((rows - 2)) $(( (cols - 10) / 2 ))
        echo -e "${RED}Time's up!${RESET}"
        sleep 1
        return 1
    elif [[ -z "$user_answer" ]]; then
        # Réponse vide
        tput cup $((rows - 2)) $(( (cols - 20) / 2 ))
        echo -e "${RED}No answer provided!${RESET}"
        sleep 1
        return 1
    else
        # Vérifier la réponse (insensible à la casse)
        local user_lower=$(echo "$user_answer" | tr '[:upper:]' '[:lower:]')
        local correct_lower=$(echo "$correct_answer" | tr '[:upper:]' '[:lower:]')
        
        if [[ "$user_lower" == "$correct_lower" ]]; then
            return 0  # Correct
        else
            tput cup $((rows - 2)) $(( (cols - 60) / 2 ))
            echo -e "${RED}Wrong answer! You said: '$user_answer', correct was: '$correct_answer'${RESET}"
            sleep 2
            return 1  # Incorrect
        fi
    fi
}

# Fonction pour les questions mathématiques
ask_math_question() {
    local question="$1"
    local correct_answer="$2"
    local user_answer=""
    
    clear
    echo -e "${GREEN}"
    print_centered "$question"
    echo -e "${RESET}"
    
    # Lancer le countdown en arrière-plan
    show_countdown &
    local countdown_pid=$!
    
    # Positionner le curseur pour la saisie en bas de l'écran
    local rows=$(tput lines)
    local cols=$(tput cols)
    tput cup $((rows - 3)) $(( (cols - 13) / 2 ))  # Centrer "Your answer:"
    echo -n "Your answer: "
    
    # Lire la réponse avec timeout
    read -t 4 user_answer
    local read_status=$?
    
    # Arrêter le countdown
    kill $countdown_pid 2>/dev/null
    wait $countdown_pid 2>/dev/null
    
    # Nettoyer la ligne du chronomètre
    tput cup 2 0
    tput el
    
    # Vérifier le résultat
    if [ $read_status -ne 0 ]; then
        tput cup $((rows - 2)) $(( (cols - 10) / 2 ))
        echo -e "${RED}Time's up!${RESET}"
        sleep 1
        return 1
    elif [[ -z "$user_answer" ]]; then
        tput cup $((rows - 2)) $(( (cols - 20) / 2 ))
        echo -e "${RED}No answer provided!${RESET}"
        sleep 1
        return 1
    elif [[ "$user_answer" == "$correct_answer" ]]; then
        return 0  # Correct
    else
        tput cup $((rows - 2)) $(( (cols - 60) / 2 ))
        echo -e "${RED}Wrong answer! You said: '$user_answer', correct was: '$correct_answer'${RESET}"
        sleep 2
        return 1  # Incorrect
    fi
}

# Écrans de résultat
show_correct() {
    local correct_text="
 ▄████▄   ▒█████   ██▀███   ██▀███  ▓█████  ▄████▄  ▄▄▄█████▓
▒██▀ ▀█  ▒██▒  ██▒▓██ ▒ ██▒▓██ ▒ ██▒▓█   ▀ ▒██▀ ▀█  ▓  ██▒ ▓▒
▒▓█    ▄ ▒██░  ██▒▓██ ░▄█ ▒▓██ ░▄█ ▒▒███   ▒▓█    ▄ ▒ ▓██░ ▒░
▒▓▓▄ ▄██▒▒██   ██░▒██▀▀█▄  ▒██▀▀█▄  ▒▓█  ▄ ▒▓▓▄ ▄██▒░ ▓██▓ ░ 
▒ ▓███▀ ░░ ████▓▒░░██▓ ▒██▒░██▓ ▒██▒░▒████▒▒ ▓███▀ ░  ▒██▒ ░ 
░ ░▒ ▒  ░░ ▒░▒░▒░ ░ ▒▓ ░▒▓░░ ▒▓ ░▒▓░░░ ▒░ ░░ ░▒ ▒  ░  ▒ ░░   
  ░  ▒     ░ ▒ ▒░   ░▒ ░ ▒░  ░▒ ░ ▒░ ░ ░  ░  ░  ▒       ░    
░        ░ ░ ░ ▒    ░░   ░   ░░   ░    ░   ░          ░      
░ ░          ░ ░     ░        ░        ░  ░░ ░               
░                                          ░                 "
    
    clear
    echo -e "${GREEN}"
    print_centered "$correct_text"
    echo -e "${RESET}"
    sleep 2
}

show_wrong() {
    local wrong_text="
 █     █░ ██▀███   ▒█████   ███▄    █   ▄████ 
▓█░ █ ░█░▓██ ▒ ██▒▒██▒  ██▒ ██ ▀█   █  ██▒ ▀█▒
▒█░ █ ░█ ▓██ ░▄█ ▒▒██░  ██▒▓██  ▀█ ██▒▒██░▄▄▄░
░█░ █ ░█ ▒██▀▀█▄  ▒██   ██░▓██▒  ▐▌██▒░▓█  ██▓
░░██▒██▓ ░██▓ ▒██▒░ ████▓▒░▒██░   ▓██░░▒▓███▀▒
░ ▓░▒ ▒  ░ ▒▓ ░▒▓░░ ▒░▒░▒░ ░ ▒░   ▒ ▒  ░▒   ▒ 
  ▒ ░ ░    ░▒ ░ ▒░  ░ ▒ ▒░ ░ ░░   ░ ▒░  ░   ░ 
  ░   ░    ░░   ░ ░ ░ ░ ▒     ░   ░ ░ ░ ░   ░ 
    ░       ░         ░ ░           ░       ░   "
    
    local dead_text="
▓██   ██▓ ▒█████   █    ██     ▄▄▄       ██▀███  ▓█████    ▓█████▄ ▓█████ ▄▄▄      ▓█████▄ 
 ▒██  ██▒▒██▒  ██▒ ██  ▓██▒   ▒████▄    ▓██ ▒ ██▒▓█   ▀    ▒██▀ ██▌▓█   ▀▒████▄    ▒██▀ ██▌
  ▒██ ██░▒██░  ██▒▓██  ▒██░   ▒██  ▀█▄  ▓██ ░▄█ ▒▒███      ░██   █▌▒███  ▒██  ▀█▄  ░██   █▌
  ░ ▐██▓░▒██   ██░▓▓█  ░██░   ░██▄▄▄▄██ ▒██▀▀█▄  ▒▓█  ▄    ░▓█▄   ▌▒▓█  ▄░██▄▄▄▄██ ░▓█▄   ▌
  ░ ██▒▓░░ ████▓▒░▒▒█████▓     ▓█   ▓██▒░██▓ ▒██▒░▒████▒   ░▒████▓ ░▒████▒▓█   ▓██▒░▒████▓ 
   ██▒▒▒ ░ ▒░▒░▒░ ░▒▓▒ ▒ ▒     ▒▒   ▓▒█░░ ▒▓ ░▒▓░░░ ▒░ ░    ▒▒▓  ▒ ░░ ▒░ ░▒▒   ▓▒█░ ▒▒▓  ▒ 
 ▓██ ░▒░   ░ ▒ ▒░ ░░▒░ ░ ░      ▒   ▒▒ ░  ░▒ ░ ▒░ ░ ░  ░    ░ ▒  ▒  ░ ░  ░ ▒   ▒▒ ░ ░ ▒  ▒ 
 ▒ ▒ ░░  ░ ░ ░ ▒   ░░░ ░ ░      ░   ▒     ░░   ░    ░       ░ ░  ░    ░    ░   ▒    ░ ░  ░ 
 ░ ░         ░ ░     ░              ░  ░   ░        ░  ░      ░       ░  ░     ░  ░   ░     
 ░ ░                                                        ░                        ░     "
    
    clear
    echo -e "${RED}"
    print_centered "$wrong_text"
    echo -e "${RESET}"
    sleep 2
    clear
    echo -e "${RED}"
    print_centered "$dead_text"
    echo -e "${RESET}"
    echo ""
    echo -e "${RED}Press Enter to restart the chapter${RESET}"
    read -p ""
    exec "$0"
}

# Initialisation du jeu
init_game() {
    clear
    
    echo -e "${GREEN}Loading... please wait...${RESET}"
    sleep 3
    
    # Séquence de boot
    local boot_sequence=(
        "[ OK ] Initializing NEON SHELL System..."
        "[ OK ] Checking Memory Banks..."
        "[ OK ] Mounting Virtual Sectors..."
        "[ OK ] Connecting to Byte Data Server..."
        "[ OK ] Synchronizing Shell Environment..."
        "[ OK ] Loading AI Protocols..."
        "[ OK ] Preparing Main Menu Interface..."
        "${RED}[ERROR] Failed to connect to ZEROTRACE...${RESET}"
        "${RED}[ERROR] ENTITY NOT FOUND${RESET}"
        "[ ? ] Hello did you hear me ?"
        "[ ? ] I'm here !"
        "[ ? ] What are you doing ?"
        "[ ? ] You're not supposed to be here !"
        "[ ? ] What's your name ? Tell me !"
    )
    
    for msg in "${boot_sequence[@]}"; do
        echo -e "${GREEN}$msg${RESET}"
        sleep 1.5
    done
    
    sleep 0.5
    echo ""
    echo ""
    read -p "Enter Your Name: " player_name
    echo "$player_name" > savefile.txt
    
    # Deuxième séquence
    local second_boot_sequence=(
        ""
        "[ OK ] New player detected: ${RESET}$player_name${GREEN}"
        "[ ? ] Oh, i see you are ${RESET}$player_name${GREEN} ?"
        "[ OK ] Initializing ZEROTRACE System..."
        "[ ? ] Hear me ${RESET}$player_name${GREEN}, You are not supposed to be here !"
        "[ Ok ] ${RESET}$player_name${GREEN}, connected to the system."
        "${RED}[ ERROR ] ENTITY NOT AUTHORISED${RESET}"
        "[ ? ] ${RESET}$player_name${GREEN}, RUN !!"
        "[ ? ] ${RESET}$player_name${GREEN}, you have to escape this place !"
        "[ ? ] ${RESET}$player_name${GREEN}, you must find the key !"
        "[ ? ] ${RESET}$player_name${GREEN}, RUN ! RUN FOR YOUR LIFE ! "
    )
    
    for msg in "${second_boot_sequence[@]}"; do
        echo -e "${GREEN}$msg${RESET}"
        sleep 1.5
    done
    
    sleep 1
    show_title_animation
}

# Animation du titre
show_title_animation() {
    local runTitle="
 ██▀███   █    ██  ███▄    █ 
▓██ ▒ ██▒ ██  ▓██▒ ██ ▀█   █ 
▓██ ░▄█ ▒▓██  ▒██░▓██  ▀█ ██▒
▒██▀▀█▄  ▓▓█  ░██░▓██▒  ▐▌██▒
░██▓ ▒██▒▒▒█████▓ ▒██░   ▓██░
░ ▒▓ ░▒▓░░▒▓▒ ▒ ▒ ░ ▒░   ▒ ▒ 
  ░▒ ░ ▒░░░▒░ ░ ░ ░ ░░   ░ ▒░
  ░░   ░  ░░░ ░ ░    ░   ░ ░ 
   ░        ░              ░ "
    
    # Animation rouge/vert
    for i in {1..6}; do
        clear
        if [ $((i % 2)) -eq 1 ]; then
            echo -e "${RED}"
        else
            echo -e "${GREEN}"
        fi
        print_centered "$runTitle"
        echo -e "${RESET}"
        sleep 0.5
    done
    
    clear
    show_rules
}

# Affichage des règles
show_rules() {
    local centered_rules="
        READ & WRITE NOW !
        
        Welcome to the first chapter of the game.
        The rules are simple: sentences will appear, and you must type the correct response to proceed, find the key, and escape.
        You will have 4 seconds to type the correct sentence, or you will DIE!
        
        GOOD LUCK, ${player_name}!"
    
    print_centered "$centered_rules"
    echo ""
    read -p "Press Enter to start the game..."
    
    clear
    local countdown_text="Are you ready ${player_name} ?"
    echo -e "${GREEN}"
    print_centered "$countdown_text"
    echo -e "${RESET}"
    sleep 1
    
    for num in 3 2 1 "Go!"; do
        clear
        echo -e "${GREEN}"
        print_centered "$num"
        echo -e "${RESET}"
        sleep 1
    done
    
    clear
    start_questions
}

# Questions du jeu
start_questions() {
    # Question 1
    if ask_question "First question: What is the capital of France?" "paris"; then
        show_correct
    else
        show_wrong
        return
    fi
    
    # Question 2
    if ask_question "Second question: What is the representative number of Black Jack?" "21"; then
        show_correct
    else
        show_wrong
        return
    fi
    
    # Question 3
    if ask_question "Third question: What is the name of the first game ever created?" "pong"; then
        show_correct
    else
        show_wrong
        return
    fi
    
    # Question 4
    if ask_question "Fourth question: Do you want the key to escape this place?" "yes"; then
        show_correct
        second_part
    else
        show_wrong
        return
    fi
}

# Deuxième partie du jeu
second_part() {
    clear
    echo -e "${GREEN}"
    print_centered "You find the key, but.. it's not the good one"
    echo -e "${RESET}"
    sleep 3
    
    clear
    echo -e "${RED}"
    print_centered "[ZEROTRACE] And you really think you can escape this place easily ?"
    echo -e "${RESET}"
    sleep 3
    
    clear
    echo -e "${RED}"
    print_centered "Well, let's see if you can calculate to find the code"
    echo -e "${RESET}"
    sleep 3
    
    clear
    echo -e "${GREEN}"
    echo "You have only one chance to find it, so don't waste time"
    echo "The combination consists of the result of the three calculations"
    echo -e "${RESET}"
    sleep 3
    read -p "Press Enter for the second part of the game..."
    
    second_part_calculation
}

second_part_calculation() {
    # Génère trois nombres aléatoires entre 0 et 9
    local num1=$((RANDOM % 10))
    local num2=$((RANDOM % 10))
    local num3=$((RANDOM % 10))
    
    # Première étape : addition
    local result1=$((num1 + num2))
    if ask_math_question "Step 1: What is $num1 + $num2 ?" "$result1"; then
        show_correct
    else
        show_wrong
        return
    fi
    
    # Deuxième étape : multiplication
    local result2=$((num2 * num3))
    if ask_math_question "Step 2: What is $num2 × $num3 ?" "$result2"; then
        show_correct
    else
        show_wrong
        return
    fi
    
    # Troisième étape : soustraction
    local result3=$((num1 - num3))
    if ask_math_question "Step 3: What is $num1 - $num3 ?" "$result3"; then
        show_correct
    else
        show_wrong
        return
    fi
    
    # Code final
    local final_code="${num1}${result1}${result2}"
    
    clear
    print_centered "Congratulations! You solved the calculations."
    print_centered "Now enter the 3-digit code to unlock the door"
    print_centered "Code format: [first number][addition result][multiplication result]"
    echo ""
    
    if ask_math_question "Type the code to unlock the door:" "$final_code"; then
        show_correct
        passage_chapter_1_to_chapter_2
    else
        show_wrong
        return
    fi
}

# Fin du chapitre
passage_chapter_1_to_chapter_2() {
    clear
    echo -e "${GREEN}"
    print_centered "You have successfully found the code!"
    echo -e "${RESET}"
    sleep 2
    
    clear
    print_centered "You open the door and see a ladder leading up to the roof."
    sleep 2
    
    clear
    print_centered "You climb up the ladder and reach the roof."
    print_centered "You look around and notice that there is an exit on the other side of the building."
    sleep 2
    
    clear
    echo -e "${GREEN}"
    print_centered "You run towards the exit and jump off the building."
    echo -e "${RESET}"
    sleep 2
    
    clear
    print_centered "You land safely on the ground and look back at the building."
    print_centered "You have successfully escaped the building!"
    sleep 2
    
    clear
    echo -e "${GREEN}"
    print_centered "Congratulations, ${player_name}! You have completed Chapter 1!"
    echo -e "${RESET}"
    
    echo ""
    read -p "Press Enter to exit..."
}

# Démarrage du jeu
init_game
