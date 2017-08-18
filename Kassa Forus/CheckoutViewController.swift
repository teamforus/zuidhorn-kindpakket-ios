//
//  CheckoutViewController.swift
//  Kassa Forus
//
//  Created by Jamal on 21/07/2017.
//  Copyright © 2017 Forus. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class CheckoutViewController: UIViewController {

    @IBOutlet weak var budgetLabel: UILabel!
    @IBOutlet weak var expenceInputField: UITextField!
    
    var availableBudget = Double()
    var voucherCode = String()
    
    @IBAction func confirmationButton(_ sender: Any) {
        if let amount = expenceInputField.text?.doubleValue {
            let refreshAlert = UIAlertController(title: "Betaling: €\(String(format: "%.2f", arguments: [amount]))", message: "Wilt u deze transactie uitvoeren?", preferredStyle: UIAlertControllerStyle.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Bevestig", style: .default, handler: { (action: UIAlertAction!) in
                self.processPaymentFor(self.voucherCode, amount: amount)
                self.expenceInputField.text = ""
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "Annuleer", style: .cancel, handler: { (action: UIAlertAction!) in
                print("Handle Cancel Logic here")
            }))
            
            present(refreshAlert, animated: true, completion: nil)
        }
    }
    
    func processPaymentFor(_ code: String, amount: Double) {
        Alamofire.request("http://mvp.forus.io/app/voucher/\(code)", method: .post, parameters: ["amount": "\(amount)", "_method": "PUT"], encoding: JSONEncoding.default)
            .responseJSON { response in
                self.updateBudget()
        }
    }
    
    func updateBudget() {
        Alamofire.request("http://mvp.forus.io/app/voucher/\(voucherCode)", method: .get, parameters: nil, encoding: JSONEncoding.default)
            .responseJSON { response in
            if let json = response.data {
                let data = JSON(data: json)
                let max_amount = data["response"]["max_amount"]
                if let amount = max_amount.double {
                    self.budgetLabel.text = "€\(String(format: "%.2f", arguments: [amount]))"
                } else {
                    let alert = UIAlertController(title: "Error", message: "De transactie is mislukt, controleer uw verbinding en probeer het opnieuw.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // todo: check if budget > 0
        self.budgetLabel.text = "€\(String(format: "%.2f", arguments: [availableBudget]))"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
