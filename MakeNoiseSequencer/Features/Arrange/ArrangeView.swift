import SwiftUI

// Placeholder for Arrange view - future implementation
struct ArrangeView: View {
    var body: some View {
        ZStack {
            PanelStyles.panelBackground()
            
            VStack(spacing: DS.Space.m) {
                Text("ARRANGE")
                    .font(DS.Font.monoL)
                    .foregroundStyle(DS.Color.textPrimary)
                
                Text("Coming soon")
                    .font(DS.Font.monoS)
                    .foregroundStyle(DS.Color.textMuted)
            }
        }
    }
}
