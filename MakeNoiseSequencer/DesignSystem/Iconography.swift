import SwiftUI

// MAKE NOISE-INSPIRED ICONOGRAPHY
// - short labels, symbols before words, monospace values
// - avoid verbose UI copy

enum Iconography {

  // Panel symbols (text-based)
  enum Sym {
    static let on  = "●"
    static let off = "○"
    static let selected = "▣"
    static let empty = "▢"
    static let step = "▪︎"
    static let prob = "P"
    static let len  = "L"
    static let vel  = "V"
    static let time = "T"
    static let rpt  = "R"
  }

  // SF Symbols mapping for transport / common actions
  enum SF {
    static let play  = "play.fill"
    static let stop  = "stop.fill"
    static let rec   = "record.circle"
    static let mute  = "speaker.slash.fill"
    static let solo  = "headphones"
    static let dup   = "square.on.square"
    static let copy  = "doc.on.doc"
    static let paste = "doc.on.clipboard"
    static let undo  = "arrow.uturn.backward"
    static let redo  = "arrow.uturn.forward"
  }

  // Short parameter labels (keep stable positions in Inspector)
  enum Label {
    static let note = "NOTE"
    static let vel  = "VEL"
    static let len  = "LEN"
    static let time = "TIME"
    static let prob = "PROB"
    static let rpt  = "RPT"

    static let bpm  = "BPM"
    static let swing = "SWNG"
    static let quant = "QNTZ"
    static let loop  = "LOOP"
    
    // CV / Audio Interface labels
    static let cv    = "CV"
    static let gate  = "GATE"
    static let pitch = "PITCH"
    static let mod   = "MOD"
    static let clock = "CLK"
    static let trig  = "TRIG"
    static let env   = "ENV"
    static let lfo   = "LFO"
    static let dc    = "DC"
    static let out   = "OUT"
    static let input = "IN"
  }
  
  // SF Symbols for CV/Settings
  enum SFCV {
    static let settings = "slider.horizontal.3"
    static let output   = "arrow.right.circle"
    static let input    = "arrow.left.circle"
    static let voltage  = "bolt"
    static let waveform = "waveform"
    static let link     = "link"
    
    // ADSR Envelope
    static let envelope  = "waveform.path"
    static let attack    = "arrow.up.right"
    static let decay     = "arrow.down.right"
    static let sustain   = "minus"
    static let release   = "arrow.down.right.circle"
    static let retrigger = "arrow.clockwise"
    static let loop      = "repeat"
  }
}
