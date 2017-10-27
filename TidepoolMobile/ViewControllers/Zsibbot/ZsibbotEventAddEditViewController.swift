//
//  ZsibbotEventAddEditViewController.swift
//  TidepoolMobile
//
//  Created by Zsolt Essig on 25/10/2017.
//  Copyright © 2017 Tidepool. All rights reserved.
//

import Foundation
import UIKit

class ZsibbotEventAddEditViewController: EventAddEditViewController {
    
    var eventName: String {
        get {
            return "Event Type"
        }
    }
    
    static let defaultRowHeight: CGFloat = 30
    
    static let leftAnchoredLabelWidth: CGFloat = 75 - labelInset
    
    static var leftAnchoredLabelOuterWidth: CGFloat {
        return leftAnchoredLabelWidth + 2 * labelInset
    }
    
    var fullScreenWidth: CGFloat {
        return self.sceneContainerView.frame.width
    }
    
    var fullTextFieldWidth: CGFloat {
        return fullScreenWidth - 2 * labelInset
    }
    
    static var rightAnchoredTextFieldX: CGFloat {
        return leftAnchoredLabelOuterWidth
    }
    
    var rightAnchoredTextFieldWidth: CGFloat {
        return self.sceneContainerView.frame.width - ZsibbotEventAddEditViewController.leftAnchoredLabelWidth
    }
    
    func addRow(_ view: UIView) {
        self.sceneContainerView.addSubview(view)
    }
    
    func addUITextField(afterView: UIView, delegate: UITextFieldDelegate,
                           defaultText: String = "") -> UITextField {
        let textField = TidepoolMobileUITextField()
        textField.backgroundColor = lightGreyColor
        textField.font = mediumRegularFont
        
        textField.text = defaultText
        textField.textColor = Styles.blackishColor
        
        textField.frame.size = CGSize(
            width: rightAnchoredTextFieldWidth,
            height: ZsibbotEventAddEditViewController.defaultRowHeight)
        textField.frame.origin.x = ZsibbotEventAddEditViewController.rightAnchoredTextFieldX
        textField.frame.origin.y = afterView.frame.maxY + labelInset
        textField.delegate = delegate
        textField.autocapitalizationType = UITextAutocapitalizationType.sentences
        textField.autocorrectionType = UITextAutocorrectionType.yes
        textField.spellCheckingType = UITextSpellCheckingType.yes
        textField.keyboardAppearance = UIKeyboardAppearance.dark
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.default
        textField.isSecureTextEntry = false
        
        textField.usage = "eventType"
        textField.paddingLeft = 20.0
        ZsibbotViewHelper.setBorder(textField.layer)
        
        self.addRow(textField)
        return textField
    }
    
    func addLabel(afterView: UIView, text: String) -> UILabel {
        let label = TidepoolMobileUILabel()
        label.text = text
        label.font = smallRegularFont
        label.textColor = Styles.brightBlueColor
        label.sizeToFit()
        label.frame.origin.x = labelInset
        label.frame.origin.y = afterView.frame.maxY + labelInset
        label.frame.size = CGSize(
            width: ZsibbotEventAddEditViewController.leftAnchoredLabelOuterWidth,
            height: ZsibbotEventAddEditViewController.defaultRowHeight)

        label.usage = "eventType"
        self.addRow(label)
        return label
    }
    
    override func configureTitleView() {
        self.navItem.title = isAddNote ? "Add \(eventName)" : "Edit \(eventName)"
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
        let messageBoxW = fullTextFieldWidth
        let messageBoxH = (postButtonFrame.minY - lastSubView.frame.maxY) - 2 * labelInset
        messageBox.frame.size = CGSize(width: messageBoxW, height: messageBoxH)
        
        messageBox.frame.origin.x = labelInset
        messageBox.frame.origin.y = lastSubView.frame.maxY + labelInset
    }
    
    override func viewDidLayoutSubviews() {
        if(subviewsInitialized) {
            return
        }
                
        super.viewDidLayoutSubviews()
        
        removeHashTagScrollView()
        
        recalcMessageBox(lastSubView: separatorOne)
        
        messageBox.isEditable = false
    }
}
