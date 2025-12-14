import Foundation

/// Thread-safe cache for pattern data to improve pattern switching performance
final class PatternCache {
    static let shared = PatternCache()
    
    private var cache: [Int: PatternSnapshot] = [:]
    private let lock = NSLock()
    private let maxCacheSize = 8
    
    struct PatternSnapshot {
        let pattern: PatternModel
        let timestamp: Date
    }
    
    private init() {}
    
    /// Cache a pattern at the given index
    func cache(_ pattern: PatternModel, at index: Int) {
        lock.lock()
        defer { lock.unlock() }
        
        cache[index] = PatternSnapshot(pattern: pattern, timestamp: Date())
        
        // Evict oldest entries if cache is too large
        if cache.count > maxCacheSize {
            evictOldest()
        }
    }
    
    /// Get a cached pattern if available
    func get(at index: Int) -> PatternModel? {
        lock.lock()
        defer { lock.unlock() }
        
        return cache[index]?.pattern
    }
    
    /// Preload patterns around the current index
    func preload(currentIndex: Int, patterns: [PatternModel]) {
        lock.lock()
        defer { lock.unlock() }
        
        // Preload adjacent patterns
        let indicesToPreload = [currentIndex - 1, currentIndex, currentIndex + 1]
            .filter { $0 >= 0 && $0 < patterns.count }
        
        for index in indicesToPreload {
            if cache[index] == nil {
                cache[index] = PatternSnapshot(pattern: patterns[index], timestamp: Date())
            }
        }
        
        // Evict if needed
        while cache.count > maxCacheSize {
            evictOldest(excluding: Set(indicesToPreload))
        }
    }
    
    /// Invalidate cache for a specific pattern
    func invalidate(at index: Int) {
        lock.lock()
        defer { lock.unlock() }
        
        cache.removeValue(forKey: index)
    }
    
    /// Invalidate entire cache
    func invalidateAll() {
        lock.lock()
        defer { lock.unlock() }
        
        cache.removeAll()
    }
    
    /// Update cached pattern
    func update(_ pattern: PatternModel, at index: Int) {
        lock.lock()
        defer { lock.unlock() }
        
        cache[index] = PatternSnapshot(pattern: pattern, timestamp: Date())
    }
    
    private func evictOldest(excluding: Set<Int> = []) {
        guard let oldestKey = cache
            .filter({ !excluding.contains($0.key) })
            .min(by: { $0.value.timestamp < $1.value.timestamp })?
            .key
        else { return }
        
        cache.removeValue(forKey: oldestKey)
    }
}

// MARK: - Rendering Cache for Step Cells

/// Cache for pre-computed step cell rendering data
final class StepRenderCache {
    static let shared = StepRenderCache()
    
    private var velocityOpacityCache: [Int: Double] = [:]
    private let lock = NSLock()
    
    private init() {
        // Pre-compute velocity opacities
        for velocity in 1...127 {
            let t = Double(velocity) / 127.0
            velocityOpacityCache[velocity] = 0.15 + (0.80 * t)
        }
    }
    
    /// Get pre-computed velocity opacity
    func velocityOpacity(for velocity: Int) -> Double {
        let clamped = max(1, min(127, velocity))
        return velocityOpacityCache[clamped] ?? 0.5
    }
}

// MARK: - Note Name Cache

/// Cache for note name lookups
final class NoteNameCache {
    static let shared = NoteNameCache()
    
    private var noteNames: [Int: String] = [:]
    private let noteLetters = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    
    private init() {
        // Pre-compute all note names
        for note in 0...127 {
            let octave = (note / 12) - 1
            let noteName = noteLetters[note % 12]
            noteNames[note] = "\(noteName)\(octave)"
        }
    }
    
    /// Get note name for MIDI note number
    func name(for note: Int) -> String {
        let clamped = max(0, min(127, note))
        return noteNames[clamped] ?? "C4"
    }
}
