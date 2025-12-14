import SwiftUI
import Combine

/// Model för att hantera audio/MIDI latency
@MainActor
class LatencyMonitor: ObservableObject {
    @Published var audioLatencyMs: Double = 0
    @Published var midiLatencyMs: Double = 0
    @Published var isConnected: Bool = false
    @Published var deviceCount: Int = 0
    
    private var updateTimer: Timer?
    
    init() {
        startMonitoring()
    }
    
    func startMonitoring() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateLatency()
            }
        }
    }
    
    func stopMonitoring() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    private func updateLatency() {
        // Simulerad latency för demo - i verkligheten skulle detta läsas från AVAudioSession/CoreMIDI
        #if targetEnvironment(simulator)
        audioLatencyMs = Double.random(in: 8...15)
        midiLatencyMs = Double.random(in: 1...5)
        deviceCount = 2
        isConnected = true
        #else
        // Faktisk implementation skulle använda:
        // - AVAudioSession.sharedInstance().outputLatency för audio
        // - CoreMIDI endpoints för MIDI-latency
        audioLatencyMs = 10.0 // Placeholder
        midiLatencyMs = 2.0 // Placeholder
        deviceCount = 0
        isConnected = false
        #endif
    }
    
    var totalLatencyMs: Double {
        audioLatencyMs + midiLatencyMs
    }
    
    var latencyStatus: LatencyStatus {
        if totalLatencyMs < 10 {
            return .excellent
        } else if totalLatencyMs < 20 {
            return .good
        } else if totalLatencyMs < 40 {
            return .acceptable
        } else {
            return .poor
        }
    }
    
    enum LatencyStatus {
        case excellent, good, acceptable, poor
        
        var color: Color {
            switch self {
            case .excellent: return .green
            case .good: return .mint
            case .acceptable: return .yellow
            case .poor: return .red
            }
        }
        
        var label: String {
            switch self {
            case .excellent: return "Utmärkt"
            case .good: return "Bra"
            case .acceptable: return "OK"
            case .poor: return "Hög"
            }
        }
    }
}

/// Kompakt latency-indikator för transport bar
struct LatencyIndicator: View {
    @StateObject private var monitor = LatencyMonitor()
    @State private var showDetails: Bool = false
    
    var body: some View {
        Button(action: { showDetails.toggle() }) {
            HStack(spacing: DS.Space.xxs) {
                // Status dot
                Circle()
                    .fill(monitor.latencyStatus.color)
                    .frame(width: 6, height: 6)
                
                // Latency value
                Text("\(Int(monitor.totalLatencyMs))ms")
                    .font(DS.Font.monoXS)
                    .foregroundStyle(DS.Color.textMuted)
            }
            .padding(.horizontal, DS.Space.xs)
            .padding(.vertical, DS.Space.xxs)
            .background(DS.Color.surface)
            .cornerRadius(DS.Radius.s)
        }
        .buttonStyle(.plain)
        .popover(isPresented: $showDetails, arrowEdge: .bottom) {
            LatencyDetailView(monitor: monitor)
        }
        .accessibilityLabel("Latency \(Int(monitor.totalLatencyMs)) millisekunder, \(monitor.latencyStatus.label)")
    }
}

/// Detaljerad latency-vy
struct LatencyDetailView: View {
    @ObservedObject var monitor: LatencyMonitor
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.m) {
            // Header
            HStack {
                Text("LATENCY")
                    .font(DS.Font.monoS)
                    .foregroundStyle(DS.Color.textSecondary)
                
                Spacer()
                
                // Status badge
                HStack(spacing: DS.Space.xxs) {
                    Circle()
                        .fill(monitor.latencyStatus.color)
                        .frame(width: 8, height: 8)
                    Text(monitor.latencyStatus.label)
                        .font(DS.Font.monoXS)
                        .foregroundStyle(monitor.latencyStatus.color)
                }
                .padding(.horizontal, DS.Space.xs)
                .padding(.vertical, 2)
                .background(monitor.latencyStatus.color.opacity(0.15))
                .cornerRadius(4)
            }
            
            Divider()
                .background(DS.Color.etchedLine)
            
            // Breakdown
            VStack(spacing: DS.Space.s) {
                latencyRow(
                    label: "Audio",
                    value: monitor.audioLatencyMs,
                    icon: "speaker.wave.2"
                )
                
                latencyRow(
                    label: "MIDI",
                    value: monitor.midiLatencyMs,
                    icon: "pianokeys"
                )
                
                Divider()
                    .background(DS.Color.etchedLine)
                
                latencyRow(
                    label: "Total",
                    value: monitor.totalLatencyMs,
                    icon: "clock",
                    isTotal: true
                )
            }
            
            // Connection status
            Divider()
                .background(DS.Color.etchedLine)
            
            HStack {
                Image(systemName: monitor.isConnected ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(monitor.isConnected ? .green : .red)
                    .font(.system(size: 14))
                
                VStack(alignment: .leading, spacing: 1) {
                    Text(monitor.isConnected ? "Ansluten" : "Ej ansluten")
                        .font(DS.Font.monoXS)
                        .foregroundStyle(DS.Color.textPrimary)
                    
                    if monitor.deviceCount > 0 {
                        Text("\(monitor.deviceCount) enheter")
                            .font(DS.Font.monoXS)
                            .foregroundStyle(DS.Color.textMuted)
                    }
                }
                
                Spacer()
            }
            
            // Tips
            if monitor.latencyStatus == .poor {
                HStack(spacing: DS.Space.xs) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(.yellow)
                        .font(.system(size: 12))
                    
                    Text("Prova att minska buffer-storleken i ljudinställningarna")
                        .font(DS.Font.monoXS)
                        .foregroundStyle(DS.Color.textMuted)
                }
                .padding(DS.Space.xs)
                .background(DS.Color.surface2)
                .cornerRadius(DS.Radius.s)
            }
        }
        .padding(DS.Space.m)
        .frame(width: 220)
        .background(DS.Color.surface)
    }
    
    private func latencyRow(label: String, value: Double, icon: String, isTotal: Bool = false) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(DS.Color.textMuted)
                .frame(width: 20)
            
            Text(label)
                .font(isTotal ? DS.Font.monoS : DS.Font.monoXS)
                .foregroundStyle(isTotal ? DS.Color.textPrimary : DS.Color.textSecondary)
            
            Spacer()
            
            Text(String(format: "%.1f ms", value))
                .font(isTotal ? DS.Font.monoS : DS.Font.monoXS)
                .foregroundStyle(isTotal ? DS.Color.textPrimary : DS.Color.textMuted)
        }
    }
}

/// Inline MIDI/CV status indikator
struct ConnectionStatusIndicator: View {
    @EnvironmentObject var store: SequencerStore
    
    var body: some View {
        HStack(spacing: DS.Space.xs) {
            // MIDI status
            HStack(spacing: 2) {
                Image(systemName: "pianokeys")
                    .font(.system(size: 10))
                Circle()
                    .fill(Color.green)
                    .frame(width: 4, height: 4)
            }
            .foregroundStyle(DS.Color.textMuted)
            
            // CV status (if DC-coupled interface)
            if store.selectedInterface.isDCCoupled {
                HStack(spacing: 2) {
                    Image(systemName: "bolt")
                        .font(.system(size: 10))
                    Circle()
                        .fill(DS.Color.led)
                        .frame(width: 4, height: 4)
                }
                .foregroundStyle(DS.Color.textMuted)
            }
        }
        .padding(.horizontal, DS.Space.xs)
        .padding(.vertical, 2)
        .background(DS.Color.surface)
        .cornerRadius(4)
    }
}
