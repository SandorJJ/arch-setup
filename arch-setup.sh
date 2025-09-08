#!/usr/bin/env -S bash -e

readonly BOLD='\e[1m'
readonly RED='\e[91m'
readonly BLUE='\e[34m'  
readonly GREEN='\e[92m'
readonly YELLOW='\e[93m'
readonly RESET='\e[0m'

readonly PERCENTAGE_BAR_LENGTH=100
readonly PERCENTAGE_BAR_DIVIDER=2

input=""

print_info () {
    local infos=("${@}")

    for (( i=0; i<"${#}"; i++ ))
    do
        printf "${BOLD}${BLUE}%s${RESET}\n" "${infos[i]}"
    done
}

read_input () {
    local prompt="${1}"

    printf "${BLUE}%s: ${RESET}" "${prompt}"
    read input
}

print_warning () {
    local msg="${1}"

    printf "${BOLD}${YELLOW}%s${RESET}\n" "${msg}"
}

print_percentage() {
    local percentage="${1}"
    local action="${2}"

    local bar="["
    for (( i=0; i<"${percentage}" / "${PERCENTAGE_BAR_DIVIDER}"; i++ ))
    do
        bar="${bar}#"
    done
    for (( i=0; i<("${PERCENTAGE_BAR_LENGTH}" - "${percentage}") / "${PERCENTAGE_BAR_DIVIDER}"; i++ ))
    do
        bar="${bar}-"
    done
    bar="${bar}] (${percentage}%)"

    printf "\r\e[2K"
    printf "${GREEN}%s - %s${RESET}\r" "${bar}" "${action}"

    if [[ "${percentage}" == 100 ]]; then
        printf "\n"
    fi
}

error_handler () {
    printf "${BOLD}${RED}An error has occured on line!\nCheck \"$(basename ${0} .sh).out\" for more information.${RESET}\n"
}

trap "error_handler" ERR
clear

printf "${RED}
 █████╗ ██████╗  ██████╗██╗  ██╗    ███████╗███████╗████████╗██╗   ██╗██████╗
██╔══██╗██╔══██╗██╔════╝██║  ██║    ██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗
███████║██████╔╝██║     ███████║    ███████╗█████╗     ██║   ██║   ██║██████╔╝
██╔══██║██╔══██╗██║     ██╔══██║    ╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝
██║  ██║██║  ██║╚██████╗██║  ██║    ███████║███████╗   ██║   ╚██████╔╝██║
╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝    ╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                                                               by SandorJJ
${RESET}
"

while :
do
    print_info "Start Arch Linux setup?"
    read_input "[y]es / [n]o"

    if [[ "${input}" == "y" ]] || [[ "${input}" == "Y" ]] || [[ "${input}" == "yes" ]] || [[ "${input}" == "Yes" ]]; then
        printf "\n"
        break
    elif [[ "${input}" == "n" ]] || [[ "${input}" == "N" ]] || [[ "${input}" == "no" ]] || [[ "${input}" == "No" ]]; then
        exit 0
    else
        print_warning "Invalid input: \""${input}"\", try again!"
        printf "\n"
    fi
done

print_info "Enter user password for sudo."
read_input "user password"
password="${input}"

print_percentage 0 "Updating packages"
echo "${password}" | sudo -S pacman -Syu

utility_packages="vim git reflector vi fastfetch"
print_percentage 5 "Installing utility tool packages (${utility_packages})"
echo "${password}" | sudo -S pacman -S --noconfirm --needed ${utility_packages}

print_percentage 10 "Installing AUR package manager packages (yay go)"
echo "${password}" | sudo -S pacman -S --noconfirm --needed go
git clone https://aur.archlinux.org/yay.git
cd yay/
makepkg -si --noconfirm --needed
cd
rm -rf yay/

documentation_packages="man-db man-pages tldr"
print_percentage 15 "Installing documentation packages (${documentation_packages})"
echo "${password}" | sudo -S pacman -S --noconfirm --needed ${documentation_packages}

font_packages="ttf-jetbrains-mono-nerd ttf-nerd-fonts-symbols-mono"
print_percentage 15 "Installing font packages (${font_packages})"
echo "${password}" | sudo -S pacman -S --noconfirm --needed ${font_packages}

desktop_packages="hyprland qt5-wayland qt6-wayland xdg-desktop-portal-hyprland hyprpolkitagent hyprpaper waybar sddm"
print_percentage 20 "Installing desktop environment packages (${desktop_packages})"
echo "${password}" | sudo -S pacman -S --noconfirm --needed ${desktop_packages}

launcher_packages="gtk4 gtk4-layer-shell cairo protobuf poppler-glib"
print_percentage 30 "Installing app launcher packages (walker elephant elephant-desktopapplications ${launcher_packages})"
echo "${password}" | sudo -S pacman -S --noconfirm --needed ${launcher_packages}
yay -S --noconfirm --needed elephant elephant-desktopapplications
git clone https://github.com/abenz1267/walker.git
cd walker/
cd
rm -rf walker/

notification_packages="dunst libnotify"
print_percentage 25 "Installing notification packages (${notification_packages})"
echo "${password}" | sudo -S pacman -S --noconfirm --needed ${notification_packages}

audio_packages="pipewire wireplumber pipewire-pulse pipewire-jack pavucontrol"
print_percentage 30 "Installing audio packages (${audio_packages})"
echo "${password}" | sudo -S pacman -S --noconfirm --needed ${audio_packages}

other_packages="yazi dolphin obs-studio"
print_percentage 25 "Installing other packages (${other_packages})"
echo "${password}" | sudo -S pacman -S --noconfirm --needed ${other_packages}
yay -S --noconfirm --needed wezterm-git zen-browser-bin
