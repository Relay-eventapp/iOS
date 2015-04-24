//
//  Event.swift
//  EventApp
//
//  Created by Mike Zhao on 4/13/15.
//  Copyright (c) 2015 Mike Zhao. All rights reserved.
//

import UIKit

class Event {
   
    //init variables
    var objectId: String!
    var createdAt: NSDate!
    var updatedAt: NSDate!
    
    //first level retrieval
    var location: CLLocationCoordinate2D!
    var priority: Int!
    var access: Int!
    var startTime: NSDate!
    var endTime: NSDate!
    
    //second level retrieval
    var name: String!
    var type: Int!

    var photo: UIImage!
    
    //third level retrieval
    var creator: String!
    var description: String!
    var attendees: [String]!
    
    //init
    init(objectId: String, createdAt: NSDate, updatedAt: NSDate) {
        self.objectId = objectId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
