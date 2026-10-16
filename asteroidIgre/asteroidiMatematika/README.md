# 🚀 Asteroidi Matematika

Igra za vježbanje računanja. Asteroidi s računskim zadacima (npr. `7+5`,
`24:6`) padaju prema Zemlji, a igrač ih uništava tako da **utipka točan
rezultat** i pritisne ENTER. Igra se u terminalu (biblioteka `curses`).

## Što se uči

- zbrajanje
- oduzimanje
- zbrajanje i oduzimanje zajedno
- množenje (tablice do 10)
- dijeljenje (bez ostatka, tablice do 10)
- sve zajedno (nasumični mix)

Raspon brojeva bira igrač (npr. 10, 20, 50, 100, 200), pa igra raste zajedno s
djetetom, od 1. razreda nadalje.

## Zahtjevi

- Python 3
- Terminal dovoljno velik da stane ekran igre
- `curses`:
  - **Linux / macOS** - već dolazi uz Python
  - **Windows** - igra sama pokuša instalirati `windows-curses` pomoću `pip`

## Pokretanje

```bash
cd asteroidIgre/asteroidiMatematika
python3 asteroidiMatametika.py
```

## Kako se igra

Prije početka izbornik traži redom:

1. **Ime** (ako ostane prazno, koristi se "Astronaut")
2. **Težinu**, tj. ciljni broj bodova za pobjedu:

| Težina  | Cilj |
|---------|------|
| Lagano  | 100 bodova |
| Srednje | 200 bodova |
| Teško   | 300 bodova |
| Custom  | vlastiti cilj (najmanje 10) |

3. **Do kojeg broja** se računa (najmanje 2)
4. **Vrstu zadataka** (6 načina, vidi gore)
5. **Brzinu** padanja asteroida: Sporo (0.7 s), Srednje (0.4 s), Brzo (0.2 s) po koraku

### Kontrole

| Tipka | Radnja |
|-------|--------|
| `0-9` | upisivanje odgovora |
| `-` | minus (samo na početku unosa) |
| `Backspace` | briše zadnju znamenku |
| `Enter` | potvrda odgovora |
| `Esc` | prekid igre |

### Pravila

- Točan odgovor uništava asteroid s tim rezultatom: **+10 bodova**
- Netočan odgovor se samo broji kao greška (ne oduzima život)
- Asteroid koji padne na Zemlju oduzima **život** - imaš **3 života** (❤)
- Na ekranu može biti najviše **3 asteroida**, a novi se pojavljuje otprilike
  svakih 5 sekundi

### Kraj igre

- **POBJEDA** - dostignut ciljni broj bodova
- **GAME OVER** - izgubljena sva 3 života
- **PREKINUTO** - izlaz tipkom ESC

## Rezultati

Rezultati se spremaju u direktorij `rezultati/` koji se kreira **u direktoriju
iz kojeg je igra pokrenuta**, grupirano po datumu:

```
rezultati/
└── 2026-10-16/
    └── rezultati_Ana_14h35m.txt
```

Datoteka sadrži igrača, težinu, cilj, najveći broj, datum, ishod, bodove,
broj točnih i netočnih odgovora, uništene asteroide, preostale živote i
trajanje igre. Prekinute igre imaju u nazivu dodatak `-PREKINUTO`.
