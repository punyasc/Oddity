//
//  ViewController.swift
//  Oddity
//
//  Created by Punya Chatterjee on 12/15/17.
//  Copyright © 2017 Punya Chatterjee. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    
    var authHandle:AuthStateDidChangeListenerHandle?
    var ref:DatabaseReference!
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        //self.view.bindToKeyboard()
        self.hideKeyboardWhenTappedAround()
        
        //let tap = UITapGestureRecognizer(target: self.view, action: Selector("dismissKeyboard"))
        //tap.cancelsTouchesInView = false
        //self.view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authHandle = Auth.auth().addStateDidChangeListener { (auth, user) in
            // ...
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let authHandle = authHandle {
            Auth.auth().removeStateDidChangeListener(authHandle)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBOutlet var logEmailField: UITextField!
    @IBOutlet var logPassField: UITextField!
    @IBAction func loginPress(_ sender: Any) {
        let email = logEmailField.text ?? ""
        let password = logPassField.text ?? ""
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if (error != nil) {
                print("ERR signin:", error!)
                return
            }
            print("SUCCESS, signed in:", email)
            self.performSegue(withIdentifier: "LoggedIn", sender: self)
        }
    }
    
    
    @IBOutlet var regEmailField: UITextField!
    @IBOutlet var regPassField: UITextField!
    @IBOutlet var regHandleField: UITextField!
    @IBAction func registerPress(_ sender: Any) {
        let email = regEmailField.text ?? ""
        let password = regPassField.text ?? ""
        let handle = regHandleField.text ?? ""
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if (error != nil) {
                print("ERR signup:", error!)
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
            self.performSegue(withIdentifier: "LoggedIn", sender: self)
        }
    }
    


}

extension UIView {
    func bindToKeyboard(){
        NotificationCenter.default.addObserver(self, selector: #selector(UIView.keyboardWillChange(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    @objc func keyboardWillChange(_ notification: NSNotification) {
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        let curve = notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! UInt
        let curFrame = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let targetFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let deltaY = targetFrame.origin.y - curFrame.origin.y
        
        UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: UIViewKeyframeAnimationOptions(rawValue: curve), animations: {
            self.frame.origin.y += deltaY
            
        },completion: {(true) in
            self.layoutIfNeeded()
        })
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer =     UITapGestureRecognizer(target: self, action:    #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

