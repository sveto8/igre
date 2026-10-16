#!/usr/bin/env python3
import sys
import subprocess
import os

# --- Provjera i instalacija potrebnih biblioteka ---
def instaliraj_biblioteke():
    """Automatski instalira potrebne biblioteke ako nedostaju"""
    try:
        import curses
        # Provjeri radi li curses na Windowsu
        try:
            import curses
            curses.setupterm()
            return True
        except:
            # Ako curses ne radi, pokušaj instalirati windows-curses
            try:
                import curses
                return True
            except:
                pass
    except ImportError:
        pass
    
    # Pokušaj instalirati windows-curses
    print("📦 Instaliram potrebne biblioteke...")
    try:
        subprocess.check_call([sys.executable, "-m", "pip", "install", "windows-curses"])
        print("✅ Biblioteke uspješno instalirane!")
        return True
    except:
        print("❌ Greška pri instalaciji. Pokušaj pokrenuti: pip install windows-curses")
        return False

# Instaliraj biblioteke ako je potrebno
if not instaliraj_biblioteke():
    sys.exit(1)

# Sada uvezi sve ostalo
import curses
import random
import time
from datetime import datetime

# --- Postavke igre ---
ZIVOTI           = 3

# --- Težine igre ---
TEZINE = {
    "1": {"naziv": "Lagano", "cilj": 100},
    "2": {"naziv": "Srednje", "cilj": 200},
    "3": {"naziv": "Teško", "cilj": 300},
    "4": {"naziv": "Custom", "cilj": 0},  # 0 znači da će korisnik unijeti
}

# --- Brzine igre (sekunde između svakog "pada") ---
BRZINE = {
    "1": {"naziv": "Sporo", "vrijednost": 0.7},
    "2": {"naziv": "Srednje", "vrijednost": 0.4},
    "3": {"naziv": "Brzo", "vrijednost": 0.2},
}

NOVI_ASTEROID_SVK = 5.0  # novi asteroid svake N sekundi
MAX_ASTEROIDA    = 3

# --- Funkcije za generiranje zadataka ---
def _zbroj(max_br):
    def gen():
        a = random.randint(1, max_br - 1)
        max_b = max_br - a
        if max_b < 1:
            max_b = 1
        b = random.randint(1, max_b)
        return f"{a}+{b}", a + b
    return gen

def _oduzimanje(max_br):
    def gen():
        a = random.randint(1, max_br)
        b = random.randint(1, a)
        return f"{a}-{b}", a - b
    return gen

def _zbroj_oduz(max_br):
    def gen():
        a = random.randint(1, max_br)
        op = random.choice(['+', '-'])
        if op == '+':
            max_b = max_br - a
            if max_b < 1:
                max_b = 1
            b = random.randint(1, max_b)
            return f"{a}+{b}", a + b
        else:
            b = random.randint(1, a)
            return f"{a}-{b}", a - b
    return gen

def _mnozenje(lo, hi):
    def gen():
        a = random.randint(lo, hi)
        b = random.randint(lo, hi)
        return f"{a}x{b}", a * b
    return gen

def _dijeljenje(lo, hi):
    def gen():
        b = random.randint(lo, hi)
        a = b * random.randint(lo, hi)
        return f"{a}:{b}", a // b
    return gen

# --- Načini igre ---
def kreiraj_nacine(max_broj):
    """Kreiraj načine igre s prilagođenim maksimalnim brojem"""
    max_tablica = min(10, max_broj)
    
    return {
        "1": {
            "naziv": f"Zbrajanje do {max_broj}",
            "opis":  f"npr. 3+4, 1+8 (do {max_broj})",
            "fn": _zbroj(max_broj),
        },
        "2": {
            "naziv": f"Oduzimanje do {max_broj}",
            "opis":  f"npr. 15-7, 20-5 (do {max_broj})",
            "fn": _oduzimanje(max_broj),
        },
        "3": {
            "naziv": f"Zbrajanje i oduzimanje do {max_broj}",
            "opis":  f"npr. 15-7, 9+6 (do {max_broj})",
            "fn": _zbroj_oduz(max_broj),
        },
        "4": {
            "naziv": f"Množenje (tablice 1-{max_tablica})",
            "opis":  f"npr. 3x7, 8x4 (do {max_tablica})",
            "fn": _mnozenje(1, max_tablica),
        },
        "5": {
            "naziv": f"Dijeljenje (tablice 1-{max_tablica})",
            "opis":  f"npr. 24:6, 35:5 (do {max_tablica})",
            "fn": _dijeljenje(1, max_tablica),
        },
        "6": {
            "naziv": "Sve zajedno",
            "opis":  f"mix svega (do {max_broj})",
            "fn": lambda: random.choice([
                _zbroj(max_broj)(),
                _oduzimanje(max_broj)(),
                _zbroj_oduz(max_broj)(),
                _mnozenje(1, max_tablica)(),
                _dijeljenje(1, max_tablica)(),
            ]),
        },
    }


# ──────────────────────────────────────────────
class Asteroid:
    def __init__(self, cols, gen_fn):
        self.zadatak, self.odgovor = gen_fn()
        prikaz_len = len(self.zadatak) + 4
        self.col = random.randint(2, max(3, cols - prikaz_len - 3))
        self.row = 2
        self.eksplodira = False
        self.eksplozija_timer = 0


# ──────────────────────────────────────────────
def izbornik():
    """Tekstualni izbornik prije curses petlje."""
    print("\n" + "═" * 50)
    ime = input("  Upiši svoje ime: ").strip()
    if not ime:
        ime = "Astronaut"
    
    print("\n" + "═" * 50)
    print(f"  🚀  DOBRODOŠAO, {ime.upper()}!  🚀")
    print("═" * 50)
    
    print("\nOdaberi težinu (ciljni broj bodova):\n")
    for k, v in TEZINE.items():
        if v["cilj"] > 0:
            print(f"  [{k}]  {v['naziv']} - {v['cilj']} bodova")
        else:
            print(f"  [{k}]  {v['naziv']} - unesi sam")
    print()

    while True:
        tezina_odabir = input("Tvoj odabir (1-4): ").strip()
        if tezina_odabir in TEZINE:
            break
        print("    Upiši broj između 1 i 4.")
    
    if tezina_odabir == "4":
        print("\nUnesi željeni broj bodova za pobjedu:")
        while True:
            try:
                CILJ_BODOVA = int(input("  Broj bodova: ").strip())
                if CILJ_BODOVA >= 10:
                    break
                else:
                    print("  Broj mora biti najmanje 10.")
            except ValueError:
                print("  Molim unesi ispravan broj.")
        tezina_naziv = f"Custom ({CILJ_BODOVA})"
    else:
        CILJ_BODOVA = TEZINE[tezina_odabir]["cilj"]
        tezina_naziv = TEZINE[tezina_odabir]["naziv"]
    
    print("\nDo kojeg broja želiš igrati?")
    print("  (preporuka: 10, 20, 50, 100, 200)")
    
    while True:
        try:
            max_broj = int(input("  Unesi broj: ").strip())
            if max_broj >= 2:
                break
            else:
                print("  Broj mora biti veći od 1.")
        except ValueError:
            print("  Molim unesi ispravan broj.")
    
    NACINI = kreiraj_nacine(max_broj)
    
    print("\n" + "═" * 50)
    print("Odaberi vrstu zadataka:\n")
    for k, v in NACINI.items():
        print(f"  [{k}]  {v['naziv']}")
        print(f"        {v['opis']}")
    print()

    while True:
        odabir = input("Tvoj odabir (1-6): ").strip()
        if odabir in NACINI:
            break
        print("    Upiši broj između 1 i 6.")

    print()
    print("─" * 50)
    print(f"  Odabrano: {NACINI[odabir]['naziv']}")
    print(f"  Težina:   {tezina_naziv}")
    print(f"  Cilj:     {CILJ_BODOVA} bodova")
    print(f"  Maks. broj: {max_broj}")
    print(f"  Životi:   {ZIVOTI}")
    
    print("\nOdaberi brzinu igre:\n")
    for k, v in BRZINE.items():
        print(f"  [{k}]  {v['naziv']}")
    print()

    while True:
        brzina_odabir = input("Tvoj odabir (1-3): ").strip()
        if brzina_odabir in BRZINE:
            break
        print("    Upiši broj između 1 i 3.")
    
    print("─" * 50)
    print(f"  Brzina: {BRZINE[brzina_odabir]['naziv']}")
    print("\nUpute:")
    print("  • Utipkaj odgovor i pritisni ENTER")
    print("  • BACKSPACE briše zadnji broj")
    print("  • ESC = izlaz iz igre")
    print()
    input("Pritisni ENTER za početak...")

    return NACINI[odabir]["fn"], BRZINE[brzina_odabir]['vrijednost'], ime, max_broj, CILJ_BODOVA, tezina_naziv


# ──────────────────────────────────────────────
def kreiraj_direktorij_za_rezultate():
    """Kreiraj direktorijsku strukturu za rezultate"""
    glavni_dir = "rezultati"
    if not os.path.exists(glavni_dir):
        os.makedirs(glavni_dir)
    
    datum_str = datetime.now().strftime('%Y-%m-%d')
    datum_dir = os.path.join(glavni_dir, datum_str)
    if not os.path.exists(datum_dir):
        os.makedirs(datum_dir)
    
    return datum_dir


def spremi_rezultate(ime_igraca, max_broj, cilj_bodova, tezina, bodovi, tocnih_odgovora, 
                     krivi_odgovori, pobijeno, zivoti, start_vrijeme, ishod, dodatni_tekst=""):
    """Spremi rezultate u TXT datoteku unutar direktorijske strukture"""
    datum_dir = kreiraj_direktorij_za_rezultate()
    
    sada = datetime.now()
    sati = sada.strftime('%H')
    minute = sada.strftime('%M')
    vrijeme_str = f"{sati}h{minute}m"
    
    ime_datoteke = f"rezultati_{ime_igraca}_{vrijeme_str}"
    
    if ishod == "PREKINUTO":
        ime_datoteke += "-PREKINUTO"
    
    ime_datoteke += ".txt"
    putanja = os.path.join(datum_dir, ime_datoteke)
    
    brojac = 1
    while os.path.exists(putanja):
        if ishod == "PREKINUTO":
            ime_datoteke = f"rezultati_{ime_igraca}_{vrijeme_str}-PREKINUTO_{brojac}.txt"
        else:
            ime_datoteke = f"rezultati_{ime_igraca}_{vrijeme_str}_{brojac}.txt"
        putanja = os.path.join(datum_dir, ime_datoteke)
        brojac += 1
    
    kraj_vrijeme = time.time()
    trajanje = kraj_vrijeme - start_vrijeme
    minute_trajanje = int(trajanje // 60)
    sekunde_trajanje = int(trajanje % 60)
    
    try:
        with open(putanja, 'w', encoding='utf-8') as f:
            f.write("=" * 50 + "\n")
            f.write("  REZULTATI IGRE\n")
            f.write("=" * 50 + "\n")
            f.write(f"Igrač:        {ime_igraca}\n")
            f.write(f"Težina:       {tezina}\n")
            f.write(f"Cilj:         {cilj_bodova} bodova\n")
            f.write(f"Maks. broj:   {max_broj}\n")
            f.write(f"Datum:        {datetime.now().strftime('%d.%m.%Y. %H:%M:%S')}\n")
            f.write(f"Is hod:       {ishod}\n")
            if dodatni_tekst:
                f.write(f"Napomena:     {dodatni_tekst}\n")
            f.write("-" * 50 + "\n")
            f.write(f"Bodovi:       {bodovi}\n")
            f.write(f"Točnih odgovora: {tocnih_odgovora}\n")
            f.write(f"Netočnih odgovora: {krivi_odgovori}\n")
            f.write(f"Uništenih asteroida: {pobijeno}\n")
            f.write(f"Preostalih života: {max(0, zivoti)}\n")
            f.write(f"Vrijeme trajanja: {minute_trajanje}m {sekunde_trajanje}s\n")
            f.write("=" * 50 + "\n")
        return putanja
    except Exception as e:
        print(f"Greška pri spremanju rezultata: {e}")
        return None


# ──────────────────────────────────────────────
def igraj(stdscr, gen_fn, brzina_pada, ime_igraca, max_broj, cilj_bodova, tezina):
    curses.curs_set(1)
    curses.start_color()
    curses.use_default_colors()

    # Postavi boje (prilagođeno za Windows)
    if os.name == 'nt':  # Windows
        curses.init_pair(1, curses.COLOR_RED,     curses.COLOR_BLACK)
        curses.init_pair(2, curses.COLOR_YELLOW,  curses.COLOR_BLACK)
        curses.init_pair(3, curses.COLOR_GREEN,   curses.COLOR_BLACK)
        curses.init_pair(4, curses.COLOR_CYAN,    curses.COLOR_BLACK)
        curses.init_pair(5, curses.COLOR_WHITE,   curses.COLOR_BLACK)
        curses.init_pair(6, curses.COLOR_MAGENTA, curses.COLOR_BLACK)
        curses.init_pair(7, curses.COLOR_RED,     curses.COLOR_BLACK)
    else:
        curses.init_pair(1, curses.COLOR_RED,     -1)
        curses.init_pair(2, curses.COLOR_YELLOW,  -1)
        curses.init_pair(3, curses.COLOR_GREEN,   -1)
        curses.init_pair(4, curses.COLOR_CYAN,    -1)
        curses.init_pair(5, curses.COLOR_WHITE,   -1)
        curses.init_pair(6, curses.COLOR_MAGENTA, -1)
        curses.init_pair(7, curses.COLOR_RED,     -1)

    stdscr.nodelay(True)
    stdscr.timeout(50)

    visina, sirina = stdscr.getmaxyx()
    zemlja_red = visina - 3

    asteroidi      = []
    unos           = ""
    bodovi         = 0
    zivoti         = ZIVOTI
    poruka         = ""
    poruka_boja    = 3
    poruka_timer   = 0
    zadnji_asteroid = time.time()
    zadnji_pad      = time.time()
    pobijeno        = 0
    krivi_odgovori  = 0
    tocnih_odgovora = 0
    start_vrijeme   = time.time()
    prekinuto       = False

    def prikazi_kraj(naslov, boja, pobjeda):
        stdscr.clear()
        cy = visina // 2
        cx = sirina // 2
        stdscr.addstr(cy - 6, cx - 15, "─" * 30, curses.color_pair(4))
        stdscr.addstr(cy - 5, cx - 15, f"  {naslov}", curses.color_pair(boja) | curses.A_BOLD)
        stdscr.addstr(cy - 3, cx - 15, f"  Igrač:      {ime_igraca}", curses.color_pair(5))
        stdscr.addstr(cy - 2, cx - 15, f"  Težina:     {tezina}", curses.color_pair(5))
        stdscr.addstr(cy - 1, cx - 15, f"  Cilj:       {cilj_bodova} bodova", curses.color_pair(5))
        stdscr.addstr(cy,     cx - 15, f"  Bodovi:     {bodovi}", curses.color_pair(4) | curses.A_BOLD)
        stdscr.addstr(cy + 1, cx - 15, f"  Točnih:     {tocnih_odgovora}", curses.color_pair(3))
        stdscr.addstr(cy + 2, cx - 15, f"  Netočnih:   {krivi_odgovori}", curses.color_pair(1))
        stdscr.addstr(cy + 3, cx - 15, f"  Uništeno:   {pobijeno} asteroida", curses.color_pair(5))
        stdscr.addstr(cy + 4, cx - 15, f"  Preostalo života: {max(0, zivoti)}", curses.color_pair(5))
        stdscr.addstr(cy + 6, cx - 15, "  Pritisni ENTER za izlaz", curses.color_pair(5))
        stdscr.addstr(cy + 7, cx - 15, "─" * 30, curses.color_pair(4))
        stdscr.refresh()
        stdscr.nodelay(False)
        while True:
            k = stdscr.getch()
            if k in (curses.KEY_ENTER, 10, 13, 27):
                return

    while True:
        sada = time.time()

        try:
            tipka = stdscr.getch()
        except:
            tipka = -1

        if tipka == 27:
            prekinuto = True
            break
        elif tipka in (curses.KEY_BACKSPACE, 127, 8):
            unos = unos[:-1]
        elif tipka in (curses.KEY_ENTER, 10, 13):
            try:
                broj = int(unos)
                pogodak = False
                for ast in asteroidi[:]:
                    if ast.odgovor == broj and not ast.eksplodira:
                        ast.eksplodira = True
                        ast.eksplozija_timer = sada
                        bodovi += 10
                        pobijeno += 1
                        tocnih_odgovora += 1
                        poruka = f"  BOOM! +10  "
                        poruka_boja = 3
                        poruka_timer = sada
                        pogodak = True
                        break
                if not pogodak:
                    krivi_odgovori += 1
                    poruka = f"  Krivi odgovor!  "
                    poruka_boja = 7
                    poruka_timer = sada
            except ValueError:
                poruka = "  Upiši broj!  "
                poruka_boja = 7
                poruka_timer = sada
            unos = ""
        elif 48 <= tipka <= 57:
            unos += chr(tipka)
        elif tipka == ord('-') and not unos:
            unos = "-"

        if sada - zadnji_asteroid > NOVI_ASTEROID_SVK and len(asteroidi) < MAX_ASTEROIDA:
            asteroidi.append(Asteroid(sirina, gen_fn))
            zadnji_asteroid = sada

        if sada - zadnji_pad > brzina_pada:
            for ast in asteroidi[:]:
                if not ast.eksplodira:
                    ast.row += 1
                    if ast.row >= zemlja_red:
                        asteroidi.remove(ast)
                        zivoti -= 1
                        poruka = "  Asteroid udario Zemlju!  "
                        poruka_boja = 7
                        poruka_timer = sada
            zadnji_pad = sada

        for ast in asteroidi[:]:
            if ast.eksplodira and sada - ast.eksplozija_timer > 0.5:
                asteroidi.remove(ast)

        if zivoti <= 0:
            putanja = spremi_rezultate(ime_igraca, max_broj, cilj_bodova, tezina, bodovi, 
                                     tocnih_odgovora, krivi_odgovori, pobijeno, zivoti, 
                                     start_vrijeme, "GAME OVER", "Asteroidi su uništili Zemlju!")
            prikazi_kraj("★  GAME OVER  ★", 1, False)
            return bodovi

        if bodovi >= cilj_bodova:
            putanja = spremi_rezultate(ime_igraca, max_broj, cilj_bodova, tezina, bodovi, 
                                     tocnih_odgovora, krivi_odgovori, pobijeno, zivoti, 
                                     start_vrijeme, "POBJEDA", "Čestitamo! Spašena je Zemlja!")
            prikazi_kraj("🏆  POBJEDA!  🏆", 3, True)
            return bodovi

        stdscr.erase()
        try:
            stdscr.border()
        except:
            pass

        srce = "❤ " * zivoti
        napredak = f"{bodovi}/{cilj_bodova}"
        header = f"  {ime_igraca.upper()}  |  Bodovi: {napredak}  |  {srce}"
        try:
            stdscr.addstr(0, 2, header[:sirina - 4], curses.color_pair(4) | curses.A_BOLD)
        except:
            pass

        sirina_trake = sirina - 4
        popunjeno = int(sirina_trake * bodovi / cilj_bodova)
        traka = "█" * popunjeno + "░" * (sirina_trake - popunjeno)
        try:
            stdscr.addstr(1, 2, traka[:sirina - 4], curses.color_pair(3))
        except:
            pass

        try:
            max_info = f"MAX:{max_broj}  {tezina}"
            stdscr.addstr(1, sirina - len(max_info) - 3, max_info, curses.color_pair(4))
        except:
            pass

        try:
            stdscr.addstr(zemlja_red, 1, "═" * (sirina - 2), curses.color_pair(6) | curses.A_BOLD)
            stdscr.addstr(zemlja_red + 1, sirina // 2 - 5, "[ ZEMLJA ]", curses.color_pair(6) | curses.A_BOLD)
        except:
            pass

        for ast in asteroidi:
            try:
                if ast.eksplodira:
                    stdscr.addstr(ast.row, ast.col, " * BOOM * ", curses.color_pair(2) | curses.A_BOLD)
                else:
                    prikaz = f"[{ast.zadatak}=?]"
                    boja = curses.color_pair(1) | (curses.A_BOLD if ast.row > zemlja_red - 6 else 0)
                    stdscr.addstr(ast.row, ast.col, prikaz, boja)
                    if ast.row > 2:
                        stdscr.addstr(ast.row - 1, ast.col + len(prikaz) // 2, "☆", curses.color_pair(5))
            except:
                pass

        if poruka and sada - poruka_timer < 1.5:
            try:
                stdscr.addstr(zemlja_red - 2,
                              sirina // 2 - len(poruka) // 2,
                              poruka,
                              curses.color_pair(poruka_boja) | curses.A_BOLD)
            except:
                pass

        try:
            stdscr.addstr(visina - 2, 2,
                          f" Odgovor: {unos}█",
                          curses.color_pair(5) | curses.A_BOLD)
            stdscr.addstr(visina - 2, sirina - 20,
                          " ESC = izlaz ",
                          curses.color_pair(4))
            
            stdscr.addstr(visina - 4, sirina - 25,
                          f"T:{tocnih_odgovora} K:{krivi_odgovori}",
                          curses.color_pair(5))
        except:
            pass

        stdscr.refresh()

    if prekinuto:
        putanja = spremi_rezultate(ime_igraca, max_broj, cilj_bodova, tezina, bodovi, 
                                 tocnih_odgovora, krivi_odgovori, pobijeno, zivoti, 
                                 start_vrijeme, "PREKINUTO", "Igra je prekinuta prije kraja (ESC)")
        
        stdscr.clear()
        cy = visina // 2
        cx = sirina // 2
        stdscr.addstr(cy - 6, cx - 15, "─" * 30, curses.color_pair(4))
        stdscr.addstr(cy - 5, cx - 15, "  ⏸  IGRA PREKINUTA  ", curses.color_pair(1) | curses.A_BOLD)
        stdscr.addstr(cy - 3, cx - 15, f"  Igrač:      {ime_igraca}", curses.color_pair(5))
        stdscr.addstr(cy - 2, cx - 15, f"  Težina:     {tezina}", curses.color_pair(5))
        stdscr.addstr(cy - 1, cx - 15, f"  Cilj:       {cilj_bodova} bodova", curses.color_pair(5))
        stdscr.addstr(cy,     cx - 15, f"  Bodovi:     {bodovi}", curses.color_pair(4) | curses.A_BOLD)
        stdscr.addstr(cy + 1, cx - 15, f"  Točnih:     {tocnih_odgovora}", curses.color_pair(3))
        stdscr.addstr(cy + 2, cx - 15, f"  Netočnih:   {krivi_odgovori}", curses.color_pair(1))
        stdscr.addstr(cy + 3, cx - 15, f"  Uništeno:   {pobijeno} asteroida", curses.color_pair(5))
        if putanja:
            ime_datoteke = os.path.basename(putanja)
            stdscr.addstr(cy + 5, cx - 20, f"  Rezultati spremljeni kao:", curses.color_pair(4))
            stdscr.addstr(cy + 6, cx - 20, f"  {ime_datoteke}", curses.color_pair(4))
        stdscr.addstr(cy + 8, cx - 15, "  Pritisni ENTER za izlaz", curses.color_pair(5))
        stdscr.addstr(cy + 9, cx - 15, "─" * 30, curses.color_pair(4))
        stdscr.refresh()
        stdscr.nodelay(False)
        while True:
            k = stdscr.getch()
            if k in (curses.KEY_ENTER, 10, 13, 27):
                break

    return bodovi


# ──────────────────────────────────────────────
def main():
    gen_fn, brzina_pada, ime_igraca, max_broj, cilj_bodova, tezina = izbornik()
    bodovi = curses.wrapper(igraj, gen_fn, brzina_pada, ime_igraca, max_broj, cilj_bodova, tezina)
    print(f"\n🏆 Završni rezultat: {bodovi} bodova!")
    print("Bravo! Do idućeg puta! 👋\n")

if __name__ == "__main__":
    main()