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
  }
}
