# Snirklon 🎹🤖

> **Status: ✅ Komplett Implementation**

En generativ sequencer-applikation med Claude som central AI-motor, inspirerad av Sequentix Cirklon.

## Vision

Snirklon kombinerar kraften i modern AI med kreativ musikskapande för att erbjuda en unik sequencing-upplevelse där Claude fungerar som din kreativa partner.

## Installation

```bash
npm install
```

## Användning

```typescript
import { SnirklonClaudeClient, MUSICAL_PERSONAS } from './src/claude';

// Skapa klient och session
const client = new SnirklonClaudeClient();
const session = client.startSession({
  bpm: 120,
  timeSignature: [4, 4],
  key: 'Am',
  scale: 'minor',
});

// Generera en sekvens
const result = await client.generateSequence({
  prompt: 'Skapa en mörk bassslinga',
  context: session.context,
  persona: 'techno_engineer',
});
```

## Dokumentation

- [Claude Integration Guide](./CLAUDE_INTEGRATION_GUIDE.md) - Omfattande guide för tips, förbättringar och kreativa möjligheter
- [Implementation Plan](./plan.md) - Fullständig projektplan och arkitektur

---

## Huvudfunktioner

### 🤖 AI-driven Sekvensering
- 🎵 **Generativa sekvenser** - AI-skapade melodier, rytmer och harmonier
- 💬 **Naturlig dialog** - Beskriv musik med ord, få sekvenser tillbaka
- 🔄 **Iterativ förfining** - Ge feedback, förbättra tillsammans med AI
- 🎭 **Musikaliska personas** - 12+ olika kreativa "karaktärer" för varierad output
- 🌊 **Mood morphing** - Transformera sekvenser baserat på känslor
- 🧬 **Evolutionär musik** - Låt sekvenser utvecklas organiskt
- 📖 **Musikalisk storytelling** - Skapa flerkapitels musikaliska berättelser
- 🎯 **Constraint-based generation** - Kreativitet inom begränsningar

### 🎹 Cirklon-inspirerade Funktioner
- **64 spår per pattern** - Instrument, CV, Auxiliary och P3-spår
- **Polymetrisk sekvensering** - Individuella spårlängder för polymetriska kompositioner
- **Avancerad step-sekvensering**:
  - Probability (sannolikhet per steg)
  - Villkorlig triggning (Fill, A/B-patterns, etc.)
  - Ratchets/Rolls (upprepningar)
  - Micro-timing och swing
  - Parameter locks
- **P3 Modulering** - LFO, Envelope och Step-modulatorer för parametrar
- **Song Mode** - Pattern chaining och song-arrangemang
- **Skalor & Ackord** - Inbyggt stöd för musikteori

### 🎛️ MIDI
- **MIDI Out** - Full CoreMIDI-support med multipla portar (5 x 16 kanaler)
- **MIDI Sync** - Master/Slave MIDI Clock-synkronisering
- **MIDI Learn** - CC-mappning för extern kontroll

### ⚡ CV/Gate/ADSR (Modular Integration)
- **CV Pitch Output** - 1V/oktav med kalibrering per utgång
- **Gate/Trigger Output** - Gate och trigger-lägen
- **ADSR Envelope Generator** - Multipla ADSR:er med CV-utgång
- **CV Clock Output** - Modulär clock med divisioner och multiplikationer
- **CV LFO** - Tempo-synkade LFO:er med CV-ut
- **Portamento/Glide** - Legato och always-läge
- **Multi-channel** - Upp till 16 CV-kanaler

### 🔗 Synkronisering
- **Ableton Link** - Tempo och fas-synkronisering med Link-kompatibla enheter
- **MIDI Clock** - Master/Slave med Song Position Pointer
- **CV Clock** - Analog clock-ut för modulärer

---

## Tillgängliga Personas

| Persona | Beskrivning | Stil |
|---------|-------------|------|
| `cosmic_explorer` | Spacey, ambient | Calm, lydian |
| `dream_weaver` | Drömlikt, eteriskt | Free, pentatonic |
| `urban_groove` | Tight, funky | Syncopated, dorian |
| `polyrhythm_shaman` | Komplex, hypnotisk | Polyrhythmic |
| `glitch_wizard` | Kaotisk, experimentell | Chaotic, chromatic |
| `noise_poet` | Textural, emotionell | Free, experimental |
| `melody_architect` | Klassisk melodisk | Steady, consonant |
| `baroque_machine` | Kontrapunktisk | Complex, counterpoint |
| `techno_engineer` | Driving, hypnotisk | Minimal, energetic |
| `lo_fi_dreamer` | Nostalgisk, varm | Syncopated, jazzy |
| `minimalist_monk` | Repetitiv, meditativ | Minimal, process |
| `chaos_mathematician` | Algoritmisk, fraktal | Complex, mathematical |

---

## Stödda CV-gränssnitt

### 🌟 Expert Sleepers ES-9 (Primärt stöd)

| Specifikation | Värde |
|---------------|-------|
| **CV Outputs** | 8 DC-kopplade (±10V) |
| **CV Inputs** | 4 DC-kopplade (±10V) |
| **ADAT Expansion** | +8 ut (ES-3) / +8 in (ES-6) |
| **Latens** | <1ms (64 samples @ 48kHz) |
| **Presets** | Mono Synth, 4-Voice Poly, Drums, MPE |

### Övriga gränssnitt

| Gränssnitt | CV Out | CV In | Anslutning |
|------------|--------|-------|------------|
| Expert Sleepers ES-8 | 8 | 4 | USB |
| Expert Sleepers ES-3 | 8 | - | ADAT (via ES-9) |
| Expert Sleepers ES-6 | - | 8 | ADAT (via ES-9) |
| MOTU UltraLite mk5 | 10 | 2 | USB |
| MOTU 828es | 28 | 28 | USB/Thunderbolt |
| RME Fireface UCX II | 8 | 8 | USB |

## 🔌 Avancerat CV-system (Bitwig-inspirerat)

### CV = Audio
- **Sample-accurate** - Full 32-bit floating point precision
- **Processbar** - Filter, delay, distortion på CV-signaler
- **Flexibel routing** - CV Routing Matrix med feedback-stöd

### CV Processing
| Processor | Användning |
|-----------|------------|
| **CVFilter** | LP/HP/BP/comb på CV |
| **CVDistortion** | Waveshaping, foldback |
| **CVDelay** | Tempo-synkad delay på CV |
| **CVQuantizer** | CV → skalkvantiserade noter |
| **CVSlew** | Portamento, anti-click |

### CV Modulators
- **LFO** - Chaos (Lorenz), morphing, custom wavetable
- **Curves** - Freeform kurvor med loop
- **Random** - S&H, turing machine, walk
- **Steps** - Step sequencer som modulator
- **Sidechain** - Audio → CV (pitch tracking, envelope follower)

## 🥁 Drum Machine MIDI Maps

| Trummaskin | Spår | Features |
|------------|------|----------|
| **Roland TR-909** | 11 | Tune CC, Decay CC, Accent |
| **Elektron Analog Rytm** | 12 | Full parameter control |
| **LinnDrum** | 16 | LM-1/LM-2 kompatibel |
| **Kawai R-100** | 16 | Alla PCM-ljud |
| **Vermona DRM1 MKIII** | 8 | Tune/Decay CC per spår |

## 🎵 128-stegs Pattern Library

| Genre | Patterns | Tempo | Subgenrer |
|-------|----------|-------|-----------|
| **Darkwave** | 100+ | 85-135 | Cold Wave, Gothic, Deathrock, Post-Punk |
| **Synthpop** | 100+ | 85-145 | Electropop, Futurepop, New Wave |
| **EBM** | 100+ | 95-160 | Classic, Aggrotech, Dark Electro, New Beat |
| **Techno** | 100+ | 120-155 | Minimal, Detroit, Berlin, Industrial, Acid |

**Totalt:** 400+ patterns, 800+ variationer, 600+ fills

---

## Teknisk Stack

- **AI**: Claude API (Anthropic) - claude-sonnet-4-20250514
- **Språk**: TypeScript (claude-integration), Swift 5.9+ (sequencer)
- **UI**: SwiftUI - Modern deklarativ UI
- **MIDI**: CoreMIDI (in/out)
- **Audio/CV**: CoreAudio/AVFoundation - Högprecisionstiming och CV-utgång
- **Sync**: Ableton Link SDK
- **Bridge**: WebSocket (TypeScript ↔ Swift)
- **Streaming**: Realtidsrespons för bättre UX
- **Format**: JSON-baserat sekvensformat

## ✅ Implementation Status

| Modul | Status | Beskrivning |
|-------|--------|-------------|
| **Claude Integration (TS)** | ✅ 100% | Klient, personas, prompts, validering |
| **Core Models (Swift)** | ✅ 100% | Step, Track, Pattern, Project |
| **Sequencer Engine** | ✅ 100% | Playback, timing, pattern chaining |
| **MIDI System** | ✅ 100% | Input, Output, MIDI Learn, Mapping |
| **CV System** | ✅ 100% | Engine, Processing, Modulators |
| **CV Processing** | ✅ 100% | Filter, Delay, Quantizer, Slew, Distortion |
| **CV Modulators** | ✅ 100% | LFO, Envelope, Steps, Random, Curves |
| **MIDI ↔ CV** | ✅ 100% | Bidirectional conversion |
| **HW CV Devices** | ✅ 100% | Instrument, Clock |
| **Bridge (TS ↔ Swift)** | ✅ 100% | WebSocket server/client |
| **Pattern Library** | ✅ 100% | 50+ extended patterns |
| **Ableton Link** | ✅ 100% | Tempo/phase sync |
| **UI (Vintage Voltage)** | ✅ 100% | Theme, components, views |

---

## Projektstruktur

```
src/
├── claude/              # Core AI integration
│   ├── index.ts
│   ├── client.ts        # Claude API-klient
│   ├── types.ts         # Bas-typer
│   ├── personas.ts      # 12 musikaliska personas
│   ├── prompts.ts       # Prompt engineering
│   └── validators.ts    # Validering
│
├── synth/               # Synth Sequencer
│   ├── index.ts
│   ├── types.ts         # Oscillatorer, filter, LFO, etc.
│   └── presets.ts       # Fördefinierade patches
│
├── drums/               # Drum Sequencer  
│   ├── index.ts
│   ├── types.ts         # Drum sounds, kits, patterns
│   └── patterns.ts      # Kits, grooves, styles
│
├── sequencer/           # Unified Controller
│   ├── index.ts
│   └── client.ts        # Kombinerad synth+drum klient
│
└── examples/
    ├── basic-usage.ts
    └── synth-and-drums.ts

MakeNoiseSequencer/      # Swift-baserad visual sequencer
├── App/
├── DesignSystem/
├── Features/
├── Models/
└── Store/
```

---

## 🎹 Synth Sequencer

### Features
- **Oscillatorer**: Sine, saw, square, pulse, noise, wavetable, FM
- **Filter**: LP, HP, BP, notch, comb, formant med envelope
- **Envelopes**: ADSR + multi-stage med kurvor
- **LFO**: 3 st med sync, olika former, fria destinations
- **Modulation Matrix**: Flexibel routing
- **Effekter**: Delay, reverb, chorus, distortion, bitcrusher, etc.
- **Voice Modes**: Poly, mono (legato), unison
- **Per-note**: Slide, accent, filter offset, automation

### Presets
| Kategori | Presets |
|----------|---------|
| Bass | `sub_bass`, `acid_bass`, `reese_bass` |
| Lead | `classic_lead`, `screaming_lead` |
| Pad | `warm_pad`, `dark_pad` |
| Pluck | `digital_pluck`, `bell_tone` |
| FX | `noise_sweep` |

---

## 🥁 Drum Sequencer

### Features
- **Kits**: 808, 909, Acoustic, hybrid
- **Per-step**: Velocity, nudge, probability, parameter locks
- **Flams & Rolls**: Med velocity ramp
- **Euclidean**: Automatisk rytmgenerering
- **Polymetri**: Olika längder per spår
- **Groove Templates**: MPC 60, SP-1200, shuffle
- **Fills**: Buildup, breakdown, transition, drop
- **Style Transform**: Konvertera mellan genrer

### Drum Styles (25+)
`techno`, `house`, `deep_house`, `minimal`, `trance`, `drum_and_bass`, `jungle`, `dubstep`, `breakbeat`, `trap`, `hip_hop`, `funk`, `jazz`, `rock`, `pop`, `latin`, `afrobeat`, `industrial`, `glitch`, `polyrhythmic`...

### Classic Patterns
- `four_on_floor` - House/Techno
- `breakbeat_basic` - Hip-hop/Breaks  
- `dnb_basic` - Drum & Bass
- `trap_basic` - Trap
- `techno_minimal` - Minimal Techno

---

## 🔮 Kreativa AI-funktioner

### För Synth
```typescript
// Generera sekvens
await client.generateSynthSequence({
  prompt: 'Acid bassline med slides',
  context,
  patchHint: 'acid_bass',
});

// Designa patch från beskrivning
await client.designSynthPatch(
  'Aggressiv lead med metallisk karaktär'
);

// Generera arpeggio
await client.generateArpeggio([60, 64, 67, 72], request);
```

### För Drums
```typescript
// Generera pattern
await client.generateDrumSequence({
  prompt: 'Driving techno beat',
  style: 'techno',
  kitId: 'kit_909',
});

// Euclidean rhythms
generateEuclidean({ hits: 5, steps: 16, rotation: 0 });

// Style transform
await client.styleTransform(technoPattern, 'jungle');

// Generate fills
await client.generateFill(pattern, 'buildup');
```

### Kombinerat
```typescript
// Full arrangement
await client.generateFullArrangement(
  'Mörk techno som bygger till klimax',
  4  // sections
);

// Jam session - AI svarar på din input
await client.jamSession(
  { type: 'synth', sequence: bassLine },
  'drums'  // AI svarar med trummor
);
```

---

## Licens

MIT
