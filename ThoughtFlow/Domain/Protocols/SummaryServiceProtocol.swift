//
//  Summary.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-07-28.
//

import Foundation

@available(iOS 15.0, *)
protocol SummaryServiceProtocol {
    func summarizeNotes(for date: Date) async throws -> String
}
