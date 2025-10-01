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
//    @State private var selectedDate: Date?
    
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(monthYearString).font(.title2).fontWeight(.semibold)
                Spacer()
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                }
            }.padding()
            
            Divider()
            
            HStack(spacing: 0) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 8)
            
            LazyVGrid(columns: columns, spacing: 0) {
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
                        // Padding
                        Color.clear
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
            Spacer()
        }
        .navigationDestination(for: Date.self) { date in
            EntryEditorView(date: date).environmentObject(store)
        }.navigationTitle("Chronicler").frame(minWidth: 800, minHeight: 600)
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
    
    private var weekdaySymbols: [String] {
        calendar.veryShortWeekdaySymbols
    }
    
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
        VStack {
            Text(dayNumber)
                .font(.body)
                .fontWeight(isToday ? .bold : .regular)
                .foregroundColor(isSelected ? .white : (isToday ? .blue : .primary))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .background(
                    Circle().fill(isSelected ? Color.blue : Color.clear)
                )
                .overlay(
                    Circle()
                    .strokeBorder(isToday && !isSelected ? Color.blue : Color.clear, lineWidth: 2)
                )
                .overlay(
                    Circle()
                        .fill(hasEntry && !isSelected ? Color.green : Color.clear)
                        .frame(width: 6, height: 6)
                        .offset(y: 20)
                )
        }.padding(4)
    }
}

#Preview {
    CalendarView()
        .environmentObject(JournalStore())
        .frame(width: 900, height: 700)
}
