//
//  MapViewController.swift
//  EventApp
//
//  Created by Mike Zhao on 3/16/15.
//  Copyright (c) 2015 Mike Zhao. All rights reserved.
//

import UIKit

var currentEvents:[PFObject]! = []


var eventColors:[UIColor]! =
[
    UIColor(rgba: "#90745B"),
    UIColor(rgba: "#9F363A"),
    UIColor(rgba: "#6E4931"),
    UIColor(rgba: "#5A5A5A"),
    UIColor(rgba: "#7A567B"),
    UIColor(rgba: "#C24100"),
    UIColor(rgba: "#5F504D"),
    UIColor(rgba: "#2C4F60"),
    UIColor(rgba: "#467E36"),
    UIColor(rgba: "#435E80")
    
]
/*[
    UIColor(red: 44/255.0, green: 56/255.0, blue: 114/255.0, alpha: 1.0),
    UIColor(red: 60/255.0, green: 29/255.0, blue: 64/255.0, alpha: 1.0),
    UIColor(red: 37/255.0, green: 64/255.0, blue: 38/255.0, alpha: 1.0),
    UIColor(red: 80/255.0, green: 28/255.0, blue: 24/255.0, alpha: 1.0),
    UIColor(red: 62/255.0, green: 45/255.0, blue: 31/255.0, alpha: 1.0),
    UIColor(red: 34/255.0, green: 46/255.0, blue: 64/255.0, alpha: 1.0),
    UIColor(red: 217/255.0, green: 108/255.0, blue: 0/255.0, alpha: 1.0),
    UIColor(red: 172/255.0, green: 40/255.0, blue: 28/255.0, alpha: 1.0),
    UIColor(red: 95/255.0, green: 80/255.0, blue: 77/255.0, alpha: 1.0),
    UIColor(red: 201/255.0, green: 63/255.0, blue: 69/255.0, alpha: 1.0)
]*/

var eventCategories:[String]! =
[
    "Chill","Music","Food & Drink","Education","Networking","Business","Community","Arts",
    "Science & Tech","Fashion","History","Fitness & Health","Charity & Causes", "Other"
]

class MapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate
{
    //create a location manager
    let locationManager = CLLocationManager()
    var animator: ZFModalTransitionAnimator?
    
    //create the UI buttons
    var menuButton = VBFPopFlatButton()
    var filterEventsButton = VBFPopFlatButton()
    
    //create the map
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var navigationLabel: UILabel!
    
    var pressedLocation:CLLocationCoordinate2D!
    var didChangeCameraPosition:Bool!
    var selectedMarkerId: String!
    
    var info: infoWindow!
    
    //Load the View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initialize the location manager
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        //set up the map view
        mapView.settings.consumesGesturesInView = true
        mapView.mapType = kGMSTypeNormal
        mapView.delegate = self
    
        //initialize the menu button
        menuButton = VBFPopFlatButton(frame: CGRectMake(16,30,28,28), buttonType: .buttonMenuType, buttonStyle: .buttonPlainStyle, animateToInitialState: false)
        //menuButton.contentEdgeInsets = UIEdgeInsetsMake(4, 4, 4, 4)
        menuButton.lineThickness = 2
        menuButton.tintColor = UIColor.whiteColor()
        self.view.addSubview(menuButton)
            
        //initialize the filter events button
        /*
        filterEventsButton = VBFPopFlatButton(frame: CGRectMake(view.frame.width-16-26,30,36,36), buttonType: .buttonForwardType, buttonStyle: .buttonPlainStyle, animateToInitialState: false)
        filterEventsButton.lineThickness = 2
        filterEventsButton.tintColor = UIColor.whiteColor()
        self.view.addSubview(filterEventsButton)
        */

        info = infoWindow(frame: CGRectMake(0, view.frame.height, view.frame.width, 96))
        info.hidden = true
        view.addSubview(info)
        
        let tap = UITapGestureRecognizer(target: self, action: Selector("infoWindowTapped:"))
        tap.delegate = self
        info.addGestureRecognizer(tap)
        
        menuButton.addTarget(self, action: "revealMenu:", forControlEvents: .TouchUpInside)
        updateEventsInView(mapView.camera)
    }
    
    func revealMenu(sender: UIButton)
    {
        slideMenuController()?.openLeft()
    }
    
    override func viewWillAppear(animated: Bool) {
        mapView.myLocationEnabled = true
        mapView.settings.myLocationButton = true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "createEvent"
        {
            let createEventViewController = segue.destinationViewController as! CreateEventViewController
            createEventViewController.newEventLocation = pressedLocation
            println("pressed location: \(pressedLocation)")
            self.animator = ZFModalTransitionAnimator(modalViewController: createEventViewController)
            createEventViewController.transitioningDelegate = self.animator!
            createEventViewController.modalPresentationStyle = .Custom
            self.animator!.dragable = true
            self.animator!.bounces = false
            self.animator!.direction = .Right
            self.animator!.transitionDuration = 0.4
        }
        else if segue.identifier == "inspectEvent"
        {
            let vc = segue.destinationViewController as! InspectEventViewController
            vc.eventId = selectedMarkerId
        }
    }
    
    @IBAction func unwindToMapViewController(sender: UIStoryboardSegue)
    {
        updateEventsInView(mapView.camera)
    }
    
    func mapView(mapView: GMSMapView!, didLongPressAtCoordinate coordinate: CLLocationCoordinate2D) {
        
        pressedLocation = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)
        self.performSegueWithIdentifier("createEvent", sender: self)
    }
    
    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
        
        if(didChangeCameraPosition == true)
        {
            updateEventsInView(position)
            didChangeCameraPosition = false
        }
        
    }
    
    func mapView(mapView: GMSMapView!, didChangeCameraPosition position: GMSCameraPosition!)
    {
        didChangeCameraPosition = true
    }

    func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        if(info.hidden == false)
        {
            UIView.animateWithDuration(0.15, animations: {
                //self.info.alpha = 0
                self.info.frame = CGRectMake(0, self.view.frame.height, self.view.frame.height, self.info.frame.height)
                self.mapView.padding = UIEdgeInsets(top: self.topLayoutGuide.length, left: 0, bottom: 0, right: 0)
                }, completion: {
                    (value: Bool) in
                    self.info.hidden = true
            })
        }
    }
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        
        selectedMarkerId = marker.userData as! String
        self.info.getInfo(selectedMarkerId)
        if(info.hidden == true)
        {
            info.hidden = false
            //info.alpha = 0
            UIView.animateWithDuration(0.15)
            {
                //self.info.alpha = 1
                self.info.frame = CGRectMake(0, self.view.frame.height-self.info.frame.height, self.view.frame.height, self.info.frame.height)
                self.mapView.padding = UIEdgeInsets(top: self.topLayoutGuide.length, left: 0, bottom: self.info.frame.height, right: 0)
            }
        }
        return false
    }
    
    func infoWindowTapped(sender: UITapGestureRecognizer) {
        performSegueWithIdentifier("inspectEvent", sender: self)
    }
    
    func updateEventsInView(position: GMSCameraPosition)
    {
        let view = PFGeoPoint(latitude: position.target.latitude, longitude: position.target.longitude)
        var query = PFQuery(className: "Events")
        query.selectKeys(["location", "priority", "access", "startTime", "endTime", "category", "subCategory"])
        query.whereKey("location", nearGeoPoint: view, withinKilometers: 10)
        query.orderByDescending("priority")
        query.limit = 100
        
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            
                if(error == nil)
                {
                    var updatedEvents = [PFObject]()
                    var newEvents = [PFObject]()
                    var eventsToRemove = [PFObject]()
                    
                    //search for new events
                    if let arr = objects as? [PFObject]
                    {
                        for event in arr {
                            
                            updatedEvents.append(event)
                            if(!contains(currentEvents, event))
                            {
                                newEvents.append(event)
                            }
                        }
                    }
                    
                    //add events that are no longer needed to the eventsToRemove array
                    for event in currentEvents {
                        
                        if(!contains(updatedEvents, event))
                        {
                            eventsToRemove.append(event)
                        }
                    }
                    
                    //update all newEvents with PFQuery
                    for newEvent in newEvents {
                        
                        var location = CLLocationCoordinate2D(latitude: (newEvent["location"] as! PFGeoPoint).latitude, longitude: (newEvent["location"] as! PFGeoPoint).longitude)
                        
                        let priority = newEvent["priority"] as! Int
                        let category = newEvent["category"] as! Int
                        let subCategory = newEvent["subCategory"] as! Int
                        var marker = GMSMarker(position:location)
                        marker.icon = self.createMarkerIcon(priority, category: category, subCategory: subCategory)
                        
                        marker.userData = newEvent.objectId
                        marker.appearAnimation = kGMSMarkerAnimationPop
                        marker.map = self.mapView
                    }
                    
                    currentEvents = currentEvents.filter { event in
                        !contains(eventsToRemove, event)
                    }
                    
                    for event in newEvents {
                        currentEvents.append(event)
                    }
                    
                }
                else
                {
                    println("Error: \(error)")
                }

        }
        
    }
    
    //Start Updating Location
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if status == .AuthorizedWhenInUse {
            
            locationManager.startUpdatingLocation()
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
    
    //Stop Updating Location
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location = locations.first as? CLLocation {
            
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            locationManager.stopUpdatingLocation()
        }
    }
    
    //create the marker layer
    func createMarkerIcon(priority: Int!, category: Int!, subCategory: Int!) -> UIImage
    {
        var newSize = CGSizeMake(42, 42)
        var popupColor = eventColors[priority].CGColor //UIColor(red: 33/255.0, green: 33/255.0, blue: 33/255.0, alpha: 1.0).CGColor //UIColor(red: 221/255.0, green: 70/255.0, blue: 80/255.0, alpha: 1.0).CGColor
        
        UIGraphicsBeginImageContext(newSize)
        
        var marker = CALayer()
        var popup = CAShapeLayer()
        //println("\(eventCategories[category])\(subCategory)")
        var icon = UIImage(named: "\(eventCategories[category])\(subCategory)")
        
        marker.frame = CGRectMake(0, 0, newSize.width, newSize.height)
        popup.frame = marker.bounds
        popup.backgroundColor = popupColor
        
        var startAngle:Float = Float(2 * M_PI)
        var endAngle: Float = 0.0

        let strokeWidth = popup.frame.width/2
        let radius = CGFloat((CGFloat(popup.frame.size.width) - CGFloat(strokeWidth)) / 2)
        var context = UIGraphicsGetCurrentContext()
        let center = CGPointMake(popup.frame.size.width / 2, popup.frame.size.width / 2)
        CGContextSetStrokeColorWithColor(context, popupColor)
        CGContextSetLineWidth(context, CGFloat(strokeWidth))
        startAngle = startAngle - Float(M_PI_2)
        endAngle = endAngle - Float(M_PI_2)
        CGContextAddArc(context, center.x, center.y, CGFloat(radius), CGFloat(startAngle), CGFloat(endAngle), 0)
        CGContextDrawPath(context, kCGPathStroke) // or kCGPathFillStroke to fill and stroke the circle
        icon?.drawInRect(CGRectMake(8, 8, newSize.width-16, newSize.width-16))
        marker.renderInContext(UIGraphicsGetCurrentContext())
        var image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
