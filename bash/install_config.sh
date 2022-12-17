#! /bin/bash
#
# Script para Instalar, Actualizar y Configurar entorno Linux de forma rapida.
#
# Author: Antonio da Silva <adsmicrosistemas@gmail.com> (https://adsmicrosistemas.com)
#

SCRIPT_NAME="Install and Config Script"
AUTHOR="Antonio da Silva"
VERSION="2.0"
LAST_UPDATED="17-12-2022"

# Abrimos archivo de configuracion, debe estar en la ruta del script...
ADS_CONFIG_FILE=`dirname "$0"`
ADS_CONFIG_FILE=`( cd "$ADS_CONFIG_FILE" && pwd )`
ADS_CONFIG_FILE="$ADS_CONFIG_FILE/install_config.ini"
if [ ! -f "${ADS_CONFIG_FILE}" ]; then
  echo "Error! Config file not found. [${ADS_CONFIG_FILE}]"
  exit 1
fi
. "${ADS_CONFIG_FILE}" >/dev/null 2>&1

# Cargamos variables y funciones para decorar textos...
if [ ! -f "${ADS_TOOLS}" ]; then
  echo "Error! Script library file not found."
  exit 1
fi
. "${ADS_TOOLS}" >/dev/null 2>&1
clear
script_info

# Get distro name & version...
OS_NAME=""
OS_VERSION=""
if [ -f /etc/os-release ]; then
  . /etc/os-release
  OS_NAME=$ID_LIKE
  OS_VERSION=$VERSION_ID
fi

SUDOR="";
if [ $(id -u) -ne 0 ]; then
  SUDOR="sudo "
fi
RESTART_SSH_OR_NOT='nn' # No reiniciar ssh por defecto!
SET_DEF_LOCALE='nn' # No establecer por defecto locale!

PAKMAN=""
if [[ "$OS_NAME" == *"debian"* ]]; then # "ubuntu"
  PAKMAN="apt-get"
elif [[ "$OS_NAME" == *"rhel"* ]]; then
  PAKMAN="dnf"
  if [[ "$ID" == "centos" ]]; then
    PAKMAN="yum"
  fi
fi
if [ -z "$PAKMAN" ]; then
  set_clr "${B_RED}"; msg_err "Linux version error. Id:[$(t $OS_NAME ${B_WHITE})], v:[$(t $OS_VERSION ${B_WHITE})]\n"
  exit 1
fi

# Param...
ALL_YESNO="xxx";
for i in "$@"; do
  case $i in
    -y|--yes)
      ALL_YESNO="yes|y"
      shift
      ;;
    -n|--no)
      ALL_YESNO="no|n"
      shift
      ;;
    -*|--help|--*)
      if [[ "${i}" != "-h" && "${i}" != "--help" ]]; then
        set_clr "${B_RED}"; msg_err "Unknown option: $(t $i ${BG_RED}${B_WHITE})\n"
      fi

      set_clr "${CYAN}" 
      msg "Option:"
      msg "  $(t '-h' ${B_WHITE}), $(t '--help' ${B_WHITE}) show options"

      exit 1
      ;;
    *)
      ;;
  esac
done


#--------------------------------------------------------------------------------
#----- Alias, Hostname, Hosts, Network, etc -----
countItems=${#CONFIG_DATA[@]}
for ((i=0; i<$countItems; i++)); do
  configItem=$(echo -e ${!CONFIG_DATA[i]:0:1})
  configFile=$(echo -e ${!CONFIG_DATA[i]:1:1})
  configCont=$(echo -e ${!CONFIG_DATA[i]:2:1})
  configOpt=$(echo -e ${!CONFIG_DATA[i]:3:1})
  CONFIG_ADD=$(echo -e ${!CONFIG_DATA[i]:4:1})

  resp="x";
  if [[ "yes|y" == *"${ALL_YESNO}"* ]]; then
    resp="y";
  elif [[ "no|n" == *"${ALL_YESNO}"* ]]; then
    resp="n";
  fi
  if [[ "x" == *"${resp}"* ]]; then
    resp=$(prompt "Do you want to set config of: $(t ${configItem} ${B_WHITE})${CLR_OFF}");
    if [[ "${resp}" == "yy"  ]]; then
      ALL_YESNO="yes|y"
    elif [[ "${resp}" == "nn" ]]; then
      ALL_YESNO="no|n"
    fi
  fi

  if [[ "yes|y" == *"${resp}"* ]]; then
    settingCfg=1
    while [[ ${settingCfg} == 1 ]]; do
      if [[ -z "${configFile}" || "${configFile}" == "" ]]; then
        set_clr "${B_RED}"; msg_err "No config file specified: $(t ${configItem} ${BG_RED}${B_WHITE})\n"
        continue;
      fi

      if [[ -z "${configCont}" || "${configCont}" == "" ]]; then
        set_clr "${B_RED}"; msg_err "No config setting for: $(t ${configItem} ${BG_RED}${B_WHITE})\n"
        continue;
      fi

      if [[ "${configOpt}" == "verifyAdd" ]]; then
        if [ -f "${configFile}" ]; then
          set_clr "${B_GREEN}"; msg "Setting config in: $(t ${configFile} ${B_WHITE})"

          outputFile="${configFile}_tmp"
          insertdata_tofile "${configFile}" "${configCont}" "${outputFile}"
          
          if [ -f "${outputFile}" ]; then
            mv -f "${outputFile}" "${configFile}"
          fi
        fi
      elif [[ "${configOpt}" == "overWrite" ]]; then
        set_clr "${B_GREEN}"; msg "Setting config in: $(t ${configFile} ${B_WHITE})"

        echo -e "${configCont}" > "${configFile}"
      fi

      settingCfg=0;
      if [[ "${CONFIG_ADD}" != "--"  ]]; then
        configItem=$(echo -e ${!CONFIG_ADD[0]:0:1})
        configFile=$(echo -e ${!CONFIG_ADD[0]:1:1})
        configCont=$(echo -e ${!CONFIG_ADD[0]:2:1})
        configOpt=$(echo -e ${!CONFIG_ADD[0]:3:1})
        CONFIG_ADD=$(echo -e ${!CONFIG_ADD[0]:4:1})
        
        settingCfg=1;
      fi
    done
  fi
done


#--------------------------------------------------------------------------------
#----- Change the machine-id, locale, language packs, etc -----
countItems=${#CONFIG_EXTRA[@]}
for ((i=0; i<$countItems; i++)); do
  # ["SO o any"]["BEFORE o --"]["lista de comandos"]["Mensaje1"]["Mensaje2"]["Mensaje2"]["AFTER o --"]["Cmd Adicional]"
  osName=$(echo -e ${!CONFIG_EXTRA[i]:0:1})
  beforeCmdsList=$(echo -e ${!CONFIG_EXTRA[i]:1:1})
  commandsList=$(echo -e ${!CONFIG_EXTRA[i]:2:1})
  msgUser1=$(echo -e ${!CONFIG_EXTRA[i]:3:1})
  msgUser2=$(echo -e ${!CONFIG_EXTRA[i]:4:1})
  msgUser3=$(echo -e ${!CONFIG_EXTRA[i]:5:1})
  afterCmdsList=$(echo -e ${!CONFIG_EXTRA[i]:6:1})
  ADD_CMDS=$(echo -e ${!CONFIG_EXTRA[i]:7:1});

  arrBeforeCmdsList=();
  if [[ "${beforeCmdsList}" != "--"  ]]; then
    IFS='|' read -r -a arrBeforeCmdsList <<< "$beforeCmdsList"
  fi

  arrCommandsList=();
  if [[ "${commandsList}" != "--"  ]]; then
    IFS='|' read -r -a arrCommandsList <<< "$commandsList"
  fi

  arrAfterCmdsList=();
  if [[ "${afterCmdsList}" != "--"  ]]; then
    IFS='|' read -r -a arrAfterCmdsList <<< "$afterCmdsList"
  fi

  resp="x";
  if [[ "yes|y" == *"${ALL_YESNO}"* ]]; then
    resp="y";
  elif [[ "no|n" == *"${ALL_YESNO}"* ]]; then
    resp="n";
  fi
  if [[ "x" == *"${resp}"* ]]; then
    msgUser1=$(eval echo "${msgUser1}");
    if [[ "${msgUser1}" == "yy"  ]]; then
      resp="y";
    elif [[ "${msgUser1}" == "nn" || "${msgUser1}" == "--" ]]; then
      resp="n";
    else
      if [[ "$OS_NAME" == *"${osName}"* || "${osName}" == "any" ]]; then
        resp=$(prompt "${msgUser1}");
      fi
    fi
  
    if [[ "${resp}" == "yy"  ]]; then
      ALL_YESNO="yes|y"
    elif [[ "${resp}" == "nn" ]]; then
      ALL_YESNO="no|n"
    fi
  fi

  if [[ "yes|y" == *"${resp}"* ]]; then
    if [[ "$OS_NAME" == *"${osName}"* || "${osName}" == "any" ]]; then
      if [[ "${beforeCmdsList}" != "--"  ]]; then
        for cmdToRun in "${arrBeforeCmdsList[@]}"; do
          # echo "1_cmdToRun:[${cmdToRun}]"
          eval "${cmdToRun}"
        done
      fi

      if [[ "${msgUser2}" != "--"  ]]; then
        msgUser2=$(eval echo "\$${msgUser2}");
        set_clr "${B_GREEN}"; msg "${msgUser2}"
      fi

      if [[ "${commandsList}" != "--"  ]]; then
        for cmdToRun in "${arrCommandsList[@]}"; do
          # echo "2_commandsList:[${cmdToRun}]"
          eval "${cmdToRun}"
        done
      fi

      if [[ "${afterCmdsList}" != "--"  ]]; then
        for cmdToRun in "${arrAfterCmdsList[@]}"; do
          # echo "3_afterCmdsList:[${cmdToRun}]"
          eval "${cmdToRun}"
        done
      fi

      if [[ "${ADD_CMDS}" != "--" ]]; then
        count="${#ADD_CMDS[@]}"

        if [[ ${count} > 0 ]]; then
          tmpCmd=$(echo -e ${!ADD_CMDS[0]});
          
          arrAddCmds=();
          if [[ "${tmpCmd}" != "--"  ]]; then
            IFS=',' read -r -a arrAddCmds <<< "$tmpCmd"
          fi

          count="${#arrAddCmds[@]}";
          n=0;
          while (( $n <= $count )); do
            msgTmp=$(eval echo "${arrAddCmds[n]}");
            if [[ "${msgTmp}" != "--"  ]]; then
              set_clr "${msgTmp}";
            fi

            n=$(( n+1 ));
            msgTmp=$(eval echo "${arrAddCmds[n]}");
            if [[ "${msgTmp}" != "--"  ]]; then
              msg "${msgTmp}";
            fi

            n=$(( n+1 ));
            if [[ "${arrAddCmds[n]}" != "--"  ]]; then
              eval "${arrAddCmds[n]}";
            fi
            n=$(( n+1 ));
          done
        fi
      fi
    fi
    if [[ "${msgUser3}" != "--"  ]]; then
      msgUser3=$(eval echo "\$${msgUser3}");
      set_clr "${B_GREEN}"; msg "${msgUser3}"
    fi
  fi
done


#--------------------------------------------------------------------------------
#----- Update, etc -----
countItems=${#CONFIG_SETS[@]}
for ((i=0; i<$countItems; i++)); do
  # "Sistema/Operativo o any" "lista de comandos" "Mensaje1" "Mensaje2"
  osName=$(echo -e ${!CONFIG_SETS[i]:0:1})
  configSetList=$(echo -e ${!CONFIG_SETS[i]:1:1})
  msgUser1=$(echo -e ${!CONFIG_SETS[i]:2:1})
  msgUser2=$(echo -e ${!CONFIG_SETS[i]:3:1})
  msgUser3=$(echo -e ${!CONFIG_SETS[i]:4:1})
  
  arrConfigSetList=();
  if [[ "${configSetList}" != "--"  ]]; then
    IFS='|' read -r -a arrConfigSetList <<< "$configSetList"
  fi
 
  resp="x";
  if [[ "yes|y" == *"${ALL_YESNO}"* ]]; then
    resp="y";
  elif [[ "no|n" == *"${ALL_YESNO}"* ]]; then
    resp="n";
  fi
  if [[ "x" == *"${resp}"* ]]; then
    msgUser1=$(eval echo "${msgUser1}");
    if [[ "${msgUser1}" == "yy"  ]]; then
      resp="y";
    elif [[ "${msgUser1}" == "nn" ]]; then
      resp="n";
    else
      if [[ "$OS_NAME" == *"${osName}"* || "${osName}" == "any" ]]; then
        resp=$(prompt "${msgUser1}");
      fi
    fi
    
    if [[ "${resp}" == "yy"  ]]; then
      ALL_YESNO="yes|y"
    elif [[ "${resp}" == "nn" ]]; then
      ALL_YESNO="no|n"
    fi
  fi

  if [[ "yes|y" == *"${resp}"* ]]; then
    if [[ "${msgUser2}" != "--"  ]]; then
      msgUser2=$(eval echo "\$${msgUser2}");
      set_clr "${B_GREEN}"; msg "${msgUser2}"
    fi

    if [[ "$OS_NAME" == *"${osName}"* || "${osName}" == "any" ]]; then
      for cmdToRun in "${arrConfigSetList[@]}"; do
        if [[ "${cmdToRun}" != "--"  ]]; then
          eval "${cmdToRun}";
        fi
      done

      if [[ "${msgUser3}" != "--"  ]]; then
        msgUser3=$(eval echo "\$${msgUser3}");
        set_clr "${B_GREEN}"; msg "${msgUser3}"
      fi
    fi
  fi
done


#--------------------------------------------------------------------------------
#----- Install Packs, Midnight Commander, nano, clear, tar, wget, curl, etc -----
countItems=${#CONFIG_APPS[@]}
for ((i=0; i<$countItems; i++)); do
  # ["OSName"] ["appBinary ó --"] ["Fullname|Msg"] ["installerList"] ["extraCmdsList o --"]
  osName=$(echo -e ${!CONFIG_APPS[i]:0:1})
  appBinary=$(echo -e ${!CONFIG_APPS[i]:1:1})
  appFullName=$(echo -e ${!CONFIG_APPS[i]:2:1})
  installerList=$(echo -e ${!CONFIG_APPS[i]:3:1})
  extraCmdsList=$(echo -e ${!CONFIG_APPS[i]:4:1})
  
  if [[ "$OS_NAME" == *"${osName}"* || "${osName}" == "any" ]]; then
    arrInstallerList=();
    if [[ "${installerList}" != "--"  ]]; then
      IFS='|' read -r -a arrInstallerList <<< "$installerList"
    fi

    arrExtraCmdsList=();
    if [[ "${extraCmdsList}" != "--"  ]]; then
      IFS='|' read -r -a arrExtraCmdsList <<< "$extraCmdsList"
    fi

    resp="x";
    if [[ "yes|y" == *"${ALL_YESNO}"* ]]; then
      resp="y";
    elif [[ "no|n" == *"${ALL_YESNO}"* ]]; then
      resp="n";
    fi
    if [[ "x" == *"${resp}"* ]]; then
      resp=$(prompt "Do you want to install $(t ${appFullName} ${B_WHITE})${CLR_OFF}");
      if [[ "${resp}" == "yy"  ]]; then
        ALL_YESNO="yes|y"
      elif [[ "${resp}" == "nn" ]]; then
        ALL_YESNO="no|n"
      fi
    fi

    if [[ "yes|y" == *"${resp}"* ]]; then
      APP_INSTALLED=0 

      if [[ "${appBinary}" != "--"  ]]; then
        set_clr "${B_CYAN}"; msg "Searching for $(t ${appFullName} ${B_WHITE}) installed..."
      
        PATH_BIN=$(find_path "${appBinary}")
        [[ -z "${PATH_BIN}" ]]; APP_INSTALLED=$?

        if [[ "${APP_INSTALLED}" && "${PATH_BIN}" ]]; then # && -f "${PATH_BIN}"
          set_clr "${B_GREEN}"; msg_ok "$(t ${appFullName} ${B_WHITE}) is already installed!"
        fi
      fi

      if [[ ${APP_INSTALLED} == 0 ]]; then
        set_clr "${B_GREEN}"; msg "Installing $(t ${appFullName} ${B_WHITE})..."
        for apkToInstall in "${arrInstallerList[@]}"; do
          if [[ "${apkToInstall}" != "--"  ]]; then
            eval "${apkToInstall}";
          fi
        done

        for cmdToRun in "${arrExtraCmdsList[@]}"; do
          if [[ "${cmdToRun}" != "--"  ]]; then
            eval ${cmdToRun}
          fi
        done
      fi
    fi
  fi
done

echo -e "\n"; msg_ok "Config completed!"
