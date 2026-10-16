#!/bin/bash

# ============================================
# DEBUG - PROVJERI VARIJABLE
# ============================================

echo "=== DEBUG INFO ==="
echo "SHELL: $SHELL"
echo "HOME: $HOME"
echo "=================="

# ============================================
# LINUX AVANTURA - IGRA ZA UČENJE LINUXA
# (VERZIJA S IZBOROM ODGOVORA A/B/C/D)
# ============================================

# Boje za zabavniji prikaz
CRVENO='\033[0;31m'
ZELENO='\033[0;32m'
ZUTO='\033[1;33m'
PLAVO='\033[0;34m'
LJUBICASTO='\033[0;35m'
CIJANO='\033[0;36m'
PODVLACENO='\033[4m'
DEBELO='\033[1m'
NORMALNO='\033[0m'

# Bodovi
BODOVI=0
RAZINA=1

# ============================================
# TEŽINA IGRE - KOLIKO VREMENA DIJETE IMA ZA ODGOVOR
# ============================================
# BASE_VRIJEME je broj sekundi za odgovor na razini LAGANO.
# SREDNJE ide 1/3 BRŽE (dijete ima 2/3 od BASE_VRIJEME).
# TEŠKO ide 2/3 BRŽE (dijete ima 1/3 od BASE_VRIJEME).
# Vrijeme je UVIJEK ISTO za svako pitanje - ne raste i ne pada
# tijekom igre, ovisi samo o odabranoj težini.
BASE_VRIJEME=30
TEZINA="LAGANO"
VRIJEME_ODGOVORA=$BASE_VRIJEME

odaberi_tezinu() {
    echo -e "\n${LJUBICASTO}${DEBELO}⏱ IZABERI TEŽINU IGRE:${NORMALNO}"
    echo -e "${CIJANO}========================================${NORMALNO}"
    echo -e "  ${ZELENO}${DEBELO}1)${NORMALNO} LAGANO  - PUNO VREMENA ZA RAZMISLITI (${BASE_VRIJEME}S PO PITANJU)"
    echo -e "  ${ZUTO}${DEBELO}2)${NORMALNO} SREDNJE - MALO BRŽE ($(( BASE_VRIJEME * 2 / 3 ))S PO PITANJU)"
    echo -e "  ${CRVENO}${DEBELO}3)${NORMALNO} TEŠKO   - BRZO, ZA PRAVE MAJSTORE ($(( BASE_VRIJEME / 3 ))S PO PITANJU)"
    echo -e "${CIJANO}========================================${NORMALNO}"

    local izbor_tezine=""
    while true; do
        echo -n "TVOJ IZBOR (1-3): "
        read izbor_tezine
        case "$izbor_tezine" in
            1)
                TEZINA="LAGANO"
                VRIJEME_ODGOVORA=$BASE_VRIJEME
                break
                ;;
            2)
                TEZINA="SREDNJE"
                VRIJEME_ODGOVORA=$(( BASE_VRIJEME * 2 / 3 ))
                break
                ;;
            3)
                TEZINA="TEŠKO"
                VRIJEME_ODGOVORA=$(( BASE_VRIJEME / 3 ))
                break
                ;;
            *)
                echo -e "${ZUTO}NAPIŠI 1, 2 ILI 3.${NORMALNO}"
                ;;
        esac
    done

    echo -e "${ZELENO}✅ TEŽINA POSTAVLJENA NA: $TEZINA (${VRIJEME_ODGOVORA}S PO PITANJU)${NORMALNO}"
    zapisnik "IZABRAO/LA TEŽINU: $TEZINA (${VRIJEME_ODGOVORA}S PO PITANJU)"
}

# ============================================
# DOHVATI KORISNIČKO IME
# ============================================

KORISNIK=$(whoami)
PUNO_IME=$(getent passwd $KORISNIK | cut -d: -f5 | cut -d',' -f1)

if [ -z "$PUNO_IME" ]; then
    PUNO_IME="$KORISNIK"
fi

# Prvo slovo veliko za ljepši prikaz (a kasnije ionako sve ide u VELIKA SLOVA)
PUNO_IME=$(echo "$PUNO_IME" | sed 's/.*/\L&/; s/[a-z]*/\u&/')
PUNO_IME_VELIKO=$(echo "$PUNO_IME" | tr '[:lower:]' '[:upper:]')
KORISNIK_VELIKO=$(echo "$KORISNIK" | tr '[:lower:]' '[:upper:]')

# ============================================
# SIGURNOSNA PROVJERA $HOME VARIJABLE
# ============================================
if [[ "$HOME" != /* ]]; then
    echo -e "${CRVENO}⚠️  UPOZORENJE: HOME VARIJABLA NIJE ISPRAVNA ('$HOME'). POPRAVLJAM AUTOMATSKI...${NORMALNO}"
    HOME_STVARNI=$(getent passwd "$KORISNIK" | cut -d: -f6)
    if [[ -z "$HOME_STVARNI" || "$HOME_STVARNI" != /* ]]; then
        HOME_STVARNI="/home/$KORISNIK"
    fi
    export HOME="$HOME_STVARNI"
    echo -e "${ZELENO}✅ HOME ISPRAVLJEN NA: $HOME${NORMALNO}"
fi

# ============================================
# POSTAVKE DIREKTORIJA
# ============================================
# SVE datoteke igre (dnevnik, certifikat, privremeni podaci)
# kreiraju se U ISTOM DIREKTORIJU GDJE JE SPREMLJENA OVA SKRIPTA -
# bez obzira odakle je pokrenuta (iz tog direktorija, apsolutnom
# putanjom, relativnom putanjom, preko simboličke poveznice...).
# BASH_SOURCE[0] je putanja do skripte kako je pozvana; dirname
# izvlači direktorij, a cd+pwd ga pretvara u APSOLUTNU putanju
# (rješava i slučaj pokretanja iz nekog drugog direktorija).
SKRIPTA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GLAVNI_DIR="$SKRIPTA_DIR"
DNEVNIK="$GLAVNI_DIR/linux_avantura_dnevnik.txt"
CERTIFIKAT="$GLAVNI_DIR/linux_certifikat_${KORISNIK}.txt"
IGRA_TMP_DIR="$GLAVNI_DIR/.igra_tmp"

echo "SKRIPTA_DIR: $SKRIPTA_DIR"
echo "GLAVNI_DIR: $GLAVNI_DIR"
echo "DNEVNIK: $DNEVNIK"
echo "CERTIFIKAT: $CERTIFIKAT"

if [ ! -d "$GLAVNI_DIR" ]; then
    echo -e "${ZUTO}📁 KREIRAM DIREKTORIJ: $GLAVNI_DIR${NORMALNO}"
    mkdir -p "$GLAVNI_DIR"
    chmod 755 "$GLAVNI_DIR"
fi

if [ -d "$GLAVNI_DIR/~" ]; then
    echo -e "${ZUTO}🧹 PRONAŠAO/LA SAM STARU ZABRLJANU MAPU '~' UNUTAR UCI_LINUX, ČISTIM JE...${NORMALNO}"
    cp -rn "$GLAVNI_DIR/~/." "$GLAVNI_DIR/" 2>/dev/null
    rm -rf "$GLAVNI_DIR/~"
    echo -e "${ZELENO}✅ SREĐENO! SVE JE SAD U: $GLAVNI_DIR${NORMALNO}"
fi

rm -rf "$IGRA_TMP_DIR" 2>/dev/null

# ============================================
# DNEVNIK NAPRETKA
# ============================================

zapisnik() {
    local poruka="$1"

    if [ ! -d "$GLAVNI_DIR" ]; then
        echo -e "${ZUTO}📁 KREIRAM DIREKTORIJ: $GLAVNI_DIR${NORMALNO}"
        mkdir -p "$GLAVNI_DIR"
        chmod 755 "$GLAVNI_DIR"
    fi

    echo "$(date '+%Y-%m-%d %H:%M:%S') - $PUNO_IME_VELIKO: $poruka" >> "$DNEVNIK"

    if [ ! -s "$DNEVNIK" ]; then
        echo "========================================" > "$DNEVNIK"
        echo "  LINUX AVANTURA - DNEVNIK NAPRETKA" >> "$DNEVNIK"
        echo "  IGRAČ: $PUNO_IME_VELIKO ($KORISNIK_VELIKO)" >> "$DNEVNIK"
        echo "  POČETAK: $(date '+%Y-%m-%d %H:%M:%S')" >> "$DNEVNIK"
        echo "========================================" >> "$DNEVNIK"
        echo "" >> "$DNEVNIK"
    fi
}

# ============================================
# PERSONALIZIRANI SAVJETI
# ============================================

daj_savjet() {
    local razina="$1"
    local savjeti_osnovni=(
        "💡 SAVJET, $PUNO_IME_VELIKO: KAD ZAPNEŠ, UVIJEK MOŽEŠ UPISATI 'MAN' ZA POMOĆ!"
        "💡 SAVJET, $PUNO_IME_VELIKO: TAB TIPKA AUTOMATSKI DOVRŠAVA NAREDBE - PROBAJ!"
        "💡 SAVJET, $PUNO_IME_VELIKO: 'CLEAR' ĆE OČISTITI EKRAN KAD POSTANE PREVIŠE NATRPANO"
        "💡 SAVJET, $PUNO_IME_VELIKO: 'HISTORY' POKAZUJE SVE TVOJE RANIJE NAREDBE"
        "💡 SAVJET, $PUNO_IME_VELIKO: STRELICA GORE/DOLJE VRAĆA STARE NAREDBE"
    )

    local savjeti_srednji=(
        "💡 SAVJET, $PUNO_IME_VELIKO: 'GREP' JE KAO DETEKTIV - TRAŽI OBRASCE U DATOTEKAMA!"
        "💡 SAVJET, $PUNO_IME_VELIKO: '|' (PIPE) SPAJA NAREDBE - KAO CJEVOVOD U IGRICI!"
        "💡 SAVJET, $PUNO_IME_VELIKO: 'CHMOD' MIJENJA DOZVOLE - KAO KLJUČ ZA VRATA"
        "💡 SAVJET, $PUNO_IME_VELIKO: 'FIND' JE TVOJ NAJBOLJI PRIJATELJ ZA TRAŽENJE"
        "💡 SAVJET, $PUNO_IME_VELIKO: 'ALIAS' MOŽE SKRATITI DUGE NAREDBE - KAO PREČICA"
    )

    local savjeti_napredni=(
        "💡 SAVJET, $PUNO_IME_VELIKO: 'CRON' MOŽE POKRETATI NAREDBE U ODREĐENO VRIJEME!"
        "💡 SAVJET, $PUNO_IME_VELIKO: 'SSH' TE SPAJA NA DRUGE RAČUNARE - KAO TELEPORT"
        "💡 SAVJET, $PUNO_IME_VELIKO: 'SCP' SIGURNO KOPIRA DATOTEKE NA DRUGE RAČUNARE"
        "💡 SAVJET, $PUNO_IME_VELIKO: 'SCREEN' DRŽI TVOJE SESIJE OTVORENIMA"
        "💡 SAVJET, $PUNO_IME_VELIKO: LINUX JE KAO LEGO - SVE MOŽEŠ SLAGATI KAKO ŽELIŠ!"
    )

    if [[ "$PUNO_IME_VELIKO" == "MARKO" ]]; then
        echo -e "${ZELENO}💡 MARKO, ZNAŠ LI DA JE LINUX DOBIO IME PO LINUSU TORVALDSU?${NORMALNO}"
        return
    elif [[ "$PUNO_IME_VELIKO" == "ANA" ]] || [[ "$PUNO_IME_VELIKO" == "IVA" ]]; then
        echo -e "${ZELENO}💡 $PUNO_IME_VELIKO, PRVA PROGRAMERKA NA SVIJETU BILA JE ADA LOVELACE!${NORMALNO}"
        return
    elif [[ "$PUNO_IME_VELIKO" == "LUKA" ]]; then
        echo -e "${ZELENO}💡 LUKA, PRVI LINUX KERNEL NAPISAN JE 1991. - ISTE GODINE KAD SI TI?${NORMALNO}"
        return
    fi

    case $razina in
        1|2)
            local idx=$((RANDOM % ${#savjeti_osnovni[@]}))
            echo -e "${ZELENO}${savjeti_osnovni[$idx]}${NORMALNO}"
            ;;
        3|4)
            local idx=$((RANDOM % ${#savjeti_srednji[@]}))
            echo -e "${ZELENO}${savjeti_srednji[$idx]}${NORMALNO}"
            ;;
        *)
            local idx=$((RANDOM % ${#savjeti_napredni[@]}))
            echo -e "${ZELENO}${savjeti_napredni[$idx]}${NORMALNO}"
            ;;
    esac
}

# ============================================
# BADGE SUSTAV
# ============================================

BADGE_OSVOJENI=()
BADGE_NIVO=0

dodaj_badge() {
    local badge="$1"
    local boja="$2"

    for b in "${BADGE_OSVOJENI[@]}"; do
        if [[ "$b" == "$badge" ]]; then
            return
        fi
    done

    BADGE_OSVOJENI+=("$badge")
    BADGE_NIVO=$((BADGE_NIVO + 1))

    echo -e "\n${boja}🏅 OSVOJIO/LA SI BADGE: ${DEBELO}$badge${NORMALNO}"
    echo -e "${boja}   UKUPNO BADGE-OVA: $BADGE_NIVO${NORMALNO}"
    zapisnik "OSVOJIO/LA BADGE: $badge"
}

prikazi_badge_ove() {
    echo -e "\n${LJUBICASTO}${DEBELO}🏅 TVOJE BADGE-OVE:${NORMALNO}"

    if [ ${#BADGE_OSVOJENI[@]} -eq 0 ]; then
        echo -e "${ZUTO}JOŠ NEMAŠ BADGE-OVE. IGRAJ IGRE DA IH OSVOJIŠ!${NORMALNO}"
        return
    fi

    local i=1
    for badge in "${BADGE_OSVOJENI[@]}"; do
        echo -e "  $i. $badge"
        ((i++))
    done

    echo -e "\n${DEBELO}UKUPNO: $BADGE_NIVO BADGE-OVA${NORMALNO}"

    if [ $BADGE_NIVO -ge 8 ]; then
        echo -e "${ZELENO}🌟 LEGENDA LINUXA! SVE BADGE-OVE IMAŠ!${NORMALNO}"
    elif [ $BADGE_NIVO -ge 5 ]; then
        echo -e "${ZELENO}⭐ VRLO DOBAR - SAMO JOŠ MALO DO LEGENDE!${NORMALNO}"
    elif [ $BADGE_NIVO -ge 3 ]; then
        echo -e "${ZUTO}📈 NAPREDUJEŠ - NASTAVI TAKO!${NORMALNO}"
    else
        echo -e "${CIJANO}🌱 POČETNIK - SVAKI MAJSTOR JE BIO POČETNIK!${NORMALNO}"
    fi
}

# ============================================
# CERTIFIKAT
# ============================================

certifikat() {
    echo -e "\n${LJUBICASTO}${DEBELO}========================================${NORMALNO}"
    echo -e "${LJUBICASTO}${DEBELO}      🏆 PERSONALIZIRANI CERTIFIKAT 🏆${NORMALNO}"
    echo -e "${LJUBICASTO}${DEBELO}========================================${NORMALNO}"

    local datum=$(date '+%d.%m.%Y.')
    local razina_zvanja=""

    if [ $BODOVI -ge 200 ]; then
        razina_zvanja="MAJSTOR LINUXA 🐧"
        boja_zvanja=$ZELENO
    elif [ $BODOVI -ge 140 ]; then
        razina_zvanja="LINUX GURU 🌟"
        boja_zvanja=$ZELENO
    elif [ $BODOVI -ge 70 ]; then
        razina_zvanja="LINUX AVANTURIST 🗺️"
        boja_zvanja=$ZUTO
    else
        razina_zvanja="LINUX PUTNIK 🌱"
        boja_zvanja=$CIJANO
    fi

    local badge_count=${#BADGE_OSVOJENI[@]}

    local CERT_TEKST
    CERT_TEKST=$(cat << EOF
${ZELENO}╔══════════════════════════════════════════════════════════════╗
║                                                                  ║
║              🏆 SLUŽBENI CERTIFIKAT O ZNANJU 🏆               ║
║                                                                  ║
║   OVIME SE POTVRĐUJE DA JE                                      ║
║                                                                  ║
║   ${DEBELO}⭐ $PUNO_IME_VELIKO ⭐${NORMALNO}${ZELENO}                                            ║
║                                                                  ║
║   USPJEŠNO ZAVRŠIO/LA LINUX AVANTURU I POKAZAO/LA               ║
║   IZVRSNO ZNANJE OSNOVA LINUXA!                                 ║
║                                                                  ║
║   📅 DATUM: $datum                                               ║
║   🏅 BODOVI: $BODOVI                                            ║
║   🏅 BADGE-OVI: $badge_count                                    ║
║   🎓 ZVANJE: ${boja_zvanja}${DEBELO}$razina_zvanja${NORMALNO}${ZELENO}                            ║
║                                                                  ║
║   🌟 POSEBNO PRIZNANJE:                                          ║
║   $PUNO_IME_VELIKO JE POKAZAO/LA IZVRSNU ZNATIŽELJU I            ║
║   UPORNOST U UČENJU LINUXA!                                     ║
║                                                                  ║
║   ${DEBELO}🐧 NASTAVI ISTRAŽIVATI SVIJET LINUXA! 🐧${NORMALNO}${ZELENO}                  ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════╝${NORMALNO}
EOF
)
    echo -e "$CERT_TEKST"

    {
        echo "========================================"
        echo "  🏆 CERTIFIKAT O ZNANJU LINUXA 🏆"
        echo "========================================"
        echo ""
        echo "IGRAČ: $PUNO_IME_VELIKO ($KORISNIK_VELIKO)"
        echo "DATUM: $datum"
        echo "BODOVI: $BODOVI"
        echo "BADGE-OVI: $badge_count"
        echo "ZVANJE: $razina_zvanja"
        echo ""
        echo "OSVOJENI BADGE-OVI:"
        for badge in "${BADGE_OSVOJENI[@]}"; do
            echo "  - $badge"
        done
        echo ""
        echo "----------------------------------------"
        echo "🐧 NASTAVI ISTRAŽIVATI LINUX! 🐧"
        echo "========================================"
    } > "$CERTIFIKAT"

    echo -e "\n${ZELENO}💾 CERTIFIKAT JE SPREMLJEN U: $CERTIFIKAT${NORMALNO}"
    echo -e "${ZELENO}📝 MOŽEŠ GA ISPISATI ILI PODIJELITI S PRIJATELJIMA!${NORMALNO}"

    zapisnik "DOBIO/LA CERTIFIKAT: $razina_zvanja"
}

# ============================================
# VARALICA ZA IGRU - POKAZUJE SVE ODGOVORE
# ============================================

prikazi_varalicu() {
    echo -e "\n${ZUTO}${DEBELO}📋 VARALICA - SVI ODGOVORI ZA OVU IGRU:${NORMALNO}"
    echo -e "${CIJANO}----------------------------------------${NORMALNO}"

    case $1 in
        "navigacija")
            echo -e "${ZELENO}  PWD        ${NORMALNO}→ POKAZUJE GDJE SI"
            echo -e "${ZELENO}  CD         ${NORMALNO}→ IDE U TVOJ DOM (BEZ ARGUMENATA)"
            echo -e "${ZELENO}  CD /HOME/$KORISNIK_VELIKO ${NORMALNO}→ IDE U TVOJ DOM"
            echo -e "${ZELENO}  CD ..      ${NORMALNO}→ IDE GORE (RODITELJSKI)"
            echo -e "${ZELENO}  LS         ${NORMALNO}→ POKAZUJE ŠTO IMA"
            echo -e "${ZELENO}  MKDIR IME  ${NORMALNO}→ NAPRAVI DIREKTORIJ"
            ;;
        "datoteke")
            echo -e "${ZELENO}  CAT DATOTEKA    ${NORMALNO}→ VIDI ŠTO PIŠE"
            echo -e "${ZELENO}  CP IZ U        ${NORMALNO}→ KOPIRAJ"
            echo -e "${ZELENO}  MV STARI NOVI   ${NORMALNO}→ PREMJESTI/PREIMENUJ"
            echo -e "${ZELENO}  RM DATOTEKA     ${NORMALNO}→ OBRIŠI"
            echo -e "${ZELENO}  TAIL -5         ${NORMALNO}→ VIDI KRAJ"
            ;;
        "permisije")
            echo -e "${ZELENO}  LS -L       ${NORMALNO}→ VIDI DOZVOLE"
            echo -e "${ZELENO}  CHMOD +X    ${NORMALNO}→ DAJ DOZVOLU ZA POKRETANJE"
            echo -e "${ZELENO}  CHOWN       ${NORMALNO}→ PROMIJENI VLASNIKA"
            echo -e "${ZELENO}  SUDO        ${NORMALNO}→ KAO ADMINISTRATOR"
            echo -e "${ZELENO}  WHOAMI      ${NORMALNO}→ TKO SI TI"
            ;;
        "potraznja")
            echo -e "${ZELENO}  FIND / -NAME  ${NORMALNO}→ TRAŽI DATOTEKU"
            echo -e "${ZELENO}  MAN           ${NORMALNO}→ PRIRUČNIK"
            echo -e "${ZELENO}  PS AUX        ${NORMALNO}→ PROCESI KOJI RADE"
            echo -e "${ZELENO}  CTRL+C        ${NORMALNO}→ PREKINI PROGRAM"
            echo -e "${ZELENO}  DF -H         ${NORMALNO}→ SLOBODAN DISK"
            ;;
    esac

    echo -e "${CIJANO}----------------------------------------${NORMALNO}"
    echo -e "${ZUTO}💡 POGLEDAJ GORE, ODGOVORI SU TU!${NORMALNO}"
    echo -e "${ZELENO}📝 MOŽEŠ GLEDATI VARALICU DOK ODGOVARAŠ!${NORMALNO}\n"
}

# ============================================
# PROVJERA OPERATIVNOG SUSTAVA
# ============================================

provjeri_os() {
    echo -e "${PLAVO}========================================${NORMALNO}"
    echo -e "${DEBELO}🔍 PROVJERA TVOJEG RAČUNALA${NORMALNO}"
    echo -e "${PLAVO}========================================${NORMALNO}"

    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo -e "${ZELENO}✅ KORISTIŠ LINUX! SUPER! 🐧${NORMALNO}"

        if [ -f /etc/os-release ]; then
            . /etc/os-release
            local NAME_VELIKO=$(echo "$NAME" | tr '[:lower:]' '[:upper:]')
            echo -e "📦 TVOJ LINUX SE ZOVE: ${DEBELO}$NAME_VELIKO${NORMALNO}"

            echo -e "\n${ZUTO}📚 KAKO NADOGRADITI (UPDATE/UPGRADE):${NORMALNO}"

            if command -v pacman &> /dev/null; then
                echo -e "  ${ZELENO}sudo pacman -Syu${NORMALNO}  # AŽURIRA SVE"
                echo -e "  ${ZELENO}sudo pacman -S${NORMALNO} IME_PROGRAMA # INSTALIRAJ PROGRAM"

                if command -v yay &> /dev/null; then
                    echo -e "  ${ZELENO}yay -Syu${NORMALNO}          # AŽURIRA SVE (UKLJUČUJUĆI AUR)"
                elif command -v paru &> /dev/null; then
                    echo -e "  ${ZELENO}paru -Syu${NORMALNO}         # AŽURIRA SVE (UKLJUČUJUĆI AUR)"
                fi

            elif command -v apt &> /dev/null; then
                echo -e "  ${ZELENO}sudo apt update${NORMALNO}   # AŽURIRA POPIS PROGRAMA"
                echo -e "  ${ZELENO}sudo apt upgrade${NORMALNO}  # NADOGRADI PROGRAME"
                echo -e "  ${ZELENO}sudo apt install ${NORMALNO}IME_PROGRAMA # INSTALIRAJ PROGRAM"

            elif command -v dnf &> /dev/null; then
                echo -e "  ${ZELENO}sudo dnf update${NORMALNO}   # AŽURIRA SVE"
                echo -e "  ${ZELENO}sudo dnf install${NORMALNO} IME_PROGRAMA # INSTALIRAJ PROGRAM"

            elif command -v zypper &> /dev/null; then
                echo -e "  ${ZELENO}sudo zypper refresh${NORMALNO}  # OSVJEŽI REPOZITORIJE"
                echo -e "  ${ZELENO}sudo zypper update${NORMALNO}   # AŽURIRA SVE"

            else
                echo -e "  ${ZUTO}NE MOGU PREPOZNATI PAKET MENADŽER.${NORMALNO}"
                echo -e "  ${ZUTO}KORISTIŠ $NAME_VELIKO, POGLEDAJ ONLINE KAKO SE RADI UPDATE${NORMALNO}"
            fi

            echo -e "\n${CIJANO}💡 TVOJ PAKET MENADŽER: ${DEBELO}$(command -v pacman || command -v apt || command -v dnf || command -v zypper 2>/dev/null)${NORMALNO}"
        fi

    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo -e "${ZUTO}🍎 KORISTIŠ macOS (TO JE KAO LINUX, ALI DRUGAČIJI)${NORMALNO}"
        echo -e "\n${ZUTO}📚 NADOGRADNJA NA macOS-U:${NORMALNO}"
        echo -e "  ${ZELENO}softwareupdate -l${NORMALNO}      # VIDI DOSTUPNE NADOGRADNJE"
        echo -e "  ${ZELENO}softwareupdate -i -a${NORMALNO}  # INSTALIRAJ SVE"
        echo -e "  ${ZELENO}brew update${NORMALNO}           # AKO IMAŠ HOMEBREW"
        echo -e "  ${ZELENO}brew upgrade${NORMALNO}          # NADOGRADI S HOMEBREW-OM"

    elif [[ "$OSTYPE" == "msys"* ]] || [[ "$OSTYPE" == "cygwin"* ]] || [[ "$OSTYPE" == "win32" ]]; then
        echo -e "${CRVENO}🪟 KORISTIŠ WINDOWS!${NORMALNO}"
        echo -e "${ZUTO}💡 SAVJET: INSTALIRAJ WSL (WINDOWS SUBSYSTEM FOR LINUX)${NORMALNO}"
        echo -e "   ILI KORISTI GIT BASH ZA VJEŽBANJE LINUX NAREDBI!\n"
    else
        echo -e "${ZUTO}❓ NE ZNAM KOJI OS KORISTIŠ, ALI TO JE OK!${NORMALNO}"
    fi
}

# ============================================
# DRVO LINUXA - Objašnjenje strukture
# ============================================

nacrtaj_drvo() {
    echo -e "\n${LJUBICASTO}${DEBELO}🌳 DRVO LINUXA - KAKO JE SVE POSLOŽENO${NORMALNO}"
    echo -e "${CIJANO}========================================${NORMALNO}"

    echo -e "        /"
    echo -e "       ├── BIN     → OSNOVNI PROGRAMI (LS, CP, MV...)"
    echo -e "       ├── BOOT    → POKRETANJE SUSTAVA"
    echo -e "       ├── DEV     → UREĐAJI (MIŠ, TIPKOVNICA...)"
    echo -e "       ├── ETC     → POSTAVKE SUSTAVA"
    echo -e "       ├── HOME    → 🏠 TVOJ DOM (OVO JE TVOJE!)"
    echo -e "       │   └── ${ZELENO}${DEBELO}$KORISNIK_VELIKO${NORMALNO} ← ${ZUTO}${DEBELO}TI SI OVDJE, $PUNO_IME_VELIKO!${NORMALNO}"
    echo -e "       │       ├── DOKUMENTI"
    echo -e "       │       ├── SLIKE"
    echo -e "       │       ├── GLAZBA"
    echo -e "       │       ├── PREUZIMANJA"
    echo -e "       │       └── VIDEOZAPISI"
    echo -e "       ├── OPT     → DODATNI PROGRAMI"
    echo -e "       ├── TMP     → PRIVREMENE DATOTEKE (BRIŠU SE)"
    echo -e "       ├── USR     → PROGRAMI ZA SVE KORISNIKE"
    echo -e "       └── VAR     → STVARI KOJE SE MIJENJAJU (LOGOVI)"

    echo -e "\n${ZUTO}💡 NAJVAŽNIJE:"
    echo -e "${ZELENO}/HOME/$KORISNIK_VELIKO${NORMALNO} = TVOJ DOMAĆI DIREKTORIJ"
    echo -e "${ZELENO}/${NORMALNO} = KORIJEN (ROOT) - POČETAK SVEGA"
    echo -e "${ZELENO}..${NORMALNO} = IDI GORE (U RODITELJSKI DIREKTORIJ)"
    echo -e "${ZELENO}.${NORMALNO}  = TRENUTNI DIREKTORIJ"

    echo -e "\n${CIJANO}📌 TVOJE IME: ${DEBELO}$PUNO_IME_VELIKO${NORMALNO}"
    echo -e "${CIJANO}📌 TVOJE KORISNIČKO IME: ${DEBELO}$KORISNIK_VELIKO${NORMALNO}"

    daj_savjet 1
}

# ============================================
# POMOĆ - SVE NAREDBE I OBJAŠNJENJA
# ============================================

prikazi_naredbe() {
    echo -e "\n${LJUBICASTO}${DEBELO}📚 LINUX NAREDBE - PRIRUČNIK ZA POČETNIKE${NORMALNO}"
    echo -e "${CIJANO}========================================${NORMALNO}"

    echo -e "\n${DEBELO}${ZELENO}📁 NAVIGACIJA:${NORMALNO}"
    echo -e "  ${DEBELO}PWD${NORMALNO}     - PRINT WORKING DIRECTORY (POKAZUJE GDJE SI)"
    echo -e "  ${DEBELO}LS${NORMALNO}      - LIST (POPISUJE DATOTEKE I DIREKTORIJE)"
    echo -e "  ${DEBELO}LS -LA${NORMALNO}  - LIST S VIŠE DETALJA (UKLJUČUJUĆI SKRIVENE)"
    echo -e "  ${DEBELO}CD${NORMALNO}      - CHANGE DIRECTORY (PROMIJENI DIREKTORIJ)"
    echo -e "  ${DEBELO}CD${NORMALNO}      - IDE U TVOJ DOMAĆI DIREKTORIJ (BEZ ARGUMENATA)"
    echo -e "  ${DEBELO}CD /HOME/$KORISNIK_VELIKO${NORMALNO} - IDE U TVOJ DOMAĆI DIREKTORIJ"
    echo -e "  ${DEBELO}CD ..${NORMALNO}   - IDE JEDAN KORAK GORE (RODITELJSKI)"
    echo -e "  ${DEBELO}CD /${NORMALNO}    - IDE U KORIJEN (ROOT) DIREKTORIJ"
    echo -e "  ${DEBELO}MKDIR${NORMALNO}   - MAKE DIRECTORY (NAPRAVI NOVI DIREKTORIJ)"

    echo -e "\n${DEBELO}${ZELENO}📄 RAD S DATOTEKAMA:${NORMALNO}"
    echo -e "  ${DEBELO}CAT${NORMALNO}     - CONCATENATE (ISPISUJE SADRŽAJ DATOTEKE)"
    echo -e "  ${DEBELO}CP${NORMALNO}      - COPY (KOPIRA DATOTEKE ILI DIREKTORIJE)"
    echo -e "  ${DEBELO}MV${NORMALNO}      - MOVE (PREMJEŠTA ILI PREIMENUJE)"
    echo -e "  ${DEBELO}RM${NORMALNO}      - REMOVE (BRIŠE DATOTEKE)"
    echo -e "  ${DEBELO}RM -RF${NORMALNO}  - BRIŠE DIREKTORIJE I SAV NJIHOV SADRŽAJ (OPREZNO!)"
    echo -e "  ${DEBELO}TOUCH${NORMALNO}   - STVARA PRAZNU DATOTEKU ILI AŽURIRA VRIJEME"
    echo -e "  ${DEBELO}HEAD${NORMALNO}    - POKAZUJE PRVIH 10 REDAKA DATOTEKE"
    echo -e "  ${DEBELO}TAIL${NORMALNO}    - POKAZUJE ZADNJIH 10 REDAKA DATOTEKE"

    echo -e "\n${DEBELO}${ZELENO}🔐 SIGURNOST I DOZVOLE:${NORMALNO}"
    echo -e "  ${DEBELO}LS -L${NORMALNO}   - POKAZUJE DOZVOLE ZA DATOTEKE"
    echo -e "  ${DEBELO}CHMOD${NORMALNO}   - CHANGE MODE (MIJENJA DOZVOLE)"
    echo -e "  ${DEBELO}CHOWN${NORMALNO}   - CHANGE OWNER (MIJENJA VLASNIKA)"
    echo -e "  ${DEBELO}SUDO${NORMALNO}    - SUPERUSER DO (IZVRŠAVA KAO ADMINISTRATOR)"
    echo -e "  ${DEBELO}WHOAMI${NORMALNO}  - POKAZUJE TKO SI TRENUTNO PRIJAVLJEN"
    echo -e "  ${DEBELO}ID${NORMALNO}      - POKAZUJE TVOJ ID I GRUPE"

    echo -e "\n${DEBELO}${ZELENO}🔍 TRAŽENJE I POMOĆ:${NORMALNO}"
    echo -e "  ${DEBELO}MAN${NORMALNO}     - MANUAL (PRIRUČNIK ZA NAREDBE)"
    echo -e "  ${DEBELO}FIND${NORMALNO}    - TRAŽI DATOTEKE I DIREKTORIJE"
    echo -e "  ${DEBELO}GREP${NORMALNO}    - TRAŽI TEKST UNUTAR DATOTEKA"
    echo -e "  ${DEBELO}PS${NORMALNO}      - PROCESI (POKAZUJE PROGRAME KOJI RADE)"
    echo -e "  ${DEBELO}PS AUX${NORMALNO}  - SVI PROCESI S DETALJIMA"
    echo -e "  ${DEBELO}DF -H${NORMALNO}   - DISK FREE (SLOBODNI PROSTOR NA DISKU)"
    echo -e "  ${DEBELO}DU -SH${NORMALNO}  - DISK USAGE (VELIČINA DIREKTORIJA)"
    echo -e "  ${DEBELO}HISTORY${NORMALNO} - POVIJEST TVOJIH NAREDBI"

    echo -e "\n${DEBELO}${ZELENO}💡 KORISNI SAVJETI:${NORMALNO}"
    echo -e "  ${DEBELO}CTRL+C${NORMALNO}  - PREKIDA TRENUTNI PROGRAM"
    echo -e "  ${DEBELO}CTRL+D${NORMALNO}  - ZATVARA TERMINAL ILI ULAZ"
    echo -e "  ${DEBELO}TAB${NORMALNO}     - AUTOMATSKO DOVRŠAVANJE NAREDBI"
    echo -e "  ${DEBELO}↑/↓${NORMALNO}     - STRELICAMA VRAĆAŠ STARE NAREDBE"
    echo -e "  ${DEBELO}CLEAR${NORMALNO}   - ČISTI EKRAN"
    echo -e "  ${DEBELO}EXIT${NORMALNO}    - ZATVARA TERMINAL"

    echo -e "\n${DEBELO}${ZELENO}🌳 VAŽNI DIREKTORIJI:${NORMALNO}"
    echo -e "  ${DEBELO}/${NORMALNO}        - KORIJEN (ROOT) - POČETAK SVEGA"
    echo -e "  ${DEBELO}/HOME/${NORMALNO}   - DOMAĆI DIREKTORIJI SVIH KORISNIKA"
    echo -e "  ${DEBELO}/HOME/$KORISNIK_VELIKO${NORMALNO} - TVOJ DOM (TAMO SU DOKUMENTI, SLIKE...)"
    echo -e "  ${DEBELO}/HOME/$KORISNIK_VELIKO${NORMALNO} - PREČAC ZA TVOJ DOMAĆI DIREKTORIJ"
    echo -e "  ${DEBELO}..${NORMALNO}       - RODITELJSKI DIREKTORIJ (IDI GORE)"
    echo -e "  ${DEBELO}.${NORMALNO}        - TRENUTNI DIREKTORIJ"
    echo -e "  ${DEBELO}/TMP/${NORMALNO}    - PRIVREMENE DATOTEKE (BRIŠU SE PRI RESTARTU)"
    echo -e "  ${DEBELO}/ETC/${NORMALNO}    - POSTAVKE SUSTAVA"
    echo -e "  ${DEBELO}/USR/${NORMALNO}    - PROGRAMI ZA SVE KORISNIKE"

    echo -e "\n${CIJANO}========================================${NORMALNO}"
    echo -e "${ZUTO}💡 SAVJET: OVE NAREDBE ĆEŠ KORISTITI U IGRAMA!${NORMALNO}"
    echo -e "${ZELENO}📖 PREPORUKA: ISPROBAJ SVAKU NAREDBU U TERMINALU!${NORMALNO}"

    zapisnik "PREGLEDAO/LA PRIRUČNIK NAREDBI"
}

# ============================================
# POZDRAVNA PORUKA S IMENOM
# ============================================

pozdrav() {
    echo -e "\n${LJUBICASTO}${DEBELO}╔═════════════════════════════════════════════╗${NORMALNO}"
    echo -e "${LJUBICASTO}${DEBELO}║   🐧 LINUX AVANTURA ZA DJECU 🐧           ║${NORMALNO}"
    echo -e "${LJUBICASTO}${DEBELO}╚═════════════════════════════════════════════╝${NORMALNO}"
    echo -e "${CIJANO}=================================================${NORMALNO}"

    echo -e "${ZELENO}${DEBELO}👋 DOBRODOŠAO, $PUNO_IME_VELIKO!${NORMALNO}"
    echo -e "${ZUTO}DANAS ĆEMO ZAJEDNO ISTRAŽIVATI LINUX!${NORMALNO}"
    echo -e "${CIJANO}TVOJ DOMAĆI DIREKTORIJ JE: ${ZELENO}/HOME/$KORISNIK_VELIKO${NORMALNO}"
    echo -e "${CIJANO}=================================================${NORMALNO}\n"

    zapisnik "POKRENUO/LA IGRU"
    daj_savjet 1
}

# ============================================
# PITANJE S IZBOROM ODGOVORA (A/B/C/D)
# ============================================
# Argumenti:
#  $1 = tekst pitanja
#  $2 = TOČAN odgovor (tekst)
#  $3 = kriv odgovor 1
#  $4 = kriv odgovor 2
#  $5 = kriv odgovor 3
#  $6 = objašnjenje (prikazuje se nakon odgovora)
# Povratna vrijednost (return): 0 = točno, 1 = netočno
# Bodovi se automatski dodaju u BODOVI.

postavi_pitanje() {
    local pitanje="$1"
    local tocan="$2"
    local kriva1="$3"
    local kriva2="$4"
    local kriva3="$5"
    local objasnjenje="$6"

    echo -e "\n${DEBELO}$pitanje${NORMALNO}"

    # izmiješaj opcije
    local opcije=("$tocan" "$kriva1" "$kriva2" "$kriva3")
    local slova=(A B C D)
    local i j tmp
    for ((i=3; i>0; i--)); do
        j=$((RANDOM % (i+1)))
        tmp="${opcije[i]}"
        opcije[i]="${opcije[j]}"
        opcije[j]="$tmp"
    done

    local tocno_slovo=""
    for i in 0 1 2 3; do
        if [[ "${opcije[i]}" == "$tocan" ]]; then
            tocno_slovo="${slova[i]}"
        fi
        echo -e "  ${ZELENO}${DEBELO}${slova[i]})${NORMALNO} ${opcije[i]}"
    done

    local odgovor=""
    echo -e "${CIJANO}⏱ IMAŠ $VRIJEME_ODGOVORA SEKUNDI DA ODGOVORIŠ!${NORMALNO}"
    echo -n "TVOJ ODGOVOR (A/B/C/D): "

    if read -t "$VRIJEME_ODGOVORA" odgovor; then
        odgovor=$(echo "$odgovor" | tr -d '[:space:]' | tr '[:lower:]' '[:upper:]')
    else
        echo ""
        echo -e "${CRVENO}⏰ VRIJEME JE ISTEKLO!${NORMALNO}"
        odgovor=""
    fi

    if [[ "$odgovor" != "A" && "$odgovor" != "B" && "$odgovor" != "C" && "$odgovor" != "D" ]]; then
        echo -e "${CRVENO}❌ NIJE TOČNO. TOČAN ODGOVOR JE: $tocno_slovo) $tocan${NORMALNO}"
        echo -e "${ZUTO}💡 $objasnjenje${NORMALNO}"
        BODOVI=$((BODOVI + 5))
        sleep 1
        return 1
    fi

    if [[ "$odgovor" == "$tocno_slovo" ]]; then
        echo -e "${ZELENO}✅ TOČNO! $objasnjenje${NORMALNO}"
        BODOVI=$((BODOVI + 10))
        sleep 1
        return 0
    else
        echo -e "${CRVENO}❌ NIJE TOČNO. TOČAN ODGOVOR JE: $tocno_slovo) $tocan${NORMALNO}"
        echo -e "${ZUTO}💡 $objasnjenje${NORMALNO}"
        BODOVI=$((BODOVI + 5))
        sleep 1
        return 1
    fi
}

# ============================================
# IGRE
# ============================================

# 1. IGRA - Navigacija
igra_navigacija() {
    clear
    RAZINA=1

    echo -e "\n${ZUTO}${DEBELO}🗺️ IGRA 1: GDJE SE NALAZIM?${NORMALNO}"
    echo -e "${CIJANO}----------------------------------------${NORMALNO}"

    prikazi_varalicu "navigacija"

    echo -e "\n${DEBELO}PITANJA (ODGOVORI SU GORE ☝️):${NORMALNO}"
    echo -e "${CIJANO}========================================${NORMALNO}"

    local tocnih=0

    postavi_pitanje \
        "PITANJE 1: KOJA NAREDBA POKAZUJE GDJE SE TRENUTNO NALAZIŠ?" \
        "PWD" "LS" "CD" "WHOAMI" \
        "PWD = PRINT WORKING DIRECTORY (ISPISUJE PUTANJU)" && tocnih=$((tocnih+1))
    echo -e "${PLAVO}BODOVI: $BODOVI${NORMALNO}"

    postavi_pitanje \
        "PITANJE 2: KAKO IDEŠ U SVOJ DOMAĆI DIREKTORIJ (GDJE SU DOKUMENTI, SLIKE...)?" \
        "CD" "CD .." "LS -LA" "MKDIR" \
        "CD (BEZ ARGUMENATA) = IDE U TVOJ DOM ( /HOME/$KORISNIK_VELIKO )" && tocnih=$((tocnih+1))
    echo -e "${PLAVO}BODOVI: $BODOVI${NORMALNO}"

    postavi_pitanje \
        "PITANJE 3: KAKO IDEŠ JEDAN KORAK GORE (U RODITELJSKI DIREKTORIJ)?" \
        "CD .." "CD ~" "PWD" "CD ." \
        ".. ZNAČI 'IDI GORE'" && tocnih=$((tocnih+1))
    echo -e "${PLAVO}BODOVI: $BODOVI${NORMALNO}"

    postavi_pitanje \
        "PITANJE 4: KAKO VIDIŠ ŠTO SVE IMA U TRENUTNOM DIREKTORIJU?" \
        "LS" "CAT" "PWD" "MKDIR" \
        "LS = LIST (POPIŠI SADRŽAJ)" && tocnih=$((tocnih+1))
    echo -e "${PLAVO}BODOVI: $BODOVI${NORMALNO}"

    postavi_pitanje \
        "PITANJE 5: KAKO NAPRAVIŠ NOVI DIREKTORIJ 'MOJE_IGRE'?" \
        "MKDIR MOJE_IGRE" "CD MOJE_IGRE" "TOUCH MOJE_IGRE" "RM MOJE_IGRE" \
        "MKDIR = MAKE DIRECTORY (NAPRAVI DIREKTORIJ)" && tocnih=$((tocnih+1))
    echo -e "${PLAVO}BODOVI: $BODOVI${NORMALNO}"

    if [ $tocnih -eq 5 ]; then
        dodaj_badge "🗺️ MAJSTOR NAVIGACIJE" "$ZELENO"
    elif [ $tocnih -ge 3 ]; then
        dodaj_badge "🗺️ PUTNIK" "$ZUTO"
    fi

    zapisnik "ZAVRŠIO/LA IGRU 1 (NAVIGACIJA) - $tocnih/5 TOČNIH"
    daj_savjet 2
}

# 2. IGRA - Rad s datotekama
igra_datoteke() {
    clear
    RAZINA=2

    echo -e "\n${ZUTO}${DEBELO}📄 IGRA 2: DATOTEKE I DIREKTORIJI${NORMALNO}"
    echo -e "${CIJANO}----------------------------------------${NORMALNO}"

    prikazi_varalicu "datoteke"

    echo -e "\n${DEBELO}PITANJA (ODGOVORI SU GORE ☝️):${NORMALNO}"
    echo -e "${CIJANO}========================================${NORMALNO}"

    mkdir -p "$IGRA_TMP_DIR"

    local _stari_pwd
    _stari_pwd=$(pwd)
    trap 'cd "$_stari_pwd" 2>/dev/null; rm -rf "$IGRA_TMP_DIR"' RETURN INT

    cd "$IGRA_TMP_DIR" || { echo -e "${CRVENO}GREŠKA: NE MOGU UĆI U PRIVREMENI DIREKTORIJ IGRE.${NORMALNO}"; return; }

    echo -e "\nNAPRAVIT ĆEMO NEKE DATOTEKE ZA VJEŽBU!"
    echo -e "${ZELENO}STVORENE DATOTEKE:${NORMALNO}"
    touch pjesma.txt prica.txt crtez.txt
    echo "HELLO LINUX!" > pozdrav.txt
    echo "OVO JE MOJA PJESMA" > pjesma.txt
    echo "BIO JEDNOM JEDAN LINUX..." > prica.txt

    ls -la

    local tocnih=0

    postavi_pitanje \
        "PITANJE 1: KAKO VIDIŠ ŠTO PIŠE U DATOTECI POZDRAV.TXT?" \
        "CAT POZDRAV.TXT" "LS POZDRAV.TXT" "RM POZDRAV.TXT" "MKDIR POZDRAV.TXT" \
        "CAT = CONCATENATE (ISPISUJE SADRŽAJ)" && tocnih=$((tocnih+1))
    echo -e "${PLAVO}BODOVI: $BODOVI${NORMALNO}"

    postavi_pitanje \
        "PITANJE 2: KAKO KOPIRAŠ PJESMA.TXT U PJESMA_KOPIJA.TXT?" \
        "CP PJESMA.TXT PJESMA_KOPIJA.TXT" "MV PJESMA.TXT PJESMA_KOPIJA.TXT" "CAT PJESMA.TXT PJESMA_KOPIJA.TXT" "RM PJESMA.TXT PJESMA_KOPIJA.TXT" \
        "CP = COPY (KOPIRA DATOTEKU)" && tocnih=$((tocnih+1))
    echo -e "${PLAVO}BODOVI: $BODOVI${NORMALNO}"

    postavi_pitanje \
        "PITANJE 3: KAKO PREMJESTIŠ (PREIMENUJEŠ) CRTEZ.TXT U SLIKA.TXT?" \
        "MV CRTEZ.TXT SLIKA.TXT" "CP CRTEZ.TXT SLIKA.TXT" "RM CRTEZ.TXT SLIKA.TXT" "CAT CRTEZ.TXT SLIKA.TXT" \
        "MV = MOVE (PREMJEŠTA ILI PREIMENUJE)" && tocnih=$((tocnih+1))
    echo -e "${PLAVO}BODOVI: $BODOVI${NORMALNO}"

    postavi_pitanje \
        "PITANJE 4: KAKO OBRIŠEŠ DATOTEKU PRICA.TXT?" \
        "RM PRICA.TXT" "CP PRICA.TXT" "MV PRICA.TXT" "CAT PRICA.TXT" \
        "RM = REMOVE (BRIŠE DATOTEKU)" && tocnih=$((tocnih+1))
    echo -e "${PLAVO}BODOVI: $BODOVI${NORMALNO}"

    postavi_pitanje \
        "PITANJE 5: KAKO VIDIŠ ZADNJIH 5 REDAKA U DATOTECI?" \
        "TAIL -5" "HEAD -5" "CAT -5" "LS -5" \
        "TAIL = POKAZUJE KRAJ DATOTEKE" && tocnih=$((tocnih+1))
    echo -e "${PLAVO}BODOVI: $BODOVI${NORMALNO}"

    if [ $tocnih -eq 5 ]; then
        dodaj_badge "📄 GOSPODAR DATOTEKA" "$ZELENO"
    elif [ $tocnih -ge 3 ]; then
        dodaj_badge "📄 RADNIK S DATOTEKAMA" "$ZUTO"
    fi

    zapisnik "ZAVRŠIO/LA IGRU 2 (DATOTEKE) - $tocnih/5 TOČNIH"

    cd "$_stari_pwd" 2>/dev/null
    rm -rf "$IGRA_TMP_DIR"
    trap - RETURN INT

    daj_savjet 3
}

# 3. IGRA - Permisije i korisnici
igra_permisije() {
    clear
    RAZINA=3

    echo -e "\n${ZUTO}${DEBELO}🔐 IGRA 3: SIGURNOST I DOZVOLE${NORMALNO}"
    echo -e "${CIJANO}----------------------------------------${NORMALNO}"

    prikazi_varalicu "permisije"

    echo -e "\n${DEBELO}PITANJA (ODGOVORI SU GORE ☝️):${NORMALNO}"
    echo -e "${CIJANO}========================================${NORMALNO}"

    echo -e "\n${DEBELO}📖 MALI VODIČ:${NORMALNO}"
    echo "LINUX IMA 3 VRSTE DOZVOLA:"
    echo "  R = READ (ČITAJ)"
    echo "  W = WRITE (PIŠI)"
    echo "  X = EXECUTE (POKRENI)"
    echo ""
    echo "TRI GRUPE KORISNIKA:"
    echo "  VLASNIK | GRUPA | OSTALI"
    echo "  RWX     RWX     RWX"
    echo -e "  NPR. ${ZELENO}-RW-R--R--${NORMALNO} ZNAČI:"
    echo "  VLASNIK MOŽE ČITATI I PISATI, OSTALI SAMO ČITATI"
    echo -e "\n${CIJANO}TI SI TRENUTNO KORISNIK: ${DEBELO}$KORISNIK_VELIKO${NORMALNO}"

    local tocnih=0

    postavi_pitanje \
        "PITANJE 1: KOJOM NAREDBOM VIDIŠ DOZVOLE ZA DATOTEKE?" \
        "LS -L" "LS -A" "CHMOD -L" "PWD -L" \
        "LS -L PRIKAZUJE DETALJAN POPIS S DOZVOLAMA" && tocnih=$((tocnih+1))
    echo -e "${PLAVO}BODOVI: $BODOVI${NORMALNO}"

    postavi_pitanje \
        "PITANJE 2: KAKO DATOTECI 'IGRA.SH' DAŠ DOZVOLU ZA IZVRŠAVANJE?" \
        "CHMOD +X IGRA.SH" "CHOWN +X IGRA.SH" "SUDO +X IGRA.SH" "RM +X IGRA.SH" \
        "CHMOD +X DODAJE DOZVOLU ZA POKRETANJE" && tocnih=$((tocnih+1))
    echo -e "${PLAVO}BODOVI: $BODOVI${NORMALNO}"

    postavi_pitanje \
        "PITANJE 3: KOJA NAREDBA MIJENJA VLASNIKA DATOTEKE?" \
        "CHOWN" "CHMOD" "SUDO" "WHOAMI" \
        "CHOWN = CHANGE OWNER (MIJENJA VLASNIKA)" && tocnih=$((tocnih+1))
    echo -e "${PLAVO}BODOVI: $BODOVI${NORMALNO}"

    postavi_pitanje \
        "PITANJE 4: ŠTO ZNAČI 'SUDO'?" \
        "SUPERUSER DO - IZVRŠAVA NAREDBU KAO ADMINISTRATOR" \
        "SUPER DOBRO - POKREĆE IGRU" \
        "SUSTAV DO - ISKLJUČUJE RAČUNALO" \
        "SIGURAN DOKUMENT - SPREMA DATOTEKU" \
        "SUDO = SUPERUSER DO" && tocnih=$((tocnih+1))
    echo -e "${PLAVO}BODOVI: $BODOVI${NORMALNO}"

    postavi_pitanje \
        "PITANJE 5: KAKO VIDIŠ TKO SI TRENUTNO PRIJAVLJEN?" \
        "WHOAMI" "WHO" "ID" "PWD" \
        "WHOAMI ISPISUJE TVOJE KORISNIČKO IME" && tocnih=$((tocnih+1))
    echo -e "${PLAVO}BODOVI: $BODOVI${NORMALNO}"

    if [ $tocnih -eq 5 ]; then
        dodaj_badge "🔐 ČUVAR SIGURNOSTI" "$ZELENO"
    elif [ $tocnih -ge 3 ]; then
        dodaj_badge "🔐 PRIPRAVNIK" "$ZUTO"
    fi

    zapisnik "ZAVRŠIO/LA IGRU 3 (PERMISIJE) - $tocnih/5 TOČNIH"
    daj_savjet 3
}

# 4. IGRA - Potražnja i pomoć
igra_potraznja() {
    clear
    RAZINA=4

    echo -e "\n${ZUTO}${DEBELO}🔍 IGRA 4: TRAŽENJE I POMOĆ${NORMALNO}"
    echo -e "${CIJANO}----------------------------------------${NORMALNO}"

    prikazi_varalicu "potraznja"

    echo -e "\n${DEBELO}PITANJA (ODGOVORI SU GORE ☝️):${NORMALNO}"
    echo -e "${CIJANO}========================================${NORMALNO}"

    local tocnih=0

    postavi_pitanje \
        "PITANJE 1: KAKO TRAŽIŠ DATOTEKU PO IMENU U CIJELOM SUSTAVU?" \
        "FIND / -NAME" "GREP / -NAME" "LS / -NAME" "CAT / -NAME" \
        "FIND = TRAŽI DATOTEKE" && tocnih=$((tocnih+1))
    echo -e "${PLAVO}BODOVI: $BODOVI${NORMALNO}"

    postavi_pitanje \
        "PITANJE 2: KOJA NAREDBA POKAZUJE UPUTE ZA NEKU NAREDBU?" \
        "MAN" "HELP" "INFO" "DOC" \
        "MAN = MANUAL (PRIRUČNIK)" && tocnih=$((tocnih+1))
    echo -e "${PLAVO}BODOVI: $BODOVI${NORMALNO}"

    postavi_pitanje \
        "PITANJE 3: KAKO VIDIŠ SVE PROCESE KOJI TRENUTNO RADE?" \
        "PS AUX" "LS AUX" "FIND AUX" "DF AUX" \
        "PS = PROCESI" && tocnih=$((tocnih+1))
    echo -e "${PLAVO}BODOVI: $BODOVI${NORMALNO}"

    postavi_pitanje \
        "PITANJE 4: KAKO PREKINEŠ PROGRAM KOJI SE NE ŽELI ZAUSTAVITI?" \
        "CTRL+C" "CTRL+Z" "CTRL+X" "CTRL+D" \
        "CTRL+C = PREKIDA PROGRAM" && tocnih=$((tocnih+1))
    echo -e "${PLAVO}BODOVI: $BODOVI${NORMALNO}"

    postavi_pitanje \
        "PITANJE 5: KAKO VIDIŠ KOLIKO SLOBODNOG MJESTA IMA NA DISKU?" \
        "DF -H" "DU -H" "LS -H" "PS -H" \
        "DF = DISK FREE (SLOBODNI DISK)" && tocnih=$((tocnih+1))
    echo -e "${PLAVO}BODOVI: $BODOVI${NORMALNO}"

    if [ $tocnih -eq 5 ]; then
        dodaj_badge "🔍 DETEKTIV" "$ZELENO"
    elif [ $tocnih -ge 3 ]; then
        dodaj_badge "🔍 TRAGAČ" "$ZUTO"
    fi

    zapisnik "ZAVRŠIO/LA IGRU 4 (POTRAŽNJA) - $tocnih/5 TOČNIH"
    daj_savjet 4
}

# 5. IGRA - Pronađi svoje ime
igra_pronadi_ime() {
    clear
    RAZINA=5

    echo -e "\n${ZUTO}${DEBELO}🔎 IGRA 5: PRONAĐI SVOJE IME U SUSTAVU!${NORMALNO}"
    echo -e "${CIJANO}----------------------------------------${NORMALNO}"

    echo -e "TVOJE IME JE ${DEBELO}$PUNO_IME_VELIKO${NORMALNO}, A KORISNIČKO IME ${DEBELO}$KORISNIK_VELIKO${NORMALNO}"
    echo -e "\nSTVORIO/LA SAM SKRIVENI TRAG U /TMP DIREKTORIJU!"

    echo "$PUNO_IME_VELIKO VOLI LINUX!" > /tmp/ime_$KORISNIK.txt
    echo "$KORISNIK_VELIKO JE COOL KORISNIK!" >> /tmp/ime_$KORISNIK.txt

    postavi_pitanje \
        "PITANJE: KOJA NAREDBA TRAŽI TVOJE IME UNUTAR DATOTEKA U /TMP DIREKTORIJU?" \
        "GREP -R '$PUNO_IME_VELIKO' /TMP/" \
        "CAT -R '$PUNO_IME_VELIKO' /TMP/" \
        "FIND -R '$PUNO_IME_VELIKO' /TMP/" \
        "LS -R '$PUNO_IME_VELIKO' /TMP/" \
        "GREP = DETEKTIV KOJI TRAŽI TEKST UNUTAR DATOTEKA"

    if [ $? -eq 0 ]; then
        echo -e "\n${ZELENO}EVO ŠTO BI PRONAŠAO/LA:${NORMALNO}"
        grep -r "$PUNO_IME_VELIKO\|$KORISNIK_VELIKO" /tmp/ime_$KORISNIK.txt 2>/dev/null
        dodaj_badge "🔎 PRONALAZAČ" "$ZELENO"
    fi

    rm -f /tmp/ime_$KORISNIK.txt

    zapisnik "ZAVRŠIO/LA IGRU 5 (PRONAĐI IME)"
    daj_savjet 4
}

# ============================================
# ZAVRŠNI REZULTAT
# ============================================

zavrsi_igru() {
    echo -e "\n${LJUBICASTO}${DEBELO}========================================${NORMALNO}"
    echo -e "${LJUBICASTO}${DEBELO}    🎉 ČESTITAMO, $PUNO_IME_VELIKO! 🎉${NORMALNO}"
    echo -e "${LJUBICASTO}${DEBELO}========================================${NORMALNO}"

    echo -e "\nTVOJ UKUPNI REZULTAT: ${DEBELO}$BODOVI BODOVA${NORMALNO}"

    if [ $BODOVI -ge 200 ]; then
        echo -e "${ZELENO}🌟 MAJSTOR LINUXA! $PUNO_IME_VELIKO ZNAŠ SVE!${NORMALNO}"
        echo -e "${ZELENO}🏆 TI SI PRAVI LINUX GURU!${NORMALNO}"
        dodaj_badge "🌟 LINUX MAJSTOR" "$ZELENO"
    elif [ $BODOVI -ge 140 ]; then
        echo -e "${ZELENO}👍 VRLO DOBRO, $PUNO_IME_VELIKO! ODLIČNO NAPREDOVANJE!${NORMALNO}"
        echo -e "${ZELENO}🌱 VEĆ SI IZRASTAO U MLADO LINUX STABLO!${NORMALNO}"
        dodaj_badge "🌱 LINUX ENTUZIJAST" "$ZUTO"
    elif [ $BODOVI -ge 70 ]; then
        echo -e "${ZUTO}📖 DOBAR POČETAK, $PUNO_IME_VELIKO! VJEŽBAJ JOŠ MALO!${NORMALNO}"
        echo -e "${ZUTO}🌰 SVAKI VELIKI LINUX MAJSTOR JE POČEO KAO SJEME!${NORMALNO}"
        dodaj_badge "🌰 POČETNIK" "$CIJANO"
    else
        echo -e "${CRVENO}💪 SVAKI POČETAK JE TEŽAK, $PUNO_IME_VELIKO!${NORMALNO}"
        echo -e "${CRVENO}🌟 POKUŠAJ PONOVNO - SVI SMO MI UČILI KORAK PO KORAK!${NORMALNO}"
    fi

    prikazi_badge_ove

    echo -e "\n${DEBELO}📚 PREPORUKE ZA DALJE, $PUNO_IME_VELIKO:${NORMALNO}"
    echo "  1. IGRAJ SE U TERMINALU SVAKI DAN - TVOJ DOM JE /HOME/$KORISNIK_VELIKO"
    echo "  2. PROBAJ NAPRAVITI SVOJU PRVU BASH SKRIPTU"
    echo "  3. ISTRAŽI NAREDBE: GREP, SORT, WC, HISTORY"
    echo "  4. PITAJ ODRASLE ILI GOOGLE KAD NEŠTO NE ZNAŠ"
    echo -e "  5. ZAPAMTI: ${ZELENO}SVAKI LINUX MAJSTOR JE NEKAD BIO POČETNIK${NORMALNO}"

    certifikat

    zapisnik "ZAVRŠIO/LA IGRU S $BODOVI BODOVA I $BADGE_NIVO BADGE-OVA"
}

# ============================================
# GLAVNI IZBORNIK
# ============================================

glavni_izbornik() {
    clear
    pozdrav

    echo -e "${CIJANO}⏱ TRENUTNA TEŽINA: ${DEBELO}$TEZINA${NORMALNO}${CIJANO} (${VRIJEME_ODGOVORA}S PO PITANJU)${NORMALNO}"
    echo ""
    echo "ŠTO ŽELIŠ RADITI?"
    echo "  1) 🏠 NAUČI O LINUX STRUKTURI (DRVO)"
    echo "  2) 📚 PREGLED SVIH NAREDBI (PRIRUČNIK)"
    echo "  3) 🗺️ IGRA NAVIGACIJE (CD, LS, PWD, MKDIR)"
    echo "  4) 📄 IGRA S DATOTEKAMA (CAT, CP, MV, RM)"
    echo "  5) 🔐 IGRA O DOZVOLAMA I SIGURNOSTI"
    echo "  6) 🔍 IGRA TRAŽENJA I POMOĆI"
    echo "  7) 🎯 PRONAĐI SVOJE IME U SUSTAVU"
    echo "  8) 🏅 POGLEDAJ SVOJE BADGE-OVE"
    echo "  9) 🚀 SVE IGRE - KOMPLETNA AVANTURA"
    echo " 10) ℹ️ PROVJERA OS-A I UPDATE UPUTE"
    echo " 11) 📖 POGLEDAJ DNEVNIK NAPRETKA"
    echo " 12) ❌ IZAĐI IZ IGRE"
    echo " 13) ⏱ PROMIJENI TEŽINU"
    echo ""
    echo -n "TVOJ IZBOR (1-13): "
    read izbor

    case $izbor in
        1) nacrtaj_drvo ;;
        2) prikazi_naredbe ;;
        3) igra_navigacija ;;
        4) igra_datoteke ;;
        5) igra_permisije ;;
        6) igra_potraznja ;;
        7) igra_pronadi_ime ;;
        8) prikazi_badge_ove ;;
        9)
            clear
            echo -e "${ZELENO}${DEBELO}🚀 POKREĆEM KOMPLETNU AVANTURU!${NORMALNO}"
            echo -e "${ZUTO}PRVO ĆEMO NAUČITI STRUKTURU, PA NAREDBE, PA IGRE!${NORMALNO}"
            echo -e "\n${ZUTO}PRITISNI ENTER ZA POČETAK...${NORMALNO}"
            read

            nacrtaj_drvo
            echo -e "\n${ZUTO}PRITISNI ENTER ZA NASTAVAK NA PRIRUČNIK...${NORMALNO}"
            read

            prikazi_naredbe
            echo -e "\n${ZUTO}PRITISNI ENTER ZA POČETAK IGARA...${NORMALNO}"
            read

            igra_navigacija
            echo -e "\n${ZUTO}PRITISNI ENTER ZA SLJEDEĆU IGRU...${NORMALNO}"
            read

            igra_datoteke
            echo -e "\n${ZUTO}PRITISNI ENTER ZA SLJEDEĆU IGRU...${NORMALNO}"
            read

            igra_permisije
            echo -e "\n${ZUTO}PRITISNI ENTER ZA SLJEDEĆU IGRU...${NORMALNO}"
            read

            igra_potraznja
            echo -e "\n${ZUTO}PRITISNI ENTER ZA SLJEDEĆU IGRU...${NORMALNO}"
            read

            igra_pronadi_ime
            echo -e "\n${ZUTO}PRITISNI ENTER ZA REZULTATE...${NORMALNO}"
            read

            zavrsi_igru
            ;;
        10) provjeri_os ;;
        11)
            if [ -f "$DNEVNIK" ]; then
                echo -e "\n${PLAVO}${DEBELO}📖 DNEVNIK NAPRETKA:${NORMALNO}"
                echo -e "${CIJANO}----------------------------------------${NORMALNO}"
                cat "$DNEVNIK"
                echo -e "${CIJANO}----------------------------------------${NORMALNO}"
                echo -e "${ZELENO}📁 DNEVNIK SE NALAZI U: $DNEVNIK${NORMALNO}"
            else
                echo -e "${ZUTO}JOŠ NEMAŠ UNOSA U DNEVNIKU. IGRAJ IGRE DA GA NAPUNIŠ!${NORMALNO}"
                echo -e "${ZUTO}💡 DNEVNIK ĆE BITI KREIRAN U: $DNEVNIK${NORMALNO}"
            fi
            ;;
        12)
            echo -e "${ZELENO}DOVIĐENJA, $PUNO_IME_VELIKO! NASTAVI ISTRAŽIVATI LINUX! 🐧${NORMALNO}"
            zapisnik "ZAVRŠIO/LA IGRU"
            exit 0
            ;;
        13) odaberi_tezinu ;;
        *) echo -e "${CRVENO}NEPOZNAT IZBOR! POKUŠAJ PONOVNO.${NORMALNO}" ;;
    esac

    echo -e "\n${ZUTO}PRITISNI ENTER ZA POVRATAK NA IZBORNIK...${NORMALNO}"
    read
    glavni_izbornik
}

# ============================================
# POKRENI IGRU
# ============================================

if ! command -v ls &> /dev/null; then
    echo -e "${CRVENO}GREŠKA: LS NIJE PRONAĐEN! NISI U LINUX TERMINALU?${NORMALNO}"
    exit 1
fi

clear
provjeri_os
echo -e "\n${ZUTO}PRITISNI ENTER ZA POČETAK AVANTURE...${NORMALNO}"
read
odaberi_tezinu
echo -e "\n${ZUTO}PRITISNI ENTER ZA NASTAVAK...${NORMALNO}"
read
glavni_izbornik
