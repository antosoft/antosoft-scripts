#!/bin/bash
#
# Script para crear/modificar/eliminar grupos y usuarios en el sistema a partir
# de una archivo de texto formateado que se utiliza como entrada de datos.
#
# Author: Antonio da Silva <adsmicrosistemas@gmail.com> (https://adsmicrosistemas.com)
#
# Input: File data format
# -----------------------
# group:create:groupname:passwd:gid:
# group:modify:groupname:passwd:gid:newgroupname:
# group:delete:groupname:
#
# user:create:username:passwd:uid:gid:realname:homedir:shell:groups:sudo|nosudo:
# user:modify:username:passwd:uid:gid:realname:homedir:shell:newusername:groups:sudo|nosudo:
# user:delete:username:
# -------------------------------------------------------------------

# Funcion para crear/modificar/eliminar grupos de Linux.
cmd_group() {
  # Procesamos solo grupos...
  if [[ "${array[0]}" == 'group' ]]; then
    array[2]="${array[2]}" || ""  # groupname
    if [[ "${array[2]}" == "" ]]; then
      set_clr "${B_RED}"; msg_err "Nombre de grupo no válido..."
      echo; return 1;
    fi

    array[3]="${array[3]}" || ""    # passwd
    array[4]="${array[4]}" || ""    # gid
    array[5]="${array[5]}" || ""    # newgroupname

    local msgText="Creando"
    local msgErr="crear"
    local msgOk="Creado!"
    local msgClr="${B_GREEN}"
    if [[ "${array[1]}" == "create" ]]; then
      # Verificamos que el grupo EXISTA!
      if grep -q "^${array[2]}:" /etc/group; then
        set_clr "${B_YELLOW}"; msg "Grupo: [$(t ${array[2]} ${B_WHITE})] ya existe!"
        echo; return 1;
      fi
    else
      msgText="Modificando"; msgErr="modificar"; msgOk="Modificado!"; msgClr="${B_GREEN}"
      if [[ "${array[1]}" == "delete" ]]; then
        msgText="Eliminando"; msgErr="eliminar"; msgOk="Eliminado!"; msgClr="${B_RED}"
      fi
      
      # Si el grupo NO EXISTE...
      set_clr "${B_CYAN}"; msg "Buscando grupo: [$(t ${array[2]} ${B_WHITE})] para ${msgErr}..."
      if ! grep -q "^${array[2]}:" /etc/group; then
        set_clr "${B_RED}"; msg_err "Grupo: [$(t ${array[2]} ${B_WHITE})] no existe!"
        echo; return 1;
      fi
    fi

    set_clr "${msgClr}"; msg "${msgText} grupo: [$(t ${array[2]} ${B_WHITE})]..."
    group_system "target:${array[0]}" \
      "action:${array[1]}" \
      "groupname:${array[2]}" \
      "passwd:${array[3]}" \
      "gid:${array[4]}" \
      "newgroupname:${array[5]}"
    local retval=$?;
    if [[ ${retval} > 0 ]]; then
      set_clr "${B_RED}"; msg "Error al intentar ${msgErr} grupo: [$(t ${array[2]} ${B_WHITE})]!"
    else
      msg_ok "${msgOk}"
    fi
    echo; return ${retval}
  fi
  echo; return 1;
}


# Funcion para crear/modificar/eliminar usuarios de Linux.
cmd_user() {
  # Procesamos solo usuarios...
  if [[ "${array[0]}" == 'user' ]]; then
    local usrname="${array[2]}" || ""  # username 
    if [[ "${usrname}" == "" ]]; then
      set_clr "${B_RED}"; msg "Nombre de usuario no válido..."
      echo; return 1;
    fi

    # if [[ "create|modify" == *"${array[1]}"* ]]; then
    array[3]="${array[3]}" || ""  # passwd 
    array[4]="${array[4]}" || ""  # uid
    array[5]="${array[5]}" || ""  # gid
    array[6]="${array[6]}" || ""  # realname
    array[7]="${array[7]}" || ""  # homedir
    array[8]="${array[8]}" || ""  # shell
    array[9]="${array[9]}" || ""  # groups
    array[10]="${array[10]}" || ""  # newusername
    array[11]="${array[11]}" || "nosudo"  # sudo|nosudo

    # fi
    local isSudo="false"
    local msgText="Creando"
    local msgErr="crear"
    local msgOk="Creado!"
    local msgClr="${B_GREEN}"
    if [[ "${array[1]}" == "create" ]]; then
      # Verificamos que el usuario NO EXISTA!
      if grep -q "^${usrname}:" /etc/passwd; then
        set_clr "${B_YELLOW}"; msg "Usuario: [$(t ${usrname} ${B_WHITE})] ya existe!"
        echo; return 1;
      fi
    else
      msgText="Modificando"; msgErr="modificar"; msgOk="Modificado!"; msgClr="${B_CYAN}"
      if [[ "${array[1]}" == "delete" ]]; then
        msgText="Eliminando"; msgErr="eliminar"; msgOk="Eliminado!"; msgClr="${B_RED}"
      fi

      # Si NO EXISTE el usuario! bye
      set_clr "${B_CYAN}"; msg "Buscando usuario: [$(t ${usrname} ${B_WHITE})] para ${msgErr}..."
      if ! grep -q "^${usrname}:" /etc/passwd; then
        set_clr "${B_RED}"; msg_err "Usuario: [$(t ${usrname} ${B_WHITE})] no existe!"
        echo; return 1;
      fi
    fi

    # Aqui intentamos crear el nuevo usuario...
    set_clr "${msgClr}"; msg "${msgText} usuario: [$(t ${usrname} ${B_WHITE})]..."
    user_system "target:${array[0]}" \
      "action:${array[1]}" \
      "username:${usrname}" \
      "passwd:${array[3]}" \
      "uid:${array[4]}" \
      "gid:${array[5]}" \
      "realname:${array[6]}" \
      "homedir:${array[7]}" \
      "shell:${array[8]}" \
      "groups: ${array[9]}" \
      "newusername:${array[10]}" \
      "sudoers:${array[11]}"
    local retval=$?;
    if [[ ${retval} > 0 ]]; then
      set_clr "${B_RED}"; msg "Error al intentar ${msgErr} usuario: [$(t ${usrname} ${B_WHITE})]!"
      echo; return ${retval};
    else
      msg_ok "${msgOk}"
      if [[ "${isSudo}" == "true" ]]; then
        set_clr "${B_PURPLE}"; msg "Usuario: [$(t ${usrname} ${B_WHITE})] agregado al grupo Sudo!"
      fi
    fi

    if [[ "$smbUser" == "--smb-user" ]]; then
      cmd_samba_user
      if [[ $? > 0 ]]; then
        echo; return $?;
      fi
    fi
  fi
  echo; return 1;
}


# Funcion para crear/modificar/eliminar usuarios para Samba.
cmd_samba_user() {
  # Procesamos solo usuarios...
  if [[ "${array[0]}" == 'user' ]]; then
    array[2]="${array[2]}" || ""
    array[3]="${array[3]}" || ""

    if [[ "${array[2]}" == "" ]]; then 
      set_clr "${B_RED}"; msg_err "Nombre de usuario no válido..."
      echo; return 1;
    fi

    local msgText="Creando"; local msgErr="crear"
    if [[ "${array[1]}" == "modify" ]]; then
      msgText="Modificando"; msgErr="modificar"
    elif [[ "${array[1]}" == "delete" ]]; then
      msgText="Eliminando"; msgErr="eliminar"
    fi

    set_clr "${B_PURPLE}"; msg "${msgText} usuario samba: [$(t ${array[2]} ${B_WHITE})]..."
    smb_user_system "target:${array[0]}" \
      "action:${array[1]}" \
      "username:${array[2]}" \
      "passwd:${array[3]}"
    local retval=$?;
    if [[ ${retval} > 0 ]]; then
      set_clr "${B_RED}"; msg "Error al intentar ${msgErr} usuario samba: [$(t ${array[2]} ${B_WHITE})]!"
    fi
    echo; return ${retval};
  fi
  echo; return 1;
}

# -------------------------------------- 
# Funcion principal de user_manager
main() {
  local SCRIPT_NAME="User Manager Script"
  local AUTHOR="Antonio da Silva"
  local VERSION="1.2"
  local LAST_UPDATED="26-11-2022"

  # Cargamos variables y funciones para decorar textos...
  # local ADS_TOOLS="/var/shared/antosoft/scripts/ads_tools.sh"
  local ADS_TOOLS="ads_tools.sh"
  if [ ! -f "${ADS_TOOLS}" ]; then
    echo "Error! libreria de scripts no encontrado."
    exit 1
  fi
  . "${ADS_TOOLS}" >/dev/null 2>&1
  clear
  script_info "${BG_PURPLE}"

  # Parametros...
  local fileName="$1"
  local smbUser="$2"

  # Verificamos si somos root...
  if [ $(id -u) -ne 0 ]; then
    echo
    set_clr "${B_YELLOW}"; msg "Este script debe ejecutarse como Usuario $(t root ${B_RED})!"
    echo; return 1;
  fi

  if [[ -z $fileName ]]; then
    set_clr "${B_RED}"; msg_err "Debe especificar un $(t 'archivo.txt' ${B_WHITE}) como entrada!"
    echo
    set_clr "${B_CYAN}"
    msg "Mode de uso: $(t './user_manager.sh archivo.txt' ${B_WHITE})"
    echo
    msg "$(t 'Opciones' ${B_GREEN})"
    msg "$(t '--smb-user' ${B_WHITE})      :Procesar tambien usuarios de Samba"
    msg "$(t '--smb-user-only' ${B_WHITE}) :Procesar solamente usuarios de Samba"
    msg "$(t '--no-smb-user' ${B_WHITE})   :No procesar usuarios de Samba"
    echo; return 1;
  fi
  if [[ -z $smbUser ]]; then
    smbUser="--no-smb-user"
  else
    if [[ "--smb-user|--smb-user-only" != *"$smbUser"* ]]; then
      smbUser="--no-smb-user"
    fi
  fi

  # Verificamos archivo de entrada...
  if [ ! -f $fileName ]; then
    echo
    set_clr "${B_RED}"; msg_err "Archivo [$(t $fileName ${B_WHITE})] no existe!"
    echo; return 1;
  fi

  # Leemos linea por linea el archivo de entrada...
  echo
  set_clr "${B_CYAN}"; msg "Leyendo grupos/usuarios desde el archivo: [$(t $fileName ${B_WHITE})]..."
  while IFS= read -r line
  do
    # echo "Procesando: $line"
    # Saltamos comentarios o lineas en blanco...
    if [[ -z "${line}" ]] || [[ "#" == *"${line}"* ]]; then
      continue
    fi

    IFS=':' read -r -a array <<< "$line"
    
    if [[ -z "${array[0]}" ]] || [[ -z "${array[1]}" ]] || [[ -z "${array[2]}" ]] || \
        [[ "group|user" != *"${array[0]}"* ]] || \
        [[ "create|modify|delete" != *"${array[1]}"* ]]; then
      continue
    fi

    if [[ "$smbUser" == "--smb-user-only" ]]; then
      cmd_samba_user
      if [[ $? > 0 ]]; then # -gt
        continue
      fi
    else
      # Aqui procesamos grupos...
      if [[ "${array[0]}" == "group" ]]; then
        # [group]:[modify]:[groupname]:[passwd]:[gid]:[newgroupname]
        cmd_group
        if [[ $? > 0 ]]; then #-gt
          continue
        fi

      # Y aqui usuarios...
      elif [[ "${array[0]}" == "user" ]]; then
        # [user]:[modify]:[username]:[passwd]:[uid]:[gid]:[realname]:[homedir]:[shell]:[groups]:[newusername]:[sudo]
        cmd_user
        if [[ $? > 0 ]]; then # -gt
          continue
        fi
      fi
    fi
  done < "$fileName"

  echo; return $?;
}

# Ejecutamos funcion principal...
main "${1}" "${2}"

msg_ok "Proceso completado!"