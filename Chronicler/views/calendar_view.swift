//
//  calendar_view.swift
//  Chronicler
//
//  Created by Rolando on 9/30/25.
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var store: JournalStore
    @State private var currentMonth: Date = Date()
    
    private let calendar: Calendar = Calendar.current
    private let columns: Array = Array(repeating: GridItem(.flexible(), spacing: Theme.Spacing.calendarGridSpacing), count: 7)
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    HStack {
                        Button(action: previousMonth) {
                            Image(systemName: "chevron.left").font(Theme.Fonts.monthTitle)
                        }.buttonStyle(.plain)
                        Spacer()
                        Text(monthYearString).font(.title2).fontWeight(.semibold)
                        Spacer()
                        Button(action: nextMonth) {
                            Image(systemName: "chevron.right").font(.title2)
                        }.buttonStyle(.plain)
                    }.padding(.horizontal).padding(.vertical, 12)
                    
                    Divider()
                    
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(weekdaySymbols, id: \.self) { symbol in
                                Text(symbol)
                                .font(Theme.Fonts.weekdayHeader)
                                .fontWeight(.semibold)
                                .foregroundColor(Theme.Colors.secondaryText)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .aspectRatio(1, contentMode: .fit)
                        }
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: min(geometry.size.width * 0.9, Theme.Sizes.maxCalendarWidth))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    
                    LazyVGrid(columns: columns, spacing: Theme.Spacing.calendarGridSpacing) {
                        ForEach(daysInMonth, id: \.self) { date in
                            if let date = date {
                                NavigationLink(value: date) {
                                    DayCell(
                                        date: date,
                                        isSelected: false,
                                        hasEntry: hasEntry(for: date),
                                        isToday: calendar.isDateInToday(date)
                                    )
                                }
                                .buttonStyle(.plain)
                            } else {
                                Color.clear
                                    .aspectRatio(1, contentMode: .fit)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: min(geometry.size.width * 0.9, Theme.Sizes.maxCalendarWidth))
                    .frame(maxWidth: .infinity)
                    
                    Spacer()
                }
            }
        }
        .navigationDestination(for: Date.self) { date in
            EntryEditorView(date: date).environmentObject(store)
        }.navigationTitle("Chronicler").frame(minWidth: Theme.Sizes.minWindowWidth, minHeight: Theme.Sizes.minWindowHeight)
    }
    
    private func previousMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    private func nextMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    private var weekdaySymbols: [String] { calendar.shortWeekdaySymbols }
    
    private var daysInMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }
        
        var days: [Date?] = []
        var currentDate = monthFirstWeek.start
        
        for _ in 0..<42 {
            if calendar.isDate(currentDate, equalTo: currentMonth, toGranularity: .month) {
                days.append(currentDate)
            } else {
                days.append(nil)
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return days
    }
    
    private func hasEntry(for date: Date) -> Bool {
        store.entries.contains { entry in
            calendar.isDate(entry.createdAt, inSameDayAs: date)}
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let hasEntry: Bool
    let isToday: Bool
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Theme.Spacing.dayCellCornerRadius)
                .fill(Theme.Colors.dayCellBackground)
            
            VStack(spacing: 4) {
                Text(dayNumber)
                    .font(Theme.Fonts.dayNumber)
                    .fontWeight(isToday ? .bold : .medium)
                    .foregroundColor(isToday ? Theme.Colors.todayAccent : Theme.Colors.primaryText)
                if hasEntry {
                    Circle()
                        .fill(Theme.Colors.entryIndicator)
                        .frame(width: Theme.Sizes.entryDotSize, height: Theme.Sizes.entryDotSize)                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: Theme.Sizes.entryDotSize, height: Theme.Sizes.entryDotSize)
                }
            }
            .padding(Theme.Spacing.dayCellPadding)
            
            if isToday {
                RoundedRectangle(cornerRadius: Theme.Spacing.dayCellCornerRadius)
                    .strokeBorder(Theme.Colors.todayAccent, lineWidth: Theme.Sizes.todayBorderWidth)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    CalendarView()
        .environmentObject(JournalStore())
        .frame(width: 900, height: 700)
}
