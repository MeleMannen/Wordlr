//
//  IndexedListView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 16/02/2025.
//

import SwiftUI

//struct IndexedListView: View {
//    let words: [String] = ["Apple", "Apples", "Banana", "Cherry", "Date", "Elderberry", "Fig", "Grapes", "Honeydew", "Iceberg", "Jackfruit", "Kiwi", "Lemon", "Mango", "Nectarine", "Orange", "Papaya", "Quince", "Raspberry", "Strawberry", "Tomato", "Ugli", "Vanilla", "Watermelon", "Xigua", "Yam", "Zucchini"]
//    
//    private var groupedWords: [String: [String]] {
//        Dictionary(grouping: words, by: { String($0.prefix(1)).uppercased() })
//    }
//    
//    private var sectionTitles: [String] {
//        groupedWords.keys.sorted()
//    }
//    
//    var body: some View {
//        NavigationView {
//            ScrollViewReader { proxy in
//                HStack(spacing: 0) {
//                    ScrollView {
//                        LazyVStack(alignment: .leading, spacing: 10, pinnedViews: [.sectionHeaders]) {
//                            ForEach(sectionTitles, id: \.self) { letter in
//                                Section {
//                                    ForEach(groupedWords[letter] ?? [], id: \.self) { word in
//                                        VStack(alignment: .leading, spacing: 0) {
//                                            Text(word)
//                                                .padding(.vertical, 4)
//                                            
//                                            Divider()
//                                                .background(Color.white)
//                                        }
//                                        .padding(.leading, 5)
//                                        .frame(maxWidth: .infinity, alignment: .leading)
//                                        
//                                    }
//                                } header: {
//                                    VStack {
//                                        HStack {
//                                            Text(letter)
//                                                .foregroundStyle(.gray)
//                                                .font(.headline)
//                                            
//                                            Spacer()
//                                        }
//                                        
//                                        .padding(.bottom, -5)
//                                        Divider()
//                                            .background(Color.white)
//                                    }
//                                    
//                                    .frame(height: 20)
//                                    .id(letter)
//                                    .padding(.leading, 5)
//                                    .padding(.top, 2)
//                                    .background {
//                                        Rectangle()
//                                            .foregroundStyle(.background)
//                                    }
//                                }
//                                .padding(.bottom, 10)
//                                
//                                
//                                
//                            }
//                            
//                        }
//                        
//                        
//                    }
//                    .padding(.leading, 5)
//                    .scrollIndicators(.hidden)
////                    .listStyle(.grouped)
//                    .listSectionSeparator(.visible)
//                    .listSectionSpacing(100)
//                    
//                    
//                    
//                    VStack(spacing: 5) {
//                        GeometryReader { geometry in
//                            let letterHeight = CGFloat(15)
//                            
//                            VStack(spacing: 0) {
//                                ForEach(sectionTitles, id: \.self) { letter in
//                                    Text(letter)
//                                        .font(.system(size: 12, weight: .bold))
//                                        .foregroundColor(.blue)
//                                        .frame(width: 20, height: letterHeight)
//                                        .contentShape(Rectangle())
//                                        .onTapGesture {
//                                            withAnimation {
//                                                proxy.scrollTo(letter, anchor: .top)
//                                            }
//                                        }
//                                }
//                            }
//                            .frame(maxHeight: .infinity)
//                            .gesture(
//                                DragGesture(minimumDistance: 0)
//                                    .onChanged { value in
//                                        let y = value.location.y
//                                        let index = Int(y / letterHeight)
//                                        if index >= 0 && index < sectionTitles.count {
//                                            let selectedLetter = sectionTitles[index]
//                                            withAnimation {
//                                                proxy.scrollTo(selectedLetter, anchor: .top)
//                                            }
//                                        }
//                                    }
//                            )
//                        }
//                    }
//                    .frame(width: 20)
//                    .padding(.trailing, 5)
//                }
//                .navigationTitle("Words List")
//            }
//        }
//    }
//}
//
//struct IndexedListView_Previews: PreviewProvider {
//    static var previews: some View {
//        IndexedListView()
//    }
//}

// Enhanced version with ScrollViewReader for actual scrolling (iOS 14+)
//struct ContactsStyleViewWithScrolling: View {
//    let words = [
//        "Apple", "Airplane", "Ant", "Banana", "Bear", "Bird", "Cat", "Car", "Dog",
//        "Duck", "Elephant", "Eagle", "Fox", "Fish", "Grape", "Goat", "Horse",
//        "Hat", "Ice", "Igloo", "Jacket", "Jar", "Kite", "Key", "Lion", "Lamp",
//        "Mouse", "Moon", "Notebook", "Nail", "Orange", "Owl", "Piano", "Pen",
//        "Queen", "Quilt", "Rabbit", "Rose", "Sun", "Star", "Tiger", "Tree",
//        "Umbrella", "Under", "Violin", "Vase", "Water", "Wolf", "Xylophone",
//        "X-ray", "Yellow", "Yarn", "Zebra", "Zoo"
//    ]
//    
//    private var groupedWords: [String: [String]] {
//        Dictionary(grouping: words.sorted()) { String($0.prefix(1)).uppercased() }
//    }
//    
//    private var sectionKeys: [String] {
//        groupedWords.keys.sorted()
//    }
//    
//    var body: some View {
//        NavigationView {
//            ScrollViewReader { proxy in
//                HStack(spacing: 0) {
//                    List {
//                        ForEach(sectionKeys, id: \.self) { letter in
//                            Section {
//                                ForEach(Array((groupedWords[letter] ?? []).enumerated()), id: \.offset) { index, word in
//                                    NavigationLink(destination: DetailView(word: word)) {
//                                        HStack {
//                                            Text(word)
//                                                .font(.title3)
//                                            Spacer()
//                                        }
//                                        .padding(.vertical, 8)
//                                        .contentShape(Rectangle())
//                                    }
//                                    .listRowBackground(Color(.systemGray6))
//                                    .listRowSeparator(index == (groupedWords[letter]?.count ?? 0) - 1 ? .hidden : .visible)
//                                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
//                                    
//                                }
//                            } header: {
//                                SectionHeaderView(letter: letter)
//                            }
//                            .listSectionSeparator(.hidden)
//                            .id(letter)
//                        }
//                    }
//                    .listStyle(PlainListStyle())
//                    .navigationTitle("Words")
//                    .navigationBarTitleDisplayMode(.large)
//                    
//                    
//                    
//                    VStack(spacing: 5) {
//                        GeometryReader { geometry in
//                            let letterHeight = CGFloat(15)
//                            
//                            VStack(spacing: 0) {
//                                ForEach(sectionKeys, id: \.self) { letter in
//                                    Text(letter)
//                                        .font(.system(size: 12, weight: .bold))
//                                        .foregroundColor(.blue)
//                                        .frame(width: 20, height: letterHeight)
//                                        .contentShape(Rectangle())
//                                        .onTapGesture {
//                                            withAnimation(.easeInOut) {
//                                                proxy.scrollTo(letter, anchor: .top)
//                                            }
//                                        }
//                                }
//                            }
//                            .frame(maxHeight: .infinity)
//                            .gesture(
//                                DragGesture(minimumDistance: 0)
//                                    .onChanged { value in
//                                        let y = value.location.y
//                                        let index = Int(y / letterHeight)
//                                        if index >= 0 && index < sectionKeys.count {
//                                            let selectedLetter = sectionKeys[index]
//                                            proxy.scrollTo(selectedLetter, anchor: .top)
//                                        }
//                                    }
//                            )
//                        }
//                    }
//                    .frame(width: 15)
//                }
//            }
//        }
//    }
//    
//}
//
//
//// Improved section header with proper sticky detection
//struct SectionHeaderView: View {
//    let letter: String
//    
//    var body: some View {
//        VStack {
//            HStack {
//                Text(letter)
//                    .font(.headline)
//                    .fontWeight(.semibold)
//                    .foregroundColor(.gray)
//                    .padding(.leading, 16)
//                Spacer()
//            }
//        }
//        .padding(.vertical, 8)
//        .frame(height: 35)
//        .listRowInsets(EdgeInsets())
//    }
//}

// Preview
//struct ContactsStyleView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContactsStyleViewWithScrolling()
//    }
//}




