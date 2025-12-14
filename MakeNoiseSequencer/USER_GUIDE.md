# MakeNoise Sequencer - Användarguide

## Introduktion

MakeNoise Sequencer är en kraftfull 64-stegs sekvenser inspirerad av Cirklon, designad för att styra modulärsyntar via CV/Gate-utgångar. Med en intuitiv panel-estetik och snabb responstid är den perfekt för live-performance och studioarbete.

---

## Snabbstart

### 1. Aktivera steg
Tryck på rutnätet för att aktivera/avaktivera steg. Aktiva steg lyser med spårets färg.

### 2. Starta uppspelning
Tryck på **PLAY** i transportfältet eller tryck **SPACE**.

### 3. Justera tempo
Ändra **BPM** (20-300) med pilarna eller dra för att finjustera.

### 4. Välj spår
Klicka på ett spår i sidofältet (KICK, SNARE, HAT, BASS).

---

## Gränssnittet

```
┌─────────────────────────────────────────────────────────────────────┐
│ ▶ STOP │ BPM 120 │ SWNG 50% │ STEP 01 │ ES-9 ⚙ │ ?                 │
├─────────────────────────────────────────────────────────────────────┤
│ Spår   │ [P1] [P2] [P3] [P4]                                        │
│ ───────│────────────────────────────────────────────────────────────│
│ KICK   │ B1        B2        B3        B4                           │
│ M S    │ 1 · · · 2 · · · 3 · · · 4 · · · 1 · · · 2 · · · ...       │
│────────│ ● · · · ● · · · ● · · · ● · · · ● · · · ● · · · ...       │
│ SNARE  │ · · · · ● · · · · · · · ● · · · · · · · ● · · · ...       │
│ M S    │                                                            │
│────────│                                                            │
│ HAT    │ ● · ● · ● · ● · ● · ● · ● · ● · ● · ● · ● · ● · ...       │
│ M S    │                                                            │
│────────│                                                            │
│ BASS   │ · · · · · · · · · · · · · · · · · · · · · · · · ...       │
│ M S    │                                                            │
└────────┴────────────────────────────────────────────────────────────┘
```

### Områden

| Område | Beskrivning |
|--------|-------------|
| **Transport** | Play/Stop, BPM, Swing, Stegräknare |
| **Sidofält** | Spårlista med Mute/Solo |
| **Mönsterväljare** | P1-P4 för mönsterval |
| **Rutnät** | 64 steg × antal spår |
| **Inspektör** | Detaljerad stegredigering |

---

## Stegsekvensering

### Grundläggande gester

| Gest | Funktion |
|------|----------|
| **Tap** | Aktivera/avaktivera steg |
| **Dra vertikalt** | Justera velocity |
| **Långtryck (0.25s)** | Öppna inspektören |
| **Shift + tap** | Markera flera steg |

### Stegparametrar

| Parameter | Område | Beskrivning |
|-----------|--------|-------------|
| **NOTE** | C0-G10 | MIDI-notnummer |
| **VEL** | 1-127 | Velocity/styrka |
| **LEN** | 1-96 ticks | Notlängd |
| **TIME** | -48 till +48 | Mikrotiming offset |
| **PROB** | 0-100% | Sannolikhet att spela |

### Velocity-visualisering
Ljusstyrkan på varje steg visar velocity:
- Ljust = hög velocity
- Dämpat = låg velocity
- Tomt = inaktivt steg

---

## Spårhantering

### Mute & Solo

- **M (Mute)**: Tystar spåret utan att ta bort stegen
- **S (Solo)**: Spelar bara markerade spår

Du kan kombinera flera spår på Solo.

### Färgkodning
Varje spår har en unik färg för enkel identifiering i rutnätet.

---

## Mönster

### Mönsterväljare (P1-P4)
- Tryck för omedelbart byte
- Köade byten sker vid nästa takt för smidig övergång

### Kopiera mönster
1. Välj källmönster
2. Öppna menyn
3. Välj "Kopiera mönster"
4. Välj destination

---

## CV-utgångar

### Krav
Du behöver ett **DC-kopplat ljudkort** för att skicka CV:

| Modell | Utgångar | Spänning | Rekommenderas |
|--------|----------|----------|---------------|
| Expert Sleepers ES-9 | 16 | ±10V | ⭐ Bäst |
| Expert Sleepers ES-8 | 8 | ±10V | ⭐ Bra |
| MOTU UltraLite mk5 | 10 | ±5V | OK |
| MOTU 828es | 28 | ±5V | OK |

### Signaltyper

| Typ | Användning |
|-----|------------|
| **Pitch** | 1V/oktav för VCO |
| **Gate** | On/off för ADSR-trigger |
| **Velocity** | Dynamik till VCA |
| **Modulation** | Fri modulering |

### Konfigurera CV
1. Öppna ⚙ (inställningar) i transportfältet
2. Välj ditt ljudkort
3. Tilldela kanaler till spår
4. Anslut kablar till modulärsynthen

---

## ADSR-enveloper

### Vad är ADSR?

```
Nivå
  │     ╱╲
  │    ╱  ╲__________
  │   ╱              ╲
  │  ╱                ╲
  └─┴────────────────────── Tid
    A    D    S    R
```

| Fas | Beskrivning |
|-----|-------------|
| **Attack** | Tid att nå maxnivå (1-10000 ms) |
| **Decay** | Tid att sjunka till sustain (1-10000 ms) |
| **Sustain** | Hållen nivå (0-100%) |
| **Release** | Tid till noll efter gate-off (1-10000 ms) |

### Skapa en envelop
1. Gå till **CV/ADSR**-fliken
2. Tryck **+ ADD**
3. Välj källspår (trigger)
4. Justera ADSR med rattarna
5. Välj destination (VCA, VCF, etc.)

### Presets

| Preset | Användning |
|--------|------------|
| PERC | Snabba percussion-ljud |
| PLUCK | Plucky synth |
| PAD | Mjuka pads |
| KICK | Bastrumma |
| SNARE | Virvel |

### Kurvtyper

| Kurva | Karaktär |
|-------|----------|
| **Linear** | Rak linje |
| **Exponential** | Snabb start, långsam slut |
| **Logarithmic** | Långsam start, snabb slut |
| **S-Curve** | Mjuk övergång |

---

## Tangentbordsgenvägar

### Transport
| Genväg | Funktion |
|--------|----------|
| `Space` | Play/Stop |
| `Enter` | Play från början |
| `Esc` | Stop och återställ |

### Navigation
| Genväg | Funktion |
|--------|----------|
| `↑` `↓` | Byt spår |
| `←` `→` | Flytta i rutnätet |
| `1-4` | Byt mönster |
| `Tab` | Växla inspektör |

### Redigering
| Genväg | Funktion |
|--------|----------|
| `⌘C` | Kopiera |
| `⌘V` | Klistra in |
| `⌘Z` | Ångra |
| `⌘A` | Markera alla |
| `Delete` | Ta bort |

---

## Felsökning

### Inget ljud
1. ✓ Är spåret muteat?
2. ✓ Finns aktiva steg?
3. ✓ Är MIDI/CV korrekt ansluten?
4. ✓ Är ljudkortet rätt konfigurerat?

### CV fungerar inte
1. ✓ Är ljudkortet DC-kopplat?
2. ✓ Rätt utgångskanal vald?
3. ✓ Är CV-spåret aktiverat?
4. ✓ Kablar korrekt anslutna?

### Timing-problem
1. ✓ Kontrollera BPM
2. ✓ Swing på 50% för rakt tempo
3. ✓ Vid extern sync, verifiera clock-källa

---

## Tips & Tricks

### 💡 Snabbast möjliga workflow
- Använd tangentbordsgenvägar
- Håll inspektören öppen vid detaljarbete
- Använd Mute för att testa variationer

### 💡 Bättre CV-signaler
- ES-9 ger bäst precision
- Kalibrera 1V/oktav för VCO
- Använd slew för mjukare övergångar

### 💡 Kreativa tekniker
- Polyrytmik: Olika längd per spår
- Probability: Slumpmässig variation
- Mikrotiming: Mänsklig känsla

---

## Support

Tryck på **?** i appen för interaktiv hjälp och chat-assistent.

---

*MakeNoise Sequencer v1.0*
*Inspirerad av Cirklon & Make Noise*
