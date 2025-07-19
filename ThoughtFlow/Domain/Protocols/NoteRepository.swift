//
//  NoteRepository.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-07-19.
//

protocol NoteRepositoryProtocol {
    func save(note: Note) throws
    func delete(note: Note) throws
    func insert(note: Note) throws -> Note
    func fetchAllNotes() throws -> [Note]
}
