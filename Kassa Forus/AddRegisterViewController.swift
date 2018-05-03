//
//  AddRegisterViewController.swift
//  Kassa Forus
//
//  Created by Jamal on 23/08/2017.
//  Copyright © 2017 Forus. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AddRegisterViewController: UIViewController {

    @IBOutlet weak var qrCode: UIImageView!
    
    var token = String()
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 50, y: 50)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
    
    func getToken() {
        Alamofire.request(baseURL+"shop-keepers/devices/token", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if let json = response.data {
                let data = JSON(data: json)
                self.token = String(describing: data["token"])
                if self.token.count > 10 {
                    let tokenQR = self.generateQRCode(from: self.token)
                    self.qrCode.image = tokenQR
                    
                    self.startStatusChecker()
                } else {
                    self.displayConnectionError()
                }
            }
        }
    }
    
    func displayConnectionError() {
        let message = popupMessages["noConnection2"]
        
        let alert = UIAlertController(title: message?[0], message: message?[1], preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
            self.navigationController?.popViewController(animated: true)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }

    
    var statusChecker = Timer()

    @objc func startStatusChecker() {
        if statusChecker.isValid {
            self.statusChecker.invalidate()
        } else {
            self.statusChecker = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(getRegistrationStatus), userInfo: nil, repeats: true)
        }
    }
    
    func stopStatusChecker() {
        if statusChecker.isValid {
            self.statusChecker.invalidate()
        }
    }
    
    @objc func getRegistrationStatus() {
        Alamofire.request(baseURL+"shop-keepers/devices/token/\(token)/state", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if let json = response.data {
                let data = JSON(data: json)
                if data["authorized"] == true {
                    self.stopStatusChecker()
                    
                    let token = data["access_token"]
                    UserDefaults.standard.setValue(String(describing: token), forKey: "APItoken")
                    UserDefaults.standard.setValue("approved", forKey: "registrationStatus")
                    headers["Authorization"] = "Bearer \(token)"
                    
                    self.performSegue(withIdentifier: "openScanner", sender: self)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let target = segue.destination as? ScannerViewController {
            target.navigationItem.setHidesBackButton(true, animated:false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getToken()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
