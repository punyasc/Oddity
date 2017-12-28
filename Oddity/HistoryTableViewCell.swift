//
//  HistoryTableViewCell.swift
//  Oddity
//
//  Created by Punya Chatterjee on 12/26/17.
//  Copyright © 2017 Punya Chatterjee. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {

    var task:String?
    @IBOutlet var taskLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var unreadBadge: RoundButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateCell(match: Match) {
        unreadBadge.isHidden = !match.unread
        taskLabel.text = "\(match.task)?"
        //if let interval = matchDict["intDate"] as? Double {
        let timeCreated = Date(timeIntervalSince1970: TimeInterval(match.intDate)).getElapsedInterval()
        timeLabel.text = "\(timeCreated)"
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
