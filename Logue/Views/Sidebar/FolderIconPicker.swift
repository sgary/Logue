import SwiftUI

/// A popover grid for picking an SF Symbol icon for a space.
struct SpaceIconPicker: View {
    let currentIcon: String?
    let onSelect: (String?) -> Void

    @State private var searchText = ""

    private var filteredIcons: [(String, [String])] {
        if searchText.isEmpty {
            return Self.iconGroups
        }
        let query = searchText.lowercased()
        return Self.iconGroups.compactMap { group in
            let filtered = group.1.filter { $0.localizedCaseInsensitiveContains(query) }
            return filtered.isEmpty ? nil : (group.0, filtered)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                    .font(.caption)
                TextField("搜索图标…", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.callout)
                    .accessibilityLabel("搜索图标")
                    .accessibilityHint("输入以筛选可用的空间图标")
            }
            .padding(8)
            .background(Color.primary.opacity(AppThemeConstants.opacityLight), in: RoundedRectangle(cornerRadius: 6))
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, 8)

            Divider()

            // Grid
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    // Reset to default
                    Button {
                        onSelect(nil)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "folder")
                                .frame(width: 20)
                            Text("默认（文件夹）")
                                .font(.caption)
                            Spacer()
                            if currentIcon == nil {
                                Image(systemName: "checkmark")
                                    .font(.caption2.bold())
                                    .foregroundStyle(AppThemeConstants.brandPrimary)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("默认空间图标")
                    .accessibilityHint("将空间图标重置为默认")
                    .accessibilityAddTraits(currentIcon == nil ? .isSelected : [])

                    Divider().padding(.horizontal, 12)

                    ForEach(filteredIcons, id: \.0) { group, icons in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(group)
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 12)

                            LazyVGrid(columns: Array(repeating: GridItem(.fixed(32), spacing: 4), count: 8), spacing: 4) {
                                ForEach(icons, id: \.self) { icon in
                                    Button {
                                        onSelect(icon)
                                    } label: {
                                        Image(systemName: icon)
                                            .font(.system(size: 14))
                                            .frame(width: 32, height: 32)
                                            .background(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .fill(currentIcon == icon ? AppThemeConstants.brandPrimary
                                                        .opacity(AppThemeConstants.opacityMedium) : Color.clear)
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .strokeBorder(currentIcon == icon ? AppThemeConstants.brandPrimary : Color.clear, lineWidth: 1.5)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel(icon)
                                    .accessibilityHint("将空间图标设为 \(icon)")
                                    .accessibilityAddTraits(currentIcon == icon ? .isSelected : [])
                                    .help(icon)
                                }
                            }
                            .padding(.horizontal, 12)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .frame(width: 300, height: 360)
    }

    // MARK: - Icon Library

    static let iconGroups: [(String, [String])] = [
        ("通用", [
            "folder", "folder.fill", "tray", "tray.full", "archivebox",
            "doc", "doc.text", "note.text", "list.bullet", "bookmark",
            "tag", "flag", "star", "heart", "bell",
            "pin", "paperclip", "link",
        ]),
        ("商务", [
            "building.2", "building.columns", "banknote", "creditcard",
            "chart.bar", "chart.line.uptrend.xyaxis", "chart.pie",
            "briefcase", "case", "dollarsign.circle",
            "percent", "cart", "bag", "storefront",
        ]),
        ("人物", [
            "person", "person.2", "person.3", "person.badge.plus",
            "person.crop.circle", "figure.stand",
            "graduationcap", "brain.head.profile",
        ]),
        ("技术", [
            "terminal", "chevron.left.forwardslash.chevron.right", "server.rack",
            "cpu", "memorychip", "antenna.radiowaves.left.and.right",
            "wifi", "globe", "network", "icloud",
            "desktopcomputer", "laptopcomputer", "iphone",
        ]),
        ("沟通", [
            "envelope", "phone", "message", "bubble.left.and.bubble.right",
            "video", "mic", "waveform", "speaker.wave.2",
        ]),
        ("安全与法律", [
            "lock", "lock.shield", "key", "shield.checkered",
            "hand.raised", "eye.slash", "faceid",
            "exclamationmark.triangle", "checkmark.shield",
        ]),
        ("医疗", [
            "cross.case", "heart.text.square", "stethoscope",
            "pills", "syringe", "bandage",
            "waveform.path.ecg", "brain",
        ]),
        ("创意", [
            "paintbrush", "pencil", "scribble", "photo",
            "camera", "film", "music.note", "theatermasks",
            "lightbulb", "sparkles", "wand.and.stars",
        ]),
        ("组织", [
            "calendar", "clock", "hourglass",
            "map", "location", "mappin.and.ellipse",
            "scope", "target", "flag.checkered",
            "crown", "rosette",
        ]),
    ]
}
