//
//  CheckoutViewController.swift
//  Kassa Forus
//
//  Created by Jamal on 21/07/2017.
//  Copyright © 2017 Forus. All rights reserved.
//

import UIKit

class CheckoutViewController: UIViewController {

    @IBOutlet weak var budgetLabel: UILabel!
    
    var availableBudget = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // check if budget > 0
        // 
        
        delay(0.5) { 
            self.budgetLabel.text = self.availableBudget
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
