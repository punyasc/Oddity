//
//  OddsWaitingViewController.swift
//  Oddity
//
//  Created by Punya Chatterjee on 12/21/17.
//  Copyright © 2017 Punya Chatterjee. All rights reserved.
//

import UIKit
import Firebase

class OddsWaitingViewController: UIViewController {

    var ref:DatabaseReference!
    var mid:String?
    var opponentHandle = "."
    var opponentId:String?
    
    @IBOutlet var waitingLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func remindPress(_ sender: Any) {
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateUI(handle:String, id:String) {
        waitingLabel.text = "\(handle) has not picked a number yet."
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
