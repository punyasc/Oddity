//
//  OddsLimitViewController.swift
//  Oddity
//
//  Created by Punya Chatterjee on 12/21/17.
//  Copyright © 2017 Punya Chatterjee. All rights reserved.
//

import UIKit
import Firebase

class OddsLimitViewController: UIViewController {

    @IBOutlet var numCard: UIView!
    @IBOutlet var limitField: UITextField!
    @IBOutlet var mynumField: UITextField!
    var mid:String?
    var limits:[Int] = [2, 3, 4, 5, 10, 15, 20, 30, 40, 50, 75, 100, 200, 300, 400, 500, 600, 700, 800, 900, 999]
    var ref:DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func respondPress(_ sender: Any) {
        let limit = Int(limitField.text ?? "0") ?? -1
        let mynum = Int(mynumField.text ?? "0") ?? -1
        let childUpdates = ["/matches/\(mid!)/challengeePick": mynum,
                            "/matches/\(mid!)/limit": limit,
        "/matches/\(mid!)/status":1] as [String: Any]
        ref.updateChildValues(childUpdates)
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
