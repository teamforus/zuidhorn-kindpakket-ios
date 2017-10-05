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
    
    var statusChecker = Timer()
    var registrationApproved = false
    
    @IBAction func cancelRequest(_ sender: Any) {
        // todo: add cancel logic
    }
    
    @IBAction func addRegister(_ sender: Any) {
        self.performSegue(withIdentifier: "loadScanner", sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated:true)
        
        checkRegistrationStatus()
    }
    
    func checkRegistrationStatus() {
        if let registrationStatus = UserDefaults.standard.value(forKey: "registrationStatus") as? String {
            if registrationStatus == "pending" {
                setupView.isHidden = true
                startStatusChecker()
            }
        } else {
            pendingView.isHidden = true
        }
    }
    
    @objc func getRegistrationStatus() {
        Alamofire.request("http://test-mvp.forus.io/api/user", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if let json = response.data {
                let data = JSON(data: json)
                print("status: \(data)")
                if data["shop_keeper"]["state"] == "approved" {
                    self.approveRegistration()
                }
            }
        }
    }
    
    func approveRegistration() {
        stopStatusChecker()
        registrationApproved = true
        
        UserDefaults.standard.setValue("approved", forKey: "registrationStatus")
        
        let alert = UIAlertController(title: "Aanvraag afgerond.", message: "U kunt vanaf nu vouchers scannen.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Open Scanner", style: .cancel, handler: { (_) in
            self.performSegue(withIdentifier: "loadScanner", sender: self)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func startStatusChecker() {
        let registrationStatus = UserDefaults.standard.value(forKey: "registrationStatus") as? String
        
        if registrationStatus == "pending" {
            if statusChecker.isValid {
                self.statusChecker.invalidate()
            } else {
                self.statusChecker = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(getRegistrationStatus), userInfo: nil, repeats: true)
            }
        }
    }
    
    func stopStatusChecker() {
        if statusChecker.isValid {
            self.statusChecker.invalidate()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector:#selector(startStatusChecker), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let target = segue.destination as? ScannerViewController {
            if !registrationApproved {
                target.addingDevice = true
                let backItem = UIBarButtonItem()
                navigationItem.backBarButtonItem = backItem
            }
        } 
    }
}
