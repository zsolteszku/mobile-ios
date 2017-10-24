//
//  ZsibbotMealTypeAddEditTableViewController.swift
//  TidepoolMobile
//
//  Created by Zsolt Essig on 23/10/2017.
//  Copyright © 2017 Tidepool. All rights reserved.
//

import Foundation
import UIKit

class ZsibbotMealTypeAddEditViewController: EventAddEditViewController {
    
    override func configureTitleView() {
        self.navItem.title = isAddNote ? "Add Meal Type" : "Edit Meal Type"
    }
    
    func removeHashTagScrollView() {
        // remove hashTagScrollView
        self.sceneContainerView.willRemoveSubview(self.hashtagsScrollView)
        self.hashtagsScrollView.removeFromSuperview()
        
        // remove separator two
        self.sceneContainerView.willRemoveSubview(self.separatorTwo)
        self.separatorTwo.removeFromSuperview()
        
        
    }
    
    func recalcMessageBox(lastSubView: UIView) {
        let messageBoxW = self.sceneContainerView.frame.width - 2 * labelInset
        let messageBoxH = (postButtonFrame.minY - lastSubView.frame.maxY) - 2 * labelInset
        messageBox.frame.size = CGSize(width: messageBoxW, height: messageBoxH)
        
        messageBox.frame.origin.x = labelInset
        messageBox.frame.origin.y = lastSubView.frame.maxY + labelInset
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        removeHashTagScrollView()
        
        recalcMessageBox(lastSubView: separatorOne)
        
        messageBox.isEditable = false
    }
}


