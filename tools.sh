#!/bin/bash

if (( $EUID != 0 )); then
    echo "Please run as root"
    exit
fi

install_dir="/opt"
error_apt="/root/missing_packages-tools.log"
>> "$error_apt"
error_git="/root/git_install_errors-tools.log"
>> "$error_git"
error_go="/root/go_install_errors-tools.log"
>> "$error_go"

# used later when concurrently running commands
max_jobs=5

# installing one at a time to prevent installation errors 
packages="nmap metasploit-framework arp-scan netdiscover exploitdb smbclient ffuf john hashcat hydra name-that-hash wpscan sublist3r subfinder wafw00f exiftool adb apktool jadx"

apt-get update
for pkg in $packages; do
    echo "Installing $pkg..."
    apt-get install -y -f    # not really required everytime but I like to be on safe side 
    if ! sudo apt-get install -y "$pkg"; then
        echo "FAILED: $pkg" >> "$error_apt"
    fi
done

apt-get update && apt-get install -y -f && apt-get clean -y && apt-get autoremove -y

commands=(
  "cd \"$install_dir\" && git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git"
  "echo \"alias sqlmap='python3 \$install_dir/sqlmap/sqlmap.py'\" >> ~/.bashrc"
  "echo \"alias sqlmap='python3 \$install_dir/sqlmap/sqlmap.py'\" >> ~/.zshrc"
  "cd \"$install_dir\" && python3 -m venv ghauri && source ghauri/bin/activate && pip install git+https://github.com/r0oth3x49/ghauri.git && deactivate"
  "echo 'ghauri_run() { source \$install_dir/ghauri/bin/activate; ghauri \"\$@\"; deactivate; }' >> ~/.bashrc"
  "echo 'ghauri_run() { source \$install_dir/ghauri/bin/activate; ghauri \"\$@\"; deactivate; }' >> ~/.zshrc"
  "cd \"$install_dir\" && wget https://github.com/bee-san/RustScan/releases/download/2.4.1/rustscan.deb.zip && unzip rustscan.deb.zip && dpkg -i rustscan_2.4.1-1_amd64.deb && rm rustscan_2.4.1-1_amd64.deb rustscan.deb.zip rustscan.tmp0-stripped"
  "cd \"$install_dir\" && git clone https://github.com/ticarpi/jwt_tool.git && cd jwt_tool && python3 -m venv jwt_tool-venv && source jwt_tool-venv/bin/activate && pip install termcolor cprint pycryptodomex requests pycryptodomex ratelimit && deactivate"
  "echo 'jwt_tool() { source \$install_dir/jwt_tool/jwt_tool-venv/bin/activate; python3 \$install_dir/jwt_tool/jwt_tool.py \"\$@\"; deactivate; }' >> ~/.bashrc"
  "echo 'jwt_tool() { source \$install_dir/jwt_tool/jwt_tool-venv/bin/activate; python3 \$install_dir/jwt_tool/jwt_tool.py \"\$@\"; deactivate; }' >> ~/.zshrc"
  "curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh | sh -s -- -b /usr/local/bin"
  "cd \"$install_dir\" && git clone https://github.com/devploit/nomore403.git && cd nomore403 && go get && go build"
  "echo \"alias nomore403='$install_dir/nomore403/nomore403'\" >> ~/.bashrc"
  "echo \"alias nomore403='$install_dir/nomore403/nomore403'\" >> ~/.zshrc"
  "cd \"$install_dir\" && git clone https://github.com/sullo/nikto.git"
  "echo \"alias nikto='\$install_dir/nikto/program/nikto.pl'\" >> ~/.bashrc"
  "echo \"alias nikto='\$install_dir/nikto/program/nikto.pl'\" >> ~/.zshrc"
  "cd \"$install_dir\" && git clone --depth 1 https://github.com/stamparm/identYwaf.git"
  "echo \"alias identYwaf='python3 \$install_dir/identYwaf/identYwaf.py'\" >> ~/.bashrc"
  "echo \"alias identYwaf='python3 \$install_dir/identYwaf/identYwaf.py'\" >> ~/.zshrc"
  "cd \"$install_dir\" && wget https://github.com/Findomain/Findomain/releases/download/9.0.4/findomain-linux.zip && unzip findomain-linux.zip && chmod +x findomain && rm findomain-linux.zip && sudo mv findomain /usr/bin"
  "cd \"$install_dir\" && git clone https://github.com/ozguralp/gmapsapiscanner.git && cd gmapsapiscanner && python3 -m venv gmapsapiscanner-venv && source gmapsapiscanner-venv/bin/activate && pip install requests && deactivate"
  "echo 'gmapsapiscanner() { source \$install_dir/gmapsapiscanner/gmapsapiscanner-venv/bin/activate; python3 \$install_dir/gmapsapiscanner/maps_api_scanner.py \"\$@\"; deactivate; }' >> ~/.bashrc"
  "echo 'gmapsapiscanner() { source \$install_dir/gmapsapiscanner/gmapsapiscanner-venv/bin/activate; python3 \$install_dir/gmapsapiscanner/maps_api_scanner.py \"\$@\"; deactivate; }' >> ~/.zshrc"
  "cd \"$install_dir\" && git clone https://github.com/gwen001/cloudflare-origin-ip.git && cd cloudflare-origin-ip && python3 -m venv cloudflare-origin-ip-venv && source cloudflare-origin-ip-venv/bin/activate && pip3 install -r requirements.txt && deactivate"
  "echo 'cloudflare-origin-ip() { source \$install_dir/cloudflare-origin-ip/cloudflare-origin-ip-venv/bin/activate; python3 \$install_dir/cloudflare-origin-ip/cloudflare-origin-ip.py \"\$@\"; deactivate; }' >> ~/.bashrc"
  "echo 'cloudflare-origin-ip() { source \$install_dir/cloudflare-origin-ip/cloudflare-origin-ip-venv/bin/activate; python3 \$install_dir/cloudflare-origin-ip/cloudflare-origin-ip.py \"\$@\"; deactivate; }' >> ~/.zshrc"
  "cd \"$install_dir\" && git clone --depth 1 https://github.com/drwetter/testssl.sh.git testssl"
  "echo \"alias testssl='\$install_dir/testssl/testssl.sh'\" >> ~/.bashrc"
  "echo \"alias testssl='\$install_dir/testssl/testssl.sh'\" >> ~/.zshrc"
  "cd \"$install_dir\" && git clone https://github.com/s0md3v/Arjun.git && cd Arjun && python3 -m venv arjun-venv && source arjun-venv/bin/activate && pip install dicttoxml setuptools && cd \"$install_dir\"/Arjun && pip install . && deactivate"
  "echo 'arjun_run() { source \$install_dir/Arjun/arjun-venv/bin/activate; arjun \"\$@\"; deactivate; }' >> ~/.bashrc"
  "echo 'arjun_run() { source \$install_dir/Arjun/arjun-venv/bin/activate; arjun \"\$@\"; deactivate; }' >> ~/.zshrc"
  "cd \"$install_dir\" && git clone https://github.com/devanshbatham/paramspider.git && cd paramspider && python3 -m venv paramspider-venv && source paramspider-venv/bin/activate && pip install setuptools && cd \"$install_dir\"/paramspider && pip install . && deactivate"
  "echo 'paramspider_run() { source \$install_dir/paramspider/paramspider-venv/bin/activate; paramspider \"\$@\"; deactivate; }' >> ~/.bashrc"
  "echo 'paramspider_run() { source \$install_dir/paramspider/paramspider-venv/bin/activate; paramspider \"\$@\"; deactivate; }' >> ~/.zshrc"
  "cd \"$install_dir\" && git clone https://github.com/m4ll0k/SecretFinder.git secretfinder && cd secretfinder && python3 -m venv secretfinder-venv && source secretfinder-venv/bin/activate && pip install -r requirements.txt && deactivate"
  "echo 'secretfinder() { source \$install_dir/secretfinder/secretfinder-venv/bin/activate; python3 \$install_dir/secretfinder/SecretFinder.py \"\$@\"; deactivate; }' >> ~/.bashrc"
  "cd \"$install_dir\" && git clone https://github.com/w9w/JSA.git && cd JSA && python3 -m venv jsa-venv && source jsa-venv/bin/activate && pip3 install -r requirements.txt && deactivate"
  "echo 'jsa() { source \$install_dir/JSA/jsa-venv/bin/activate; echo \"\$@\" | subjs | python3 /opt/JSA/jsa.py; deactivate; }' >> ~/.bashrc"
  "echo 'jsa() { source \$install_dir/JSA/jsa-venv/bin/activate; echo \"\$@\" | subjs | python3 /opt/JSA/jsa.py; deactivate; }' >> ~/.zshrc"
  "cd \"$install_dir\" && git clone https://github.com/GerbenJavado/LinkFinder.git && cd LinkFinder && python3 -m venv linkfinder-venv && source linkfinder-venv/bin/activate && pip3 install -r requirements.txt && pip3 install setuptools && python setup.py install && deactivate"
  "echo 'linkfinder() { source \$install_dir/LinkFinder/linkfinder-venv/bin/activate; python3 /opt/LinkFinder/linkfinder.py \"\$@\"; deactivate; }' >> ~/.bashrc"
  "echo 'linkfinder() { source \$install_dir/LinkFinder/linkfinder-venv/bin/activate; python3 /opt/LinkFinder/linkfinder.py \"\$@\"; deactivate; }' >> ~/.zshrc"
  "cd \"$install_dir\" && python3 -m venv waymore && source waymore/bin/activate && pip install waymore && deactivate"
  "echo 'waymore_run() { source \$install_dir/waymore/bin/activate; waymore \"\$@\"; deactivate; }' >> ~/.bashrc"
  "echo 'waymore_run() { source \$install_dir/waymore/bin/activate; waymore \"\$@\"; deactivate; }' >> ~/.zshrc"
  "cd \"$install_dir\" && git clone https://github.com/MobSF/Mobile-Security-Framework-MobSF mobsf && cd mobsf && python3 -m venv mobsf-venv && source mobsf-venv/bin/activate && ./setup.sh && deactivate"
  "echo 'mobsf() { source \$install_dir/mobsf/mobsf-venv/bin/activate; cd \$install_dir/mobsf && ./run.sh > /dev/null 2>&1 && deactivate; }' >> ~/.bashrc"
  "echo 'mobsf() { source \$install_dir/mobsf/mobsf-venv/bin/activate; cd \$install_dir/mobsf && ./run.sh > /dev/null 2>&1 && deactivate; }' >> ~/.zshrc"
  "cd \"$install_dir\" && wget https://github.com/patrickfav/uber-apk-signer/releases/download/v1.2.1/uber-apk-signer-1.2.1.jar"
  "echo \"alias uber-apk-signer='java -jar /opt/uber-apk-signer-1.2.1.jar --allowResign -a'\" >> ~/.bashrc"
  "echo \"alias uber-apk-signer='java -jar /opt/uber-apk-signer-1.2.1.jar --allowResign -a'\" >> ~/.zshrc"
)

# runs commands in background
runCmd() {
  local c="$1"
  bash -c "$c"
  local status=$?
  if [[ $status -ne 0 ]]; then
    echo "FAILED: $c" >> "$error_git"
  fi
}

for cmd in "${commands[@]}"; do
    while (( $(jobs -rp | wc -l) >= max_jobs )); do
        sleep 1   # Checks every second whether the number of running background jobs is less than max jobs allowed (if so executes the next command)
    done
    runCmd "$cmd" &
done
wait  # waits for all background jobs to finish 

commands=(
  'go install -v github.com/owasp-amass/amass/v4/...@master'
  'go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest'
  'go install github.com/projectdiscovery/katana/cmd/katana@latest'
  'go install github.com/lc/gau/v2/cmd/gau@latest'
  'go install github.com/hahwul/dalfox/v2@latest'
  'go install github.com/lc/subjs@latest'
  'go install github.com/visma-prodsec/confused@latest'
  'go install github.com/003random/getJS/v2@latest'
  'rm -f /usr/bin/httpx || true && go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest'
  'go install github.com/tomnomnom/waybackurls@latest'
)

# runs commands in background
runCmd() {
  local c="$1"
  bash -c "$c"
  local status=$?
  if [[ $status -ne 0 ]]; then
    echo "FAILED: $c" >> "$error_go"
  fi
}

for cmd in "${commands[@]}"; do
    while (( $(jobs -rp | wc -l) >= max_jobs )); do
        sleep 1   # Checks every second whether the number of running background jobs is less than max jobs allowed (if so runs the next command)
    done
    runCmd "$cmd" & 
done
wait  # waits for all background jobs to finish

# basic dmarc
echo 'dmarcCheck() {' >> ~/.bashrc
echo '    domain="$1"' >> ~/.bashrc
echo '' >> ~/.bashrc
echo '    if [ -z "$domain" ]; then' >> ~/.bashrc
echo '        echo "Usage: dmarcCheck <domain>"' >> ~/.bashrc
echo '        return 1' >> ~/.bashrc
echo '    fi' >> ~/.bashrc
echo '' >> ~/.bashrc
echo '    echo "=== DMARC Record ==="' >> ~/.bashrc
echo '    dig +short TXT _dmarc.$domain' >> ~/.bashrc
echo '' >> ~/.bashrc
echo '    echo "=== SPF Record ==="' >> ~/.bashrc
echo '    dig +short TXT $domain | grep '\''v=spf1'\''' >> ~/.bashrc
echo '}' >> ~/.bashrc
echo 'dmarcCheck() {' >> ~/.zshrc
echo '    domain="$1"' >> ~/.zshrc
echo '' >> ~/.zshrc
echo '    if [ -z "$domain" ]; then' >> ~/.zshrc
echo '        echo "Usage: dmarcCheck <zshrc>"' >> ~/.zshrc
echo '        return 1' >> ~/.zshrc
echo '    fi' >> ~/.zshrc
echo '' >> ~/.zshrc
echo '    echo "=== DMARC Record ==="' >> ~/.zshrc
echo '    dig +short TXT _dmarc.$domain' >> ~/.zshrc
echo '' >> ~/.zshrc
echo '    echo "=== SPF Record ==="' >> ~/.zshrc
echo '    dig +short TXT $domain | grep '\''v=spf1'\''' >> ~/.zshrc
echo '}' >> ~/.zshrc

# nuclei wordfence templates
export GITHUB_TEMPLATE_REPO=topscoder/nuclei-wordfence-cve && nuclei -ut

printf '%*s\n' "$COLUMNS" '' | tr ' ' '-'
echo "Installation complete. Check $error_apt, $error_git and $error_go for errors."
printf '%*s\n' "$COLUMNS" '' | tr ' ' '-'