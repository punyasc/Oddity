//
//  OddsMasterViewController.swift
//  Oddity
//
//  Created by Punya Chatterjee on 12/21/17.
//  Copyright © 2017 Punya Chatterjee. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework

class OddsMasterViewController: UIViewController {

    @IBOutlet var playersView: UIView!
    var mid:String?
    var ref:DatabaseReference!
    var curStatus:Int = -1
    var challengerId:String?
    var challengeeId:String?
    var limit = -1
    
    var waitingVC:OddsWaitingViewController?
    var respondVC:OddsRespondViewController?
    var resultVC:OddsResultViewController?
    
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var challengerLabel: UILabel!
    @IBOutlet var challengeeLabel: UILabel!
    @IBOutlet var taskLabel: UILabel!
    @IBOutlet var waitingContainer: UIView!
    @IBOutlet var responseContainer: UIView!
    @IBOutlet var limitContainer: UIView!
    @IBOutlet var resultContainer: UIView!
    @IBOutlet var cardView: RoundedView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        waitingContainer.isHidden = true
        responseContainer.isHidden = true
        limitContainer.isHidden = true
        resultContainer.isHidden = true
        ref = Database.database().reference()
        dateLabel.text = ""
        //self.cardView.layer.cornerRadius = 20.0
        //self.cardView.layer.masksToBounds = false
        self.cardView.contentMode = UIViewContentMode.redraw
        self.cardView.setNeedsDisplay()
        ///////
        self.view.backgroundColor = UIColor(gradientStyle:UIGradientStyle.topToBottom, withFrame:view.frame, andColors:[UIColor.Primary.bgGradTop, UIColor.Primary.bgGradBot])
        navigationItem.titleView = playersView
        navigationItem.leftBarButtonItem?.title = ""
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-cancel-72"), style: .plain, target: self, action: #selector(OddsMasterViewController.dismissModal))
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }
    
    @objc func dismissModal() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if mid != nil {
            refreshUI()
        }
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshUI() {
        ref.child("matches").child(mid!).observe(.value, with: { (snapshot) in
            // Get match values, set header labels
            let matchDict = snapshot.value as? [String : AnyObject] ?? [:]
            let challengee = matchDict["challengee"] as? String ?? "Fail"
            let challenger = matchDict["challenger"] as? String ?? "Fail"
            self.challengeeLabel.text = "@" + challengee
            self.challengerLabel.text = "@" + challenger
            let task = matchDict["task"] as? String ?? "@Fail"
            self.taskLabel.text = "What are the odds you \(task)?"
            self.curStatus = matchDict["status"] as? Int ?? -1
            self.challengerId = matchDict["challengerId"] as? String ?? "Fail"
            self.challengeeId = matchDict["challengeeId"] as? String ?? "Fail"
            self.limit = matchDict["limit"] as? Int ?? 0
            if let interval = matchDict["intDate"] as? Double {
                let timeCreated = Date(timeIntervalSince1970: TimeInterval(interval))
                self.dateLabel.text = timeCreated.getElapsedInterval()
            } else {
                self.dateLabel.text = ""
            }
            let challengerPick = matchDict["challengerPick"] as? Int ?? -1
            let challengeePick = matchDict["challengeePick"] as? Int ?? -1
            
            /*
            self.cardView.layer.cornerRadius = 20.0
            self.cardView.layer.masksToBounds = false
            self.cardView.clipsToBounds = true
            self.cardView.layer.shadowColor = UIColor.gray.cgColor
            self.cardView.layer.shadowOffset = CGSize.zero
            self.cardView.layer.shadowOpacity = 1.0
            self.cardView.layer.shadowRadius = 7.0*/
            //self.cardView.setup()
            var opponentHandle = ""
            var opponentId = ""
            let userIsChallenger = (Auth.auth().currentUser?.uid == self.challengerId)
            if userIsChallenger {
                //user is challenger
                opponentHandle = self.challengeeLabel.text ?? ""
                opponentId = self.challengeeId ?? ""
            } else {
                //user is challengee
                opponentHandle = self.challengerLabel.text ?? ""
                opponentId = self.challengerId ?? ""
            }
            
            
            
            
            //Set the match
            if challengerPick > -1 && challengeePick > -1 {
                print("CRP", challengerPick, "CEP", challengeePick)
                var isMatch = (challengerPick == challengeePick)
                var childUpdates = ["matches/\(self.mid!)/ismatch": isMatch]
                self.ref.updateChildValues(childUpdates)
            }
            
            //Update container views
            self.waitingVC?.updateUI(handle: opponentHandle, id: opponentId)
            self.respondVC?.updateUI(limit: self.limit)
            self.resultVC?.updateUI(erPick: challengerPick, eePick: challengeePick, isEr: userIsChallenger)
            self.switchContainer()
            
        }) { (error) in
            // print(error.localizedDescription)
        }
    }
    
    func switchContainer() {
        waitingContainer.isHidden = true
        responseContainer.isHidden = true
        limitContainer.isHidden = true
        resultContainer.isHidden = true
        let uid = Auth.auth().currentUser?.uid ?? ""
        switch curStatus {
        case 0: //Challenger sent request, waiting on Challengee to pick
            if uid == challengerId {
                //user is challenger
                waitingContainer.isHidden = false
            } else {
                //user is challengee
                limitContainer.isHidden = false
            }
        case 1: //Challenge picked, waiting on Challenger to pick
            if uid == challengerId {
                //user is challenger
                responseContainer.isHidden = false
            } else {
                //user is challengee
                waitingContainer.isHidden = false
            }
        case 2: //Both numbers picked, calculate and present results
                resultContainer.isHidden = false
        default:
            return
        }
        
    }
    

    func setOpponentHandle() {
        
    }
   
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? OddsResultViewController {
            self.resultVC = dest
            dest.mid = self.mid
        } else if let dest = segue.destination as? OddsLimitViewController {
            dest.mid = self.mid
        } else if let dest = segue.destination as? OddsWaitingViewController {
            self.waitingVC = dest
            dest.mid = self.mid
        } else if let dest = segue.destination as? OddsRespondViewController {
            self.respondVC = dest
            dest.mid = self.mid
        }
    }
    

}
