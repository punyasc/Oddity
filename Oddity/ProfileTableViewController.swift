//
//  ProfileTableViewController.swift
//  Oddity
//
//  Created by Punya Chatterjee on 12/23/17.
//  Copyright © 2017 Punya Chatterjee. All rights reserved.
//

import UIKit
import Firebase
import SwiftMessages

class ProfileTableViewController: UITableViewController {

    var ref:DatabaseReference!
    var handle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        ref.child("/users/\(Auth.auth().currentUser!.uid)/handle").observe(DataEventType.value, with: {(snapshot) in
            self.handle = snapshot.value as? String ?? ""
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 1
        }
        return 2
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            changeHandle()
        } else if indexPath.row == 0 {
            signOut()
        } else {
            deleteAccount()
        }
    }
    
    func changeHandle() {
        var handleField: UITextField?
        let alert = UIAlertController(title: "Enter a new username", message: "Note: your username will stay the same in all Odds you're already a part of.", preferredStyle: .alert)
        // Add textfield to alert view
        alert.addTextField { (textField) in
            handleField = textField
        }
        alert.addAction(UIAlertAction(title: "Save", style: UIAlertActionStyle.default, handler: { action in
            //check if name is valid
            var newHandle = handleField?.text ?? ""
            newHandle = newHandle.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
            var handleQuery = self.ref.child("/handles/\(newHandle)")
            handleQuery.observeSingleEvent(of: .value, with:{ (snapshot: DataSnapshot) in
                if snapshot.exists() {
                    //username taken
                    print("taken")
                    self.showAlert(title: "Error", message: "This username is already in use.", theme: .error)
                } else {
                    //username not taken, proceed
                    
                    let childUpdates = ["/users/\(Auth.auth().currentUser!.uid)/handle": newHandle,
                                        "/handles/\(self.handle)/":nil,
                                        "/handles/\(newHandle)/":Auth.auth().currentUser!.uid] as [String : Any]
                    self.ref.updateChildValues(childUpdates)
                    
                }
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
            if let index = self.tableView.indexPathForSelectedRow{
                self.tableView.deselectRow(at: index, animated: true)
            }
        }))
        if let index = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: index, animated: true)
        }
        self.present(alert, animated: true, completion: nil)
        
        //let childUpdates = []
    }
    
    func signOut() {
        let alert = UIAlertController(title: "Are you sure you want to log out?", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Log Out", style: UIAlertActionStyle.default, handler: { action in
            
            do {
                try Auth.auth().signOut()
                UserDefaults.standard.set(0, forKey: "numChallenged")
                self.performSegue(withIdentifier: "unwindSignout", sender: self)
            } catch let signOutError as NSError {
                self.showAlert(title:"Error", message: "Could not sign out", theme: .error)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
            if let index = self.tableView.indexPathForSelectedRow{
                self.tableView.deselectRow(at: index, animated: true)
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
        
        
        
    }
    
    func confirmedDelete() {
        let user = Auth.auth().currentUser
        print("DELETE CONFIRMED")
        
        let childUpdates = ["/users/\(user!.uid)":nil,
                            "/handles/\(self.handle)/":nil] as [String : Any?]
        self.ref.updateChildValues(childUpdates)
        self.ref.child("/users/\(user!.uid)/").observe(DataEventType.value, with: { (snapshot) in
            if !snapshot.exists() {
                
                user?.delete { error in
                    if let index = self.tableView.indexPathForSelectedRow{
                        self.tableView.deselectRow(at: index, animated: true)
                    }
                    if let error = error {
                        print("Error deleting user", error)
                        self.showAlert(title: "Error", message: "An error occurred while deleting the account", theme: .error)
                        // An error happened.
                    } else {
                        print("User successfully deleted")
                        // Account deleted.
                        UserDefaults.standard.set(0, forKey: "numChallenged")
                        self.performSegue(withIdentifier: "unwindSignout", sender: self)
                    }
                }
                
                
                
            }
        })
        
        
        
        
        
    }
    
    func deleteAccount() {
        let alert = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete your account?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { action in
            self.confirmedDelete()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
            if let index = self.tableView.indexPathForSelectedRow{
                self.tableView.deselectRow(at: index, animated: true)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
