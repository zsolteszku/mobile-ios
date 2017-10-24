//
//  ZsibbotEventListViewController.swift
//  TidepoolMobile
//
//  Created by Zsolt Essig on 22/10/2017.
//  Copyright © 2017 Tidepool. All rights reserved.
//

import Foundation
import UIKit

fileprivate struct AssociatedKeys {
    static var pickerViewPresenter: UInt8 = 0
    static var pickerViewPresenterAction: UInt8 = 0
}

private typealias ZsibbotEventListViewController = EventListViewController
extension ZsibbotEventListViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    enum ZsibbotEventType: String {
        case Note
        case Meal
        case MealType
        
        static let All: [ZsibbotEventType] = ZsibbotEventType.fetchAll()
        
        private static func fetchAll() -> [ZsibbotEventType] {
            var allValues: [ZsibbotEventType] = []
            switch (ZsibbotEventType.Note) {
                case .Note: allValues.append(.Note); fallthrough
                case .Meal: allValues.append(.Meal); fallthrough
                case .MealType: allValues.append(.MealType)
            }
            return allValues
        }
    }
    
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
    
    private static let dataModel: [ZsibbotEventType] = ZsibbotEventType.All
    
    private var pickerViewPresenterAction: ((ZsibbotEventType) -> Void)? {
        get {
            return getStoredProperty(&AssociatedKeys.pickerViewPresenterAction)
        }
        set {
            return setStoredProperty(&AssociatedKeys.pickerViewPresenterAction, newValue: newValue)
        }
    }
    
    private func createPickerViewPresenter() -> ZsibbotPickerViewPresenter {
        let val = ZsibbotPickerViewPresenter()
        val.tintColor = view.tintColor
        val.pickerDelegate = self
        val.pickerDataSource = self
        val.doneButtonAction = { [weak self] () -> Void in
            guard let strongSelf = self else {
                return
            }
            let res = ZsibbotEventType.All[val.currentlySelectedRow]
            strongSelf.pickerViewPresenterAction?(res)
            strongSelf.pickerViewPresenterAction = nil
            val.hidePicker()
        }
        
        return val
    }
    
    func zsibbotViewDidLoad() {
        addPickerViewPresenterAsSubview()
        hideKeyboardWhenTappedAround()
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
        return ZsibbotEventType.All[row].rawValue
    }
    
    func presentPickerView() {
        let index = 0 // [0..dataModel.count-1]
        pickerViewPresenter.selectRowAtIndex(index: index)
        pickerViewPresenter.showPicker()
    }
    
    func presentPickerView(completitionHandler: @escaping (ZsibbotEventType) -> Void) {
        pickerViewPresenterAction = completitionHandler
        presentPickerView()
    }
    
    func zsibbotNavBarRightButtonHandler(_ sender: Any) {
        self.presentPickerView() { [weak self] (value: ZsibbotEventType) -> Void in
            guard let strongSelf = self else {
                return
            }
            switch(value) {
            case .Note: strongSelf.originalNavBarRightButtonHandler(sender)
            case .MealType: strongSelf.navigateToMealType()
            default:
                fatalError("ZsibbotEventType(\(value.rawValue) View is not yet implemented.")
            }
        }
    }
    
    func navigateToMealType() {
        if APIConnector.connector().alertIfNetworkIsUnreachable() {
            return
        }
        let viewController:ZsibbotMealTypeAddEditViewController = UIStoryboard(name: "ZsibbotEvents", bundle: nil).instantiateViewController(withIdentifier: "MealTypeAddEdit") as! ZsibbotMealTypeAddEditViewController
        // .instantiatViewControllerWithIdentifier() returns AnyObject! this must be downcast to utilize it
        
        viewController.isAddNote = true
        viewController.user = dataController.currentLoggedInUser!
        viewController.group = dataController.currentViewedUser!
        
        self.present(viewController, animated: true, completion: nil)
        if !firstTimeAddNoteTip.isHidden {
            firstTimeAddNoteTip.isHidden = true
        }
    }
}

