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

class UserLoginChallengeHandler : SecurityCheckChallengeHandler {
    let challengeHandlerName = "UserLoginChallengeHandler"
    let securityCheckName = "EnrollmentUserLogin"
    var isChallenged = false
    
    override init() {
        super.init(securityCheck: securityCheckName)
        WLClient.sharedInstance().registerChallengeHandler(self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(login(_:)), name: ACTION_USERLOGIN_SUBMIT_ANSWER, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(logout), name: ACTION_LOGOUT, object: nil)
    }
    
    override func handleChallenge(challenge: [NSObject : AnyObject]!) {
        print("\(self.challengeHandlerName): handleChallenge - \(challenge)")
        self.isChallenged = true
        var errorMsg = ""
        if (challenge["errorMsg"] is NSNull) {
            errorMsg = ""
        } else{
            errorMsg = challenge["errorMsg"] as! String
        }
        NSNotificationCenter.defaultCenter().postNotificationName(ACTION_USERLOGIN_CHALLENGE_RECEIVED , object: self, userInfo: ["errorMsg":errorMsg])
    }
    
    override func handleSuccess(success: [NSObject : AnyObject]!) {
        print("\(self.challengeHandlerName): handleSuccess - \(success)")
        self.isChallenged = false
        let userDisplayName = success["user"]!["displayName"] as! String
        NSNotificationCenter.defaultCenter().postNotificationName(ACTION_USERLOGIN_CHALLENGE_SUCCESS , object: self, userInfo: ["displayName":userDisplayName])
    }
    
    override func handleFailure(failure: [NSObject : AnyObject]!) {
        print("\(self.challengeHandlerName): \(failure)")
        self.isChallenged = false
    }
    
    func login(notification: NSNotification){
        let username = notification.userInfo!["username"] as! String
        let password = notification.userInfo!["password"] as! String
        if(!self.isChallenged){
            print("\(self.challengeHandlerName): login")
            WLAuthorizationManager.sharedInstance().login(securityCheckName, withCredentials: ["username": username, "password": password]) { (error) -> Void in
                if(error != nil){
                    print("\(self.challengeHandlerName): login failure - \(error.description)")
                } else {
                    print("\(self.challengeHandlerName): login success")
                }
            }
        } else {
            print("\(self.challengeHandlerName): submitChallengeAnswer")
            self.submitChallengeAnswer(["username": username, "password": password])
        }
    }
    
    func logout(){
        print("\(self.challengeHandlerName): logout")
        WLAuthorizationManager.sharedInstance().logout(securityCheckName) { (error) -> Void in
            if (error != nil){
                print("\(self.challengeHandlerName): logout failure - \(error.description)")
            } else {
                print("\(self.challengeHandlerName): logout success)")
                NSNotificationCenter.defaultCenter().postNotificationName(ACTION_USERLOGIN_LOGOUT_SUCCESS , object: self)
                self.isChallenged = false
            }
        }
    }

}
