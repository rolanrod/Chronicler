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
    @State private var selectedDate: Date?
    @State private var showingEditor = false
    
    private let calendar: Calendar = Calendar.current
    private let columns: Array = Array(repeating: GridItem(.flexible(), spacing: Theme.Spacing.calendarGridSpacing), count: 7)
    
    var body: some View {
        GeometryReader { geometry in
            if !showingEditor {
                ScrollView {
                    VStack(spacing: 0) {
                        HStack {
                            Button(action: previousMonth) {
                                Image(systemName: "chevron.left").font(.title2)
                            }.buttonStyle(.plain)
                            Spacer()
                            Text(monthYearString).font(Theme.Fonts.monthTitle).fontWeight(.semibold)
                            Spacer()
                            Button(action: nextMonth) {
                                Image(systemName: "chevron.right").font(.title2)
                            }.buttonStyle(.plain)
                        }.padding(.horizontal).padding(.vertical, 12)
                        
                        Divider()
                        
                        LazyVGrid(columns: columns, spacing: 0) {
                            ForEach(weekdaySymbols, id: \.self) { symbol in
                                Text(symbol)
                                    .font(Theme.Fonts.weekdayHeader)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Theme.Colors.secondaryText)
                                    .frame(height: 50)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 6)
                        
                        LazyVGrid(columns: columns, spacing: Theme.Spacing.calendarGridSpacing) {
                            ForEach(daysInMonth, id: \.self) { date in
                                if let date = date {
                                    DayCell(
                                        date: date,
                                        isSelected: false,
                                        hasEntry: hasEntry(for: date),
                                        isToday: calendar.isDateInToday(date),
                                        isWeekend: calendar.isDateInWeekend(date),
                                        isInCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
                                    )
                                    .frame(height: 80)
                                    .onTapGesture {
                                        selectedDate = date
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                            showingEditor = true
                                        }
                                    }
                                } else {
                                    Color.clear
                                        .frame(height: 100)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                }.background(Theme.Colors.calendarBackground)
            }
        }
        .overlay {
            if showingEditor, let date = selectedDate {
                EntryEditorView(date: date, onDismiss: {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        showingEditor = false
                    }
                })
                .environmentObject(store)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.9, anchor: .center).combined(with: .opacity),
                    removal: .scale(scale: 0.9, anchor: .center).combined(with: .opacity)
                ))
            }
        }.frame(minWidth: Theme.Sizes.minWindowWidth, minHeight: Theme.Sizes.minWindowHeight)
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
            days.append(currentDate)
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
    let isWeekend: Bool
    let isInCurrentMonth: Bool
    
    @State private var isPressed = false;
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Theme.Spacing.dayCellCornerRadius)
                .fill(isWeekend ? Theme.Colors.weekendBackground : Theme.Colors.weekdayBackground)
                .overlay(
                    Rectangle()
                        .strokeBorder(Color.gray.opacity(0.2), lineWidth: 0.5)
                )
            
            ZStack {
                Text(dayNumber)
                    .font(.system(.title2, design: .serif))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .foregroundColor(
                        isToday ? Theme.Colors.todayAccent :
                        !isInCurrentMonth ? Theme.Colors.secondaryText.opacity(0.4) :
                        (isWeekend ? Theme.Colors.secondaryText : Theme.Colors.primaryText)
                    )
                
                if hasEntry {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "bookmark.fill")
                                .font(.system(size: 18))
                                .foregroundColor(Theme.Colors.entryIndicator)
                                .padding(-4)
                        }
                        Spacer()
                    }
                }
            }
            .padding(Theme.Spacing.dayCellPadding)
            
            if isToday {
                RoundedRectangle(cornerRadius: Theme.Spacing.dayCellCornerRadius)
                    .strokeBorder(Theme.Colors.todayAccent, lineWidth: Theme.Sizes.todayBorderWidth)
            }
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    CalendarView()
        .environmentObject(JournalStore())
        .frame(width: 900, height: 700)
}
