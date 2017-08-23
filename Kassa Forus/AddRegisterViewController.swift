//
//  AddRegisterViewController.swift
//  Kassa Forus
//
//  Created by Jamal on 23/08/2017.
//  Copyright © 2017 Forus. All rights reserved.
//

import UIKit

class AddRegisterViewController: UIViewController {

    @IBOutlet weak var qrCode: UIImageView!
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 50, y: 50)
            
            if let output = filter.outputImage?.applying(transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let message = generateQRCode(from: "test")
        
        qrCode.image = message
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
