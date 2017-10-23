//
//  ZsibbotUIViewController.swift
//  TidepoolMobile
//
//  Created by Zsolt Essig on 23/10/2017.
//  Copyright © 2017 Tidepool. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.zsibbotDismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func zsibbotDismissKeyboard() {
        view.endEditing(true)
    }
}
