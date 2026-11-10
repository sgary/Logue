import AppKit

/// A user-customizable keyboard shortcut represented by a virtual key code and modifier flags.
struct CustomShortcut: Equatable {
    var keyCode: UInt16
    var modifierFlags: UInt // NSEvent.ModifierFlags.rawValue

    // MARK: - Defaults

    /// Cmd + Shift + W
    static let defaultCommandCenter = CustomShortcut(keyCode: 13, modifierFlags: NSEvent.ModifierFlags([.command, .shift]).rawValue)

    // MARK: - Derived Properties

    var flags: NSEvent.ModifierFlags {
        NSEvent.ModifierFlags(rawValue: modifierFlags)
    }

    /// Human-readable display string, e.g. "⌘⇧G".
    var displayString: String {
        var parts: [String] = []
        if flags.contains(.control) {
            parts.append("⌃")
        }
        if flags.contains(.option) {
            parts.append("⌥")
        }
        if flags.contains(.shift) {
            parts.append("⇧")
        }
        if flags.contains(.command) {
            parts.append("⌘")
        }
        parts.append(Self.displayKeyName(for: keyCode))
        return parts.joined()
    }

    /// Key names as macOS draws them, used only for display.
    ///
    /// Kept apart from `keyName(for:)`, which also derives `keyEquivalent`; turning
    /// "Return" into "↩" there would change what a menu item receives.
    private static func displayKeyName(for keyCode: UInt16) -> String {
        switch keyCode {
        case 36: "↩"
        case 48: "⇥"
        case 49: "空格"
        case 51: "⌫"
        case 53: "⎋"
        case 123: "←"
        case 124: "→"
        case 125: "↓"
        case 126: "↑"
        default: keyName(for: keyCode)
        }
    }

    /// Single-character key equivalent for NSMenuItem (uppercased letter).
    var keyEquivalent: String {
        let name = Self.keyName(for: keyCode)
        if name.count == 1 {
            return name
        }
        // Special keys
        switch keyCode {
        case 49: return " " // Space
        default: return ""
        }
    }

    /// Modifier mask suitable for NSMenuItem.
    var menuModifierMask: NSEvent.ModifierFlags {
        flags.intersection(.deviceIndependentFlagsMask)
    }

    /// Returns `true` when `event` matches this shortcut (device-independent comparison).
    func matches(_ event: NSEvent) -> Bool {
        let eventMods = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        let shortcutMods = flags.intersection(.deviceIndependentFlagsMask)
        return event.keyCode == keyCode && eventMods == shortcutMods
    }

    // MARK: - Key Name Mapping

    private static let keyNameMap: [UInt16: String] = [
        0: "A", 1: "S", 2: "D", 3: "F", 4: "H", 5: "G", 6: "Z", 7: "X",
        8: "C", 9: "V", 11: "B", 12: "Q", 13: "W", 14: "E", 15: "R",
        16: "Y", 17: "T", 18: "1", 19: "2", 20: "3", 21: "4", 22: "6",
        23: "5", 24: "=", 25: "9", 26: "7", 27: "-", 28: "8", 29: "0",
        30: "]", 31: "O", 32: "U", 33: "[", 34: "I", 35: "P", 36: "Return",
        37: "L", 38: "J", 39: "'", 40: "K", 41: ";", 42: "\\", 43: ",",
        44: "/", 45: "N", 46: "M", 47: ".", 48: "Tab", 49: "Space",
        50: "`", 51: "Delete", 53: "Esc",
        96: "F5", 97: "F6", 98: "F7", 99: "F3", 100: "F8", 101: "F9",
        103: "F11", 105: "F13", 109: "F10", 111: "F12", 118: "F4",
        120: "F2", 122: "F1",
        123: "Left", 124: "Right", 125: "Down", 126: "Up",
    ]

    static func keyName(for keyCode: UInt16) -> String {
        keyNameMap[keyCode] ?? "Key\(keyCode)"
    }
}
