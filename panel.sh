#!/bin/bash

version="1.0"
date="2023-10-10"
title="SSH TUI Panel v$version"

get_users() {
    local users=$(awk -F: '$3 >= 1000 { print $1 }' /etc/passwd)
    echo "root $users"
}

is_suspended() {
    local username="$1"
    local account_status

    account_status=$(sudo chage -l "$username" 2>/dev/null | grep "Password expires")

    if [[ "$account_status" == *"never"* ]]; then
        return 1
    else
        return 0
    fi
}

manage_users() {
    users=$(get_users)

    if [ -n "$1" ]; then
        filtered_users=""
        for user in $users; do
            if [[ "$user" == *"$1"* ]]; then
                filtered_users="$filtered_users $user"
            fi
        done
        users="$filtered_users"
    fi
    i=1
    choices=""
    user_list=()
    for user in $users; do
        local text
        if is_suspended "$user"; then
            text="$user(suspended)"
        else
            text="$user"
        fi
        choices="$choices $i $text"
        user_list["$i"]=$user
        ((i++))
    done
    choice=$(dialog --clear --backtitle "$title" \
        --title "Non-System Users" \
        --menu "Select username:" 30 60 20 $choices 2>&1 >/dev/tty)
    username="${user_list[$choice]}"

    if [ -n "$username" ]; then
        choice=$(dialog --clear --backtitle "$title" \
            --title "Manage User: $username" \
            --menu "\nChoose an action:" 20 60 5 \
                1 "Statistics" \
                2 "Reset Password" \
                3 "Suspend User" \
                4 "Delete" \
            2>&1 >/dev/tty)

        case "$choice" in
            1) # Statistics
                dialog --clear --backtitle "$title" --msgbox "Statistics of \`$username\`" 10 60
                ;;
            
            2) # Reset Password
                clear
                echo "Resetting password for \`$username\`"
                sudo passwd "$username"
                dialog --clear --backtitle "$title" --title "Success" --msgbox "\nPassword for \`$username\` updated successfully." 10 60
                ;;
            
            3) # Suspend User
                confirmed_username=$(dialog --clear --backtitle "$title" --title "Suspend User" \
                --inputbox "Enter \`$username\` to confirm:" 10 60 2>&1 >/dev/tty)

                if [ "$username" = "$confirmed_username" ]; then
                    sudo passwd -e "$username"
                    dialog --clear --backtitle "$title" --title "Suspended" --msgbox "\nUser \`$username\` suspended successfully." 10 60
                else
                    dialog --clear --backtitle "$title" --title "Error!" --msgbox "\nOperation canceled!" 10 60
                fi
                ;;
            
            4) # Delete
                confirmed_username=$(dialog --clear --backtitle "$title" --title "Delete User" \
                --inputbox "Enter \`$username\` to confirm:" 10 60 2>&1 >/dev/tty)

                if [ "$username" = "$confirmed_username" ]; then
                    sudo userdel -r "$username"
                    dialog --clear --backtitle "$title" --title "Deleted" --msgbox "\nUser `$username` deleted successfully." 10 60
                else
                    dialog --clear --backtitle "$title" --title "Error!" --msgbox "\nOperation canceled!" 10 60
                fi
                ;;
        esac
    fi
}

user_stats() {
    ./hogs -type=csv /var/log/ssh-panel/* > ./hogs.csv
    i=1
    if [ -n "$1" ]; then
        users="$1"
    else
        users=$(get_users)
    fi

    clear
    printf " |-------|-------------------------------------|--------------|--------------|\n"
    printf " |   #   |               Username              |  Upload(MB)  | Download(MB) |\n"
    printf " |-------|-------------------------------------|--------------|--------------|\n"
    for user in $users; do
        user_upload=0
        user_download=0
        filtered_data=$(grep ",$user," ./hogs.csv)
        while IFS=, read -r tmp upload download username path machine; do
            # date=$(echo "$path" | awk -F/ '{print $NF}' | awk -F. '{print $1}' | cut -d "-" -f "1-3")
            if [ -n "$upload" ]; then
                user_upload=$(bc <<<"$user_upload + ($upload / 1024)")
            fi
            if [ -n "$download" ]; then
                user_download=$(bc <<<"$user_download + ($download / 1024)")
            fi
        done <<< "$filtered_data"
        local text
        if is_suspended "$user"; then
            text="$user(suspended)"
        else
            text="$user"
        fi
        printf " | %4d  |  %-34s |  %'10.0f  |  %'10.0f  |\n" $i $text $user_upload $user_download
        ((i++))
    done
    printf " |-------|-------------------------------------|--------------|--------------|\n\n"
    read -n 1 -s -r -p "Press any key to continue..."
}

while true; do
    choice=$(dialog --clear --backtitle "$title" \
        --title "SSH User Management" \
        --no-cancel \
        --menu "\nChoose an operation:" 20 60 10 \
            1 "Manage Users" \
            2 "Search User" \
            3 "Statistics" \
            4 "Create User" \
            5 "About" \
            6 "Exit" \
        2>&1 >/dev/tty)

    case "$choice" in
        1) # Manage Users
            manage_users
            ;;

        2) # Serach User
            username=$(dialog --clear --backtitle "$title" \
                --title "Search User" \
                --inputbox "Enter Username:" 10 40 2>&1 >/dev/tty)
            
            manage_users "$username"
            ;;

        3) # Statistics
            choice=$(dialog --clear --backtitle "$title" \
                --title "Statistics" \
                --menu "\nChoose an action:" 20 60 5 \
                    1 "Per User" \
                    2 "Clear Statistics" \
                2>&1 >/dev/tty)

            case "$choice" in
                1) # Per User
                    user_stats
                    ;;

                # 2) # Daily
                #     ;;

                2) # Clear Statistics
                    prompt=$(dialog --clear --backtitle "$title" --title "Delete User" \
                    --inputbox "Enter \`CLEAR\` to confirm:" 10 60 2>&1 >/dev/tty)
                    if [ "$prompt" = "CLEAR" ]; then
                        sudo rm -rf /var/log/ssh-panel/*
                        dialog --clear --backtitle "$title" --title "Success" --msgbox "\nStatistics cleared successfully." 10 60
                    else
                        dialog --clear --backtitle "$title" --title "Cancel" --msgbox "\nOperation canceled!" 10 60
                    fi
                    ;;
            esac
            ;;

        4) # Create User
            username=$(dialog --clear --backtitle "$title" \
                --title "Create User" \
                --inputbox "Enter Username:" 10 40 2>&1 >/dev/tty)

            if [ -n "$username" ]; then
                sudo adduser "$username" --shell /usr/sbin/nologin
                dialog --clear --backtitle "$title" --title "Success" --msgbox "\nUser \`$username\` created successfully." 10 60
                clear
                sudo passwd "$username"
                dialog --clear --backtitle "$title" --title "Success" --msgbox "\nPassword for \`$username\` updated successfully." 10 60
            else
                dialog --clear --backtitle "$title" --title "Error!" --msgbox "\nOperation canceled!" 10 60
            fi
            ;;

        5) # About
            dialog --clear --backtitle "$title" \
            --title "About" \
            --msgbox "\n$title \n\nLicenced under GPLv3\nby Vahid Farid\n\nRepo: github.com/vfarid/ssh-panel\nTwitter: @vahidfarid" 15 60
            ;;

        6) # Exit
            clear
            exit 0
            ;;
    esac
done
