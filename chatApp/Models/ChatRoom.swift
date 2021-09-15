//
//  ChatRoom.swift
//  chatApp
//
//  Created by ShoIwasaki on 2021/08/20.
//

import Foundation
import Firebase
import FirebaseFirestore

class ChatRoom {
    let members:[String]?
    let latestMessageId:String?
    let createdId:Timestamp
    
    var partnerUser:User?
    var documentId:String?
    
    init(dic:[String:Any]) {
        self.members = dic["members"] as? [String] ?? [String]()
        self.latestMessageId = dic["latestMessageId"] as? String ?? ""
        self.createdId = dic["createdId"] as? Timestamp ?? Timestamp()
    }
}
