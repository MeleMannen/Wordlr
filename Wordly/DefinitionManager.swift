//
//  DefinitionManager.swift
//  Wordle
//
//  Created by Kristoffer Melen on 16/07/2025.
//

import Foundation
import AVFoundation

final class DefinitionManager: NSObject, ObservableObject {
    private var audioPlayer: AVPlayer?
    
    
    func getEnglishDefinition(for word: String, completion: @escaping ([EnglishDefinition]) -> Void) {
        WordleDataManager.shared.fetchEnglishDefinition(for: word) { definition in
            guard let definition = definition else {
                completion([])
                return
            }
            DispatchQueue.main.async {
                completion(definition)
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
    
    
    func getDefinition(for word: String, completion: @escaping ([ProcessedWord]) -> Void) {
        var processedWords: [ProcessedWord] = []
        WordleDataManager.shared.fetchArticleIDs(for: word) { articleIDs in
            guard let articleIDs = articleIDs else {
                DispatchQueue.main.async {
                    completion(processedWords)
                }
                return
            }
            
            let dispatchGroup = DispatchGroup()
            
            for articleID in articleIDs {
                dispatchGroup.enter()
                WordleDataManager.shared.fetchArticleDetails(articleID: articleID) { fetchedProcessedWord in
                    if let fetchedProcessedWord {
                        DispatchQueue.main.async {
                            processedWords.append(fetchedProcessedWord)
                        }
                    }
                    dispatchGroup.leave()
                }
                
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(processedWords)
                
            }
        }
    }
	
	func getSpanishDefinition(for word: String, completion: @escaping (SpanishDefinition?) -> Void) {
		WordleDataManager.shared.fetchSpanishDefinition(for: word) { definition in
			guard let definition = definition else {
				completion(nil)
				return
			}
			DispatchQueue.main.async {
				completion(definition)
			}
		}
	}
    
    
}
