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

import Foundation
import IBMMobileFirstPlatformFoundation

class PinCodeChallengeHandler : WLChallengeHandler {
    
    let challengeHandlerName = "PinCodeChallengeHandler"
    let securityCheckName = "EnrollmentPinCode"
    var isChallenged = false
    
    override init() {
        super.init(securityCheck: securityCheckName)
        WLClient.sharedInstance().registerChallengeHandler(self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(challengeSubmitAnswer(_:)), name: ACTION_PINCODE_SUBMIT_ANSWER, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(challengeCanceled), name: ACTION_PINCODE_CHALLENGE_CANCEL, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(logout), name: ACTION_USERLOGIN_LOGOUT_SUCCESS, object: nil)

    }
    
    override func handleChallenge(challenge: [NSObject : AnyObject]!) {
        print("\(self.challengeHandlerName): handleChallenge - \(challenge)")
        isChallenged = true
        var errorMsg: String
        if (challenge["errorMsg"] is NSNull) {
            errorMsg = "Enter PIN code:"
        } else{
            errorMsg = challenge["errorMsg"] as! String
        }
        NSNotificationCenter.defaultCenter().postNotificationName(ACTION_PINCODE_CHALLENGE_RECEIVED , object: self, userInfo: ["errorMsg":errorMsg])
    }
    
    override func handleFailure(failure: [NSObject : AnyObject]!) {
        print("\(self.challengeHandlerName): handleFailure - \(failure)")
        isChallenged = false
        var errorMsg: String
        if (failure["failure"] is NSNull) {
            errorMsg = "Unknown error"
        } else {
            errorMsg = failure["failure"] as! String
        }
        NSNotificationCenter.defaultCenter().postNotificationName(ACTION_PINCODE_CHALLENGE_FAILURE, object: self, userInfo: ["errorMsg":errorMsg])
    }
    
    override func handleSuccess(success: [NSObject : AnyObject]!) {
        print("\(self.challengeHandlerName): handleSuccess - \(success)")
        isChallenged = false
    }
    
    func challengeSubmitAnswer(notification: NSNotification){
        print("\(self.challengeHandlerName): challengeSubmitAnswer")
        self.submitChallengeAnswer(["pin": (notification.userInfo!["pinCode"] as? String)!])
    }
    
    func challengeCanceled(){
        print("\(self.challengeHandlerName): challengeCanceled")
        self.submitFailure(nil)
    }
    
    func logout(){
        print("\(self.challengeHandlerName): logout")
        WLAuthorizationManager.sharedInstance().logout(securityCheckName) { (error) -> Void in
            if (error != nil){
                print("\(self.challengeHandlerName): logout failure - \(error.description)")
            } else {
                print("\(self.challengeHandlerName): logout success)")
                NSNotificationCenter.defaultCenter().postNotificationName(ACTION_USERLOGIN_LOGOUT_SUCCESS , object: self)
            }
        }
    }
}