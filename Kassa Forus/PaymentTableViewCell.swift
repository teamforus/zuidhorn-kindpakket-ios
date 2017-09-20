//
//  PaymentTableViewCell.swift
//  Kassa Forus
//
//  Created by Jamal on 20/09/2017.
//  Copyright © 2017 Forus. All rights reserved.
//

import UIKit

class PaymentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var returnButton: UIButton!
    
    @IBAction func returnButton(_ sender: Any) {
        print(self.tag)
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
