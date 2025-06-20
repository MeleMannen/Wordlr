//
//  SettingsView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 19/12/2024.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("appTheme") private var appTheme: AppTheme = .dark
    @AppStorage("defaultLanguage") private var defaultLanguage: LanguageSelection = .norwegian
    @AppStorage("defaultNumberOfLetters") private var defaultNumberOfLetters: Int = 5
    
    @AppStorage("defaultStatLanguage") private var defaultStatLanguage: LanguageSelection = .both
    @AppStorage("defaultStatNumberOfLetters") private var defaultStatNumberOfLetters: Int = 9
    @AppStorage("defaultStatGameMode") private var defaultStatGameMode: GameMode = .both
    @EnvironmentObject var appManager: AppManager
    var body: some View {
        NavigationStack {
            List {
                Section {
                    DisclosureGroup {
                        HStack {
                            Spacer()
                            Picker(selection: $defaultNumberOfLetters) {
                                ForEach(1...8, id: \.self) { number in
                                    Text("\(number) letters").tag(number)
                                }
                                
                            } label: {
                                
                            }
                            .padding(.trailing, 10)
                            .pickerStyle(.menu)
                            .tint(.primary)
                            .background {
                                if #unavailable(iOS 26.0, ) {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundStyle(Color(uiColor: .tertiarySystemBackground))
                                }
                            }
                            .padding(3)
                            .padding(.vertical, 5)
                            .modifier(ConditionalGlassEffect())
                        }
                        
                        
                    } label: {
                        HStack {
                            Text("Default Number of Letters:")
                                .font(.title3).bold()
                        }
                        .padding(.vertical, 5)
                    }
                    
                    DisclosureGroup {
                        Picker("", selection: $defaultLanguage) {
                            ForEach(LanguageSelection.languages) { language in
                                Text(language.localizedName.capitalized)
                                    .tag(language)
                            }
                            
                        }
                        .pickerStyle(.segmented)
                        .foregroundStyle(.primary)
                        .accentColor(.secondary)
                        .padding(.vertical, 5)
                        
                        
                    } label: {
                        HStack {
                            Text("Default Language:")
                                .font(.title3).bold()
                        }
                        .padding(.vertical, 5)
                    }
                } header: {
                    Text("Game")
                }
                
                Section {
                    DisclosureGroup {
                        HStack {
                            Spacer()
                            Picker(selection: $defaultStatNumberOfLetters) {
                                ForEach(1...9, id: \.self) { number in
                                    if number != 9 {
                                        Text("\(number) letters")
                                            .font(.title2).bold()
                                    } else {
                                        Text("All letters")
                                            .font(.title2).bold()
                                    }
                                }
                                
                            } label: {
                                
                            }
                            .padding(.trailing, 10)
                            .pickerStyle(.menu)
                            .tint(.primary)
                            .background {
                                if #unavailable(iOS 26.0, ) {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundStyle(Color(uiColor: .tertiarySystemBackground))
                                }
                            }
                            .padding(3)
                            .padding(.vertical, 5)
                            .modifier(ConditionalGlassEffect())
                        }
                        
                        
                    } label: {
                        HStack {
                            Text("Default Number of Letters:")
                                .font(.title3).bold()
                        }
                        .padding(.vertical, 5)
                    }
                    
                    DisclosureGroup {
                        Picker("", selection: $defaultStatLanguage) {
                            ForEach(LanguageSelection.allCases) { language in
                                if language == .both {
                                    Text("Both")
                                        .tag(language)
                                } else {
                                    Text(language.localizedName.capitalized)
                                        .tag(language)
                                }
                            }
                            
                        }
                        .pickerStyle(.segmented)
                        .foregroundStyle(.primary)
                        .accentColor(.secondary)
                        .padding(.vertical, 5)
                        
                        
                    } label: {
                        HStack {
                            Text("Default Language:")
                                .font(.title3).bold()
                        }
                        .padding(.vertical, 5)
                    }
                    
                    DisclosureGroup {
                        Picker("", selection: $defaultStatGameMode) {
                            ForEach(GameMode.allCases) { mode in
                                if mode == .both {
                                    Text("Both")
                                        .tag(mode)
                                } else {
                                    Text(mode.localizedName.capitalized)
                                        .tag(mode)
                                }
                            }
                            
                        }
                        .pickerStyle(.segmented)
                        .foregroundStyle(.primary)
                        .accentColor(.primary)
                        .padding(.vertical, 5)
                        
                        
                        
                        
                        
                        
                    } label: {
                        HStack {
                            Text("Default Gamemode:")
                                .font(.title3).bold()
                        }
                        .padding(.vertical, 5)
                    }
                } header: {
                    Text("Stats and History")
                }
                
                Section {
                    DisclosureGroup {
                        Picker("", selection: $appTheme) {
                            Text("System")
                                .tag(AppTheme.system)
                            Text("Dark")
                                .tag(AppTheme.dark)
                            Text("Light")
                                .tag(AppTheme.light)
                            
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.vertical, 5)
                        
                    } label: {
                        HStack {
                            Text("App Theme:")
                                .font(.title3).bold()
                        }
                        .padding(.vertical, 5)
                    }
                } header: {
                    Text("Theme")
                }
                
                
                
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppManager())
}
