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
// todo: check if budget > 0

class CheckoutViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource {

    @IBOutlet weak var expenceInputField: UITextField!
    
    var model: CheckoutModel?
    
    var availableBudget = Double()
    var voucherCode = String()
    
    var progressHUD = UIVisualEffectView()
    
    var tableView = UITableView()
    
    @IBAction func confirmationButton(_ sender: Any) {
        model?.confirmPayment()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.tableView = tableView
        return (model?.transactions.count)!  // if transactions = 0, hide tableview
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.selectionStyle = .none
        
        let transaction = model!.transactions[indexPath.item]

        cell.textLabel?.text = String("€ \(transaction.amount)")
        cell.detailTextLabel?.text = transaction.date
        cell.tag = transaction.id
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Transactie geschiedenis"
    }
    
    func displayTransactionError() {
        let alert = UIAlertController(title: "Error", message: "De transactie is mislukt, controleer uw verbinding en probeer het opnieuw.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        model?.confirmPayment()
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        model = CheckoutModel(viewController: self)
        voucher = voucherCode // temp
        model!.getTransactions() // temp
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        expenceInputField.delegate = self

        progressHUD = ProgressHUDView(text: "Verzenden")
        self.view.addSubview(progressHUD)
        self.progressHUD.isHidden = true
        
        expenceInputField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
