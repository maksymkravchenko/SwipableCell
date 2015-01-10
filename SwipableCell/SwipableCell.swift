//
//  SwipableCell.swift
//  SwipableCell
//
//  Created by Max Kravchenko on 1/11/15.
//  Copyright (c) 2015 Max Kravchenko. All rights reserved.
//

import UIKit

protocol SwipableCellTableViewCellDelegate: NSObjectProtocol {
    func swipeCellDidStartSwiping(cell : SwipableCell)
}


class SwipableCell: UITableViewCell {
    
    var delegate : SwipableCellTableViewCellDelegate?
    let kBounceValue = CGFloat(20)
    var panGesture : UIPanGestureRecognizer?
    var isSwiped = false
    
    private var panStartPoint : CGPoint?
    private var startRightConstraint : CGFloat?
    
    private var _allButtons: [UIButton]?
    private var _viewOfContents: UIView?
    private var _rightConstraint: NSLayoutConstraint?
    private var _leftConstraint: NSLayoutConstraint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func resetAllVisibleCells() {
        if let theDelegate = delegate {
            if theDelegate.respondsToSelector("swipeCellDidStartSwiping:") {
                theDelegate.swipeCellDidStartSwiping(self)
            }
        }
    }
    
    func panCell(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .Began :
            panStartPoint = recognizer.translationInView(viewOfContents!)
            startRightConstraint = rightConstraint?.constant
            resetAllVisibleCells()
            
            break
        case .Changed :
            var currentPoint = recognizer.translationInView(viewOfContents!)
            var deltaX = currentPoint.x - panStartPoint!.x
            var movesLeft = false
            if currentPoint.x < panStartPoint!.x {
                movesLeft = true
            }
            if startRightConstraint == 0 {
                if !movesLeft {
                    var constant = CGFloat(max(-deltaX, 0.0))
                    if constant == 0 {
                        rightConstraint!.constant = constant
                    } else {
                        resetConstraints(true)
                    }
                } else {
                    var constant = CGFloat(min(-deltaX, buttonTotalWidth()))
                    if constant == buttonTotalWidth() {
                        showAllButtons(false)
                    } else {
                        rightConstraint!.constant = constant
                    }
                }
            } else {
                var adjustment = startRightConstraint! - deltaX
                if !movesLeft {
                    var constant = CGFloat(max(adjustment, 0.0))
                    if constant == 0 {
                        resetConstraints(true)
                    } else {
                        rightConstraint!.constant = constant
                    }
                } else {
                    var constant = CGFloat(min(adjustment, buttonTotalWidth()))
                    if constant == buttonTotalWidth() {
                        showAllButtons(false)
                    } else {
                        rightConstraint!.constant = constant
                    }
                }
            }
            leftConstraint!.constant = -rightConstraint!.constant
            break
        case .Ended :
            if startRightConstraint == 0 {
                //Cell was opening
                var halfOfButtonOne : CGFloat?
                if let button = allButtons?.first {
                    halfOfButtonOne = button.frame.width / 2
                } else {
                    halfOfButtonOne = CGFloat(40)
                }
                
                if rightConstraint!.constant >= halfOfButtonOne {
                    //Open all the way
                    showAllButtons(true)
                    isSwiped = true
                } else {
                    //Re-close
                    resetConstraints(false)
                    isSwiped = false
                }
            } else {
                //Cell was closing
                var buttonsMinusHalfOfLastButton: CGFloat?
                var allButtonsWidth = CGFloat(0)
                for button in allButtons! {
                    allButtonsWidth += button.frame.width
                }
                if allButtonsWidth > 0 {
                    buttonsMinusHalfOfLastButton = allButtonsWidth - allButtons!.last!.frame.width / 2
                } else {
                    buttonsMinusHalfOfLastButton = CGFloat(70)
                }
                
                if rightConstraint!.constant >= buttonsMinusHalfOfLastButton {
                    //Re-open all the way
                    showAllButtons(true)
                    isSwiped = true
                } else {
                    //Close
                    resetConstraints(false)
                    isSwiped = false
                }
            }
            break
        case .Cancelled :
            if startRightConstraint == 0 {
                resetConstraints(false)
            } else {
                showAllButtons(true)
            }
        default :
            break
        }
    }
    
    private func buttonTotalWidth() -> CGFloat {
        if let lastButton = allButtons!.last {
            return CGRectGetWidth(frame) - CGRectGetMinX(lastButton.frame)
        } else {
            return CGRectGetWidth(frame) / 4
        }
    }
    
    func resetConstraints(animated: Bool) {
        if startRightConstraint! == 0 && rightConstraint!.constant == 0 {
            return
        }
        leftConstraint!.constant = -kBounceValue
        rightConstraint!.constant = kBounceValue
        
        updateConstraintsIfNeeded(true, completion: {
            (finished : Bool) in
            self.rightConstraint!.constant = 0
            self.leftConstraint!.constant = 0
            
            self.updateConstraintsIfNeeded(true, completion: {
                (finished : Bool) in
                self.startRightConstraint! = self.rightConstraint!.constant
            })
        })
        
    }
    
    private func showAllButtons(animated: Bool) {
        if startRightConstraint == buttonTotalWidth() &&
            rightConstraint!.constant == buttonTotalWidth() {
                return
        }
        
        leftConstraint!.constant = -buttonTotalWidth() - kBounceValue
        rightConstraint!.constant = buttonTotalWidth() + kBounceValue
        
        updateConstraintsIfNeeded(animated, completion: {
            (finished : Bool) in
            self.leftConstraint!.constant = -self.buttonTotalWidth()
            self.rightConstraint!.constant  = self.buttonTotalWidth()
            
            self.updateConstraintsIfNeeded(animated, completion: {
                (finished : Bool) in
                self.startRightConstraint = self.rightConstraint!.constant
            })
        })
    }
    
    private func updateConstraintsIfNeeded(animated : Bool, completion: (Bool) -> Void ) {
        var duration = 0.0
        if (animated) {
            duration = 0.1
        }
        UIView.animateWithDuration(
            duration,
            delay: 0.0,
            options:UIViewAnimationOptions.CurveEaseOut,
            animations: {
                self.layoutIfNeeded()
            },
            completion : completion)
    }
    
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetConstraints(false)
    }
    
    var allButtons: [UIButton]? {
        get {
            if _allButtons == nil {
                return  [UIButton()]
            }
            return _allButtons
        }
        set {
            _allButtons = newValue
        }
    }
    
    var viewOfContents: UIView? {
        get {
            if _viewOfContents == nil {
                return UIView()
            }
            return _viewOfContents!
        }
        set {
            _viewOfContents = newValue
        }
    }
    
    var rightConstraint: NSLayoutConstraint? {
        get {
            if _rightConstraint == nil {
                return NSLayoutConstraint()
            }
            return _rightConstraint!
        }
        set {
            _rightConstraint = newValue
        }
    }
    
    var leftConstraint: NSLayoutConstraint? {
        get {
            if _leftConstraint == nil {
                return NSLayoutConstraint()
            }
            return _leftConstraint!
        }
        set {
            _leftConstraint = newValue
        }
    }
}
