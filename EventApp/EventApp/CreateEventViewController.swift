//
//  CreateEventViewController.swift
//  EventApp
//
//  Created by Mike Zhao on 4/23/15.
//  Copyright (c) 2015 Mike Zhao. All rights reserved.
//

import UIKit

class CreateEventViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    var accessButton: DDExpandableButton!
    
    @IBOutlet weak var startTime: UITextField!
    @IBOutlet weak var endTime: UITextField!
    var dateformatter = NSDateFormatter()
    var startDatePickerView:UIDatePicker = UIDatePicker()
    var endDatePickerView:UIDatePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        accessButton = DDExpandableButton(point: CGPointMake(16, descriptionField.frame.maxY+8), leftTitle: "Access:", buttons: ["Public", "Private", "Protected"])
        accessButton.labelFont = UIFont(name: "HelveticaNeue-Light", size: 20)
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
            attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        descriptionField.attributedPlaceholder = NSAttributedString(string:"Description",
            attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        startTime.attributedPlaceholder = NSAttributedString(string:"Start Time",
            attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        endTime.attributedPlaceholder = NSAttributedString(string:"End Time",
            attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        
        nameField.delegate = self
        descriptionField.delegate = self
        startTime.delegate = self
        endTime.delegate = self
    }

    func toggleAccess(sender: DDExpandableButton)
    {
        println("asdf")
        /*
        switch sender.selectedItem
        {
        case default:
            println("asdf")
        }
        */
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

}
