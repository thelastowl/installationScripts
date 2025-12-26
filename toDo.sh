Set alias -> xfreerdp3 /cert:ignore /w:700 /h:768 +drives

apt install webshells
pip install six impacket 

webshell vs sudo apt install laudanum??
mv webshells /opt/wordlists/webshells

add freerdp3-x11 remina

add terminator to dash to panel & remove default

pipx install git+https://github.com/lgandx/Responder.git   -> not working! so installed using apt
pip install netifaces aioquic

add setup for burp suite latest without apt


setup config! -> curl https://raw.githubusercontent.com/OWASP/Amass/master/examples/config.ini > ~/.config/amass/config.ini
add wkhtmltopdf to mobsf
add frida-tools objection reflutter==0.8.4
add drupwn
### ERROR: Could not find a version that satisfies the requirement prompt_toolkit>=2.0.7 (from versions: none)
### cd $install_dir && git clone https://github.com/immunIT/drupwn && cd drupwn && python3 -m venv drupwn-venv && source drupwn-venv/bin/activate && pip install setuptools && pip install -r /opt/drupwn/requirements.txt && cd /opt/drupwn && python3 setup.py install && deactivate
### echo 'drupwn_run() {
###     source $install_dir/drupwn-venv/bin/activate
###     drupwn "$@"
###     deactivate
### }' >> ~/.bashrc

# updateTools.sh
## for those installed via apt
## rustscan 

# wordlists.sh
## asset notes -> wget -r --no-parent -R "index.html*" https://wordlists-cdn.assetnote.io/data/ -nH -e robots=off
## add custom-wordlists from notion
## rev-shells
### wget https://raw.githubusercontent.com/pentestmonkey/php-reverse-shell/refs/heads/master/php-reverse-shell.php 
### wget https://raw.githubusercontent.com/pentestmonkey/php-reverse-shell/master/php-reverse-shell.php -O php-rev.php
### wget https://raw.githubusercontent.com/thelastowl/reverse-shells/main/node-rev.js 
### wget http://pentestmonkey.net/tools/perl-reverse-shell/perl-reverse-shell-1.0.tar.gz 
### tar -xvf perl-reverse-shell-1.0.tar.gz  
### mv perl-reverse-shell-1.0/perl-reverse-shell.pl perl-rev.pl
### rm -rf perl-reverse-shell-1.0 perl-reverse-shell-1.0.tar.gz