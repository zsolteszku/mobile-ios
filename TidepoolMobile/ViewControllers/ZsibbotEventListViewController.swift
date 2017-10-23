//
//  ZsibbotEventListViewController.swift
//  TidepoolMobile
//
//  Created by Zsolt Essig on 22/10/2017.
//  Copyright © 2017 Tidepool. All rights reserved.
//

import Foundation
import UIKit

struct AssociatedKeys {
    static var pickerViewPresenter: UInt8 = 0
    static var pickerViewPresenterAction: UInt8 = 0
}

extension EventListViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    private var pickerViewPresenter: ZsibbotPickerViewPresenter {
        get {
            return getStoredProperty(&AssociatedKeys.pickerViewPresenter) {
                self.createPickerViewPresenter()
            }
        }
        set(newValue) {
            setStoredProperty(&AssociatedKeys.pickerViewPresenter, newValue: newValue)
        }
    }
    
    private static let dataModel: [String] = ["Food", "FoodType"]
    
    private var pickerViewPresenterAction: ((String) -> Void)? {
        get {
            return getStoredProperty(&AssociatedKeys.pickerViewPresenterAction)
        }
        set {
            return setStoredProperty(&AssociatedKeys.pickerViewPresenterAction, newValue: newValue)
        }
    }
    
    private func createPickerViewPresenter() -> ZsibbotPickerViewPresenter {
        let val = ZsibbotPickerViewPresenter()
        val.pickerDelegate = self
        val.pickerDataSource = self
        val.selectButtonAction = { [weak self] () -> Void in
            guard let strongSelf = self else {
                return
            }
            let res = EventListViewController.dataModel[val.currentlySelectedRow]
            strongSelf.pickerViewPresenterAction?(res)
            strongSelf.pickerViewPresenterAction = nil
            val.hidePicker()
        }
        
        return val
    }
    
    func addPickerViewPresenterAsSubview() {
        view.addSubview(pickerViewPresenter)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return EventListViewController.dataModel.count
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return EventListViewController.dataModel[row]
    }
    
    func presentPickerView() {
        let index = 0 // [0..dataModel.count-1]
        pickerViewPresenter.selectRowAtIndex(index: index)
        pickerViewPresenter.showPicker()
    }
    
    func presentPickerView(completitionHandler: @escaping (String) -> Void) {
        pickerViewPresenterAction = completitionHandler
        presentPickerView()
    }
}
