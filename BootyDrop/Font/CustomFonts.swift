//
//  CustomFonts.swift
//  BootyDrop
//
//  Created by Kevin Green on 7/26/24.
//

import UIKit

struct CustomFont {
    
    static var rum = "TheRumIsGone"
    
    static var theRumIsGone: UIFont {
        guard let customFont = UIFont(name: "TheRumIsGone", size: UIFont.labelFontSize) else {
            fatalError("""
        Failed to load the "TheRumIsGone" font.
        Make sure the font file is included in the project and the font name is spelled correctly.
        """
            )
        }
        return customFont
    }
    
    
    
    
}

