//
//  ProfileViewController.swift
//  Oddity
//
//  Created by Punya Chatterjee on 12/23/17.
//  Copyright © 2017 Punya Chatterjee. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework

class ProfileViewController: UIViewController {

    
    @IBOutlet var numChallengedButton: RoundButton!
    @IBOutlet var handleLabel: UILabel!
    var handle:String?
    var ref:DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(gradientStyle:UIGradientStyle.topToBottom, withFrame:view.frame, andColors:[UIColor.Primary.bgGradTop, UIColor.Primary.bgGradBot])
        ref = Database.database().reference()
        getHandle()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let numChallenged = UserDefaults.standard.integer(forKey: "numChallenged")
        numChallengedButton.setTitle("\(numChallenged)", for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getHandle() {
        let user = Auth.auth().currentUser
        ref.child("/users/\(user?.uid ?? " ")/handle").observe( .value, with: { (snapshot) in
            // Get user value
            self.handle = snapshot.value as? String ?? " "
            //let numCompleted = userDict["numCompleted"] as? Int ?? 0
            //var numChallenged = userDict["numChallenged"] as? Int ?? 1
            //numChallenged = numChallenged == 0 ? 1 : numChallenged
            //var score = CGFloat(numCompleted)/CGFloat(numChallenged)
            self.handleLabel.text = "@\(self.handle ?? "me")"
        }) { (error) in
            // print(error.localizedDescription)
        }
    }

 

}
