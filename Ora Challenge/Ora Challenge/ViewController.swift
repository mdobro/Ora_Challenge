//
//  ViewController.swift
//  Ora Challenge
//
//  Created by Mike Dobrowolski on 9/18/17.
//  Copyright © 2017 Ora. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var chatTable: UITableView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var inputTextField: UITextField!
    
    let chatClient = Chat()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        chatClient.delegate = self
        chatClient.startSession()
        
        //NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) //This will hide the keyboard
    }
    
    func reloadChat() {
        chatTable.reloadData()
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
    
    //MARK: IBAction Methods
    
    @IBAction func barButtonPress(_ sender: UIBarButtonItem) {
        print("bar button press")
    }
    
    @IBAction func sendButtonPress(_ sender: UIButton) {
        print("send: \(inputTextField.text!)")
    }
    
}

