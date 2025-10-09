#!/bin/bash

# use as root
if (( $EUID != 0 )); then
    echo "Please run as root"
    exit
fi

install_dir="/opt"
wordlist_dir="/opt/wordlist"
max_jobs=5

error_log="/root/update_errors-tools.log"

# for tools
packages="nmap metasploit-framework arp-scan netdiscover exploitdb smbclient ffuf john hashcat hydra name-that-hash wpscan sublist3r subfinder wafw00f exiftool adb apktool jadx"

apt-get update
for pkg in $packages; do
    echo "Updating $pkg..."
    apt-get install -y -f    # not really required everytime but I like to be on safe side 
    if ! sudo apt-get install -y --only-upgrade "$pkg"; then
        echo "FAILED: $pkg" >> "$error_log"
    fi
done

# for some utilities - may cause version errors so be careful
packages="vim unzip netcat-traditional hexedit openvpn whois nbtscan curl git"

apt-get update
for pkg in $packages; do
    echo "Updating $pkg..."
    apt-get install -y -f    # not really required everytime but I like to be on safe side 
    if ! sudo apt-get install -y --only-upgrade "$pkg"; then
        echo "FAILED: $pkg" >> "$error_log"
    fi
done

# cleaning up
apt-get update && apt-get install -y -f && apt-get clean -y && apt-get autoremove -y

# all except apt
commands=(
  "nuclei -up && nuclei -ut"
  "source \"$install_dir/ghauri/bin/activate\" && pip install --upgrade git+https://github.com/r0oth3x49/ghauri.git && deactivate"
  "git -C \"$install_dir\"/sqlmap pull origin master"
  "git -C \"$install_dir\"/jwt_tool pull origin master"
  "git -C \"$install_dir\"/Arjun pull origin master"
  "git -C \"$install_dir\"/mobsf pull origin master"
  "git -C \"$install_dir\"/nomore403 pull origin main"
  "git -C \"$install_dir\"/nikto pull origin master"
  "git -C \"$install_dir\"/identYwaf pull origin master"
  "git -C \"$install_dir\"/testssl pull origin 3.3dev"
  "git -C \"$install_dir\"/cloudflare-origin-ip pull origin main"
  "git -C \"$install_dir\"/gmapsapiscanner pull origin master"
  "git -C \"$install_dir\"/paramspider pull origin master"
  "git -C \"$install_dir\"/secretfinder origin master"
  "git -C \"$install_dir\"/JSA pull origin main"
  "git -C \"$install_dir\"/LinkFinder pull origin master"
  "go install github.com/lc/gau/v2/cmd/gau@latest"
  "go install github.com/tomnomnom/waybackurls@latest"
  "go install github.com/projectdiscovery/katana/cmd/katana@latest"
  "go install github.com/003random/getJS/v2@latest"
  "go install github.com/visma-prodsec/confused@latest"
  "git -C \"$wordlist_dir\"/seclists pull origin master"
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

printf '%*s\n' "$COLUMNS" '' | tr ' ' '-'
echo -e "Updating complete"
printf '%*s\n' "$COLUMNS" '' | tr ' ' '-'