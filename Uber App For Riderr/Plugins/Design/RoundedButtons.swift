//
//  RoundedButtons.swift
//  Uber App For Rider
//
//  Created by Artem Antuh on 8/24/18.
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
