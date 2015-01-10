//
//  DemoCell.swift
//  SwipableCell
//
//  Created by Max Kravchenko on 1/11/15.
//  Copyright (c) 2015 Max Kravchenko. All rights reserved.
//

import UIKit

class DemoCell: SwipableCell {
    var demoButtons: [UIButton]?
    
    @IBOutlet weak var demoText: UILabel!
    @IBOutlet weak var butt1: UIButton!
    @IBOutlet weak var butt2: UIButton!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var theRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var theLeftConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        demoButtons = [butt2, butt1]
        allButtons = demoButtons
        rightConstraint = theRightConstraint
        leftConstraint = theLeftConstraint
        viewOfContents = view
        panGesture = UIPanGestureRecognizer(target: self, action: "panCell:")
        panGesture!.delegate = self
        view.addGestureRecognizer(panGesture!)
    }
    
}
