//
//  closeTableViewController.swift
//  EventApp
//
//  Created by Mike Zhao on 3/17/15.
//  Copyright (c) 2015 Mike Zhao. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController, UIGestureRecognizerDelegate {

    let closeButton = UIButton()
    let closeButtonImage = UIImage(named: "close") as UIImage!
    
    let addEventButton = UIButton()
    let addEventButtonImage = UIImage(named: "add") as UIImage!
    
    var logoutCellRow = 6
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //initialize the close button
        closeButton.setImage(closeButtonImage, forState: .Normal)
        closeButton.frame = CGRectMake(8, 0, 42, 42)
        self.view.addSubview(closeButton)
        
        //initialize the filter events button
        addEventButton.setImage(addEventButtonImage, forState: .Normal)
        addEventButton.frame = CGRectMake(self.view.frame.width - 8 - 42, 0, 42, 42)
        self.view.addSubview(addEventButton)
        
        if self.revealViewController() != nil {
            
            closeButton.addTarget(self.revealViewController(), action:Selector("revealToggle:"), forControlEvents: .TouchUpInside)
            
        }
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
