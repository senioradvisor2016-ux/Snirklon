import SwiftUI

struct SelectionModel: Equatable {
    var selectedTrackID: UUID?
    var selectedStepIDs: Set<UUID>
    var showInspector: Bool
    
    init(
        selectedTrackID: UUID? = nil,
        selectedStepIDs: Set<UUID> = [],
        showInspector: Bool = false
    ) {
        self.selectedTrackID = selectedTrackID
        self.selectedStepIDs = selectedStepIDs
        self.showInspector = showInspector
    }
    
    var hasSelection: Bool {
        !selectedStepIDs.isEmpty
    }
    
    var singleStepSelected: Bool {
        selectedStepIDs.count == 1
    }
    
    mutating func selectStep(_ stepID: UUID) {
        selectedStepIDs = [stepID]
    }
    
    mutating func toggleStepSelection(_ stepID: UUID) {
        if selectedStepIDs.contains(stepID) {
            selectedStepIDs.remove(stepID)
        } else {
            selectedStepIDs.insert(stepID)
        }
    }
    
    mutating func addToSelection(_ stepID: UUID) {
        selectedStepIDs.insert(stepID)
    }
    
    mutating func clearSelection() {
        selectedStepIDs.removeAll()
    }
}
