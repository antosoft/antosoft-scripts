#! /bin/bash
#
# Script de variables de colores y funciones varias para mostrar 
# mensajes de colores personalizados y demas.
#
# Author: Antonio da Silva <adsmicrosistemas@gmail.com> (https://adsmicrosistemas.com)
# Last Update: 26-11-2022 
#

# Reset
CLR_OFF=$(echo "\033[0m")       # Text Reset

# Regular Colors
BLACK=$(echo "\033[0;30m")        # Black Normal
RED=$(echo "\033[0;31m")          # Red Normal
GREEN=$(echo "\033[0;32m")        # Green Normal
YELLOW=$(echo "\033[0;33m")       # Yellow Normal
BLUE=$(echo "\033[0;34m")         # Blue Normal
PURPLE=$(echo "\033[0;35m")       # Purple Normal
CYAN=$(echo "\033[0;36m")         # Cyan Normal
WHITE=$(echo "\033[0;37m")        # White Normal

# Bold
B_BLACK=$(echo "\033[1;30m")       # Black Bold
B_RED=$(echo "\033[1;31m")         # Red Bold
B_GREEN=$(echo "\033[1;32m")       # Green Bold
B_YELLOW=$(echo "\033[1;33m")      # Yellow Bold
B_BLUE=$(echo "\033[1;34m")        # Blue Bold
B_PURPLE=$(echo "\033[1;35m")      # Purple Bold
B_CYAN=$(echo "\033[1;36m")        # Cyan Bold
B_WHITE=$(echo "\033[1;37m")       # White Bold

# High Intensity
I_BLACK=$(echo "\033[0;90m")       # Black High Intensity
I_RED=$(echo "\033[0;91m")         # Red High Intensity
I_GREEN=$(echo "\033[0;92m")       # Green High Intensity
I_YELLOW=$(echo "\033[0;93m")      # Yellow High Intensity
I_BLUE=$(echo "\033[0;94m")        # Blue High Intensity
I_PURPLE=$(echo "\033[0;95m")      # Purple High Intensity
I_CYAN=$(echo "\033[0;96m")        # Cyan High Intensity
I_WHITE=$(echo "\033[0;97m")       # White High Intensity

# Bold High Intensity
BI_BLACK=$(echo "\033[1;90m")      # Black Bold High Intensity
BI_RED=$(echo "\033[1;91m")        # Red Bold High Intensity
BI_GREEN=$(echo "\033[1;92m")      # Green Bold High Intensity
BI_YELLOW=$(echo "\033[1;93m")     # Yellow Bold High Intensity
BI_BLUE=$(echo "\033[1;94m")       # Blue Bold High Intensity
BI_PURPLE=$(echo "\033[1;95m")     # Purple Bold High Intensity
BI_CYAN=$(echo "\033[1;96m")       # Cyan Bold High Intensity
BI_WHITE=$(echo "\033[1;97m")      # White Bold High Intensity

# Underline
U_BLACK=$(echo "\033[4;30m")       # Black Underline
U_RED=$(echo "\033[4;31m")         # Red Underline
U_GREEN=$(echo "\033[4;32m")       # Green Underline
U_YELLOW=$(echo "\033[4;33m")      # Yellow Underline
U_BLUE=$(echo "\033[4;34m")        # Blue Underline
U_PURPLE=$(echo "\033[4;35m")      # Purple Underline
U_CYAN=$(echo "\033[4;36m")        # Cyan Underline
U_WHITE=$(echo "\033[4;37m")       # White Underline

# Background
BG_BLACK=$(echo "\033[40m")       # Black Normal Background
BG_RED=$(echo "\033[41m")         # Red Normal Background
BG_GREEN=$(echo "\033[42m")       # Green Normal Background
BG_YELLOW=$(echo "\033[43m")      # Yellow Normal Background
BG_BLUE=$(echo "\033[44m")        # Blue Normal Background
BG_PURPLE=$(echo "\033[45m")      # Purple Normal Background
BG_CYAN=$(echo "\033[46m")        # Cyan Normal Background
BG_WHITE=$(echo "\033[47m")       # White Normal Background

# High Intensity backgrounds
BGI_BLACK=$(echo "\033[0;100m")   # Black High Intensity Background
BGI_RED=$(echo "\033[0;101m")     # Red High Intensity Background
BGI_GREEN=$(echo "\033[0;102m")   # Green High Intensity Background
BGI_YELLOW=$(echo "\033[0;103m")  # Yellow High Intensity Background
BGI_BLUE=$(echo "\033[0;104m")    # Blue High Intensity Background
BGI_PURPLE=$(echo "\033[0;105m")  # Purple High Intensity Background
BGI_CYAN=$(echo "\033[0;106m")    # Cyan High Intensity Background
BGI_WHITE=$(echo "\033[0;107m")   # White High Intensity Background

# Symbols
SYM_CHECK="${BI_GREEN}✓${B_GREEN}"   # Bold Green Ok Check Symbol
SYM_CROSS="${BI_RED}✗${B_RED}"     # Bold Red Error Cross Symbol
CUR_CLR=""                         # Current Color Set
HOLD="-"

# Establece y guarda color actual.
set_clr() {
  CUR_CLR="$1"
}

# Devuelve el color actual.
get_clr() {
  echo "$CUR_CLR"
}

# Insertar texto de otro color dentro de un mensage.
t() {
  echo -e "${2}${1}$(get_clr)"
}

# Muestra mensaje en cualquier color.
msg() {
  echo -e "$(get_clr)${1}${CLR_OFF}"
}

# Muestra mensaje de exito con icono al inicio.
msg_ok() {
  echo -e "${SYM_CHECK}${B_GREEN} ${1}${CLR_OFF}"
}

# Muestra mensaje de error con icono al inicio.
msg_err() {
  echo -e "${SYM_CROSS}${B_RED} ${1}${CLR_OFF}"
}

# Muestra mensajes de infos.
msg_info() {
  echo -ne " ${HOLD} ${B_YELLOW}${1}..."
}

# Busca el PATH de un archivo, paquete o aplicacion.
find_path() {
  local FILE_PATH=""
  local FILE="${1}"
  local BIN="${2}"
  if [[ -z "${BIN}" ]]; then
    BIN="bin"
  fi

  if ! [[ -z "${FILE}" ]]; then
    FILE_PATH=`find / -type f -name "${FILE}" 2>/dev/null | fgrep -w "${BIN}"`
  fi
  echo "${FILE_PATH}"
}

# Reemplaza texto dentro de otro texto.
replace() {
  local str="$1"
  local search="$2"
  local replace="$3"
  local options="$4" #g=global, i=sin distincion de mayusc/minusc

  if [[ "$str" != "" ]]; then #&& "$search" != "" && "$replace" != ""
    if [[ "$options" != "" ]]; then
      if [[ "$options" != "g" && "$options" != "i" && "$options" != "gi" ]]; then
        options=""
      fi
    fi
    str=$(echo $str | sed "s/$search/$replace/$options")
  fi
  echo $str
}

# Convierte texto/s en minusculas.
lower() {
  local str="$@"
  local output

  output=$(tr '[A-Z]' '[a-z]'<<<"${str}")

  echo $output
}

# Convierte texto/s en mayusculas.
upper() {
  local str="$@"
  local output
  
  output=$(tr '[a-z]' '[A-Z]'<<<"${str}")

  echo $output
}

# Capitaliza texto/s.
proper() {
  local str=$(lower "$@")
  local mode="${*: -1}"
  local output

  if [[ "${mode}" == "--full-text" ]]; then
    str=$(replace "$str" "--full-text" "")
    output=$(echo "${str^}")
  else
    output=$(tr '[A-Z]' '[a-z]'<<<"${str}")
    output=$(echo $output | sed 's/\b\([[:alpha:]]\)\([[:alpha:]]*\)\b/\u\1\L\2/g')
  fi
  echo $output
}

# Devuelve una sub-cadena desde una cadena segun delimintador y posicion.
# Parametros: $1=Cadena, $2=Delimitador, $3=Pos. sub-cadena a devolver.
substr() {
  echo "$1"| cut -d"$2" -f $(("$3"))
}

# Repite un caracter n veces.
repeat() {
  local CHAR="${1}"
  local NTIMES=$(("$2"))

  local STR=""
  for (( i=1; i<=$NTIMES; i++ ))
  do 
    STR+="${CHAR}"
  done

  echo -e "$STR"
}


# Muestra un cuadro con el nombre y version del script
script_info() {
  IFS=
  local BG_CLR="${1}"
  local F_CLR="${2}"
  local S_CLR="${3}"

  if [[ -z "${F_CLR}" ]]; then
    F_CLR="${B_WHITE}"
  fi
  if [[ -z "${S_CLR}" ]]; then
    S_CLR="${B_CYAN}"
  fi
  if [[ -z "${BG_CLR}" ]]; then
    BG_CLR="${BG_BLUE}"
  fi

  [[ -z "${SCRIPT_NAME}" || -z "${VERSION}" || -z "${AUTHOR}" || -z "${LAST_UPDATED}" ]]; SCRIPT_INFO=$?
  if [[ "${SCRIPT_INFO}" ]]; then
    set_clr "${BG_CLR}${F_CLR}";
    local TEXT="│ ${SCRIPT_NAME} v${VERSION} - (c)$(substr ${LAST_UPDATED} '-' 3) by ${AUTHOR} │"
    local LEN_TEXT=${#TEXT}-2
    msg "┌$(repeat '─' ${LEN_TEXT})┐"
    msg "│ $(t ${SCRIPT_NAME} ${S_CLR}) v${VERSION} - (c)$(substr ${LAST_UPDATED} '-' 3) by ${AUTHOR} │"
    msg "└$(repeat '─' ${LEN_TEXT})┘"
    echo
  fi
}


# Crea, modifica o elimina grupos de Linux.
group_system() {
  # Si no estan definidas estas variables, intentamos obtener de args...
  if [[ -z "$target" && -z "$action" && -z "$groupname" ]]; then
    # Recibimos argumentos como array...
    local args=("$@")   

    # De un array indexado pasamos a uno asociativo...
    declare -A groupdata=()
    for i in "${args[@]}"; do
      IFS=':' read -r -a array <<< "$i"
      groupdata["${array[0]}"]="${array[1]}"
    done

    local target="${groupdata['target']}" || ""
    local action="${groupdata['action']}" || ""
    local gid="${groupdata['gid']}" || ""
    local groupname="${groupdata['groupname']}" || ""
    local passwd="${groupdata['passwd']}" || ""
    local pwd=""
  fi

  # El target tiene que ser 'group'...
  if [[ "$target" != "group" ]]; then
    echo; return 1;
  fi

  # Debemos recibir un nombre de grupo válido..."
  if [[ "$groupname" == "" ]]; then
    echo; return 1;
  fi

  # Si se paso una contraseña, debemos encryptar...
  if [[ "$passwd" != "" ]]; then
    pwd=`openssl passwd -1 ${passwd}`;
  fi

  # Aqui comenzamos...
  if [[ "${action}" == 'create' ]]; then
    if ! grep -q "^$groupname:" /etc/group; then
      groupadd ${gid:+-g"$gid"} \
        ${pwd:+--password"$pwd"} \
        "$groupname"
      return $?;
    fi

  elif [[ "${action}" == 'modify' ]]; then
    local newgroupname="${groupdata['newgroupname']}" || ""

    if grep -q "^$groupname:" /etc/group; then
      groupmod ${gid:+--gid"$gid"} \
        ${newgroupname:+--new-name"$newgroupname"} \
        ${pwd:+--password"$pwd"} \
        "$groupname"
      return $?;
    fi

  elif [[ "${action}" == 'delete' ]]; then
    if grep -q "^$groupname:" /etc/group; then
      groupdel -f "$groupname"
      return $?;
    fi
    
  fi
  echo; return 1;
}


# Crea, modifica o elimina usuarios de Linux.
user_system() {
  # Si no estan definidas estas variables, intentamos obtener de args...
  if [[ -z "$target" && -z "$action" && -z "$username" ]]; then
    # Recibimos argumentos como array...
    local args=("$@")

    # De un array indexado pasamos a uno asociativo...
    declare -A userdata=()
    for i in "${args[@]}"; do
      IFS=':' read -r -a array <<< "$i"
      userdata["${array[0]}"]="${array[1]}"
    done

    # echo "keys: ${!userdata[@]}"
    # echo "values: ${userdata[@]}"
    local target="${userdata['target']}" || ""
    local action="${userdata['action']}" || ""
    local username="${userdata['username']}" || ""
    local passwd="${userdata['passwd']}" || ""
    local pwd=""
    local uid="${userdata['uid']}" || ""
    local gid="${userdata['gid']}" || ""
    local realname="${userdata['realname']}" || ""
    local homedir="${userdata['homedir']}" || ""
    local shell="${userdata['shell']}" || ""
    local groups="${userdata['groups']}" || ""
    local sudoers="${userdata['sudoers']}" || ""
  fi

  # El target tiene que ser 'user'...
  if [[ "$target" != "user" ]]; then
    # echo 1; return
    echo; return 1;
  fi

  # Debemos recibir un nombre de usuario válido..."
  if [[ "$username" == "" ]]; then
    # echo 1; return
    echo; return 1;
  fi

  # Si se paso una contraseña, debemos encryptar...
  if [[ "$passwd" != "" ]]; then
    pwd=`openssl passwd -1 ${passwd}`;
  fi

  # Reemplazams espacios por _ para el nombre...
  if [[ "$realname" != "" ]]; then
    realname=${realname//[_]/' '};
  fi
  
  if [[ "${action}" == 'create' ]]; then
    if [[ "$homedir" != "" ]]; then
      # homedir="-m -d ${homedir}";
      homedir="-m";
    else
      homedir="-M"
    fi

    if [[ "$shell" == "" ]]; then
      shell="/bin/false"
    fi

    adduser ${pwd:+-p"$pwd"} \
      ${uid:+-u"$uid"} \
      ${gid:+-g"$gid"} \
      ${realname:+-c"$realname"} \
      ${homedir:+"$homedir"} \
      "$username"
      # ${groups:+-G "$groups"} \
      # ${shell:+--shell="$shell"} \
    local retval=$?;
    if [[ ${retval} == 0 && "${sudoers}" == "sudo" ]]; then
      usermod -aG wheel "${username}"
      if [[ $? == 0 ]]; then
        isSudo="true"
      fi
    fi
    return ${retval};

  elif [[ "${action}" == 'modify' ]]; then
    local newusername="${userdata['newusername']}" || ""
    if [[ "$homedir" != "" ]]; then
      homedir="-m -d ${homedir}";
    fi

    if grep -q "^$username:" /etc/passwd; then
      usermod ${pwd:+-p"$pwd"} \
        ${uid:+-u"$uid"} \
        ${gid:+-g"$gid"} \
        ${realname:+-c"$realname"} \
        ${newusername:+-l"$newusername"} \
        "$username";

        # ${homedir:+"$homedir"} \
        # ${groups:+-G "$groups"} \
        # ${shell:+-s "$shell"} \
      local retval=$?;
      if [[ ${retval} == 0 && "${sudoers}" == "sudo" ]]; then
        usermod -aG wheel "${username}"
        if [[ $? == 0 ]]; then
          isSudo="true"
        fi
      fi
      return ${retval};
    fi

  elif [[ "${action}" == 'delete' ]]; then
    if grep -q "^$username:" /etc/passwd; then
      userdel -r -f "$username";
      return $?;
    fi
  fi
  echo; return 1;
}


# Crea, modifica o elimina usuarios de Samba.
smb_user_system() {
  # Si no estan definidas estas variables, intentamos obtener de args...
  if [[ -z "$target" && -z "$action" && -z "$username" ]]; then
    # Recibimos argumentos como array...
    local args=("$@")   

    # De un array indexado pasamos a uno asociativo...
    declare -A userdata=()
    for i in "${args[@]}"; do
      IFS=':' read -r -a array <<< "$i"
      userdata["${array[0]}"]="${array[1]}"
    done

    local target="${userdata['target']}" || ""
    local action="${userdata['action']}" || ""
    local passwd="${userdata['passwd']}" || ""
    local username="${userdata['username']}" || ""
  fi

  # El target tiene que ser 'user'...
  if [[ "$target" != "user" ]]; then
    echo; return 1;
  fi

  # Debemos recibir un nombre de usuario válido..."
  if [[ "$username" == "" ]]; then
    echo; return 1;
  fi

  # PARA SAMBA la password de ser texto plano..
  # if [[ "$passwd" != "" ]]; then
  #   pwd=$(openssl passwd -1 $passwd);
  # fi

  if [[ "${action}" == 'create' ]]; then
    echo -e "$passwd\n$passwd" | smbpasswd -s -a "$username"
    return $?;
  
  elif [[ "${action}" == 'modify' ]]; then
    local newusername="${userdata['newusername']}" || ""
    if [grep -q "^$username:" /etc/passwd && ! grep -q "^$newusername:" /etc/passwd]; then
      pdbedit -x "$username";
      echo -e "$passwd\n$passwd" | smbpasswd -s -a "$newusername"
      return $?;
    fi

  elif [[ "${action}" == 'delete' ]]; then
    if grep -q "^$username:" /etc/passwd; then
      # smbpasswd -x "$username";
      pdbedit -x "$username";
      return $?;
    fi
  fi
  echo; return 1;
}
