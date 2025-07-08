#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

loading_title="loading... please wait..."

title_game="
▒███████▒▓█████  ██▀███   ▒█████  ▄▄▄█████▓ ██▀███   ▄▄▄       ▄████▄  ▓█████ 
▒ ▒ ▒ ▄▀░▓█   ▀ ▓██ ▒ ██▒▒██▒  ██▒▓  ██▒ ▓▒▓██ ▒ ██▒▒████▄    ▒██▀ ▀█  ▓█   ▀ 
░ ▒ ▄▀▒░ ▒███   ▓██ ░▄█ ▒▒██░  ██▒▒ ▓██░ ▒░▓██ ░▄█ ▒▒██  ▀█▄  ▒▓█    ▄ ▒███   
  ▄▀▒   ░▒▓█  ▄ ▒██▀▀█▄  ▒██   ██░░ ▓██▓ ░ ▒██▀▀█▄  ░██▄▄▄▄██ ▒▓▓▄ ▄██▒▒▓█  ▄ 
▒███████▒░▒████▒░██▓ ▒██▒░ ████▓▒░  ▒██▒ ░ ░██▓ ▒██▒ ▓█   ▓██▒▒ ▓███▀ ░░▒████▒
░▒▒ ▓░▒░▒░░ ▒░ ░░ ▒▓ ░▒▓░░ ▒░▒░▒░   ▒ ░░   ░ ▒▓ ░▒▓░ ▒▒   ▓▒█░░ ░▒ ▒  ░░░ ▒░ ░
░░▒ ▒ ░ ▒ ░ ░  ░  ░▒ ░ ▒░  ░ ▒ ▒░     ░      ░▒ ░ ▒░  ▒   ▒▒ ░  ░  ▒    ░ ░  ░
░ ░ ░ ░ ░   ░     ░░   ░ ░ ░ ░ ▒    ░        ░░   ░   ░   ▒   ░           ░   
  ░ ░       ░  ░   ░         ░ ░              ░           ░  ░░ ░         ░  ░
░                                                             ░               
"

rows=$(tput lines)
cols=$(tput cols)

# Function to center and print a multi-line title
print_centered() {
        local text="$1"
        IFS=$'\n' read -rd '' -a lines <<<"$text"
        local height=${#lines[@]}
        local max_width=0
        for line in "${lines[@]}"; do
                (( ${#line} > max_width )) && max_width=${#line}
        done
        local start_row=$(( (rows - height) / 2 ))
        for i in "${!lines[@]}"; do
                local line="${lines[$i]}"
                local col=$(( (cols - ${#line}) / 2 ))
                tput cup $((start_row + i)) $col
                echo "$line"
        done
}

# Function to print a multi-line title centered at the top
print_centered_top() {
    local text="$1"
    IFS=$'\n' read -rd '' -a lines <<<"$text"
    local max_width=0
    for line in "${lines[@]}"; do
        (( ${#line} > max_width )) && max_width=${#line}
    done
    for i in "${!lines[@]}"; do
        local line="${lines[$i]}"
        local col=$(( (cols - ${#line}) / 2 ))
        tput cup $i $col
        echo "$line"
    done
}

clear
echo -e "${GREEN}"
print_centered "$loading_title"
echo -e "${RESET}"
sleep 4

echo -e "${GREEN}"
print_centered "$title_game"
echo -e "${RESET}"
sleep 2

clear

echo -e "${GREEN}"
print_centered_top "$title_game"
echo -e "${RESET}"
sleep 1

# Prepare menu items
menu_items=("======================|  Main Menu  |======================" "" "" "" "[1]. Start Game" "" "[2]. Chapter List" "" "[3]. Exit Game")
menu_height=${#menu_items[@]}
menu_width=0
for item in "${menu_items[@]}"; do
    (( ${#item} > menu_width )) && menu_width=${#item}
done

# Calculate starting row and column for the menu HUD
start_row=$(( (rows - menu_height) / 2 ))
start_col=$(( (cols - menu_width) / 2 ))

# Print menu HUD with green color
for i in "${!menu_items[@]}"; do
    tput cup $((start_row + i)) $start_col
    if [[ "${menu_items[$i]}" != "" ]]; then
        echo -e "${menu_items[$i]}"
    else
        echo ""
    fi
done

echo ""
echo ""
echo ""
echo ""

read -p "" choice
case $choice in
    1)
        clear
        ./game_chapter_1.bash;;
    2)
        clear
        ./chapterist.bash;;
    *)
        exit;;
esac
