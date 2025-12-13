import SwiftUI

@main
struct MakeNoiseSequencerApp: App {
    @StateObject private var store = SequencerStore()
    
    var body: some Scene {
        WindowGroup {
            AppShellView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
        }
    }
}
