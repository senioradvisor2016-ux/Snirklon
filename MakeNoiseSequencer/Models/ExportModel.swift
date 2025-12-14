import SwiftUI
import UniformTypeIdentifiers

/// Export system for MIDI, WAV, and JSON formats
class ExportManager: ObservableObject {
    @Published var isExporting: Bool = false
    @Published var exportProgress: Double = 0
    @Published var exportError: String?
    @Published var lastExportURL: URL?
    
    private let fileManager = FileManager.default
    
    private var exportDirectory: URL {
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("Exports", isDirectory: true)
    }
    
    init() {
        createExportDirectoryIfNeeded()
    }
    
    private func createExportDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: exportDirectory.path) {
            try? fileManager.createDirectory(at: exportDirectory, withIntermediateDirectories: true)
        }
    }
    
    // MARK: - Export Functions
    
    func exportToMIDI(patterns: [PatternModel], bpm: Int, name: String) async throws -> URL {
        isExporting = true
        exportProgress = 0
        defer { isExporting = false }
        
        let fileName = "\(name).mid"
        let fileURL = exportDirectory.appendingPathComponent(fileName)
        
        // Generate MIDI data
        let midiData = try generateMIDIData(patterns: patterns, bpm: bpm)
        
        exportProgress = 0.8
        
        // Write to file
        try midiData.write(to: fileURL)
        
        exportProgress = 1.0
        lastExportURL = fileURL
        
        return fileURL
    }
    
    func exportToWAV(patterns: [PatternModel], bpm: Int, name: String, duration: Double) async throws -> URL {
        isExporting = true
        exportProgress = 0
        defer { isExporting = false }
        
        let fileName = "\(name).wav"
        let fileURL = exportDirectory.appendingPathComponent(fileName)
        
        // Generate WAV data (placeholder - would need audio engine integration)
        let wavData = try generateWAVData(patterns: patterns, bpm: bpm, duration: duration)
        
        exportProgress = 0.8
        
        // Write to file
        try wavData.write(to: fileURL)
        
        exportProgress = 1.0
        lastExportURL = fileURL
        
        return fileURL
    }
    
    func exportToJSON(snapshot: SequencerSnapshot, name: String) async throws -> URL {
        isExporting = true
        exportProgress = 0
        defer { isExporting = false }
        
        let fileName = "\(name).json"
        let fileURL = exportDirectory.appendingPathComponent(fileName)
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let jsonData = try encoder.encode(snapshot)
        
        exportProgress = 0.8
        
        try jsonData.write(to: fileURL)
        
        exportProgress = 1.0
        lastExportURL = fileURL
        
        return fileURL
    }
    
    // MARK: - MIDI Generation
    
    private func generateMIDIData(patterns: [PatternModel], bpm: Int) throws -> Data {
        var midiData = Data()
        
        // MIDI Header
        midiData.append(contentsOf: [0x4D, 0x54, 0x68, 0x64]) // "MThd"
        midiData.append(contentsOf: [0x00, 0x00, 0x00, 0x06]) // Header length
        midiData.append(contentsOf: [0x00, 0x01]) // Format type 1
        
        let trackCount = UInt16(patterns.first?.tracks.count ?? 1) + 1 // +1 for tempo track
        midiData.append(contentsOf: withUnsafeBytes(of: trackCount.bigEndian) { Array($0) })
        midiData.append(contentsOf: [0x00, 0x60]) // 96 ticks per quarter note
        
        // Tempo track
        midiData.append(contentsOf: generateTempoTrack(bpm: bpm))
        
        // Generate tracks
        if let pattern = patterns.first {
            for track in pattern.tracks {
                midiData.append(contentsOf: generateMIDITrack(track: track, channel: UInt8(track.midiChannel - 1)))
                exportProgress += 0.7 / Double(pattern.tracks.count)
            }
        }
        
        return midiData
    }
    
    private func generateTempoTrack(bpm: Int) -> [UInt8] {
        var track: [UInt8] = []
        
        // Track header
        track.append(contentsOf: [0x4D, 0x54, 0x72, 0x6B]) // "MTrk"
        
        // Track data
        var trackData: [UInt8] = []
        
        // Tempo meta event
        let microsPerBeat = 60_000_000 / bpm
        trackData.append(contentsOf: [0x00, 0xFF, 0x51, 0x03])
        trackData.append(UInt8((microsPerBeat >> 16) & 0xFF))
        trackData.append(UInt8((microsPerBeat >> 8) & 0xFF))
        trackData.append(UInt8(microsPerBeat & 0xFF))
        
        // End of track
        trackData.append(contentsOf: [0x00, 0xFF, 0x2F, 0x00])
        
        // Track length
        let length = UInt32(trackData.count)
        track.append(contentsOf: withUnsafeBytes(of: length.bigEndian) { Array($0) })
        track.append(contentsOf: trackData)
        
        return track
    }
    
    private func generateMIDITrack(track: TrackModel, channel: UInt8) -> [UInt8] {
        var trackBytes: [UInt8] = []
        
        // Track header
        trackBytes.append(contentsOf: [0x4D, 0x54, 0x72, 0x6B]) // "MTrk"
        
        // Track data
        var trackData: [UInt8] = []
        
        // Track name meta event
        let trackName = Array(track.name.utf8)
        trackData.append(contentsOf: [0x00, 0xFF, 0x03, UInt8(trackName.count)])
        trackData.append(contentsOf: trackName)
        
        // Note events
        let ticksPerStep = 24 // 16th notes at 96 PPQN
        var currentTick = 0
        
        for step in track.steps where step.isOn {
            // Calculate delta time
            let stepTick = step.index * ticksPerStep
            let deltaTime = stepTick - currentTick
            trackData.append(contentsOf: encodeVariableLength(deltaTime))
            
            // Note on
            trackData.append(0x90 | channel)
            trackData.append(UInt8(step.note))
            trackData.append(UInt8(step.velocity))
            
            // Note off (after step length)
            let noteOffDelta = (step.length * ticksPerStep) / 96
            trackData.append(contentsOf: encodeVariableLength(max(1, noteOffDelta)))
            trackData.append(0x80 | channel)
            trackData.append(UInt8(step.note))
            trackData.append(0x00)
            
            currentTick = stepTick + noteOffDelta
        }
        
        // End of track
        trackData.append(contentsOf: [0x00, 0xFF, 0x2F, 0x00])
        
        // Track length
        let length = UInt32(trackData.count)
        trackBytes.append(contentsOf: withUnsafeBytes(of: length.bigEndian) { Array($0) })
        trackBytes.append(contentsOf: trackData)
        
        return trackBytes
    }
    
    private func encodeVariableLength(_ value: Int) -> [UInt8] {
        var result: [UInt8] = []
        var v = value
        
        result.append(UInt8(v & 0x7F))
        v >>= 7
        
        while v > 0 {
            result.insert(UInt8((v & 0x7F) | 0x80), at: 0)
            v >>= 7
        }
        
        return result
    }
    
    // MARK: - WAV Generation (Placeholder)
    
    private func generateWAVData(patterns: [PatternModel], bpm: Int, duration: Double) throws -> Data {
        // This would integrate with an audio engine for real audio rendering
        // For now, return a valid but silent WAV file
        
        let sampleRate: UInt32 = 44100
        let channels: UInt16 = 2
        let bitsPerSample: UInt16 = 16
        let numSamples = UInt32(duration * Double(sampleRate))
        let dataSize = numSamples * UInt32(channels) * UInt32(bitsPerSample / 8)
        let fileSize = 36 + dataSize
        
        var wavData = Data()
        
        // RIFF header
        wavData.append(contentsOf: Array("RIFF".utf8))
        wavData.append(contentsOf: withUnsafeBytes(of: fileSize.littleEndian) { Array($0) })
        wavData.append(contentsOf: Array("WAVE".utf8))
        
        // fmt chunk
        wavData.append(contentsOf: Array("fmt ".utf8))
        wavData.append(contentsOf: withUnsafeBytes(of: UInt32(16).littleEndian) { Array($0) })
        wavData.append(contentsOf: withUnsafeBytes(of: UInt16(1).littleEndian) { Array($0) }) // PCM
        wavData.append(contentsOf: withUnsafeBytes(of: channels.littleEndian) { Array($0) })
        wavData.append(contentsOf: withUnsafeBytes(of: sampleRate.littleEndian) { Array($0) })
        let byteRate = sampleRate * UInt32(channels) * UInt32(bitsPerSample / 8)
        wavData.append(contentsOf: withUnsafeBytes(of: byteRate.littleEndian) { Array($0) })
        let blockAlign = channels * (bitsPerSample / 8)
        wavData.append(contentsOf: withUnsafeBytes(of: blockAlign.littleEndian) { Array($0) })
        wavData.append(contentsOf: withUnsafeBytes(of: bitsPerSample.littleEndian) { Array($0) })
        
        // data chunk
        wavData.append(contentsOf: Array("data".utf8))
        wavData.append(contentsOf: withUnsafeBytes(of: dataSize.littleEndian) { Array($0) })
        
        // Silent audio data
        wavData.append(contentsOf: [UInt8](repeating: 0, count: Int(dataSize)))
        
        return wavData
    }
    
    // MARK: - Import
    
    func importFromJSON(url: URL) throws -> SequencerSnapshot {
        let data = try Data(contentsOf: url)
        let snapshot = try JSONDecoder().decode(SequencerSnapshot.self, from: data)
        return snapshot
    }
}

// MARK: - Export Dialog View

struct ExportDialogView: View {
    @ObservedObject var exportManager: ExportManager
    @Binding var isPresented: Bool
    let patterns: [PatternModel]
    let bpm: Int
    
    @State private var exportName: String = "MyPattern"
    @State private var selectedFormat: ExportFormat = .midi
    @State private var exportDuration: Double = 8 // bars
    
    var body: some View {
        VStack(spacing: DS.Space.l) {
            // Header
            HStack {
                Image(systemName: "square.and.arrow.up")
                    .foregroundStyle(DS.Color.led)
                Text("EXPORTERA")
                    .font(DS.Font.monoM)
                Spacer()
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark")
                        .foregroundStyle(DS.Color.textMuted)
                }
            }
            
            // Name input
            VStack(alignment: .leading, spacing: DS.Space.xs) {
                Text("NAMN")
                    .font(DS.Font.monoXS)
                    .foregroundStyle(DS.Color.textMuted)
                
                TextField("Filnamn", text: $exportName)
                    .font(DS.Font.monoS)
                    .textFieldStyle(.plain)
                    .padding(DS.Space.s)
                    .background(
                        RoundedRectangle(cornerRadius: DS.Radius.s)
                            .fill(DS.Color.surface)
                    )
            }
            
            // Format selector
            VStack(alignment: .leading, spacing: DS.Space.xs) {
                Text("FORMAT")
                    .font(DS.Font.monoXS)
                    .foregroundStyle(DS.Color.textMuted)
                
                HStack(spacing: DS.Space.s) {
                    ForEach(ExportFormat.allCases, id: \.self) { format in
                        formatButton(format)
                    }
                }
            }
            
            // Duration (for WAV)
            if selectedFormat == .wav {
                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text("LÄNGD (TAKTER)")
                        .font(DS.Font.monoXS)
                        .foregroundStyle(DS.Color.textMuted)
                    
                    HStack {
                        Slider(value: $exportDuration, in: 1...64, step: 1)
                        Text("\(Int(exportDuration))")
                            .font(DS.Font.monoS)
                            .frame(width: 30)
                    }
                }
            }
            
            // Progress
            if exportManager.isExporting {
                VStack(spacing: DS.Space.xs) {
                    ProgressView(value: exportManager.exportProgress)
                        .tint(DS.Color.led)
                    Text("Exporterar...")
                        .font(DS.Font.monoXS)
                        .foregroundStyle(DS.Color.textMuted)
                }
            }
            
            // Error
            if let error = exportManager.exportError {
                Text(error)
                    .font(DS.Font.monoXS)
                    .foregroundStyle(.red)
            }
            
            // Export button
            Button(action: startExport) {
                HStack {
                    Image(systemName: selectedFormat.icon)
                    Text("Exportera \(selectedFormat.rawValue)")
                }
                .font(DS.Font.monoS)
                .foregroundStyle(DS.Color.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(DS.Space.m)
                .background(
                    RoundedRectangle(cornerRadius: DS.Radius.m)
                        .fill(DS.Color.led)
                )
            }
            .disabled(exportManager.isExporting || exportName.isEmpty)
            .buttonStyle(.plain)
        }
        .padding(DS.Space.l)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.m)
                .fill(DS.Color.surface)
        )
        .frame(maxWidth: 350)
    }
    
    private func formatButton(_ format: ExportFormat) -> some View {
        Button(action: { selectedFormat = format }) {
            VStack(spacing: DS.Space.xs) {
                Image(systemName: format.icon)
                    .font(.system(size: 20))
                Text(format.rawValue)
                    .font(DS.Font.monoXS)
            }
            .foregroundStyle(selectedFormat == format ? DS.Color.led : DS.Color.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(DS.Space.m)
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.s)
                    .fill(selectedFormat == format ? DS.Color.surface2 : DS.Color.cutout)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func startExport() {
        Task {
            do {
                let snapshot = SequencerSnapshot(
                    patterns: patterns,
                    currentPatternIndex: 0,
                    bpm: bpm,
                    swing: 50
                )
                
                switch selectedFormat {
                case .midi:
                    _ = try await exportManager.exportToMIDI(patterns: patterns, bpm: bpm, name: exportName)
                case .wav:
                    let duration = exportDuration * 4 * 60 / Double(bpm) // Convert bars to seconds
                    _ = try await exportManager.exportToWAV(patterns: patterns, bpm: bpm, name: exportName, duration: duration)
                case .json:
                    _ = try await exportManager.exportToJSON(snapshot: snapshot, name: exportName)
                }
                
                isPresented = false
            } catch {
                exportManager.exportError = error.localizedDescription
            }
        }
    }
}
