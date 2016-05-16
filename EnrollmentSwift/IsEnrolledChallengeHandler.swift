//
//  IsEnrolledChallengeHandler.swift
//  EnrollmentSwift
//
//  Created by Lior Burg on 10/05/2016.
//  Copyright © 2016 sample. All rights reserved.
//

import Foundation
import IBMMobileFirstPlatformFoundation

class IsEnrolledChallengeHandler: WLChallengeHandler{
    let challengeHandlerName = "IsEnrolledChallengeHandler"
    let securityCheckName = "IsEnrolled"
    
    override init() {
        super.init(securityCheck: securityCheckName)
        WLClient.sharedInstance().registerChallengeHandler(self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(logout), name: ACTION_PINCODE_LOGOUT_SUCCESS, object: nil)
    }
    
    func logout(){
        print("\(self.challengeHandlerName): logout")
        WLAuthorizationManager.sharedInstance().logout(securityCheckName) { (error) -> Void in
            if (error != nil){
                print("\(self.challengeHandlerName): logout failure - \(error.description)")
            } else {
                print("\(self.challengeHandlerName): logout success)")
                NSNotificationCenter.defaultCenter().postNotificationName(ACTION_ISENROLLED_LOGOUT_SUCCESS, object: self)
            }
        }
    }
}