//
//  RegistrationViewController.swift
//  Kassa Forus
//
//  Created by Jamal on 21/08/2017.
//  Copyright © 2017 Forus. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class RegistrationViewController: UIViewController {

    @IBOutlet weak var KVKInput: UITextField!
    @IBOutlet weak var IBANInput: UITextField!
    @IBOutlet weak var IBANNameInput: UITextField!
    @IBOutlet weak var emailInput: UITextField!
    
    @IBAction func registerButton(_ sender: Any) {
        signup(kvk: KVKInput.text!, iban: IBANInput.text!, email: emailInput.text!)
    }
    
    func signup(kvk: String, iban: String, email: String) {
        Alamofire.request("http://mvp.forus.io/api/shop-keeper/sign-up", method: .post, parameters: [
            "kvk_number": "\(kvk)",
            "iban": "\(iban)",
            "email": "\(email)"
        ], encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if let json = response.data {
                let data = JSON(data: json)
                let token = data["access_token"]
                UserDefaults.standard.setValue(String(describing: token), forKey: "APItoken")
                headers["Authorization"] = "Bearer \(token)"
                self.performSegue(withIdentifier: "loadScanner", sender: self)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
