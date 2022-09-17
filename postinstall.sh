#!/bin/bash
rouge='\e[1;31m'
neutre='\e[0;m'
vert='\e[4;32m'
bleu='\e[1;34m'
jaune='\e[1;33m'

if [ "$UID" -eq "0" ]; then
    echo -e "${rouge}lance le sans sudo, le mot de passe sera demandé dans le terminal lors de la 1ère action nécessitant le droit administrateur.${vert}"
    exit
fi

echo -e "${vert}mise à jour des dépots ${neutre}"
sudo dnf upgrade -y

if [ ! -f "/usr/bin/shellcheck" ]; then
    echo -e "${vert}ShellCheck n'est pas installé voulez-vous l'installer?${neutre}[O/n]"
    read -r shell
    case $shell in
    N | n)
        echo "ShellCheck ne sera pas installé"
        echo "le script continue la vérification et l'installation des programmes"
        ;;
    O | o | *)
        echo -e "${vert}installation de ShellCheck ${neutre}"
        sudo dnf install -y ShellCheck
        ;;
    esac
else
    echo -e "${rouge}ShellCheck est déja installé ${neutre}"
    echo "le script continue la vérification et l'installation des programmes"
fi

if [ ! -f "/usr/bin/codium" ];  then
    echo -e "${bleu}ont install vscodium ?${neutre}"
    read -r codium
    case $codium in
    N | n)
        echo "VSCodium ne sera pas installé, tu ne sera pas un programmeur jeune padawan"
        echo "le script continue la vérification et l'installation des programmes"
        ;;
    O | o |*)
        echo -e "${jaune}j'installe VSCodium, tu sera un programmeur OpenSource Luke"
        sudo rpmkeys --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg
        printf "[gitlab.com_paulcarroty_vscodium_repo]\nname=download.vscodium.com\nbaseurl=https://download.vscodium.com/rpms/\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg\nmetadata_expire=1h" | sudo tee -a /etc/yum.repos.d/vscodium.repo
        sudo dnf install codium -y
        ;;
    esac
else
    echo -e "${rouge}VSCodium est déjà installé, tu es un grand monsieur ${neutre}"
    echo "le script continue la vérification et l'installation des programmes"
fi

if [ ! -f "/usr/bin/keepassxc" ];  then
    echo -e "${vert}tu veux installer Keepassxc? ${neutre}"
    read -r "$keepassxc"
    case $keepassxc   in  
    N | n)
        echo "KeepassXC ne sera pas installé, honte à toi"
        echo "le script continue la vérification et l'installation des programmes"
        ;;
    O | o |*)
        echo -e "${bleu}Installation de KeepassXC,la force Luke ${neutre}"
        sudo dnf install keepassxc -y
        ;;
    esac
else
    echo -e "${rouge}KeepassXC est déjà installé, la force est déjà en toi ...${neutre}"
    echo "Le script continue la vérification et l'installation des programmes"
fi
