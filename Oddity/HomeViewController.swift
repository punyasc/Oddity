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

class HomeViewController: UIViewController, UITextViewDelegate {

    @IBOutlet var cardWrapper: SpringView!
    var ref:DatabaseReference!
    var chosenMid:String?
    let defaultUserId = "cSxXIX29obQ3qDogfKBKzvcOjFI3"
    var opponentId:String?
    var opponentHandle:String?
    var userHandle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        getUserHandle(for: Auth.auth().currentUser?.uid ?? "")
        self.hideKeyboardWhenTappedAround()
        self.cardView.contentMode = UIViewContentMode.redraw
        self.cardView.setNeedsDisplay()
        cardWrapper.animate()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    @IBOutlet var cardView: RoundedView!
    @IBOutlet var taskView: UITextViewFixed!
    @IBOutlet var handleField: UITextField!
    @IBAction func goPress(_ sender: Any) {
        cardWrapper.animation = "pop"
        cardWrapper.duration = 0.5
        cardWrapper.force = 0.2
        cardWrapper.animate()
        let handle = handleField?.text ?? "magician" //implement handle-checking
        ref.child("handles").child(handle).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if snapshot.exists() {
                self.opponentId = snapshot.value as! String
                self.opponentHandle = handle
                self.createChallenge()
            } else {
                print("Snapshot did not exist")
            }
            // ...
        }) { (error) in
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
        let childUpdates = ["/matches/\(mid)": match,
                            "/users/\(opponentId!)/matches/\(mid)": task,
                            "/users/\(uid)/matches/\(mid)": task] as [String : Any]
        ref.updateChildValues(childUpdates)
        
        let statusRef = ref.child("matches").child(mid).child("status")
        statusRef.observe(DataEventType.value, with: { (snapshot) in
            let stat = snapshot.value as? Int ?? -1
            if stat >= 0 {
                self.chosenMid = mid
                self.performSegue(withIdentifier: "showOddsDetail", sender: self)
            }
            
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? OddsMasterViewController {
            dest.mid = self.chosenMid ?? ""
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
/*
extension UIView {
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
}*/

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
    
    func setup() {
        layer.shadowColor = UIColor(red:0.41, green:0.62, blue:0.78, alpha:1.0).cgColor
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 10.0
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
