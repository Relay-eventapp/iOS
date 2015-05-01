//
//  InfoWindow.swift
//  EventApp
//
//  Created by Mike Zhao on 4/15/15.
//  Copyright (c) 2015 Mike Zhao. All rights reserved.
//

import UIKit

class infoWindow: UIView, UIGestureRecognizerDelegate {

    var image: UIImageView!
    var timeicon: UIImageView!
    var mapicon: UIImageView!
    var name: UILabel!
    var date: UILabel!
    var address: UILabel!
    
    override init(frame: CGRect)
    {
        super.init(frame : frame)
        var txtClr = UIColor(red: 225/255.0, green: 225/255.0, blue: 225/255.0, alpha: 1.0)
        var blur = UIVisualEffectView(effect: UIBlurEffect(style: .Dark)) as UIVisualEffectView
        blur.frame = self.bounds
        self.addSubview(blur)
        //self.backgroundColor = UIColor(red: 75/255.0, green: 70/255.0, blue: 85/255.0, alpha: 1.0)
        
        image = UIImageView(frame: CGRectMake(8, 8, self.frame.height-16, self.frame.height-16))
        
        var o = image.frame.maxX + 8
        var l = self.frame.width - image.frame.width - 16
        var h:CGFloat = (self.frame.height-32)/3
        name = UILabel(frame: CGRectMake(o, 8, l, h+8))
        
        date = UILabel(frame: CGRectMake(o+h+4, name.frame.maxY+4, l-h, h))
        address = UILabel(frame: CGRectMake(o+h+4, date.frame.maxY+4, l-h,h))
        
        timeicon = UIImageView(frame: CGRectMake(o, name.frame.maxY+4, h, h))
        mapicon = UIImageView(frame: CGRectMake(o, date.frame.maxY+4, h, h))
        timeicon.image = UIImage(named: "uicalendar")
        mapicon.image = UIImage(named: "uilocation")
        
        image.backgroundColor = UIColor.lightGrayColor()
        image.contentMode = UIViewContentMode.ScaleAspectFill
        image.clipsToBounds = true
        
        self.addSubview(image)
        self.addSubview(name)
        self.addSubview(timeicon)
        self.addSubview(date)
        self.addSubview(mapicon)
        self.addSubview(address)
        
        name.textColor = UIColor.whiteColor()
        name.font = UIFont(name: "HelveticaNeue-Light", size: 24)
        date.textColor = txtClr
        date.font = UIFont(name: "HelveticaNeue-Light", size: 17)
        address.textColor = txtClr
        address.font = UIFont(name: "HelveticaNeue-Light", size: 17)
    }

    func getInfo(eventId: String)
    {
        image.image = UIImage()
        name.text = ""
        address.text = ""
        date.text = ""
        
        var query = PFQuery(className: "Events")
        query.selectKeys(["name", "photo"])
        let event = query.getObjectWithId(eventId) as PFObject!
        let startTime = event["startTime"] as! NSDate
        
        name.text = event["name"] as? String
        
        let geocoder = GMSGeocoder()
        let pflocation = event["location"] as! PFGeoPoint!
        var location = CLLocationCoordinate2D(latitude: pflocation.latitude, longitude: pflocation.longitude)
        
        geocoder.reverseGeocodeCoordinate(location) { response , error in
            
            if let location = response?.firstResult() {
                
                let lines = location.lines as! [String]
                self.address.text = join("\n", lines)
                
            }
        }
        
        var formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        date.text = formatter.stringFromDate(startTime)
        
        let userImageFile = event["photo"] as? PFFile
        if (userImageFile != nil)
        {
            let imageData = userImageFile?.getData()
            self.image.image = UIImage(data:imageData!)
        }
        else
        {
            let category = event["category"] as! Int
            self.image.image = UIImage(named: "sback_\(eventCategories[category].lowercaseString)")
        }
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
