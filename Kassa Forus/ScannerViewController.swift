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

class ScannerViewController: UIViewController, QRCodeReaderViewControllerDelegate {
    
    @IBOutlet weak var instruction: UILabel!
    @IBOutlet weak var refundLabel: UILabel!
    
    var progressHUD = UIVisualEffectView()
    
    var model: ScannerModel?
    
    @IBOutlet weak var previewView: UIView!
    
    @IBAction func settleDebt(_ sender: Any) {
        // get and open payment url
        payDebt()
    }
    
    
    lazy var reader: QRCodeReader = QRCodeReader()
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [AVMetadataObject.ObjectType.qr.rawValue], captureDevicePosition: .back)
            $0.showTorchButton = false
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    // MARK: - Actions
    
    func loadScanner() {
        guard (model?.checkScanPermissions())!, !reader.isRunning else { return }
        
        reader.previewLayer.frame = previewView.bounds
        previewView.layer.addSublayer(reader.previewLayer)
        
        reader.startScanning()
        reader.didFindCode = { result in
            self.progressHUD.isHidden = false
            self.model?.scanResult = result.value
            self.model?.checkCode((self.model?.scanResult)!)
        }
    }
    
    func displayDeviceAddedConfirmation() {
        self.progressHUD.isHidden = true
        
        let alert = UIAlertController(title: "Success", message: "Dit apparaat is succesvol toegevoegd", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in
            self.model?.addingDevice = false
            self.instruction.text = "Scan de code op de voucher van een klant."
            self.loadScanner()
            self.showAddDeviceButton()
        }))
        
        self.present(alert, animated: true)
    }
    
    // MARK: - QRCodeReader Delegate Methods
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        
        dismiss(animated: true) { [weak self] in
            self?.model?.scanResult = result.value
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
        
        model = ScannerModel(viewController: self)
        
        if !(model?.addingDevice)! {
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
        setHeaderAndToken()
        
        if !loadSetup() {
            loadScanner()
        }
    }
    
    func setHeaderAndToken() {
        headers["Device-Id"] = UIDevice.current.identifierForVendor!.uuidString
        
        if let token = UserDefaults.standard.value(forKey: "APItoken") {
            headers["Authorization"] = "Bearer \(token)"
        }
    }
    
    func loadSetup() -> Bool {
        if !(model?.addingDevice)! {
            if UserDefaults.standard.value(forKey: "APItoken") == nil {
                performSegue(withIdentifier: "loadSetup", sender: self)
                return true
            }
            
            if let registrationStatus = UserDefaults.standard.value(forKey: "registrationStatus") as? String {
                if registrationStatus == "pending" {
                    performSegue(withIdentifier: "loadSetup", sender: self)
                    return true
                }
            }
        }
        
        return false
    }
    
    func getRefundAmount() {
        Alamofire.request("http://test-mvp.forus.io/api/refund/amount", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    let data = JSON(data: json)
                    print("refund amount: \(data)")
                    let amount = data["amount"]
                    print(amount)
                    self.refundLabel.text = "Openstaand: €\(amount)"
                }
        }
    }
    
    func payDebt() {
        Alamofire.request("http://test-mvp.forus.io/api/refund/link", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    let data = JSON(data: json)
                    print("refund link: \(data)")
                    let url = String(describing: data["url"])
                    UIApplication.shared.openURL(URL(string: url)!)
                }
        }
    }
    
    override func viewDidLoad() {
        progressHUD = ProgressHUDView(text: "Verzenden")
        self.view.addSubview(progressHUD)
        self.progressHUD.isHidden = true
        
        delay(0.2) {
            self.getRefundAmount()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let target = segue.destination as? CheckoutViewController {
            target.availableBudget = (self.model?.budget)!
            target.voucherCode = (self.model?.scanResult)!
            self.progressHUD.isHidden = true	
        }
    }
}
