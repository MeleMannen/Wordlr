//
//  NAOBView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 13/06/2025.
//

import SwiftUI
//#if canImport(WebKit)
//import WebKit
//#endif

struct NAOBView: View {
    @State var word: String = ""
//#if canImport(WebKit)
//    @State var page: WebPage = WebPage()
//#endif
    var body: some View {
        EmptyView()
//#if canImport(WebKit)
//        if #available(iOS 26.0, *) {
//            WebView(page)
//                .navigationTitle("NAOB - \(self.word)")
//                .onAppear {
//                    page.load(URLRequest(url: URL(string: "https://naob.no/ordbok/\(self.word)")!))
//                }
//                .ignoresSafeArea(.all, edges: .bottom)
//        }
//#endif
        #warning("NAOBView is not implemented yet. Fix when WebKit is available for iOS 26.0 and later.")
    }
}

#Preview {
    NAOBView(word: "Sessing")
}
