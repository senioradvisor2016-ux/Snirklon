# Snirklon 🎹🤖

En generativ sequencer-applikation med Claude som central AI-motor.

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

## Huvudfunktioner

- 🎵 **Generativa sekvenser** - AI-skapade melodier, rytmer och harmonier
- 💬 **Naturlig dialog** - Beskriv musik med ord, få sekvenser tillbaka
- 🔄 **Iterativ förfining** - Ge feedback, förbättra tillsammans med AI
- 🎭 **Musikaliska personas** - 12+ olika kreativa "karaktärer" för varierad output
- 🌊 **Mood morphing** - Transformera sekvenser baserat på känslor
- 🧬 **Evolutionär musik** - Låt sekvenser utvecklas organiskt
- 📖 **Musikalisk storytelling** - Skapa flerkapitels musikaliska berättelser
- 🎯 **Constraint-based generation** - Kreativitet inom begränsningar

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

## Teknisk Stack

- **AI**: Claude API (Anthropic) - claude-sonnet-4-20250514
- **Språk**: TypeScript
- **Streaming**: Realtidsrespons för bättre UX
- **Format**: JSON-baserat sekvensformat

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