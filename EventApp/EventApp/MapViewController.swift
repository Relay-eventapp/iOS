//
//  MapViewController.swift
//  EventApp
//
//  Created by Mike Zhao on 3/16/15.
//  Copyright (c) 2015 Mike Zhao. All rights reserved.
//

import UIKit

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate
{
    //create a location manager
    let locationManager = CLLocationManager()
    
    //create the UI buttons
    let menuButton = UIButton()
    let menuButtonImage = UIImage(named: "menu") as UIImage!
    let filterEventsButton = UIButton()
    let filterEventsButtonImage = UIImage(named: "filter") as UIImage!
    
    //create the map
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var navigationLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!

    var pressedLocation:CLLocationCoordinate2D!
    var didChangeCameraPosition:Bool!
    
    var currentEvents: NSMutableArray!
    var currentMarkers: Dictionary <String, GMSMarker>!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    //Load the View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentEvents = NSMutableArray(capacity: 20)
        currentMarkers = Dictionary <String, GMSMarker>()
        
        //initialize the location manager
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        //set up the map view
        mapView.settings.consumesGesturesInView = true
        mapView.mapType = kGMSTypeNormal
        mapView.delegate = self
        
        //initialize the menu button
        menuButton.setImage(menuButtonImage, forState: .Normal)
        menuButton.frame = CGRectMake(8, 16+1, 42, 42)
        self.view.addSubview(menuButton)
        
        //initialize the filter events button
        filterEventsButton.setImage(filterEventsButtonImage, forState: .Normal)
        filterEventsButton.frame = CGRectMake(self.view.frame.width - 8 - 42, 16, 42, 42)
        self.view.addSubview(filterEventsButton)
        
        if self.revealViewController() != nil {
            
            self.revealViewController().rearViewRevealWidth = 0.9*self.view.frame.width
            
            menuButton.addTarget(self.revealViewController(), action:Selector("revealToggle:"), forControlEvents: .TouchUpInside)
        }
        
        updateEventsInView(mapView.camera)
    }
    
    override func viewWillAppear(animated: Bool) {
    
        //TODO: find a way to implement this if statement
        
        //if status == .AuthorizedWhenInUse {
        
            println("\nMap View:")
        
            //locationManager.startUpdatingLocation()
        
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
        
            let labelHeight = self.addressLabel.frame.height
            self.mapView.padding = UIEdgeInsets(top: self.topLayoutGuide.length, left: 0, bottom: labelHeight, right: 0)
        
        //}
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "createNewEvent"
        {
            println("Performing segue to New Event Table View.")
            let vc = segue.destinationViewController as NewEventTableViewController
            vc.newEventLocation = pressedLocation
        }
    }
    
    @IBAction func unwindToMapViewController(sender: UIStoryboardSegue)
    {
        updateEventsInView(mapView.camera)
        println("Unwinding to Map View.")
    }
    
    func mapView(mapView: GMSMapView!, didLongPressAtCoordinate coordinate: CLLocationCoordinate2D) {
        
        pressedLocation = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)
        self.performSegueWithIdentifier("createNewEvent", sender: self)
    }
    
    /*
    //return a custom info window
    func mapView(mapView: GMSMapView!, markerInfoWindow marker: GMSMarker!) -> UIView! {
        
        var customInfoWindow = NSBundle.mainBundle().loadNibNamed("InfoWindow", owner: self, options: nil)[0] as CustomInfoWindow
        return customInfoWindow
    }
    */
    
    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
        
        reverseGeocodeCoordinate(position.target)
        
        if(didChangeCameraPosition == true)
        {
            updateEventsInView(position)
            didChangeCameraPosition = false
        }
        
    }
    
    func mapView(mapView: GMSMapView!, didChangeCameraPosition position: GMSCameraPosition!) {
        
        didChangeCameraPosition = true
        
    }
    
    //lock the Map View when the user is scrolling in the Map View
    func mapView(mapView: GMSMapView!, willMove gesture: Bool) {
        addressLabel.lock()
    }
    
    func updateEventsInView(position: GMSCameraPosition)
    {
        let view = PFGeoPoint(latitude: position.target.latitude, longitude: position.target.longitude)
        
        var query = PFQuery(className: "Events")
        query.orderByDescending("priority")
        //query.fromLocalDatastore()
        query.whereKey("location", nearGeoPoint: view, withinKilometers: 10)
        query.limit = 20
        
        query.findObjectsInBackgroundWithBlock
        { (objects: [AnyObject]!, error: NSError!) -> Void in
            
            if(error == nil)
            {
                var updatedEvents = NSMutableArray(capacity: 20)
                var newEvents = NSMutableArray(capacity: 20)
                var eventsToRemove = NSMutableArray(capacity: 20)
                
                //search for new events
                for event in objects {
                    
                    var updatedEvent = event as PFObject
                    updatedEvents.addObject(updatedEvent)
                    
                    //add new events to the newEvents array
                    if(!self.currentEvents.containsObject(updatedEvent))
                    {
                        newEvents.addObject(updatedEvent)
                    }
                }
                
                //add events that are no longer needed to the eventsToRemove array
                for event in self.currentEvents {
                    
                    if(!updatedEvents.containsObject(event))
                    {
                        eventsToRemove.addObject(event)
                    }
                }
                
                for newEvent in newEvents {
                    
                    var name = newEvent["name"] as String
                    var description = newEvent["description"] as String
                    var location = CLLocationCoordinate2D(latitude: (newEvent["location"] as PFGeoPoint).latitude, longitude: (newEvent["location"] as PFGeoPoint).longitude)
                    
                    var popup = newEvent["popup"] as Int
                    var icon = newEvent["icon"] as Int
                    
                    var marker = GMSMarker(position: location)
                    marker.title = name
                    marker.snippet = description
                    marker.icon = self.createMarkerIcon("popup\(popup)", icon: "icon\(icon)")
                    marker.appearAnimation = kGMSMarkerAnimationPop
                    marker.map = self.mapView
                    
                    self.currentMarkers[newEvent.objectId] = marker
                }
                
                self.currentEvents.removeObjectsInArray(eventsToRemove)
                self.currentEvents.addObjectsFromArray(newEvents)
                
                for removeEvent in eventsToRemove {
                 
                    let removeMarker: GMSMarker = self.currentMarkers[removeEvent.objectId]!
                    removeMarker.map = nil
                }
            }
            else
            {
                println("Error: \(error)")
            }
        }

    }
    
    //Reverse a CLLocationCoordinate 2D and return an address as String
    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(coordinate) { response , error in
            
            self.addressLabel.unlock()
            
            if let address = response?.firstResult() {
                let lines = address.lines as [String]
                self.addressLabel.text = join("\n", lines)
                
                UIView.animateWithDuration(0.25) {
                    self.view.layoutIfNeeded()
                }
                
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
    
    //create the marker icon
    func createMarkerIcon(popup: String!, icon: String!) -> UIImage
    {
        var bottomImage = UIImage(named: popup) //background image
        var topImage    = UIImage(named: icon) //foreground image
        
        var newSize = CGSizeMake(50, 60)
        UIGraphicsBeginImageContext(newSize)
        
        bottomImage?.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        topImage?.drawInRect(CGRectMake(0, 1, newSize.width, newSize.width))
        
        var combinedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return combinedImage
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
