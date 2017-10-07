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
    
    var addingDevice = false
    
    func checkScanPermissions() -> Bool {
        do {
            return try QRCodeReader.supportsMetadataObjectTypes()
        } catch let error as NSError {
            let alert: UIAlertController?
            
            switch error.code {
            case -11852:
                alert = UIAlertController(title: "Error", message: "This app is not authorized to use Back Camera.", preferredStyle: .alert)
                
                alert?.addAction(UIAlertAction(title: "Setting", style: .default, handler: { (_) in
                    DispatchQueue.main.async {
                        if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
                            UIApplication.shared.openURL(settingsURL)
                        }
                    }
                }))
                
                alert?.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            case -11814:
                alert = UIAlertController(title: "Error", message: "Reader not supported by the current device", preferredStyle: .alert)
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
    
    func checkCode(_ code: String) {
        if addingDevice {
            addDevice(code)
        } else {
            checkVoucher(code)
        }
    }
    
    func checkVoucher(_ code: String) {
        Alamofire.request("http://test-mvp.forus.io/api/vouchers/\(code)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if let json = response.data {
                let data = JSON(data: json)
                let max_amount = data["max_amount"]
                
                if max_amount.doubleValue != 0.0 {
                    self.budget = max_amount.doubleValue
                    self.viewController.performSegue(withIdentifier: "proceedToCheckout", sender: self)
                } else {
                    let alert = UIAlertController(title: "Error", message: "Dit is geen valide voucher of er was een verbindingsprobleem.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
                        self.viewController.loadScanner()
                        self.viewController.progressHUD.isHidden = true
                    }))
                    
                    self.viewController.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func addDevice(_ code: String) {
        Alamofire.request("http://test-mvp.forus.io/api/shop-keepers/device", method: .post, parameters: ["token": "\(code)"], encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if let json = response.data {
                // TODO: check for positive confirmation
                let data = JSON(data: json)
                let token = data["access_token"]
                UserDefaults.standard.setValue(String(describing: token), forKey: "APItoken")
                UserDefaults.standard.setValue("approved", forKey: "registrationStatus")
                headers["Authorization"] = "Bearer \(token)"
                
                self.viewController.displayDeviceAddedConfirmation()
            }
        }
    }
    
    init(viewController: ScannerViewController) {
        self.viewController = viewController
    }

}
