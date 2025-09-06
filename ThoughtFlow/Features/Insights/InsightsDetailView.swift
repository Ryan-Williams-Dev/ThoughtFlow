//
//  InsightsDetailView.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-08-26.
//

import SwiftUI

struct InsightsDetailView: View {
    let insights: Insights
    let insightsService: InsightsService?
    
    init(insights: Insights, insightsService: InsightsService? = nil) {
        self.insights = insights
        self.insightsService = insightsService
    }
    
    var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Date Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text(insights.date.formatted(.dateTime.weekday(.wide)))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Text(insights.date.formatted(.dateTime
                            .month(.wide)
                            .day()
                            .year()
                        ))
                        .font(.title2)
                        .fontWeight(.semibold)
                    }
                    
                    Divider()
                    
                    // Content
                    if let text = insights.text, !text.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Label("Daily Insights", systemImage: "lightbulb")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            
                            if let attributedString = insightsService?.convertRTFToAttributedString(text) {
                                Text(attributedString)
                                    .font(.body)
                                    .lineSpacing(4)
                                    .textSelection(.enabled)
                            } else {
                                Text(text)
                                    .font(.body)
                                    .lineSpacing(4)
                                    .textSelection(.enabled)
                            }
                        }
                    } else {
                        // Empty State
                        VStack(spacing: 12) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 40))
                                .foregroundStyle(.tertiary)
                            
                            Text("No Insights Yet")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            
                            Text("Insights will appear here once they're generated for this day.")
                                .font(.subheadline)
                                .foregroundStyle(.tertiary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 40)
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .background(Color(.systemGroupedBackground))
        }
}

#Preview {
    InsightsDetailView(insights: Insights.mockDay)
}
