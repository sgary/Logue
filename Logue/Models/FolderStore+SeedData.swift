import Foundation

// MARK: - Seed Space IDs (shared across Document/Meeting seed data)

// swiftlint:disable force_unwrapping

/// Deterministic UUIDs so documents and meetings can reference their spaces.
enum SeedSpaceID {
    // Top-level spaces
    static let work = UUID(uuidString: "A0000001-0000-0000-0000-000000000001")!
    static let school = UUID(uuidString: "A0000001-0000-0000-0000-000000000002")!
    static let personal = UUID(uuidString: "A0000001-0000-0000-0000-000000000003")!

    // Work sub-spaces
    static let clientProjects = UUID(uuidString: "A0000001-0000-0000-0000-000000000011")!
    static let `internal` = UUID(uuidString: "A0000001-0000-0000-0000-000000000012")!

    // School sub-spaces
    static let cs301 = UUID(uuidString: "A0000001-0000-0000-0000-000000000021")!
    static let businessEthics = UUID(uuidString: "A0000001-0000-0000-0000-000000000022")!

    // Standalone persona spaces
    static let legal = UUID(uuidString: "A0000001-0000-0000-0000-000000000004")!
    static let healthcare = UUID(uuidString: "A0000001-0000-0000-0000-000000000005")!
}

// MARK: - Seed Spaces

extension SpaceStore {
    static func makeSeedSpaces() -> [Space] {
        [
            // Top-level
            Space(id: SeedSpaceID.work, name: "工作", sortOrder: 0, icon: "briefcase.fill", isExpanded: true),
            Space(id: SeedSpaceID.school, name: "学校", sortOrder: 1, icon: "book.closed.fill", isExpanded: true),
            Space(id: SeedSpaceID.personal, name: "个人", sortOrder: 2, icon: "house.fill"),

            // Work children
            Space(id: SeedSpaceID.clientProjects, name: "客户项目", parentID: SeedSpaceID.work, sortOrder: 0, icon: "person.2.circle"),
            Space(id: SeedSpaceID.internal, name: "内部", parentID: SeedSpaceID.work, sortOrder: 1, icon: "lock.shield"),

            // School children
            Space(id: SeedSpaceID.cs301, name: "CS 301", parentID: SeedSpaceID.school, sortOrder: 0, icon: "terminal"),
            Space(id: SeedSpaceID.businessEthics, name: "商业伦理", parentID: SeedSpaceID.school, sortOrder: 1, icon: "building.columns"),

            // Standalone persona spaces
            Space(id: SeedSpaceID.legal, name: "法务", sortOrder: 3, icon: "scalemass.fill"),
            Space(id: SeedSpaceID.healthcare, name: "医疗", sortOrder: 4, icon: "cross.case.fill"),
        ]
    }
}

// swiftlint:enable force_unwrapping
