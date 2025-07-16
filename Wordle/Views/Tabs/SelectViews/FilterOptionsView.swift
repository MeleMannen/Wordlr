//
//  Untitled.swift
//  Wordle
//
//  Created by Kristoffer Melen on 08/06/2025.
//

import SwiftUI

enum FilterOptionsFields: Hashable {
    case search
    case startsWith
    case endsWith
}

struct FilterOptionsView: View {
    @EnvironmentObject var appManager: AppManager
    @Environment(\.dismiss) var dismiss
    @FocusState var focusedField: FilterOptionsFields?
    @Binding var searchedWord: String
    @Binding var isFilteringSearchWord: Bool
    @Binding var isFilteringStartWith: Bool
    @Binding var startsWithFilter: String
    @Binding var isFilteringEndsWith: Bool
    @Binding var endsWithFilter: String
    @Binding var isFilteringExcludeLetters: Bool
    @Binding var isFilteringIncludedLetters: Bool
    @Binding var selectedExcludedLetters: [String]
    @Binding var selectedIncludedLetters: [String]
    
    let englishLetters: [String] = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    let norwegianLetters: [String] = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "Æ", "Ø", "Å"]
    
    var body: some View {
        List {
            VStack {
                Toggle(isOn: self.$isFilteringSearchWord) {
                    Text("Search:")
                        .font(.headline)
                }
                .tint(.green)
                
                
                TextField("Search for a Phrase", text: self.$searchedWord)
                    .textFieldStyle(ThePhraseTextFieldStyle())
                    .focused($focusedField, equals: .search)
                    .onTapGesture {
                        self.focusedField = .search
                    }
                    .onSubmit {
                        self.focusNextField()
                    }
                    .onChange(of: self.searchedWord) { oldValue, newValue in
                        if newValue.count > 0 && !self.isFilteringSearchWord {
                            self.isFilteringSearchWord = true
                        }
                    }
            }
            
            VStack {
                Toggle(isOn: self.$isFilteringStartWith) {
                    Text("Starts with:")
                        .font(.headline)
                }
                .tint(.green)
                
                TextField("Enter starting letters", text: self.$startsWithFilter)
                    .textFieldStyle(ThePhraseTextFieldStyle())
                    .focused($focusedField, equals: .startsWith)
                    .onTapGesture {
                        self.focusedField = .startsWith
                    }
                    .onSubmit {
                        self.focusNextField()
                    }
                    .onChange(of: self.startsWithFilter) { oldValue, newValue in
                        if newValue.count == 0 {
                            self.isFilteringStartWith = false
                        } else {
                            self.isFilteringStartWith = true
                        }
                    }
            }
            
            VStack {
                Toggle(isOn: self.$isFilteringEndsWith) {
                    Text("Ends with:")
                        .font(.headline)
                }
                .tint(.green)
                
                TextField("Enter ending letters", text: self.$endsWithFilter)
                    .textFieldStyle(ThePhraseTextFieldStyle())
                    .focused($focusedField, equals: .endsWith)
                    .onTapGesture {
                        self.focusedField = .endsWith
                    }
                    .onSubmit {
                        self.focusNextField()
                    }
                    .onChange(of: self.endsWithFilter) { oldValue, newValue in
                        if newValue.count == 0 {
                            self.isFilteringEndsWith = false
                        } else {
                            self.isFilteringEndsWith = true
                        }
                    }
            }
            
            VStack {
                Toggle(isOn: self.$isFilteringIncludedLetters) {
                    Text("Included letters:")
                        .font(.headline)
                }
                .tint(.green)
                
                HStack {
                    Spacer()
                    
                    Menu {
                        ForEach(appManager.selectedLanguage == .english ? self.englishLetters : self.norwegianLetters, id: \.self) { letter in
                            Toggle(
                                isOn: Binding(
                                    get: { self.selectedIncludedLetters.contains(letter) },
                                    set: { isSelected in
                                        if isSelected {
                                            self.selectedIncludedLetters.append(letter)
                                        } else {
                                            self.selectedIncludedLetters.removeAll { $0 == letter }
                                        }
                                    }
                                )
                            ) {
                                Text(letter)
                                    .font(.title3)
                            }
                        }
                    } label: {
                        HStack {
                            let includedLettersText = NSLocalizedString("Included letters", comment: "Label for included letters in filter options")
                            Text(self.selectedIncludedLetters.isEmpty ? includedLettersText : self.selectedIncludedLetters.joined(separator: ", "))
                                .font(.callout)
                            
                            Image(systemName: "chevron.up.chevron.down")
                        }
                        .padding(5)
                        .frame(width: 170, alignment: .center)
                        .modifier(ConditionalGlassEffect())
                    }
                    .accentColor(.primary)
                    .menuActionDismissBehavior(.disabled)
                    .background {
                        if #unavailable(iOS 26.0, ) {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(Color(uiColor: .tertiarySystemBackground))
                        }
                        
                    }
                    .onChange(of: self.selectedIncludedLetters) { oldValue, newValue in
                        if newValue.count == 0 {
                            self.isFilteringIncludedLetters = false
                        } else {
                            self.selectedIncludedLetters = self.selectedIncludedLetters.sorted(by: {
                                $0.caseInsensitiveCompare($1) == .orderedAscending
                            })
                            self.isFilteringIncludedLetters = true
                        }
                    }
                }
            }
            
            VStack {
                Toggle(isOn: self.$isFilteringExcludeLetters) {
                    Text("Exclude letters:")
                        .font(.headline)
                }
                .tint(.green)
                
                HStack {
                    Spacer()
                    
                    Menu {
                        ForEach(appManager.selectedLanguage == .english ? self.englishLetters : self.norwegianLetters, id: \.self) { letter in
                            Toggle(
                                isOn: Binding(
                                    get: { self.selectedExcludedLetters.contains(letter) },
                                    set: { isSelected in
                                        if isSelected {
                                            self.selectedExcludedLetters.append(letter)
                                        } else {
                                            self.selectedExcludedLetters.removeAll { $0 == letter }
                                        }
                                    }
                                )
                            ) {
                                Text(letter)
                                    .font(.title3)
                            }
                        }
                    } label: {
                        HStack {
                            let excludedLettersText = NSLocalizedString("Excluded letters", comment: "Label for excluded letters in filter options")
                            Text(self.selectedExcludedLetters.isEmpty ? excludedLettersText : self.selectedExcludedLetters.joined(separator: ", "))
                                .font(.callout)
                            
                            Image(systemName: "chevron.up.chevron.down")
                        }
                        .padding(5)
                        .frame(width: 170, alignment: .center)
                        .modifier(ConditionalGlassEffect())
                    }
                    .accentColor(.primary)
                    .menuActionDismissBehavior(.disabled)
                    .background {
                        if #unavailable(iOS 26.0, ) {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(Color(uiColor: .tertiarySystemBackground))
                        }
                    }
                    .onChange(of: self.selectedExcludedLetters) { oldValue, newValue in
                        if newValue.count == 0 {
                            self.isFilteringExcludeLetters = false
                        } else {
                            self.selectedExcludedLetters.sort()
                            self.isFilteringExcludeLetters = true
                        }
                    }
                }
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button {
                        self.resetFilters()
                    } label: {
                        Text("Reset filter")
                            .font(.headline)
                            .foregroundStyle(.red)
                    }
                    Spacer()
                }
                .padding(.vertical, 5)
            }
        }
        .padding(.top, -20)
        .onTapGesture {
            self.focusedField = nil
        }
        .scrollDisabled(true)
        .navigationTitle("Filter Options")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            withAnimation {
                self.focusedField = nil
            }
        }
    }
    
    func focusNextField() {
        guard let currentField = focusedField else { return }
        switch currentField {
            case .search:
                focusedField = .startsWith
            case .startsWith:
                focusedField = .endsWith
            case .endsWith:
                focusedField = nil
        }
    }
    
    func resetFilters() {
        self.isFilteringSearchWord = true
        self.isFilteringStartWith = false
        self.startsWithFilter = ""
        self.isFilteringEndsWith = false
        self.endsWithFilter = ""
        self.isFilteringIncludedLetters = false
        self.isFilteringExcludeLetters = false
        if !selectedIncludedLetters.isEmpty {
            self.selectedIncludedLetters.removeAll()
        }
        if !selectedExcludedLetters.isEmpty {
            self.selectedExcludedLetters.removeAll()
        }
    }
}

struct ThePhraseTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(10)
            .background(.background)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.primary)
            )
    }
}

//#Preview {
//    FilterOptionsView()
//        .environmentObject(AppManager())
//}
