//
//  CreateEventViewController.swift
//  EventApp
//
//  Created by Mike Zhao on 4/23/15.
//  Copyright (c) 2015 Mike Zhao. All rights reserved.
//

import UIKit

class CreateEventViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate {
    
    //UI Elements
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var selectPhotoButton: UIButton!
    
    @IBOutlet weak var nameField: InsetTextField!
    @IBOutlet weak var descriptionField: InsetTextField!
    var accessButton: DDExpandableButton!
    var backButton = VBFPopFlatButton()
    
    @IBOutlet weak var inviteesCollectionView: UICollectionView!
    @IBOutlet weak var locationField: InsetTextField!
    @IBOutlet weak var startTimeField: InsetTextField!
    @IBOutlet weak var endTimeField: InsetTextField!
    
    var startDatePicker:UIDatePicker = UIDatePicker()
    var endDatePicker:UIDatePicker = UIDatePicker()
    
    @IBOutlet weak var createButton: UIButton!
    
    //variables
    var newEventLocation:CLLocationCoordinate2D!
    var imagePicked = false
    
    var dateFormatter = NSDateFormatter()
    var startTime = NSDate()
    var timeInterval: NSTimeInterval = 3600
    var endTime = NSDate()
    
    var unselectedColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.65)
    var selectedColor = UIColor(red: 221/255.0, green: 70/255.0, blue: 80/255.0, alpha: 0.9)
    var hasInfoColor = UIColor(red: 127.5/255.0, green: 127.5/255.0, blue: 127.5/255.0, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectPhotoButton.addTarget(self, action: "selectPhoto:", forControlEvents: .TouchUpInside)
        
        backButton = VBFPopFlatButton(frame: CGRectMake(16,28,selectPhotoButton.frame.width,selectPhotoButton.frame.height), buttonType: .buttonBackType, buttonStyle: .buttonPlainStyle, animateToInitialState: false)
        backButton.lineThickness = 2
        backButton.tintColor = UIColor.whiteColor()
        backButton.addTarget(self, action: "dismissView:", forControlEvents: .TouchUpInside)
        self.view.addSubview(backButton)
        
        accessButton = DDExpandableButton(point: CGPointMake(16, endTimeField.frame.maxY+8), leftTitle: "Access:", buttons: ["Public", "Private", "Protected"])
        accessButton.labelFont = UIFont(name: "HelveticaNeue-Light", size: 20)
        accessButton.borderColor = UIColor.clearColor()
        accessButton.textColor = UIColor.whiteColor()
        accessButton.verticalPadding = 9
        accessButton.horizontalPadding = 8
        accessButton.updateDisplay()
        self.view.addSubview(accessButton)
        
        startDatePicker.datePickerMode = .DateAndTime
        endDatePicker.datePickerMode = .DateAndTime
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle
        
        nameField.attributedPlaceholder = NSAttributedString(string:"Name",
            attributes:[NSForegroundColorAttributeName: unselectedColor])
        nameField.addTarget(self, action: "contentsDidChange:", forControlEvents: .EditingChanged)
        nameField.layer.cornerRadius = nameField.frame.height/2
        
        descriptionField.attributedPlaceholder = NSAttributedString(string:"Description",
            attributes:[NSForegroundColorAttributeName: unselectedColor])
        descriptionField.addTarget(self, action: "contentsDidChange:", forControlEvents: .EditingChanged)
        descriptionField.layer.cornerRadius = descriptionField.frame.height/2
        
        locationField.attributedPlaceholder = NSAttributedString(string:"Location",
            attributes:[NSForegroundColorAttributeName: unselectedColor])
        locationField.addTarget(self, action: "contentsDidChange:", forControlEvents: .EditingChanged)
        locationField.layer.cornerRadius = locationField.frame.height/2
        
        startTimeField.attributedPlaceholder = NSAttributedString(string:"Start Time",
            attributes:[NSForegroundColorAttributeName: unselectedColor])
        startTimeField.addTarget(self, action: "contentsDidChange:", forControlEvents: .EditingChanged)
        startTimeField.layer.cornerRadius = startTimeField.frame.height/2
        
        endTimeField.attributedPlaceholder = NSAttributedString(string:"End Time",
            attributes:[NSForegroundColorAttributeName: unselectedColor])
        endTimeField.addTarget(self, action: "contentsDidChange:", forControlEvents: .EditingChanged)
        endTimeField.layer.cornerRadius = endTimeField.frame.height/2
        
        createButton.addTarget(self, action: "createButtonPressed:", forControlEvents: .TouchUpInside)
        createButton.layer.cornerRadius = 8
        
        nameField.delegate = self
        descriptionField.delegate = self
        locationField.delegate = self
        startTimeField.delegate = self
        endTimeField.delegate = self
        
        updateTimeInterval()
        if(newEventLocation != nil)
        {
            let geocoder = GMSGeocoder()
            geocoder.reverseGeocodeCoordinate(newEventLocation) { response , error in
                if let address = response?.firstResult() {

                    let lines = address.lines as! [String]
                    self.locationField.text = join(", ",lines)
                }
            }
            
            UIView.animateWithDuration(0.25, animations: {
                self.locationField.backgroundColor = self.hasInfoColor
            })
        }
    }

    func selectPhoto(sender: UIButton)
    {
        var imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.allowsEditing = true
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func dismissView(sender: UIButton)
    {
        performSegueWithIdentifier("exitView", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        backgroundImage.alpha = 0
        backgroundImage.image = image
        UIView.animateWithDuration(1.0, animations: {
            self.backgroundImage.alpha = 0.75
        })
        imagePicked = true
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell: ProfileCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("profileCell", forIndexPath: indexPath) as! ProfileCollectionViewCell
        cell.nameLabel.text = "person\(indexPath.row)"
        cell.nameLabel.textColor = UIColor.whiteColor()
        
        cell.profilePicture.image = UIImage(named: "face\(indexPath.row)")
        cell.profilePicture.layer.cornerRadius = cell.profilePicture.frame.width/2
        cell.profilePicture.clipsToBounds = true
        cell.profilePicture.layer.borderWidth = 3.0
        if(cell.invited == true)
        {
            UIView.animateWithDuration(0.5, animations: {
                cell.profilePicture.layer.borderColor = self.selectedColor.CGColor
                cell.nameLabel.textColor = self.selectedColor
            })
        }
        else
        {
            UIView.animateWithDuration(0.5, animations: {
                cell.profilePicture.layer.borderColor = self.unselectedColor.CGColor
                cell.nameLabel.textColor = self.unselectedColor
            })
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ProfileCollectionViewCell
        
        if(cell.invited == false)
        {
            UIView.animateWithDuration(0.5, animations: {
                cell.profilePicture.layer.borderColor = self.selectedColor.CGColor
                cell.nameLabel.textColor = self.selectedColor
            })
            cell.invited = true
        }
        else
        {
            UIView.animateWithDuration(0.5, animations: {
                cell.profilePicture.layer.borderColor = self.unselectedColor.CGColor
                cell.nameLabel.textColor = self.unselectedColor
            })
            cell.invited = false
        }
    }
    
    func updateTimeInterval()
    {
        if(startTimeField.backgroundColor == nil)
        {
            UIView.animateWithDuration(0.25, animations: { self.startTimeField.backgroundColor = self.hasInfoColor })
        }
        
        if(endTimeField.backgroundColor == nil)
        {
            UIView.animateWithDuration(0.25, animations: { self.endTimeField.backgroundColor = self.hasInfoColor })
        }
        
        endTime = startTime.dateByAddingTimeInterval(timeInterval)
        startTimeField.text = dateFormatter.stringFromDate(startTime)
        endTimeField.text = dateFormatter.stringFromDate(endTime)
        
        //check if the time is invalid
        if(timeInterval <= 0)
        {
            endTimeField.textColor = UIColor(red: 221/255.0, green: 70/255.0, blue: 80/255.0, alpha: 1.0)
            createButton.setTitle("Invalid Time", forState: UIControlState.Normal)
        }
        else
        {
            endTimeField.textColor = UIColor.whiteColor()
            createButton.setTitle("Create", forState: UIControlState.Normal)
        }
        
    }
    
    func createButtonPressed(sender: UIButton)
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
            var randomPriority = Int(arc4random_uniform(6))
            var randomCategory = Int(arc4random_uniform(14))
            var randomSubCategory = Int(arc4random_uniform(3))
            
            newEvent.setObject(location, forKey: "location")
            newEvent.setObject(randomPriority, forKey: "priority")
            //newEvent.setObject(access, forKey: "access")
            newEvent.setObject(randomCategory, forKey: "category")
            newEvent.setObject(randomSubCategory, forKey: "subCategory")
            newEvent.setObject(startTime, forKey: "startTime")
            newEvent.setObject(endTime, forKey: "endTime")
            
            //second level
            newEvent.setObject(name, forKey: "name")
            if(imagePicked == true)
            {
                let imageData = UIImagePNGRepresentation(backgroundImage.image)
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
    
    @IBAction func startTimeFieldEditing(sender: UITextField) {
        
        let inputDateView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 242))
        
        startDatePicker = UIDatePicker(frame: CGRectMake(0, 40, 0, 0))
        startDatePicker.date = startTime
        startDatePicker.datePickerMode = UIDatePickerMode.DateAndTime
        startDatePicker.addTarget(self, action: Selector("startDatePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        inputDateView.addSubview(startDatePicker)

        var doneButton = UIButton(frame: CGRectMake(8, 8, self.view.frame.width-16, 42))
        doneButton.setTitle("Done", forState: UIControlState.Normal)
        doneButton.backgroundColor = selectedColor
        doneButton.layer.cornerRadius = 8
        doneButton.addTarget(self, action: "doneButton:", forControlEvents: UIControlEvents.TouchUpInside)
        inputDateView.addSubview(doneButton)
        
        sender.inputView = inputDateView
    }

    @IBAction func endTimeFieldEditing(sender: UITextField) {
        
        let inputDateView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 242))
        
        endDatePicker = UIDatePicker(frame: CGRectMake(0, 40, 0, 0))
        endDatePicker.date = endTime
        endDatePicker.datePickerMode = UIDatePickerMode.DateAndTime
        endDatePicker.addTarget(self, action: Selector("endDatePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        inputDateView.addSubview(endDatePicker)
        
        var doneButton = UIButton(frame: CGRectMake(8, 8, self.view.frame.width-16, 42))
        doneButton.setTitle("Done", forState: UIControlState.Normal)
        doneButton.backgroundColor = selectedColor
        doneButton.layer.cornerRadius = 8
        doneButton.addTarget(self, action: "doneButton:", forControlEvents: UIControlEvents.TouchUpInside)
        inputDateView.addSubview(doneButton)
        
        sender.inputView = inputDateView
    }
    
    func startDatePickerValueChanged (sender: UIDatePicker) {
        startTime = sender.date
        updateTimeInterval()
    }
    
    func endDatePickerValueChanged (sender: UIDatePicker) {
        endTime = sender.date
        timeInterval = endTime.timeIntervalSinceDate(startTime)
        updateTimeInterval()
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }

    func contentsDidChange(textField: UITextField) {
        if(textField.text != "")
        {
            UIView.animateWithDuration(0.25, animations: {
                textField.backgroundColor = self.hasInfoColor
            })
        }
        else
        {
            UIView.animateWithDuration(0.25, animations: {
                textField.backgroundColor = UIColor.clearColor()
            })
        }
    }
    
    func doneButton(sender:UIButton)
    {
        self.view.endEditing(true)
    }
}
