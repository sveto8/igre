# Linux Avantura za Djecu 🐧

Edukativna igra koja djecu (od otprilike 6-10 godina) kroz kviz s ponuđenim
odgovorima (A/B/C/D) uči osnovne Linux naredbe: navigaciju, rad s
datotekama, dozvole i sigurnost te traženje pomoći.

## Postavljanje

1. Prebaci CIJELI direktorij ove igre gdje god želiš na svom računalu
   (npr. `~/igre/uciLinux`)
2. Otvori terminal u tom direktoriju
3. Pokreni jednom: `chmod +x uci_linux.sh` (daje dozvolu za pokretanje)

Igra radi neovisno o tome gdje je direktorij smješten - ne mora biti u
`$HOME`.

## Pokretanje

```
./uci_linux.sh
```

## Kako igra radi

- Sve je na hrvatskom i ispisuje se VELIKIM SLOVIMA
- Umjesto tipkanja Linux naredbi, dijete bira odgovor A, B, C ili D
- Na početku igra pita za TEŽINU:
  - **LAGANO** - 30 sekundi po pitanju (puno vremena za razmišljanje)
  - **SREDNJE** - 20 sekundi po pitanju (1/3 brže)
  - **TEŠKO** - 10 sekundi po pitanju (2/3 brže, za prave majstore)
  - Težinu je moguće kasnije promijeniti iz glavnog izbornika (opcija 13)
- Ako dijete ne stigne odgovoriti na vrijeme, pitanje se broji kao
  netočno i igra ide dalje - nema zastoja ni čekanja
- Igra ima 5 mini-igara (navigacija, datoteke, dozvole, traženje,
  pronađi svoje ime) te opciju da se sve odigraju redom kao jedna
  velika avantura (opcija 9)
- Za svaku igru postoje bodovi i "badge-ovi" (značke) koji se osvajaju
  ovisno o uspjehu

## Gdje se datoteke spremaju

Igra sama kreira sve svoje datoteke **u istom direktoriju u kojem se
nalazi `uci_linux.sh`**, bez obzira odakle je pokrenuta:

```
uciLinux/
    ├── uci_linux.sh
    ├── linux_avantura_dnevnik.txt   ← dnevnik napretka (bilježi svaku
    │                                   igru, badge i postignuće)
    └── linux_certifikat_<korisnik>.txt  ← certifikat na kraju avanture
```

Zbog toga direktorij igre treba biti na mjestu gdje korisnik koji je
pokreće ima dozvolu za pisanje (obično je to slučaj za bilo koji
direktorij unutar vlastitog `$HOME`).

## Napomene

- Igra automatski prepoznaje je li sustav Arch/CachyOS (pacman/yay/paru),
  Debian/Ubuntu (apt), Fedora (dnf) ili openSUSE (zypper) i predlaže
  odgovarajuće naredbe za nadogradnju sustava
- Dnevnik napretka moguće je pregledati u bilo kojem trenutku iz
  glavnog izbornika (opcija 11)
