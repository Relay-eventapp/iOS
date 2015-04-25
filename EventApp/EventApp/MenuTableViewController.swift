//
//  closeTableViewController.swift
//  EventApp
//
//  Created by Mike Zhao on 3/17/15.
//  Copyright (c) 2015 Mike Zhao. All rights reserved.
//

import UIKit
import Parse

class MenuTableViewController: UITableViewController, UIGestureRecognizerDelegate {
    
    var closeButton = VBFPopFlatButton()
    
    //"profile" cell outlets
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var additionalInfoLabel: UILabel!
    
    var logoutCellRow = 5
    var normalCellHeight: CGFloat!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        normalCellHeight = self.tableView.frame.height/10
        
        //initialize the close button
        closeButton = VBFPopFlatButton(frame: CGRectMake(16,30,26,26), buttonType: .buttonCloseType, buttonStyle: .buttonRoundedStyle, animateToInitialState: false)
        closeButton.lineThickness = 2
        closeButton.lineRadius = 0.1
        closeButton.roundBackgroundColor = UIColor.whiteColor()
        closeButton.tintColor = UIColor(red: (75/255.0), green: (70/255.0), blue: (85/255.0), alpha: 1)
        self.view.addSubview(closeButton)
        
        profilePicture.layer.cornerRadius = profilePicture.frame.height/2
        profilePicture.clipsToBounds = true
        profilePicture.layer.borderWidth = 3.0
        profilePicture.layer.borderColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1).CGColor
        
        //hide extraneous cells
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        if self.revealViewController() != nil {
            
            closeButton.addTarget(self.revealViewController(), action:Selector("revealToggle:"), forControlEvents: .TouchUpInside)
            
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        
        revealViewController().frontViewController.view.userInteractionEnabled = false
        tableView.frame = CGRectMake(0, 0, revealViewController().rearViewRevealWidth, self.tableView.frame.height)
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        revealViewController().frontViewController.view.userInteractionEnabled = true
    }
    
    /*
    //sets the height for each cell in the table view
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.row {
        case 0:
            return 4.5 * normalCellHeight
        default:
            return normalCellHeight
        }
    }
        */
    
    //log out the user when the "log out" cell is selected
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
