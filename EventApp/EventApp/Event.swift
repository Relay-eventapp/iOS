//
//  event.swift
//  EventApp
//
//  Created by Mike Zhao on 5/1/15.
//  Copyright (c) 2015 Mike Zhao. All rights reserved.
//

import UIKit

class Event: NSObject {
 
    var id: String!
    var data: PFObject!
    var marker: GMSMarker!
    
    /*
    override init() {
        data = PFObject()
        marker = GMSMarker()
    }
    */
    
    init(data: PFObject) {
        self.data = data
        self.marker = GMSMarker()
    }
    
    init(data: PFObject, marker: GMSMarker) {
        self.data = data
        self.marker = marker
    }
}
