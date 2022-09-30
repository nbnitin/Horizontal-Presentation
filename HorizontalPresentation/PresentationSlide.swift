//
//  Slide.swift
//  HorizontalPresentation
//
//  Created by Nitin Bhatia on 05/09/22.
//

import UIKit

class PresentationSlide: UIView {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var lblSubTitle: UILabel!
}


struct Slide {
    let title : String!
    let subTitle : String!
}
