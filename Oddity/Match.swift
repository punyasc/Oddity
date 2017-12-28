//
//  Match.swift
//  Oddity
//
//  Created by Punya Chatterjee on 12/26/17.
//  Copyright © 2017 Punya Chatterjee. All rights reserved.
//

import Foundation

struct Match {
    var mid:String
    var task:String
    var unread: Bool
    var intDate: Double
    init(task:String, unread:Bool, intDate:Double, mid:String) {
        self.mid = mid
        self.task = task
        self.unread = unread
        self.intDate = intDate
    }
}
