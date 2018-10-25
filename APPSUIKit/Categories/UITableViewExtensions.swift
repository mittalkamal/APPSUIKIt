//
//  UITableViewExtensions.swift
//  AppstronomyStandardKit
//
//  Created by Ken Grigsby on 1/3/17.
//  Copyright © 2017 Appstronomy, LLC. All rights reserved.
//

import UIKit

extension UITableView {
    
    /**
     Apply blur effect to table view background. You will probably want
     to set the cell background color to clear for the full effect. If presented
     in a nav controller make the following changes before presenting.
     
     navController.modalPresentationStyle = UIModalPresentationOverCurrentContext; // allow background to show through
     navController.modalPresentationCapturesStatusBarAppearance = YES;  // Allow nav controller to set status bar to dark text
     */
    open func applyBlurEffect(style: UIBlurEffectStyle) {
        // Credit: http://belka.us/en/modal-uiviewcontroller-blur-background-swift/

        backgroundColor = UIColor.clear
        
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = frame
        
        separatorEffect = UIVibrancyEffect(blurEffect: blurEffect)
        backgroundView = blurEffectView
    }
    
    /**
     Calls layoutIfNeeded on the cell, then beingUpdates/endUpdates, and optionally scrolls the cell into view.
     */
    open func animateRowHeightChanges(at indexPath: IndexPath, withDuration duration: TimeInterval, scrollIntoView: Bool) {
        
        guard let cell = self.cellForRow(at: indexPath) else {
            self.beginUpdates()
            self.endUpdates()
            return
        }
        
        CATransaction.begin()
        
        CATransaction.setCompletionBlock {
            if scrollIntoView {
                // Need to delay otherwise scrolling the last cell into view doesn't work.
                // I don't know why.
                DispatchQueue.main.async {
                    let rectInTableView = cell.convert(cell.bounds, to: self)
                    self.scrollRectToVisible(rectInTableView, animated: true)
                }
            }
        }
        
        UIView.animate(withDuration: duration) { 
            cell.layoutIfNeeded()
        }
        
        self.beginUpdates()
        self.endUpdates()
        
        CATransaction.commit()
    }

}
