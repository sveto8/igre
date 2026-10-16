# ☄️ Informatika Meteori

Edukativna igra za djecu **1. razreda osnovne škole**. Na ekranu padaju meteori
s ponuđenim odgovorima (A/B/C/D), a igrač mora "pucati" na točan odgovor prije
nego što padne na Zemlju. Igra se u terminalu (biblioteka `curses`).

## Što se uči

Osnove informatike kroz **25 pitanja** s ponuđenim odgovorima: dijelovi računala
(monitor, miš, tipkovnica, pisač, zvučnici, kamera, mikrofon), korištenje
tipkovnice (Space, Enter, Backspace, Shift...), što je internet, lozinke,
sigurno ponašanje na internetu i pravilno gašenje računala.

## Zahtjevi

- Python 3
- Terminal veličine najmanje **40 x 15** znakova (inače igra javi da je ekran premali)
- `curses`:
  - **Linux / macOS** - već dolazi uz Python
  - **Windows** - igra sama pokuša instalirati `windows-curses` pomoću `pip`

## Pokretanje

```bash
cd asteroidIgre/asteroidInformatika
python3 asteroidiInformatika.py
```

## Kako se igra

1. Upiši svoje ime (ako ostane prazno, koristi se "Učenik")
2. Odaberi težinu:

| Težina  | Pitanja | Brzina meteora |
|---------|---------|----------------|
| Lagano  | 10      | spora (0.2)    |
| Srednje | 15      | srednja (0.4)  |
| Teško   | 25      | brza (0.6)     |
| Custom  | 1-25 po izboru | sporo / srednje / brzo po izboru |

3. Za svako pitanje padaju 4 meteora, po jedan za svaki odgovor (raspored
   se miješa, nije uvijek A B C D)
4. Pritisni **A**, **B**, **C** ili **D** da pogodiš meteor s točnim odgovorom

### Pravila

- ✅ Točan odgovor - meteor eksplodira, **+10 bodova**
- ❌ Krivi odgovor - **gubiš život**
- ☄️ Ako točan odgovor padne na Zemlju - **gubiš život**
- Imaš **3 života** (❤)
- **ESC** - prekid igre

### Kraj igre

- **POBJEDA** - odgovorena sva pitanja prije nego što ostaneš bez života
- **GAME OVER** - izgubljena sva 3 života
- **PREKINUTO** - izlaz tipkom ESC

Na kraju igra daje ocjenu prema postotku točnih odgovora (pragovi su blaži
na lakšoj težini):

| Ocjena | Lagano | Srednje | Teško |
|--------|--------|---------|-------|
| 🌟 Bravo! Izvrsno! | ≥ 90% | ≥ 90% | ≥ 85% |
| 👍 Vrlo dobro! | ≥ 80% | ≥ 75% | ≥ 70% |
| 📚 Dobro! Možeš bolje! | ≥ 60% | ≥ 55% | ≥ 50% |
| 📖 Vježbaj još! | ispod | ispod | ispod |

## Rezultati

Rezultati se spremaju u tekstualne datoteke u direktoriju `rezultati/` koji se
kreira **u direktoriju iz kojeg je igra pokrenuta** (ne nužno uz skriptu):

```
rezultati/
└── 2026-10-16/
    └── rezultati_Ana_14h35m.txt
```

Datoteka sadrži ime igrača, broj pitanja, datum, ishod, ocjenu, bodove, broj
točnih i netočnih odgovora, postotak točnosti i trajanje igre. Prekinute igre
imaju u nazivu dodatak `-PREKINUTO`.

## Dodavanje vlastitih pitanja

Pitanja su u listi `PITANJA` na vrhu skripte. Svako pitanje ima ovaj oblik:

```python
{
    "pitanje": "Što je računalo?",
    "odgovori": {"A": "Igračka", "B": "Vozilo",
                 "C": "Uređaj za rad i učenje", "D": "Kućni ljubimac"},
    "tocan": "C"
},
```

Ako dodaš pitanja, za opciju *Custom* maksimalni broj pitanja prilagođava se
duljini liste, a fiksne težine (10/15/25) trebaš po potrebi sam promijeniti u
funkciji `izbornik()`.
