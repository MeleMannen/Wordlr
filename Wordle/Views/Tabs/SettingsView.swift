//
//  SettingsView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 19/12/2024.
//

import SwiftUI
import GoogleMobileAds
import AppTrackingTransparency

struct SettingsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("appTheme") private var appTheme: AppTheme = .dark
    @AppStorage("userWantsAds") var userWantsAds: Bool = false
    @AppStorage("userWantsNormalTheme") private var userWantsNormalTheme: Bool = true
    @AppStorage("defaultLanguage") private var defaultLanguage: LanguageSelection = .norwegian
    @AppStorage("defaultNumberOfLetters") private var defaultNumberOfLetters: Int = 5
    
    @AppStorage("defaultStatLanguage") private var defaultStatLanguage: LanguageSelection = .both
    @AppStorage("defaultStatNumberOfLetters") private var defaultStatNumberOfLetters: Int = 9
    @AppStorage("defaultStatGameMode") private var defaultStatGameMode: GameMode = .both
    @AppStorage("defaultStatHintsUsed") private var defaultStatHintsUsed: ShowsWhenHintsUsed = .both
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                List {
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
                                    .font(.headline)
                            }
                            .padding(.vertical, 5)
                        }
                        
                        if self.colorScheme == .dark {
                            DisclosureGroup {
                                Picker("", selection: $userWantsNormalTheme) {
                                    Text("Standard")
                                        .tag(true)
                                    Text("Gold")
                                        .tag(false)
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .padding(.vertical, 5)
                            } label: {
                                HStack {
                                    Text("Daily Word Theme:")
                                        .font(.headline)
                                }
                                .padding(.vertical, 5)
                            }
                        }
                        
                        DisclosureGroup {
                            Picker("", selection: $userWantsAds) {
                                Text("Allow Ads")
                                    .tag(true)
                                Text("Don't Allow Ads")
                                    .tag(false)
                                
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.vertical, 5)
                            
                        } label: {
                            HStack {
                                Text("Ads:")
                                    .font(.headline)
                            }
                            .padding(.vertical, 5)
                        }
                        .onChange(of: userWantsAds) {
                            if userWantsAds {
                                MobileAds.shared.start()
                            }
                        }
                    } header: {
                        Text("App")
                    }
                    
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
                                            .conditionalShadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)
                                    }
                                }
                                .padding(3)
                                .padding(.vertical, 5)
                                .modifier(ConditionalGlassEffect())
                            }
                            
                            
                        } label: {
                            HStack {
                                Text("Default Number of Letters:")
                                    .font(.headline)
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
                                    .font(.headline)
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
                                            .conditionalShadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)
                                    }
                                }
                                .padding(3)
                                .padding(.vertical, 5)
                                .modifier(ConditionalGlassEffect())
                            }
                            
                            
                        } label: {
                            HStack {
                                Text("Default Number of Letters:")
                                    .font(.headline)
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
                                    .font(.headline)
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
                                    .font(.headline)
                            }
                            .padding(.vertical, 5)
                        }
                        
                        DisclosureGroup {
                            Picker("", selection: $defaultStatHintsUsed) {
                                ForEach(ShowsWhenHintsUsed.allCases) { mode in
                                    Text(mode.localizedName.capitalized)
                                        .tag(mode)
                                }
                            }
                            .pickerStyle(.segmented)
                            .foregroundStyle(.primary)
                            .accentColor(.primary)
                            .padding(.vertical, 5)
                            
                            
                        } label: {
                            HStack {
                                Text("Default Show When Hints Used:")
                                    .font(.headline)
                            }
                            .padding(.vertical, 5)
                        }
                    } header: {
                        Text("Stats and History")
                    }
                    
                    Section {
                        VStack {
                            HStack {
                                Text("Version:")
                                    .padding(.leading, 3)
                                    .font(.headline)
                                
                                Spacer()
                                
                                Text("\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0")")
                                //                                .font(.headline)
                                    .contextMenu {
                                        Button(action: {
                                            UIPasteboard.general.string = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
                                        }) {
                                            Text("Copy")
                                            Image(systemName: "doc.on.doc")
                                        }
                                    }
                            }
                        }
                        VStack {
                            HStack {
                                Text("Build:")
                                    .padding(.leading, 3)
                                    .font(.headline)
                                
                                
                                Spacer()
                                
                                Text("\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0")")
                                //                                .font(.headline)
                                    .contextMenu {
                                        Button(action: {
                                            UIPasteboard.general.string = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"
                                        }) {
                                            Text("Copy")
                                            Image(systemName: "doc.on.doc")
                                        }
                                    }
                            }
                        }
                        
                    } header: {
                        Text("App Info")
                    }
                }
                .navigationTitle("Settings")
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    if self.userWantsAds {
                        ATTrackingManager.requestTrackingAuthorization(completionHandler: { _ in })
                    }
                }
                .safeAreaPadding(.bottom, 54)
            }
        }
    }
}



struct BannerViewContainer: UIViewRepresentable {
    typealias UIViewType = BannerView
    let adSize: AdSize
    
    init(_ adSize: AdSize) {
        self.adSize = adSize
    }
    
    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: adSize)
        banner.adUnitID = "ca-app-pub-3940256099942544/2435281174" // ca-app-pub-7619403750703078/6852604335
        banner.load(Request())
        banner.delegate = context.coordinator
        return banner
    }
    
    func updateUIView(_ uiView: BannerView, context: Context) {}
    
    func makeCoordinator() -> BannerCoordinator {
        return BannerCoordinator(self)
    }
    
    class BannerCoordinator: NSObject, BannerViewDelegate {
        let parent: BannerViewContainer
        
        init(_ parent: BannerViewContainer) {
            self.parent = parent
        }
        
        // MARK: - GADBannerViewDelegate methods
        
        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            print("DID RECEIVE AD.")
            bannerView.alpha = 0
            UIView.animate(withDuration: 1, animations: {
                bannerView.alpha = 1
            })
        }

        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            print("FAILED TO RECEIVE AD: \(error.localizedDescription)")
        }
    }
}

#Preview {
    SettingsView()
}
