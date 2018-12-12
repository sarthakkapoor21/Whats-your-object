//
//  RoundShadowImage.swift
//  Vision Dev
//
//  Created by Sarthak Kapoor on 08/10/17.
//  Copyright © 2017 SK21. All rights reserved.
//

import UIKit

class RoundShadowImage: UIImageView {
    
    override func awakeFromNib() {
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowRadius = 10.0
        layer.shadowOpacity = 0.9
        layer.cornerRadius = 5
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
