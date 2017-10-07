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

var voucher = String() // temp; store in cell

class CheckoutViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource {

    @IBOutlet weak var expenceInputField: UITextField!
    
    var progressHUD = UIVisualEffectView()
    
    var availableBudget = Double()
    var voucherCode = String()
    
    var tableView = UITableView()
    
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
    
    @IBAction func confirmationButton(_ sender: Any) {
        confirmPayment()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.tableView = tableView
        return transactions.count  // if transactions = 0, hide tableview
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.selectionStyle = .none
        
        let transaction = transactions[indexPath.item]

        cell.textLabel?.text = String("€ \(transaction.amount)")
        cell.detailTextLabel?.text = transaction.date
        cell.tag = transaction.id
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Transactie geschiedenis"
    }
    
    func getTransactions() {
        Alamofire.request("http://test-mvp.forus.io/api/vouchers/\(voucherCode)/transactions", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.data {
                    let data = JSON(data: json)

                    self.transactionsJSON = data
                    self.loadTransactions()
                }
        }
    }
    
    func loadTransactions() {
        if let amount = transactionsJSON.array?.count {
            for i in 0 ..< amount {
                
                let transaction = transactionsJSON[i]
                
                let id = transaction["id"].int
                let amount = transaction["amount"].double
                let date = transaction["created_at"].string
                
                transactions.append(Transaction(date: date!, amount: amount!, id: id!))
            }
        }
        
        self.tableView.reloadData()
    }
    
    func confirmPayment() {
        let maxUserSpendable = self.availableBudget
        let paymentRequestAmount = self.expenceInputField.text!.doubleValue
        
        if maxUserSpendable >= paymentRequestAmount {
            self.payWithSufficientBudget()
        } else if maxUserSpendable < paymentRequestAmount {
            self.pay(spendable: maxUserSpendable, amount: paymentRequestAmount)
        } else {
            self.displayTransactionError()
        }
    }
    
    func displayTransactionError() {
        let alert = UIAlertController(title: "Error", message: "De transactie is mislukt, controleer uw verbinding en probeer het opnieuw.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    func payWithSufficientBudget() {
        if let amount = expenceInputField.text?.doubleValue {
            let refreshAlert = UIAlertController(title: "Betaling: €\(String(format: "%.2f", arguments: [amount]))", message: "Wilt u deze transactie uitvoeren?", preferredStyle: UIAlertControllerStyle.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Bevestig", style: .default, handler: { (action: UIAlertAction!) in
                self.progressHUD.isHidden = false
                self.processPaymentFor(self.voucherCode, amount: amount)
                self.expenceInputField.text = ""
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "Annuleer", style: .cancel, handler: { (action: UIAlertAction!) in
                print("Handle Cancel Logic here")
            }))
            
            present(refreshAlert, animated: true, completion: nil)
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
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    func exeedingPayment(spendable: Double, amount: Double) {
        let refreshAlert = UIAlertController(title: "Bevestig", message: "Bevestig dat de klant €\(String(format: "%.2f", arguments: [abs(spendable-amount)])) heeft bijbetaald.", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Bevestig", style: .default, handler: { (action: UIAlertAction!) in
            self.progressHUD.isHidden = false
            self.processPaymentFor(self.voucherCode, amount: spendable)
            self.expenceInputField.text = ""
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Annuleer", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    func processPaymentFor(_ code: String, amount: Double) {
        print(amount)
//        let extra = 15
        Alamofire.request("http://test-mvp.forus.io/api/vouchers/\(code)/transactions", method: .post, parameters: [
            "amount": "\(amount)",
            "extra_amount": "0"
            ], encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                
                print(response)
                self.progressHUD.isHidden = true
                
                let alert = UIAlertController(title: "Success", message: "De transactie was successvol", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Open Scanner", style: .cancel, handler: { (action: UIAlertAction!) in
                    self.performSegue(withIdentifier: "returnToScanner", sender: self)
                }))
                
                self.present(alert, animated: true)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        confirmPayment()
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // todo: check if budget > 0
        print("budget: \(availableBudget)")
        
        getTransactions() // temp
        
        expenceInputField.delegate = self

        progressHUD = ProgressHUDView(text: "Verzenden")
        self.view.addSubview(progressHUD)
        self.progressHUD.isHidden = true
        
        expenceInputField.becomeFirstResponder()
        
        voucher = voucherCode // temp
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
