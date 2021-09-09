//
//  CursorView.swift
//  SMSCodeTextField
//
//  Created by Nikita Bruy on 09.09.2021.
//

import UIKit

class CursorView: UIView {
    
    func setColor(_ color: UIColor?) {
        self.backgroundColor = color
    }
    
    func enableAnimation() {
        DispatchQueue.main.async {
            Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { _ in
                self.isHidden.toggle()
            }
        }
    }
}
