//
//  DesignSystem.swift
//  FMEAR
//
//  Created by Angus Lau on 2020-07-07.
//  Copyright © 2020 Safe Software Inc. All rights reserved.
//

import Foundation
import UIKit

// liz. v.2.1
// safecom design system
// https://www.safe.com/liz/
struct DesignSystem {
    
    struct Colour {
        
        struct CorePalette {
            static let orange = UIColor(hex: 0xF36C00)
            static let blue = UIColor(hex: 0x0153D1)
        }
        
        struct ExtendedPalette {
            static let orangeDark20  = UIColor(hex: 0x8D3F00)
            static let orangeDark10  = UIColor(hex: 0xC05500)
            static let orange        = CorePalette.orange
            static let orangeLight10 = UIColor(hex: 0xFF8727)
            static let orangeLight20 = UIColor(hex: 0xFFA35A)
            static let orangeLight30 = UIColor(hex: 0xFFC08D)
            static let orangeLight40 = UIColor(hex: 0xFFDCC0)
            static let orangeLight50 = UIColor(hex: 0xFFF8F3)
            
            static let blueDark20    = UIColor(hex: 0x0002A6)
            static let blueDark10    = UIColor(hex: 0x013F9E)
            static let blue          = CorePalette.blue
            static let blueLight10   = UIColor(hex: 0x0768FE)
            static let blueLight20   = UIColor(hex: 0x3A87FE)
            static let blueLight30   = UIColor(hex: 0x6DA6FE)
            static let blueLight40   = UIColor(hex: 0x9FC5FF)
            static let blueLight50   = UIColor(hex: 0xD2E4FF)
            static let blueLight60   = UIColor(hex: 0xF6F9FF)
        }
        
        struct SemanticPalette {
            static let redDark20  = UIColor(hex: 0x870400)
            static let redDark10  = UIColor(hex: 0xBA0500)
            static let red        = UIColor(hex: 0xED0700)
            static let redLight10 = UIColor(hex: 0xFF2821)
            static let redLight20 = UIColor(hex: 0xFF5954)
            static let redLight30 = UIColor(hex: 0xFF8B87)
            static let redLight40 = UIColor(hex: 0xFFBCBA)
            static let redLight50 = UIColor(hex: 0xFFEEED)
            
            static let greenDark20  = UIColor(hex: 0x125428)
            static let greenDark10  = UIColor(hex: 0x1C7D3D)
            static let green        = UIColor(hex: 0x25A751)
            static let greenLight10 = UIColor(hex: 0x2ED165)
            static let greenLight20 = UIColor(hex: 0x58DA84)
            static let greenLight30 = UIColor(hex: 0x82E3A3)
            static let greenLight40 = UIColor(hex: 0xABEDC1)
            static let greenLight50 = UIColor(hex: 0xD5F6E0)
            
            static let yellowDark20  = UIColor(hex: 0x997800)
            static let yellowDark10  = UIColor(hex: 0xCCA000)
            static let yellow        = UIColor(hex: 0xFFC800)
            static let yellowLight20 = UIColor(hex: 0xFFD333)
            static let yellowLight30 = UIColor(hex: 0xFFDE66)
            static let yellowLight40 = UIColor(hex: 0xFFE999)
            static let yellowLight50 = UIColor(hex: 0xFFF4CC)
            
            static let mayaBlueDark60  = UIColor(hex: 0x00141C)
            static let mayaBlueDark50  = UIColor(hex: 0x00394F)
            static let mayaBlueDark40  = UIColor(hex: 0x005D82)
            static let mayaBlueDark30  = UIColor(hex: 0x0082B5)
            static let mayaBlueDark20  = UIColor(hex: 0x00A6E8)
            static let mayaBlueDark10  = UIColor(hex: 0x1CBFFF)
            static let mayaBlue        = UIColor(hex: 0x4FCDFF)
            static let mayaBlueLight30 = UIColor(hex: 0x82DBFF)
            static let mayaBlueLight40 = UIColor(hex: 0xB5EAFF)
            static let mayaBlueLight50 = UIColor(hex: 0xE8F8FF)
        }
        
        struct NeutralPalette {
            static let offWhite = UIColor(hex: 0xF5F5F5)
            static let white    = UIColor(hex: 0xFFFFFF)
            
            static let grey        = UIColor(hex: 0x333333)
            static let greyLight10 = UIColor(hex: 0x4D4D4D)
            static let greyLight20 = UIColor(hex: 0x666666)
            static let greyLight30 = UIColor(hex: 0x808080)
            static let greyLight40 = UIColor(hex: 0x999999)
            static let greyLight50 = UIColor(hex: 0xB3B3B3)
            static let greyLight60 = UIColor(hex: 0xCCCCCC)
            static let greyLight70 = UIColor(hex: 0xE0E0E0)
            static let greyLight80 = UIColor(hex: 0xEBEBEB)
            
            static let black    = UIColor(hex: 0x000000)
            static let offBlack = UIColor(hex: 0x1A1A1A)
        }
        
        struct SecondaryPalette {
            static let blueGreyDark20  = UIColor(hex: 0x14191E)
            static let blueGreyDark10  = UIColor(hex: 0x28333D)
            static let blueGrey        = UIColor(hex: 0x3C4D5C)
            static let blueGreyLight10 = UIColor(hex: 0x050677)
            static let blueGreyLight20 = UIColor(hex: 0x64819A)
            static let blueGreyLight30 = UIColor(hex: 0x839AAE)
            static let blueGreyLight40 = UIColor(hex: 0xA2B3C2)
            static let blueGreyLight50 = UIColor(hex: 0xC1CCD6)
            static let blueGreyLight60 = UIColor(hex: 0xE0E5EA)
            static let blueGreyLight70 = UIColor(hex: 0xFEFEFF)
            
            static let infraRedDark60  = UIColor(hex: 0x040001)
            static let infraRedDark50  = UIColor(hex: 0x33040F)
            static let infraRedDark40  = UIColor(hex: 0x61081E)
            static let infraRedDark30  = UIColor(hex: 0x900D2C)
            static let infraRedDark20  = UIColor(hex: 0xBF113A)
            static let infraRedDark10  = UIColor(hex: 0xEB184A)
            static let infraRed        = UIColor(hex: 0xEF476F)
            static let infraRedLight30 = UIColor(hex: 0xF37694)
            static let infraRedLight40 = UIColor(hex: 0xF37694)
            static let infraRedLight50 = UIColor(hex: 0xFBD4DD)
            
            static let brownDark50  = UIColor(hex: 0x160C07)
            static let brownDark40  = UIColor(hex: 0x160C07)
            static let brownDark30  = UIColor(hex: 0x613622)
            static let brownDark20  = UIColor(hex: 0x874C2F)
            static let brownDark10  = UIColor(hex: 0xAD613C)
            static let brown        = UIColor(hex: 0xC57B57)
            static let brownLight10 = UIColor(hex: 0xD2997D)
            static let brownLight30 = UIColor(hex: 0xDFB7A3)
            static let brownLight40 = UIColor(hex: 0xECD4C9)
            static let brownLight50 = UIColor(hex: 0xF9F2EF)
            
            static let purpleDark30  = UIColor(hex: 0x28074D)
            static let purpleDark20  = UIColor(hex: 0x410C7B)
            static let purpleDark10  = UIColor(hex: 0x5910AA)
            static let purple        = UIColor(hex: 0x7215D8)
            static let purpleLight10 = UIColor(hex: 0x8C35EB)
            static let purpleLight20 = UIColor(hex: 0xA663F0)
            static let purpleLight30 = UIColor(hex: 0xC192F4)
            static let purpleLight40 = UIColor(hex: 0xDBC0F9)
            static let purpleLight50 = UIColor(hex: 0xF6EFFD)
        }
    }
}
