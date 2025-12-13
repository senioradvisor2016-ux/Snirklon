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
├── claude/
│   ├── index.ts       # Huvudexport
│   ├── client.ts      # Claude API-klient
│   ├── types.ts       # TypeScript-typer
│   ├── personas.ts    # Musikaliska personas
│   ├── prompts.ts     # Prompt engineering
│   └── validators.ts  # Validering och parsing
└── examples/
    └── basic-usage.ts # Användningsexempel
```

## Licens

MIT