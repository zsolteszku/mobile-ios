/*
* Copyright (c) 2015, Tidepool Project
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

//
//  Extension to format the dates consistently through the application.
//

import UIKit

// TODO: change this file to return strings useful for nutshell...
// ------------ Date Formatter ------------

/*
Commonly used date formats
Careful with changing iso8601 date formats
Uniform date format will change NoteCell and Add/EditNoteVCs
Regular date format for birthdays, diagnosis date, etc.
*/

let uniformDateFormat: String = "MMM d, yyyy    h:mm a"
let iso8601dateOne: String = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
let iso8601dateTwo: String = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
let regularDateFormat: String = "yyyy-MM-dd"

let smallRegularFont: UIFont = UIFont(name: "OpenSans", size: 12.5)!
let smallBoldFont: UIFont = UIFont(name: "OpenSans-Bold", size: 12.5)!
let noteTextColor: UIColor = UIColor.blackColor()

public extension NSDateFormatter {

    
    func attributedStringFromDate(date: NSDate) -> NSMutableAttributedString {
        // Date format being used.
        self.dateFormat = uniformDateFormat
        var dateString = self.stringFromDate(date)
        
        // Replace uppercase PM and AM with lowercase versions
        dateString = dateString.stringByReplacingOccurrencesOfString("PM", withString: "pm", options: NSStringCompareOptions.LiteralSearch, range: nil)
        dateString = dateString.stringByReplacingOccurrencesOfString("AM", withString: "am", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        let attrStr = NSMutableAttributedString(string: dateString, attributes: [NSForegroundColorAttributeName: noteTextColor, NSFontAttributeName: smallRegularFont])
        
        return attrStr
    }
    
    func dateFromISOString(string: String) -> NSDate {
        self.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        self.timeZone = NSTimeZone.localTimeZone()
        self.dateFormat = iso8601dateOne
        if let date = self.dateFromString(string) {
            return date
        } else {
            self.dateFormat = iso8601dateTwo
            return self.dateFromString(string)!
        }
    }
    
    func isoStringFromDate(date: NSDate, zone: NSTimeZone?) -> String {
        self.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        if (zone != nil) {
            self.timeZone = zone
        } else {
            self.timeZone = NSTimeZone.localTimeZone()
        }
        self.dateFormat = iso8601dateOne
        return self.stringFromDate(date)
    }
    
    func stringFromRegDate(date:NSDate) -> String {
        self.dateFormat = regularDateFormat
        return stringFromDate(date)
    }
    
}