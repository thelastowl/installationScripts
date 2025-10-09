#!/bin/bash

# use as root
if (( $EUID != 0 )); then
    echo "Please run as root"
    exit
fi

max_jobs=5
wordlist_dir="/opt/wordlist"
privesc_dir="/opt/privesc"
rev_dir="/opt/rev-shells"
error_log="/root/install_errors-wordlists.log"
>> "$error_log"

if [ ! -d "$wordlist_dir" ]; then
    sudo mkdir -p "$wordlist_dir"
fi
if [ ! -d "$privesc_dir" ]; then
    mkdir "$privesc_dir"
fi
if [ ! -d "$rev_dir" ]; then
    mkdir "$rev_dir"
fi

commands=(
  "cd \"$wordlist_dir\" && git clone https://github.com/danielmiessler/SecLists.git seclists"
  "cd \"$wordlist_dir\" && wget https://github.com/praetorian-inc/Hob0Rules/raw/refs/heads/master/wordlists/rockyou.txt.gz && gunzip rockyou.txt.gz"
  "mv -f /usr/share/wordlists \"$wordlist_dir\""
  "cd \"$wordlist_dir\" && wget https://gist.githubusercontent.com/jhaddix/b80ea67d85c13206125806f0828f4d10/raw/c81a34fe84731430741e0463eb6076129c20c4c0/content_discovery_all.txt -O jhaddix-content-discovery-all.txt"
  "cd \"$wordlist_dir\" && wget https://github.com/six2dez/OneListForAll/archive/refs/tags/v2.4.1.1.zip && unzip v2.4.1.1.zip && rm v2.4.1.1.zip"
  "cd \"$wordlist_dir\" && wget https://raw.githubusercontent.com/six2dez/OneListForAll/refs/heads/main/onelistforallshort.txt"
  "cd \"$privesc_dir\" && wget https://github.com/diego-treitos/linux-smart-enumeration/releases/latest/download/lse.sh"
  "cd \"$privesc_dir\" && wget https://github.com/DominicBreuker/pspy/releases/latest/download/pspy32 && wget https://github.com/DominicBreuker/pspy/releases/latest/download/pspy64 && chmod +x lse.sh pspy32 pspy64"
  "cd \"$privesc_dir\" && wget https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh && wget https://github.com/peass-ng/PEASS-ng/releases/latest/download/winpeas.bat"
  "cd \"$wordlist_dir\" && wget https://crackstation.net/files/crackstation.txt.gz && gzip -d crackstation.txt.gz"
  "cd \"$wordlist_dir\" && wget https://crackstation.net/files/crackstation-human-only.txt.gz && gzip -d crackstation-human-only.txt.gz"
)

# runs commands in background
runCmd() {
  local c="$1"
  bash -c "$c"
  local status=$?
  if [[ $status -ne 0 ]]; then
    echo "FAILED: $c" >> "$error_log"
  fi
}

for cmd in "${commands[@]}"; do
    while (( $(jobs -rp | wc -l) >= max_jobs )); do
        sleep 1   # Checks every second whether the number of running background jobs is less than max jobs allowed (if so runs the next command)
    done
    runCmd "$cmd" & 
done
wait  # waits for all background jobs to finish
