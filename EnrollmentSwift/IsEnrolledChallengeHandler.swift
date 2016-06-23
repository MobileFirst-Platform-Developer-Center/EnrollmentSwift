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

class IsEnrolledChallengeHandler : SecurityCheckChallengeHandler {
    let challengeHandlerName = "IsEnrolledChallengeHandler"
    let securityCheckName = "IsEnrolled"
    
    override init() {
        super.init(securityCheck: securityCheckName)
        WLClient.sharedInstance().registerChallengeHandler(self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(logout), name: ACTION_PINCODE_LOGOUT_SUCCESS, object: nil)
    }
    
    override func handleSuccess(success: [NSObject : AnyObject]!) {
        print("\(self.challengeHandlerName): handleSuccess - \(success)")
        let userDisplayName = success["user"]!["displayName"] as! String
        NSNotificationCenter.defaultCenter().postNotificationName(ACTION_ISENROLLED_CHALLENGE_SUCCESS , object: self, userInfo: ["displayName":userDisplayName])
    }
    
    func logout(){
        print("IsEnrolled: logout")
        WLAuthorizationManager.sharedInstance().logout("IsEnrolled") { (error) -> Void in
            if (error != nil){
                print("\(self.challengeHandlerName): logout failure - \(error.description)")
            } else {
                print("\(self.challengeHandlerName): logout success)")
                NSNotificationCenter.defaultCenter().postNotificationName(ACTION_ISENROLLED_LOGOUT_SUCCESS , object: self)
            }
        }
    }

}
