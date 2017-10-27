//
//  ZsibbotMealTypeAddEditTableViewController.swift
//  TidepoolMobile
//
//  Created by Zsolt Essig on 23/10/2017.
//  Copyright © 2017 Tidepool. All rights reserved.
//

import Foundation
import UIKit

class ZsibbotMealTypeAddEditViewController: ZsibbotEventAddEditViewController, UITextFieldDelegate {
    override var eventName: String {
        get {
            return "Meal Type"
        }
    }
    
    override func viewDidLayoutSubviews() {
        if(subviewsInitialized) {
            return
        }
        super.viewDidLayoutSubviews()
        let label = addLabel(afterView: separatorOne, text: "Name")
        let _ = addUITextField(afterView: separatorOne, delegate: self)
        
        recalcMessageBox(lastSubView: label)
    }
}


