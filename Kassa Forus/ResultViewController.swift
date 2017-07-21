//
//  ResultViewController.swift
//  Kassa Forus
//
//  Created by Jamal on 21/07/2017.
//  Copyright © 2017 Forus. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {
    
    @IBOutlet weak var resultField: UILabel!
    @IBOutlet weak var scanNewCodeButton: UIButton!
    
    var scanResult = String()
    
    @IBAction func scanNewCodeButton(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        self.resultField.text = scanResult
        
        delay(1) {
            if self.scanResult != "€120" {
                self.resultField.text = "Success!"
                
                delay(1) {
                    self.performSegue(withIdentifier: "proceedToCheckout", sender: self)
                }
            } else {
                self.resultField.text = "Deze code is ongeldig.\n Bel 0900-1234 als u \nniet verder komt."
                
                delay(1) {
                    self.scanNewCodeButton.isHidden = false
                }
            }
            
            
            
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let target = segue.destination as? CheckoutViewController {
            target.availableBudget = self.scanResult
        }
    }
}
