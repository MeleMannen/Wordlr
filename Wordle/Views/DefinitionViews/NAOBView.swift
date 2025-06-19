//
//  NAOBView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 13/06/2025.
//

import SwiftUI
import WebKit

struct NAOBView: View {
    @EnvironmentObject var appManager: AppManager
    @State var word: String = ""
    @State var page: WebPage = WebPage()
    var body: some View {
        if #available(iOS 26.0, *) {
            WebView(page)
                .navigationTitle("NAOB - \(self.word)")
                .onAppear {
                    page.load(URLRequest(url: URL(string: "https://naob.no/ordbok/\(self.word)")!))
                }
                .ignoresSafeArea(.all, edges: .bottom)
        }
    }
}

#Preview {
    NAOBView(word: "Sessing")
        .environmentObject(AppManager())
}
