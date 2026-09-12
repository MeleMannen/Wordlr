// Run with Tests/check-wiktapi.sh. No app services or live network required.
import Foundation

final class StubProtocol: URLProtocol, @unchecked Sendable {
    static let lock = NSLock()
    static var replies: [(Int, String)] = []
    static var requests: [URLRequest] = []

    static func prepare(_ replies: [(Int, String)]) {
        lock.lock()
        defer { lock.unlock() }
        self.replies = replies
        requests = []
    }

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        Self.lock.lock()
        Self.requests.append(request)
        let reply = Self.replies.isEmpty ? (500, "") : Self.replies.removeFirst()
        Self.lock.unlock()
        if reply.0 == -1 {
            client?.urlProtocol(self, didFailWithError: URLError(.notConnectedToInternet))
            return
        }
        client?.urlProtocol(self, didReceive: HTTPURLResponse(url: request.url!, statusCode: reply.0, httpVersion: nil, headerFields: nil)!, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data(reply.1.utf8))
        client?.urlProtocolDidFinishLoading(self)
    }
    override func stopLoading() {}
}

@main
struct Checks {
    static func main() async throws {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [StubProtocol.self]
        let provider = WiktDefinitionProvider(session: URLSession(configuration: config))
        let valid = #"{"word":"hello","edition":"fr","definitions":[{"pos":"intj","lang_code":"en","senses":[{"glosses":["Salut, bonjour.","Allô."],"tags":["informal"],"examples":[{"text":"Hello!","translation":"Bonjour !","ref":"A citation","roman":"hello"}]}]}]}"#
        StubProtocol.prepare([(200, valid)])
        let result = try await provider.fetch(word: "HELLO", wordLanguage: "en", preferredLanguage: "fr-FR")
        precondition(result?.definitions.first?.senses.first?.explanations.count == 2)
        precondition(result?.definitions.first?.senses.first?.examples?.first?.translation == "Bonjour !")
        precondition(result?.sourceURL?.absoluteString == "https://fr.wiktionary.org/wiki/hello")
        precondition(StubProtocol.requests.first?.url?.absoluteString == "https://api.wiktapi.dev/v1/fr/word/hello/definitions?lang=en")
        precondition(StubProtocol.requests.count == 1)
        precondition(WiktDefinitionProvider.explanationLanguage(for: "pt-BR") == "pt")
        precondition(WiktDefinitionProvider.explanationLanguage(for: "zh-Hant-TW") == "zh")

        let englishEditionFallback = #"{"word":"hello","edition":"en","definitions":[{"pos":"intj","lang_code":"en","senses":[{"glosses":["A greeting."],"examples":[],"tags":[]}]}]}"#

        for code: String? in [nil, "no", "nb", "nn"] {
            StubProtocol.prepare([])
            let result = try await provider.fetch(word: "huset", wordLanguage: code, preferredLanguage: "fr")
            precondition(result == nil && StubProtocol.requests.isEmpty)
        }
        for reply in [(503, valid), (429, valid), (200, "invalid json"), (-1, "")] {
            StubProtocol.prepare([reply])
            let result = try await provider.fetch(word: "hello", wordLanguage: "en", preferredLanguage: "fr")
            precondition(result == nil && StubProtocol.requests.count == 2)
        }
        StubProtocol.prepare([(404, ""), (200, englishEditionFallback)])
        let caseResult = try await provider.fetch(word: "Hello", wordLanguage: "en", preferredLanguage: "fr")
        precondition(caseResult != nil && StubProtocol.requests.count == 2)
        precondition(caseResult?.definitions.allSatisfy { $0.lang_code == "en" } == true)
        precondition(StubProtocol.requests.map(\.url?.absoluteString) == [
            "https://api.wiktapi.dev/v1/fr/word/hello/definitions?lang=en",
            "https://api.wiktapi.dev/v1/en/word/hello/definitions?lang=en"
        ])

        let empty = #"{"word":"hello","edition":"fr","definitions":[{"pos":"noun","lang_code":"en","senses":[{"glosses":["  "]}]}]}"#
        let wrongLanguage = valid.replacingOccurrences(of: "\"lang_code\":\"en\"", with: "\"lang_code\":\"fr\"")
        for body in [empty, wrongLanguage] {
            StubProtocol.prepare([(200, body), (404, "")])
            let result = try await provider.fetch(word: "hello", wordLanguage: "en", preferredLanguage: "fr")
            precondition(result == nil)
        }
        let optionalFields = #"{"word":"hello","edition":"fr","definitions":[{"pos":"intj","lang_code":"en","senses":[{"glosses":["Bonjour."]}]}]}"#
        StubProtocol.prepare([(200, optionalFields)])
        let minimal = try await provider.fetch(word: "hello", wordLanguage: "en", preferredLanguage: "fr")
        precondition(minimal != nil)

        let url = WiktDefinitionProvider.requestURL(word: "café?#", edition: "fr", wordLanguage: "en")!
        let parts = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        precondition(parts.path == "/v1/fr/word/café?#/definitions")
        precondition(parts.queryItems == [URLQueryItem(name: "lang", value: "en")])
        let task = Task {
            withUnsafeCurrentTask { $0?.cancel() }
            return try await provider.fetch(word: "hello", wordLanguage: "en", preferredLanguage: "fr")
        }
        do {
            _ = try await task.value
            preconditionFailure("Cancellation must propagate")
        } catch is CancellationError {}
        print("All WiktAPI provider checks passed.")
    }
}
