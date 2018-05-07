//
//  ScannerModel.swift
//  Checkout Forus
//
//  Created by Jamal on 07/10/2017.
//  Copyright © 2017 Forus. All rights reserved.
//

import UIKit
import Alamofire
import QRCodeReader
import AVFoundation
import SwiftyJSON

class ScannerModel {
    var viewController: ScannerViewController
    
    var scanResult = String()
    var budget = Double()
    
    func checkScanPermissions() -> Bool {
        do {
            return try QRCodeReader.supportsMetadataObjectTypes()
        } catch let error as NSError {
            let alert: UIAlertController?
            
            switch error.code {
            case -11852:
                let message = popupMessages["backCameraPermission"]
                alert = UIAlertController(title: message?[0], message: message?[1], preferredStyle: .alert)
                
                alert?.addAction(UIAlertAction(title: "Setting", style: .default, handler: { (_) in
                    DispatchQueue.main.async {
                        if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
                            UIApplication.shared.openURL(settingsURL)
                        }
                    }
                }))
                
                alert?.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            case -11814:
                let message = popupMessages["unsupportedReader"]
                alert = UIAlertController(title: message?[0], message: message?[1], preferredStyle: .alert)
                alert?.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            default:
                alert = nil
            }
            
            guard let vc = alert else { return false }
            
            viewController.present(vc, animated: false, completion: nil)
            
            return false
        }
    }
    
    lazy var reader: QRCodeReader = QRCodeReader()
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [AVMetadataObject.ObjectType.qr.rawValue], captureDevicePosition: .back)
            $0.showTorchButton = false
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    func setHeaderAndToken() {
        if let publicKey = UserDefaults.standard.value(forKey: "publicKey") {
            headers["Device-Id"] = "\(publicKey)"
        }
        
        if let token = UserDefaults.standard.value(forKey: "APItoken") {
            headers["Authorization"] = "Bearer \(token)"
        }
    }
    
    func checkCode(_ code: String) {
        if code.count > 42 {
            authorizeToken(code)
        } else {
            checkVoucher(code)
        }
    }
    
    func checkVoucher(_ code: String) {
        Alamofire.request(baseURL+"vouchers/\(code)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            print(response)
            
            if let json = response.data {
                let data = JSON(data: json)
                
                if data.isEmpty {
                    self.connectionError()
                } else {
                    print(data)
                    if data["error"] == "voucher-unavailable-categories" {self.categoryError()}
                    if data["error"] == "shopkeeper-pending" {self.pendingError()}
                    
                    let max_amount = data["max_amount"]
                    
                    if max_amount.doubleValue != 0.0 {
                        self.budget = max_amount.doubleValue
                        self.viewController.performSegue(withIdentifier: "proceedToCheckout", sender: self)
                    } else if max_amount.doubleValue == 0.0 {
                        self.budget = max_amount.doubleValue
                        self.noBudgetWarning()
                    }
                }
            }
        }
    }
    
    func connectionError() {
        let message = popupMessages["noConnection"]
        
        var alert = UIAlertController(title: message?[0], message: message?[1], preferredStyle: .alert)
        alert = UIAlertController(title: message?[0], message: message?[1], preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
            self.viewController.loadScanner()
            self.viewController.progressHUD.isHidden = true
        }))
        
        self.viewController.present(alert, animated: true, completion: nil)
    }
    
    func noBudgetWarning() {
        let message = popupMessages["noBudget"]
        
        var alert = UIAlertController(title: message?[0], message: message?[1], preferredStyle: .alert)
        alert = UIAlertController(title: message?[0], message: message?[1], preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
            self.viewController.performSegue(withIdentifier: "proceedToCheckout", sender: self)
        }))
        
        self.viewController.present(alert, animated: true, completion: nil)
    }
        
    func categoryError() {
        let message = popupMessages["noCategory"]
        
        var alert = UIAlertController(title: message?[0], message: message?[1], preferredStyle: .alert)
        alert = UIAlertController(title: message?[0], message: message?[1], preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
            self.viewController.loadScanner()
            self.viewController.progressHUD.isHidden = true
        }))
        
        self.viewController.present(alert, animated: true, completion: nil)
    }
    
    func pendingError() {
        let message = popupMessages["shopkeeperPending"]
        
        var alert = UIAlertController(title: message?[0], message: message?[1], preferredStyle: .alert)
        alert = UIAlertController(title: message?[0], message: message?[1], preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
            self.viewController.loadScanner()
            self.viewController.progressHUD.isHidden = true
        }))
        
        self.viewController.present(alert, animated: true, completion: nil)
    }
    
    func authorizeToken(_ code: String) {
        Alamofire.request(baseURL+"shop-keepers/devices/token/\(code)", method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            self.viewController.loadScanner()
            self.viewController.progressHUD.isHidden = true
        }
    }
    
    func getRefundAmount() {
        Alamofire.request(baseURL+"refund/amount", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    let data = JSON(data: json)
                    print("refund amount: \(data)")
                    let amount = data["amount"]
                    if amount > 0.0 {
                        self.viewController.refundView.isHidden = false
                        self.viewController.refundLabel.text = "Openstaand: €\(Double(round(100*amount.double!)/100))"
                    }
                }
        }
    }
    
    func payDebt() {
        viewController.progressHUD.isHidden = false
        Alamofire.request(baseURL+"refund/link", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    self.viewController.progressHUD.isHidden = true
                    
                    let data = JSON(data: json)
                    let url = String(describing: data["url"])
                    UIApplication.shared.openURL(URL(string: url)!)
                }
        }
    }
    
    init(viewController: ScannerViewController) {
        self.viewController = viewController
    }

}
