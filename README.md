# Snirklon

En professionell MIDI-sequencer för macOS/iOS inspirerad av Sequentix Cirklon.

## Funktioner

- **64 spår per pattern** - Instrument, CV, Auxiliary och P3-spår
- **Polymetrisk sekvensering** - Individuella spårlängder för polymetriska kompositioner
- **Avancerad step-sekvensering**:
  - Probability (sannolikhet per steg)
  - Villkorlig triggning (Fill, A/B-patterns, etc.)
  - Ratchets/Rolls (upprepningar)
  - Micro-timing och swing
  - Parameter locks
- **P3 Modulering** - LFO, Envelope och Step-modulatorer för parametrar
- **MIDI Out** - Full CoreMIDI-support med multipla portar
- **MIDI Sync** - Master/Slave MIDI Clock-synkronisering
- **Ableton Link** - Tempo och fas-synkronisering med Link-kompatibla enheter
- **Song Mode** - Pattern chaining och song-arrangemang
- **Skalor & Ackord** - Inbyggt stöd för musikteori

## Teknisk Stack

- **Swift 5.9+**
- **SwiftUI** - Modern deklarativ UI
- **CoreMIDI** - MIDI I/O
- **CoreAudio** - Högprecisionstiming
- **Ableton Link SDK** - Nätverkssynkronisering

## Dokumentation

Se [plan.md](plan.md) för fullständig projektplan och arkitektur.

## Licens

MIT