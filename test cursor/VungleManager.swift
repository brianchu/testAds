import Foundation
import UIKit
import VungleAdsSDK
import Combine

class VungleManager: NSObject, ObservableObject {
    static let shared = VungleManager()
    
    @Published private(set) var isInitialized = false
    @Published var isBannerAdReady = false
    @Published var isInterstitialAdReady = false
    @Published var isRewardedAdReady = false
    @Published var isNativeAdReady = false
    
    var bannerAd: VungleBannerView?
    var interstitialAd: VungleInterstitial?
    var rewardedAd: VungleRewarded?
    var nativeAd: VungleNative?
    
    private override init() {
        super.init()
    }
    
    func initializeAndLoadAds() {
        print("Starting Vungle SDK initialization...")
        VungleAds.initWithAppId("66fb5291cde9700bb6f03adc") { [weak self] error in
//        VungleAds.initWithAppId("66fe23113d15f9d2c570a56a") { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Vungle SDK initialization failed: \(error.localizedDescription)")
                } else {
                    print("Vungle SDK initialized successfully")
                    self?.isInitialized = true
                    
                    // Add delays before loading each ad type
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { self?.loadBannerAd() }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { self?.loadInterstitialAd() }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { self?.loadRewardedAd() }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { self?.loadNativeAd() }
                }
            }
        }
    }
    
    private func loadBannerAd(size: VungleAdSize = .VungleAdSizeBannerRegular) {
        guard isInitialized else {
            print("Cannot load banner ad: Vungle SDK not initialized")
            return
        }
        print("Attempting to load banner ad")
        bannerAd = VungleBannerView(placementId:
//                                        "DEFAULT-3490035"
//                                        "BANNER_AD_TEST-1061447"
                                    "BANNER_AGAIN-1543783"
                                    , vungleAdSize: size)
        bannerAd?.delegate = self
        bannerAd?.load()
    }
    
    private func loadInterstitialAd() {
        guard isInitialized else {
            print("Cannot load interstitial ad: Vungle SDK not initialized")
            return
        }
        print("Attempting to load interstitial ad")
        interstitialAd = VungleInterstitial(placementId: "INTERSTITIAL_TEST-7818329")
        interstitialAd?.delegate = self
        interstitialAd?.load()
    }
    
    private func loadRewardedAd() {
        guard isInitialized else {
            print("Cannot load rewarded ad: Vungle SDK not initialized")
            return
        }
        print("Attempting to load rewarded ad")
        rewardedAd = VungleRewarded(placementId: "REWARDED_TEST-5736143")
        rewardedAd?.delegate = self
        rewardedAd?.load()
    }
    
    private func loadNativeAd() {
        guard isInitialized else {
            print("Cannot load native ad: Vungle SDK not initialized")
            return
        }
        print("Attempting to load native ad")
        nativeAd = VungleNative(placementId: "NATIVE_TEST-1025423")
        nativeAd?.delegate = self
        nativeAd?.load()
    }
    
    func isReadyToLoadAds() -> Bool {
        return isInitialized
    }
    
    // Add this method to the VungleManager class
    func showInterstitialAd(from viewController: UIViewController) {
        guard isInterstitialAdReady, let interstitialAd = interstitialAd else {
            print("Interstitial ad is not ready to be shown")
            return
        }
        
        interstitialAd.present(with: viewController)
    }
    
    func showRewardedAd() {
        guard isRewardedAdReady, let rewardedAd = rewardedAd else {
            print("Rewarded ad is not ready to be shown")
            return
        }
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rewardedAd.present(with: rootViewController)
        } else {
            print("Unable to find root view controller to present rewarded ad")
        }
    }
}

extension VungleManager: VungleBannerViewDelegate, VungleInterstitialDelegate, VungleRewardedDelegate, VungleNativeDelegate {
    func bannerAdDidLoad(_ bannerView: VungleBannerView) {
        DispatchQueue.main.async {
            print("Banner ad loaded successfully")
            self.isBannerAdReady = true
        }
    }
    
    func bannerAdDidFail(_ bannerView: VungleBannerView, withError error: NSError) {
        DispatchQueue.main.async {
            print("Banner ad failed to load: \(error.localizedDescription), error code: \(error.code)")
            self.isBannerAdReady = false
        }
    }
    
    // VungleInterstitialDelegate
    func interstitialAdDidLoad(_ interstitial: VungleInterstitial) {
        DispatchQueue.main.async {
            print("Interstitial ad loaded successfully")
            self.isInterstitialAdReady = true
        }
    }
    
    func interstitialAdDidFailToLoad(_ interstitial: VungleInterstitial, withError error: NSError) {
        print("Interstitial ad failed to load: \(error.localizedDescription)")
        self.isInterstitialAdReady = false
    }
    
    // VungleRewardedDelegate
    func rewardedAdDidLoad(_ rewarded: VungleRewarded) {
        DispatchQueue.main.async {
            print("Rewarded ad loaded successfully")
            self.isRewardedAdReady = true
        }
    }
    
    func rewardedAdDidPresent(_ rewarded: VungleRewarded) {
        print("Rewarded ad presented")
    }
    
    func rewardedAdDidFailToLoad(_ rewarded: VungleRewarded, withError error: NSError) {
        print("Rewarded ad failed to load: \(error.localizedDescription)")
        self.isRewardedAdReady = false
    }
    
    func rewardedAdDidRewardUser(_ rewarded: VungleRewarded) {
        print("Rewarded ad has been fulfilled - User should receive the reward")
    }
    
    func rewardedAdDidFailToPresent(_ rewarded: VungleRewarded, withError error: NSError) {
        print("Rewarded ad failed to present: \(error.localizedDescription)")
    }
    
    func rewardedAdDidDismiss(_ rewarded: VungleRewarded) {
        print("Rewarded ad dismissed")
        // Reload the rewarded ad for the next opportunity
        loadRewardedAd()
    }
    
    // VungleNativeDelegate
    func nativeAdDidLoad(_ native: VungleNative) {
        DispatchQueue.main.async {
            print("Native ad loaded successfully")
            self.isNativeAdReady = true
        }
    }
    
    func nativeAdDidFailToLoad(_ native: VungleNative, withError error: NSError) {
        DispatchQueue.main.async {
            print("Native ad failed to load: \(error.localizedDescription)")
            self.isNativeAdReady = false
        }
    }
    
    func nativeAdDidFailToPresent(_ native: VungleNative, withError error: NSError) {
        print("Native ad failed to present: \(error.localizedDescription)")
    }
    
    func nativeAdDidTrackImpression(_ native: VungleNative) {
        print("Native ad impression tracked")
    }
    
    func nativeAdDidClick(_ native: VungleNative) {
        print("Native ad was clicked")
    }
}
