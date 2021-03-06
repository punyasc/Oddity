//
//  HistoryTableViewController.swift
//  Oddity
//
//  Created by Punya Chatterjee on 12/22/17.
//  Copyright © 2017 Punya Chatterjee. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework

class HistoryTableViewController: UITableViewController {

    var ref:DatabaseReference!
    var matches:[Match] = []
    var titles:[String] = []
    var chosenMid:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        //self.view.backgroundColor = UIColor(gradientStyle:UIGradientStyle.topToBottom, withFrame:view.frame, andColors:[UIColor.Primary.bgGradTop, UIColor.Primary.bgGradBot])
        //self.tableView.backgroundColor = UIColor(gradientStyle:UIGradientStyle.topToBottom, withFrame:view.frame, andColors:[UIColor.Primary.bgGradTop, UIColor.Primary.bgGradBot])
        let childUpdates = ["/users/\(Auth.auth().currentUser!.uid)/unread":0]
        ref.updateChildValues(childUpdates)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewDidAppear(_ animated:Bool) {
        super.viewDidAppear(animated)
        fillData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    
    func fillData() {
        matches = []
        let uid = Auth.auth().currentUser?.uid ?? ""
        
        let recentOddsQuery = ref.child("/users/\(uid)/matches").queryOrderedByKey()
        recentOddsQuery.observe(.value, with:{ (snapshot: DataSnapshot) in
            for snap in snapshot.children {
                let snapshot = snap as! DataSnapshot
                
                let match = snapshot.value as? [String: Any] ?? [:]
                let mid = snapshot.key
                let task = match["task"] as? String ?? mid
                let unread = match["unread"] as? Bool ?? false
                let intDate = match["intDate"] as? Double ?? -1.0
                
                let newMatch = Match(task: task, unread: unread, intDate: intDate, mid: mid)
                
                print("iDDDDD", intDate)
                self.matches.append(newMatch)
                //let task = snapshot.value as? String ?? "Match\(mid)"
                print("KEY:", mid, "VAL:", task)
                //self.titles.append(task)
            }
            self.matches.reverse()
            self.tableView.reloadData()
        })
    }
    
    
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return matches.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicOdds", for: indexPath) as! HistoryTableViewCell
        cell.updateCell(match: matches[indexPath.row])
        // Configure the cell...

        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenMid = matches[indexPath.row].mid
        performSegue(withIdentifier: "historyToOdds", sender: self)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    var modalVC: OddsMasterViewController?
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destNC = segue.destination as? UINavigationController {
            if let dest = destNC.topViewController as? OddsMasterViewController {
                modalVC = dest
                dest.mid = chosenMid
            }
        }
    }
    
 

}
