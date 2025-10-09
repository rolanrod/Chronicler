//
//  Theme.swift
//  Chronicler
//
//  Created by Rolando on 10/1/25.
//

import SwiftUI

struct Theme {
    struct Colors {
        // Calendar colors
        static let calendarBackground = LinearGradient(
            colors: [Color(hex: "513B56"), Color(hex: "8D6B94")],
            startPoint: .top,
            endPoint: .bottom
        )
        
        static let weekdayBackground = Color(nsColor: .controlBackgroundColor)
        static let weekendBackground = Color(hex: "424242")
        static let todayAccent = Color.white
        static let entryIndicator = Color(hex: "8D6B94")
        static let buttonAccent = Color(hex: "8D6B94")
        
        // Text colors
        static let primaryText = Color.primary
        static let secondaryText = Color.secondary
        
        // Editor colors
        static let editorBackground = Color(nsColor: .textBackgroundColor)
    }
    
    struct Fonts {
        // Base font styles
        private static let serifDesign: Font.Design = .serif
        private static let roundedDesign: Font.Design = .rounded
        private static let defaultDesign: Font.Design = .default
        
        // Calendar fonts
        static let monthTitle = Font.system(.title, design: .serif).weight(.semibold)
        static let weekdayHeader = Font.system(.title2, design: .serif).weight(.bold)
        static let dayNumber = Font.system(.title, design: .serif)
        
        // Editor fonts
        static let entryDate = Font.system(.title2, design: serifDesign)
        static let entryTitle = Font.system(.title, design: serifDesign)
        static let entrySong = Font.system(.title3, design: serifDesign)
        static let entryContent = Font.system(.body, design: serifDesign)
        static let statusBar = Font.system(.caption, design: defaultDesign)

    }
    
    struct Spacing {
        // Calendar spacings
        static let calendarGridSpacing: CGFloat = 0
        static let calendarPadding: CGFloat = 12
        static let dayCellPadding: CGFloat = 8
        static let dayCellCornerRadius: CGFloat = 0
        
        // Editor spacings
        static let editorPadding: CGFloat = 16
    }
    
    struct Sizes {
        static let todayBorderWidth: CGFloat = 2
        static let maxCalendarWidth: CGFloat = 800
        static let minWindowWidth: CGFloat = 600
        static let minWindowHeight: CGFloat = 500
    }
}
