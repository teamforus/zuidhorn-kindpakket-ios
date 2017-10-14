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

var scannerVC = ScannerViewController() // workaround

class ScannerViewController: UIViewController, QRCodeReaderViewControllerDelegate {
    
    @IBOutlet weak var instruction: UILabel!
    @IBOutlet weak var refundLabel: UILabel!
    @IBOutlet weak var refundView: UIView!
    
    var progressHUD = UIVisualEffectView()
    
    var model: ScannerModel?
    
    @IBOutlet weak var previewView: UIView!
    
    @IBAction func settleDebt(_ sender: Any) {
        model?.payDebt()
    }
    
    lazy var reader: QRCodeReader = QRCodeReader()
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [AVMetadataObject.ObjectType.qr.rawValue], captureDevicePosition: .back)
            $0.showTorchButton = false
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
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
    
    @objc func showToken() {
        self.performSegue(withIdentifier: "showToken", sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        model = ScannerModel(viewController: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        model?.setHeaderAndToken()
        
        if !loadSetup() {
            loadScanner()
        }
    }
    
    func loadSetup() -> Bool {
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
        
        return false
    }
    
    override func viewDidLoad() {
        navigationItem.setHidesBackButton(true, animated:false)
        progressHUD = ProgressHUDView(text: "Verzenden")
        self.view.addSubview(progressHUD)
        self.progressHUD.isHidden = true
        
        refundView.isHidden = true
        scannerVC = self
        
        delay(0.2) {
            self.model?.getRefundAmount()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let target = segue.destination as? CheckoutViewController {
            target.availableBudget = self.model!.budget
            target.voucherCode = self.model!.scanResult
            self.progressHUD.isHidden = true	
        }
    }
}
