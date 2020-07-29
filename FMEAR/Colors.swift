//
//  Colors.swift
//  FMEAR
//
//  Created by Angus Lau on 2020-07-29.
//  Copyright © 2020 Safe Software Inc. All rights reserved.
//

import Foundation
import UIKit

struct Colors {
    
    static let primaryText = UIColor(named: "label") ?? DesignSystem.Colour.NeutralPalette.offBlack
    static let secondaryText = UIColor(named: "secondaryLabel") ?? DesignSystem.Colour.NeutralPalette.greyLight20
    static let labelFill = UIColor(named: "labelFill") ?? DesignSystem.Colour.NeutralPalette.offWhite.withAlphaComponent(0.95)
    static let labelBorder = UIColor(named: "labelBorder") ?? UIColor.clear
    static let callToActionFill = UIColor(named: "callToActionFill") ?? DesignSystem.Colour.ExtendedPalette.orangeLight20.withAlphaComponent(0.5)
    static let callToActionStroke = UIColor(named: "callToActionStroke") ?? DesignSystem.Colour.ExtendedPalette.orange
}
