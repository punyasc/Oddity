//
//  SignupViewController.swift
//  Oddity
//
//  Created by Punya Chatterjee on 12/25/17.
//  Copyright © 2017 Punya Chatterjee. All rights reserved.
//

import UIKit
import Firebase
import SwiftMessages

class SignupViewController: UIViewController {

    var ref:DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        ref = Database.database().reference()
        navigationItem.title = "Sign Up"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet var regEmailField: UITextField!
    @IBOutlet var regPassField: UITextField!
    @IBOutlet var regHandleField: UITextField!
    @IBAction func registerPress(_ sender: Any) {
        print("registering")
        let email = regEmailField.text ?? ""
        let password = regPassField.text ?? ""
        var handle = regHandleField.text ?? ""
        handle = handle.trimmingCharacters(in: .whitespacesAndNewlines)
        if handle.count < 4 {
            showAlert(title: "Error", message: "Your username must have more than 4 characters", theme: .error)
            return
        } else if handle.count > 15 {
            showAlert(title: "Error", message: "Your username must have 15 or fewer characters", theme: .error)
            return
        } else if (handle.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) != nil) {
            showAlert(title: "Error", message: "Your username may only have letters or numbers", theme: .error)
            return
        }
        
        var handleQuery = ref.child("/handles/\(handle)")
        handleQuery.observeSingleEvent(of: .value, with:{ (snapshot: DataSnapshot) in
            if snapshot.exists() {
                //username taken
                print("taken")
                self.showAlert(title: "Error", message: "This username is already in use", theme: .error)
            } else {
                //username not taken, proceed
                print("not taken")
                
                Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                    if (error != nil) {
                        let err = error as! NSError
                        var message = ""
                        switch AuthErrorCode(rawValue: error!._code)! {
                        case .invalidEmail:
                            message = "Invalid Email"
                        case .emailAlreadyInUse:
                            message = "This Email is already in use"
                        case .weakPassword:
                            message = "Weak password: \(err.userInfo[NSLocalizedFailureReasonErrorKey] ?? "")"
                        default:
                            message = "An error occurred, try again"
                        }
                        self.showAlert(title: "Error", message: message, theme: .error)
                        return
                    }
                    print("SUCCESS, user created:", email)
                    
                    //Insert user into Database
                    //self.ref.child("users").child(user!.uid).setValue()
                    let newUser = ["handle": handle, "numChallenged":0, "numCompleted":0] as [String : Any]
                    //self.ref.child("handles").setValue([handle: user!.uid])
                    let childUpdates = ["/users/\(user!.uid)": newUser,
                                        "/handles/\(handle)": user!.uid] as [String : Any]
                    self.ref.updateChildValues(childUpdates)
                    
                    self.ref.child("/users/\(user!.uid)").observe(DataEventType.value, with: { (snapshot) in
                        if snapshot.exists() {
                            self.performSegue(withIdentifier: "LoggedIn", sender: self)
                        }
                    })
                    
                }
 
            }
        })
        
        
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
