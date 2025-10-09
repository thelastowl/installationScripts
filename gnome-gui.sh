#!/bin/bash

if (( $EUID != 0 )); then
    echo "Please run as root"
    exit
fi

USERNAME="cyberlogist"

apt-get update && apt-get -y --fix-broken install && apt-get install -y gnome-shell-extension-dashtodock

# GUI, wallpaper & other settings
export DISPLAY=:0
wget https://r4.wallpaperflare.com/wallpaper/185/49/104/joakim-ericsson-digital-art-artwork-samurai-wallpaper-ecdf44e60425e800adc54f94e2600ff8.jpg -O /usr/share/desktop-base/kali-theme/wallpaper/samurai.jpg
gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/desktop-base/kali-theme/wallpaper/samurai.jpg'
gsettings set org.gnome.desktop.background picture-uri-dark 'file:///usr/share/desktop-base/kali-theme/wallpaper/samurai.jpg'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface icon-theme "Gnome"
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0
gsettings set org.gnome.desktop.session idle-delay 0
gsettings set org.gnome.desktop.screensaver lock-enabled false
gsettings set org.gnome.desktop.lockdown disable-lock-screen true
gsettings set org.gnome.shell favorite-apps "['org.gnome.Terminal.desktop', 'org.gnome.Nautilus.desktop', 'firefox-esr.desktop', 'sublime_text.desktop', 'kali-burpsuite.desktop']"
sudo -u $USERNAME gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/desktop-base/kali-theme/wallpaper/samurai.jpg'
sudo -u $USERNAME gsettings set org.gnome.desktop.background picture-uri-dark 'file:///usr/share/desktop-base/kali-theme/wallpaper/samurai.jpg'
sudo -u $USERNAME gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
sudo -u $USERNAME gsettings set org.gnome.desktop.interface icon-theme "Gnome"
sudo -u $USERNAME gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0
sudo -u $USERNAME gsettings set org.gnome.desktop.session idle-delay 0
sudo -u $USERNAME gsettings set org.gnome.desktop.screensaver lock-enabled false
sudo -u $USERNAME gsettings set org.gnome.desktop.lockdown disable-lock-screen true
sudo -u $USERNAME gsettings set org.gnome.shell favorite-apps "['org.gnome.Terminal.desktop', 'org.gnome.Nautilus.desktop', 'firefox-esr.desktop', 'sublime_text.desktop', 'kali-burpsuite.desktop']"

# auto login
cp /etc/gdm3/daemon.conf /etc/gdm3/daemon.conf.bak
sed -i '/AutomaticLoginEnable/d' /etc/gdm3/daemon.conf
sed -i '/AutomaticLogin/d' /etc/gdm3/daemon.conf
if ! grep -q '^\[daemon\]' /etc/gdm3/daemon.conf; then
  echo -e "\n[daemon]" | tee -a /etc/gdm3/daemon.conf > /dev/null
fi
sed -i '/^\[daemon\]/a AutomaticLoginEnable=True\nAutomaticLogin='"$USERNAME" /etc/gdm3/daemon.conf

# Changing resolution
WIDTH=1920
HEIGHT=1080
REFRESH=60
DISPLAY_NAME=$(xrandr | grep " connected" | awk '{ print $1 }')
if [ -z "$DISPLAY_NAME" ]; then
  echo "No connected display found."
  exit 1
fi
if xrandr | grep -q "${WIDTH}x${HEIGHT}"; then
  echo "Mode ${WIDTH}x${HEIGHT} exists. Setting resolution..."
else
  echo "Mode ${WIDTH}x${HEIGHT} not found. Creating mode..."
  MODELINE=$(cvt $WIDTH $HEIGHT $REFRESH | grep Modeline | sed 's/Modeline //')
  MODE_NAME=$(echo $MODELINE | cut -d' ' -f1 | tr -d '"')
  xrandr --newmode $MODELINE
  xrandr --addmode $DISPLAY_NAME $MODE_NAME
fi
xrandr --output $DISPLAY_NAME --mode ${WIDTH}x${HEIGHT}
echo "Resolution set to ${WIDTH}x${HEIGHT} for display $DISPLAY_NAME."

systemctl restart gdm