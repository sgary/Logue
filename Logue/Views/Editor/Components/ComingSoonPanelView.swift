import SwiftUI

struct ComingSoonPanelView: View {
    let tool: EditorTool

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: tool.icon)
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text(tool.displayName)
                .font(.headline)
            Text("即将推出")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppThemeConstants.surfaceBackground)
    }
}
