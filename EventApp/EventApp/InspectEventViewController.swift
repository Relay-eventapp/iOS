//
//  InspectEventTableViewController.swift
//  EventApp
//
//  Created by Mike Zhao on 4/8/15.
//  Copyright (c) 2015 Mike Zhao. All rights reserved.
//

import UIKit

class InspectEventViewController: UIViewController {

    @IBOutlet weak var background: UIImageView!
    var eventId: String!
    var event: PFObject!
    
    let locationButton = UIButton()
    let locationButtonImage = UIImage(named: "map") as UIImage!
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var categoryField: UITextField!
    @IBOutlet weak var timeField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //find the event in the currentEvents Array
        
        event = currentEvents[eventId]!.data
        
        let priority = event["priority"] as! Int
        
        let userImageFile = event["photo"] as? PFFile
        if (userImageFile != nil)
        {
            let imageData = userImageFile?.getData()
            self.background.image = UIImage(data:imageData!)
        }
        else
        {
            let category = event["category"] as! Int
            self.background.image = UIImage(named: "back_\(eventCategories[category].lowercaseString)")
        }
        
        var name = event["name"] as! String
        nameField.text = name
        
        var category = event["category"] as! Int
        categoryField.text = eventCategories[category]
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle
        var startTime = event["startTime"] as! NSDate
        var endTime = event["endTime"] as! NSDate
        
        timeField.text = "\(dateFormatter.stringFromDate(startTime)) - \(dateFormatter.stringFromDate(endTime))"
        
        let location = CLLocationCoordinate2D(latitude: (event["location"] as! PFGeoPoint).latitude, longitude: (event["location"] as! PFGeoPoint).longitude)
        
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(location) { response , error in
            if let address = response?.firstResult() {
                
                let lines = address.lines as! [String]
                self.locationField.text = join(", ",lines)
            }
        }
    }
    
    func dismissView(sender: UIButton)
    {
        performSegueWithIdentifier("exitView", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
