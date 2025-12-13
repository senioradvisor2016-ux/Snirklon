# Snirklon

En professionell MIDI/CV-sequencer för macOS/iOS inspirerad av Sequentix Cirklon.

## Funktioner

### Sekvensering
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

### MIDI
- **MIDI Out** - Full CoreMIDI-support med multipla portar (5 x 16 kanaler)
- **MIDI Sync** - Master/Slave MIDI Clock-synkronisering
- **MIDI Learn** - CC-mappning för extern kontroll

### CV/Gate/ADSR (Modular Integration)
- **CV Pitch Output** - 1V/oktav med kalibrering per utgång
- **Gate/Trigger Output** - Gate och trigger-lägen
- **ADSR Envelope Generator** - Multipla ADSR:er med CV-utgång
  - Attack, Decay, Sustain, Release
  - Velocity sensitivity
  - Kurvformer (linjär, exponentiell, logaritmisk)
- **CV Clock Output** - Modulär clock med:
  - Divisioner (1/1 till 1/32, trioler, punkterade)
  - Multiplikationer (1x-4x)
  - Swing och fasförskjutning
  - Reset/Run-utgångar
- **CV LFO** - Tempo-synkade LFO:er med CV-ut
- **Portamento/Glide** - Legato och always-läge
- **Multi-channel** - Upp till 16 CV-kanaler

### Synkronisering
- **Ableton Link** - Tempo och fas-synkronisering med Link-kompatibla enheter
- **MIDI Clock** - Master/Slave med Song Position Pointer
- **CV Clock** - Analog clock-ut för modulärer

## Stödda CV-gränssnitt

| Gränssnitt | CV-utgångar | Anslutning |
|------------|-------------|------------|
| Expert Sleepers ES-8 | 8 | USB |
| Expert Sleepers ES-9 | 16 | USB |
| Expert Sleepers ES-3 | 8 | ADAT |
| MOTU UltraLite mk5 | 10 | USB |
| MOTU 828es | 28 | USB/Thunderbolt |
| RME Fireface UCX II | 8 | USB |

## Teknisk Stack

- **Swift 5.9+**
- **SwiftUI** - Modern deklarativ UI
- **CoreMIDI** - MIDI I/O
- **CoreAudio/AVFoundation** - Högprecisionstiming och CV-utgång
- **Ableton Link SDK** - Nätverkssynkronisering

## Dokumentation

Se [plan.md](plan.md) för fullständig projektplan och arkitektur.

## Licens

MIT