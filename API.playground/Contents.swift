//: Playground - noun: a place where people can play

import UIKit
import Alamofire
import SwiftyJSON
import PlaygroundSupport


var headers: HTTPHeaders = [
    "Accept": "application/json",
    "Device-Id": "c28d266b8088ffb8f176bc7823ccccfa44bb19df",
//    "Authorization": "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6IjIyY2I5OWI5NjY0OTFlNzg0ZjQ0NWJmMWE3ZmEzZjU2OGE5Y2I4NmMxYmRhNzZiZTYzNDRjNzA1MDEwOGEwMzAzY2MzOTU5ZjI2MmZhZGZjIn0.eyJhdWQiOiIxIiwianRpIjoiMjJjYjk5Yjk2NjQ5MWU3ODRmNDQ1YmYxYTdmYTNmNTY4YTljYjg2YzFiZGE3NmJlNjM0NGM3MDUwMTA4YTAzMDNjYzM5NTlmMjYyZmFkZmMiLCJpYXQiOjE1MDMzMjA3NTMsIm5iZiI6MTUwMzMyMDc1MywiZXhwIjoxNTM0ODU2NzUzLCJzdWIiOiI0NDIiLCJzY29wZXMiOltdfQ.BCnxRauEehJSBhqWCvpTmmCz7GByCjZN0cc6GXr_huBAcjbSY98mILL1Z_cjgoZpSiNqyDB8z9V-zC8pveue5ZKqDj2-4v7vU4iE4JQU7qrQBsMWGMg_TxZp0nw07kHY-yOsEzyZo-9kjEU6s9LgoATikMJkPm22HGf4XR8T2TxQKTUVyFkKQzBMnDV3P5-Pm1mDpLhielKY9OchfNqK8cNKHZ4dXuA8Og4h459NFT-MGizyJX6hycH1ehqZc3TS4VJnzrh8E8RfBsN6ZGxebl1nHYKut-1-yArJ3BXK_IL6ahFuP6SoXmoTTHK_mXKln-Wm4z0OwvfmcevY4_QEJR9rpyGfBrundeNxwkUHbbNwWKIYfyJsH0lOcF0e9_zvrCYVGRtpu67iv4RZadQtTJNeux3AbMKf2rZ_K_n8EzqftL_UYq4VvHBCtQIpFZR8oDqqlBgHjh7d2JBQopWfkXCEp4H8SE_5VMEqQJRe8ygwM3D2h1BqqVPVMEpGJ1NYP3hZkdU-QqBzFKmYXAvotSxL2CHsxmFyrcwJt4iUzuQSqZ9jfIROOhvVbLesQoNKjHQdObC8bdXwQuaf-5F38M7V0pfWXiJbiy5cKUWkA8ZQEPteL4kSIOHwUf7u9rUoGKghak9XFrbdjF-ceFDtjTsBi6-83WWSPK5IsQPdUGA"
]

func checkCode(_ code: String) {
    Alamofire.request("http://mvp.forus.io/api/voucher/\(code)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
        if let json = response.data {
            let data = JSON(data: json)
            let max_amount = data["max_amount"]
            if let amount = max_amount.double {
                print("€\(String(format: "%.2f", arguments: [amount]))")
            } else {
                print("error, probably not a voucher..")
            }
        }
    }
}

//checkCode("HBYHPY-E6UDM3-8T3UXE-ZASNRW")


func signup(kvk: String, iban: String, email: String) {
    Alamofire.request("http://test-mvp.forus.io/api/shop-keepers/sign-up", method: .post, parameters: [
        "kvk_number": "\(kvk)",
        "iban": "\(iban)",
        "email": "\(email)"
        ], encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if let json = response.data {
                let data = JSON(data: json)
                let token = data["access_token"]
                UserDefaults.standard.setValue(String(describing: token), forKey: "APItoken")
                headers["Authorization"] = "Bearer \(token)"
            }
    }
}

signup(kvk: "69097488", iban: "NL91RABO0134369122", email: "jamal@stichtingforus.nl")


func processPaymentFor(_ code: String, amount: Double) {
    // new method
    Alamofire.request("http://mvp.forus.io/api/voucher/\(code)", method: .post, parameters: [
        "amount": "3.33",
        "_method": "PUT",
        ], encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if let json = response.data {
                let data = JSON(data: json)
                print(data)
            }
    }
}

//processPaymentFor("HBYHPY-E6UDM3-8T3UXE-ZASNRW", amount: 3.33)


func getStatus() {
    // new method
    Alamofire.request("http://mvp.forus.io/api/user", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if let json = response.data {
                let data = JSON(data: json)
                print(data)
            }
    }
}



let kvkKey = "l7xx45d657b473d94db29e58337db156ca29"



func kvkCheck(kvk: String) {
    Alamofire.request("https://api.kvk.nl/api/v2/profile/companies?q=\(kvk)&user_key=\(kvkKey)",
                      method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if let json = response.data {
                let data = JSON(data: json)
                if data["error"]["message"] == "NotFound" {
                    print("not found!")
                } else {
                    print(data["data"]["items"][0]["tradeNames"]["businessName"])
                }
            }
    }
}

//kvkCheck(kvk: "69488266")



func ibanCheck(iban: String) {
    Alamofire.request("https://openiban.com/validate/\(iban)?getBIC=false&validateBankCode=true",
        method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if let json = response.data {
                let data = JSON(data: json)
                if data["valid"] == true {
                    print("iban valid!")
                } else {
                    print("iban invalid!")
                }
            }
    }
}

//ibanCheck(iban: "NL78BUNQ2290297186")








PlaygroundPage.current.needsIndefiniteExecution = true
URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
