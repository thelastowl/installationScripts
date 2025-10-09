# if VirtualBox <-> Windows are acting up
sudo apt install -y --reinstall virtualbox-guest-x11
sudo reboot -f

# self-signed certificates
sudo mv custom.crt /usr/local/share/ca-certificates
sudo update-ca-certificates --fresh

# xfce to Gnome; may be insufficient
echo $XDG_CURRENT_DESKTOP
apt-get update && apt-get install -y kali-desktop-gnome # selectgdm3
update-alternatives --config x-session-manager 
reboot

# set dash lines for any terminal size
printf '%*s\n' "$COLUMNS" '' | tr ' ' '-'

# fixes GO path
## better fix in the utilities.sh
wget https://go.dev/dl/go1.22.3.linux-amd64.tar.gz && sudo tar -xzvf go1.22.3.linux-amd64.tar.gz -C /usr/local && echo export PATH=$HOME/go/bin:/usr/local/go/bin:$PATH >> ~/.profile && source ~/.profile