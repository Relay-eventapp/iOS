//
//  MapViewController.swift
//  EventApp
//
//  Created by Mike Zhao on 3/16/15.
//  Copyright (c) 2015 Mike Zhao. All rights reserved.
//

import UIKit

class MapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate
{
    @IBOutlet weak var mapView: GMSMapView!
    let locationManager = CLLocationManager()
    var animator: ZFModalTransitionAnimator?
    var pressedLocation:CLLocationCoordinate2D!
    var didChangeCameraPosition:Bool!
    var selectedMarkerId: String!
    var info: infoWindow!

    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        if status == .AuthorizedWhenInUse
        {
            locationManager.startUpdatingLocation()
            mapView.myLocationEnabled = true
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!)
    {
        if let location = locations.first as? CLLocation
        {
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            locationManager.stopUpdatingLocation()
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()

        mapView.settings.consumesGesturesInView = true
        mapView.myLocationEnabled = true
        mapView.mapType = kGMSTypeNormal //Normal, Satellite, Hybrid, Terrain, None
        mapView.delegate = self

        info = infoWindow(frame: CGRectMake(0, view.frame.height, view.frame.width, 96))
        info.hidden = true
        view.addSubview(info)
        
        let tap = UITapGestureRecognizer(target: self, action: Selector("infoWindowTapped:"))
        tap.delegate = self
        info.addGestureRecognizer(tap)
        
        updateEventsInView(mapView.camera)
    }
    
    @IBAction func unwindToMapViewController(sender: UIStoryboardSegue)
    {
        updateEventsInView(mapView.camera)
    }
    
    func mapView(mapView: GMSMapView!, didLongPressAtCoordinate coordinate: CLLocationCoordinate2D)
    {
        pressedLocation = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)
        self.performSegueWithIdentifier("createEvent", sender: self)
    }
    
    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!)
    {
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
            UIView.animateWithDuration(0.15, animations:
            {
                self.info.frame = CGRectMake(0, self.view.frame.height, self.view.frame.height, self.info.frame.height)
            },
            completion:
            {
                (value: Bool) in
                self.info.hidden = true
            })
        }
    }
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool
    {
        selectedMarkerId = marker.userData as! String
        self.info.getInfo(selectedMarkerId)
        if(info.hidden == true)
        {
            info.hidden = false
            UIView.animateWithDuration(0.15)
            {
                self.info.frame = CGRectMake(0, self.view.frame.height-self.info.frame.height-self.tabBarController!.tabBar.frame.height, self.view.frame.height, self.info.frame.height)
            }
        }
        return false
    }
    
    func infoWindowTapped(sender: UITapGestureRecognizer)
    {
        performSegueWithIdentifier("inspectEvent", sender: self)
    }
    
    func updateEventsInView(position: GMSCameraPosition)
    {
        let view = PFGeoPoint(latitude: position.target.latitude, longitude: position.target.longitude)
        var query = PFQuery(className: "Events")
        query.selectKeys(["location"])
        query.whereKey("location", nearGeoPoint: view, withinKilometers: 10)
        query.orderByDescending("priority")
        query.limit = 100
        
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if(error != nil)
            {
                println(error)
                return
            }
            
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
    }

    func createMarkerIcon(priority: Int!, category: Int!, subCategory: Int!) -> UIImage
    {
        var size :CGFloat = 36.0
        var rs :CGFloat = 0.0 //CGFloat(Int(arc4random()) % 24)
        var newSize = CGSizeMake(size+rs, size+rs)
        
        var inset: CGFloat = 6
        var eventColor =  eventColors[priority].CGColor
        var popupColor = CGColorCreateCopyWithAlpha(eventColor, 0.85)
        
        UIGraphicsBeginImageContext(newSize)
        
        var marker = CALayer()
        var popup = CAShapeLayer()
        var backgroundImage = UIImage(named: "sback_\(eventCategories[category].lowercaseString)")
        var icon = UIImage(named: "\(eventCategories[category])\(subCategory)")
        
        marker.frame = CGRectMake(0, 0, newSize.width, newSize.height)
        popup.frame = marker.bounds
        popup.backgroundColor = popupColor
        
        var startAngle:Float = Float(2 * M_PI)
        var endAngle: Float = 0.0

        let strokeWidth = 1
        let radius = CGFloat((CGFloat(popup.frame.size.width) - CGFloat(strokeWidth)) / 2)
        var context = UIGraphicsGetCurrentContext()
        let center = CGPointMake(popup.frame.size.width / 2, popup.frame.size.width / 2)
        CGContextSetStrokeColorWithColor(context, popupColor)
        CGContextSetFillColorWithColor(context, popupColor)
        CGContextSetLineWidth(context, CGFloat(strokeWidth))
        startAngle = startAngle - Float(M_PI_2)
        endAngle = endAngle - Float(M_PI_2)
        CGContextAddArc(context, center.x, center.y, CGFloat(radius), CGFloat(startAngle), CGFloat(endAngle), 0)
        CGContextDrawPath(context, kCGPathFillStroke) // or kCGPathFillStroke to fill and stroke the circle

        icon?.drawInRect(CGRectMake(inset, inset, newSize.width-2*inset, newSize.height-2*inset))
        
        marker.renderInContext(UIGraphicsGetCurrentContext())
        var image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
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
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
}
