# 🎮 Igre za djecu

Zbirka malih edukativnih igara za djecu, namijenjenih za pokretanje u
terminalu. Sve igre su na hrvatskom jeziku i bez grafičkih ovisnosti, pa rade
i na starijim računalima.

## Popis igara

| Igra | Tema | Dob | Tehnologija | Upute |
|------|------|-----|-------------|-------|
| ☄️ [Informatika Meteori](asteroidIgre/asteroidInformatika/) | osnove informatike (kviz, 25 pitanja) | 1. razred | Python 3 + curses | [README](asteroidIgre/asteroidInformatika/README.md) |
| 🚀 [Asteroidi Matematika](asteroidIgre/asteroidiMatematika/) | zbrajanje, oduzimanje, množenje, dijeljenje | 1. razred i dalje | Python 3 + curses | [README](asteroidIgre/asteroidiMatematika/README.md) |
| 🐧 [Linux Avantura](uciLinux/) | osnovne Linux naredbe (kviz A/B/C/D, 5 mini-igara) | oko 6-10 godina | Bash | [README](uciLinux/README.md) |

## Kratki opis

**Informatika Meteori** - meteori s odgovorima A/B/C/D padaju prema Zemlji,
a dijete pritiskom na slovo uništava onaj s točnim odgovorom. Tri života,
tri težine, ocjena na kraju.

**Asteroidi Matematika** - asteroidi s računskim zadacima padaju prema
Zemlji, a dijete utipkava rezultat i uništava ih. Bira se težina, raspon
brojeva, vrsta računskih operacija i brzina.

**Linux Avantura** - kviz u kojem dijete uči navigaciju, rad s datotekama,
dozvole, traženje i sigurnost u Linuxu. Ima tri težine s vremenskim
ograničenjem, bodove, značke i certifikat na kraju.

## Struktura repozitorija

```
igre/
├── README.md                          ← ova datoteka
├── asteroidIgre/
│   ├── asteroidInformatika/
│   │   ├── README.md
│   │   └── asteroidiInformatika.py
│   └── asteroidiMatematika/
│       ├── README.md
│       └── asteroidiMatametika.py
└── uciLinux/
    ├── README.md
    └── uciLinux.sh
```

## Brzi početak

```bash
git clone <adresa-repozitorija> igre
cd igre

# Informatika Meteori
python3 asteroidIgre/asteroidInformatika/asteroidiInformatika.py

# Asteroidi Matematika
python3 asteroidIgre/asteroidiMatematika/asteroidiMatametika.py

# Linux Avantura
cd uciLinux && chmod +x uciLinux.sh && ./uciLinux.sh
```

## Zahtjevi

- **Python igre** - Python 3 i terminal veličine barem 40 x 15 znakova.
  `curses` dolazi uz Python na Linuxu i macOS-u; na Windowsu igre same
  pokušaju instalirati `windows-curses`.
- **Linux Avantura** - Bash (Linux). Prepoznaje Arch/CachyOS, Debian/Ubuntu,
  Fedora i openSUSE.

## Gdje se spremaju rezultati

| Igra | Mjesto spremanja |
|------|------------------|
| Informatika Meteori | `rezultati/<datum>/` u direktoriju iz kojeg je igra pokrenuta |
| Asteroidi Matematika | `rezultati/<datum>/` u direktoriju iz kojeg je igra pokrenuta |
| Linux Avantura | dnevnik i certifikat u direktoriju same igre |

Preporuka: Python igre pokretati iz njihovog direktorija da se `rezultati/`
ne razbacuje po računalu.

## Dodavanje novih igara

Svaka igra ima vlastiti direktorij s `README.md` datotekom (postavljanje,
pokretanje, pravila, gdje sprema podatke). Nakon dodavanja nove igre dopiši
je u tablicu iznad.
