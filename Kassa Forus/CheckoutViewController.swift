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
            processPaymentFor(voucherCode, amount: amount)
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
