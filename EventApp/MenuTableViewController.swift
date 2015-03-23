//
//  MenuTableViewController.swift
//  EventApp
//
//  Created by Mike Zhao on 3/17/15.
//  Copyright (c) 2015 Mike Zhao. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController, UIGestureRecognizerDelegate {

    let menuButton = UIButton()
    //let menuButtonImage = UIImage(named: "bullets.png") as UIImage!
    
    let addEventButton = UIButton()
    //let addEventButtonImage = UIImage(named: "add.png") as UIImage!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //initialize the menu button
        //menuButton.setImage(menuButtonImage, forState: .Normal)
        menuButton.frame = CGRectMake(10, 10, 50, 50)
        menuButton.backgroundColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1.0)
        menuButton.layer.cornerRadius = 25
        self.view.addSubview(menuButton)
        
        //initialize the add event button
        //addEventButton.setImage(addEventButtonImage, forState: .Normal)
        addEventButton.frame = CGRectMake(self.view.frame.width - 60, 10, 50, 50)
        addEventButton.backgroundColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1.0)
        addEventButton.layer.cornerRadius = 25
        self.view.addSubview(addEventButton)
        
        if self.revealViewController() != nil {
            
            menuButton.addTarget(self.revealViewController(), action:Selector("revealToggle:"), forControlEvents: .TouchUpInside)
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func logOutButton(sender: AnyObject)
    {
        if(PFUser.currentUser() != nil)
        {
        PFUser.logOut()
        //segue to loginViewController
        println("User logged out.")
        }
    }

    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
