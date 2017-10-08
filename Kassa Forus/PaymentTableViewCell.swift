//
//  PaymentTableViewCell.swift
//  Kassa Forus
//
//  Created by Jamal on 20/09/2017.
//  Copyright © 2017 Forus. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class PaymentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var returnButton: UIButton!
    
    @IBAction func returnButton(_ sender: Any) {
        print(self.tag)
        
        returnTransaction(id: self.tag)
        // return the transaction with this tag
    }
    
    func returnTransaction(id: Int) {
        let url = baseURL+"vouchers/\(voucher)/transactions/\(id)/refund"

        Alamofire.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if let json = response.data {
                let data = JSON(data: json)
                print(data)
            }
            print(response)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
