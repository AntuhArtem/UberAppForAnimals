//
//  RoundedButtons.swift
//  Uber App For Driver
//
//  Created by Artem Antuh on 9/2/18.
//  Copyright © 2018 Artem Antuh. All rights reserved.
//

import UIKit
@IBDesignable
class RoundedButtons: UIButton {
    
    @IBInspectable var roundedButtons: Bool = false{
        didSet {
            if roundedButtons{
                layer.cornerRadius = frame.height / 2
            }
        }
    }
    
    override func prepareForInterfaceBuilder() {
        if roundedButtons{
            layer.cornerRadius = frame.height / 2
        }
    }
    
}
