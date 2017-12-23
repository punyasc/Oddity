//
//  OddsRespondViewController.swift
//  Oddity
//
//  Created by Punya Chatterjee on 12/21/17.
//  Copyright © 2017 Punya Chatterjee. All rights reserved.
//

import UIKit
import Firebase

class OddsRespondViewController: UIViewController {

    @IBOutlet var limitLabel: UILabel!
    @IBOutlet var mynumField: UITextField!
    var mid:String?
    
    var ref:DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        self.hideKeyboardWhenTappedAround()
        self.view.bindToKeyboard()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func randomPress(_ sender: Any) {
    }
    
    @IBAction func respondPress(_ sender: Any) {
        let mynum = Int(mynumField.text ?? "0")
        let childUpdates = ["/matches/\(mid!)/challengerPick": mynum,
                            "/matches/\(mid!)/status":2] as [String: Any]
        ref.updateChildValues(childUpdates)
    }
    
    func updateUI(limit:Int) {
        limitLabel.text = "\(limit)"
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
