//
//  HomeViewController.swift
//  Oddity
//
//  Created by Punya Chatterjee on 12/19/17.
//  Copyright © 2017 Punya Chatterjee. All rights reserved.
//

import UIKit
import Firebase
import Spring
import ChameleonFramework
import SwiftMessages

class HomeViewController: UIViewController, UITextViewDelegate {

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var unreadLabel: UILabel!
    @IBOutlet var unreadWrapper: SpringView!
    @IBOutlet var unreadCard: RoundedView!
    @IBOutlet var cardWrapper: SpringView!
    var ref:DatabaseReference!
    var chosenMid:String?
    let defaultUserId = "cSxXIX29obQ3qDogfKBKzvcOjFI3"
    var opponentId:String?
    var opponentHandle:String?
    var userHandle = ""
    var curUnread = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        //getUserHandle(for: Auth.auth().currentUser?.uid ?? "")
        self.hideKeyboardWhenTappedAround()
        self.cardView.contentMode = UIViewContentMode.redraw
        self.cardView.setNeedsDisplay()
        setColors()
        cardWrapper.animate()
        unreadCard.isHidden = true
        setUnreadListener()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.activityIndicator.isHidden = true
        self.cardWrapper.alpha = 1.0
        getUserHandle(for: Auth.auth().currentUser?.uid ?? "")
    }
    
    func setUnreadListener() {
        //let statusRef = self.ref.child("matches").child(mid).child("status")
        let uid = Auth.auth().currentUser?.uid
        ref.child("/users/\(uid ?? "")/unread").observe(DataEventType.value, with: { (snapshot) in
            let unread = snapshot.value as? Int ?? 0
            //self.unreadCard.isHidden = unread == 0
            if unread == 0 {
                self.unreadWrapper.animation = "fall"
                self.unreadWrapper.duration = 2.0
                self.unreadWrapper.animate()
                //self.unreadCard.isHidden = true
            } else if self.curUnread == 0 {
                    self.unreadCard.isHidden = false
                self.unreadWrapper.duration = 2.0
                    self.unreadWrapper.animation = "fadeInUp"
                   self.unreadWrapper.animate()
            } else if unread > self.curUnread {
                    self.unreadWrapper.animation = "flash"
                    self.unreadWrapper.duration = 0.5
            }
            self.curUnread = unread
            print("UNREAD:", unread)
            self.unreadLabel.text = "You have \(unread) new Odds"
        })
    }
    
    func setColors() {
        self.view.backgroundColor = UIColor(gradientStyle:UIGradientStyle.topToBottom, withFrame:view.frame, andColors:[UIColor.Primary.bgGradTop, UIColor.Primary.bgGradBot])
        goButton.backgroundColor = UIColor.Primary.buttonPrimary
        goButton.setTitleColor(UIColor.Primary.title, for: .normal)
        openButton.backgroundColor = UIColor.Primary.buttonSecondary
        openButton.setTitleColor(UIColor.Primary.title, for: .normal)
    }
    
    @IBOutlet var goButton: RoundButton!
    @IBOutlet var openButton: RoundButton!
    @IBOutlet var cardView: RoundedView!
    @IBOutlet var taskView: UITextViewFixed!
    @IBOutlet var handleField: UITextField!
    @IBAction func goPress(_ sender: Any) {
        cardWrapper.animation = "pop"
        cardWrapper.duration = 0.5
        cardWrapper.force = 0.2
        cardWrapper.animate()
        var handle = handleField!.text ?? ""
        handle = handle.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        if handle == "" {
            showAlert(title: "No recipient", message: "Please enter a username to send this to", theme: .warning)
            return
        } else if handle == userHandle {
            showAlert(title: "Don't @ yourself", message: "Enter a username other than your own", theme: .warning)
            return
        } else if taskView.text == "" {
            showAlert(title: "Enter a dare", message: "Enter a dare to send", theme: .warning)
            return
        }
        activityIndicator.isHidden = false
        cardWrapper.alpha = 0.5
        ref.child("/handles/\(handle)").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if let oppId = snapshot.value as? String {
                self.opponentId = oppId
                self.opponentHandle = handle
                self.createChallenge()
            } else {
                self.activityIndicator.isHidden = true
                self.cardWrapper.alpha = 1.0
                self.showAlert(title: "Invalid username", message: "No one with that username exists", theme: .warning)
                print("Snapshot did not exist")
            }
            // ...
        }) { (error) in
            self.showAlert(title: "Could not send", message: "Check your internet connection", theme: .error)
            self.activityIndicator.isHidden = true
            self.cardWrapper.alpha = 1.0
            // print(error.localizedDescription)
        }
    }
    
    @IBAction func signoutPress(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        performSegue(withIdentifier: "BackToLogin", sender: self)
    }
    
    @IBAction func openUnreadPress(_ sender: Any) {
        if let par = parent as? PagesViewController {
            par.jumpToHistory()
        }
    }
    
    
    func getUserHandle(for id:String) {
        ref.child("users/\(id)/handle").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if snapshot.exists() {
                self.userHandle = snapshot.value as? String ?? ""
            } else {
                print("Snapshot did not exist")
            }
            // ...
        }) { (error) in
            // print(error.localizedDescription)
        }
    }
    
    func createChallenge() {
        print("creating challenge")
        let uid = Auth.auth().currentUser?.uid ?? ""
        let mid = ref.child("matches").childByAutoId().key
        print("MID:", mid)
        let task = taskView.text.replacingOccurrences(of: "?", with: "") ?? ""
        let interval = Date().timeIntervalSince1970
        let match = ["challengerId": uid,
                    "challengeeId": opponentId ?? "",
                    "challenger": userHandle,
                    "challengee": opponentHandle,
                    "intDate": interval,
                    "task": task,
                    "status": 0,
                    "ismatch": false] as [String : Any]
        
        //Get the other user's unread count and add to it
        ref.child("/users/\(opponentId!)/unread").observeSingleEvent(of: .value, with: { (snapshot) in
            var unread = snapshot.value as? Int ?? 0
            unread += 1
            let childUpdates = ["/matches/\(mid)": match,
                                "/users/\(uid)/matches/\(mid)/task":task,
                                "/users/\(uid)/matches/\(mid)/unread":false,
                                "/users/\(uid)/matches/\(mid)/intDate":Double(interval),
                                "/users/\(self.opponentId!)/matches/\(mid)/task":task,
                                "/users/\(self.opponentId!)/matches/\(mid)/unread":true,
                                "/users/\(self.opponentId!)/matches/\(mid)/intDate":Double(interval),
                                "/users/\(self.opponentId!)/unread":unread] as [String : Any]
            
            self.ref.updateChildValues(childUpdates)
            
            let statusRef = self.ref.child("matches").child(mid).child("status")
            statusRef.observe(DataEventType.value, with: { (snapshot) in
                let stat = snapshot.value as? Int ?? -1
                if stat >= 0 {
                    self.chosenMid = mid
                    self.handleField.text = ""
                    self.taskView.text = ""
                    if let placeholderLabel = self.taskView.viewWithTag(100) as? UILabel {
                        placeholderLabel.isHidden = false
                    }
                    let numChallenged = UserDefaults.standard.integer(forKey: "numChallenged")
                    UserDefaults.standard.set(numChallenged + 1, forKey: "numChallenged")
                    self.activityIndicator.isHidden = true
                    self.cardWrapper.alpha = 1.0
                    self.showAlert(title: "Odds sent!", message: "You sent an Odds to \(self.opponentHandle!)", theme: .success)
                    //self.performSegue(withIdentifier: "showOddsDetail", sender: self)
                }
                
            }) { (error) in
                self.showAlert(title: "Could not send", message: "Check your internet connection", theme: .error)
                self.activityIndicator.isHidden = true
                self.cardWrapper.alpha = 1.0
            }
            
        }) { (error) in
            self.showAlert(title: "Could not send", message: "Check your internet connection", theme: .error)
            self.activityIndicator.isHidden = true
            self.cardWrapper.alpha = 1.0
        }
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destNC = segue.destination as? UINavigationController {
            if let dest = destNC.topViewController as? OddsMasterViewController {
                dest.mid = self.chosenMid ?? ""
            }
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let curPos = textField.selectedTextRange?.start ?? textField.endOfDocument
        print("STR", string)
        if string == "" {
            // handle backspace scenario here
            return true
        } else if string == "?" {
            return false
        } else if var textString = textField.text {
            
            print("TS\t", textString)
            let unitString = "?"
            if textString.contains(unitString) {
                textString = textString.replacingOccurrences(of: unitString, with: "")
                textField.text = textString
                textField.selectedTextRange = textField.textRange(from: curPos, to: curPos)
                if let textRange = textField.selectedTextRange {
                    print("BOII")
                    textField.insertText(string)
                    //textField.replace(textRange, withText:string)
                }
                textField.text = textField.text! + unitString
            } else {
                print("ELSE")
                textField.text = string + unitString
            }
            let nextPos = textField.position(from: curPos, offset: 1) ?? textField.endOfDocument
            textField.selectedTextRange = textField.textRange(from: nextPos, to: nextPos)
            /*
            if textField.selectedTextRange?.start == textField.endOfDocument {
                let newPosition = textField.position(from: textField.endOfDocument, offset: -1)
                textField.selectedTextRange = textField.textRange(from: newPosition!, to: newPosition!)
            }*/
            
            return false
        }
        return true
    }
 

}

extension Date {
    
    func toString(withFormat format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        let myString = formatter.string(from: self)
        let yourDate = formatter.date(from: myString)
        formatter.dateFormat = format
        
        return formatter.string(from: yourDate!)
    }
}


class GradientView: UIView {
    
    
    override open class var layerClass: AnyClass {
        return CAGradientLayer.classForCoder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let gradientLayer = self.layer as! CAGradientLayer
        gradientLayer.colors = [UIColor.white.cgColor, UIColor(red:0.73, green:0.84, blue:0.93, alpha:1.0).cgColor]
    }
}

@IBDesignable class UITextViewFixed: UITextView, UITextViewDelegate {
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    func setup() {
        textContainerInset = UIEdgeInsets.zero
        textContainer.lineFragmentPadding = 0
    }
    
    override open var bounds: CGRect {
        didSet {
            self.resizePlaceholder()
        }
    }
    
    /// The UITextView placeholder text
    @IBInspectable
    public var placeholder: String? {
        get {
            var placeholderText: String?
            
            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderText = placeholderLabel.text
            }
            
            return placeholderText
        }
        set {
            if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
                placeholderLabel.text = newValue
                placeholderLabel.sizeToFit()
            } else {
                self.addPlaceholder(newValue!)
            }
        }
    }
    
    /// When the UITextView did change, show or hide the label based on if the UITextView is empty or not
    ///
    /// - Parameter textView: The UITextView that got updated
    
    public func textViewDidChange(_ textView: UITextView) {
        print("CALLED")
        if let placeholderLabel = self.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = self.text != ""
        }
    }
    
    /// Resize the placeholder UILabel to make sure it's in the same position as the UITextView text
    private func resizePlaceholder() {
        if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
            let labelX:CGFloat = 0.0
            //self.textContainer
            let labelY = UIEdgeInsets.zero.top + 2
            let labelWidth = self.frame.width - (labelX * 2)
            let labelHeight = placeholderLabel.frame.height
            
            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        }
    }
    
    /// Adds a placeholder UILabel to this UITextView
    private func addPlaceholder(_ placeholderText: String) {
        let placeholderLabel = UILabel()
        
        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()
        
        placeholderLabel.font = self.font
        placeholderLabel.textColor = UIColor(red:0.79, green:0.79, blue:0.82, alpha:1.0)
        placeholderLabel.tag = 100
        
        placeholderLabel.isHidden = self.text.characters.count > 0
        
        self.addSubview(placeholderLabel)
        self.resizePlaceholder()
        self.delegate = self
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if let placeholderLabel = self.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = self.text != "" || text != "" || text != "?"
        }
        
        let curPos = textView.selectedTextRange?.start ?? textView.endOfDocument
        if text == "" {
            // handle backspace scenario here
            return true
        } else if text == "?" {
            return false
        } else if var textString = textView.text {
            
            let unitString = "?"
            if textString.contains(unitString) {
                textString = textString.replacingOccurrences(of: unitString, with: "")
                textView.text = textString
                textView.selectedTextRange = textView.textRange(from: curPos, to: curPos)
                if let textRange = textView.selectedTextRange {

                    textView.insertText(text)
                    //textField.replace(textRange, withText:string)
                }
                textView.text = textView.text! + unitString
            } else {
                textView.text = text + unitString
            }
            let nextPos = textView.position(from: curPos, offset: text.count) ?? textView.endOfDocument
            textView.selectedTextRange = textView.textRange(from: nextPos, to: nextPos)
            
            if textView.selectedTextRange?.start == textView.endOfDocument {
                let newPosition = textView.position(from: textView.endOfDocument, offset: -1)
                textView.selectedTextRange = textView.textRange(from: newPosition!, to: newPosition!)
            }
            return false
        }
        return true
    }
}

@IBDesignable class RoundedView: UIView {
    
    @IBInspectable var cornerRadius: CGFloat = 0.0
    @IBInspectable var borderColor: UIColor = UIColor.black
    @IBInspectable var borderWidth: CGFloat = 0.5
    private var customBackgroundColor = UIColor.white
    override var backgroundColor: UIColor?{
        didSet {
            customBackgroundColor = backgroundColor!
            super.backgroundColor = UIColor.clear
        }
    }
    
    @IBInspectable var shadowColor: UIColor = UIColor(red:0.41, green:0.62, blue:0.78, alpha:1.0) {
        didSet {
            setup()
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 10.0 {
        didSet {
            setup()
        }
    }
    
    func setup() {
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = 0.2
        super.backgroundColor = UIColor.clear
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override func draw(_ rect: CGRect) {
        customBackgroundColor.setFill()
        UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius ?? 0).fill()
        
        let borderRect = bounds.insetBy(dx: borderWidth/2, dy: borderWidth/2)
        let borderPath = UIBezierPath(roundedRect: borderRect, cornerRadius: cornerRadius - borderWidth/2)
        borderColor.setStroke()
        borderPath.lineWidth = borderWidth
        borderPath.stroke()
        
        // whatever else you need drawn
    }
}

extension Date {
    
    func getElapsedInterval() -> String {
        
        let interval = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self, to: Date())
        
        if let year = interval.year, year > 0 {
            return year == 1 ? "\(year)" + " " + "year ago" :
                "\(year)" + " " + "years ago"
        } else if let month = interval.month, month > 0 {
            return month == 1 ? "\(month)" + " " + "month ago" :
                "\(month)" + " " + "months ago"
        } else if let day = interval.day, day > 0 {
            return day == 1 ? "\(day)" + " " + "day ago" :
                "\(day)" + " " + "days ago"
        } else if let hour = interval.hour, hour > 0 {
            return hour == 1 ? "\(hour)" + " " + "hour ago" :
                "\(hour)" + " " + "hours ago"
        } else if let minute = interval.minute, minute > 0 {
            return minute == 1 ? "\(minute)" + " " + "minute ago" :
                "\(minute)" + " " + "minutes ago"
        } else {
            return "Just now"
            
        }
        
    }
}

extension UIColor{
    
    @nonobjc static var clr_blue: UIColor = UIColor(hue: 0.6, saturation: 0.85, brightness: 1, alpha: 1)
   
    
}

extension UIViewController {
    func showAlert(title:String, message:String, theme:Theme) {
        let view = MessageView.viewFromNib(layout: .cardView)
        var config = SwiftMessages.Config()
        config.presentationStyle = .top
        config.duration = .seconds(seconds: 3.5)
        config.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
        view.configureTheme(theme)
        view.configureDropShadow()
        view.button?.isHidden = true
        view.configureContent(title: title, body: message)
        SwiftMessages.show(config: config, view: view)
    }
}
