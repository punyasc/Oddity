//
//  OddsLimitViewController.swift
//  Oddity
//
//  Created by Punya Chatterjee on 12/21/17.
//  Copyright © 2017 Punya Chatterjee. All rights reserved.
//

import UIKit
import Firebase
import SwiftMessages

class OddsLimitViewController: UIViewController {

    @IBOutlet var numCard: UIView!
    @IBOutlet var limitField: UITextField!
    @IBOutlet var mynumField: UITextField!
    var mid:String?
    var limits:[Int] = [2, 3, 4, 5, 10, 15, 20, 30, 40, 50, 75, 100, 200, 300, 400, 500, 600, 700, 800, 900, 999]
    var ref:DatabaseReference!
    var opponentId:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        self.hideKeyboardWhenTappedAround()
        let childUpdates = ["/users/\(Auth.auth().currentUser!.uid)/matches/\(mid!)/unread": false] as [String: Any]
        ref.updateChildValues(childUpdates)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateUI(id: String) {
        opponentId = id
    }
    
    @IBAction func respondPress(_ sender: Any) {
        guard let limit = Int(limitField.text ?? "") else {
            self.showAlert(title: "Invalid limit", message: "Pick a real number greater than 1 for the limit", theme: .error)
            return
        }
        if limit <= 1 {
            self.showAlert(title: "Invalid limit", message: "The limit must be greater than 1, pick a new number", theme: .error)
            return
        } else if limit >= 1000 {
            self.showAlert(title: "Invalid limit", message: "If you're gonna set such a high limit, why even do the odds?", theme: .error)
            return
        }
        guard let mynum = Int(mynumField.text ?? "") else {
            self.showAlert(title: "Invalid number", message: "Pick a real number greater than 1 and less than \(limit)", theme: .error)
            return
        }
        if mynum < 1 {
            self.showAlert(title: "Invalid number", message: "Pick a real number greater than 1 and less than \(limit)", theme: .error)
            return
        } else if mynum > limit {
            self.showAlert(title: "Invalid number", message: "You cannot guess a number more than the limit you set, \(limit)", theme: .error)
            return
        }
        let childUpdates = ["/matches/\(mid!)/challengeePick": mynum,
                            "/matches/\(mid!)/limit": limit,
        "/matches/\(mid!)/status":1,
        "/users/\(self.opponentId!)/matches/\(mid!)/unread": true] as [String: Any]
        ref.updateChildValues(childUpdates)
        self.showAlert(title: "Sent", message: "", theme: .success)
    }
    
    @IBAction func chickenOutPress(_ sender: Any) {
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
