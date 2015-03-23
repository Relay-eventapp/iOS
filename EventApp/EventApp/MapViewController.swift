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
    //let menuButtonImage = UIImage(named: "bullets.png") as UIImage!
    let filterEventsButton = UIButton()
    //let filterEventsButtonImage = UIImage(named: "filter.png") as UIImage!
    
    //create the map
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var addressLabel: UILabel!
    
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
        
        //initialize the menu button
        //menuButton.setImage(menuButtonImage, forState: .Normal)
        menuButton.frame = CGRectMake(10, 30, 50, 50)
        menuButton.backgroundColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 0.9)
        menuButton.layer.cornerRadius = 25
        self.view.addSubview(menuButton)
        
        //initialize the filter events button
        //filterEventsButton.setImage(filterEventsButtonImage, forState: .Normal)
        filterEventsButton.frame = CGRectMake(self.view.frame.width - 60, 30, 50, 50)
        filterEventsButton.backgroundColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 0.9)
        filterEventsButton.layer.cornerRadius = 25
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
        
            locationManager.startUpdatingLocation()
        
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
        
            let labelHeight = self.addressLabel.frame.height
            self.mapView.padding = UIEdgeInsets(top: self.topLayoutGuide.length, left: 0, bottom: labelHeight, right: 0)
        //}
    }
    
    func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D)
    {
        println("You created an event at (\(coordinate.latitude), \(coordinate.longitude))")
        var position = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)
        
        var marker = GMSMarker(position: position)
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.infoWindowAnchor = CGPoint(x: 0.5, y: 3)
        marker.map = mapView
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("createNewEvent") as NewEventTableViewController
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func mapView(mapView: GMSMapView!, markerInfoWindow marker: GMSMarker!) -> UIView! {
        
        var customInfoWindow = NSBundle.mainBundle().loadNibNamed("InfoWindow", owner: self, options: nil)[0] as CustomInfoWindow
        
        //customInfoWindow.eventName.text = "New Event"
        return customInfoWindow
    }
    
    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
        reverseGeocodeCoordinate(position.target)
    }
    
    func mapView(mapView: GMSMapView!, willMove gesture: Bool) {
        addressLabel.lock()
    }
    
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
            
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 16, bearing: 0, viewingAngle: 0)

            locationManager.stopUpdatingLocation()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
