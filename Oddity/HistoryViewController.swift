//
//  HistoryViewController.swift
//  Oddity
//
//  Created by Punya Chatterjee on 12/26/17.
//  Copyright © 2017 Punya Chatterjee. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework
import UIEmptyState

class HistoryViewController: UIViewController {

    var ref:DatabaseReference!
    var matches:[Match] = []
    var titles:[String] = []
    var chosenMid:String?
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        self.view.backgroundColor = UIColor(gradientStyle:UIGradientStyle.topToBottom, withFrame:view.frame, andColors:[UIColor.Primary.bgGradTop, UIColor.Primary.bgGradBot])
        self.emptyStateDelegate = self
        self.emptyStateDataSource = self
        fillData()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated:Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated:Bool) {
        super.viewDidAppear(animated)
        self.reloadEmptyStateForTableView(tableView)
        let childUpdates = ["/users/\(Auth.auth().currentUser!.uid)/unread":0]
        ref.updateChildValues(childUpdates)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    
    func fillData() {
        let uid = Auth.auth().currentUser?.uid ?? ""
        
        let recentOddsQuery = ref.child("/users/\(uid)/matches").queryOrderedByKey()
        recentOddsQuery.observe(.value, with:{ (snapshot: DataSnapshot) in
            self.matches.removeAll()
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
                print("KEY:", mid, "VAL:", task)
            }
            print("Done loading list, updating table")
            self.matches.reverse()
            self.tableView.reloadData()
            self.reloadEmptyStateForTableView(self.tableView)
        })
    }
    
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

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource, UIEmptyStateDataSource, UIEmptyStateDelegate {
    
    
    // MARK: - Empty State Data Source
    
    var emptyStateViewSpacing: CGFloat {
        return 30.0
    }
    
    var emptyStateImage: UIImage? {
        return #imageLiteral(resourceName: "cubeRedEmptySet")
    }
    
    var emptyStateTitle: NSAttributedString {
        let attrs = [NSAttributedStringKey.foregroundColor: UIColor.black,
                     NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17)]
        return NSAttributedString(string: "No odds yet", attributes: attrs)
    }
    
    var emptyStateButtonTitle: NSAttributedString? {
        let attrs = [NSAttributedStringKey.foregroundColor: UIColor.white,
                     NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15)]
        return NSAttributedString(string: "Challenge someone", attributes: attrs)
    }
    
    var emptyStateButtonSize: CGSize? {
        return CGSize(width: 200, height: 40)
    }
    
    
    // MARK: - Empty State Delegate
    
    func emptyStateViewWillShow(view: UIView) {
        guard let emptyView = view as? UIEmptyStateView else { return }
        // Some custom button stuff
        emptyView.button.layer.cornerRadius = 5
        emptyView.button.layer.borderWidth = 1
        emptyView.button.layer.borderColor = UIColor.Primary.buttonSecondary.cgColor
        emptyView.button.layer.backgroundColor = UIColor.Primary.buttonSecondary.cgColor
    }
    
    func emptyStatebuttonWasTapped(button: UIButton) {
        if let par = parent as? PagesViewController {
            par.jumpToHome()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete this match from your list?"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let childUpdates = ["/users/\(Auth.auth().currentUser!.uid)/matches/\(matches[indexPath.row].mid)":false] as [String:Any]
        ref.updateChildValues(childUpdates)
        ref.child("/users/(Auth.auth().currentUser!.uid)/matches").observe(DataEventType.childRemoved, with: {(snapshot) in
            self.matches.removeAll()
            self.tableView.reloadData()
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matches.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicOdds", for: indexPath) as! HistoryTableViewCell
        cell.updateCell(match: matches[indexPath.row])
        // Configure the cell...
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenMid = matches[indexPath.row].mid
        performSegue(withIdentifier: "historyToOdds", sender: self)
    }
}
