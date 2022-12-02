# AntoSoft|Scripts
Sometimes I feel very bored repeating the same processes over and over again when creating a new server, whether physical or virtual. Thinking about how to improve this situation, I have created a script that automates some of these processes or at least makes it a bit easier.

I will be adding more scripts over time and/or improving some. **You can also add what you find useful ;)**

I hope it helps you save even a little time by doing these processes.

Enjoy it!
<br><br>

## Bash Scripts

### **[ads_tools.sh]**

### It is a library of bash scripts, mainly for reuse within other scripts to display messages in different colors, etc. These are some of the functions it has:
- set_clr()           **# Sets and saves a current color.**
- get_clr()           **# Returns the current color set with set_color().**
- t()                 **# Insert text of another color inside a message.**
- msg()               **# Display message in any color.**
- msg_ok()            **# Show success message with icon at start.**
- msg_err()           **# Show error message with icon at startup.**
- msg_info()          **# Show info messages.**
- find_path()         **# Find the PATH of a file, package or application.**
- replace()           **# Replace text inside other text.**
- lower()             **# Convert text/s to lowercase.**
- upper()             **# Convert text/s to uppercase.**
- proper()            **# Capitalize text/s.**
- substr()            **# Returns a substring from a string according to delimiter and position.**
- repeat()            **# Repeat a character n times.**
- script_info()       **# Show a box with the name and version of the script**
- group_system()      **# Create, modify, or delete Linux groups.**
- user_system()       **# Create, modify, or delete Linux users.**
- smb_user_system()   **# Create, modify or delete Samba users.**
- insertdata_tofile() **# Insert a chunk of data to a file, in a delimited section.**


### Variable list for colors
| Regular |   Bold   | Intense  |Bold Intense | Underline | Background | Background Intense |
|---------|----------|----------|------------|-----------|------------|------------|
| BLACK   | B_BLACK  | I_BLACK  | BI_BLACK   | U_BLACK   | BG_BLACK   | BGI_BLACK  |
| RED     | B_RED    | I_RED    | BI_RED     | U_RED     | BG_RED     | BGI_RED    |
| GREEN   | B_GREEN  | I_GREEN  | BI_GREEN   | U_GREEN   | BG_GREEN   | BGI_GREEN  |
| YELLOW  | B_YELLOW | I_YELLOW | BI_YELLOW  | U_YELLOW  | BG_YELLOW  | BGI_YELLOW |
| BLUE    | B_BLUE   | I_BLUE   | BI_BLUE    | U_BLUE    | BG_BLUE    | BGI_BLUE   |
| PURPLE  | B_PURPLE | I_PURPLE | BI_PURPLE  | U_PURPLE  | BG_PURPLE  | BGI_PURPLE |
| CYAN    | B_CYAN   | I_CYAN   | BI_CYAN    | U_CYAN    | BG_CYAN    | BGI_CYAN   |
| WHITE   | B_WHITE  | I_WHITE  | BI_WHITE   | U_WHITE   | BG_WHITE   | BGI_WHITE  |

*CLR_OFF: Use for reset color.*
<br><br>


### **[user_manager.sh]**
### I use this script to quickly create groups and users according to a formatted text file with all the necessary data of the group or user to create, modify or delete. This file is taken as input to the script and must be formatted as follows:
- For groups:
  **[group]:[create|modify|delete]:[groupname]:[passwd]:[gid]:[newgroupname]**

- For users:
  **[user]:[create|modify|delete]:[username]:[passwd]:[uid]:[gid]:[realname]:[homedir]:[shell]:[groups]:[newusername]:[sudo]**

**Example of the content of the input file, the fields must be separated by colons:**
```
cat users_groups_list.txt

# Creamos grupos
group:create:antosoft::1000:
group:create:adsmicrosistemas::1001:
group:create:accounting::1002:
group:create:management::1003:

# Creamos usuarios
user:create:antosoft:PassworD:1000:1000:Antonio da Silva:/home/antosoft:/bin/bash:::sudo:
user:create:adsmicrosistemas:PassworD123:1001:1001:AdS Microsistemas:/home/antosoft:/bin/bash:::sudo:
user:create:juanperez:Pass234:1002:1002:Juan Perez:/home/antosoft:/bin/bash:::nosudo:
user:create:elizabethshue:Passxxz:1003:1002:Elizabeth Shue:/home/antosoft:/bin/bash:::nosudo:
user:create:pamela:password565:1004:1003:Pamela Anderson:/home/antosoft:/bin/bash:::nosudo:
user:create:tom:passworxxx:1005:1000:Tom Cruise:/home/antosoft:/bin/bash:::sudo:

# Modificamos usuario
user:modify:antosoft:NewPassworD:1006:1000:Antonio da Silva:/home/antosoft:/bin/bash:newantosoft::sudo:

# Eliminamos grupo
group:delete:adsmicrosistemas:

# Eliminamos usuario
user:delete:adsmicrosistemas:
```

**Usage:**
```
./user_manager.sh

┌────────────────────────────────────────────────────────┐
│ User Manager Script v1.2 - (c)2022 by Antonio da Silva │
└────────────────────────────────────────────────────────┘

✗ Debe especificar un archivo.txt como entrada!

Mode de uso: ./user_manager.sh archivo.txt

Opciones
--smb-user      :Procesar tambien usuarios de Samba
--smb-user-only :Procesar solamente usuarios de Samba
--no-smb-user   :No procesar usuarios de Samba


./user_manager.sh users_groups_list.txt

```
*You can optionally process samba users by passing a second parameter. **(--smb-user | --smb-user-only | --no-smb-user)***

*Important: This script must be executed as the "root" user to be able to create the groups and users.*
<br><br>


### **install_config.sh**
### This script I use to install some packages and configure others, it works like a command line with parameters. Some of the options that can be used are the following, by default they are all set to "yes". If you want not to execute some of the options you must set it to "no". You can also set all the options to "no" with "-d" and then set the one you need with "yes" to execute only that option or options.

**Examples:**
- To display the list of arguments you can type:
```
./install_config.sh --help

┌──────────────────────────────────────────────────────────────┐
│ Install and Config Script v1.0 - (c)2022 by Antonio da Silva │
└──────────────────────────────────────────────────────────────┘

Options (Default all y|yes; Set n|no to skip):
  -d (initial value for all)
  -a, --aliases 
  -h, --hostname
  -l, --locale
  -m, --mcommander
  -n, --nanoeditor
  -s, --sshserver
  -sk, --sshgenkeys
  -t, --localtime
  -u, --update

```
- To set everything to "no" and just regenerate the certificates for ssh and install the ssh server, you can type:

```
./install_config.sh -d="no" -sk="yes" -s="yes"

```
*For **--aliases** option: You must create a file containing the code snippet to insert it into "/etc/profile".*

*Important: You must have the configuration for ssh already done by changing the files "ssh_config and sshd_config" as you require and have it saved in a shared folder. Then set it in the script with the variable "SSH_CONFIG" the path of those files.*
<br><br>


## Author
[Antonio da Silva](https://github.com/antosoft)

## License
[ISC License](https://github.com/antosoft/antosoft-scripts/raw/main/LICENSE)
