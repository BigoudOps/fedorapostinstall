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
        sudo dnf install -y shellcheck
        ;;
    esac
else
    echo -e "${rouge}ShellCheck est déja installé ${neutre}"
    echo "le script continue la vérification et l'installation des programmes"
fi
