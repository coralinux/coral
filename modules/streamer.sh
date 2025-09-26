#===================================================================#
# Streamer profile.
# Pacotes otimizados para streamers, com softwares essenciais
# instalados para garantir uma ótima experiência.
#===================================================================#
function STREAMER()
{
    pkg_apt=(
    'ffmpeg'
    'handbrake'
    'pipewire'
    'wireplumber'
    'intel-media-va-driver'
    'firmware-amd-graphics'
    'mesa-vulkan-drivers'
    'mesa-vdpau-drivers'
    )

    pkg_flatpak=(
        'com.obsproject.Studio'
        'org.kde.kdenlive'
        'org.gimp.GIMP'
    )

    #================================#
    # Start here
    #================================#

    # Xanmod Kernel
    if whiptail --title "Kernel XanMod" --yesno "Do you want install (Kernel Xanmod) for low audio latency?" 10 70; then
        wget -qO - https://dl.xanmod.org/archive.key | sudo gpg --dearmor -vo /etc/apt/keyrings/xanmod-archive-keyring.gpg
        echo "deb [signed-by=/etc/apt/keyrings/xanmod-archive-keyring.gpg] http://deb.xanmod.org $(lsb_release -sc) main" | \
        sudo tee /etc/apt/sources.list.d/xanmod-release.list
        sudo apt update && sudo apt install linux-xanmod-x64v3
        
    fi

    # For nvidia users.
    if lspci | grep -i "NVIDIA" &>/dev/null; then
        pkg_apt+=("nvidia-driver-full")
    fi

    # Check if software is installed o system.
    # and install with apt.
    for pkg_install in "${pkg_apt[@]}"; do
        if ! dpkg -s "$pkg_install" &>/dev/null; then
            sudo apt install -y "$pkg_install"
        fi
    done

    # Install flatpaks.
    flatpak install flathub --user "${pkg_flatpak[@]}" -y

    #===============================#
    # Adjust
    #===============================#

    # Enable services
    systemctl --user enable --now pipewire
    systemctl --user enable --now wireplumber

}
