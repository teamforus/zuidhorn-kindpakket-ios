//: Playground - noun: a place where people can play

import UIKit
import Alamofire
import SwiftyJSON
import PlaygroundSupport

func checkCode(_ code: String) {
    Alamofire.request("http://mvp.forus.io/app/voucher/\(code)", method: .get, parameters: nil, encoding: JSONEncoding.default)
        .responseJSON { response in
        if let json = response.data {
            let data = JSON(data: json)
            let max_amount = data["response"]["max_amount"]
            if let amount = max_amount.double {
                print("€\(String(format: "%.2f", arguments: [amount]))")
            } else {
                print("error, probably not a voucher..")
            }
        }
    }
}


func processPaymentFor(_ code: String, amount: Double) {
    Alamofire.request("http://mvp.forus.io/app/voucher/\(code)", method: .post, parameters: ["amount": "\(amount)", "_method": "PUT"], encoding: JSONEncoding.default)
        .responseJSON { response in
        if let json = response.data {
            let data = JSON(data: json)
            print(data)
        }
    }
}


processPaymentFor("RJR5V8-WA83QF-JZLMRF-CFSRQS", amount: 1.05)
checkCode("RJR5V8-WA83QF-JZLMRF-CFSRQS")





PlaygroundPage.current.needsIndefiniteExecution = true
URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)