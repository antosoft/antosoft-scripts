#! /bin/bash
#
# Script para Instalar, Actualizar y Configurar entorno Linux de forma rapida.
#
# Author: Antonio da Silva <adsmicrosistemas@gmail.com> (https://adsmicrosistemas.com)
#

SCRIPT_NAME="Install and Config Script"
AUTHOR="Antonio da Silva"
VERSION="1.0"
LAST_UPDATED="26-11-2022"

# Cargamos variables y funciones para decorar textos...
ADS_TOOLS="/var/shared/antosoft/scripts/ads_tools.sh"
# ADS_TOOLS="ads_tools.sh"
if [ ! -f "${ADS_TOOLS}" ]; then
  echo "Error! script library file not found."
  exit 1
fi
. "${ADS_TOOLS}" >/dev/null 2>&1
clear
script_info

PROFILE_FILE="/etc/profile"
ALIAS_FILE="/var/shared/antosoft/scripts/alias_list.txt"
# ALIAS_FILE="alias_list.txt"
HN=$(hostname -A)
HOST_NAME="$(cut -d'.' -f1 <<<"$HN")"
HOST_IP=$(hostname -i)
SEARCH_TXT="ListenAddress 0.0.0.0"
REPLACE_TXT="ListenAddress $HOST_IP"

# Get distro name & version...
OS_NAME=""
OS_VERSION=""
if [ -f /etc/os-release ]; then
  . /etc/os-release
  OS_NAME=$ID
  OS_VERSION=$VERSION_ID
fi

PAKMAN=""
SSH_SERVICE="sshd"
LIB_LOCALES="glibc-langpack-es"
SSH_CONFIG="/var/shared/antosoft/redhat"  # Define dir config store
if [[ "$OS_NAME" == "debian" || "$OS_NAME" == "ubuntu" ]]; then
  PAKMAN="apt-get"
  SSH_SERVICE="ssh.service"
  LIB_LOCALES="locales"
  SSH_CONFIG="/var/shared/antosoft/debian"
elif [[ "$OS_NAME" == "almalinux" || "$OS_NAME" == "rocky" ]]; then
  PAKMAN="dnf"
elif [[ "$OS_NAME" == "centos" ]]; then
  PAKMAN="yum"
fi
if [ -z "$PAKMAN" ]; then
  set_clr "${B_RED}"; msg_err "Linux version error. Id:[$(t $OS_NAME ${B_WHITE})], v:[$(t $OS_VERSION ${B_WHITE})]\n"
  exit 1
fi

# Params...
SET_ALIASES="yes"
SET_HOSTNAME="yes"
SET_LOCALE="yes"
M_COMMANDER="yes"
NANO_EDITOR="yes"
SSH_SERVER="yes"
SSH_GENKEYS="yes"
SET_LOCALTIME="yes"
UPDATE="yes"
for x in "$@"; do
  case $x in
    -d=*)
      SET_ALIASES="${x#*=}"
      SET_HOSTNAME="${x#*=}"
      SET_LOCALE="${x#*=}"
      M_COMMANDER="${x#*=}"
      NANO_EDITOR="${x#*=}"
      SSH_SERVER="${x#*=}"
      SSH_GENKEYS="${x#*=}"
      SET_LOCALTIME="${x#*=}"
      UPDATE="${x#*=}"
      shift
      ;;
  esac
done

for i in "$@"; do
  case $i in
    -a=*|--aliases=*)
      SET_ALIASES="${i#*=}"
      shift
      ;;
    -h=*|--hostname=*)
      SET_HOSTNAME="${i#*=}"
      shift
      ;;
    -l=*|--locale=*)
      SET_LOCALE="${i#*=}"
      shift
      ;;
    -m=*|--mcommander=*)
      M_COMMANDER="${i#*=}"
      shift
      ;;
    -n=*|--nanoeditor=*)
      NANO_EDITOR="${i#*=}"
      shift
      ;;
    -s=*|--sshserver=*)
      SSH_SERVER="${i#*=}"
      shift
      ;;
    -sk=*|--sshgenkeys=*)
      SSH_GENKEYS="${i#*=}"
      shift
      ;;
    -t=*|--localtime=*)
      SET_LOCALTIME="${i#*=}"
      shift
      ;;
    -u=*|--update=*)
      UPDATE="${i#*=}"
      shift
      ;;
    -d=*)
      shift
      ;;
    -*|--help|--*)
      if [[ "${i}" != "-h" && "${i}" != "--help" ]]; then
        set_clr "${B_RED}"; msg_err "Unknown option: $(t $i ${BG_RED}${B_WHITE})\n"
      fi

      set_clr "${CYAN}" 
      msg "Options (Default all $(t 'y|yes' ${B_WHITE}); Set $(t 'n|no' ${B_WHITE}) to skip):"
      msg "  $(t -d ${B_WHITE}) (initial value for all)"
      msg "  $(t -a ${B_WHITE}), $(t --aliases ${B_WHITE})"
      msg "  $(t -h ${B_WHITE}), $(t --hostname ${B_WHITE})"
      msg "  $(t -l ${B_WHITE}), $(t --locale ${B_WHITE})"
      msg "  $(t -m ${B_WHITE}), $(t --mcommander ${B_WHITE})"
      msg "  $(t -n ${B_WHITE}), $(t --nanoeditor ${B_WHITE})"
      msg "  $(t -s ${B_WHITE}), $(t --sshserver ${B_WHITE})"
      msg "  $(t -sk ${B_WHITE}), $(t --sshgenkeys ${B_WHITE})"
      msg "  $(t -t ${B_WHITE}), $(t --localtime ${B_WHITE})"
      msg "  $(t -u ${B_WHITE}), $(t --update ${B_WHITE}) \n"

      exit 1
      ;;
    *)
      ;;
  esac
done


if [[ "yes|y" == *"${SET_ALIASES}"* ]]; then
  if [ -f "${PROFILE_FILE}" ] && [ -f "${ALIAS_FILE}" ]; then
    set_clr "${B_CYAN}"; msg "Setting aliases in: $(t $PROFILE_FILE ${B_WHITE})"

    dataInsert=$(cat "${ALIAS_FILE}")
    outputFile=$(replace "${PROFILE_FILE}" "profile" "_tmp_profile" "")
    insertdata_tofile "${PROFILE_FILE}" "${dataInsert}" "${outputFile}"
    
    if [ -f "${outputFile}" ]; then
      mv -f "${outputFile}" "${PROFILE_FILE}"
    fi
  fi
fi

if [[ "yes|y" == *"${SET_HOSTNAME}"* ]]; then
  set_clr "${B_CYAN}"; msg "Setting hostname: $(t $HOST_NAME ${B_WHITE})"
  echo $HOST_NAME > /etc/hostname
fi

if [[ "yes|y" == *"${SET_LOCALTIME}"* ]]; then
  set_clr "${B_CYAN}"; msg "Setting timezone: $(t 'America/Asuncion' ${B_WHITE})"

  rm -rf /etc/localtime
  ln -s /usr/share/zoneinfo/America/Asuncion /etc/localtime
fi

if [[ "yes|y" == *"${UPDATE}"* ]]; then
  set_clr "${B_CYAN}"; msg "Updating packages..."
  # dnf/yum/apt-get update -y
  $PAKMAN update -y
fi

if [[ "yes|y" == *"${SET_LOCALE}"* ]]; then
  set_clr "${B_CYAN}"; msg "Installing language packs..."
  # dnf/yum install glibc-langpack-es  -y
  # apt-get install language-pack-es -y
  $PAKMAN install "$LIB_LOCALES" -y
  
  set_clr "${B_CYAN}"; msg "Setting default lenguaje..."

  if [[ "$OS_NAME" == "debian" || "$OS_NAME" == "ubuntu" ]]; then
    locale-gen es_PY.UTF-8
  fi
  localectl set-locale LANG=es_PY.UTF-8
  localectl set-locale LC_CTYPE=es_PY.UTF-8
  localectl set-locale LC_NUMERIC=es_PY.UTF-8
  localectl set-locale LC_TIME=es_PY.UTF-8
  localectl set-locale LC_COLLATE=es_PY.UTF-8
  localectl set-locale LC_MONETARY=es_PY.UTF-8
  localectl set-locale LC_MESSAGES=es_PY.UTF-8
  localectl set-locale LC_PAPER=es_PY.UTF-8
  localectl set-locale LC_NAME=es_PY.UTF-8
  localectl set-locale LC_ADDRESS=es_PY.UTF-8
  localectl set-locale LC_TELEPHONE=es_PY.UTF-8
  localectl set-locale LC_MEASUREMENT=es_PY.UTF-8
  localectl set-locale LC_IDENTIFICATION=es_PY.UTF-8
fi

if [[ "yes|y" == *"${SSH_SERVER}"* ]]; then
  set_clr "${B_CYAN}"; msg "Installing ssh server..."

  # dnf/yum/apt-get install openssh-server openssh-clients -y
  $PAKMAN install openssh-server -y

  sed "s/$SEARCH_TXT/$REPLACE_TXT/g" "$SSH_CONFIG/sshd_config" > /etc/ssh/sshd_config
  \cp -r "$SSH_CONFIG/ssh_config" /etc/ssh/

  sleep 5

  systemctl start "$SSH_SERVICE"
  systemctl daemon-reload
  systemctl enable "$SSH_SERVICE"
  #systemctl restart "$SSH_SERVICE"
fi

if [[ "yes|y" == *"${SSH_GENKEYS}"* ]]; then
  set_clr "${B_CYAN}"; msg "Generating openssh keys..."
  rm -fr /etc/ssh/bk
  mkdir -p /etc/ssh/bk
  mv -f /etc/ssh/ssh_host_rsa_key /etc/ssh/bk/
  mv -f /etc/ssh/ssh_host_ed25519_key /etc/ssh/bk/
  mv -f /etc/ssh/ssh_host_ecdsa_key /etc/ssh/bk/
  mv -f /etc/ssh/ssh_host_dsa_key /etc/ssh/bk/

  set_clr "${BI_PURPLE}"; msg "Generating rsa key [$(t '/etc/ssh/ssh_host_rsa_key' ${B_WHITE})]..."
  ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -q -N ""

  set_clr "${BI_PURPLE}"; msg "Generating ed25519 key [$(t '/etc/ssh/ssh_host_ed25519_key' ${B_WHITE})]..."
  ssh-keygen -t ed25519  -f /etc/ssh/ssh_host_ed25519_key -q -N ""

  set_clr "${BI_PURPLE}"; msg "Generating ecdsa key [$(t '/etc/ssh/ssh_host_ecdsa_key' ${B_WHITE})]..."
  ssh-keygen -t ecdsa -b 521 -f /etc/ssh/ssh_host_ecdsa_key -q -N ""

  set_clr "${BI_PURPLE}"; msg "Generating dsa key [$(t '/etc/ssh/ssh_host_dsa_key' ${B_WHITE})]..."
  ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -q -N ""
fi

if [[ "yes|y" == *"${M_COMMANDER}"* ]]; then
  set_clr "${B_CYAN}"; msg "Installing Midnight Commander for $(t $OS_NAME ${B_WHITE})"

  if [[ "$OS_NAME" == "debian" || "$OS_NAME" == "ubuntu" ]]; then
	  # apt-get install mc -y
	  $PAKMAN install mc -y
  else
    # dnf/yum config-manager --set-enabled crb
    # dnf/yum install epel-release -y
    # dnf/yum install mc -y
    $PAKMAN config-manager --set-enabled crb
    $PAKMAN install epel-release -y
    $PAKMAN install mc -y
  fi
fi

if [[ "yes|y" == *"${NANO_EDITOR}"* ]]; then
  set_clr "${B_CYAN}"; msg "Searching for Nano Editor installed..."
  
  PATH_NANO=$(find_path "nano")
  [[ -z "${PATH_NANO}" ]]; NANO_INSTALLED=$?

  if [[ "${NANO_INSTALLED}" && -f "${PATH_NANO}" ]]; then
    set_clr msg_ok "Nano Editor is already installed!"
  else
    set_clr "${B_CYAN}"; msg "Installing Nano Editor for $(t $OS_NAME ${B_WHITE})"
    $PAKMAN install nano -y

    PATH_NANO=$(find_path "nano")
  fi

  set_clr "${B_CYAN}"; msg "Creating alias $(t 'ne' ${B_WHITE}) for Nano Editor..."
  grep -qxF "alias ne='${PATH_NANO}'" ~/.bashrc || echo "alias ne='${PATH_NANO}'" >> ~/.bashrc
  . ~/.bashrc
fi

# In this section we install as many packages as necessary...
# -- clear
set_clr "${B_CYAN}"; msg "Searching $(t 'clear' ${B_WHITE}) command..."
PATH_FIND=$(find_path "clear")
[[ -z "${PATH_FIND}" ]]; APP_INSTALLED=$?
if [[ ! "${APP_INSTALLED}" && ! -f "${PATH_FIND}" ]]; then
  set_clr "${B_CYAN}"; msg "Installing commands: $(t 'clear' ${B_WHITE})"
  $PAKMAN install ncurses -y
fi

# -- tar
set_clr "${B_CYAN}"; msg "Searching $(t 'tar' ${B_WHITE}) command..."
PATH_FIND=$(find_path "tar")
[[ -z "${PATH_FIND}" ]]; APP_INSTALLED=$?
if [[ ! "${APP_INSTALLED}" && ! -f "${PATH_FIND}" ]]; then
  set_clr "${B_CYAN}"; msg "Installing commands: $(t 'tar' ${B_WHITE})"
  $PAKMAN install tar -y
fi

echo -e "\n"; msg_ok "Config completed!"
