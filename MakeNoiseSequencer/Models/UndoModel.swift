import SwiftUI

/// Undo/Redo system for sequencer actions
class UndoManager: ObservableObject {
    @Published private(set) var canUndo: Bool = false
    @Published private(set) var canRedo: Bool = false
    @Published private(set) var undoActionName: String = ""
    @Published private(set) var redoActionName: String = ""
    
    private var undoStack: [UndoAction] = []
    private var redoStack: [UndoAction] = []
    private let maxHistorySize: Int = 50
    
    /// Register an undoable action
    func registerUndo(name: String, undo: @escaping () -> Void, redo: @escaping () -> Void) {
        let action = UndoAction(name: name, undo: undo, redo: redo)
        undoStack.append(action)
        
        // Clear redo stack when new action is performed
        redoStack.removeAll()
        
        // Limit history size
        if undoStack.count > maxHistorySize {
            undoStack.removeFirst()
        }
        
        updateState()
    }
    
    /// Undo the last action
    func undo() {
        guard let action = undoStack.popLast() else { return }
        action.undo()
        redoStack.append(action)
        updateState()
    }
    
    /// Redo the last undone action
    func redo() {
        guard let action = redoStack.popLast() else { return }
        action.redo()
        undoStack.append(action)
        updateState()
    }
    
    /// Clear all history
    func clearHistory() {
        undoStack.removeAll()
        redoStack.removeAll()
        updateState()
    }
    
    private func updateState() {
        canUndo = !undoStack.isEmpty
        canRedo = !redoStack.isEmpty
        undoActionName = undoStack.last?.name ?? ""
        redoActionName = redoStack.last?.name ?? ""
    }
}

struct UndoAction {
    let name: String
    let undo: () -> Void
    let redo: () -> Void
}

/// Snapshot of sequencer state for undo
struct SequencerSnapshot: Codable {
    let patterns: [PatternSnapshot]
    let currentPatternIndex: Int
    let bpm: Int
    let swing: Int
    let timestamp: Date
    
    init(patterns: [PatternModel], currentPatternIndex: Int, bpm: Int, swing: Int) {
        self.patterns = patterns.map { PatternSnapshot(from: $0) }
        self.currentPatternIndex = currentPatternIndex
        self.bpm = bpm
        self.swing = swing
        self.timestamp = Date()
    }
}

struct PatternSnapshot: Codable {
    let id: String
    let name: String
    let index: Int
    let tracks: [TrackSnapshot]
    
    init(from pattern: PatternModel) {
        self.id = pattern.id.uuidString
        self.name = pattern.name
        self.index = pattern.index
        self.tracks = pattern.tracks.map { TrackSnapshot(from: $0) }
    }
}

struct TrackSnapshot: Codable {
    let id: String
    let name: String
    let midiChannel: Int
    let isMuted: Bool
    let isSolo: Bool
    let length: Int
    let steps: [StepSnapshot]
    let colorRed: Double
    let colorGreen: Double
    let colorBlue: Double
    
    init(from track: TrackModel) {
        self.id = track.id.uuidString
        self.name = track.name
        self.midiChannel = track.midiChannel
        self.isMuted = track.isMuted
        self.isSolo = track.isSolo
        self.length = track.length
        self.steps = track.steps.map { StepSnapshot(from: $0) }
        
        // Extract color components
        let uiColor = UIColor(track.color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: nil)
        self.colorRed = Double(r)
        self.colorGreen = Double(g)
        self.colorBlue = Double(b)
    }
}

struct StepSnapshot: Codable {
    let id: String
    let index: Int
    let isOn: Bool
    let note: Int
    let velocity: Int
    let length: Int
    let timing: Int
    let probability: Int
    let repeat_: Int
    
    init(from step: StepModel) {
        self.id = step.id.uuidString
        self.index = step.index
        self.isOn = step.isOn
        self.note = step.note
        self.velocity = step.velocity
        self.length = step.length
        self.timing = step.timing
        self.probability = step.probability
        self.repeat_ = step.repeat_
    }
}

// MARK: - UIColor Extension for Color Extraction
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
typealias UIColor = NSColor
#endif
