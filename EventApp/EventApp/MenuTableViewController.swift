//
//  MenuTableViewController.swift
//  EventApp
//
//  Created by Mike Zhao on 3/17/15.
//  Copyright (c) 2015 Mike Zhao. All rights reserved.
//

import UIKit
import Parse

class MenuTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var closeButton = VBFPopFlatButton()
    
    @IBOutlet weak var profilePictureButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var additionalInfoLabel: UILabel!
    
    var logoutCellRow = 5
    var normalCellHeight: CGFloat!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        normalCellHeight = self.tableView.frame.height/10
        
        closeButton = VBFPopFlatButton(frame: CGRectMake(16,30,28,28), buttonType: .buttonCloseType, buttonStyle: .buttonPlainStyle, animateToInitialState: false)
        closeButton.lineThickness = 2
        closeButton.tintColor = UIColor.whiteColor()
        closeButton.addTarget(self, action: "dismissMenu:", forControlEvents: .TouchUpInside)
        self.view.addSubview(closeButton)
        
        profilePictureButton.layer.cornerRadius = profilePictureButton.frame.height/2
        profilePictureButton.clipsToBounds = true
        profilePictureButton.layer.borderWidth = 3.0
        profilePictureButton.layer.borderColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1).CGColor
        profilePictureButton.addTarget(self, action: "selectProfilePicture:", forControlEvents: .TouchUpInside)
        
        println("User: \(PFUser.currentUser())")
        
        usernameLabel.text = PFUser.currentUser()?.username
        additionalInfoLabel.text = PFUser.currentUser()?.email
        
        //hide extraneous cells
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        if (!UIAccessibilityIsReduceTransparencyEnabled()) {
            tableView.backgroundColor = UIColor.clearColor()
            let blurEffect = UIBlurEffect(style: .Dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            tableView.backgroundView = blurEffectView
        }
    }

    func dismissMenu(sender: UIButton)
    {
        slideMenuController()?.closeLeft()
    }

    func selectProfilePicture(sender: UIButton)
    {
        var imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.allowsEditing = true
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        profilePictureButton.alpha = 0
        profilePictureButton.setImage(image, forState: .Normal)
        UIView.animateWithDuration(1.0, animations: {
            self.profilePictureButton.alpha = 1
        })
        //imagePicked = true
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if(indexPath.row == logoutCellRow)
        {
            if(PFUser.currentUser() != nil)
            {
                PFUser.logOut()
                println("User logged out.")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
