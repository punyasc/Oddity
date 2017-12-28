//
//  ViewController.swift
//  Oddity
//
//  Created by Punya Chatterjee on 12/15/17.
//  Copyright © 2017 Punya Chatterjee. All rights reserved.
//

import UIKit
import Firebase
import SwiftMessages

class LoginViewController: UIViewController {
    
    
    var authHandle:AuthStateDidChangeListenerHandle?
    var ref:DatabaseReference!
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        //self.view.bindToKeyboard()
        self.hideKeyboardWhenTappedAround()
        navigationItem.title = "Log In"
        
        //let tap = UITapGestureRecognizer(target: self.view, action: Selector("dismissKeyboard"))
        //tap.cancelsTouchesInView = false
        //self.view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
                var message = ""
                switch AuthErrorCode(rawValue: error!._code)! {
                case .invalidEmail:
                    message = "Invalid email"
                case .wrongPassword:
                    message = "Incorrect password"
                case .userDisabled:
                    message = "Your account is disabled"
                default:
                    message = "An error occurred, try again"
                }
                self.showAlert(title: "Error", message: message, theme: .error)
                return
            }
            print("SUCCESS, signed in:", email)
            self.performSegue(withIdentifier: "LoggedIn", sender: self)
        }
    }

    @IBAction func forgotPasswordPress(_ sender: Any) {
        if logEmailField.text == "" {
            self.showAlert(title: "Enter email", message: "Enter your email into the first field to reset your password", theme: .warning)
            return
        }
        let email = logEmailField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if error != nil {
                self.showAlert(title: "Sent", message: "Check your inbox for a password recovery email", theme: .success)
            } else {
                self.showAlert(title: "Error", message: "There may not be an account for this email address", theme: .error)
            }
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

