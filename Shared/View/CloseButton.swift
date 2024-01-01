import SwiftUI

struct CloseButton: View {
    var action: () -> Void = {}
    
    var body: some View {
        HStack {
            Spacer()
            
            Button("Close", systemImage: "xmark.circle.fill", role: .cancel, action: action)
                .font(.title2)
                .foregroundStyle(.secondary, Color(uiColor: .secondarySystemFill))
                .labelStyle(.iconOnly)
        }
        .padding([.top, .trailing], 8)
    }
}

#Preview {
    CloseButton()
}
