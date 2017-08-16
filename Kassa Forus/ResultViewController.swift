//
//  ResultViewController.swift
//  Kassa Forus
//
//  Created by Jamal on 21/07/2017.
//  Copyright © 2017 Forus. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ResultViewController: UIViewController {
    
    @IBOutlet weak var resultField: UILabel!
    @IBOutlet weak var scanNewCodeButton: UIButton!
    
    var scanResult = String()
    var budget = Double()
    
    @IBAction func scanNewCodeButton(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        checkCode(scanResult)
    }
    
    func checkCode(_ code: String) {
        Alamofire.request("http://mvp.forus.io/app/voucher/\(code)", method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { response in
            if let json = response.data {
                let data = JSON(data: json)
                let max_amount = data["response"]["max_amount"]
                if let amount = max_amount.double {
                    self.budget = amount
                    self.performSegue(withIdentifier: "proceedToCheckout", sender: self)
                } else {
                    self.resultField.text = "Dit is waarschijnlijk geen\nkindpakket voucher."
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let target = segue.destination as? CheckoutViewController {
            target.availableBudget = self.budget
            target.voucherCode = self.scanResult
        }
    }
}
