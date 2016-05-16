/**
 * Copyright 2016 IBM Corp.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import UIKit
import IBMMobileFirstPlatformFoundation

class HomeViewController: UIViewController {

    @IBOutlet weak var resultTxt: UITextView!
    @IBOutlet weak var getBalanceBtn: UIButton!
    @IBOutlet weak var getTransactionsBtn: UIButton!
    
    var logoutBtn:UIBarButtonItem!
    var enrollBtn:UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        enrollBtn = UIBarButtonItem(title: "Enroll", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.enroll))
        self.navigationItem.rightBarButtonItem = enrollBtn
        
        logoutBtn = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.logout))
        
        let request = WLResourceRequest(URL: NSURL(string: "/adapters/Enrollment/isEnrolled"), method: WLHttpMethodGet)
        request.sendWithCompletionHandler { (response, error) in
            if (error != nil){
                print("isEnrolled error: \(error.description)")
            } else if (!NSString(string: response.responseText!).boolValue){
                print("isEnrolled response: \(response.responseText)")
            } else {
                print("isEnrolled response: \(response.responseText)")
                self.getBalanceBtn.hidden = false
                self.getTransactionsBtn.hidden = false
                self.navigationItem.rightBarButtonItem = self.logoutBtn
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(showLoginPage), name: ACTION_USERLOGIN_CHALLENGE_RECEIVED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(showPinCodePopup(_:)), name: ACTION_PINCODE_CHALLENGE_RECEIVED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(enrollAfterFailure(_:)), name: ACTION_PINCODE_CHALLENGE_FAILURE, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(deletePinCode), name: ACTION_ISENROLLED_LOGOUT_SUCCESS, object: nil)
    }
    
    func enroll(){
        self.resultTxt.text = ""
        WLAuthorizationManager.sharedInstance().obtainAccessTokenForScope("setPinCode") { (token, error) in
            if (error != nil){
                print("enroll error: \(error.description)")
            } else {
                print("enroll Success")
                self.setPinCodeAlert("")
            }
        }
    }
    
    func setPinCodeAlert(msg: String){
        let alert = UIAlertController(title: "Set Pin Code", message: msg, preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "CHOOSE A PIN CODE"
            textField.keyboardType = .NumberPad
        }
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let pinTextField = alert.textFields![0] as UITextField
            self.setPinCode(pinTextField.text!)
        }))
        self.presentViewController(alert,
                                   animated: true,
                                   completion: nil)
    }
    
    func logout(){
        self.resultTxt.text = ""
        NSNotificationCenter.defaultCenter().postNotificationName(ACTION_LOGOUT, object: self)
    }
    
    func deletePinCode(){
        let request = WLResourceRequest(URL: NSURL(string: "/adapters/Enrollment/deletePinCode"), method: WLHttpMethodDelete)
        request.sendWithCompletionHandler { (response, error) in
            if (error != nil){
                print("deletePinCode error: \(error.description)")
            } else {
                print("deletePinCode status: \(response.status)")
                self.getBalanceBtn.hidden = true
                self.getTransactionsBtn.hidden = true
                self.navigationItem.rightBarButtonItem = self.enrollBtn
            }
        }
    }
    
    func setPinCode(pinCode: String){
        if (pinCode == ""){
            self.setPinCodeAlert("Pincode is required, please try again")
        } else {
            let request = WLResourceRequest(URL: NSURL(string: "/adapters/Enrollment/setPinCode/" + pinCode), method: WLHttpMethodPost)
            request.sendWithCompletionHandler { (response, error) in
                if (error != nil){
                    print("setPinCode error: \(error.description)")
                } else {
                    print("setPinCode status: \(response.status)")
                    self.getBalanceBtn.hidden = false
                    self.getTransactionsBtn.hidden = false
                    self.navigationItem.rightBarButtonItem = self.logoutBtn
                }
            }
        }
    }
    
    func showLoginPage(sender: AnyObject){
        self.performSegueWithIdentifier("login", sender: self)
    }
    
    func showPinCodePopup(notification: NSNotification){
        let alert = UIAlertController(title: "Pin Code",
                                      message: notification.userInfo!["errorMsg"] as? String,
                                      preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "PIN CODE"
            textField.keyboardType = .NumberPad
        }
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let pinTextField = alert.textFields![0] as UITextField
            NSNotificationCenter.defaultCenter().postNotificationName(ACTION_PINCODE_SUBMIT_ANSWER , object: self, userInfo: ["pinCode":pinTextField.text!])
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName(ACTION_PINCODE_CHALLENGE_CANCEL , object: self)
        }))
        
        self.presentViewController(alert,
                                   animated: true,
                                   completion: nil)
    }
    
    func enrollAfterFailure(notification: NSNotification){
        let failureMsg = notification.userInfo!["errorMsg"] as? String
        if (failureMsg == "Account blocked"){
            enroll()
        }
    }

    @IBAction func getPublicData(sender: AnyObject) {
        self.resultTxt.text = ""
        let request = WLResourceRequest(URL: NSURL(string: "/adapters/Enrollment/publicData"), method: WLHttpMethodGet)
        request.sendWithCompletionHandler { (response, error) in
            if (error != nil){
                print("getPublicData error: \(error.description)")
            } else {
                print("getPublicData response: \(response.responseText)")
                self.resultTxt.text = response.responseText
            }
        }
    }

    @IBAction func getBalance(sender: AnyObject) {
        self.resultTxt.text = ""
        let request = WLResourceRequest(URL: NSURL(string: "/adapters/Enrollment/balance"), method: WLHttpMethodGet)
        request.sendWithCompletionHandler { (response, error) in
            if (error != nil){
                print("getBalance error: \(error.description)")
            } else {
                print("getBalance response: \(response.responseText)")
                self.resultTxt.text = response.responseText
            }
        }
    }

    @IBAction func getTransactions(sender: AnyObject) {
        self.resultTxt.text = ""
        let request = WLResourceRequest(URL: NSURL(string: "/adapters/Enrollment/transactions"), method: WLHttpMethodGet)
        request.sendWithCompletionHandler { (response, error) in
            if (error != nil){
                print("getTransactions error: \(error.description)")
            } else {
                print("getTransactions response: \(response.responseText)")
                self.resultTxt.text = response.responseText
            }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}

