//
//  OddsResultViewController.swift
//  Oddity
//
//  Created by Punya Chatterjee on 12/21/17.
//  Copyright © 2017 Punya Chatterjee. All rights reserved.
//

import UIKit
import ChameleonFramework

class OddsResultViewController: UIViewController {

    @IBOutlet var mypickLabel: UILabel!
    @IBOutlet var theirpickLabel: UILabel!
    @IBOutlet var winloseLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    var mid:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateUI(erPick:Int, eePick:Int, isEr:Bool) {
        print("UPDATE:","er", erPick, "ee", eePick)
        mypickLabel.text = isEr ? "\(erPick)" : "\(eePick)"
        theirpickLabel.text = isEr ? "\(eePick)" : "\(erPick)"
        if erPick == eePick {
            mypickLabel.textColor = isEr ? UIColor.flatGreen() : UIColor.flatRed()
            theirpickLabel.textColor = isEr ? UIColor.flatGreen() : UIColor.flatRed()
            winloseLabel.text = isEr ? "You win!" : "You lost!"
            detailLabel.text = isEr ? "Make sure to rub it in their face" : "Looks like the odds were not in your favor."
        } else {
            mypickLabel.textColor = .black
            theirpickLabel.textColor = .black
            winloseLabel.text = "No match."
            detailLabel.text = isEr ? "Your numbers didn't match. Better luck next time." : "Phew, close one! Your numbers didn't match. "
        }
        
    }


}
