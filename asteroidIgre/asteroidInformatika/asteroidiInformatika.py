#!/usr/bin/env python3
import sys
import subprocess
import os

# --- Provjera i instalacija potrebnih biblioteka ---
def instaliraj_biblioteke():
    """Automatski instalira potrebne biblioteke ako nedostaju"""
    try:
        import curses
        try:
            import curses
            curses.setupterm()
            return True
        except:
            try:
                import curses
                return True
            except:
                pass
    except ImportError:
        pass
    
    print("📦 Instaliram potrebne biblioteke...")
    try:
        subprocess.check_call([sys.executable, "-m", "pip", "install", "windows-curses"])
        print("✅ Biblioteke uspješno instalirane!")
        return True
    except:
        print("❌ Greška pri instalaciji. Pokušaj pokrenuti: pip install windows-curses")
        return False

if not instaliraj_biblioteke():
    sys.exit(1)

import curses
import random
import time
from datetime import datetime

# --- Pitanja iz informatike za 1. razred ---
PITANJA = [
    {
        "pitanje": "Što je računalo?",
        "odgovori": {
            "A": "Igračka",
            "B": "Vozilo",
            "C": "Uređaj za rad i učenje",
            "D": "Kućni ljubimac"
        },
        "tocan": "C"
    },
    {
        "pitanje": "Koji dio računala prikazuje sliku?",
        "odgovori": {
            "A": "Miš",
            "B": "Monitor",
            "C": "Tipkovnica",
            "D": "Zvučnik"
        },
        "tocan": "B"
    },
    {
        "pitanje": "Čime pomičemo pokazivač na ekranu?",
        "odgovori": {
            "A": "Monitorom",
            "B": "Pisačem",
            "C": "Mišem",
            "D": "Kamerom"
        },
        "tocan": "C"
    },
    {
        "pitanje": "Na čemu tipkamo slova i brojeve?",
        "odgovori": {
            "A": "Mišu",
            "B": "Monitoru",
            "C": "Tipkovnici",
            "D": "Zvučniku"
        },
        "tocan": "C"
    },
    {
        "pitanje": "Koji uređaj ispisuje tekst na papir?",
        "odgovori": {
            "A": "Pisač",
            "B": "Monitor",
            "C": "Miš",
            "D": "Kamera"
        },
        "tocan": "A"
    },
    {
        "pitanje": "Što koristimo za slušanje zvuka?",
        "odgovori": {
            "A": "Tipkovnicu",
            "B": "Zvučnike",
            "C": "Pisač",
            "D": "Miš"
        },
        "tocan": "B"
    },
    {
        "pitanje": "Kako se zove uređaj kojim fotografiramo?",
        "odgovori": {
            "A": "Kamera",
            "B": "Monitor",
            "C": "Miš",
            "D": "Tipkovnica"
        },
        "tocan": "A"
    },
    {
        "pitanje": "Što trebamo učiniti nakon rada na računalu?",
        "odgovori": {
            "A": "Ostaviti ga uključeno",
            "B": "Baciti ga",
            "C": "Pravilno ga ugasiti",
            "D": "Isključiti monitor i otići"
        },
        "tocan": "C"
    },
    {
        "pitanje": "Koja tipka služi za razmak između riječi?",
        "odgovori": {
            "A": "Enter",
            "B": "Shift",
            "C": "Razmaknica (Space)",
            "D": "Esc"
        },
        "tocan": "C"
    },
    {
        "pitanje": "Koja tipka briše slovo lijevo od pokazivača?",
        "odgovori": {
            "A": "Enter",
            "B": "Backspace",
            "C": "Shift",
            "D": "Tab"
        },
        "tocan": "B"
    },
    {
        "pitanje": "Što je internet?",
        "odgovori": {
            "A": "Vrsta računala",
            "B": "Mreža koja povezuje računala",
            "C": "Igra",
            "D": "Tipkovnica"
        },
        "tocan": "B"
    },
    {
        "pitanje": "Gdje možemo pronaći informacije na internetu?",
        "odgovori": {
            "A": "U pregledniku",
            "B": "U pisaču",
            "C": "U zvučniku",
            "D": "Na mišu"
        },
        "tocan": "A"
    },
    {
        "pitanje": "Što je ikona na računalu?",
        "odgovori": {
            "A": "Mala sličica programa ili datoteke",
            "B": "Tipka na tipkovnici",
            "C": "Miš",
            "D": "Zvučnik"
        },
        "tocan": "A"
    },
    {
        "pitanje": "Koja je osnovna boja ekrana kada je računalo ugašeno?",
        "odgovori": {
            "A": "Zelena",
            "B": "Plava",
            "C": "Crna",
            "D": "Crvena"
        },
        "tocan": "C"
    },
    {
        "pitanje": "Što ne smijemo dijeliti s nepoznatim osobama na internetu?",
        "odgovori": {
            "A": "Tajne i osobne podatke",
            "B": "Crteže",
            "C": "Boje",
            "D": "Brojeve zadataka"
        },
        "tocan": "A"
    },
    {
        "pitanje": "Kako se zove uređaj koji snima naš glas?",
        "odgovori": {
            "A": "Mikrofon",
            "B": "Monitor",
            "C": "Miš",
            "D": "Pisač"
        },
        "tocan": "A"
    },
    {
        "pitanje": "Što znači dvostruki klik mišem?",
        "odgovori": {
            "A": "Dvaput brzo pritisnuti tipku miša",
            "B": "Ugasiti računalo",
            "C": "Pomaknuti miš",
            "D": "Pritisnuti tipkovnicu"
        },
        "tocan": "A"
    },
    {
        "pitanje": "Koji uređaj koristimo za gledanje videa?",
        "odgovori": {
            "A": "Monitor",
            "B": "Miš",
            "C": "Pisač",
            "D": "Mikrofon"
        },
        "tocan": "A"
    },
    {
        "pitanje": "Čemu služi mapa (folder)?",
        "odgovori": {
            "A": "Za spremanje i organiziranje datoteka",
            "B": "Za slušanje glazbe",
            "C": "Za fotografiranje",
            "D": "Za ispisivanje"
        },
        "tocan": "A"
    },
    {
        "pitanje": "Što je program na računalu?",
        "odgovori": {
            "A": "Skup uputa koje računalo izvršava",
            "B": "Vrsta miša",
            "C": "Monitor",
            "D": "Kabel"
        },
        "tocan": "A"
    },
    {
        "pitanje": "Koji uređaj omogućuje unos teksta u računalo?",
        "odgovori": {
            "A": "Tipkovnica",
            "B": "Monitor",
            "C": "Pisač",
            "D": "Zvučnik"
        },
        "tocan": "A"
    },
    {
        "pitanje": "Što znači spremiti datoteku?",
        "odgovori": {
            "A": "Obrisati je",
            "B": "Sačuvati je za kasnije korištenje",
            "C": "Ispisati je",
            "D": "Poslati je poštom"
        },
        "tocan": "B"
    },
    {
        "pitanje": "Koji je siguran način korištenja interneta?",
        "odgovori": {
            "A": "Dijeliti lozinke svima",
            "B": "Otvarati sve poruke",
            "C": "Pitati odraslu osobu za pomoć",
            "D": "Davati adresu nepoznatima"
        },
        "tocan": "C"
    },
    {
        "pitanje": "Što je lozinka?",
        "odgovori": {
            "A": "Tajna riječ za zaštitu računa",
            "B": "Naziv računala",
            "C": "Vrsta monitora",
            "D": "Tipka na mišu"
        },
        "tocan": "A"
    },
    {
        "pitanje": "Koji uređaj služi za unos zvuka u računalo?",
        "odgovori": {
            "A": "Mikrofon",
            "B": "Zvučnik",
            "C": "Monitor",
            "D": "Pisač"
        },
        "tocan": "A"
    }
]

# --- Funkcije za ocjenjivanje ---
def dobij_ocjenu(tocni, ukupno, tezina):
    postotak = (tocni / ukupno) * 100 if ukupno > 0 else 0
    
    if tezina == "Lagano":
        if postotak >= 90:
            return "🌟 BRAVO! Izvrsno!", 3
        elif postotak >= 80:
            return "👍 VRLO DOBRO!", 2
        elif postotak >= 60:
            return "📚 DOBRO! Možeš bolje!", 4
        else:
            return "📖 VJEŽBAJ JOŠ!", 1
    elif tezina == "Srednje":
        if postotak >= 90:
            return "🌟 BRAVO! Izvrsno!", 3
        elif postotak >= 75:
            return "👍 VRLO DOBRO!", 2
        elif postotak >= 55:
            return "📚 DOBRO! Možeš bolje!", 4
        else:
            return "📖 VJEŽBAJ JOŠ!", 1
    else:
        if postotak >= 85:
            return "🌟 BRAVO! Izvrsno!", 3
        elif postotak >= 70:
            return "👍 VRLO DOBRO!", 2
        elif postotak >= 50:
            return "📚 DOBRO! Možeš bolje!", 4
        else:
            return "📖 VJEŽBAJ JOŠ!", 1

# --- Funkcije za spremanje rezultata ---
def _sigurno_ime(ime):
    """Ime igrača za naziv datoteke: zamijeni znakove koji nisu dozvoljeni (npr. / \\ :)"""
    sigurno = "".join(c if (c.isalnum() or c in "-_ ") else "_" for c in ime).strip()
    return sigurno or "igrac"

def kreiraj_direktorij_za_rezultate():
    glavni_dir = "rezultati"
    if not os.path.exists(glavni_dir):
        os.makedirs(glavni_dir)
    
    datum_str = datetime.now().strftime('%Y-%m-%d')
    datum_dir = os.path.join(glavni_dir, datum_str)
    if not os.path.exists(datum_dir):
        os.makedirs(datum_dir)
    
    return datum_dir

def spremi_rezultate(ime_igraca, broj_pitanja, tocni_odgovori, krivi_odgovori, 
                     bodovi, start_vrijeme, ishod, ocjena, dodatni_tekst="", tezina=""):
    datum_dir = kreiraj_direktorij_za_rezultate()
    
    sada = datetime.now()
    vrijeme_str = sada.strftime('%Hh%Mm')
    
    ime_datoteke = f"rezultati_{_sigurno_ime(ime_igraca)}_{vrijeme_str}"
    if ishod == "PREKINUTO":
        ime_datoteke += "-PREKINUTO"
    ime_datoteke += ".txt"
    
    putanja = os.path.join(datum_dir, ime_datoteke)
    
    brojac = 1
    while os.path.exists(putanja):
        if ishod == "PREKINUTO":
            ime_datoteke = f"rezultati_{_sigurno_ime(ime_igraca)}_{vrijeme_str}-PREKINUTO_{brojac}.txt"
        else:
            ime_datoteke = f"rezultati_{_sigurno_ime(ime_igraca)}_{vrijeme_str}_{brojac}.txt"
        putanja = os.path.join(datum_dir, ime_datoteke)
        brojac += 1
    
    kraj_vrijeme = time.time()
    trajanje = kraj_vrijeme - start_vrijeme
    minute_trajanje = int(trajanje // 60)
    sekunde_trajanje = int(trajanje % 60)
    
    try:
        with open(putanja, 'w', encoding='utf-8') as f:
            f.write("=" * 50 + "\n")
            f.write("  REZULTATI - INFORMATIKA METEORI\n")
            f.write("=" * 50 + "\n")
            f.write(f"Igrač:        {ime_igraca}\n")
            if tezina:
                f.write(f"Težina:       {tezina}\n")
            f.write(f"Broj pitanja:  {broj_pitanja}\n")
            f.write(f"Datum:        {datetime.now().strftime('%d.%m.%Y. %H:%M:%S')}\n")
            f.write(f"Ishod:        {ishod}\n")
            f.write(f"Ocjena:       {ocjena}\n")
            if dodatni_tekst:
                f.write(f"Napomena:     {dodatni_tekst}\n")
            f.write("-" * 50 + "\n")
            f.write(f"Bodovi:       {bodovi}\n")
            f.write(f"Točnih:       {tocni_odgovori}\n")
            f.write(f"Netočnih:     {krivi_odgovori}\n")
            f.write(f"Točnost:      {int(tocni_odgovori / broj_pitanja * 100) if broj_pitanja > 0 else 0}%\n")
            f.write(f"Vrijeme trajanja: {minute_trajanje}m {sekunde_trajanje}s\n")
            f.write("=" * 50 + "\n")
        return putanja
    except Exception as e:
        print(f"Greška pri spremanju rezultata: {e}")
        return None

# --- Glavna igra ---
def izbornik():
    print("\n" + "═" * 50)
    print("  ☄️  INFORMATIKA METEORI - 1. RAZRED  ☄️")
    print("═" * 50)
    
    ime = input("\n  Upiši svoje ime: ").strip()
    if not ime:
        ime = "Učenik"
    
    print("\nOdaberi težinu:\n")
    print("  [1]  Lagano - 10 pitanja, spori meteori")
    print("  [2]  Srednje - 15 pitanja, srednji meteori")
    print("  [3]  Teško - 25 pitanja, brzi meteori")
    print("  [4]  Custom - odaberi broj pitanja i brzinu")
    print()
    
    while True:
        tezina = input("Tvoj odabir (1-4): ").strip()
        if tezina in ["1", "2", "3", "4"]:
            break
        print("  Upiši broj između 1 i 4.")
    
    if tezina == "1":
        broj_pitanja = 10
        brzina_pada = 0.2
        naziv_tezine = "Lagano"
    elif tezina == "2":
        broj_pitanja = 15
        brzina_pada = 0.4
        naziv_tezine = "Srednje"
    elif tezina == "3":
        broj_pitanja = 25
        brzina_pada = 0.6
        naziv_tezine = "Teško"
    else:
        print("\nUnesi željeni broj pitanja (1-25):")
        while True:
            try:
                broj_pitanja = int(input("  Broj pitanja: ").strip())
                if 1 <= broj_pitanja <= len(PITANJA):
                    break
                else:
                    print(f"  Broj mora biti između 1 i {len(PITANJA)}.")
            except ValueError:
                print("  Molim unesi ispravan broj.")
        
        print("\nOdaberi brzinu meteora (1-3):")
        print("  [1]  Sporo")
        print("  [2]  Srednje")
        print("  [3]  Brzo")
        while True:
            brzina_izbor = input("  Tvoj odabir (1-3): ").strip()
            if brzina_izbor == "1":
                brzina_pada = 0.2
                break
            elif brzina_izbor == "2":
                brzina_pada = 0.4
                break
            elif brzina_izbor == "3":
                brzina_pada = 0.6
                break
            else:
                print("  Upiši broj između 1 i 3.")
        
        naziv_tezine = f"Custom ({broj_pitanja})"
    
    print("\n" + "─" * 50)
    print(f"  Igrač:   {ime}")
    print(f"  Težina:  {naziv_tezine}")
    print(f"  Pitanja: {broj_pitanja}")
    print(f"  Brzina:  {brzina_pada}")
    print("\nUpute:")
    print("  • Pritisni A, B, C ili D za pucanje na točan odgovor!")
    print("  • ✅ Točan odgovor - eksplodira i donosi 10 bodova")
    print("  • ❌ Krivi odgovor - pada na Zemlju i oduzima život")
    print("  • ☄️ Ako točan odgovor padne na Zemlju - gubiš život!")
    print("  • ESC = izlaz iz igre")
    print()
    input("Pritisni ENTER za početak...")
    
    return ime, broj_pitanja, naziv_tezine, brzina_pada

def igraj(stdscr, ime_igraca, broj_pitanja, naziv_tezine, brzina_pada):
    # Inicijalizacija curses
    curses.curs_set(0)
    curses.start_color()
    curses.use_default_colors()
    
    # Postavi boje
    curses.init_pair(1, curses.COLOR_RED, -1)
    curses.init_pair(2, curses.COLOR_YELLOW, -1)
    curses.init_pair(3, curses.COLOR_GREEN, -1)
    curses.init_pair(4, curses.COLOR_CYAN, -1)
    curses.init_pair(5, curses.COLOR_WHITE, -1)
    curses.init_pair(6, curses.COLOR_MAGENTA, -1)
    
    stdscr.nodelay(True)
    stdscr.timeout(50)
    
    visina, sirina = stdscr.getmaxyx()
    
    # Provjeri veličinu ekrana
    if visina < 15 or sirina < 40:
        stdscr.addstr(0, 0, "Ekran je premali! Povećaj prozor.", curses.color_pair(1))
        stdscr.refresh()
        time.sleep(2)
        return 0
    
    zemlja_red = visina - 3
    
    # Miješanje pitanja
    pitanja_za_igru = random.sample(PITANJA, min(broj_pitanja, len(PITANJA)))
    
    # Varijable
    trenutno_pitanje = 0
    meteori = []
    tocni = 0
    krivi = 0
    bodovi = 0
    zivoti = 3
    poruka = ""
    poruka_boja = 3
    poruka_timer = 0
    start_vrijeme = time.time()
    prekinuto = False
    ceka_novo = False
    ceka_timer = 0
    zadnji_pad = time.time()
    odgovoreno = False
    
    def zapocni_pitanje():
        nonlocal meteori, odgovoreno
        if trenutno_pitanje >= len(pitanja_za_igru):
            return
        
        pitanje = pitanja_za_igru[trenutno_pitanje]
        meteori = []
        odgovoreno = False
        
        # Stvori meteor za svaki odgovor - rasporedi ih po širini
        odgovori = list(pitanje['odgovori'].items())
        ukupno = len(odgovori)
        
        # Pomiješaj raspored meteora - ne uvijek A B C D
        random.shuffle(odgovori)

        # Širina stupca: ravnomjerno podijeli ekran na ukupno stupaca
        sirina_stupca = (sirina - 4) // ukupno - 2
        sirina_stupca = max(12, sirina_stupca)

        # Izračunaj pozicije i linije za svaki meteor
        for i, (slovo, tekst) in enumerate(odgovori):
            # Podijeli tekst u više redaka ako je predugačak
            prvi_red = f"{slovo}) {tekst}"
            if len(prvi_red) <= sirina_stupca:
                linije_raw = [prvi_red]
            else:
                prefix = f"{slovo}) "
                rijeci = tekst.split()
                linije_raw = []
                trenutna = prefix
                for rijec in rijeci:
                    test = trenutna + rijec if trenutna == prefix else trenutna + " " + rijec
                    if len(test) <= sirina_stupca:
                        trenutna = test
                    else:
                        linije_raw.append(trenutna.rstrip())
                        trenutna = "   " + rijec
                if trenutna.strip():
                    linije_raw.append(trenutna.rstrip())

            # Poravnaj sve linije na istu širinu (širina najdulje linije)
            sirina_linije = max(len(l) for l in linije_raw)
            linije = [l.ljust(sirina_linije) for l in linije_raw]
            # Širina meteora = sirina_linije + 2 (za [ i ])
            sirina_meteora = sirina_linije + 2

            # Raspored: podijeli ekran ravnomjerno
            razmak = (sirina - 2) // ukupno
            col = int(1 + razmak * i + (razmak - sirina_meteora) // 2)
            col = max(1, min(sirina - sirina_meteora - 1, col))

            # Boja (fiksna po meteoru)
            boja_meteora = [2, 4, 6, 5][i % 4]

            meteor = {
                'slovo': slovo,
                'tekst': linije[0],
                'linije': linije,
                'sirina_meteora': sirina_meteora,
                'visina': len(linije),
                'row_float': 4.0,
                'row': 4,
                'col': col,
                'boja': boja_meteora,
                'eksplodira': False,
                'eksplozija_timer': 0,
                'pogoden': False
            }

            meteori.append(meteor)
    
    def prikazi_kraj(naslov, boja, ocjena=""):
        stdscr.clear()
        cy = visina // 2
        cx = sirina // 2
        
        try:
            stdscr.addstr(cy - 8, cx - 15, "═" * 30, curses.color_pair(4))
            stdscr.addstr(cy - 7, cx - 15, f"  {naslov}", curses.color_pair(boja) | curses.A_BOLD)
            if ocjena:
                stdscr.addstr(cy - 5, cx - 15, f"  {ocjena}", curses.color_pair(boja) | curses.A_BOLD)
            stdscr.addstr(cy - 3, cx - 15, f"  Igrač:      {ime_igraca}", curses.color_pair(5))
            stdscr.addstr(cy - 2, cx - 15, f"  Težina:     {naziv_tezine}", curses.color_pair(5))
            stdscr.addstr(cy - 1, cx - 15, f"  Pitanja:    {len(pitanja_za_igru)}", curses.color_pair(5))
            stdscr.addstr(cy + 1, cx - 15, f"  Točnih:     {tocni}", curses.color_pair(3))
            stdscr.addstr(cy + 2, cx - 15, f"  Netočnih:   {krivi}", curses.color_pair(1))
            stdscr.addstr(cy + 3, cx - 15, f"  Bodovi:     {bodovi}", curses.color_pair(4) | curses.A_BOLD)
            stdscr.addstr(cy + 5, cx - 15, "  Pritisni ENTER za izlaz", curses.color_pair(5))
            stdscr.addstr(cy + 6, cx - 15, "═" * 30, curses.color_pair(4))
            stdscr.refresh()
        except:
            pass
        
        stdscr.nodelay(False)
        while True:
            k = stdscr.getch()
            if k in (curses.KEY_ENTER, 10, 13, 27):
                return
    
    # Započni prvo pitanje
    zapocni_pitanje()
    
    # Glavna petlja
    while trenutno_pitanje < len(pitanja_za_igru) and zivoti > 0:
        sada = time.time()
        
        # Provjera tipki
        try:
            tipka = stdscr.getch()
        except:
            tipka = -1
        
        if tipka == 27:  # ESC
            prekinuto = True
            break
        
        # Provjeri A, B, C, D
        if not odgovoreno and not ceka_novo and tipka in [ord('a'), ord('A'), ord('b'), ord('B'), 
                                                          ord('c'), ord('C'), ord('d'), ord('D')]:
            slovo = chr(tipka).upper()
            pitanje = pitanja_za_igru[trenutno_pitanje]
            
            for meteor in meteori[:]:
                if meteor['slovo'] == slovo and not meteor['eksplodira'] and not meteor['pogoden']:
                    if slovo == pitanje['tocan']:
                        # Točan odgovor
                        meteor['eksplodira'] = True
                        meteor['eksplozija_timer'] = sada
                        tocni += 1
                        bodovi += 10
                        poruka = f"  ✅ TOČNO! +10 bodova  "
                        poruka_boja = 3
                        poruka_timer = sada
                        odgovoreno = True
                        
                        # Ostali meteori eksplodiraju
                        for m in meteori:
                            if m != meteor and not m['pogoden']:
                                m['eksplodira'] = True
                                m['eksplozija_timer'] = sada
                        
                        ceka_novo = True
                        ceka_timer = sada
                    else:
                        # Krivi odgovor
                        meteor['pogoden'] = True
                        krivi += 1
                        zivoti -= 1
                        poruka = f"  ❌ NETOČNO!  "
                        poruka_boja = 1
                        poruka_timer = sada
                        odgovoreno = True
                        ceka_novo = True
                        ceka_timer = sada
                        
                        if zivoti <= 0:
                            break
                    break
        
        # Pomakni meteoare
        if not odgovoreno and not ceka_novo and sada - zadnji_pad > 0.1:
            for meteor in meteori[:]:
                if not meteor['eksplodira'] and not meteor['pogoden']:
                    meteor['row_float'] += brzina_pada
                    meteor['row'] = int(meteor['row_float'])
                    
                    # Provjeri je li pao na Zemlju (zadnja linija meteora)
                    dno_meteora = meteor['row'] + meteor.get('visina', 1) - 1
                    if dno_meteora >= zemlja_red:
                        pitanje = pitanja_za_igru[trenutno_pitanje]
                        if meteor['slovo'] == pitanje['tocan']:
                            # Točan odgovor pao - gubiš život
                            zivoti -= 1
                            krivi += 1
                            poruka = f"  ☄️ TOČAN ODGOVOR PAO!  "
                            poruka_boja = 1
                            poruka_timer = sada
                            odgovoreno = True
                            ceka_novo = True
                            ceka_timer = sada
                            
                            for m in meteori:
                                m['eksplodira'] = True
                                m['eksplozija_timer'] = sada
                            
                            if zivoti <= 0:
                                break
                        else:
                            # Krivi odgovor pao - ukloni ga
                            meteori.remove(meteor)
            zadnji_pad = sada
        
        # Prijeđi na sljedeće pitanje
        if ceka_novo and sada - ceka_timer > 1.0:
            meteori = []
            trenutno_pitanje += 1
            if trenutno_pitanje < len(pitanja_za_igru):
                zapocni_pitanje()
            ceka_novo = False
            odgovoreno = False
            poruka = ""
        
        # --- CRTANJE EKRANA ---
        stdscr.erase()
        
        # Border
        try:
            stdscr.border()
        except:
            pass
        
        # Header
        srca = "❤ " * zivoti if zivoti > 0 else "💀 "
        header = f"  {ime_igraca.upper()}  |  Pitanje {trenutno_pitanje + 1}/{len(pitanja_za_igru)}  |  {srca}"
        try:
            stdscr.addstr(0, 2, header[:sirina - 4], curses.color_pair(4) | curses.A_BOLD)
        except:
            pass
        
        # Statistika
        try:
            stdscr.addstr(1, 2, f"  ✅ Točno: {tocni}  ❌ Netočno: {krivi}  ⭐ Bodovi: {bodovi}", 
                         curses.color_pair(5))
        except:
            pass
        
        # Progress bar
        try:
            sirina_trake = sirina - 4
            popunjeno = int(sirina_trake * (trenutno_pitanje / len(pitanja_za_igru)))
            traka = "█" * popunjeno + "░" * (sirina_trake - popunjeno)
            stdscr.addstr(2, 2, traka[:sirina - 4], curses.color_pair(3))
        except:
            pass
        
        # Pitanje
        if trenutno_pitanje < len(pitanja_za_igru):
            pitanje = pitanja_za_igru[trenutno_pitanje]
            try:
                stdscr.addstr(3, 3, f"❓ {pitanje['pitanje']}", curses.color_pair(2) | curses.A_BOLD)
            except:
                pass
        
        # Meteori
        for meteor in meteori:
            try:
                if meteor['eksplodira']:
                    # Eksplozija
                    if sada - meteor['eksplozija_timer'] < 0.6:
                        stdscr.addstr(int(meteor['row']), int(meteor['col']), "* BOOM! *",
                                     curses.color_pair(2) | curses.A_BOLD)
                elif meteor['pogoden']:
                    # Pogodak krivi - crveno (sve linije, isti okvir)
                    linije = meteor.get('linije', [meteor['tekst']])
                    n = len(linije)
                    for li, linija in enumerate(linije):
                        r = int(meteor['row']) + li
                        if r < zemlja_red and r >= 0:
                            prikaz = f"  {linija.rstrip()} "
                            try:
                                stdscr.addstr(r, int(meteor['col']), prikaz,
                                             curses.color_pair(1) | curses.A_BOLD)
                            except:
                                pass
                else:
                    # Normalni meteor - crtaj sve linije s okvirom
                    linije = meteor.get('linije', [meteor['tekst']])
                    n = len(linije)
                    if meteor['row'] > zemlja_red - 4:
                        boja_crtanje = 1
                    else:
                        boja_crtanje = meteor['boja']

                    for li, linija in enumerate(linije):
                        r = int(meteor['row']) + li
                        if r < zemlja_red and r >= 0:
                            prikaz = f"  {linija.rstrip()} "
                            try:
                                stdscr.addstr(r, int(meteor['col']), prikaz,
                                             curses.color_pair(boja_crtanje) | curses.A_BOLD)
                            except:
                                pass

                    # Zvjezdica iznad meteora
                    if meteor['row'] > 4 and meteor['row'] < zemlja_red:
                        try:
                            sredina = int(meteor['col']) + meteor.get('sirina_meteora', 8) // 2
                            stdscr.addstr(int(meteor['row']) - 1, sredina, "✦",
                                         curses.color_pair(4))
                        except:
                            pass
            except:
                pass
        
        # Zemlja
        try:
            stdscr.addstr(zemlja_red, 1, "═" * (sirina - 2), curses.color_pair(6) | curses.A_BOLD)
            stdscr.addstr(zemlja_red + 1, sirina // 2 - 5, "[ ZEMLJA ]", curses.color_pair(6) | curses.A_BOLD)
        except:
            pass
        
        # Poruka
        if poruka and sada - poruka_timer < 1.2:
            try:
                x_pos = max(0, sirina // 2 - len(poruka) // 2)
                stdscr.addstr(zemlja_red - 2, x_pos, poruka,
                             curses.color_pair(poruka_boja) | curses.A_BOLD)
            except:
                pass
        
        # Upute
        try:
            stdscr.addstr(visina - 2, 2,
                         "  A  B  C  D  za pucanje  |  ESC = izlaz  ",
                         curses.color_pair(4))
        except:
            pass
        
        stdscr.refresh()
    
    # Kraj igre
    if prekinuto:
        ocjena, boja = dobij_ocjenu(tocni, len(pitanja_za_igru), naziv_tezine)
        spremi_rezultate(ime_igraca, len(pitanja_za_igru), tocni, krivi, 
                        bodovi, start_vrijeme, "PREKINUTO", ocjena,
                        "Igra prekinuta (ESC)", naziv_tezine)
        
        stdscr.clear()
        cy = visina // 2
        cx = sirina // 2
        try:
            stdscr.addstr(cy - 5, cx - 15, "─" * 30, curses.color_pair(4))
            stdscr.addstr(cy - 4, cx - 15, "  ⏸  IGRA PREKINUTA  ", curses.color_pair(1) | curses.A_BOLD)
            stdscr.addstr(cy - 2, cx - 15, f"  Točno: {tocni}  Netočno: {krivi}", curses.color_pair(5))
            stdscr.addstr(cy - 1, cx - 15, f"  Bodovi: {bodovi}", curses.color_pair(4) | curses.A_BOLD)
            stdscr.addstr(cy + 1, cx - 15, f"  {ocjena}", curses.color_pair(boja) | curses.A_BOLD)
            stdscr.addstr(cy + 3, cx - 15, "  Pritisni ENTER za izlaz", curses.color_pair(5))
            stdscr.addstr(cy + 4, cx - 15, "─" * 30, curses.color_pair(4))
            stdscr.refresh()
        except:
            pass
        
        stdscr.nodelay(False)
        while True:
            k = stdscr.getch()
            if k in (curses.KEY_ENTER, 10, 13, 27):
                break
    elif zivoti <= 0:
        ocjena, boja = dobij_ocjenu(tocni, len(pitanja_za_igru), naziv_tezine)
        spremi_rezultate(ime_igraca, len(pitanja_za_igru), tocni, krivi, 
                        bodovi, start_vrijeme, "GAME OVER", ocjena,
                        "Meteori su uništili Zemlju!", naziv_tezine)
        prikazi_kraj("☄️  GAME OVER  ☄️", 1, ocjena)
    else:
        ocjena, boja = dobij_ocjenu(tocni, len(pitanja_za_igru), naziv_tezine)
        spremi_rezultate(ime_igraca, len(pitanja_za_igru), tocni, krivi, 
                        bodovi, start_vrijeme, "POBJEDA", ocjena,
                        "Spašena je Zemlja!", naziv_tezine)
        prikazi_kraj("🏆  POBJEDA!  🏆", 3, ocjena)
    
    return bodovi

def main():
    ime_igraca, broj_pitanja, naziv_tezine, brzina_pada = izbornik()
    bodovi = curses.wrapper(igraj, ime_igraca, broj_pitanja, naziv_tezine, brzina_pada)
    print(f"\n🏆 Završni rezultat: {bodovi} bodova!")
    # print("📁 Rezultati spremljeni u 'rezultati_informatika_meteori'")
    print("Hvala na igri! 🌟\n")

if __name__ == "__main__":
    main()
