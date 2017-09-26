//
//  ScannerViewController.swift
//  Kassa Forus
//
//  Created by Jamal on 21/07/2017.
//  Copyright © 2017 Forus. All rights reserved.
//

import AVFoundation
import QRCodeReader
import Alamofire
import SwiftyJSON
import UIKit
import EtherealCereal

class ScannerViewController: UIViewController, QRCodeReaderViewControllerDelegate {
    
    @IBOutlet weak var instruction: UILabel!
    
    var progressHUD = UIVisualEffectView()
    
    var scanResult = String()
    var budget = Double()
    
    var addingDevice = false
    
    @IBOutlet weak var previewView: UIView!
    
    lazy var reader: QRCodeReader = QRCodeReader()
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [AVMetadataObject.ObjectType.qr.rawValue], captureDevicePosition: .back)
            $0.showTorchButton = false
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    // MARK: - Actions
    
    private func checkScanPermissions() -> Bool {
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
            
            present(vc, animated: false, completion: nil)
            
            return false
        }
    }
    
    func loadScanner() {
        guard checkScanPermissions(), !reader.isRunning else { return }
        
        reader.previewLayer.frame = previewView.bounds
        previewView.layer.addSublayer(reader.previewLayer)
        
        reader.startScanning()
        reader.didFindCode = { result in
            self.progressHUD.isHidden = false
            self.scanResult = result.value
            self.checkCode(self.scanResult)
        }
    }
    
    func checkCode(_ code: String) {
        if !addingDevice {
            Alamofire.request("http://mvp.forus.io/api/voucher/\(code)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                if let json = response.data {
                    let data = JSON(data: json)
                    let max_amount = data["max_amount"]
                    
                    if max_amount.doubleValue != 0.0 {
                        self.budget = max_amount.doubleValue
                        self.performSegue(withIdentifier: "proceedToCheckout", sender: self)
                    } else {
                        let alert = UIAlertController(title: "Error", message: "Dit is geen valide voucher of er was een verbindingsprobleem.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
                            self.loadScanner()
                            self.progressHUD.isHidden = true
                        }))
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        } else {
            Alamofire.request("http://mvp.forus.io/api/shop-keeper/device", method: .post, parameters: ["token": "\(code)"], encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                if let json = response.data {
                    // TODO: check for positive confirmation
                    let data = JSON(data: json)
                    let token = data["access_token"]
                    UserDefaults.standard.setValue(String(describing: token), forKey: "APItoken")
                    UserDefaults.standard.setValue("approved", forKey: "registrationStatus")
                    headers["Authorization"] = "Bearer \(token)"
                    
                    // notification that it worked, then loadscanner
                    let alert = UIAlertController(title: "Success", message: "Dit apparaat is succesvol toegevoegd", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in
                        self.addingDevice = false
                        self.instruction.text = "Scan de code op de voucher van een klant."
                        self.loadScanner()
                        self.showAddDeviceButton()
                    }))
                    
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    // MARK: - QRCodeReader Delegate Methods
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        
        dismiss(animated: true) { [weak self] in
            self?.scanResult = result.value
        }
    }
    
    func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
        let cameraName = newCaptureDevice.device.localizedName
            
        print("Switching capturing to: \(cameraName)")
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !addingDevice {
            showAddDeviceButton()
        } else {
            instruction.text = "Scan de code op het andere apparaat."
        }
    }
    
    func showAddDeviceButton() {
        let leftButton: UIButton = UIButton(type: UIButtonType.contactAdd)
        leftButton.addTarget(self, action: #selector(ScannerViewController.showToken), for: UIControlEvents.touchUpInside)
        
        let leftBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: leftButton)
        self.navigationItem.setLeftBarButton(leftBarButtonItem, animated: false)
    }
    
    @objc func showToken() {
        self.performSegue(withIdentifier: "showToken", sender: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        headers["Device-Id"] = UIDevice.current.identifierForVendor!.uuidString
        
        if let token = UserDefaults.standard.value(forKey: "APItoken") {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        print("adding device = \(addingDevice)")
        
        if !addingDevice {
            if let registrationStatus = UserDefaults.standard.value(forKey: "registrationStatus") as? String {
                if registrationStatus == "pending" {
                    print("Registration pending!")
                    performSegue(withIdentifier: "loadSetup", sender: self)
                    return
                }
            }
            
            if UserDefaults.standard.value(forKey: "APItoken") == nil || loadSetup == true {
                performSegue(withIdentifier: "loadSetup", sender: self)
                loadSetup = false
            } else {
                loadScanner()
            }
        } else {
            loadScanner()
        }
    }
    
    override func viewDidLoad() {
        progressHUD = ProgressHUDView(text: "Verzenden")
        self.view.addSubview(progressHUD)
        self.progressHUD.isHidden = true
        
//        let etherealCereal = EtherealCereal()
//
//        let alert = UIAlertController(title: "Ethereum Keys", message: "Address: \(etherealCereal.address) \n Private key: \(etherealCereal.privateKey)", preferredStyle: .alert)
//
//        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let target = segue.destination as? CheckoutViewController {
            target.availableBudget = self.budget
            target.voucherCode = self.scanResult
            self.progressHUD.isHidden = true	
        }
    }
}
