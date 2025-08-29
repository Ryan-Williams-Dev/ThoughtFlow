//
//  InsightsListView.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-07-18.
//

import SwiftUI

struct InsightsListView: View {
    @StateObject var vm: InsightsViewModel
    @State private var expandedMonths: Set<String> = []
    
    init(vm: InsightsViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        NavigationSplitView {
            List(selection: $vm.selectedDay) {
                ForEach(groupDaysByMonth(days: vm.days), id: \.id) { monthSection in
                    DisclosureGroup(
                        monthSection.displayName,
                        isExpanded: Binding(
                            get: { expandedMonths.contains(monthSection.id) },
                            set: { isExpanded in
                                if isExpanded {
                                    expandedMonths.insert(monthSection.id)
                                } else {
                                    expandedMonths.remove(monthSection.id)
                                }
                            }
                        )
                    ) {
                        ForEach(monthSection.days, id: \.self) { day in
                            Text(formatDayDisplay(date: day.date))
                                .tag(day)
                        }
                    }
                }
            }
            .navigationTitle("Insights")
            .toolbar {
                Button("Generate Insights") {
                    print("Generating Insights")
                }
            }
            .onAppear {
                // Auto-expand the most recent month
                if let mostRecentMonth = groupDaysByMonth(days: vm.days).first {
                    expandedMonths.insert(mostRecentMonth.id)
                }
            }
        } detail: {
            Group {
                if let day = vm.selectedDay {
                    InsightsDetailView(insights: day)
                } else {
                    ContentUnavailableView("Select a Day", systemImage: "note.text")
                }
            }
        }
    }
}

struct MonthSection: Identifiable {
    let id: String
    let year: Int
    let month: Int
    let displayName: String
    var days: [Insights]
}

func groupDaysByMonth(days: [Insights]) -> [MonthSection] {
    let calendar = Calendar.current
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM yyyy" // e.g., "August 2025"
    
    // Group days by year and month combination
    let groupedByYearMonth = Dictionary(grouping: days) { day in
        let year = calendar.component(.year, from: day.date)
        let month = calendar.component(.month, from: day.date)
        return "\(year)-\(month)"
    }
    
    let monthSections = groupedByYearMonth.map { (yearMonthKey, daysInMonth) in
        // Get year and month from the first day in this group
        let firstDay = daysInMonth.first!
        let year = calendar.component(.year, from: firstDay.date)
        let month = calendar.component(.month, from: firstDay.date)
        
        // Sort days within month (most recent first)
        let sortedDays = daysInMonth.sorted { $0.date > $1.date }
        
        return MonthSection(
            id: yearMonthKey,
            year: year,
            month: month,
            displayName: dateFormatter.string(from: firstDay.date),
            days: sortedDays
        )
    }
    
    // Sort months by date (most recent first)
    return monthSections.sorted { section1, section2 in
        if section1.year != section2.year {
            return section1.year > section2.year
        }
        return section1.month > section2.month
    }
}

func formatDayDisplay(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "d - EEEE" // e.g., "31, Wednesday"
    return formatter.string(from: date)
}

//
//#Preview {
//    // Supply a working NoteRepository instance here
//    // InsightsListView(vm: InsightsViewModel(noteRepository: NoteRepository(modelContext: /* Your model context here */)))
//}
