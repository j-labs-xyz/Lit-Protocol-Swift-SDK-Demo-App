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
    }
    
    var pkpEthAddress: String = "0x1146e6C2b9E79A20b7E3b4fE1476AF4fAB4b1D70"
    
    var pkpPublicKey: String = "0x04313d0498598c896cc0e7dcb37ceb3b960dbda2c8ecde2f8959a233842d76065aacb4159cc7ad9488bec57921d8887ed7f47c01c66e888e3a718b3ce7b8b77893"    
    
    var tokenString: String = "eyJhbGciOiJSUzI1NiIsImtpZCI6ImQzN2FhNTA0MzgxMjkzN2ZlNDM5NjBjYTNjZjBlMjI4NGI2ZmMzNGQiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiIyMTQ4NzcwNzE5OTEtMGc1N284ZTZ2aWF1MzM1MGtuaTllY2RvOWsyb3RoZ3YuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiIyMTQ4NzcwNzE5OTEtMGc1N284ZTZ2aWF1MzM1MGtuaTllY2RvOWsyb3RoZ3YuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMDg5Nzk2NzU4MTg1MDY1OTM3ODAiLCJlbWFpbCI6ImlzcmVhbGxldmVuQGdtYWlsLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJhdF9oYXNoIjoiTjQxcllpVWFNMVVJVDJxdkhzSWF3dyIsIm5vbmNlIjoiVW1DYkR4dTRuUDRLZG5vMmNtY3U4bFlzMDNKTUJDSEs5RVJ0Y2dvcHhDcyIsIm5hbWUiOiLliJjmlociLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EvQUVkRlRwNUc1ZXJlbFN5anI1ZlNIUGIzQ1dSZ0M4eThROWJRUGpST3hnUmM9czk2LWMiLCJnaXZlbl9uYW1lIjoi5paHIiwiZmFtaWx5X25hbWUiOiLliJgiLCJsb2NhbGUiOiJ6aC1DTiIsImlhdCI6MTY3NDEyNzE4NiwiZXhwIjoxNjc0MTMwNzg2fQ.Ndz4nHkpQReJWBF3KfSVQBN3cSdNXvG0wSIWI7YVyiTuerQyY01e_a7E7dMAGYG3Kgqws8T8gE6z10LsNcAUzcTdjg3tlMQSgIjVvAI5XnZsLnlxrln9vGL663Pd0OCoeYSSFsxGHgZQ_nw5DQoUwKt6TquTAvtULkPAbWL0Xnk1hRJtBvbi0DKVcYRZDcUJtACOxNYzH75ObHdeuaMc6GiILI4u7A4nTJh31ccyOgKedGzE4Tict6kYgGJ6LzmbRt1-rJjM5GeUZuHjnt3B8AINQedCZIrJzpPqf3UmcyhNv2EXh9QzRNNQb8lVHqlfQ1mgc9qrFREhL2sv-Vclig"

    @objc
    func gotoSignin() {
        if pkpPublicKey != "" {
            self.getSignature()
        } else {
            GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] res, err in
                guard let `self` = self else { return }
                if let profile = res?.user.profile, let tokenString = res?.user.idToken?.tokenString {
                    print(tokenString)
                    self.tokenString = tokenString
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
        if self.litClient.isReady == false {
            let _ = self.litClient.connect().then {
                return self.litClient.getSessionSigs(props)
            }
        } else {
            let _ = self.litClient.getSessionSigs(props)
        }
        
      
    }
    
    func didMintPKP(pkpEthAddress: String, pkpPublicKey: String, profile: GIDProfileData) {
        self.pkpPublicKey = pkpPublicKey
        self.pkpEthAddress = pkpEthAddress
        
//        let vc = WalletViewController(pkpEthAddress: pkpEthAddress, pkpPublicKey: pkpPublicKey, profile: profile)
//
//        if let window =  (UIApplication.shared.delegate as? AppDelegate)?.window {
//            window.rootViewController = vc
//        }
    }
    
}
