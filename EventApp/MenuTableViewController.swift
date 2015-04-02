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
    var normalCellHeight: CGFloat!
    
    var cellName = ["Profile", "Map", "Discover", "Friends", "Chat", "Log out"]
        
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tableView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        
        println(tableView.frame)
        println(self.view.frame.width)
        println(self.view.frame.height)
        
        normalCellHeight = self.tableView.frame.height/10
        
        self.tableView.separatorInset = UIEdgeInsetsZero
        self.tableView.layoutMargins = UIEdgeInsetsZero
        
        //initialize the close button
        closeButton.setImage(closeButtonImage, forState: .Normal)
        closeButton.frame = CGRectMake(8, 20, 42, 42)
        self.view.addSubview(closeButton)
        
        //initialize the filter events button
        addEventButton.setImage(addEventButtonImage, forState: .Normal)
        addEventButton.frame = CGRectMake(self.view.frame.width - 8 - 42, 20, 42, 42)
        self.view.addSubview(addEventButton)
        
        if self.revealViewController() != nil {
            
            closeButton.addTarget(self.revealViewController(), action:Selector("revealToggle:"), forControlEvents: .TouchUpInside)
            
        }
        
        //hide extraneous cells
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    //alters the cell for each path
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        
        cell.layoutMargins = UIEdgeInsetsZero
        cell.selectionStyle = .None
        cell.backgroundColor = UIColor.darkGrayColor()
        cell.textLabel!.textColor = UIColor(red: 240, green: 240, blue: 240, alpha: 1.0)
        cell.textLabel!.textAlignment = NSTextAlignment.Center
        cell.textLabel!.text = cellName[indexPath.row]
        
        println(cell.frame.width)
        
        cell.textLabel!.frame = CGRectMake(cell.frame.minX, cell.frame.minY, cell.frame.width, cell.frame.height)
        /*
        switch indexPath.row {
        case 0:
            cell.textLabel!.frame = CGRectMake(cell.frame.minX, cell.frame.minY, cell.frame.width-25, cell.frame.height)
        case 5:
            cell.textLabel!.frame = CGRectMake(0, 0, cell.frame.width-25, cell.frame.height)
        default:
            cell.textLabel!.frame = CGRectMake(0, 0, cell.frame.width/3, cell.frame.height)
        }
        */

        return cell
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
