#!/bin/bash

# LMDE Setup Script for Windows Users
# Makes Linux Mint Debian Edition familiar for Windows users
# Optimized for older hardware (4GB RAM)

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}LMDE Windows User Transition Setup${NC}"
echo -e "${GREEN}========================================${NC}\n"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Please run as root (use sudo)${NC}"
    exit 1
fi

REAL_USER=$(logname 2>/dev/null || echo $SUDO_USER)
USER_HOME=$(eval echo ~$REAL_USER)

echo -e "${BLUE}Setting up for user: $REAL_USER${NC}\n"

# Update system
echo -e "${YELLOW}[*] Updating system packages...${NC}"
apt update && apt upgrade -y

# ===================================
# ESSENTIAL APPLICATIONS
# ===================================

echo -e "\n${GREEN}[1/8] Installing Essential Applications${NC}"

# Web browsers
echo -e "${YELLOW}[*] Installing web browsers...${NC}"
apt install -y firefox-esr chromium

# Office suite (LibreOffice - like MS Office)
echo -e "${YELLOW}[*] Installing office suite...${NC}"
apt install -y libreoffice libreoffice-gtk3

# PDF reader
echo -e "${YELLOW}[*] Installing PDF tools...${NC}"
apt install -y evince qpdfview xpdf

# Archive manager (like WinRAR/7-Zip)
echo -e "${YELLOW}[*] Installing archive managers...${NC}"
apt install -y p7zip-full p7zip-rar unrar rar unzip zip

# ===================================
# MEDIA & GRAPHICS
# ===================================

echo -e "\n${GREEN}[2/8] Installing Media & Graphics Tools${NC}"

# Image viewer/editor
echo -e "${YELLOW}[*] Installing image tools...${NC}"
apt install -y gimp gimp-data-extras inkscape

# Media players
echo -e "${YELLOW}[*] Installing media players...${NC}"
apt install -y vlc mpv

# Audio editor
echo -e "${YELLOW}[*] Installing audio tools...${NC}"
apt install -y audacity

# Codecs
echo -e "${YELLOW}[*] Installing multimedia codecs...${NC}"
apt install -y mint-meta-codecs ffmpeg

# ===================================
# COMMUNICATION
# ===================================

echo -e "\n${GREEN}[3/8] Installing Communication Tools${NC}"

# Email client (like Outlook)
echo -e "${YELLOW}[*] Installing email client...${NC}"
apt install -y thunderbird

# Messaging apps
echo -e "${YELLOW}[*] Installing messaging apps...${NC}"

# Discord (from deb package)
if ! command -v discord &> /dev/null; then
    echo -e "${YELLOW}[*] Installing Discord...${NC}"
    wget -O /tmp/discord.deb "https://discord.com/api/download?platform=linux&format=deb"
    apt install -y /tmp/discord.deb || true
    rm /tmp/discord.deb
fi

# Zoom
read -p "Install Zoom? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}[*] Installing Zoom...${NC}"
    wget -O /tmp/zoom.deb "https://zoom.us/client/latest/zoom_amd64.deb"
    apt install -y /tmp/zoom.deb || true
    rm /tmp/zoom.deb
fi

# ===================================
# FILE MANAGEMENT
# ===================================

echo -e "\n${GREEN}[4/8] Installing File Management Tools${NC}"

# Better file managers and tools
apt install -y \
    nemo-fileroller \
    nemo-preview \
    gnome-disk-utility \
    gparted \
    baobab \
    timeshift

# Cloud storage
echo -e "${YELLOW}[*] Do you use cloud storage?${NC}"
echo "1) Dropbox"
echo "2) Google Drive (via rclone)"
echo "3) OneDrive (via rclone)"
echo "4) Skip"
read -p "Enter choice [1-4]: " CLOUD_CHOICE

case $CLOUD_CHOICE in
    1)
        echo -e "${YELLOW}[*] Installing Dropbox...${NC}"
        cd /tmp && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
        ~/.dropbox-dist/dropboxd &
        ;;
    2|3)
        echo -e "${YELLOW}[*] Installing rclone for cloud storage...${NC}"
        apt install -y rclone
        echo -e "${GREEN}[+] Run 'rclone config' to set up your cloud storage${NC}"
        ;;
esac

# ===================================
# PRODUCTIVITY & UTILITIES
# ===================================

echo -e "\n${GREEN}[5/8] Installing Productivity Tools${NC}"

# Text editors (like Notepad++)
echo -e "${YELLOW}[*] Installing text editors...${NC}"
apt install -y \
    gedit \
    mousepad \
    xed

# Note-taking
apt install -y gnote

# Screenshot tools (like Snipping Tool)
apt install -y flameshot shutter

# Calculator
apt install -y gnome-calculator

# System monitor (like Task Manager)
apt install -y gnome-system-monitor htop

# Remote desktop
apt install -y remmina remmina-plugin-rdp

# ===================================
# WINDOWS COMPATIBILITY
# ===================================

echo -e "\n${GREEN}[6/8] Installing Windows Compatibility Layer${NC}"

# Wine (to run Windows programs)
echo -e "${YELLOW}[*] Installing Wine...${NC}"
dpkg --add-architecture i386
apt update
apt install -y wine wine32 wine64 winetricks

# PlayOnLinux (easier Wine management)
apt install -y playonlinux

# Windows fonts
echo -e "${YELLOW}[*] Installing Microsoft fonts...${NC}"
echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections
apt install -y ttf-mscorefonts-installer fonts-liberation fonts-crosextra-carlito fonts-crosextra-caladea

# ===================================
# SYSTEM TWEAKS & OPTIMIZATION
# ===================================

echo -e "\n${GREEN}[7/8] Applying System Tweaks${NC}"

# Enable TRIM for SSD (if applicable)
systemctl enable fstrim.timer

# Install lightweight system tools
apt install -y \
    bleachbit \
    stacer \
    preload

# Enable preload (improves app loading times)
systemctl enable preload

# Optimize swappiness for low RAM
echo "vm.swappiness=10" >> /etc/sysctl.conf

# Install ZRAM for better memory management
apt install -y zram-tools
echo -e "ALGO=lz4\nPERCENT=50" > /etc/default/zramswap
systemctl enable zramswap

# ===================================
# DESKTOP CUSTOMIZATION
# ===================================

echo -e "\n${GREEN}[8/8] Setting Up Familiar Desktop Experience${NC}"

# Install Cinnamon themes and icons
apt install -y \
    mint-themes \
    mint-y-icons \
    mint-x-icons \
    arc-theme \
    papirus-icon-theme

# Desktop gadgets/widgets
apt install -y conky-all

# Set up Windows-like keyboard shortcuts
sudo -u $REAL_USER dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/custom0/binding "['<Super>e']"
sudo -u $REAL_USER dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/custom0/command "'nemo'"
sudo -u $REAL_USER dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/custom0/name "'File Manager'"

# ===================================
# CREATE DESKTOP SHORTCUTS
# ===================================

echo -e "${YELLOW}[*] Creating desktop shortcuts...${NC}"

# Create Documents folder structure like Windows
mkdir -p "$USER_HOME/Documents"
mkdir -p "$USER_HOME/Downloads"
mkdir -p "$USER_HOME/Pictures"
mkdir -p "$USER_HOME/Videos"
mkdir -p "$USER_HOME/Music"

chown -R $REAL_USER:$REAL_USER "$USER_HOME/Documents" "$USER_HOME/Downloads" \
    "$USER_HOME/Pictures" "$USER_HOME/Videos" "$USER_HOME/Music"

# Create a Windows equivalents guide
cat > "$USER_HOME/Desktop/Windows-to-Linux-Guide.txt" << 'EOF'
WINDOWS TO LINUX APPLICATION GUIDE
===================================

Windows Program          →    Linux Alternative
-----------------             ------------------
Microsoft Word           →    LibreOffice Writer
Microsoft Excel          →    LibreOffice Calc
Microsoft PowerPoint     →    LibreOffice Impress
Notepad                  →    Gedit / Mousepad
Notepad++                →    Gedit / Xed
Adobe Photoshop          →    GIMP
Adobe Illustrator        →    Inkscape
Windows Media Player     →    VLC Media Player
Internet Explorer/Edge   →    Firefox / Chromium
Outlook                  →    Thunderbird
Task Manager             →    System Monitor (Ctrl+Shift+Esc)
Control Panel            →    System Settings
File Explorer            →    Nemo (Super+E to open)
Command Prompt           →    Terminal (Ctrl+Alt+T)
Paint                    →    Drawing / Pinta
Snipping Tool            →    Flameshot / Shutter
7-Zip/WinRAR            →    Archive Manager (built-in)
Remote Desktop           →    Remmina
CCleaner                 →    BleachBit
Defraggler               →    Not needed on Linux!

KEYBOARD SHORTCUTS
==================
Ctrl+C, Ctrl+V, Ctrl+X   →    Same (Copy, Paste, Cut)
Ctrl+Z, Ctrl+Y           →    Same (Undo, Redo)
Ctrl+Alt+Delete          →    Ctrl+Alt+Esc (Force Quit)
Ctrl+Shift+Esc           →    Same (System Monitor)
Windows+E                →    Super+E (File Manager)
Windows+L                →    Super+L (Lock Screen)
Ctrl+Alt+T               →    Open Terminal
Alt+F4                   →    Same (Close Window)
Alt+Tab                  →    Same (Switch Windows)
PrintScreen              →    Same (Screenshot)

COMMON TERMINAL COMMANDS
========================
dir                      →    ls
cd                       →    Same
copy                     →    cp
move                     →    mv
del                      →    rm
mkdir                    →    Same
type                     →    cat
cls                      →    clear
ipconfig                 →    ip addr / ifconfig
ping                     →    Same
tracert                  →    traceroute
netstat                  →    ss / netstat

TIPS FOR WINDOWS USERS
======================
- Right-click still works the same way
- You can still double-click to open files
- Drag and drop works as expected
- Most keyboard shortcuts are identical
- Use Software Manager to install apps (like Microsoft Store)
- Updates happen automatically (like Windows Update)
- No need to defragment drives on Linux
- No registry to worry about
- Built-in antivirus not needed (Linux is secure by design)

GETTING HELP
============
- Press F1 in most applications for help
- Visit: https://forums.linuxmint.com
- Right-click taskbar for settings
- System Settings → All Settings (like Control Panel)
EOF

chown $REAL_USER:$REAL_USER "$USER_HOME/Desktop/Windows-to-Linux-Guide.txt"
chmod +x "$USER_HOME/Desktop/Windows-to-Linux-Guide.txt"

# Create useful aliases
cat >> "$USER_HOME/.bashrc" << 'EOF'

# Windows-like aliases for terminal
alias dir='ls -la'
alias cls='clear'
alias ipconfig='ip addr show'
alias tasklist='ps aux'
alias taskkill='kill'
alias where='which'
EOF

chown $REAL_USER:$REAL_USER "$USER_HOME/.bashrc"

# ===================================
# FINAL SETUP
# ===================================

echo -e "\n${YELLOW}[*] Running final cleanup...${NC}"
apt autoremove -y
apt autoclean

# Create a welcome script
cat > "$USER_HOME/Desktop/Welcome.sh" << 'EOF'
#!/bin/bash
zenity --info --title="Welcome to Linux Mint!" --width=500 --height=300 --text="
<b>Welcome to Linux Mint Debian Edition!</b>

Your system has been configured with Windows-like applications and shortcuts.

<b>Quick Tips:</b>
• Press Super+E to open File Manager (like Windows+E)
• Press Ctrl+Alt+T to open Terminal
• Check the 'Windows-to-Linux-Guide.txt' on your desktop
• Software Manager is like the Microsoft Store
• Right-click the taskbar to customize it

<b>Next Steps:</b>
1. Set up your email in Thunderbird
2. Install any additional apps from Software Manager
3. Configure your backup with Timeshift
4. Check for system updates regularly

Enjoy your new Linux experience!
"
EOF

chmod +x "$USER_HOME/Desktop/Welcome.sh"
chown $REAL_USER:$REAL_USER "$USER_HOME/Desktop/Welcome.sh"

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}\n"

echo -e "${BLUE}Applications Installed:${NC}"
echo "✓ Office Suite (LibreOffice)"
echo "✓ Image Editor (GIMP)"
echo "✓ Media Player (VLC)"
echo "✓ Email Client (Thunderbird)"
echo "✓ Wine (Windows compatibility)"
echo "✓ Archive tools (7-Zip compatible)"
echo "✓ Screenshot tools"
echo "✓ System optimization tools"

echo -e "\n${YELLOW}Important Notes:${NC}"
echo "1. Logout and login for all changes to take effect"
echo "2. Check 'Windows-to-Linux-Guide.txt' on your desktop"
echo "3. Run Timeshift to set up system backups"
echo "4. Wine is installed - you can run many Windows programs"
echo "5. Use Software Manager to install more apps"

echo -e "\n${YELLOW}Recommended Next Steps:${NC}"
echo "• Configure backup: sudo timeshift-gtk"
echo "• Update system: sudo apt update && sudo apt upgrade"
echo "• Install Chrome: Download from google.com/chrome"
echo "• Install Steam: apt install steam (for gaming)"

echo -e "\n${GREEN}Your system is now Windows-user friendly!${NC}\n"

# Show welcome message after reboot
sudo -u $REAL_USER bash -c "echo '$USER_HOME/Desktop/Welcome.sh' >> $USER_HOME/.config/autostart/welcome.desktop" 2>/dev/null || true
