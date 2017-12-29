//
//  OddsRespondViewController.swift
//  Oddity
//
//  Created by Punya Chatterjee on 12/21/17.
//  Copyright © 2017 Punya Chatterjee. All rights reserved.
//

import UIKit
import Firebase
import SwiftMessages

class OddsRespondViewController: UIViewController {

    @IBOutlet var limitLabel: UILabel!
    @IBOutlet var mynumField: UITextField!
    var mid:String?
    var opponentId:String?
    
    var ref:DatabaseReference!
    
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
    
    @IBAction func randomPress(_ sender: Any) {
        let limit = UInt32(limitLabel.text ?? "0") ?? 0
        let num = Int(arc4random_uniform(limit) + 1)
        mynumField.text = "\(num)"
    }
    
    
    @IBAction func respondPress(_ sender: Any) {
        let limit = Int(limitLabel.text ?? "0") ?? 0
        guard let mynum = Int(mynumField.text ?? "") else {
            self.showAlert(title: "Invalid number", message: "Pick a real number between 1 and \(limit)", theme: .error)
            return
        }
        if mynum < 1 {
            self.showAlert(title: "Invalid number", message: "Pick a real number between 1 and \(limit)", theme: .error)
            return
        } else if mynum > limit {
            self.showAlert(title: "Invalid number", message: "You cannot guess a number more than the limit, \(limit)", theme: .error)
            return
        }
        let childUpdates = ["/matches/\(mid!)/challengerPick": mynum,
                            "/matches/\(mid!)/status":2,
                            "/users/\(self.opponentId!)/matches/\(mid!)/unread": true] as [String: Any]
        //"/users/\(self.opponentId!)/matches/\(mid!)/unread": false
        ref.updateChildValues(childUpdates)
        self.showAlert(title: "3, 2, 1...", message: "The results are in!", theme: .success)
    }
    
    func updateUI(limit:Int, id: String) {
        limitLabel.text = "\(limit)"
        opponentId = id
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
