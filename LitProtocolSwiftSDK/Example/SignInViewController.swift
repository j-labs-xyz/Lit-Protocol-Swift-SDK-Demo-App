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

       
        let arrowRight = UIImageView()
        arrowRight.image = UIImage.init(named: "arrow_right")
        arrowRight.contentMode = .scaleAspectFit
        self.view.addSubview(arrowRight)
        arrowRight.snp.makeConstraints { make in
            make.top.equalTo(400)
            make.centerX.equalToSuperview()
            make.size.equalTo(35)
        }
        
        self.view.addSubview(self.litLogo)
        self.litLogo.snp.makeConstraints { make in
            make.centerY.equalTo(arrowRight)
            make.right.equalTo(arrowRight.snp.left).offset(0)
            make.size.equalTo(100)
        }
        
        self.view.addSubview(self.googleLogo)
        self.googleLogo.snp.makeConstraints { make in
            make.centerY.equalTo(arrowRight)
            make.left.equalTo(arrowRight.snp.left).offset(60)
            make.size.equalTo(50)
        }

        let siginButton = UIButton(type: .custom)
        siginButton.setTitle("Sign   in", for: .normal)
        siginButton.setTitleColor(UIColor.white, for: .normal)
        siginButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        siginButton.addTarget(self, action: #selector(gotoSignin), for: .touchUpInside)
        self.view.addSubview(siginButton)
        siginButton.snp.makeConstraints { make in
            make.left.equalTo(60)
            make.right.equalTo(-60)
            make.top.equalTo(arrowRight.snp.bottom).offset(70)
            make.height.equalTo(44)
        }
        siginButton.layer.borderWidth = 1
        siginButton.layer.borderColor = UIColor.white.cgColor
        siginButton.layer.cornerRadius = 4
        
    }
    
    
    @objc
    func gotoSignin() {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] res, err in
            guard let `self` = self else { return }
            if let profile = res?.user.profile, let tokenString = res?.user.idToken?.tokenString {
                let vc = MintingPKPViewController(googleTokenString: tokenString) { pkpEthAddress, pkpPublicKey in
                    self.didMintPKP(pkpEthAddress: pkpEthAddress, pkpPublicKey: pkpPublicKey, profile: profile)
                }
                vc.isModalInPresentation = true
                self.present(vc, animated: true)
            }
        }
    }
    
    func didMintPKP(pkpEthAddress: String, pkpPublicKey: String, profile: GIDProfileData) {
        
        let vc = WalletViewController(pkpEthAddress: pkpEthAddress, pkpPublicKey: pkpPublicKey, profile: profile)
        
        if let window =  (UIApplication.shared.delegate as? AppDelegate)?.window {
            window.rootViewController = vc
        }
    }
    
}
