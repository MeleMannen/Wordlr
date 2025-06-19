//
//  IndexedListViewTest.swift
//  Wordle
//
//  Created by Kristoffer Melen on 06/06/2025.
//

import SwiftUI

struct IndexedListViewTest: View {
    let words: [String] = ["Apple", "Apples", "Banana", "Cherry", "Date", "Elderberry", "Fig", "Grapes", "Honeydew", "Iceberg", "Jackfruit", "Kiwi", "Lemon", "Mango", "Nectarine", "Orange", "Papaya", "Quince", "Raspberry", "Strawberry", "Tomato", "Ugli", "Vanilla", "Watermelon", "Xigua", "Yam", "Zucchini"]
    
    private var groupedWords: [String: [String]] {
        Dictionary(grouping: words, by: { String($0.prefix(1)).uppercased() })
    }
    
    private var sectionTitles: [String] {
        groupedWords.keys.sorted()
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, pinnedViews: .sectionHeaders) {
                ForEach(sectionTitles, id: \.self) { letter in
                    Section {
                        ForEach(groupedWords[letter] ?? [], id: \.self) { word in
                            AnimatedItemView(word: word)
                            
                                
                        }

                    } header: {
                        StickyHeaderView(title: letter)
//                        Divider()
                    }
//                    Divider()
                    
                }
                
                
            }
        }
        .listSectionSeparator(.visible)
        .listRowSeparator(.visible)
        .listStyle(GroupedListStyle())
        
    }
}

struct StickyHeaderView: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
//            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
//            .background(Color.blue)
            .frame(height: 50)
        Divider()
    }
}

struct AnimatedItemView: View {
    let word: String
//    @State private var isVisible: Bool = false
    
    var body: some View {
        Text(self.word)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
//            .background(Color.gray)
//            .cornerRadius(8)
//            .shadow(color: .gray.opacity(0.5), radius: 4, x: 0, y: 2)
//            .opacity(self.isVisible ? 1 : 0)
//            .offset(y: self.isVisible ? 0 : 20)
//            .animation(.easeInOut(duration: 0.4), value: self.isVisible)
//            .onAppear {
//                self.isVisible = true
//            }
        Divider()
    }
}


#Preview {
    IndexedListViewTest()
}
