//
//  CheckoutModel.swift
//  Checkout Forus
//
//  Created by Jamal on 07/10/2017.
//  Copyright © 2017 Forus. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

var refundedTransactions: [Int] = []

class CheckoutModel {
    
    var viewController: CheckoutViewController
    
    var transactionsJSON = JSON()
    var transactions: [Transaction] = []
    
    struct Transaction {
        var date = String()
        var amount = Double()
        var id = Int()
        
        init(date: String, amount: Double, id: Int) {
            self.date = date
            self.amount = amount
            self.id = id
        }
    }
    
    func loadTransactions() {
        if let amount = transactionsJSON.array?.count {
            for i in 0 ..< amount {
                
                let transaction = transactionsJSON[i]
                
                let id = transaction["id"].int
                let amount = transaction["amount"].double
                let date = transaction["created_at"].string
                
                if transaction["status"] == "refund" {refundedTransactions.append(id!)}
                
                transactions.append(Transaction(date: date!, amount: amount!, id: id!))
            }
        }
        
        self.viewController.tableView.reloadData()
    }
    
    func confirmPayment() {
        let maxUserSpendable = viewController.availableBudget
        let paymentRequestAmount = viewController.expenceInputField.text!.doubleValue
        
        if maxUserSpendable >= paymentRequestAmount {
            self.payWithSufficientBudget()
        } else if maxUserSpendable < paymentRequestAmount {
            self.pay(spendable: maxUserSpendable, amount: paymentRequestAmount)
        } else {
            self.viewController.displayTransactionError()
        }
    }
    
    func getTransactions() {
        Alamofire.request(baseURL+"vouchers/\(viewController.voucherCode)/transactions", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    let data = JSON(data: json)
                    
                    self.transactionsJSON = data
                    self.loadTransactions()
                }
        }
    }
    
    func payWithSufficientBudget() {
        if let amount = viewController.expenceInputField.text?.doubleValue {
            let refreshAlert = UIAlertController(title: "Betaling: €\(String(format: "%.2f", arguments: [amount]))", message: "Wilt u deze transactie uitvoeren?", preferredStyle: UIAlertControllerStyle.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Bevestig", style: .default, handler: { (action: UIAlertAction!) in
                self.viewController.progressHUD.isHidden = false
                self.processPaymentFor(self.viewController.voucherCode, amount: amount)
                self.viewController.expenceInputField.text = ""
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "Annuleer", style: .cancel, handler: { (action: UIAlertAction!) in
                print("Handle Cancel Logic here")
            }))
            
            viewController.present(refreshAlert, animated: true, completion: nil)
        }
    }
    
    func pay(spendable: Double, amount: Double) {
        let refreshAlert = UIAlertController(title: "Overschrijding", message: "Deze transactie overschrijd het budget van de klant met: €\(String(format: "%.2f", arguments: [abs(spendable-amount)]))", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Klant betaalt bij", style: .default, handler: { (action: UIAlertAction!) in
            self.exeedingPayment(spendable: spendable, amount: amount)
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Annuleer", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))
        
        viewController.present(refreshAlert, animated: true, completion: nil)
    }
    
    func exeedingPayment(spendable: Double, amount: Double) {
        let refreshAlert = UIAlertController(title: "Bevestig", message: "Bevestig dat de klant €\(String(format: "%.2f", arguments: [abs(spendable-amount)])) heeft bijbetaald.", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Bevestig", style: .default, handler: { (action: UIAlertAction!) in
            self.viewController.progressHUD.isHidden = false
            self.processPaymentFor(self.viewController.voucherCode, amount: spendable)
            self.viewController.expenceInputField.text = ""
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Annuleer", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))
        
        viewController.present(refreshAlert, animated: true, completion: nil)
    }
    
    func processPaymentFor(_ code: String, amount: Double) {
        Alamofire.request(baseURL+"vouchers/\(code)/transactions", method: .post, parameters: [
            "amount": "\(amount)",
            "extra_amount": "0"
            ], encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                
                print(response)
                self.viewController.progressHUD.isHidden = true
                
                let alert = UIAlertController(title: "Success", message: "De transactie was successvol", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Open Scanner", style: .cancel, handler: { (action: UIAlertAction!) in
                    self.viewController.performSegue(withIdentifier: "returnToScanner", sender: self)
                }))
                
                self.viewController.present(alert, animated: true)
        }
    }
    
    init(viewController: CheckoutViewController) {
        self.viewController = viewController
    }
}
