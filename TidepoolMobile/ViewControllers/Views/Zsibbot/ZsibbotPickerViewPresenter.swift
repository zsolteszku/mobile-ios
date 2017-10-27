//
//  ZsibbotPickerViewPresenter.swift
//  TidepoolMobile
//
//  Created by Zsolt Essig on 22/10/2017.
//  Copyright © 2017 Tidepool. All rights reserved.
//

import UIKit

class ZsibbotPickerViewPresenter: UITextField {
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: CGRect.zero)
        inputView = pickerView
        inputAccessoryView = toolBar
    }
    
    // MARK: - Public
    
    var pickerDelegate: UIPickerViewDelegate? {
        didSet {
            pickerView.delegate = pickerDelegate
        }
    }
    
    var pickerDataSource: UIPickerViewDataSource? {
        didSet {
            pickerView.dataSource = pickerDataSource
        }
    }
    
    var doneButtonAction: (() -> Void)?
    
    var currentlySelectedRow: Int {
        return pickerView.selectedRow(inComponent: 0)
    }
    
    func selectRowAtIndex(index: Int) {
        pickerView.selectRow(index, inComponent: 0, animated: false)
    }
    
    func showPicker() {
        self.becomeFirstResponder()
    }
    
    func hidePicker() {
        self.resignFirstResponder()
    }
    
    // MARK: - Views
    
    private let pickerView = UIPickerView(frame: CGRect.zero)
    
    private lazy var toolBar: UIToolbar = {
        let res = UIToolbar()
        res.barStyle = .default
        res.isTranslucent = true
        res.tintColor = self.tintColor
        res.sizeToFit()
        
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.canceledPicker))
        
        res.setItems([cancelButton, spaceButton, doneButton], animated: false)
        res.isUserInteractionEnabled = true
        return res
    }()
    
    func donePicker() {
        doneButtonAction?();
        self.resignFirstResponder()
    }
    
    func canceledPicker() {
        self.resignFirstResponder()
    }
    
}
