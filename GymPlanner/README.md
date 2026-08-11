# GymPlanner

iOS aplikace pro jednoduchou tvorbu posilovacích tréninků.

## Funkce

### Knihovna cviků
- Vytváření a úprava cviků
- Řazení podle partie: **Záda**, **Prsa**, **Ruce**, **Ramena**, **Nohy**, **Břicho**
- U každého cviku se ukládají **nejvyšší váha** a **nejvíce opakování** z dokončených tréninků

### Trénink
- Vytvoření tréninku s **datem**
- Poskládání cviků z knihovny (filtr podle partie, vyhledávání)
- U každého cviku zadání **váhy (kg)** a **počtu opakování**
- Zobrazení **minulého výkonu** (váha × opakování z posledního dokončeného tréninku)
- Přesouvání a mazání cviků v tréninku
- **Dokončení tréninku** — přesune se do archivu a aktualizují se rekordy cviků

### Archiv
- Přehled všech dokončených tréninků
- Detail archivovaného tréninku s kompletním zápisem cviků

## Požadavky

- iOS 17.0+
- Xcode 15.0+
- iPhone

## Spuštění

1. Otevřete `GymPlanner.xcodeproj` v Xcode
2. Vyberte cílové zařízení (simulátor nebo fyzický iPhone)
3. Stiskněte **Run** (⌘R)

## Technologie

- **SwiftUI** — uživatelské rozhraní
- **SwiftData** — lokální persistence dat
- **TabView** — tři záložky (Knihovna, Trénink, Archiv)

## Struktura dat

```
Exercise (šablona cviku)
├── název, partie
├── maxWeight — nejvyšší váha
└── maxReps — nejvíce opakování

Workout (trénink)
├── datum, stav dokončení
└── WorkoutExercise[] — cviky v tréninku
    ├── váha, opakování
    └── odkaz na Exercise
```

## Poznámky

- Data se ukládají lokálně na zařízení (SwiftData)
- Rekordy cviků se aktualizují až po **dokončení** tréninku
- „Minule“ u cviku v tréninku ukazuje výkon z posledního **archivovaného** tréninku se stejným cvikem
