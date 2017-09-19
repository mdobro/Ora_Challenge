//
//  ViewController.swift
//  Ora Challenge
//
//  Created by Mike Dobrowolski on 9/18/17.
//  Copyright © 2017 Ora. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var chatTable: UITableView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var keyboardHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundUserLabel: UILabel!
    @IBOutlet weak var logoutDismissButton: UIButton!
    @IBOutlet weak var keyboardDismissButton: UIButton!
    
    let chatClient = Chat()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        chatClient.delegate = self
        chatClient.startSession()
        
        chatTable.tableFooterView = UIView() //gets rid of extra seperator lines
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        dateLabel.text = dateFormatter.string(from: Date())
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadChat() {
        chatTable.reloadData()
        if chatClient.messages.count > 0 {
            chatTable.scrollToRow(at: IndexPath(row: chatClient.messages.count-1, section: 0), at: .bottom, animated: true)
        }
    }
    
    func updateUserName(username:String) {
        userLabel.text = username
        backgroundUserLabel.text = username
        inputTextField.placeholder = "Write something \(username)..."
    }
    
    @objc func keyboardNotification(notification:NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                keyboardHeightLayoutConstraint?.constant = 0.0
            } else {
                keyboardHeightLayoutConstraint?.constant = endFrame?.size.height ?? 0.0
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: {
                            self.view.layoutIfNeeded()
                            if self.chatClient.messages.count > 0 {
                                self.chatTable.scrollToRow(at: IndexPath(row: self.chatClient.messages.count-1, section: 0), at: .bottom, animated: false)
                            }
            })
        }
    }
    
    //MARK: Table Delegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatClient.messages.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell") as! ChatTableViewCell
        let message = chatClient.messages[indexPath.row]
        cell.userName.text = message.user
        cell.message.text = message.message
        cell.date.text = message.date
        cell.time.text = message.time
        return cell;
    }
    
    //MARK: UITextFieldDelegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        keyboardDismissButton.isEnabled = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendButtonPress(self)
        return false
    }
    
    //MARK: IBAction Methods
    
    @IBAction func barButtonPress(_ sender: Any) {
        UIView.animate(withDuration: 0.5, animations: {
            let distance:CGFloat = 250
            if let chatView = self.view.viewWithTag(1) {
                if chatView.frame.origin.x == 0 {
                    chatView.frame.origin.x += distance
                } else {
                    chatView.frame.origin.x -= distance
                }
            }
        }, completion: { comp in
            if let chatView = self.view.viewWithTag(1) {
                if chatView.frame.origin.x != 0 {
                    //at logout view
                    self.logoutDismissButton.isEnabled = true
                }
            }
            })
    }
    
    //allows user to touch outside of current activity to return to chatView
    @IBAction func dismissButtonPress(_ sender:UIButton) {
        sender.isEnabled = false
        //logoutDismissButton.tag == 1
        //keyboardDimissButton.tag == 2
        if (sender.tag == 2) {
            inputTextField.resignFirstResponder()
        } else {
            barButtonPress(self)
        }
    }
    
    @IBAction func sendButtonPress(_ sender: Any) {
        if let text = inputTextField.text {
            chatClient.sendMessage(message: text)
        }
        inputTextField.text = ""
    }
    
}

