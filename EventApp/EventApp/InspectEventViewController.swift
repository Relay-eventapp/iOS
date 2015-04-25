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
    @IBOutlet weak var profilePic: UIImageView!
    var eventId: String!
    var event: PFObject!
    
    let locationButton = UIButton()
    let locationButtonImage = UIImage(named: "map") as UIImage!
    
    let joinButton = UIButton()
    let joinButtonImage = UIImage(named: "add") as UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePic.layer.cornerRadius = profilePic.frame.height/2
        profilePic.clipsToBounds = true
        profilePic.layer.borderWidth = 3.0
        profilePic.layer.borderColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.8).CGColor
        
        //find the event in the currentEvents Array
        for evnt in currentEvents {
         
            if(evnt.objectId == eventId)
            {
                event = evnt
                break
            }
        }
        
        let priority = event["priority"] as! Int
        //view.backgroundColor = UIColor(red: (75/255.0), green: (70/255.0), blue: (85/255.0), alpha: 1)
        //eventColors[priority] as UIColor
        //background.alpha = 0.25
        
        /*
        let topColor = gradientColor //UIColor(red: (75/255.0), green: (70/255.0), blue: (85/255.0), alpha: 1)
        let bottomColor = gradientColor.colorWithAlphaComponent(0) //UIColor(red: (75/255.0), green: (70/255.0), blue: (85/255.0), alpha: 0)
        
        //set up your gradient layer with two colors.....topcolor first
        let viewGradient : CAGradientLayer = CAGradientLayer(topColor: topColor, bottomColor: bottomColor)
        viewGradient.frame = self.view.frame
        background.layer.addSublayer(viewGradient)
        */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
/*
import QuartzCore

extension CAGradientLayer {
    
    convenience init(topColor: UIColor, bottomColor: UIColor) {
        self.init()
        
        let colors = [topColor.CGColor, topColor.CGColor, bottomColor.CGColor]
        
        let stopOne = 0.0
        let stopTwo = 0.4
        let stopThree = 1.0
        
        let locations = [stopOne, stopTwo, stopThree]
        
        //set the properties of the layer
        self.colors = colors
        self.locations = locations
        
    }
    
}
*/
