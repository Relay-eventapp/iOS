//
//  NewEventTableViewController.swift
//  EventApp
//
//  Created by Mike Zhao on 3/23/15.
//  Copyright (c) 2015 Mike Zhao. All rights reserved.
//

import UIKit

class NewEventTableViewController: UITableViewController {
    
    //cell heights
    var normalCellHeight: CGFloat!
    var newEventTitleCellHeight: CGFloat!
    var eventTypeCellHeight: CGFloat!
    var addCoverPhotoCellHeight: CGFloat!
    var doneButtonCellHeight: CGFloat!
    var expandedCellHeight: CGFloat!

    //Event Name and Description
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    
    //Event Types
    @IBOutlet weak var publicTypeButton: UIButton!
    @IBOutlet weak var privateTypeButton: UIButton!
    @IBOutlet weak var protectedTypeButton: UIButton!
    //0 for public, 1 for private, and 2 for protected
    var eventType:Int = 0
    
    //start time variables
    var startsInfoCellRow = 5
    var startsDatePickerCellRow = 6
    @IBOutlet weak var startsInfoCell: UITableViewCell!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var startsDatePickerCell: UITableViewCell!
    var startsDatePicker: UIDatePicker = UIDatePicker()
    var startsDatePickerSwitch = false
    var startTime = NSDate()
    
    //end time variables
    var endsInfoCellRow = 7
    var endsDatePickerCellRow = 8
    @IBOutlet weak var endsInfoCell: UITableViewCell!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var endsDatePickerCell: UITableViewCell!
    var endsDatePicker: UIDatePicker = UIDatePicker()
    var endsDatePickerSwitch = false
    var endTime = NSDate()
    
    //other variables
    @IBOutlet weak var doneButton: UIButton!
    var newEventLocation:CLLocationCoordinate2D!
    var timeInterval:NSTimeInterval = 3600
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        println("\nNew Event Table View Controller View:")
        
        //set up the event type buttons
        publicTypeButton.addTarget(self, action: "setEventType:", forControlEvents: UIControlEvents.TouchUpInside)
        privateTypeButton.addTarget(self, action: "setEventType:", forControlEvents: UIControlEvents.TouchUpInside)
        protectedTypeButton.addTarget(self, action: "setEventType:", forControlEvents: UIControlEvents.TouchUpInside)
        
        //format start and end time cells
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        
        startTimeLabel.text = formatter.stringFromDate(startTime)
        
        formatter.dateStyle = .NoStyle
        endTime = startTime.dateByAddingTimeInterval(timeInterval)
        endTimeLabel.text = formatter.stringFromDate(endTime)
        
        //set up the cell heights
        normalCellHeight = self.tableView.frame.height/13
        newEventTitleCellHeight = 1.5*self.tableView.frame.height/13
        eventTypeCellHeight = 1.5*self.tableView.frame.height/13
        addCoverPhotoCellHeight = 3.5*self.tableView.frame.height/13
        doneButtonCellHeight = 1.5*self.tableView.frame.height/13
        expandedCellHeight = 220.0
        
        //set up the done button
        doneButton.addTarget(self.revealViewController(), action:Selector("doneButtonPressed:"), forControlEvents: .TouchUpInside)
        doneButton.layer.cornerRadius = 5
        
        //hide extraneous cells
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    //set the event type when an event type button is pressed
    func setEventType(sender: UIButton!)
    {
        switch eventType {
        case publicTypeButton:
            eventType = 0
            println("event type set to public")
        case privateTypeButton:
            eventType = 1
            println("event type set to private")
        case protectedTypeButton:
            eventType = 2
            println("event type set to protected")
        default:
            eventType = 0
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
    
    //function called when the user creates an event
    func createNewEvent(name: String, location: PFGeoPoint, description: String)
    {
        //check if the user has signed in
        if(PFUser.currentUser() != nil)
        {
            //create new event
            var newEvent = PFObject(className: "Events")
            
            //set name and description of event
            newEvent.setObject(name, forKey: "name")
            newEvent.setObject(description, forKey: "description")
            
            //set location of event
            newEvent.setObject(location, forKey: "location")
            
            //set type of event
            newEvent.setObject(eventType, forKey: "type")
            
            //set icon and popup images for event
            newEvent.setObject(Int(arc4random_uniform(11)), forKey: "icon")
            newEvent.setObject(Int(arc4random_uniform(11)), forKey: "popup")
            
            newEvent.saveInBackgroundWithBlock {
                (success: Bool!, error: NSError!) -> Void in
                if success == true {
                    println("Created New Event: \(name)")
                }
                else
                {
                    println(error)
                }
                
            }
        }
        else
        {
            println("User not signed in.")
        }
    }
    
    //if the user taps a certain cell
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.cellForRowAtIndexPath(indexPath)?.selectionStyle = UITableViewCellSelectionStyle.None
        
        //if the user taps the "starts" info cell
        if (indexPath.row == startsInfoCellRow)
        {
            startsDatePickerSwitch = !startsDatePickerSwitch
            if(startsDatePickerSwitch == true)
            {
                expandStartsDatePickerCell()
                hideEndsDatePickerCell()
                endsDatePickerSwitch = false
            }
            else
            {
                hideStartsDatePickerCell()
            }
            tableView.beginUpdates()
            tableView.endUpdates()
        }
        
        //if the user taps the "starts" info cell
        if (indexPath.row == endsInfoCellRow)
        {
            endsDatePickerSwitch = !endsDatePickerSwitch
            if(endsDatePickerSwitch == true)
            {
                expandEndsDatePickerCell()
                hideStartsDatePickerCell()
                startsDatePickerSwitch = false
            }
            else
            {
                hideEndsDatePickerCell()
            }
            tableView.beginUpdates()
            tableView.endUpdates()
        }
        
    }
    
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
        case startsDatePickerCellRow:
            if (startsDatePickerSwitch == true)
            {
                return expandedCellHeight
            }
            return 0
        case endsDatePickerCellRow:
            if (endsDatePickerSwitch == true)
            {
                return expandedCellHeight
            }
            return 0
        default:
            return normalCellHeight
        }
    }
    
    func expandStartsDatePickerCell()
    {
        println("showing Starts Date Picker")
        startsDatePicker.frame = startsDatePickerCell.frame
        startsDatePicker.datePickerMode = UIDatePickerMode.DateAndTime
        startsDatePicker.addTarget(self, action: Selector("handleStartsDatePickerCell:"), forControlEvents: UIControlEvents.ValueChanged)
        self.view.addSubview(startsDatePicker)
    }
    
    func handleStartsDatePickerCell(sender: UIDatePicker) {
        startTime = sender.date
        updateTimeInterval()
    }
    
    func hideStartsDatePickerCell()
    {
        println("hiding Starts Date Picker")
        startsDatePicker.removeFromSuperview()
    }
    
    func expandEndsDatePickerCell()
    {
        println("showing Ends Date Picker")
        endsDatePicker.frame = endsDatePickerCell.frame
        endsDatePicker.datePickerMode = UIDatePickerMode.DateAndTime
        endsDatePicker.addTarget(self, action: Selector("handleEndsDatePickerCell:"), forControlEvents: UIControlEvents.ValueChanged)
        self.view.addSubview(endsDatePicker)
    }
    
    func handleEndsDatePickerCell(sender: UIDatePicker) {
        endTime = sender.date
        updateTimeInterval()
    }
    
    func hideEndsDatePickerCell()
    {
        println("hiding Ends Date Picker")
        endsDatePicker.removeFromSuperview()
    }
    
    func updateTimeInterval()
    {
        var timeFormatter = NSDateFormatter()
        timeFormatter.dateStyle = .MediumStyle
        timeFormatter.timeStyle = .ShortStyle
        startTimeLabel.text = timeFormatter.stringFromDate(startTime)
        endTimeLabel.text = timeFormatter.stringFromDate(endTime)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
