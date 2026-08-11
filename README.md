# GymPlanner — verze pro iPhone a iPad (bez Macu)

Tato verze je **webová aplikace (PWA)**, kterou spustíte přímo na iPhonu nebo iPadu v Safari — **nepotřebujete Mac ani Xcode**.

Nativní Swift verze ve složce `GymPlanner/` vyžaduje Mac. Pokud máte jen iPhone/iPad, použijte tuto webovou verzi.

## Funkce (stejné jako nativní app)

- **Knihovna cviků** — vytváření cviků podle partie (Záda, Prsa, Ruce, Ramena, Nohy, Břicho)
- **Trénink** — sestavení tréninku s datem, **počtem sérií** a u každé série váhou a opakováními
- **Minulý výkon** — u každé série vidíte, co jste cvičili naposledy
- **Archiv** — dokončené tréninky se přesunou sem
- **Rekordy** — u každého cviku se drží nejvyšší váha a nejvíce opakování

## Jak nainstalovat na iPhone / iPad

### Varianta A — GitHub Pages (doporučeno)

Po nahrání repozitáře na GitHub se aplikace automaticky nasadí na:

`https://VASE-USERNAME.github.io/gym-planner/`

1. V **Safari** na iPhonu/iPadu otevřete tuto adresu
2. Klepněte **Sdílet** → **Přidat na plochu**
3. Aplikace běží na celou obrazovku jako nativní app

> V nastavení repozitáře → **Pages** → Source: **GitHub Actions** (workflow je v repozitáři).

### Varianta B — jiný hosting

1. Nahrajte složku `GymPlannerWeb` na **Netlify** nebo **Vercel** (zdarma).
2. Na iPhonu/iPadu otevřete URL v **Safari**.
3. Klepněte na **Sdílet** → **Přidat na plochu**.

### Varianta B — lokální síť (pro rychlé vyzkoušení)

Pokud máte počítač ve stejné Wi‑Fi síti:

```bash
cd GymPlannerWeb
python3 -m http.server 8080
```

Na iPhonu otevřete v Safari: `http://IP-VASEHO-POCITACE:8080`

> iPhone musí být ve stejné Wi‑Fi síti jako počítač.

## Offline režim

Aplikace ukládá data do **localStorage** v prohlížeči a má **service worker** — po prvním načtení funguje i bez internetu.

## Poznámky

- Data zůstávají v Safari na vašem zařízení (ne v cloudu).
- Pokud vymažete historii prohlížeče / data webu, tréninky se smažou — zálohujte si je, pokud budete měnit zařízení.
- Na iPadu funguje stejně, rozhraní je optimalizované pro dotyk.

## Struktura

```
GymPlannerWeb/
├── index.html
├── manifest.json      # PWA manifest
├── sw.js              # Service worker (offline)
├── css/styles.css
├── js/
│   ├── app.js         # UI a logika
│   └── storage.js     # Ukládání dat
└── icons/
```

## Porovnání verzí

| | Web (PWA) | Nativní (Swift) |
|---|---|---|
| Potřeba Mac | ❌ Ne | ✅ Ano |
| iPhone / iPad | ✅ Ano | ✅ Ano |
| App Store | ❌ Ne (ikona na ploše) | ✅ Ano |
| Offline | ✅ Ano | ✅ Ano |
| Ukládání dat | localStorage | SwiftData |
