//
//  PaymentTableViewCell.swift
//  Kassa Forus
//
//  Created by Jamal on 20/09/2017.
//  Copyright © 2017 Forus. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class PaymentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var returnButton: UIButton!
    
    var viewController = CheckoutViewController()
    
    @IBAction func returnButton(_ sender: Any) {
        refund(transaction: self.tag)
    }
    
    func refund(transaction id: Int) {
        let url = baseURL+"vouchers/\(voucher)/transactions/\(id)/refund"

        Alamofire.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if let json = response.data {
                let data = JSON(data: json)
                
                if data["status"] == "refund" {
                    self.displaySuccessAlert()
                    scannerVC.model?.getRefundAmount()
                }
            }
        }
    }
    
    func displaySuccessAlert() {
        let alert = UIAlertController(title: "Success", message: "Retournering geslaagd", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        checkoutVC.present(alert, animated: true)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
