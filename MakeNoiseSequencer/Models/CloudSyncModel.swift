import SwiftUI
import Combine

/// Cloud sync system for iCloud and cross-device synchronization
class CloudSyncManager: ObservableObject {
    @Published var isSyncing: Bool = false
    @Published var lastSyncDate: Date?
    @Published var syncStatus: SyncStatus = .idle
    @Published var syncError: String?
    @Published var cloudPresets: [CloudPreset] = []
    @Published var isCloudEnabled: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private let userDefaults = NSUbiquitousKeyValueStore.default
    
    init() {
        setupCloudSync()
        checkCloudAvailability()
    }
    
    // MARK: - Setup
    
    private func setupCloudSync() {
        // Listen for iCloud changes
        NotificationCenter.default.publisher(for: NSUbiquitousKeyValueStore.didChangeExternallyNotification)
            .sink { [weak self] notification in
                self?.handleCloudChange(notification)
            }
            .store(in: &cancellables)
        
        // Initial sync
        userDefaults.synchronize()
    }
    
    private func checkCloudAvailability() {
        isCloudEnabled = FileManager.default.ubiquityIdentityToken != nil
    }
    
    // MARK: - Sync Operations
    
    func syncNow() {
        guard isCloudEnabled else {
            syncError = "iCloud är inte aktiverat"
            return
        }
        
        isSyncing = true
        syncStatus = .syncing
        
        // Trigger sync
        userDefaults.synchronize()
        
        // Fetch cloud presets
        fetchCloudPresets()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.isSyncing = false
            self?.syncStatus = .synced
            self?.lastSyncDate = Date()
        }
    }
    
    func uploadPreset(_ preset: Preset) {
        guard isCloudEnabled else { return }
        
        do {
            let data = try JSONEncoder().encode(preset)
            let key = "preset_\(preset.id.uuidString)"
            userDefaults.set(data, forKey: key)
            userDefaults.synchronize()
            
            // Add to index
            var presetIndex = getPresetIndex()
            if !presetIndex.contains(preset.id.uuidString) {
                presetIndex.append(preset.id.uuidString)
                userDefaults.set(presetIndex, forKey: "presetIndex")
            }
            
        } catch {
            syncError = "Kunde inte ladda upp preset: \(error.localizedDescription)"
        }
    }
    
    func downloadPreset(id: String) -> Preset? {
        guard isCloudEnabled else { return nil }
        
        let key = "preset_\(id)"
        guard let data = userDefaults.data(forKey: key) else { return nil }
        
        return try? JSONDecoder().decode(Preset.self, from: data)
    }
    
    func deleteCloudPreset(id: String) {
        guard isCloudEnabled else { return }
        
        let key = "preset_\(id)"
        userDefaults.removeObject(forKey: key)
        
        var presetIndex = getPresetIndex()
        presetIndex.removeAll { $0 == id }
        userDefaults.set(presetIndex, forKey: "presetIndex")
        
        userDefaults.synchronize()
        fetchCloudPresets()
    }
    
    // MARK: - Cloud Presets
    
    private func fetchCloudPresets() {
        let index = getPresetIndex()
        
        cloudPresets = index.compactMap { id -> CloudPreset? in
            guard let preset = downloadPreset(id: id) else { return nil }
            return CloudPreset(
                id: id,
                name: preset.name,
                category: preset.category,
                modifiedAt: preset.modifiedAt,
                isDownloaded: true
            )
        }
    }
    
    private func getPresetIndex() -> [String] {
        userDefaults.array(forKey: "presetIndex") as? [String] ?? []
    }
    
    // MARK: - Change Handling
    
    private func handleCloudChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reason = userInfo[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int else {
            return
        }
        
        switch reason {
        case NSUbiquitousKeyValueStoreServerChange,
             NSUbiquitousKeyValueStoreInitialSyncChange:
            // Data changed from server
            DispatchQueue.main.async { [weak self] in
                self?.fetchCloudPresets()
                self?.lastSyncDate = Date()
                self?.syncStatus = .synced
            }
            
        case NSUbiquitousKeyValueStoreQuotaViolationChange:
            DispatchQueue.main.async { [weak self] in
                self?.syncError = "iCloud-lagring är full"
                self?.syncStatus = .error
            }
            
        case NSUbiquitousKeyValueStoreAccountChange:
            DispatchQueue.main.async { [weak self] in
                self?.checkCloudAvailability()
                self?.fetchCloudPresets()
            }
            
        default:
            break
        }
    }
    
    // MARK: - Settings Sync
    
    func syncSettings(_ settings: AppSettings) {
        guard isCloudEnabled else { return }
        
        if let data = try? JSONEncoder().encode(settings) {
            userDefaults.set(data, forKey: "appSettings")
            userDefaults.synchronize()
        }
    }
    
    func loadCloudSettings() -> AppSettings? {
        guard isCloudEnabled,
              let data = userDefaults.data(forKey: "appSettings") else {
            return nil
        }
        return try? JSONDecoder().decode(AppSettings.self, from: data)
    }
}

// MARK: - Data Types

enum SyncStatus: String {
    case idle = "Väntar"
    case syncing = "Synkroniserar..."
    case synced = "Synkroniserad"
    case error = "Fel"
    case offline = "Offline"
    
    var icon: String {
        switch self {
        case .idle: return "cloud"
        case .syncing: return "arrow.triangle.2.circlepath"
        case .synced: return "checkmark.icloud"
        case .error: return "exclamationmark.icloud"
        case .offline: return "icloud.slash"
        }
    }
    
    var color: Color {
        switch self {
        case .idle: return DS.Color.textMuted
        case .syncing: return DS.Color.led
        case .synced: return .green
        case .error: return .red
        case .offline: return DS.Color.textMuted
        }
    }
}

struct CloudPreset: Identifiable {
    let id: String
    let name: String
    let category: PresetCategory
    let modifiedAt: Date
    var isDownloaded: Bool
}

struct AppSettings: Codable {
    var bpm: Int
    var swing: Int
    var selectedInterfaceID: String
    var tooltipsEnabled: Bool
    var themeID: String
}

// MARK: - Cloud Sync View

struct CloudSyncSettingsView: View {
    @ObservedObject var cloudManager: CloudSyncManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.l) {
            // Header
            HStack {
                Image(systemName: "icloud")
                    .foregroundStyle(DS.Color.led)
                Text("iCLOUD SYNC")
                    .font(DS.Font.monoS)
                    .foregroundStyle(DS.Color.textSecondary)
            }
            
            // Status
            statusSection
            
            // Cloud presets
            if cloudManager.isCloudEnabled {
                cloudPresetsSection
            }
            
            // Error
            if let error = cloudManager.syncError {
                Text(error)
                    .font(DS.Font.monoXS)
                    .foregroundStyle(.red)
                    .padding(DS.Space.s)
                    .background(
                        RoundedRectangle(cornerRadius: DS.Radius.s)
                            .fill(Color.red.opacity(0.1))
                    )
            }
        }
        .padding(DS.Space.m)
    }
    
    private var statusSection: some View {
        HStack {
            Image(systemName: cloudManager.syncStatus.icon)
                .foregroundStyle(cloudManager.syncStatus.color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(cloudManager.isCloudEnabled ? "iCloud aktivt" : "iCloud inaktivt")
                    .font(DS.Font.monoS)
                    .foregroundStyle(DS.Color.textPrimary)
                
                if let lastSync = cloudManager.lastSyncDate {
                    Text("Senast synkad: \(lastSync.formatted())")
                        .font(DS.Font.monoXS)
                        .foregroundStyle(DS.Color.textMuted)
                }
            }
            
            Spacer()
            
            Button(action: { cloudManager.syncNow() }) {
                if cloudManager.isSyncing {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "arrow.clockwise")
                }
            }
            .disabled(cloudManager.isSyncing || !cloudManager.isCloudEnabled)
            .buttonStyle(.plain)
        }
        .padding(DS.Space.m)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.m)
                .fill(DS.Color.surface)
        )
    }
    
    private var cloudPresetsSection: some View {
        VStack(alignment: .leading, spacing: DS.Space.s) {
            Text("PRESETS I MOLNET")
                .font(DS.Font.monoXS)
                .foregroundStyle(DS.Color.textMuted)
            
            if cloudManager.cloudPresets.isEmpty {
                Text("Inga presets i molnet")
                    .font(DS.Font.monoXS)
                    .foregroundStyle(DS.Color.textMuted)
                    .frame(maxWidth: .infinity)
                    .padding(DS.Space.m)
                    .background(
                        RoundedRectangle(cornerRadius: DS.Radius.s)
                            .fill(DS.Color.surface)
                    )
            } else {
                ForEach(cloudManager.cloudPresets) { preset in
                    cloudPresetRow(preset)
                }
            }
        }
    }
    
    private func cloudPresetRow(_ preset: CloudPreset) -> some View {
        HStack {
            Image(systemName: preset.category.icon)
                .foregroundStyle(DS.Color.textSecondary)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(preset.name)
                    .font(DS.Font.monoS)
                    .foregroundStyle(DS.Color.textPrimary)
                
                Text(preset.modifiedAt.formatted())
                    .font(DS.Font.monoXS)
                    .foregroundStyle(DS.Color.textMuted)
            }
            
            Spacer()
            
            Button(action: { cloudManager.deleteCloudPreset(id: preset.id) }) {
                Image(systemName: "trash")
                    .foregroundStyle(.red.opacity(0.7))
            }
            .buttonStyle(.plain)
        }
        .padding(DS.Space.s)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.s)
                .fill(DS.Color.surface)
        )
    }
}
