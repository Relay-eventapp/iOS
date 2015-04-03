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
    
    //"profile" cell outlets
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var additionalInfoLabel: UILabel!
    
    var logoutCellRow = 5
    var normalCellHeight: CGFloat!
    
    var cellName = ["Profile", "Map", "Discover", "Friends", "Chat", "Log out"]
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        normalCellHeight = self.tableView.frame.height/10
        
        //self.tableView.separatorInset = UIEdgeInsetsZero
        //self.tableView.layoutMargins = UIEdgeInsetsZero
        
        //initialize the close button
        closeButton.setImage(closeButtonImage, forState: .Normal)
        closeButton.frame = CGRectMake(8, 20, 42, 42)
        self.view.addSubview(closeButton)
        
        //initialize the filter events button
        addEventButton.setImage(addEventButtonImage, forState: .Normal)
        addEventButton.frame = CGRectMake(self.view.frame.width - 8 - 42, 20, 42, 42)
        self.view.addSubview(addEventButton)
        
        profilePicture.layer.cornerRadius = profilePicture.frame.height/2
        profilePicture.clipsToBounds = true
        profilePicture.layer.borderWidth = 3.0
        profilePicture.layer.borderColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1).CGColor
        
        //hide extraneous cells
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        if self.revealViewController() != nil {
            
            closeButton.addTarget(self.revealViewController(), action:Selector("revealToggle:"), forControlEvents: .TouchUpInside)
            
            //println(self.view.frame.width)
            self.revealViewController().rearViewRevealWidth = self.view.frame.width
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.frame = CGRectMake(0, 0, self.revealViewController().rearViewRevealWidth, 667)
    }
    
    //sets the height for each cell in the table view
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.row {
        case 0:
            return 4 * normalCellHeight
        case 5:
            return 2 * normalCellHeight
        default:
            return normalCellHeight
        }
    }
    
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
