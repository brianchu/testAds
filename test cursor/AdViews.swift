import SwiftUI
import VungleAdsSDK

struct BannerAdView: UIViewRepresentable {
    @ObservedObject var vungleManager: VungleManager
    let adSize: VungleAdSize
    
    init(vungleManager: VungleManager, adSize: VungleAdSize = .VungleAdSizeBannerRegular) {
        self.vungleManager = vungleManager
        self.adSize = adSize
    }
    
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView(frame: CGRect(origin: .zero, size: adSize.size))
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            if let bannerAd = vungleManager.bannerAd {
                for subview in uiView.subviews {
                    subview.removeFromSuperview()
                }
                bannerAd.frame = uiView.bounds
                uiView.addSubview(bannerAd)
            }
        }
    }
}

struct InterstitialAdView: UIViewControllerRepresentable {
    @ObservedObject var vungleManager: VungleManager
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if vungleManager.interstitialAd?.canPlayAd() == true {
            vungleManager.interstitialAd?.present(with: uiViewController)
        } else {
            print("Interstitial ad is not ready to play")
        }
    }
}

struct RewardedAdView: UIViewControllerRepresentable {
    @ObservedObject var vungleManager: VungleManager
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if vungleManager.rewardedAd?.canPlayAd() == true {
            vungleManager.rewardedAd?.present(with: uiViewController)
        } else {
            print("Rewarded ad is not ready to play")
        }
    }
}

struct NativeAdView: UIViewControllerRepresentable {
    @ObservedObject var vungleManager = VungleManager.shared
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let nativeAdView = VungleNativeAdView(frame: CGRect(x: 0, y: 0, width: 300, height: 250))
        viewController.view.addSubview(nativeAdView)
        
        if let nativeAd = vungleManager.nativeAd {
            nativeAdView.configure(with: nativeAd, viewController: viewController)
        }
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
