import Foundation
@testable import Logue
import Testing

/// Pins the two decisions that made every meeting transcribe as English: which locale the live
/// transcriber ends up with, and whether the post-recording Parakeet pass may touch the transcript.
@Suite("Transcription language selection")
@MainActor
struct TranscriptionLanguageSelectionTests {
    @Test("Apple's POSIX identifier and the system's script-qualified identifier name the same locale")
    func scriptQualifiedIdentifierMatches() {
        #expect(SpeechTranscriberEngine.languagesMatch(
            Locale(identifier: "zh_CN"),
            Locale(identifier: "zh-Hans-CN")
        ))
    }

    @Test("The same language in a different region does not match")
    func differentRegionsDoNotMatch() {
        #expect(!SpeechTranscriberEngine.languagesMatch(
            Locale(identifier: "en_US"),
            Locale(identifier: "en-GB")
        ))
    }

    @Test("A missing script or region is a wildcard")
    func missingComponentsAreWildcards() {
        #expect(SpeechTranscriberEngine.languagesMatch(
            Locale(identifier: "fr"),
            Locale(identifier: "fr-FR")
        ))
    }

    @Test("Different languages do not match")
    func differentLanguagesDoNotMatch() {
        #expect(!SpeechTranscriberEngine.languagesMatch(
            Locale(identifier: "zh-CN"),
            Locale(identifier: "ja-JP")
        ))
    }

    @Test("Parakeet covers European languages but not Chinese or Japanese")
    func batchModelCoverage() {
        #expect(BatchASRModel.version(forLanguageCode: "en") == .v3)
        #expect(BatchASRModel.version(forLanguageCode: "ru") == .v3)
        #expect(BatchASRModel.version(for: Locale(identifier: "zh-Hans-CN")) == nil)
        #expect(BatchASRModel.version(for: Locale(identifier: "ja-JP")) == nil)
    }
}
