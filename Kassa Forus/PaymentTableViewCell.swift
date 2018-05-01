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
        let message = popupMessages["confirmRefund"]
        
        let alert = UIAlertController(title: message?[0], message: message?[1], preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Bevestig", style: .default, handler: { (_) in
            self.initiateRefund()
        }))
        
        alert.addAction(UIAlertAction(title: "Annuleer", style: .cancel, handler: { (_) in
            // cancel logic
        }))
        
        checkoutVC.present(alert, animated: true, completion: nil)
    }
    
    func initiateRefund() {
        Alamofire.request(baseURL+"vouchers/\(voucher)/transactions", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    let data = JSON(data: json)
                    print(data)
                    if let amount = data.array?.count {
                        for i in 0 ..< amount {
                            if data[i]["id"].int == self.tag {
                                self.performRefund(extraAmount: data[i]["extra_amount"].double!)
                            }
                        }
                    }
                }
        }
    }
    
    func performRefund(extraAmount: Double) {
        print("perform refund, extra amount: \(extraAmount)")
        if extraAmount > 0.0 {
            let alert = UIAlertController(title: "Bijbetaling", message: "Bevestig dat u de klant €\(extraAmount) uit de kassa heeft terug betaald om deze retournerening af te ronden.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Bevestig", style: .default, handler: { (_) in
                self.finishRefund()
            }))
            
            alert.addAction(UIAlertAction(title: "Annuleer", style: .cancel, handler: { (_) in
                // cancel logic
            }))
            
            checkoutVC.present(alert, animated: true, completion: nil)
        } else {
            print("finish refund")
            finishRefund()
        }
    }
    
    func finishRefund() {
        checkoutVC.progressHUD.isHidden = false
        let url = baseURL+"vouchers/\(voucher)/transactions/\(self.tag)/refund"
        
        Alamofire.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if let json = response.data {
                let data = JSON(data: json)
                print(json)

                print(data)
                
                if data["status"] == "refunded" {
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
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            checkoutVC.performSegue(withIdentifier: "returnToScanner", sender: self)
        }))
        
        checkoutVC.progressHUD.isHidden = true
        checkoutVC.present(alert, animated: true)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if refundedTransactions.contains(self.tag) {returnButton.isEnabled = false}
        
        print("tag is: \(self.tag)")
        // Configure the view for the selected state
    }
}
