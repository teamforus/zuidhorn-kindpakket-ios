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
    
    var progressHUD = UIVisualEffectView()
    
    var iban = String()
    var ibanValid = false
    var ibanName = String()
    var ibanNameValid = true // TODO: add iban name check when available
    var kvk = String()
    var kvkValid = true // TODO: set to false
    var email = String()
    var emailValid = false
    
    var signupAttempted = false
    var displayingError = false
    
    let KVKErrorMessage = "Vul a.u.b. een geldig KVK nummer in."
    let IBANErrorMessage = "Vul a.u.b. een geldig IBAN nummer in."
    let IBANNameErrorMessage = "Vul a.u.b. een geldige IBAN rekeninghouder in."
    let emailErrorMessage = "Vul a.u.b. een geldig email adres in."
    
    @IBAction func autofill(_ sender: Any) {
        KVKInput.text = "69488266"
        IBANInput.text = "NL88BUNQ2025155751"
        IBANNameInput.text = "Jamals Voetbals"
        emailInput.text = "xyz@stichtingforus.nl"
    }
    
    @IBAction func registerButton(_ sender: Any) {
        self.progressHUD.isHidden = false
        
//        check(kvk: KVKInput.text!)
        kvk = KVKInput.text!
        check(iban: IBANInput.text!)
        check(ibanName: IBANNameInput.text!)
        check(email: emailInput.text!)
        attemptSignup()
    }
    
    func check(kvk: String) {
        let kvkKey = "l7xx45d657b473d94db29e58337db156ca29"
        
        if kvk != "" {
            self.kvk = kvk
            if !kvkValid {
                Alamofire.request("https://api.kvk.nl/api/v2/profile/companies?q=\(kvk)&user_key=\(kvkKey)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                    if let json = response.data {
                        let data = JSON(data: json)
                        if data["error"]["message"] == "NotFound" {
                            self.display(error: self.KVKErrorMessage)
                        } else {
                            print("kvk valid: \(data["data"]["items"][0]["tradeNames"]["businessName"])")
                            self.kvkValid = true
                            self.attemptSignup()
                        }
                    }
                }
            }
        } else {
            display(error: KVKErrorMessage)
        }
    }
    
    func check(iban: String) {
        if iban != "" {
            self.iban = iban
            if !ibanValid {
                Alamofire.request("https://openiban.com/validate/\(iban)?getBIC=false&validateBankCode=true", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                    if let json = response.data {
                        let data = JSON(data: json)
                        if data["valid"] == true {
                            print("iban valid!")
                            self.ibanValid = true
                            self.attemptSignup()
                        } else {
                            self.display(error: self.IBANErrorMessage)
                        }
                    }
                }
            }
        } else {
            display(error: IBANErrorMessage)
        }
    }
    
    func check(ibanName: String) {
        if ibanName != "" {
            self.ibanName = ibanName
        } else {
            display(error: IBANNameErrorMessage)
        }
    }
    
    func check(email: String) {
        self.email = email
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        if emailTest.evaluate(with: email) {
            emailValid = true
            self.attemptSignup()
        } else {
            display(error: emailErrorMessage)
        }
    }
    
    func attemptSignup() {
        if !self.signupAttempted {
            if ibanValid && ibanNameValid && kvkValid && emailValid {
                signupAttempted = true
                print("signup attempted using: \(kvk) \(iban) \(email)")
                
                Alamofire.request(baseURL+"shop-keepers/sign-up", method: .post, parameters: [
                    "kvk_number": "\(kvk)",
                    "iban": "\(iban)",
                    "email": "\(email)"
                ], encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                    if let data = response.data {
                        self.processSignup(json: data)
                    } else {
                        print("no server response") // Todo: make error
                    }
                }
            }
        }
    }
    
    func processSignup(json: Data) {
        if json.isEmpty {
            noData()
        } else {
            let data = JSON(data: json)

            if data["token_type"] == "Bearer" {
                completeSignup(data: data)
            } else {
                displayError(error: data)
            }
        }
    }
    
    func displayError(error: JSON) {
        let alert = UIAlertController(title: "Foutmelding", message: "Er ging iets fout: \(error)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in
            self.progressHUD.isHidden = true
            self.signupAttempted = false
        }))
        
        self.present(alert, animated: true)
    }
    
    func completeSignup(data: JSON) {
        let token = data["access_token"]
        UserDefaults.standard.setValue(String(describing: token), forKey: "APItoken")
        UserDefaults.standard.setValue("pending", forKey: "registrationStatus")
        headers["Authorization"] = "Bearer \(token)"
        
        self.returnToSetup()
    }
    
    func noData() {
        let message = popupMessages["noConnection2"]
        
        let alert = UIAlertController(title: message?[0], message: message?[1], preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in
            self.progressHUD.isHidden = true
            self.signupAttempted = false
        }))
        
        self.present(alert, animated: true)
    }
    
    func display(error: String) {
        if !displayingError {
            displayingError = true
            progressHUD.isHidden = true
            let alert = UIAlertController(title: "Error", message: "\(error)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in
                self.displayingError = false
            }))
            
            self.present(alert, animated: true)
        }
    }
    
    func returnToSetup() {
        self.performSegue(withIdentifier: "returnToSetup", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressHUD = ProgressHUDView(text: "Verzenden")
        self.view.addSubview(progressHUD)
        self.progressHUD.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
