//
//  NewEventTableViewController.swift
//  EventApp
//
//  Created by Mike Zhao on 3/23/15.
//  Copyright (c) 2015 Mike Zhao. All rights reserved.
//

import UIKit

class CreateEventTableViewController: UITableViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate {
    
    var newEventLocation:CLLocationCoordinate2D!
    var cellHeight: NSMutableArray! = NSMutableArray()
    var h: CGFloat!
    
    //Add Cover Photo
    var addCoverPhotoCellRow = 1
    @IBOutlet weak var coverPhoto: UIImageView!
    var imagePicked: Bool!
    
    //Event Name and Description
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    
    //Event Types
    var access: Int! //0 for public, 1 for private, and 2 for protected
    @IBOutlet weak var publicTypeButton: UIButton!
    @IBOutlet weak var privateTypeButton: UIButton!
    @IBOutlet weak var protectedTypeButton: UIButton!
    
    var datePickerSwitch: Int! = 0 //0 for both collapsed, 1 for start date picker expanded, 2 for end date picker expanded
    var timeInterval: NSTimeInterval!
    
    //start time variables
    var startDateCellRow = 5
    @IBOutlet weak var startDateCell: UITableViewCell!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    var startTime: NSDate!
    
    //end time variables
    var endDateCellRow = 6
    @IBOutlet weak var endDateCell: UITableViewCell!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    var endTime: NSDate!

    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //set up text fields
        self.nameField.delegate = self
        self.descriptionField.delegate = self
        
        //round the cover photo
        coverPhoto.layer.borderColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1).CGColor
        coverPhoto.layer.cornerRadius = (coverPhoto.frame.height)/2
        coverPhoto.layer.borderWidth = 3.0
        coverPhoto.clipsToBounds = true
        imagePicked = false
        
        //set default event type to be public
        access = 0
        publicTypeButton.backgroundColor = UIColor.lightGrayColor()
        
        //format start and end time cells
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        
        //set up the default start and end time
        startTime = NSDate()
        timeInterval = 3600
        startDatePicker.hidden = true
        endDatePicker.hidden = true
        updateTimeInterval()
        
        //set up cell heights
        h = self.view.frame.height/13
        cellHeight.insertObject(1.5*h, atIndex: 0)
        cellHeight.insertObject(3.5*h, atIndex: 1)
        cellHeight.insertObject(h, atIndex: 2)
        cellHeight.insertObject(h, atIndex: 3)
        cellHeight.insertObject(1.5*h, atIndex: 4)
        cellHeight.insertObject(h, atIndex: 5)
        cellHeight.insertObject(h, atIndex: 6)
        cellHeight.insertObject(h, atIndex: 7)
        cellHeight.insertObject(1.5*h, atIndex: 8)
        
        //set up the type buttons
        publicTypeButton.layer.cornerRadius = publicTypeButton.frame.width/2
        privateTypeButton.layer.cornerRadius = privateTypeButton.frame.width/2
        protectedTypeButton.layer.cornerRadius = protectedTypeButton.frame.width/2
        
        //set up the done button
        //doneButton.addTarget(self.revealViewController(), action: "doneButtonPressed:", forControlEvents: .TouchUpInside)
        doneButton.layer.cornerRadius = 5
        
        //hide extraneous cells
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func DismissKeyboard(){
        tableView.endEditing(true)
    }
    
    //checks if the user has edited a text field
    func textFieldDidEndEditing(textField: UITextField) {
        
        if textField == nameField && timeInterval > 0
        {
            doneButtonSwitch(nameField.text)
        }
    }
    
    //set the event type when an event type button is pressed
    @IBAction func publicTypeButton(sender: UIButton) {
        setAccess(publicTypeButton)
    }
    
    @IBAction func privateTypeButton(sender: UIButton) {
        setAccess(privateTypeButton)
    }
    
    @IBAction func protectedTypeButton(sender: UIButton) {
        setAccess(protectedTypeButton)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        coverPhoto.image = image
        imagePicked = true
    }
    
    //checks if the user taps a cell
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.row {
        case addCoverPhotoCellRow:
            
            var imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            //imagePicker.sourceType = UIImagePickerControllerSourceType.Camera <- to get access to camera
            imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
            
        case startDateCellRow:
            
            switch datePickerSwitch {
            case 1:
                hideStartDatePickerCell()
                datePickerSwitch = 0
            case 2:
                expandStartDatePickerCell()
                hideEndDatePickerCell()
                datePickerSwitch = 1
            default:
                expandStartDatePickerCell()
                datePickerSwitch = 1
            }
            
        case endDateCellRow:
            
            switch datePickerSwitch {
            case 2:
                hideEndDatePickerCell()
                datePickerSwitch = 0
            case 1:
                expandEndDatePickerCell()
                hideStartDatePickerCell()
                datePickerSwitch = 2
            default:
                expandEndDatePickerCell()
                datePickerSwitch = 2
            }
        default:
            println("do nothing")
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    //sets the height for each row in the table view
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return cellHeight.objectAtIndex(indexPath.row) as! CGFloat
    }
    
    //start date picker functions
    func expandStartDatePickerCell()
    {
        cellHeight[startDateCellRow] = cellHeight[startDateCellRow] as!CGFloat + startDatePicker.frame.height
        
        startDatePicker.datePickerMode = UIDatePickerMode.DateAndTime
        startDatePicker.addTarget(self, action: "handleStartDatePickerCell:", forControlEvents: .ValueChanged)
        
        startDatePicker.hidden = false
        startDatePicker.alpha = 0
        UIView.animateWithDuration(0.2, animations: {
            self.startDatePicker.alpha = 1
            }, completion: {
                (value: Bool) in
                var indexPath = NSIndexPath(forRow: self.startDateCellRow, inSection: 0)
                self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
        })
    }
    
    func handleStartDatePickerCell(sender: UIDatePicker) {
        startTime = sender.date
        updateTimeInterval()
    }
    
    func hideStartDatePickerCell()
    {
        cellHeight[startDateCellRow] = cellHeight[startDateCellRow] as! CGFloat - startDatePicker.frame.height
        UIView.animateWithDuration(0.2, animations: {
             self.startDatePicker.alpha = 0
            }, completion: {
                (value: Bool) in
                self.startDatePicker.hidden = true
        })
    }
    
    //End date picker functions
    func expandEndDatePickerCell()
    {
        cellHeight[endDateCellRow] = cellHeight[endDateCellRow] as! CGFloat + endDatePicker.frame.height
        
        endDatePicker.datePickerMode = UIDatePickerMode.DateAndTime
        endDatePicker.addTarget(self, action: "handleEndDatePickerCell:", forControlEvents: .ValueChanged)
        
        endDatePicker.hidden = false
        endDatePicker.alpha = 0
        UIView.animateWithDuration(0.2, animations: {
            self.endDatePicker.alpha = 1
            }, completion: {
                (value: Bool) in
                var indexPath = NSIndexPath(forRow: self.endDateCellRow, inSection: 0)
                self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
        })
    }
    
    func handleEndDatePickerCell(sender: UIDatePicker) {
        endTime = sender.date
        timeInterval = endTime.timeIntervalSinceDate(startTime)
        updateTimeInterval()
    }
    
    func hideEndDatePickerCell()
    {
        cellHeight[endDateCellRow] = cellHeight[endDateCellRow] as! CGFloat - endDatePicker.frame.height
        UIView.animateWithDuration(0.25, animations: {
            self.endDatePicker.alpha = 0
            }, completion: {
                (value: Bool) in
                self.endDatePicker.hidden = true
        })
    }
    
    //update the start and end time
    func updateTimeInterval()
    {
        var timeFormatter = NSDateFormatter()
        timeFormatter.dateStyle = .MediumStyle
        timeFormatter.timeStyle = .ShortStyle
        startTimeLabel.text = timeFormatter.stringFromDate(startTime)
        endTime = startTime.dateByAddingTimeInterval(timeInterval)
        endTimeLabel.text = timeFormatter.stringFromDate(endTime)
        startDatePicker.date = startTime
        endDatePicker.date = endTime
        
        if(timeInterval <= 0)
        {
            endTimeLabel.textColor = UIColor(red: 189/255.0, green: 91/255.0, blue: 89/255.0, alpha: 1.0)
            doneButton.setTitle("Invalid Time", forState: UIControlState.Normal)
            doneButton.backgroundColor = UIColor(red: 189/255.0, green: 91/255.0, blue: 89/255.0, alpha: 1.0)
        }
        else
        {
            endTimeLabel.textColor = UIColor(red: 85/255.0, green: 85/255.0, blue: 85/255.0, alpha: 1.0)
            doneButtonSwitch(nameField.text)
        }
    }
    
    func doneButtonSwitch(text: String)
    {
        switch text {
        case "":
            UIView.animateWithDuration(0.1) {self.doneButton.backgroundColor = UIColor(red: 175/255.0, green: 175/255.0, blue: 175/255.0, alpha: 1.0)}
        default:
            doneButton.setTitle("Create", forState: UIControlState.Normal)
            UIView.animateWithDuration(0.1) {self.doneButton.backgroundColor = UIColor(red: 53/255.0, green: 92/255.0, blue: 125/255.0, alpha: 1.0)}
        }
    }
    
    //sets the event type
    func setAccess(sender: UIButton)
    {
        UIView.animateWithDuration(0.05) {
        self.publicTypeButton.backgroundColor = UIColor.clearColor()
        self.privateTypeButton.backgroundColor = UIColor.clearColor()
        self.protectedTypeButton.backgroundColor = UIColor.clearColor()
        }
        
        switch sender {
        case privateTypeButton:
            access = 1
            UIView.animateWithDuration(0.1) {self.privateTypeButton.backgroundColor = UIColor.lightGrayColor()}
        
        case protectedTypeButton:
            access = 2
            UIView.animateWithDuration(0.1) {self.protectedTypeButton.backgroundColor = UIColor.lightGrayColor()}
        default:
            access = 0
            UIView.animateWithDuration(0.1 ) {self.publicTypeButton.backgroundColor = UIColor.lightGrayColor()}
        }
    }
    
    //create an event when the done button is pressed
    func doneButtonPressed(sender: UIButton)
    {
        if(nameField.text != "" && timeInterval > 0)
        {
            println("Calling Create New Event.")
            var location = PFGeoPoint(latitude: newEventLocation.latitude, longitude: newEventLocation.longitude)
            createNewEvent(nameField.text, location: location, description: descriptionField.text)
            performSegueWithIdentifier("exitView", sender: self)
        }
    }
    
    //creates the event and sends it to the Parse backend
    func createNewEvent(name: String, location: PFGeoPoint, description: String)
    {
        //check if the user has signed in
        if(PFUser.currentUser() != nil)
        {
            //create new event
            var newEvent = PFObject(className: "Events")

            //first level
            var randomPriority = Int(arc4random_uniform(10))
            var randomCategory = Int(arc4random_uniform(14))
            var randomSubCategory = Int(arc4random_uniform(3))
            
            newEvent.setObject(location, forKey: "location")
            newEvent.setObject(randomPriority, forKey: "priority")
            newEvent.setObject(access, forKey: "access")
            newEvent.setObject(randomCategory, forKey: "category")
            newEvent.setObject(randomSubCategory, forKey: "subCategory")
            newEvent.setObject(startTime, forKey: "startTime")
            newEvent.setObject(endTime, forKey: "endTime")
            
            //second level
            newEvent.setObject(name, forKey: "name")
            if(imagePicked == true)
            {
                let imageData = UIImagePNGRepresentation(coverPhoto.image)
                let imageFile = PFFile(name:"image.png", data:imageData)
                newEvent.setObject(imageFile, forKey: "photo")
            }

            //third level
            var user = PFUser.currentUser()!.objectId!
            newEvent.setObject([user], forKey: "attendees")
            newEvent.setObject(description, forKey: "description")
            newEvent.setObject(PFUser.currentUser()!.objectId!, forKey: "creator")
            
            newEvent.saveInBackgroundWithBlock({ (succeeded, error) -> Void in
                if error == nil {
                    println("created event: \(newEvent.objectId)")
                }
                else
                {
                    println(error)
                }
            })
        }
        else
        {
            println("User not signed in.")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
