//
//  NAOBView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 13/06/2025.
//

import SwiftUI
import WebKit

struct NAOBView: View {
	@State var word: String
    
    var body: some View {
        if #available(iOS 26, *) {
            WebView(url: URL(string: "https://naob.no/ordbok/\(word)")!)
                .navigationTitle("Definition")
                .ignoresSafeArea(.all, edges: .bottom)
        } else {
            MyWebView(request: URLRequest(
                url: URL(string: "https://naob.no/ordbok/\(word)")!
            ))
            .navigationTitle("Definition")
        }
    }
}

struct MyWebView: UIViewRepresentable {
    let request: URLRequest
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(request)
        return webView
    }
    func updateUIView(_: WKWebView, context: Context) {}
}


#Preview {
    NAOBView(word: "Sessing")
}
