//
//  Message.swift
//  chatApp
//
//  Created by ShoIwasaki on 2021/08/29.
//

import Foundation
import Firebase

class Message{
    let name:String
    let message:String
    let uid:String
    let createdAd:Timestamp
    
    var partnerUser:User?
    
    init(dic:[String:Any]) {
        self.name = dic["name"] as? String ?? ""
        self.message = dic["message"] as? String ?? ""
        self.uid = dic["uid"] as? String ?? ""
        self.createdAd = dic["createdAd"] as? Timestamp ?? Timestamp()
        
    }
    
}
