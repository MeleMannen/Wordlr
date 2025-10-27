//
//  Tips.swift
//  Wordle
//
//  Created by Kristoffer Melen on 21/08/2025.
//

import Foundation
import TipKit

struct HintTip: Tip {
	static let getHintEvent = Event(id: "getHint")
	static let gamesPlayedEvent = Event(id: "gamesPlayed")
	var title: Text {
		Text("Get a Hint")
	}
	var message: Text? {
		Text("Tap here to get a hint for the current secret word, by watching a quick ad.")
	}
	
	var image: Image? {
		Image(systemName: "lightbulb.max.fill")
	}
	
	var rules: [Rule] {
		#Rule(Self.getHintEvent) { event in
			event.donations.count == 0
		}
		
		#Rule(Self.gamesPlayedEvent) { event in
			event.donations.count >= 5
		}
	}
}

struct SearchTip: Tip {
	static let searchEvent = Event(id: "search")
	var title: Text {
		Text("Search for a Word")
	}
	
	var message: Text? {
		Text("Tap here to be able to search for words, and to see the definitions.")
	}
	
	var image: Image? {
		Image(systemName: "magnifyingglass")
	}
	
	var rules: [Rule] {
		#Rule(Self.searchEvent) { event in
			event.donations.count == 0
		}
		
		#Rule(HintTip.gamesPlayedEvent) { event in
			event.donations.count >= 8
		}
	}
}

struct FilterTip: Tip {
	static let filterEvent = Event(id: "filter")
//	static let searchViewVisitedEvent = Event(id: "searchViewVisited")
	var title: Text {
		Text("Use filters")
	}
	
	var message: Text? {
		Text("Tap here to filter the words, to easily find the word you are looking for.")
	}
	
	var image: Image? {
		Image(systemName: "slider.horizontal.3")
	}
	
	var rules: [Rule] {
		#Rule(Self.filterEvent) { event in
			event.donations.count == 0
		}
		
		#Rule(SearchTip.searchEvent) { event in
			event.donations.count >= 3
		}
	}
}
