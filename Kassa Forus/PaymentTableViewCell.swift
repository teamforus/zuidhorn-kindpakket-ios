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
    
    @IBAction func returnButton(_ sender: Any) {
        confirmRefund()
    }
    
    func confirmRefund() {
        let alert = UIAlertController(title: "Retournering", message: "Weet je zeker dat je deze betaling wil retourneren?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Bevestig", style: .default, handler: { (_) in
            self.refund()
        }))
        
        alert.addAction(UIAlertAction(title: "Annuleer", style: .cancel, handler: { (_) in
            // cancel logic
        }))
        
        checkoutVC.present(alert, animated: true, completion: nil)
    }
    
    func refund() {
        let url = baseURL+"vouchers/\(voucher)/transactions/\(self.tag)/refund"

        Alamofire.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if let json = response.data {
                let data = JSON(data: json)
                
                if data["status"] == "refund" {
                    refundedTransactions.append(self.tag)
                    self.displaySuccessAlert()
                    checkoutVC.tableView.reloadData()
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if refundedTransactions.contains(self.tag) {returnButton.isEnabled = false}
        
        print("tag is: \(self.tag)")
        // Configure the view for the selected state
    }
}
