//
//  MapViewController.swift
//  EventApp
//
//  Created by Mike Zhao on 3/16/15.
//  Copyright (c) 2015 Mike Zhao. All rights reserved.
//

import UIKit

var currentEvents = Dictionary<String, Event>()

var eventColors:[UIColor]! =
[
    UIColor(rgba: "#155339"),
    UIColor(rgba: "#A84241"),
    UIColor(rgba: "#A17144"),
    UIColor(rgba: "#376874"),
    UIColor(rgba: "#42375F"),
    UIColor(rgba: "#5C3950"),
    //UIColor(rgba: "#155339"),
    //UIColor(rgba: "#A84241"),
    //UIColor(rgba: "#A17144"),
    //UIColor(rgba: "#376874")
    
]

var eventCategories:[String]! =
[
    "Arts","Business","Charity & Causes","Chill","Community","Education","Fashion","Fitness & Health","Food & Drink","History","Music","Networking","Other","Science & Tech"
]

class MapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate
{
    //create a location manager
    let locationManager = CLLocationManager()
    var animator: ZFModalTransitionAnimator?
    
    //create the map
    @IBOutlet weak var mapView: GMSMapView!
    
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
        //kGMSTypeNormal, kGMSTypeSatellite, kGMSTypeHybrid, kGMSTypeTerrain, kGMSTypeNone
        mapView.delegate = self

        info = infoWindow(frame: CGRectMake(0, view.frame.height, view.frame.width, 96))
        info.hidden = true
        view.addSubview(info)
        
        let tap = UITapGestureRecognizer(target: self, action: Selector("infoWindowTapped:"))
        tap.delegate = self
        info.addGestureRecognizer(tap)

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
            self.animator!.transitionDuration = 0.45
        }
        else if segue.identifier == "inspectEvent"
        {
            let inspectEventViewController = segue.destinationViewController as! InspectEventViewController
            inspectEventViewController.eventId = selectedMarkerId
            self.animator = ZFModalTransitionAnimator(modalViewController: inspectEventViewController)
            inspectEventViewController.transitioningDelegate = self.animator!
            inspectEventViewController.modalPresentationStyle = .Custom
            self.animator!.dragable = true
            self.animator!.bounces = false
            self.animator!.direction = .Bottom
            self.animator!.transitionDuration = 0.6
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
                self.info.frame = CGRectMake(0, self.view.frame.height-self.info.frame.height-self.tabBarController!.tabBar.frame.height, self.view.frame.height, self.info.frame.height)
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
        query.selectKeys(["location"])
        //query.selectKeys(["location", "priority", "access", "startTime", "endTime", "category", "subCategory"])
        query.whereKey("location", nearGeoPoint: view, withinKilometers: 10)
        query.orderByDescending("priority")
        query.limit = 100
        
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if(error == nil)
            {
                if let events = objects as? [PFObject]
                {
                    var updatedEvents = [String]()
                    var newEvents = [String]()
                    var eventsToRemove = [String]()
                    
                    //first append all events to the updatedEvents array
                    for event in events
                    {
                        updatedEvents.append(event.objectId!)
                    }
                    
                    //append new events to the newEvents array
                    for eventId in updatedEvents
                    {
                        if(currentEvents[eventId] == nil)
                        {
                            newEvents.append(eventId)
                        }
                    }
                    
                    //append events that should be removed to the eventsToRemove array
                    for (id, data) in currentEvents
                    {
                        if !contains(updatedEvents, id)
                        {
                            eventsToRemove.append(id)
                        }
                    }
                    
                    query.selectKeys(["location", "priority", "access", "startTime", "endTime", "category", "subCategory"])
                    
                    for newEventId in newEvents
                    {
                        var newEvent = query.getObjectWithId(newEventId)
                        //query.getObjectInBackgroundWithId(newEventId, block: { (newEvent: PFObject?, error: NSError?) -> Void in
                            
                                let location = CLLocationCoordinate2D(latitude: (newEvent!["location"] as! PFGeoPoint).latitude, longitude: (newEvent!["location"] as! PFGeoPoint).longitude)
                                
                                let priority = newEvent!["priority"] as! Int
                                let category = newEvent!["category"] as! Int
                                let subCategory = newEvent!["subCategory"] as! Int
                            
                                var newMarker = GMSMarker(position:location)
                                newMarker.icon = self.createMarkerIcon(priority, category: category, subCategory: subCategory)
                                newMarker.userData = newEventId
                                newMarker.appearAnimation = kGMSMarkerAnimationPop
                                newMarker.map = self.mapView
                            
                                currentEvents[newEventId] = Event(data: newEvent!, marker: newMarker)
                        //})
                    }
                    //remove markers and events
                    for eventToRemove in eventsToRemove
                    {
                        currentEvents[eventToRemove]!.marker.map = nil
                        currentEvents.removeValueForKey(eventToRemove)
                    }
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
        var newSize = CGSizeMake(36, 36)
        var popupColor = eventColors[priority].CGColor
        
        UIGraphicsBeginImageContext(newSize)
        
        var marker = CALayer()
        var popup = CAShapeLayer()
        //println("\(eventCategories[category])\(subCategory)")
        var backgroundImage = UIImage(named: "sback_\(eventCategories[category].lowercaseString)")
        var icon = UIImage(named: "\(eventCategories[category])0")
        
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

        var inset: CGFloat = 6
        icon?.drawInRect(CGRectMake(inset, inset, newSize.width-2*inset, newSize.height-2*inset))
        
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
