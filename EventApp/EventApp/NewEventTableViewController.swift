//
//  NewEventTableViewController.swift
//  EventApp
//
//  Created by Mike Zhao on 3/23/15.
//  Copyright (c) 2015 Mike Zhao. All rights reserved.
//

import UIKit

class NewEventTableViewController: UITableViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    
    var newEventLocation:CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        println("\nNew Event Table View Controller View:")
        
        doneButton.addTarget(self.revealViewController(), action:Selector("doneButtonPressed:"), forControlEvents: .TouchUpInside)
        doneButton.layer.cornerRadius = 5
        
        //var backgroundView =
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //@IBAction func doneButton(sender: AnyObject) {
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
    
    func createNewEvent(name: String, location: PFGeoPoint, description: String)
    {
        //check if the user has signed in
        if(PFUser.currentUser() != nil)
        {
            var newEvent = PFObject(className: "Events")
            newEvent.setObject(name, forKey: "name")
            newEvent.setObject(description, forKey: "description")
            newEvent.setObject(location, forKey: "location")
            
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
        
        println("User tapped cell \(indexPath.row)")

    }
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        
        return cell
    }
    

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
