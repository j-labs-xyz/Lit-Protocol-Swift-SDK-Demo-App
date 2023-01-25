//
//  SignInViewController.swift
//  Example
//
//  Created by leven on 2023/1/9.
//

import Foundation
import UIKit
import SnapKit
import FLAnimatedImage
import LitOAuthPKPSignUp
import GoogleSignIn
import LitProtocolSwiftSDK
import PromiseKit
class SignInViewController: UIViewController {

    lazy var googleLogo: UIImageView = {
        let logo = UIImageView()
        logo.image = UIImage(named: "google_logo")
        return logo
    }()
    
    lazy var litLogo: UIImageView = {
        let logo = UIImageView()
        logo.image = UIImage(named: "lit_logo")
        return logo
    }()
    
    lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        return label
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
    }
    
    func initUI() {
        self.view.backgroundColor = UIColor.black

       
        let transformIcon = UIImageView()
        transformIcon.image = UIImage.init(named: "transform")
        transformIcon.contentMode = .scaleAspectFit
        self.view.addSubview(transformIcon)
        transformIcon.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 80, height: 40))
        }
        
        self.view.addSubview(self.litLogo)
        self.litLogo.snp.makeConstraints { make in
            make.centerY.equalTo(transformIcon)
            make.right.equalTo(transformIcon.snp.left).offset(0)
            make.size.equalTo(160)
        }
        
        self.view.addSubview(self.googleLogo)
        self.googleLogo.snp.makeConstraints { make in
            make.centerY.equalTo(transformIcon)
            make.left.equalTo(transformIcon.snp.right).offset(30)
            make.size.equalTo(90)
        }
        
        let siginButton = UIButton(type: .custom)
        siginButton.setTitle("Sign   in", for: .normal)
        siginButton.setTitleColor(UIColor.white, for: .normal)
        siginButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        siginButton.addTarget(self, action: #selector(gotoSignin), for: .touchUpInside)
        self.view.addSubview(siginButton)
        siginButton.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.bottom.equalTo(-safeBottomHeight - 20)
            make.height.equalTo(50)
        }
        siginButton.layer.borderWidth = 1
        siginButton.layer.borderColor = UIColor.white.cgColor
        siginButton.layer.cornerRadius = 4
        
        self.view.addSubview(self.infoLabel)
        self.infoLabel.snp.makeConstraints { make in
            make.left.right.equalTo(siginButton)
            make.top.equalTo(self.googleLogo.snp.bottom).offset(0)
            make.bottom.equalTo(siginButton.snp.top).offset(-20)
        }
    }
    
    var pkpEthAddress: String = ""
    var signature: String = ""
    var pkpPublicKey: String = ""
    
    var tokenString: String = ""

    @objc
    func gotoSignin() {
        if pkpPublicKey != "" {
            self.getSignature()
        } else {
            self.infoLabel.text = "Get Google Auth..."
            GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] res, err in
                guard let `self` = self else { return }
                if let profile = res?.user.profile, let tokenString = res?.user.idToken?.tokenString {
                    print(tokenString)
                    self.tokenString = tokenString
                    self.infoLabel.text = "Get PKP..."

                    let vc = MintingPKPViewController(googleTokenString: tokenString) { pkpEthAddress, pkpPublicKey in
                        self.didMintPKP(pkpEthAddress: pkpEthAddress, pkpPublicKey: pkpPublicKey, profile: profile)
                    }
                    vc.isModalInPresentation = true
                    self.present(vc, animated: true)
                }
            }
        }
        
    }
    
    var litClient: LitClient = LitClient(config: LitNodeClientConfig(bootstrapUrls: LitNetwork.serrano.networks, litNetwork: .serrano))

    func getSignature() {
        let authNeededCallback: AuthNeededCallback = { [weak self]chain, resources, switchChain, expiration, url in
            guard let self = self else { return Promise(error: LitError.COMMON) }
            let props = SignSessionKeyProp(sessionKey: url, authMethods: [AuthMethod(authMethodType: 6, accessToken: self.tokenString)], pkpPublicKey: self.pkpPublicKey, expiration: expiration, resouces: resources ?? [], chain: chain)
            return self.litClient.signSessionKey(props)
        }
        let props = GetSessionSigsProps(expiration: Date(timeIntervalSinceNow: 1000 * 60 * 60 * 24),
                                        chain: .ethereum,
                                        resource: ["litEncryptionCondition://*"],
                                        switchChain: false,
                                        authNeededCallback: authNeededCallback)
        self.infoLabel.text = """
        pkpPublicKey: \(pkpPublicKey)
        pkpEthAddress: \(pkpEthAddress)
        
        Get Signature....
        """
        
        if self.litClient.isReady == false {
            let _ = self.litClient.connect().then {
                return self.litClient.getSessionSigs(props)
            }.done { [weak self] res in
                guard let self = self else { return }
                if let auth = res as? JsonAuthSig {
                    self.signature = auth.sig
                    self.infoLabel.text =  """
        pkpPublicKey: \(self.pkpPublicKey)
        pkpEthAddress: \(self.pkpEthAddress)
        Signature: \(auth.sig)
        """
                }
            }
        } else {
            let _ = self.litClient.getSessionSigs(props).done { [weak self] res in
                guard let self = self else { return }
                if let auth = res as? JsonAuthSig {
                    self.signature = auth.sig
                    self.infoLabel.text =  """
        pkpPublicKey: \(self.pkpPublicKey)
        pkpEthAddress: \(self.pkpEthAddress)
        Signature: \(auth.sig)
        """
                }
            }
        }
        
      
    }
    
    func didMintPKP(pkpEthAddress: String, pkpPublicKey: String, profile: GIDProfileData) {
        self.pkpPublicKey = pkpPublicKey
        self.pkpEthAddress = pkpEthAddress
        self.infoLabel.text = """
        pkpPublicKey: \(pkpPublicKey)
        pkpEthAddress: \(pkpEthAddress)
        
        Get Signature....
        """
        self.getSignature()

//        let vc = WalletViewController(pkpEthAddress: pkpEthAddress, pkpPublicKey: pkpPublicKey, profile: profile)
//
//        if let window =  (UIApplication.shared.delegate as? AppDelegate)?.window {
//            window.rootViewController = vc
//        }
    }
    
}
