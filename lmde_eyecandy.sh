#!/bin/bash

# LMDE Compiz Fusion & Conky Eye Candy Setup
# Installs Compiz with desktop cube, wobbly windows, and more
# Plus a beautiful Conky system monitor

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${PURPLE}========================================${NC}"
echo -e "${PURPLE}  COMPIZ FUSION & CONKY INSTALLER${NC}"
echo -e "${PURPLE}  Desktop Cube • Wobbly Windows${NC}"
echo -e "${PURPLE}========================================${NC}\n"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Please run as root (use sudo)${NC}"
    exit 1
fi

REAL_USER=$(logname 2>/dev/null || echo $SUDO_USER)
USER_HOME=$(eval echo ~$REAL_USER)

echo -e "${BLUE}Setting up for user: $REAL_USER${NC}\n"

# Detect desktop environment
if pgrep -x "cinnamon" > /dev/null; then
    DE="cinnamon"
elif pgrep -x "mate-panel" > /dev/null; then
    DE="mate"
elif pgrep -x "xfce4-panel" > /dev/null; then
    DE="xfce"
else
    DE="unknown"
fi

echo -e "${YELLOW}Detected desktop environment: $DE${NC}\n"

# Update system
echo -e "${YELLOW}[*] Updating system packages...${NC}"
apt update

# ===================================
# INSTALL COMPIZ
# ===================================

echo -e "\n${GREEN}[1/4] Installing Compiz Fusion${NC}"

apt install -y \
    compiz \
    compiz-core \
    compiz-plugins \
    compiz-plugins-extra \
    compizconfig-settings-manager \
    compiz-plugins-main \
    compiz-plugins-default \
    emerald \
    fusion-icon

# Install additional dependencies
apt install -y \
    mesa-utils \
    libgl1-mesa-dri \
    libgl1-mesa-glx

echo -e "${GREEN}[+] Compiz installed successfully!${NC}"

# ===================================
# CONFIGURE COMPIZ
# ===================================

echo -e "\n${GREEN}[2/4] Configuring Compiz with Eye Candy${NC}"

# Create compiz config directory
COMPIZ_DIR="$USER_HOME/.config/compiz-1/compizconfig"
mkdir -p "$COMPIZ_DIR"

# Enable the best plugins including cube and wobbly windows
cat > "$COMPIZ_DIR/Default.ini" << 'EOF'
[core]
s0_active_plugins = core;composite;opengl;compiztoolbox;decor;mousepoll;resize;place;move;wall;vpswitch;snap;grid;imgpng;regex;session;animation;fade;workarounds;scale;expo;ezoom;switcher;cube;rotate;cubeaddon;
s0_hsize = 4
s0_vsize = 1

[rotate]
s0_rotate_to_1_key = <Control><Alt>Left
s0_rotate_to_2_key = <Control><Alt>Down
s0_rotate_to_3_key = <Control><Alt>Right
s0_rotate_to_4_key = <Control><Alt>Up
s0_edge_flip_pointer = true
s0_edge_flip_window = true
s0_edge_flip_dnd = true
s0_speed = 2.000000
s0_timestep = 1.000000
s0_acceleration = 3.000000

[cube]
s0_unfold_key = <Control><Alt>Down
s0_in = true
s0_acceleration = 3.000000
s0_speed = 1.500000
s0_timestep = 1.200000
s0_mipmap = true
s0_multioutput_mode = 0
s0_active_opacity = 50.000000
s0_inactive_opacity = 100.000000
s0_transparent_manual_only = true
s0_top_color = #0000ffff
s0_bottom_color = #000000ff

[cubeaddon]
s0_top_images = /usr/share/pixmaps/faces/sky.jpg;
s0_bottom_images = /usr/share/pixmaps/faces/ground.jpg;
s0_reflection = true
s0_ground_color1 = #b3b3b3cc
s0_ground_color2 = #b3b3b300
s0_deformation = 1
s0_unfold_deformation = true
s0_cylinder_manual_only = false

[wobbly]
s0_snap_key = <Shift>
s0_snap_inverted = false
s0_shiver = false
s0_friction = 3.000000
s0_spring_k = 8.000000
s0_grid_resolution = 8
s0_min_grid_size = 8
s0_map_effect = 0
s0_focus_effect = 0
s0_map_window_match = Splash | DropdownMenu | PopupMenu | Tooltip | Notification | Combo | Dnd | Unknown
s0_focus_window_match = 
s0_grab_window_match = 
s0_move_window_match = Toolbar | Menu | Utility | Dialog | Normal | Unknown
s0_maximize_effect = true

[animation]
s0_open_effects = animation:Glide 2;
s0_open_durations = 120;
s0_open_matches = (type=Normal | Dialog | ModalDialog | Unknown);
s0_close_effects = animation:Glide 2;
s0_close_durations = 120;
s0_close_matches = (type=Normal | Dialog | ModalDialog | Unknown);
s0_minimize_effects = animation:Magic Lamp;
s0_minimize_durations = 200;
s0_minimize_matches = (type=Normal | Dialog | ModalDialog | Unknown);
s0_shade_effects = animation:Roll Up;
s0_shade_durations = 300;
s0_shade_matches = (type=Normal | Dialog | ModalDialog | Unknown);
s0_focus_effects = animation:Fade;
s0_focus_durations = 150;

[scale]
s0_initiate_edge = TopLeft
s0_initiate_key = <Super>w
s0_spacing = 10
s0_speed = 1.500000
s0_timestep = 1.200000
s0_window_match = Toolbar | Utility | Dialog | Normal | Unknown
s0_hover_time = 750
s0_multioutput_mode = 0

[expo]
s0_expo_key = <Super>e
s0_expo_edge = 
s0_double_click_time = 500
s0_dnd_button = Button1
s0_exit_button = Button3
s0_next_vp_left_button = Button6
s0_next_vp_right_button = Button7
s0_zoom_time = 0.300000
s0_expo_immediate_move = false
s0_expo_animation = 0
s0_deform = 0
s0_x_offset = 64
s0_y_offset = 24
s0_distance = 0.005000
s0_vp_brightness = 75.000000
s0_vp_saturation = 100.000000
s0_curve = 0.500000
s0_hide_docks = false
s0_mipmaps = true
s0_multioutput_mode = 0
s0_vp_distance = 0.200000
s0_aspect_ratio = 1.000000
s0_selected_color = #fb8b008f
s0_reflection = true
s0_ground_color1 = #b3b3b3cc
s0_ground_color2 = #b3b3b300
s0_ground_size = 0.500000

[fade]
s0_fade_mode = 0
s0_fade_speed = 5.000000
s0_fade_time = 100
s0_window_match = any & !(title=notify-osd)
s0_visual_bell = false
s0_fullscreen_visual_bell = false
s0_minimize_open_close = true
s0_dim_unresponsive = true
s0_unresponsive_brightness = 65
s0_unresponsive_saturation = 0

[ezoom]
s0_zoom_in_button = <Super>Button4
s0_zoom_out_button = <Super>Button5
s0_zoom_box_button = <Super>Button2
s0_zoom_spec_target_focus = true
s0_speed = 25.000000
s0_timestep = 1.200000

[wall]
s0_thumb_highlight_gradient_shadow_color = #00000000
s0_arrow_base_color = #e6e6e6d9
s0_arrow_shadow_color = #dcdcdcd9
s0_preview_timeout = 0.200000
s0_preview_scale = 130
s0_edge_radius = 5
s0_border_width = 10
s0_outline_color = #333333d9
s0_no_slide_match = type=Dock | type=Desktop | state=Sticky

[move]
s0_initiate_button = <Alt>Button1
s0_initiate_key = <Alt>F7
s0_opacity = 100
s0_constrain_y = true
s0_snapoff_maximized = true
s0_lazy_positioning = true

[resize]
s0_initiate_button = <Alt>Button2
s0_initiate_key = <Alt>F8
s0_mode = 2
s0_border_color = #2f2f4f9f
s0_fill_color = #2f2f4f4f

[switcher]
s0_next_key = <Alt>Tab
s0_prev_key = <Shift><Alt>Tab
s0_next_all_key = <Control><Alt>Tab
s0_prev_all_key = <Shift><Control><Alt>Tab
s0_speed = 1.500000
s0_timestep = 1.200000
s0_mipmap = true
s0_saturation = 100
s0_brightness = 65
s0_opacity = 100
s0_bring_to_front = true
s0_zoom = 1.000000
s0_icon = true
s0_minimized = true
s0_auto_rotate = false
EOF

chown -R $REAL_USER:$REAL_USER "$USER_HOME/.config/compiz-1"

echo -e "${GREEN}[+] Compiz configured with all effects!${NC}"

# ===================================
# INSTALL CONKY
# ===================================

echo -e "\n${GREEN}[3/4] Installing Conky${NC}"

apt install -y \
    conky-all \
    curl \
    lm-sensors \
    hddtemp

# Detect sensors
echo -e "${YELLOW}[*] Detecting system sensors...${NC}"
sensors-detect --auto > /dev/null 2>&1 || true

# Create a beautiful conky configuration
mkdir -p "$USER_HOME/.config/conky"

cat > "$USER_HOME/.config/conky/conky.conf" << 'EOF'
conky.config = {
    -- Window settings
    alignment = 'top_right',
    background = true,
    border_width = 1,
    cpu_avg_samples = 2,
    default_color = 'white',
    default_outline_color = 'white',
    default_shade_color = 'white',
    double_buffer = true,
    draw_borders = false,
    draw_graph_borders = true,
    draw_outline = false,
    draw_shades = false,
    
    -- Performance
    update_interval = 2.0,
    cpu_avg_samples = 2,
    net_avg_samples = 2,
    no_buffers = true,
    out_to_console = false,
    out_to_ncurses = false,
    out_to_stderr = false,
    out_to_x = true,
    extra_newline = false,
    
    -- Window appearance
    own_window = true,
    own_window_class = 'Conky',
    own_window_type = 'desktop',
    own_window_transparent = true,
    own_window_argb_visual = true,
    own_window_argb_value = 180,
    own_window_hints = 'undecorated,below,sticky,skip_taskbar,skip_pager',
    
    -- Positioning
    gap_x = 20,
    gap_y = 60,
    minimum_height = 5,
    minimum_width = 280,
    maximum_width = 280,
    
    -- Text settings
    use_xft = true,
    font = 'DejaVu Sans Mono:size=9',
    xftalpha = 0.8,
    uppercase = false,
    use_spacer = 'none',
    show_graph_scale = false,
    show_graph_range = false,
    
    -- Colors
    color1 = 'DDDDDD',  -- White
    color2 = '00AAFF',  -- Blue
    color3 = 'FFAA00',  -- Orange
    color4 = '00FF00',  -- Green
}

conky.text = [[
${color2}${font :size=12}${alignc}${nodename}${font}
${color1}${hr}
${color2}System Info${color1}
 Kernel: ${alignr}${kernel}
 Uptime: ${alignr}${uptime}
 
${color2}CPU${color1}
 Usage: ${alignr}${cpu}%
 ${cpubar 8}
 Frequency: ${alignr}${freq_g} GHz
 Temperature: ${alignr}${acpitemp}°C
 ${cpugraph 30,280 00AAFF 00FF00}
 
${color2}Memory${color1}
 RAM: ${alignr}${mem} / ${memmax}
 ${membar 8}
 Usage: ${alignr}${memperc}%
 Swap: ${alignr}${swap} / ${swapmax}
 
${color2}Storage${color1}
 Root: ${alignr}${fs_used /} / ${fs_size /}
 ${fs_bar 8 /}
 Usage: ${alignr}${fs_used_perc /}%
${if_existing /home}
 Home: ${alignr}${fs_used /home} / ${fs_size /home}
 ${fs_bar 8 /home}
 Usage: ${alignr}${fs_used_perc /home}%
${endif}

${color2}Network${color1}
${if_existing /proc/net/route wlan0}
 WiFi (${addr wlan0})
 Down: ${downspeed wlan0}/s ${alignr}Up: ${upspeed wlan0}/s
 ${downspeedgraph wlan0 20,135 00AAFF 00FF00} ${upspeedgraph wlan0 20,135 FFAA00 FF0000}
 Total: ${totaldown wlan0} ${alignr}Total: ${totalup wlan0}
${else}${if_existing /proc/net/route eth0}
 Ethernet (${addr eth0})
 Down: ${downspeed eth0}/s ${alignr}Up: ${upspeed eth0}/s
 ${downspeedgraph eth0 20,135 00AAFF 00FF00} ${upspeedgraph eth0 20,135 FFAA00 FF0000}
 Total: ${totaldown eth0} ${alignr}Total: ${totalup eth0}
${endif}${endif}

${color2}Processes${color1}
 Running: ${alignr}${running_processes} / ${processes}
 
 ${color3}Name${alignr}CPU%${color1}
 ${top name 1}${alignr}${top cpu 1}
 ${top name 2}${alignr}${top cpu 2}
 ${top name 3}${alignr}${top cpu 3}
 
 ${color3}Name${alignr}MEM%${color1}
 ${top_mem name 1}${alignr}${top_mem mem 1}
 ${top_mem name 2}${alignr}${top_mem mem 2}
 ${top_mem name 3}${alignr}${top_mem mem 3}

${color2}Shortcuts${color1}
 ${color3}Ctrl+Alt+Arrow${color1} - Rotate Cube
 ${color3}Super+E${color1} - Expo Mode
 ${color3}Super+W${color1} - Scale Windows
 ${color3}Alt+Tab${color1} - Switch Windows
]]
EOF

chown -R $REAL_USER:$REAL_USER "$USER_HOME/.config/conky"

echo -e "${GREEN}[+] Conky configured!${NC}"

# ===================================
# SETUP AUTOSTART
# ===================================

echo -e "\n${GREEN}[4/4] Setting up Autostart${NC}"

# Create autostart directory
mkdir -p "$USER_HOME/.config/autostart"

# Create Compiz autostart entry
cat > "$USER_HOME/.config/autostart/compiz.desktop" << EOF
[Desktop Entry]
Type=Application
Exec=fusion-icon
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Compiz Fusion
Comment=Start Compiz window manager with effects
EOF

# Create Conky autostart entry
cat > "$USER_HOME/.config/autostart/conky.desktop" << EOF
[Desktop Entry]
Type=Application
Exec=sh -c "sleep 10 && conky -c $USER_HOME/.config/conky/conky.conf"
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Conky System Monitor
Comment=Display system information
EOF

chown -R $REAL_USER:$REAL_USER "$USER_HOME/.config/autostart"

# ===================================
# CREATE HELPER SCRIPTS
# ===================================

echo -e "${YELLOW}[*] Creating helper scripts...${NC}"

# Script to start Compiz
cat > "$USER_HOME/start-compiz.sh" << 'EOF'
#!/bin/bash
# Start Compiz with Fusion Icon
killall cinnamon 2>/dev/null || true
killall marco 2>/dev/null || true
killall xfwm4 2>/dev/null || true
sleep 2
fusion-icon &
EOF

chmod +x "$USER_HOME/start-compiz.sh"

# Script to restart window manager
cat > "$USER_HOME/restart-wm.sh" << 'EOF'
#!/bin/bash
# Restart original window manager
killall compiz 2>/dev/null
sleep 1

if pgrep -x "cinnamon-session" > /dev/null; then
    nohup cinnamon --replace &
elif pgrep -x "mate-session" > /dev/null; then
    nohup marco --replace &
elif pgrep -x "xfce4-session" > /dev/null; then
    nohup xfwm4 --replace &
fi
EOF

chmod +x "$USER_HOME/restart-wm.sh"

# Script to toggle Conky
cat > "$USER_HOME/toggle-conky.sh" << EOF
#!/bin/bash
if pgrep -x "conky" > /dev/null; then
    killall conky
    notify-send "Conky" "Stopped"
else
    conky -c $USER_HOME/.config/conky/conky.conf &
    notify-send "Conky" "Started"
fi
EOF

chmod +x "$USER_HOME/toggle-conky.sh"

chown $REAL_USER:$REAL_USER "$USER_HOME"/*.sh

# Create desktop shortcuts
cat > "$USER_HOME/Desktop/Compiz-Settings.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Compiz Settings
Comment=Configure Compiz effects
Exec=ccsm
Icon=compiz
Terminal=false
Categories=Settings;
EOF

chmod +x "$USER_HOME/Desktop/Compiz-Settings.desktop"
chown $REAL_USER:$REAL_USER "$USER_HOME/Desktop/Compiz-Settings.desktop"

# ===================================
# CREATE QUICK START GUIDE
# ===================================

cat > "$USER_HOME/Desktop/Compiz-Guide.txt" << 'EOF'
COMPIZ FUSION QUICK START GUIDE
================================

ENABLED EFFECTS:
----------------
✓ Desktop Cube (3D rotating desktop)
✓ Wobbly Windows (windows wiggle when moved)
✓ Window Animations (smooth open/close effects)
✓ Expo Mode (show all workspaces)
✓ Scale Windows (show all windows)
✓ Magic Lamp (minimize animation)
✓ Cube Reflection
✓ Desktop Wall
✓ And many more!

KEYBOARD SHORTCUTS:
-------------------
Ctrl+Alt+Left/Right/Up/Down  - Rotate desktop cube
Super+E                      - Expo mode (all desktops)
Super+W                      - Scale windows (show all)
Alt+Tab                      - Switch windows (with effects)
Ctrl+Alt+Down                - Unfold cube
Super+Mouse Wheel            - Zoom in/out
Alt+Left Click               - Move window (wobbles!)
Alt+Middle Click             - Resize window

MOUSE GESTURES:
---------------
• Drag windows to screen edges to see cube rotate
• Move windows by holding Alt+Left Click
• Resize with Alt+Middle Click
• Wobbly effect activates when moving/resizing

TIPS & TRICKS:
--------------
1. Open Compiz Settings (CCSM) for more customization
2. Set 4 workspaces for best cube experience
3. Try different animation effects
4. Adjust wobbliness in Wobbly Windows settings
5. Add custom cube images in Cube Addon settings

CUSTOMIZATION:
--------------
• CompizConfig Settings Manager (CCSM)
  - Desktop Cube settings
  - Wobbly Windows options
  - Animation effects
  - Transparency settings
  - Many more plugins!

• Emerald Theme Manager
  - Custom window decorations
  - Download more themes

TROUBLESHOOTING:
----------------
If Compiz crashes or acts weird:

1. Restart Compiz:
   ./restart-compiz.sh

2. Go back to default WM:
   ./restart-wm.sh

3. Check if effects work:
   Open CCSM and verify plugins are enabled

4. Low FPS? Disable some effects:
   - Turn off cube reflection
   - Reduce animation quality
   - Disable blur effects

CONKY SHORTCUTS:
----------------
Toggle Conky:  ./toggle-conky.sh
Edit config:   nano ~/.config/conky/conky.conf

PERFORMANCE TIPS:
-----------------
• Compiz uses GPU acceleration (good!)
• May use more RAM than default WM
• Disable effects you don't use
• Wobbly windows is surprisingly light
• Desktop cube is the coolest effect!

ENJOY YOUR 3D DESKTOP!
======================
Show off that rotating cube! 🎲
EOF

chown $REAL_USER:$REAL_USER "$USER_HOME/Desktop/Compiz-Guide.txt"

# ===================================
# FINAL MESSAGES
# ===================================

echo -e "\n${PURPLE}========================================${NC}"
echo -e "${PURPLE}  Installation Complete! 🎉${NC}"
echo -e "${PURPLE}========================================${NC}\n"

echo -e "${GREEN}✓ Compiz Fusion installed${NC}"
echo -e "${GREEN}✓ Desktop Cube enabled${NC}"
echo -e "${GREEN}✓ Wobbly Windows enabled${NC}"
echo -e "${GREEN}✓ All eye candy effects configured${NC}"
echo -e "${GREEN}✓ Conky system monitor installed${NC}"
echo -e "${GREEN}✓ Autostart configured${NC}\n"

echo -e "${YELLOW}IMPORTANT - NEXT STEPS:${NC}"
echo -e "${BLUE}1.${NC} Log out and log back in"
echo -e "${BLUE}2.${NC} Compiz will start automatically (via Fusion Icon)"
echo -e "${BLUE}3.${NC} Try: ${GREEN}Ctrl+Alt+Left/Right${NC} to rotate the cube!"
echo -e "${BLUE}4.${NC} Try: ${GREEN}Alt+Click+Drag${NC} a window (wobbly!)"
echo -e "${BLUE}5.${NC} Try: ${GREEN}Super+E${NC} for Expo mode"
echo -e "${BLUE}6.${NC} Open ${GREEN}Compiz Settings${NC} from desktop to customize\n"

echo -e "${YELLOW}MANUAL START (if needed):${NC}"
echo -e "  cd ~ && ./start-compiz.sh\n"

echo -e "${YELLOW}HELPER SCRIPTS:${NC}"
echo -e "  ${GREEN}~/start-compiz.sh${NC}    - Start Compiz manually"
echo -e "  ${GREEN}~/restart-wm.sh${NC}      - Return to default window manager"
echo -e "  ${GREEN}~/toggle-conky.sh${NC}    - Toggle Conky on/off\n"

echo -e "${YELLOW}GUIDES ON DESKTOP:${NC}"
echo -e "  • Compiz-Guide.txt"
echo -e "  • Compiz-Settings.desktop\n"

echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}     Enjoy your 3D desktop! 🎲✨${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}\n"

# Ask if user wants to start Compiz now
if [ -n "$DISPLAY" ]; then
    read -p "Start Compiz now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo -u $REAL_USER DISPLAY=$DISPLAY fusion-icon &
        sleep 3
        sudo -u $REAL_USER DISPLAY=$DISPLAY conky -c "$USER_HOME/.config/conky/conky.conf" &
        echo -e "\n${GREEN}Compiz and Conky started! Rotate your cube with Ctrl+Alt+Arrows!${NC}\n"
    fi
fi
