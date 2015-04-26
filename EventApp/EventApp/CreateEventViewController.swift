//
//  CreateEventViewController.swift
//  EventApp
//
//  Created by Mike Zhao on 4/23/15.
//  Copyright (c) 2015 Mike Zhao. All rights reserved.
//

import UIKit

class CreateEventViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    var accessButton: DDExpandableButton!
    
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var startTime: UITextField!
    @IBOutlet weak var endTime: UITextField!
    var dateformatter = NSDateFormatter()
    var startDatePickerView:UIDatePicker = UIDatePicker()
    var endDatePickerView:UIDatePicker = UIDatePicker()
    
    var almostWhiteColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.65)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        accessButton = DDExpandableButton(point: CGPointMake(16, descriptionField.frame.maxY+8), leftTitle: "Access:", buttons: ["Public", "Private", "Protected"])
        accessButton.labelFont = UIFont(name: "HelveticaNeue-Light", size: 20)
        //accessButton.unSelectedLabelFont = UIFont(name: "HelveticaNeue-Light", size: 14)
        accessButton.borderColor = UIColor.clearColor()
        accessButton.textColor = UIColor.whiteColor()
        accessButton.verticalPadding = 9
        accessButton.horizontalPadding = 7
        accessButton.addTarget(self, action: "toggleAccess:", forControlEvents: .ValueChanged)
        accessButton.updateDisplay()
        self.view.addSubview(accessButton)
        
        startDatePickerView.datePickerMode = .DateAndTime
        endDatePickerView.datePickerMode = .DateAndTime
        dateformatter.dateStyle = .MediumStyle
        dateformatter.timeStyle = .ShortStyle
        
        nameField.attributedPlaceholder = NSAttributedString(string:"Name",
            attributes:[NSForegroundColorAttributeName: almostWhiteColor ])
        descriptionField.attributedPlaceholder = NSAttributedString(string:"Description",
            attributes:[NSForegroundColorAttributeName: almostWhiteColor ])
        locationField.attributedPlaceholder = NSAttributedString(string:"Location",
            attributes:[NSForegroundColorAttributeName: almostWhiteColor ])
        startTime.attributedPlaceholder = NSAttributedString(string:"Start Time",
            attributes:[NSForegroundColorAttributeName: almostWhiteColor ])
        endTime.attributedPlaceholder = NSAttributedString(string:"End Time",
            attributes:[NSForegroundColorAttributeName: almostWhiteColor ])
        
        nameField.delegate = self
        descriptionField.delegate = self
        locationField.delegate = self
        startTime.delegate = self
        endTime.delegate = self
    }

    func toggleAccess(sender: DDExpandableButton)
    {

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        cell.profilePicture.layer.borderColor = almostWhiteColor.CGColor
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ProfileCollectionViewCell
        
        if(cell.invited == false)
        {
            UIView.animateWithDuration(0.5, animations: {
                cell.profilePicture.layer.borderColor = UIColor.flatEmeraldColor().CGColor
            })
            cell.invited = true
        }
        else
        {
            UIView.animateWithDuration(0.5, animations: {
                cell.profilePicture.layer.borderColor = self.almostWhiteColor.CGColor
            })
            cell.invited = false
        }
        println("Cell \(indexPath.row) selected")
    }
    @IBAction func startTimeEditing(sender: UITextField) {
        sender.inputView = startDatePickerView
        startDatePickerView.addTarget(self, action: Selector("startDatePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    }

    @IBAction func endTimeEditing(sender: UITextField) {
        sender.inputView = endDatePickerView
        endDatePickerView.addTarget(self, action: Selector("endDatePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func startDatePickerValueChanged (sender:UIDatePicker) {
        startTime.text = dateformatter.stringFromDate(sender.date)
    }
    
    func endDatePickerValueChanged (sender:UIDatePicker) {
        endTime.text = dateformatter.stringFromDate(sender.date)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(textField: UITextField) {
        
        if(textField.text != "")
        {
            UIView.animateWithDuration(0.25, animations: {
                textField.backgroundColor = UIColor(red: 0.45, green: 0.9, blue: 0.45, alpha: 0.5)
            })
        }
        else
        {
            UIView.animateWithDuration(0.25, animations: {
                textField.backgroundColor = UIColor.clearColor()
            })
        }
    }
}
