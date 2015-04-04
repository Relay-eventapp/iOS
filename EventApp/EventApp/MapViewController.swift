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

    var tappedLocation:CLLocationCoordinate2D!
    var didChangeCameraPosition:Bool!
    
    var localArr: NSMutableArray!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    //Load the View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //settings for the map view
        mapView.settings.consumesGesturesInView = true
        mapView.mapType = kGMSTypeNormal
        mapView.delegate = self
        
        //initialized the location manager
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        //initialize the menu button
        menuButton.setImage(menuButtonImage, forState: .Normal)
        menuButton.frame = CGRectMake(8, 16+1, 42, 42)
        self.view.addSubview(menuButton)
        
        //initialize the filter events button
        filterEventsButton.setImage(filterEventsButtonImage, forState: .Normal)
        filterEventsButton.frame = CGRectMake(self.view.frame.width - 8 - 42, 16, 42, 42)
        self.view.addSubview(filterEventsButton)
        
        //TODO: connect with other view controllers
        if self.revealViewController() != nil {
            
            menuButton.addTarget(self.revealViewController(), action:Selector("revealToggle:"), forControlEvents: .TouchUpInside)
            self.revealViewController().rearViewRevealWidth = 0.85*self.view.frame.width
        }
    }
    
    override func viewDidAppear(animated: Bool) {
    
        //TODO: find a way to implement this if statement
        
        //if status == .AuthorizedWhenInUse {
        
            println("\nMap View:")
        
            //locationManager.startUpdatingLocation()
        
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
        
            let labelHeight = self.addressLabel.frame.height
            self.mapView.padding = UIEdgeInsets(top: self.topLayoutGuide.length, left: 0, bottom: labelHeight, right: 0)
        
            updateEventsInView(mapView.camera)
        //}
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "mapCreateNewEvent"
        {
            println("Performing segue to New Event Table View.")
            let vc = segue.destinationViewController as NewEventTableViewController
            vc.newEventLocation = tappedLocation
        }
    }
    
    @IBAction func unwindToMapViewController(sender: UIStoryboardSegue)
    {
        println("Unwinding to Map View.")
    }
    
    func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D)
    {
        println("User tapped screen.")
        tappedLocation = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)
        self.performSegueWithIdentifier("mapCreateNewEvent", sender: self)
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
        var query = PFQuery(className: "Events")
        
        if(localArr.count == 0)
        {
            query.cachePolicy = PFCachePolicy.CacheThenNetwork
        }
        
        let view = PFGeoPoint(latitude: position.target.latitude, longitude: position.target.longitude)
        query.whereKey("location", nearGeoPoint: view, withinKilometers: 10)
        query.orderByDescending("priority")
        query.limit = 20
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                
                //look for new or updated events
                var newEvents = NSMutableArray(capacity: 20)
                var allNewEvents = NSMutableArray(capacity: objects.count)
                for object in objects
                {
                    
                }
                
            } else {
                // Log details of the failure
                println("Error: \(error) \(error.userInfo!)")
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
