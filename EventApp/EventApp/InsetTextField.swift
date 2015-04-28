//
//  insetTextField.swift
//  EventApp
//
//  Created by Mike Zhao on 4/26/15.
//  Copyright (c) 2015 Mike Zhao. All rights reserved.
//

import UIKit

class InsetTextField: UITextField {

    var leftMargin : CGFloat = 16.0
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        var newBounds = bounds
        newBounds.origin.x += leftMargin
        return newBounds
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        var newBounds = bounds
        newBounds.origin.x += leftMargin
        return newBounds
    }
}
