//
//  ProfileViewController.swift
//  Oddity
//
//  Created by Punya Chatterjee on 12/23/17.
//  Copyright © 2017 Punya Chatterjee. All rights reserved.
//

import UIKit
import Firebase
import UICircularProgressRing
import ChameleonFramework

class ProfileViewController: UIViewController {

    
    @IBOutlet var handleLabel: UILabel!
    @IBOutlet var progressRing: UICircularProgressRingView!
    var handle:String?
    var ref:DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(gradientStyle:UIGradientStyle.topToBottom, withFrame:view.frame, andColors:[UIColor.Primary.bgGradTop, UIColor.Primary.bgGradBot])
        ref = Database.database().reference()
        getHandle()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getHandle() {
        let user = Auth.auth().currentUser
        ref.child("/users/\(user?.uid ?? " ")").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let userDict = snapshot.value as? [String:Any] ?? [:]
            self.handle = userDict["handle"] as? String ?? " "
            let numCompleted = userDict["numCompleted"] as? Int ?? 0
            var numChallenged = userDict["numChallenged"] as? Int ?? 1
            numChallenged = numChallenged == 0 ? 1 : numChallenged
            var score = CGFloat(numCompleted)/CGFloat(numChallenged)
            self.progressRing.setProgress(value: score*100, animationDuration: 1.0) {
                print("Done animating!")
                // Do anything your heart desires...
            }
            self.handleLabel.text = "@\(self.handle ?? "me")"
        }) { (error) in
            // print(error.localizedDescription)
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? ProfileTableViewController {
            dest.handle = handle ?? " "
        }
    }
 

}
