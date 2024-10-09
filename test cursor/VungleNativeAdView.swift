import UIKit
import VungleAdsSDK

class VungleNativeAdView: UIView {
    private var nativeAd: VungleNative?
    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()
    private let callToActionButton = UIButton()
    private let iconImageView = UIImageView()
    private let sponsoredLabel = UILabel()
    private let mediaView = MediaView()
    private let adChoicesView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        backgroundColor = .systemYellow.withAlphaComponent(0.3)
        
        [iconImageView, titleLabel, bodyLabel, mediaView, callToActionButton, sponsoredLabel, adChoicesView].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        iconImageView.contentMode = .scaleAspectFit
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.numberOfLines = 2
        bodyLabel.font = .systemFont(ofSize: 14)
        bodyLabel.numberOfLines = 2
        callToActionButton.setTitleColor(.black, for: .normal)
        callToActionButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        callToActionButton.layer.cornerRadius = 8
        callToActionButton.layer.borderWidth = 1
        callToActionButton.layer.borderColor = UIColor.black.cgColor
        callToActionButton.backgroundColor = .white
        sponsoredLabel.font = .systemFont(ofSize: 12)
        sponsoredLabel.textColor = .darkGray
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            
            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            bodyLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            bodyLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            
            mediaView.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 8),
            mediaView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mediaView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mediaView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 9.0/16.0),
            
            callToActionButton.topAnchor.constraint(equalTo: mediaView.bottomAnchor, constant: 8),
            callToActionButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            callToActionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            callToActionButton.heightAnchor.constraint(equalToConstant: 44),
            
            sponsoredLabel.topAnchor.constraint(equalTo: callToActionButton.bottomAnchor, constant: 4),
            sponsoredLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            sponsoredLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            
            adChoicesView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            adChoicesView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            adChoicesView.widthAnchor.constraint(equalToConstant: 20),
            adChoicesView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func configure(with nativeAd: VungleNative, viewController: UIViewController) {
        self.nativeAd = nativeAd
        
        titleLabel.text = nativeAd.title
        bodyLabel.text = nativeAd.bodyText
        callToActionButton.setTitle(nativeAd.callToAction, for: .normal)
        sponsoredLabel.text = nativeAd.sponsoredText
        iconImageView.image = nativeAd.iconImage
        
        // Set up ad choices icon
        adChoicesView.image = UIImage(named: "adChoicesIcon") // You'll need to add this image to your assets
        
        // Define clickable views
        let clickableViews: [UIView] = [titleLabel, bodyLabel, callToActionButton, mediaView, iconImageView]
        
        // Register views for interaction
        nativeAd.registerViewForInteraction(
            view: self,
            mediaView: mediaView,
            iconImageView: iconImageView,
            viewController: viewController,
            clickableViews: clickableViews
        )
        
        print("Native Ad configured:")
        print("Title: \(nativeAd.title)")
        print("Body: \(nativeAd.bodyText)")
        print("CTA: \(nativeAd.callToAction)")
        print("Sponsored: \(nativeAd.sponsoredText)")
        print("Has Icon: \(nativeAd.iconImage != nil)")
        print("Media Aspect Ratio: \(nativeAd.getMediaAspectRatio())")
    }
}
