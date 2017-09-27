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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getToken()
    }
    
    func getToken() {
        Alamofire.request("http://mvp.forus.io/api/shop-keeper/device/token", method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if let json = response.data {
                let data = JSON(data: json)
                let token = data["token"]
                
                print(String(describing: token))
                
                let message = self.generateQRCode(from: String(describing: token))
                self.qrCode.image = message
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
