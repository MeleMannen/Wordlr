Run `Tests/check-wiktapi.sh` from the repository root. This compiles the production WiktAPI model and provider with a URLProtocol stub, without launching the app or contacting external services.

The checks cover the two language axes, regional language codes, lowercase normalization, the English-edition WiktAPI fallback, percent encoding, optional response fields, preservation of examples, missing/empty/wrong-language definitions, HTTP errors, malformed JSON, offline requests, Norwegian bypass, and cancellation. A nil provider result tells `LocalizedWordDefinitionView` to use the existing language-specific view and its provider chain.

WiktAPI's `edition` is the explanation language; `lang` is the word language. For example, a French-speaking user looking up the English word “hello” uses `/v1/fr/word/hello/definitions?lang=en`.

If that language is unavailable, the provider requests `/v1/en/word/hello/definitions` and accepts English definitions before moving to the older dictionary providers.

The definitions endpoint supplies parts of speech, glosses, usage tags and examples (including translations and references where available). It does not supply pronunciation/audio, etymology or synonym tables. The view presents the returned definition fields and links to the source entry.
