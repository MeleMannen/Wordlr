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
    
    var body: some View {
        List {
            VStack {
                Toggle(isOn: $appManager.isFilteringSearchWord) {
                    Text("Search:")
                        .font(.headline)
                }
                .tint(.green)
                
                
                TextField("Search for a Phrase", text: $appManager.searchedWord)
                    .textFieldStyle(ThePhraseTextFieldStyle())
                    .focused($focusedField, equals: .search)
                    .onTapGesture {
                        self.focusedField = .search
                    }
                    .onSubmit {
                        self.focusNextField()
                    }
                    .onChange(of: appManager.searchedWord) { oldValue, newValue in
                        if newValue.count > 0 && !appManager.isFilteringSearchWord {
                            appManager.isFilteringSearchWord = true
                        }
                    }
            }
            
            VStack {
                Toggle(isOn: $appManager.isFilteringStartWith) {
                    Text("Starts with:")
                        .font(.headline)
                }
                .tint(.green)
                
                TextField("Enter starting letters", text: $appManager.startsWithFilter)
                    .textFieldStyle(ThePhraseTextFieldStyle())
                    .focused($focusedField, equals: .startsWith)
                    .onTapGesture {
                        self.focusedField = .startsWith
                    }
                    .onSubmit {
                        self.focusNextField()
                    }
                    .onChange(of: appManager.startsWithFilter) { oldValue, newValue in
                        if newValue.count == 0 {
                            appManager.isFilteringStartWith = false
                        } else {
                            appManager.isFilteringStartWith = true
                        }
                    }
            }
            
            VStack {
                Toggle(isOn: $appManager.isFilteringEndsWith) {
                    Text("Ends with:")
                        .font(.headline)
                }
                .tint(.green)
                
                TextField("Enter ending letters", text: $appManager.endsWithFilter)
                    .textFieldStyle(ThePhraseTextFieldStyle())
                    .focused($focusedField, equals: .endsWith)
                    .onTapGesture {
                        self.focusedField = .endsWith
                    }
                    .onSubmit {
                        self.focusNextField()
                    }
                    .onChange(of: appManager.endsWithFilter) { oldValue, newValue in
                        if newValue.count == 0 {
                            appManager.isFilteringEndsWith = false
                        } else {
                            appManager.isFilteringEndsWith = true
                        }
                    }
            }
            
            VStack {
                Toggle(isOn: $appManager.isFilteringIncludedLetters) {
                    Text("Included letters:")
                        .font(.headline)
                }
                .tint(.green)
                
                HStack {
                    Spacer()
                    
                    Menu {
                        ForEach(appManager.selectedLanguage == .english ? appManager.englishLetters : appManager.norwegianLetters, id: \.self) { letter in
                            Toggle(
                                isOn: Binding(
                                    get: { appManager.selectedIncludedLetters.contains(letter) },
                                    set: { isSelected in
                                        if isSelected {
                                            appManager.selectedIncludedLetters.append(letter)
                                        } else {
                                            appManager.selectedIncludedLetters.removeAll { $0 == letter }
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
                            Text(appManager.selectedIncludedLetters.isEmpty ? includedLettersText : appManager.selectedIncludedLetters.joined(separator: ", "))
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
                    .onChange(of: appManager.selectedIncludedLetters) { oldValue, newValue in
                        if newValue.count == 0 {
                            appManager.isFilteringIncludedLetters = false
                        } else {
                            appManager.selectedIncludedLetters = appManager.selectedIncludedLetters.sorted(by: {
                                $0.caseInsensitiveCompare($1) == .orderedAscending
                            })
                            appManager.isFilteringIncludedLetters = true
                        }
                    }
                }
            }
            
            VStack {
                Toggle(isOn: $appManager.isFilteringExcludeLetters) {
                    Text("Exclude letters:")
                        .font(.headline)
                }
                .tint(.green)
                
                HStack {
                    Spacer()
                    
                    Menu {
                        ForEach(appManager.selectedLanguage == .english ? appManager.englishLetters : appManager.norwegianLetters, id: \.self) { letter in
                            Toggle(
                                isOn: Binding(
                                    get: { appManager.selectedExcludedLetters.contains(letter) },
                                    set: { isSelected in
                                        if isSelected {
                                            appManager.selectedExcludedLetters.append(letter)
                                        } else {
                                            appManager.selectedExcludedLetters.removeAll { $0 == letter }
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
                            Text(appManager.selectedExcludedLetters.isEmpty ? excludedLettersText : appManager.selectedExcludedLetters.joined(separator: ", "))
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
                    .onChange(of: appManager.selectedExcludedLetters) { oldValue, newValue in
                        if newValue.count == 0 {
                            appManager.isFilteringExcludeLetters = false
                        } else {
                            appManager.selectedExcludedLetters.sort()
                            appManager.isFilteringExcludeLetters = true
                        }
                    }
                }
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button {
                        appManager.resetFilters()
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
            focusedField = nil
        }
        .scrollDisabled(true)
        .navigationTitle("Filter Options")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            withAnimation {
                DispatchQueue.main.async {
                    self.focusedField = nil
                }
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

#Preview {
    FilterOptionsView()
        .environmentObject(AppManager())
}
