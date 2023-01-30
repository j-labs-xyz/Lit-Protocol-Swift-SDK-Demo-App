//
//  WalleteSendViewController.swift
//  Example
//
//  Created by leven on 2023/1/30.
//

import UIKit
import web3
import NVActivityIndicatorView
import Toast_Swift
import JKCategories
import WebKit
import SafariServices
import BigInt
class WalleteSendViewController: UIViewController {

    @IBOutlet weak var transactionIdLabel: UILabel!
    
    @IBOutlet weak var toAddressInput: UITextField!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var valueInput: UITextField!
    @IBOutlet weak var addressPasteButton: UIButton!
    
    var isSending: Bool = false {
        didSet {
            if isSending {
                self.loadingView.startAnimating()
            } else {
                self.loadingView.stopAnimating()
            }
        }
    }
    
    lazy var loadingView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 150, height: 150), type: .ballClipRotateMultiple, color: UIColor.black.withAlphaComponent(0.8), padding: 20)
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Send"
        addressPasteButton.addTarget(self, action: #selector(didClickAddressPaste), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(didClickSend), for: .touchUpInside)
        self.sendButton.layer.cornerRadius = 4
        self.sendButton.layer.masksToBounds = true
        self.view.addSubview(self.loadingView)
        self.loadingView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 150, height: 150))
        }
        
        self.balanceLabel.text = (WalletManager.shared.currentWallet?.balance ?? 0.0).str_6f
        self.transactionIdLabel.addTap { [weak self] in
            guard let self = self, (self.transactionIdLabel.text?.count ?? 0) > 10 else { return }
            let vc = SFSafariViewController(url: URL(string: "https://mumbai.polygonscan.com/tx/\(self.transactionIdLabel.text ?? "")")!)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func didClickAddressPaste() {
        self.toAddressInput.text = UIPasteboard.general.string
    }
    @objc func didClickSend() {
        self.view.endEditing(true)
        self.send()
    }
    
    func send() {
        guard self.isSending == false else {
            return
        }
        guard let wallet = WalletManager.shared.currentWallet, let value = self.valueInput.text?.toDouble(), value >= 0 && value <= wallet.balance else {
           return
        }
        guard let toAddress = self.toAddressInput.text, toAddress.web3.isAddress else {
            return
        }
        let weiValue: UInt64 = UInt64(value * pow(Double(10), Double(18)))
        let bigIntValue = BigUInt("\(weiValue)")
        self.isSending = true
        let hexV = bigIntValue?.web3.hexString ?? ""
        WalletManager.shared.send(toAddress: toAddress, value: hexV).done { [weak self] tx in
            guard let self = self else { return }
            self.isSending = false
            self.transactionIdLabel.text = tx
        }.catch { [weak self]err in
            guard let self = self else { return }
            print(err)
            self.isSending = false
            UIWindow.toast(msg: err.localizedDescription)
        }
    }

}
