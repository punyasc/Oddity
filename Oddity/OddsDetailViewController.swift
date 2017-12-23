//
//  OddsDetailViewController.swift
//  Oddity
//
//  Created by Punya Chatterjee on 12/20/17.
//  Copyright © 2017 Punya Chatterjee. All rights reserved.
//

import UIKit
import Firebase

class OddsDetailViewController: UIViewController {

    var mid:String?
    var ref:DatabaseReference!
    
    @IBOutlet var challengerLabel: UILabel!
    @IBOutlet var challengeeLabel: UILabel!
    @IBOutlet var taskLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        if mid != nil {
            refreshUI()
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func refreshPress(_ sender: Any) {
    }
    
    func refreshUI() {
        ref.child("matches").child(mid!).observe(.value, with: { (snapshot) in
            // Get match value
            let matchDict = snapshot.value as? [String : AnyObject] ?? [:]
            self.challengeeLabel.text = matchDict["challengee"] as? String ?? "@Fail"
            self.challengerLabel.text = matchDict["challenger"] as? String ?? "@Fail"
            self.taskLabel.text = matchDict["task"] as? String ?? "@Fail"
            let statCode = matchDict["status"] as? Int ?? -1
            self.statusLabel.text = "Status: \(statCode)"
        }) { (error) in
            // print(error.localizedDescription)
        }
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
