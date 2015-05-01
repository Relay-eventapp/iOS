//
//  InspectEventTableViewController.swift
//  EventApp
//
//  Created by Mike Zhao on 4/8/15.
//  Copyright (c) 2015 Mike Zhao. All rights reserved.
//

import UIKit

class InspectEventViewController: UIViewController {

    @IBOutlet weak var background: UIImageView!
    var eventId: String!
    var event: PFObject!
    
    let locationButton = UIButton()
    let locationButtonImage = UIImage(named: "map") as UIImage!
    
    
    var backButton: VBFPopFlatButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        backButton = VBFPopFlatButton(frame: CGRectMake(16,28,28,28), buttonType: .buttonBackType, buttonStyle: .buttonPlainStyle, animateToInitialState: false)
        backButton.lineThickness = 2
        backButton.tintColor = UIColor.whiteColor()
        backButton.addTarget(self, action: "dismissView:", forControlEvents: .TouchUpInside)
        self.view.addSubview(backButton)
        */
        //find the event in the currentEvents Array
        for evnt in currentEvents {
         
            if(evnt.objectId == eventId)
            {
                event = evnt
                break
            }
        }
        
        let priority = event["priority"] as! Int
        
        let userImageFile = event["photo"] as? PFFile
        if (userImageFile != nil)
        {
            let imageData = userImageFile?.getData()
            self.background.image = UIImage(data:imageData!)
        }
        else
        {
            let category = event["category"] as! Int
            self.background.image = UIImage(named: "back_\(eventCategories[category].lowercaseString)")
        }
    }
    
    func dismissView(sender: UIButton)
    {
        performSegueWithIdentifier("exitView", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
