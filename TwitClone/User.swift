//
//  User.swift
//  TwitClone
//
//  Created by Nathan Birkholz on 10/9/14.
//  Copyright (c) 2014 Nate Birkholz. All rights reserved.
//

import UIKit

class User {
    
    var userImageSmall : UIImage?
    var userTopDictionary : NSDictionary?
//    var userImageLarge : UIImage?
    var userName : String
    var screenName : String
    
    
    init (userTopDictionary : NSDictionary) {
        let userTopDictionary = userTopDictionary
        self.userTopDictionary = userTopDictionary
        
        var userNestedDictionary = userTopDictionary["user"] as NSDictionary
        
        self.userName = userNestedDictionary["name"] as String
        self.screenName = userNestedDictionary["screen_name"] as String
        
        
    }
    
    init(imageSmall : UIImage, userName : String, userHandle : String){
        self.userImageSmall = imageSmall
        self.userName = userName
        self.screenName = userHandle
    }
    
    
    
}