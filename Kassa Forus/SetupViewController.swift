//
//  SetupViewController.swift
//  Kassa Forus
//
//  Created by Jamal on 21/07/2017.
//  Copyright © 2017 Forus. All rights reserved.
//


import UIKit
import Alamofire
import SwiftyJSON

class SetupViewController: UIViewController {

    @IBOutlet weak var setupView: UIView!
    @IBOutlet weak var pendingView: UIView!
    
    @IBAction func cancelRequest(_ sender: Any) {
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated:true)
        
        if let registrationStatus = UserDefaults.standard.value(forKey: "registrationStatus") as? String {
            if registrationStatus == "pending" {
                setupView.isHidden = true
                getStatus()
            }
        } else {
            pendingView.isHidden = true
        }
    }
    
    func getStatus() {
        Alamofire.request("http://mvp.forus.io/api/user", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if let json = response.data {
                let data = JSON(data: json)
                if data["shop_keeper"]["state"] == "approved" {
                    let alert = UIAlertController(title: "Aanvraag afgerond.", message: "U kunt vanaf nu vouchers scannen.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Open Scanner", style: .cancel, handler: { (_) in
                        UserDefaults.standard.setValue("approved", forKey: "registrationStatus")
                        self.performSegue(withIdentifier: "loadScanner", sender: self)
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector:#selector(getStatus), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
