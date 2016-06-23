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

protocol LoginViewControllerDelegate {
    func LoginViewControllerResponse(userName: String)
}

class LoginViewController: UIViewController {
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    var delegate: LoginViewControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated:true);
        self.navigationItem.title = "Enrollment"
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(popLoginPage(_:)), name: ACTION_USERLOGIN_CHALLENGE_SUCCESS, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(showError(_:)), name: ACTION_USERLOGIN_CHALLENGE_RECEIVED, object: nil)

    }
    
    @IBAction func login(sender: AnyObject) {
        if(self.username.text != "" && self.password.text != ""){
            NSNotificationCenter.defaultCenter().postNotificationName(ACTION_USERLOGIN_SUBMIT_ANSWER, object: self, userInfo: ["username": username.text!, "password": password.text!])
        } else {
            errorLabel.text = "Username and password are required"
        }
    }
    
    func popLoginPage(notification: NSNotification){
        self.delegate?.LoginViewControllerResponse(notification.userInfo!["displayName"] as! String)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func showError(notification: NSNotification){
        self.errorLabel.text = notification.userInfo!["errorMsg"] as? String
    }
 
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
