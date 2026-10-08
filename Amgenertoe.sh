#!/data/data/com.termux/files/usr/bin/bash
# ==========================================
#   GENERATOR PREMIUM - AMGEN
#   Alight Motion Premium Full Flow
# ==========================================

[ -f "$HOME/amgen/.env" ] && source "$HOME/amgen/.env"

API_BASE="${API_BASE:-https://axzyedev.biz.id/api/v1}"
API_KEY="${API_KEY:-AzaGanteng-J402QodDBXHB2mqaxKIjKV1FXKJGBTQ2}"

G='\033[1;32m'
DG='\033[0;32m'
BG='\033[1;92m'
N='\033[0m'

STATE_DIR="$HOME/amgen/state"
mkdir -p "$STATE_DIR"

banner() {
  clear
  echo -e "${BG}"
  echo "  ██████╗ ███████╗███╗   ██╗███████╗██████╗  "
  echo " ██╔════╝ ██╔════╝████╗  ██║██╔════╝██╔══██╗ "
  echo " ██║  ███╗█████╗  ██╔██╗ ██║█████╗  ██████╔╝ "
  echo " ██║   ██║██╔══╝  ██║╚██╗██║██╔══╝  ██╔══██╗ "
  echo " ╚██████╔╝███████╗██║ ╚████║███████╗██║  ██║ "
  echo "  ╚═════╝ ╚══════╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ "
  echo -e "${N}"
  echo -e "${G}==============================================${N}"
  echo -e "${BG}         >>  GENERATOR PREMIUM  <<${N}"
  echo -e "${G}==============================================${N}"
  echo -e "${DG}  API Base :${N} ${G}$API_BASE${N}"
  echo -e "${DG}  API Key  :${N} ${G}${API_KEY:0:14}********${N}"
  echo -e "${G}==============================================${N}"
  echo ""
}

loading() {
  echo -ne "${G}[*] $1 ${N}"
  for i in $(seq 1 25); do echo -ne "${BG}#${N}"; sleep 0.03; done
  echo -e " ${BG}[OK]${N}"
}

# ---------- 1. SEND MAGIC LINK ----------
menu_send() {
  echo ""
  read -p "$(echo -e ${G}"[?] Email target: "${N})" EMAIL
  [ -z "$EMAIL" ] && echo -e "${G}[!] kosong.${N}" && return
  echo ""
  loading "Kirim magic link"
  RESP=$(curl -s -X POST "$API_BASE/send-magic-link" \
    -H "Content-Type: application/json" \
    -H "X-API-Key: $API_KEY" \
    -d "{\"email\":\"$EMAIL\"}" --max-time 25)
  echo ""
  echo -e "${G}==============================================${N}"
  echo -e "${BG}         HASIL SEND MAGIC LINK${N}"
  echo -e "${G}==============================================${N}"
  echo "$RESP" | jq . 2>/dev/null || echo -e "${G}$RESP${N}"
  echo -e "${G}==============================================${N}"
  echo -e "${DG}[i] Cek email target, copy link verifikasi.${N}"
  echo -e "${DG}[i] Lanjut menu [2] Verify Account.${N}"
  echo "$EMAIL" > "$STATE_DIR/last_email"
}

# ---------- 2. VERIFY ACCOUNT ----------
menu_verify() {
  echo ""
  echo -e "${DG}[i] Masukin email + link verifikasi dari email target.${N}"
  echo ""
  read -p "$(echo -e ${G}"[?] Email target: "${N})" EMAIL
  [ -z "$EMAIL" ] && echo -e "${G}[!] kosong.${N}" && return
  read -p "$(echo -e ${G}"[?] Raw link (paste full): "${N})" RAWLINK
  [ -z "$RAWLINK" ] && echo -e "${G}[!] link kosong.${N}" && return
  echo ""
  loading "Verify account"
  RESP=$(curl -s -X POST "$API_BASE/verify-account" \
    -H "Content-Type: application/json" \
    -H "X-API-Key: $API_KEY" \
    -d "{\"email\":\"$EMAIL\",\"rawLink\":\"$RAWLINK\"}" --max-time 25)
  echo ""
  echo -e "${G}==============================================${N}"
  echo -e "${BG}         HASIL VERIFY ACCOUNT${N}"
  echo -e "${G}==============================================${N}"
  echo "$RESP" | jq . 2>/dev/null || echo -e "${G}$RESP${N}"
  echo -e "${G}==============================================${N}"

  IDTOKEN=$(echo "$RESP" | jq -r '.idToken // empty' 2>/dev/null)
  REFRESH=$(echo "$RESP" | jq -r '.refreshToken // empty' 2>/dev/null)
  if [ -n "$IDTOKEN" ]; then
    echo "$IDTOKEN" > "$STATE_DIR/id_token"
    echo "$REFRESH" > "$STATE_DIR/refresh_token"
    echo "$EMAIL" > "$STATE_DIR/last_email"
    echo -e "${BG}[+] idToken & refreshToken tersimpan.${N}"
    echo -e "${DG}[i] Lanjut menu [3] Apply Premium.${N}"
  else
    echo -e "${G}[!] idToken kosong, cek response.${N}"
  fi
}

# ---------- 3. APPLY PREMIUM ----------
menu_apply() {
  echo ""
  IDTOKEN=$(cat "$STATE_DIR/id_token" 2>/dev/null)
  EMAIL=$(cat "$STATE_DIR/last_email" 2>/dev/null)
  if [ -z "$IDTOKEN" ]; then
    echo -e "${G}[!] belum ada idToken. jalanin menu [2] dulu.${N}"
    return
  fi
  echo -e "${DG}[i] Pakai idToken dari state. email: $EMAIL${N}"
  echo ""
  loading "Apply premium"
  RESP=$(curl -s -X POST "$API_BASE/apply-premium" \
    -H "Content-Type: application/json" \
    -H "X-API-Key: $API_KEY" \
    -d "{\"idToken\":\"$IDTOKEN\",\"email\":\"$EMAIL\"}" --max-time 25)
  echo ""
  echo -e "${G}==============================================${N}"
  echo -e "${BG}         HASIL APPLY PREMIUM${N}"
  echo -e "${G}==============================================${N}"
  echo "$RESP" | jq . 2>/dev/null || echo -e "${G}$RESP${N}"
  echo -e "${G}==============================================${N}"
}

# ---------- 4. AUTO FLOW ----------
menu_auto() {
  echo ""
  echo -e "${DG}[i] Flow: send → tunggu link → verify → apply.${N}"
  echo ""
  read -p "$(echo -e ${G}"[?] Email target: "${N})" EMAIL
  [ -z "$EMAIL" ] && echo -e "${G}[!] kosong.${N}" && return
  echo ""
  loading "Step 1/3 Kirim magic link"
  R1=$(curl -s -X POST "$API_BASE/send-magic-link" \
    -H "Content-Type: application/json" \
    -H "X-API-Key: $API_KEY" \
    -d "{\"email\":\"$EMAIL\"}" --max-time 25)
  echo -e "${DG}    resp: $(echo $R1 | head -c 120)${N}"
  echo ""
  echo -e "${BG}[i] Cek email target sekarang. Copy link verifikasi.${N}"
  echo ""
  read -p "$(echo -e ${G}"[?] Paste raw link dari email: "${N})" RAWLINK
  [ -z "$RAWLINK" ] && echo -e "${G}[!] link kosong, abort.${N}" && return
  echo ""
  loading "Step 2/3 Verify account"
  R2=$(curl -s -X POST "$API_BASE/verify-account" \
    -H "Content-Type: application/json" \
    -H "X-API-Key: $API_KEY" \
    -d "{\"email\":\"$EMAIL\",\"rawLink\":\"$RAWLINK\"}" --max-time 25)
  IDTOKEN=$(echo "$R2" | jq -r '.idToken // empty' 2>/dev/null)
  REFRESH=$(echo "$R2" | jq -r '.refreshToken // empty' 2>/dev/null)
  if [ -z "$IDTOKEN" ]; then
    echo -e "${G}[!] verify gagal:${N}"
    echo "$R2" | jq . 2>/dev/null || echo "$R2"
    return
  fi
  echo "$IDTOKEN" > "$STATE_DIR/id_token"
  echo "$REFRESH" > "$STATE_DIR/refresh_token"
  echo "$EMAIL" > "$STATE_DIR/last_email"
  echo -e "${DG}    idToken: ${IDTOKEN:0:30}...${N}"
  echo ""
  loading "Step 3/3 Apply premium"
  R3=$(curl -s -X POST "$API_BASE/apply-premium" \
    -H "Content-Type: application/json" \
    -H "X-API-Key: $API_KEY" \
    -d "{\"idToken\":\"$IDTOKEN\",\"email\":\"$EMAIL\"}" --max-time 25)
  echo ""
  echo -e "${G}==============================================${N}"
  echo -e "${BG}         HASIL AKHIR${N}"
  echo -e "${G}==============================================${N}"
  echo "$R3" | jq . 2>/dev/null || echo -e "${G}$R3${N}"
  echo -e "${G}==============================================${N}"
  echo -e "${BG}[+] Selesai. Buka Alight Motion buat verify.${N}"
  LOG="$HOME/amgen/log_$(date +%Y%m%d_%H%M%S).txt"
  { echo "Email: $EMAIL"; echo "Send: $R1"; echo "Verify: $R2"; echo "Apply: $R3"; } > "$LOG"
  echo -e "${DG}[+] log: $LOG${N}"
}

# ---------- 5. REFRESH TOKEN ----------
menu_refresh() {
  echo ""
  REFRESH=$(cat "$STATE_DIR/refresh_token" 2>/dev/null)
  if [ -z "$REFRESH" ]; then
    echo -e "${G}[!] belum ada refreshToken. jalanin verify dulu.${N}"
    return
  fi
  loading "Refresh token"
  RESP=$(curl -s -X POST "$API_BASE/refresh-token" \
    -H "Content-Type: application/json" \
    -H "X-API-Key: $API_KEY" \
    -d "{\"refreshToken\":\"$REFRESH\"}" --max-time 25)
  echo ""
  echo -e "${G}==============================================${N}"
  echo -e "${BG}         HASIL REFRESH TOKEN${N}"
  echo -e "${G}==============================================${N}"
  echo "$RESP" | jq . 2>/dev/null || echo -e "${G}$RESP${N}"
  echo -e "${G}==============================================${N}"
  NEWID=$(echo "$RESP" | jq -r '.idToken // empty' 2>/dev/null)
  [ -n "$NEWID" ] && echo "$NEWID" > "$STATE_DIR/id_token" && echo -e "${BG}[+] idToken updated.${N}"
}

# ---------- MENU ----------
menu() {
  banner
  echo -e "${G}  [1]${N} ${BG}Send Magic Link${N}"
  echo -e "${G}  [2]${N} ${BG}Verify Account${N}"
  echo -e "${G}  [3]${N} ${BG}Apply Premium${N}"
  echo -e "${G}  [4]${N} ${BG}Auto Flow (semua sekaligus)${N}"
  echo -e "${G}  [5]${N} ${BG}Refresh Token${N}"
  echo -e "${G}  [6]${N} ${BG}Keluar${N}"
  echo ""
  echo -e "${G}==============================================${N}"
  read -p "$(echo -e ${BG}" >> Pilih nomor: "${N})" PIL
  case $PIL in
    1) menu_send; read -p "Enter..." ;;
    2) menu_verify; read -p "Enter..." ;;
    3) menu_apply; read -p "Enter..." ;;
    4) menu_auto; read -p "Enter..." ;;
    5) menu_refresh; read -p "Enter..." ;;
    6) echo -e "${BG}bye ngap.${N}"; exit 0 ;;
    *) echo -e "${G}[!] pilihan salah.${N}"; sleep 1 ;;
  esac
}

for c in curl jq; do
  command -v $c &>/dev/null || { echo -e "${G}[!] install dulu: pkg install $c${N}"; exit 1; }
done

while true; do menu; done
