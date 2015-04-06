//
//  NewEventTableViewController.swift
//  EventApp
//
//  Created by Mike Zhao on 3/23/15.
//  Copyright (c) 2015 Mike Zhao. All rights reserved.
//

import UIKit

class NewEventTableViewController: UITableViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    //cell heights
    var normalCellHeight: CGFloat!
    var newEventTitleCellHeight: CGFloat!
    var eventTypeCellHeight: CGFloat!
    var addCoverPhotoCellHeight: CGFloat!
    var doneButtonCellHeight: CGFloat!
    var expandedCellHeight: CGFloat!
    
    //Add Cover Photo
    var addCoverPhotoCellRow = 1
    @IBOutlet weak var coverPhoto: UIImageView!
    var imagePicked: Bool!
    
    //Event Name and Description
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    
    //Event Types
    @IBOutlet weak var publicTypeButton: UIButton!
    @IBOutlet weak var privateTypeButton: UIButton!
    @IBOutlet weak var protectedTypeButton: UIButton!
    //0 for public, 1 for private, and 2 for protected
    var eventType: Int!
    
    //start time variables
    var startsInfoCellRow = 5
    var startsDatePickerCellRow = 6
    //@IBOutlet weak var startsInfoCell: UITableViewCell!
    //@IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var startsDatePickerCell: UITableViewCell!
    var startsDatePicker: UIDatePicker = UIDatePicker()
    var startsDatePickerSwitch = false
    var startTime: NSDate!
    
    //end time variables
    var endsInfoCellRow = 7
    var endsDatePickerCellRow = 8
    @IBOutlet weak var endsInfoCell: UITableViewCell!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var endsDatePickerCell: UITableViewCell!
    var endsDatePicker: UIDatePicker = UIDatePicker()
    var endsDatePickerSwitch = false
    var endTime: NSDate!
    
    //other variables
    @IBOutlet weak var doneButton: UIButton!
    var newEventLocation:CLLocationCoordinate2D!
    var timeInterval:NSTimeInterval = 3600
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        println("\nNew Event Table View Controller View:")
        
        self.nameField.delegate = self
        self.descriptionField.delegate = self
        imagePicked = false
        
        //round the cover photo image view
        coverPhoto.layer.cornerRadius = coverPhoto.frame.height/2
        coverPhoto.clipsToBounds = true
        coverPhoto.layer.borderWidth = 3.0
        coverPhoto.layer.borderColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1).CGColor
        
        //set default event type to be public
        eventType = 0
        publicTypeButton.backgroundColor = UIColor.lightGrayColor()
        
        //format start and end time cells
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        
        startTime = NSDate()
        endTime = startTime.dateByAddingTimeInterval(timeInterval)
        //startTimeLabel.text = formatter.stringFromDate(startTime)
        endTimeLabel.text = formatter.stringFromDate(endTime)
        
        //set up the cell heights
        normalCellHeight = self.tableView.frame.height/13
        newEventTitleCellHeight = 1.5*self.tableView.frame.height/13
        eventTypeCellHeight = 1.5*self.tableView.frame.height/13
        addCoverPhotoCellHeight = 3.5*self.tableView.frame.height/13
        doneButtonCellHeight = 1.5*self.tableView.frame.height/13
        expandedCellHeight = 220.0
        
        //set up the type buttons
        publicTypeButton.layer.cornerRadius = 21
        privateTypeButton.layer.cornerRadius = 21
        protectedTypeButton.layer.cornerRadius = 21
        
        //set up the done button
        doneButton.addTarget(self.revealViewController(), action: "doneButtonPressed:", forControlEvents: .TouchUpInside)
        doneButton.layer.cornerRadius = 5
        
        //hide extraneous cells
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        tableView.endEditing(true)
    }
    
    //checks if the user has edited a text field
    func textFieldDidEndEditing(textField: UITextField) {
        
        if textField == nameField
        {
            if(nameField.text != "")
            {
                doneButton.setTitle("Done", forState: UIControlState.Normal)
            }
            else
            {
                doneButton.setTitle("Cancel", forState: UIControlState.Normal)
            }
        }
    }
    
    //set the event type when an event type button is pressed
    @IBAction func publicTypeButton(sender: UIButton) {
        setEventType(publicTypeButton)
    }
    
    @IBAction func privateTypeButton(sender: UIButton) {
        setEventType(privateTypeButton)
    }
    
    @IBAction func protectedTypeButton(sender: UIButton) {
        setEventType(protectedTypeButton)
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        println("cover photo selected")
        self.dismissViewControllerAnimated(true, completion: nil)
        coverPhoto.image = image
        imagePicked = true
    }
    //checks if the user taps a cell
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //if the user taps the "add cover photo" cell
        if(indexPath.row == addCoverPhotoCellRow)
        {
            println("adding cover photo")
            var imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            //imagePicker.sourceType = UIImagePickerControllerSourceType.Camera <- to get access to camera
            imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
            
        }
        
    }
    
    //sets the height for each row in the table view
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.row {
        case 0:
            return newEventTitleCellHeight
        case 1:
            return addCoverPhotoCellHeight
        case 4:
            return eventTypeCellHeight
        case 10:
            return doneButtonCellHeight
        default:
            return normalCellHeight
        }
    }
    

    //update the start and end time
    func updateTimeInterval()
    {
        var timeFormatter = NSDateFormatter()
        timeFormatter.dateStyle = .MediumStyle
        timeFormatter.timeStyle = .ShortStyle
        //startTimeLabel.text = timeFormatter.stringFromDate(startTime)
        endTimeLabel.text = timeFormatter.stringFromDate(endTime)
    }
    
    //sets the event type
    func setEventType(sender: UIButton)
    {
        publicTypeButton.backgroundColor = UIColor.clearColor()
        privateTypeButton.backgroundColor = UIColor.clearColor()
        protectedTypeButton.backgroundColor = UIColor.clearColor()
        
        switch sender {
        case privateTypeButton:
            println("private")
            eventType = 1
            privateTypeButton.backgroundColor = UIColor.lightGrayColor()
        case protectedTypeButton:
            println("protected")
            eventType = 2
            protectedTypeButton.backgroundColor = UIColor.lightGrayColor()
        default:
            eventType = 0
            publicTypeButton.backgroundColor = UIColor.lightGrayColor()
            println("public")
        }
    }
    
    //create an event when the done button is pressed
    func doneButtonPressed(sender: UIButton)
    {
        if(nameField.text != "")
        {
            println("Calling Create New Event.")
            var location = PFGeoPoint(latitude: newEventLocation.latitude, longitude: newEventLocation.longitude)
            createNewEvent(nameField.text, location: location, description: descriptionField.text)
        }
        else
        {
            println("No information provided. Exiting View.")
        }
    }
    
    //creates the event and sends it to the Parse backend
    func createNewEvent(name: String, location: PFGeoPoint, description: String)
    {
        //create new event
        var newEvent = PFObject(className: "Events")
        
        //set cover photo of event
        if(imagePicked == true)
        {
            let imageData = UIImagePNGRepresentation(coverPhoto.image)
            let imageFile = PFFile(name:"image.png", data:imageData)
            newEvent.setObject(imageFile, forKey: "coverPhoto")
        }
        
        //set name and description of event
        newEvent.setObject(name, forKey: "name")
        newEvent.setObject(description, forKey: "description")
        
        //set priority of event
        newEvent.setObject(Int(arc4random_uniform(100))+1, forKey: "priority")
        //save the user's id as the creator of the event
        newEvent.setObject(PFUser.currentUser().objectId, forKey: "creator")
        
        //set location of event
        newEvent.setObject(location, forKey: "location")
        
        //set type of event
        newEvent.setObject(eventType, forKey: "type")
        
        //set start and end time of event
        //newEvent.setObject(startTimeLabel.text, forKey: "startTime")
        newEvent.setObject(endTimeLabel.text, forKey: "endTime")
        
        //set icon and popup images for event
        newEvent.setObject(Int(arc4random_uniform(9)), forKey: "icon")
        newEvent.setObject(Int(arc4random_uniform(11)), forKey: "popup")
        
        newEvent.saveEventually {(success: Bool!, error: NSError!) -> Void in
            
            if success == true {
                println("created event: \(newEvent.objectId)")
            }
            else
            {
                println(error)
            }
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
