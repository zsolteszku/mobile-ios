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
        inputAccessoryView = pickerInputAccessoryView
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
    
    var selectButtonAction: (() -> Void)?
    
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
    
    private lazy var pickerInputAccessoryView: UIView = {
        let frame = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 48.0)
        let pickerInputAccessoryView = UIView(frame: frame)
        
        // Customize the view here
        
        return pickerInputAccessoryView
    }()
    
    func selectButtonPressed(sender: UIButton) {
        selectButtonAction?()
    }
    
}
