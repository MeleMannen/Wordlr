//
//  DefinitionManager.swift
//  Wordle
//
//  Created by Kristoffer Melen on 16/07/2025.
//

import Foundation
import AVFoundation

enum DefinitionFetchResult<Value> {
    case success(Value)
    case notFound
    case networkError
}

final class DefinitionManager: NSObject, ObservableObject {
    private var audioPlayer: AVPlayer?
    
    
    func getEnglishDefinition(for word: String, completion: @escaping (DefinitionFetchResult<[EnglishDefinition]>) -> Void) {
        WordleDataManager.shared.fetchEnglishDefinition(for: word) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    func playAudio(from source: String) {
        self.audioPlayer?.pause()
        self.audioPlayer = nil
        
        guard let url = URL(string: source) else { return }
        self.audioPlayer = AVPlayer(url: url)
        self.audioPlayer?.play()
    }
    
    deinit {
        self.audioPlayer?.pause()
        self.audioPlayer = nil
    }
    
    
    func getDefinition(for word: String, completion: @escaping (DefinitionFetchResult<[ProcessedWord]>) -> Void) {
        WordleDataManager.shared.fetchNorwegianDefinition(for: word) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
	
	func getSpanishDefinition(for word: String, completion: @escaping (DefinitionFetchResult<SpanishDefinition>) -> Void) {
		WordleDataManager.shared.fetchSpanishDefinition(for: word) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
	}
    
    
}
