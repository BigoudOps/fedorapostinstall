#!/usr/bin/env bash

set -euo pipefail


rouge='\e[1;31m'
neutre='\e[0m'
vert='\e[1;32m'
bleu='\e[1;34m'
jaune='\e[1;33m'


say() { echo -e "$*${neutre}"; }
ok()  { say "${vert}$*"; }
info(){ say "${bleu}$*"; }
warn(){ say "${jaune}$*"; }
err() { say "${rouge}$*"; }

ask_yes_no() {
  
  local reply
  read -r -p "$(echo -e "${jaune}$1 [O/n] ${neutre}")" reply || true
  case "${reply:-O}" in
    [Nn]*) return 1 ;;
    *)     return 0 ;;
  esac
}

have_cmd() { command -v "$1" >/dev/null 2>&1; }

require_not_root() {
  if [ "${UID}" -eq 0 ]; then
    err "Lance le **sans sudo**, le mot de passe sera demandé pour les actions admin."
    exit 1
  fi
}

dnf_install() {
  
  local pkg="$1"
  if rpm -q --quiet "$pkg"; then
    ok "$pkg est déjà installé."
  else
    info "Installation de $pkg…"
    sudo dnf install -y "$pkg"
  fi
}


require_not_root

ok "Mise à jour des dépôts"
sudo dnf -y upgrade --refresh


dnf_install dnf-plugins-core
dnf_install curl



fedora_ver="$(rpm -E %fedora)"
if ! rpm -q --quiet "rpmfusion-free-release" ; then
  info "Installation du dépôt RPM Fusion Free"
  sudo dnf install -y "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${fedora_ver}.noarch.rpm"
else
  ok "RPM Fusion Free déjà installé."
fi

if ! rpm -q --quiet "rpmfusion-nonfree-release" ; then
  warn "Installation du dépôt RPM Fusion Non-Free"
  sudo dnf install -y "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${fedora_ver}.noarch.rpm"
else
  ok "RPM Fusion Non-Free déjà installé."
fi


if ! rpm -q --quiet rpmfusion-nonfree-release-tainted ; then
  info "Activation du dépôt Non-Free tainted"
  sudo dnf install -y rpmfusion-nonfree-release-tainted
else
  ok "Non-Free tainted déjà présent."
fi


dnf_install shfmt

if ! have_cmd shellcheck; then
  if ask_yes_no "ShellCheck n'est pas installé. Voulez-vous l'installer ?"; then
    info "Installation de ShellCheck"
    dnf_install ShellCheck
  else
    warn "ShellCheck ne sera pas installé. Le script continue."
  fi
else
  ok "ShellCheck est déjà installé."
fi


if ! have_cmd codium; then
  if ask_yes_no "On installe VSCodium ?"; then
    info "Ajout du dépôt VSCodium"
    sudo rpmkeys --import "https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg"
    sudo tee /etc/yum.repos.d/vscodium.repo >/dev/null <<'EOF'
[gitlab.com_paulcarroty_vscodium_repo]
name=download.vscodium.com
baseurl=https://download.vscodium.com/rpms/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg
metadata_expire=1h
EOF
    dnf_install codium
    ok "VSCodium installé. Tu seras un programmeur OpenSource, Luke."
  else
    warn "VSCodium ne sera pas installé. Le script continue."
  fi
else
  ok "VSCodium est déjà installé, tu es un grand monsieur."
fi


if ! have_cmd keepassxc; then
  if ask_yes_no "Tu veux installer KeePassXC ?"; then
    dnf_install keepassxc
  else
    warn "KeepassXC ne sera pas installé. Le script continue."
  fi
else
  ok "KeepassXC est déjà installé."
fi


if [ ! -f "/etc/yum.repos.d/kernel-vanilla.repo" ]; then
  if ask_yes_no "On installe le kernel Vanilla (mainline) ?"; then
    info "Activation du repo kernel-vanilla"
    curl -fsSL https://repos.fedorapeople.org/repos/thl/kernel-vanilla.repo | sudo tee /etc/yum.repos.d/kernel-vanilla.repo >/dev/null
    sudo dnf config-manager --set-enabled kernel-vanilla-mainline
    # Priorité pour que le mainline l'emporte
    sudo dnf config-manager --save --setopt="kernel-vanilla-mainline.priority=99"
    info "Mise à niveau du noyau vers Vanilla mainline"
    sudo dnf upgrade -y kernel kernel-core kernel-modules kernel-modules-extra --refresh || true
    warn "Un redémarrage est requis pour utiliser le nouveau kernel."
  else
    warn "Vanilla ne sera pas installé. Le script continue."
  fi
else
  ok "Kernel Vanilla déjà présent, avant-gardiste !"
fi


if ! have_cmd discord; then
  if ask_yes_no "Veux-tu installer Discord ?"; then
    dnf_install discord
    ok "Discord installé : profite pour rejoindre l'APDM ;-)"
  else
    warn "Discord ne sera pas installé. Le script continue."
  fi
else
  ok "Discord est déjà installé. As-tu rejoint l'APDM ?"
fi


if ! have_cmd nitrokey-app; then
  if ask_yes_no "Tu veux installer Nitrokey App ?"; then
    dnf_install nitrokey-app
  else
    warn "Nitrokey ne sera pas installé, tant pis pour la sécu (surcotée ? ^^)."
  fi
else
  ok "Nitrokey-app est déjà installé. As-tu déjà créé ta clé GnuPG ?"
fi


if ! have_cmd audacity; then
  if ask_yes_no "Tu veux installer Audacity-freeworld ?"; then
    dnf_install audacity-freeworld
  else
    warn "Audacity ne sera pas installé, dommage pour le podcast."
  fi
else
  ok "Audacity est déjà installé. As-tu configuré tes entrées ?"
fi

ok "Tout est terminé. Que la Force soit avec toi !"
