//
//  ProfileCollectionViewCell.swift
//  EventApp
//
//  Created by Mike Zhao on 4/25/15.
//  Copyright (c) 2015 Mike Zhao. All rights reserved.
//

import UIKit

class ProfileCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    var invited = false
}
