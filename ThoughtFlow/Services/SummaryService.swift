//
//  Summary.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-07-28.
//

import Foundation

@available(iOS 15.0, *)
class SummaryService: SummaryServiceProtocol {
    private let noteRepository: NoteRepository
    private let openAIKey: String

    init(noteRepository: NoteRepository, openAIKey: String) {
        self.noteRepository = noteRepository
        self.openAIKey = openAIKey
    }

    func summarizeNotes(for date: Date) async throws -> String {
        let allNotes = try noteRepository.fetchAllNotes()

        let startOfDay = Calendar.current.startOfDay(for: date)
        guard let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) else {
            throw NSError(domain: "SummaryService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid date range"])
        }

        let notesForDay = allNotes.filter { $0.createdAt >= startOfDay && $0.createdAt < endOfDay }

        guard !notesForDay.isEmpty else {
            return "No notes for this day."
        }

        let texts = notesForDay.map { $0.text }

        return try await callOpenAISummarization(with: texts)
    }

    private func callOpenAISummarization(with transcripts: [String]) async throws -> String {
        let joinedText = transcripts.joined(separator: "\n\n")
        let prompt = """
        You're a helpful assistant reviewing a series of raw thought dumps from a user.

        Your job is to:
        1. Extract and summarize the key ideas and recurring themes.
        2. Identify any actionable items, tasks, or follow-ups implied.
        3. Highlight any emotional patterns or repeated self-talk worth reflecting on.
        4. Present your findings in an organized, calming, helpful format.

        Here is today's transcript:

        \(joinedText)

        ---
        Return your response using this format:

        ### 🧩 Key Themes

        ...

        ### ✅ Suggested Tasks

        ...

        ### 🔁 Repeated Thoughts

        ...

        ### 🧘🏼 Insights to Reflect On

        ...
        """

        let messages = [
            OpenAIMessage(role: "system", content: "You are a helpful assistant."),
            OpenAIMessage(role: "user", content: prompt)
        ]

        let requestBody = OpenAIChatRequest(
            model: "gpt-4-1106-preview",
            messages: messages,
            temperature: 0.3
        )

        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            throw NSError(domain: "SummaryService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(openAIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        // Optional: check status code
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            throw NSError(domain: "SummaryService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP error \(httpResponse.statusCode)"])
        }

        let decoded = try JSONDecoder().decode(OpenAIChatResponse.self, from: data)
        guard let summary = decoded.choices.first?.message.content else {
            throw NSError(domain: "SummaryService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Empty response from API"])
        }

        return summary
    }
}

struct OpenAIMessage: Codable {
    let role: String
    let content: String
}

struct OpenAIChatRequest: Codable {
    let model: String
    let messages: [OpenAIMessage]
    let temperature: Double
}

struct OpenAIChatResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let role: String
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
}
