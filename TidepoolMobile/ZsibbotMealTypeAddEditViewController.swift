//
//  ZsibbotMealTypeAddEditTableViewController.swift
//  TidepoolMobile
//
//  Created by Zsolt Essig on 23/10/2017.
//  Copyright © 2017 Tidepool. All rights reserved.
//

import Foundation

/*
 * Copyright (c) 2017, Tidepool Project
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the associated License, which is identical to the BSD 2-Clause
 * License as published by the Open Source Initiative at opensource.org.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the License for more details.
 *
 * You should have received a copy of the License along with this program; if
 * not, you can obtain one from Tidepool Project at tidepool.org.
 */


import UIKit
import CoreData
import CocoaLumberjack

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


