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
        static let calendarBackround = Color(nsColor: .windowBackgroundColor)
        static let dayCellBackground = Color(nsColor: .controlBackgroundColor)
        static let todayAccent = Color.blue
        static let entryIndicator = Color.green
        
        // Text colors
        static let primaryText = Color.primary
        static let secondaryText = Color.secondary
        
        // Editor colors
        static let editorBackground = Color(nsColor: .textBackgroundColor)
    }
    
    struct Fonts {
        // Calendar fonts
        static let monthTitle = Font.system(.title, design: .rounded).weight(.semibold)
        static let weekdayHeader = Font.subheadline.weight(.semibold)
        static let dayNumber = Font.system(.body, design: .rounded)
        
        // Editor fonts
        static let entryDate = Font.title2
        static let entryTitle = Font.system(.title, design: .rounded)
        static let entryContent = Font.body
        static let statusBar = Font.caption
    }
    
    struct Spacing {
        // Calendar spacings
        static let calendarGridSpacing: CGFloat = 8
        static let calendarPadding: CGFloat = 12
        static let dayCellPadding: CGFloat = 8
        static let dayCellCornerRadius: CGFloat = 8
        
        // Editor spacings
        static let editorPadding: CGFloat = 16
    }
    
    struct Sizes {
        static let entryDotSize: CGFloat = 5
        static let todayBorderWidth: CGFloat = 2
        static let maxCalendarWidth: CGFloat = 800
        static let minWindowWidth: CGFloat = 600
        static let minWindowHeight: CGFloat = 500
    }
}
