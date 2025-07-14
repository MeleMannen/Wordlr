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
    @AppStorage("appTheme") private var appTheme: AppTheme = .dark
    @AppStorage("defaultLanguage") private var defaultLanguage: LanguageSelection = .norwegian
    @AppStorage("defaultNumberOfLetters") private var defaultNumberOfLetters: Int = 5
    
    @AppStorage("defaultStatLanguage") private var defaultStatLanguage: LanguageSelection = .both
    @AppStorage("defaultStatNumberOfLetters") private var defaultStatNumberOfLetters: Int = 9
    @AppStorage("defaultStatGameMode") private var defaultStatGameMode: GameMode = .both
    @AppStorage("defaultStatHintsUsed") private var defaultStatHintsUsed: ShowsWhenHintsUsed = .both
    
    @AppStorage("userWantsAds") var userWantAds: Bool = false
    @EnvironmentObject var appManager: AppManager
    @State var adIsLoaded: Bool = false
    @State var isShowingAds: Bool = true
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
                        
                        
                        DisclosureGroup {
                            Picker("", selection: $userWantAds) {
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
                        .onChange(of: userWantAds) {
                            if userWantAds {
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
                    
                    
                    
                    
                    
                }
                .navigationTitle("Settings")
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    if self.userWantAds {
                        ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in })
                    }
                }
                
                
                if self.userWantAds && self.isShowingAds {
                    if self.adIsLoaded {
                        Spacer()
                    }
                    let adSize = currentOrientationAnchoredAdaptiveBanner(width: geometry.size.width - 40)
                    BannerViewContainer(adSize, adIsLoaded: self.$adIsLoaded, isShowingAds: self.$isShowingAds)
                        .frame(width: adSize.size.width, height: adSize.size.height)
                        .padding(.bottom, 7)
                        .opacity(self.adIsLoaded ? 1 : 0)
                    
                }
                
            }
        }
    }
}

struct BannerViewContainer: UIViewRepresentable {
    typealias UIViewType = BannerView
    let adSize: AdSize
    @Binding var adIsLoaded: Bool
    @Binding var isShowingAds: Bool
    
    init(_ adSize: AdSize, adIsLoaded: Binding<Bool>, isShowingAds: Binding<Bool>) {
        self.adSize = adSize
        self._adIsLoaded = adIsLoaded
        self._isShowingAds = isShowingAds
    }
    
    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: adSize)
        banner.adUnitID = "ca-app-pub-3940256099942544/2435281174" // ca-app-pub-7619403750703078/6852604335
        banner.load(Request())
        banner.delegate = context.coordinator
        banner.isHidden = true
        return banner
    }
    
    func updateUIView(_ uiView: BannerView, context: Context) {}
    
    func makeCoordinator() -> BannerCoordinator {
        return BannerCoordinator(self, adIsLoaded: self.$adIsLoaded, isShowingAds: self.$isShowingAds)
    }
    
    class BannerCoordinator: NSObject, BannerViewDelegate {
        let parent: BannerViewContainer
        @Binding var adIsLoaded: Bool
        @Binding var isShowingAds: Bool
        
        init(_ parent: BannerViewContainer, adIsLoaded: Binding<Bool>, isShowingAds: Binding<Bool>) {
            self.parent = parent
            self._adIsLoaded = adIsLoaded
            self._isShowingAds = isShowingAds
        }
        
        // MARK: - GADBannerViewDelegate methods
        
        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            print("DID RECEIVE AD.")
            self.adIsLoaded = true
            self.isShowingAds = true
            bannerView.alpha = 0
            bannerView.isHidden = false
            UIView.animate(withDuration: 1, animations: {
                bannerView.alpha = 1
            })
        }

        
        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            print("FAILED TO RECEIVE AD: \(error.localizedDescription)")
            self.adIsLoaded = false
            self.isShowingAds = false
            bannerView.isHidden = true
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppManager())
}
