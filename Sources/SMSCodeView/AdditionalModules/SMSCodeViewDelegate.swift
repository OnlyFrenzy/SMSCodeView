//
//  SMSCodeViewDelegate.swift
//  SMSCodeTextField
//
//  Created by Nikita Bruy on 09.09.2021.
//

import UIKit

public protocol SMSCodeViewDelegate: AnyObject {
    func smsCodeValueChanged(value: String?)
    func smsCodeEndEditing(_ textField: UITextField)
    func smsCodeBeginEditing(_ textField: UITextField)
}

extension SMSCodeViewDelegate {
    func smsCodeValueChanged(value: String?) {
        
    }
    
    func smsCodeEndEditing(_ textField: UITextField) {
        
    }
    
    func smsCodeBeginEditing(_ textField: UITextField) {
        
    }
}
