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
}


