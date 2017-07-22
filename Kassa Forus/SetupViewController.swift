//
//  SetupViewController.swift
//  Kassa Forus
//
//  Created by Jamal on 21/07/2017.
//  Copyright © 2017 Forus. All rights reserved.
//


import UIKit

class SetupViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var shopNameInput: UITextField!
    @IBOutlet weak var shopIBANInput: UITextField!
    
    @IBAction func continueButton(_ sender: Any) {
        
        UserDefaults.standard.setValue(shopNameInput.text, forKey: "ShopName")
        UserDefaults.standard.setValue(shopIBANInput.text, forKey: "ShopIBAN")
        UserDefaults.standard.setValue(true, forKey: "setupComplete")
        
        performSegue(withIdentifier: "continueToQRScanner", sender: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
    
        self.shopNameInput.delegate = self;
        self.shopIBANInput.delegate = self;
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if UserDefaults.standard.value(forKey: "setupComplete") as? Bool == true && loadSetup == false {
            shopNameInput.isHidden = true
            shopIBANInput.isHidden = true
        }
        
        if loadSetup == true {loadSetup = false}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let target = segue.destination as? ScannerViewController {
//        }
//    }
}
