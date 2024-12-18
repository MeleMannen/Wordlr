//
//  SelectView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 18/12/2024.
//

import SwiftUI

struct SelectView: View {
    @EnvironmentObject var appManager: AppManager
//    @State var numberOfLetters = 5.0
//    @State var selectedLanguage: LanguageSelection = .norwegian
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Spacer()
                VStack {
                    HStack {
                        Text("Select The Phrase Length:")
                            .font(.title).bold()
                        
                        Spacer()
                    }
                    HStack {
                        
                        
                        Spacer()
                        
                        Picker("Select The Phrase Length: ", selection: $appManager.numberOfLetters) {
                            ForEach(1...8, id: \.self) { number in
                                Text("\(number) letters")
                                    .font(.title2).bold()
                            }
                            
                        }
                        .pickerStyle(.menu)
                        .foregroundStyle(Color(uiColor: .label))
                        .accentColor(Color(uiColor: .label))
                        .font(.title).bold()
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(Color(uiColor: .tertiarySystemBackground))
                        }
                        .sensoryFeedback(.selection, trigger: appManager.numberOfLetters)
                    }
                    
                    
                    
//                    Slider(value: $appManager.numberOfLetters2, in: 1...8, step: 1) {
//                        Text("Number of Letters")
//                    } minimumValueLabel: {
//                        Text("1")
//                            .onTapGesture {
//                                if appManager.numberOfLetters2 > 1 {
//                                    appManager.numberOfLetters2 -= 1
//                                }
//                                
//                            }
//                            .padding(.trailing, 3)
//                    } maximumValueLabel: {
//                        Text("8")
//                            .onTapGesture {
//                                if appManager.numberOfLetters2 < 8 {
//                                    appManager.numberOfLetters2 += 1
//                                }
//                                
//                            }
//                            .padding(.leading, 3)
//                    }
//                    .sensoryFeedback(.selection, trigger: appManager.numberOfLetters2)
//                    .onChange(of: appManager.numberOfLetters2) {
//                        appManager.numberOfLetters = Int(appManager.numberOfLetters2)
//                    }
//                    
//                    
//                    Text("\(Int(appManager.numberOfLetters2))")
//                        .font(.title2).bold()
                }
                .padding(.bottom, 50)
                
                Spacer()
                VStack {
                    HStack {
                        Text("Select Language:")
                            .font(.title).bold()
                        
                        Spacer()
                    }
                    
                    HStack {
                        
                        Spacer()
                        
                        Picker(selection: $appManager.selectedLanguage) {
                            ForEach(LanguageSelection.allCases) { language in
                                Text(language.localizedName.capitalized)
                            }
                        } label: {
                            Text("Language")
                        }
                        .pickerStyle(.menu)
                        .foregroundStyle(Color(uiColor: .label))
                        .accentColor(Color(uiColor: .label))
                        .onChange(of: appManager.selectedLanguage) {
                            if appManager.selectedLanguage == .english {
                                appManager.selectedLanguage = .norwegian
                            }
                        }
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(Color(uiColor: .tertiarySystemBackground))
                        }
                        .sensoryFeedback(.impact, trigger: appManager.selectedLanguage)
                    }
                    
                    
                }
                .padding(.bottom, 50)
                Spacer()
                Spacer()
                VStack {
                    NavigationLink(destination: GameView().environmentObject(appManager)) {
                        Text("Play")
                            .font(.largeTitle).bold()
                            .padding()
                            .padding(.horizontal, 40)
                            .foregroundStyle(Color(uiColor: .label))
                            .background {
                                RoundedRectangle(cornerRadius: 50)
                                    .foregroundStyle(.green)
                                
                            }
                    }
                    
                    
                }
                .padding(.bottom, 50)
                Spacer()
                
            }
            .padding()
            .navigationTitle("The Phrase")
            .toolbarBackground(.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        
        
    }
}

#Preview {
    SelectView()
        .environmentObject(AppManager())
}
