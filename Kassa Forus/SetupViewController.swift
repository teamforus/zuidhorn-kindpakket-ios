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
        revokeRegistration()
    }
    
    @IBAction func addRegister(_ sender: Any) {
        self.performSegue(withIdentifier: "loadScanner", sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated:true)
        
        checkRegistrationStatus()
    }
    
    func revokeRegistration() {
        let url = baseURL+"shop-keepers/revoke"
        
        Alamofire.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            self.pendingView.isHidden = true
            self.setupView.isHidden = false
            UserDefaults.standard.setValue(nil, forKey: "registrationStatus")
            self.stopStatusChecker()
        }
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
        Alamofire.request(baseURL+"user", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if let json = response.data {
                let data = JSON(data: json)
                print("\(data)")
                
                if data["shop_keeper"]["state"] == "declined" {
                    self.disapproveRegistration()
                }
                
                if data["shop_keeper"]["state"] == "approved" {
                    self.approveRegistration()
                }
            }
        }
    }
    
    func approveRegistration() {
        print("registration approved")
        stopStatusChecker()
        registrationApproved = true
        
        UserDefaults.standard.setValue("approved", forKey: "registrationStatus")
        
        let message = popupMessages["applicationFinished"]
        let alert = UIAlertController(title: message?[0], message: message?[1], preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Open Scanner", style: .cancel, handler: { (_) in
            self.performSegue(withIdentifier: "loadScanner", sender: self)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func disapproveRegistration() {
        stopStatusChecker()
        
        let message = popupMessages["applicationDisapproved"]
        let alert = UIAlertController(title: message?[0], message: message?[1], preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { (_) in
            UserDefaults.standard.setValue(nil, forKey: "APItoken")
            UserDefaults.standard.setValue(nil, forKey: "registrationStatus")
            headers["Authorization"] = nil
            
            self.pendingView.isHidden = true
            self.setupView.isHidden = false
            UserDefaults.standard.setValue(nil, forKey: "registrationStatus")
            self.stopStatusChecker()
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
        let rightButton: UIButton = UIButton(type: UIButtonType.infoLight)
        rightButton.addTarget(self, action: #selector(showInfo), for: UIControlEvents.touchUpInside)
        
        let rightBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: rightButton)
        self.navigationItem.setRightBarButton(rightBarButtonItem, animated: false)
        
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector:#selector(startStatusChecker), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    @objc func showInfo() {
        self.performSegue(withIdentifier: "showInfo", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
