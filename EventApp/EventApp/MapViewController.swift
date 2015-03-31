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
    
    //Load the View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //settings for the map view
        mapView.settings.consumesGesturesInView = true
        mapView.mapType = kGMSTypeNormal
        mapView.delegate = self
        
        //TODO: set the map frame to be 20 px lower so no space is wasted
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        //initialize the navigation and address labels
        navigationLabel.layer.masksToBounds = true
        navigationLabel.layer.cornerRadius = 5
        
        //initialize the menu button
        menuButton.setImage(menuButtonImage, forState: .Normal)
        menuButton.frame = CGRectMake(8, 16+1, 42, 42)
        self.view.addSubview(menuButton)
        
        //initialize the filter events button
        filterEventsButton.setImage(filterEventsButtonImage, forState: .Normal)
        filterEventsButton.frame = CGRectMake(self.view.frame.width - 8 - 42, 16, 42, 42)
        self.view.addSubview(filterEventsButton)
        
        //set up the menu button for transitions
        if self.revealViewController() != nil {
            
            menuButton.addTarget(self.revealViewController(), action:Selector("revealToggle:"), forControlEvents: .TouchUpInside)
         
            self.revealViewController().rearViewRevealWidth = self.view.frame.width
        }
    }
    
    override func viewDidAppear(animated: Bool) {
    
        //TODO: find a way to implement this if statement
        
        //if status == .AuthorizedWhenInUse {
        
            println("\nMap View:")
        
            locationManager.startUpdatingLocation()
        
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
        println("updateEventsInView")
        let view = PFGeoPoint(latitude: position.target.latitude, longitude: position.target.longitude)
        var query = PFQuery(className:"Events")
        query.whereKey("location", nearGeoPoint: view, withinKilometers: 10)
        query.limit = 10
        let nearbyEvents = query.findObjects()
        
        for nearbyEvent in nearbyEvents {
            
            var name = nearbyEvent["name"] as String
            var location = nearbyEvent["location"] as PFGeoPoint
            var description = nearbyEvent["description"] as String
            var popup = nearbyEvent["popup"] as Int
            var icon = nearbyEvent["icon"] as Int
            
            var markerLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            var marker = GMSMarker(position: markerLocation)
            
            marker.icon = createMarkerIcon("popup\(popup)", icon: "icon\(icon)")
            marker.title = name
            marker.snippet = description
            marker.map = mapView
            
            //println("Nearby Event: <\(name)> at \(location)")
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
}
