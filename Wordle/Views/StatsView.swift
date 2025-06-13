//
//  StatsView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 11/06/2025.
//

import SwiftUI

struct StatsView: View {
    @EnvironmentObject var appManager: AppManager
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Text("Statistics will be available soon!")
                        .font(.title2)
                        .padding(.vertical)
                }
            }
            .navigationTitle("Stats")
        }
            
    }
}

#Preview {
    StatsView()
        .environmentObject(AppManager())
}
