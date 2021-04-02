//
//  CheckBoxButton.swift
//  NotForgot
//
//  Created by administrator on 02.04.2021.
//  Copyright © 2021 administrator. All rights reserved.
//

import Foundation
import UIKit

class CheckBoxButton: UIButton {

    // Images
    let checkedImage = UIImage(named: "checked")! as UIImage
    let uncheckedImage = UIImage(named: "uncheked")! as UIImage

    // Bool property
    var isChecked: Bool = false {
        didSet{
            if isChecked == true {
                self.setImage(uncheckedImage, for: .normal)
            } else {
                self.setImage(checkedImage, for: .normal)
            }
        }
    }

    override func awakeFromNib() {
        self.isUserInteractionEnabled = false
//        self.addTarget(self, action: #selector(CheckBoxButton.buttonClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
//        self.isChecked = false
    }

    func buttonClicked(sender: UIButton) {
        if sender == self {
            if isChecked == true {
                isChecked = false
            } else {
                isChecked = true
            }
        }
    }

}
