//
//  SettingsView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 19/12/2024.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("appTheme") private var appTheme: AppTheme = .dark
    @EnvironmentObject var appManager: AppManager
    var body: some View {
        NavigationView {
            List {
                VStack {
                    HStack {
                        Text("App Theme:")
                            .font(.title)
                            .bold()
                        
                        Spacer()
                    }
                    
                    Picker("App Theme:", selection: $appTheme) {
                        Text("System")
                            .tag(AppTheme.system)
                        Text("Dark")
                            .tag(AppTheme.dark)
                        Text("Light")
                            .tag(AppTheme.light)
                        
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    
                    .padding(.horizontal, 5)
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
