import SwiftUI

/// Preset system for saving and loading patterns and configurations
struct Preset: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var category: PresetCategory
    var author: String
    var createdAt: Date
    var modifiedAt: Date
    var isFavorite: Bool
    var tags: [String]
    
    // Snapshot data
    var snapshot: SequencerSnapshot
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        category: PresetCategory = .user,
        author: String = "User",
        isFavorite: Bool = false,
        tags: [String] = [],
        snapshot: SequencerSnapshot
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.category = category
        self.author = author
        self.createdAt = Date()
        self.modifiedAt = Date()
        self.isFavorite = isFavorite
        self.tags = tags
        self.snapshot = snapshot
    }
}

enum PresetCategory: String, Codable, CaseIterable {
    case factory = "Factory"
    case user = "User"
    case drums = "Drums"
    case bass = "Bass"
    case melodic = "Melodic"
    case experimental = "Experimental"
    case live = "Live"
    case template = "Template"
    
    var icon: String {
        switch self {
        case .factory: return "building.columns"
        case .user: return "person"
        case .drums: return "drum"
        case .bass: return "waveform"
        case .melodic: return "music.note"
        case .experimental: return "sparkles"
        case .live: return "music.mic"
        case .template: return "doc"
        }
    }
}

/// Preset manager for saving/loading
class PresetManager: ObservableObject {
    @Published var presets: [Preset] = []
    @Published var selectedPresetID: UUID?
    @Published var isLoading: Bool = false
    @Published var error: String?
    
    private let fileManager = FileManager.default
    private var presetsDirectory: URL {
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("Presets", isDirectory: true)
    }
    
    init() {
        createPresetsDirectoryIfNeeded()
        loadPresets()
        addFactoryPresets()
    }
    
    // MARK: - Directory Management
    
    private func createPresetsDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: presetsDirectory.path) {
            try? fileManager.createDirectory(at: presetsDirectory, withIntermediateDirectories: true)
        }
    }
    
    // MARK: - Save/Load
    
    func savePreset(_ preset: Preset) {
        var updatedPreset = preset
        updatedPreset.modifiedAt = Date()
        
        // Update existing or add new
        if let index = presets.firstIndex(where: { $0.id == preset.id }) {
            presets[index] = updatedPreset
        } else {
            presets.append(updatedPreset)
        }
        
        // Save to disk
        let fileURL = presetsDirectory.appendingPathComponent("\(preset.id.uuidString).json")
        do {
            let data = try JSONEncoder().encode(updatedPreset)
            try data.write(to: fileURL)
        } catch {
            self.error = "Kunde inte spara preset: \(error.localizedDescription)"
        }
    }
    
    func loadPresets() {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let files = try fileManager.contentsOfDirectory(at: presetsDirectory, includingPropertiesForKeys: nil)
            presets = files.compactMap { url -> Preset? in
                guard url.pathExtension == "json" else { return nil }
                guard let data = try? Data(contentsOf: url) else { return nil }
                return try? JSONDecoder().decode(Preset.self, from: data)
            }
        } catch {
            self.error = "Kunde inte ladda presets: \(error.localizedDescription)"
        }
    }
    
    func deletePreset(_ preset: Preset) {
        presets.removeAll { $0.id == preset.id }
        
        let fileURL = presetsDirectory.appendingPathComponent("\(preset.id.uuidString).json")
        try? fileManager.removeItem(at: fileURL)
    }
    
    func duplicatePreset(_ preset: Preset) -> Preset {
        var newPreset = preset
        newPreset.name = "\(preset.name) (kopia)"
        newPreset.category = .user
        savePreset(newPreset)
        return newPreset
    }
    
    // MARK: - Factory Presets
    
    private func addFactoryPresets() {
        // Only add if no factory presets exist
        guard !presets.contains(where: { $0.category == .factory }) else { return }
        
        // Factory presets would be added here
        // For now, we'll create some basic templates
    }
    
    // MARK: - Filtering
    
    func presets(in category: PresetCategory) -> [Preset] {
        presets.filter { $0.category == category }
    }
    
    func favoritePresets() -> [Preset] {
        presets.filter { $0.isFavorite }
    }
    
    func searchPresets(_ query: String) -> [Preset] {
        guard !query.isEmpty else { return presets }
        let lowercased = query.lowercased()
        return presets.filter {
            $0.name.lowercased().contains(lowercased) ||
            $0.description.lowercased().contains(lowercased) ||
            $0.tags.contains { $0.lowercased().contains(lowercased) }
        }
    }
    
    func toggleFavorite(_ preset: Preset) {
        guard let index = presets.firstIndex(where: { $0.id == preset.id }) else { return }
        presets[index].isFavorite.toggle()
        savePreset(presets[index])
    }
}

// MARK: - Export Formats

enum ExportFormat: String, CaseIterable {
    case json = "JSON"
    case midi = "MIDI"
    case wav = "WAV"
    
    var fileExtension: String {
        rawValue.lowercased()
    }
    
    var icon: String {
        switch self {
        case .json: return "doc.text"
        case .midi: return "pianokeys"
        case .wav: return "waveform"
        }
    }
}
