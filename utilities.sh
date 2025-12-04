#!/bin/bash

if (( $EUID != 0 )); then
    echo "Please run as root"
    exit
fi

USER="cyberlogist"

# backup of original files
cp ~/.bashrc ~/.bashrc.bak
cp ~/.zshrc ~/.zshrc.bak

# no more annoying password prompts
echo "$USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# auto switch to root and cd to root directory (maybe I should use root autologin?)
echo "sudo su" >> /home/$USER/.bashrc
echo "sudo su" >> /home/$USER/.zshrc
echo "cd ~" >> /root/.bashrc
echo "cd ~" >> /root/.zshrc

# go environment path
echo 'export PATH=$HOME/go/bin:/usr/local/go/bin:/opt:$PATH' >> ~/.bashrc
echo 'export PATH=$HOME/go/bin:/usr/local/go/bin:/opt:$PATH' >> ~/.zshrc

# I like /opt
install_dir="/opt"
echo 'install_dir="/opt"' >> ~/.bashrc 
echo 'install_dir="/opt"' >> ~/.zshrc
echo 'wordlist_dir="/opt/wordlists"' >> ~/.bashrc
echo 'wordlist_dir="/opt/wordlists"' >> ~/.zshrc
echo 'rev_dir="/opt/rev-shells"' >> ~/.bashrc
echo 'rev_dir="/opt/rev-shells"' >> ~/.zshrc
echo 'privesc_dir="/opt/privesc"' >> ~/.bashrc
echo 'privesc_dir="/opt/privesc"' >> ~/.zshrc

error_apt="/root/missing_packages-utility.log"
>> "$error_apt"

apt-get update
apt-get install -y -f

# installing one at a time to prevent installation errors 
packages="build-essential vim unzip netcat-traditional terminator hexedit openvpn whois nbtscan docker.io golang-go bsdextrautils default-jdk xsltproc jq libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev curl git libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev libzstd-dev pyenv gpg file net-tools pipx cifs-utils"

for pkg in $packages; do
    echo "Installing $pkg..."
    apt-get install -y -f     # not really required everytime but I like to be on safe side 
    if ! sudo apt-get install -y "$pkg"; then
        echo "FAILED: $pkg" >> "$error_apt"
    fi
done

pipx ensurepath

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - bash)"
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init - bash)"' >> ~/.bashrc
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.profile
echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.profile
echo 'eval "$(pyenv init - bash)"' >> ~/.profile
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init - zsh)"' >> ~/.zshrc
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zprofile 
echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zprofile 
echo 'eval "$(pyenv init - zsh)"' >> ~/.zprofile 
pyenv install 3.13
pyenv global 3.13  # set python version locally using pyenv for specific tools

# aws cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip awscliv2.zip && aws/install && rm -rf awscliv2.zip aws
## i have separate scripts in private repo for setting sensitive info like api keys ;)

# sublime
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo tee /etc/apt/keyrings/sublimehq-pub.asc > /dev/null
echo -e 'Types: deb\nURIs: https://download.sublimetext.com/\nSuites: apt/stable/\nSigned-By: /etc/apt/keyrings/sublimehq-pub.asc' | sudo tee /etc/apt/sources.list.d/sublime-text.sources
sudo apt-get update && sudo apt-get install sublime-text

# cleaning up
apt-get update && apt-get install -y -f && apt-get clean -y && apt-get autoremove -y

printf '%*s\n' "$COLUMNS" '' | tr ' ' '-'
echo -e "Installation complete - Check $error_apt for missing packages\nIf package is already installed, it causes false positive (may fix later)"
printf '%*s\n' "$COLUMNS" '' | tr ' ' '-'