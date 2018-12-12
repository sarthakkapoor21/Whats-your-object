//
//  RoundShadowView.swift
//  Vision Dev
//
//  Created by Sarthak Kapoor on 07/10/17.
//  Copyright © 2017 SK21. All rights reserved.
//

import UIKit

class RoundShadowView: UIView {
    
    override func awakeFromNib() {
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowRadius = 10.0
        layer.shadowOpacity = 0.9
        layer.cornerRadius = frame.height / 2
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
