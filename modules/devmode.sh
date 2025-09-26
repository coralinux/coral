#===================================================================#
# DEVMODE profile.
# Pacotes otimizados para desenvolvedores, com softwares essenciais
# para garantir uma ótima experiência.
#===================================================================#

function DEVMODE() {
    #================================#
    # Pacotes Apt
    #================================#
    pkg_apt=(
        'shellcheck' "" ON
        'git' "" ON
        'lazygit' "" ON
        'distrobox' "" ON
        'podman' "" ON
        'tmux' "" OFF
        'neovim' "" OFF
        'podman-compose' "" ON
        'virt-manager' "" ON
    )

    #================================#
    # Pacotes Flatpak
    #================================#
    pkg_flatpak=(
        'com.vscodium.codium' "Visual Studio Code sem Telemetria" ON
        'io.podman_desktop.PodmanDesktop' "Trabalhe com contêineres e Kubernetes em modo gráfico." ON
        'com.ranfdev.DistroShelf' "Gerencie seus containers do Distrobox com uma interface amigável." ON
    )
    #================================#
    # Instalação de pacotes apt.
    #================================#
    apt_install=$(whiptail \
        --backtitle "$prg - $prg_version" \
        --title "Devmode" \
        --checklist "Selecione os softwares que você deseja instalar." \
        10 60 0 \
        "${pkg_apt[@]}" \
        --separate-output \
        --cancel-button "Retornar ao Menu" \
        3>&1 1>&2 2>&3
    )
    ret=$?
    [[ $ret -eq 1 ]] && return 0

    # Caso usuário selecionou virt-manager vamos
    # instalar alguns pacotes extras para boa exp.
    if grep -q "virt-manager" <<< "$apt_install"; then
        virt_manager_extra=(
            'qemu-kvm'
            'qemu-guest-agent'
            'libvirt-daemon-system'
            'libvirt-clients bridge-utils'
        )
    fi
    
    # Renove a array com os itens selecionados
    # pelo usuario.
    pkg_apt=($apt_install)
    pkg_apt+=(${virt_manager_extra[@]}) # intere.

    #================================#
    # Comece a instalação
    #================================#
    for pkg_install in "${pkg_apt[@]}"; do
        if ! dpkg -s "$pkg_install" &> /dev/null; then
            sudo apt install -y "$pkg_install"
        fi
    done

    # Configure o virtmanager.
    SUDO_USER=${SUDO_USER:-$USER}
    sudo adduser $SUDO_USER libvirt
    sudo adduser $SUDO_USER kvm
    sudo systemctl enable --now libvirtd

    #================================#
    # Instalação de pacotes Flatpak.
    #================================#
    flatpak_install=$(whiptail \
        --backtitle "$prg - $prg_version" \
        --title "Devmode" \
        --checklist "Selecione os flatpaks que você deseja instalar." \
        10 60 0 \
        "${pkg_flatpak[@]}" \
        --separate-output \
        --cancel-button "Retornar ao Menu" \
        3>&1 1>&2 2>&3
    )
       ret=$?
    [[ $ret -eq 1 ]] && return 0

    # Renove a array com os itens selecionados
    # pelo usuario.
    pkg_flatpak=($flatpak_install)

    flatpak install flathub --noninteractive --user "${pkg_flatpak[@]}" -y
}
