#!/data/data/com.termux/files/usr/bin/bash
G='\033[1;32m'; BG='\033[1;92m'; N='\033[0m'

echo -e "${BG}[*] Update package...${N}"
pkg update -y && pkg upgrade -y

echo -e "${BG}[*] Install dependency...${N}"
pkg install -y curl git jq nano figlet toilet

echo -e "${BG}[*] Set executable...${N}"
chmod +x "$HOME/amgen/amgen.sh"

echo -e "${BG}[*] Tambah alias...${N}"
grep -q "alias amgen" ~/.bashrc || echo 'alias amgen="bash ~/amgen/amgen.sh"' >> ~/.bashrc
source ~/.bashrc 2>/dev/null

echo ""
echo -e "${G}==============================================${N}"
echo -e "${BG}   INSTALL SELESAI${N}"
echo -e "${G}==============================================${N}"
echo -e "${G}  Jalanin: ${BG}amgen${N}"
echo -e "${G}==============================================${N}"
