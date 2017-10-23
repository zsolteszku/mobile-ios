//
//  ZsibbotNSObject.swift
//  TidepoolMobile
//
//  Created by Zsolt Essig on 22/10/2017.
//  Copyright © 2017 Tidepool. All rights reserved.
//

import Foundation

extension NSObject {
    
    func getStoredProperty<T>(_ key: UnsafeRawPointer) -> T? {
        return objc_getAssociatedObject(self, key) as? T
    }
    
    func getStoredProperty<T>(_ key: UnsafeRawPointer, _ defaultValueCreator: @escaping()-> T) -> T {
        var val: T? = getStoredProperty(key)
        if val == nil {
            val = defaultValueCreator()
            setStoredProperty(key, newValue: val)
        }
        return val!
    }
    
    func setStoredProperty<T>(_ key: UnsafeRawPointer, newValue: T) {
        objc_setAssociatedObject(self, key, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
