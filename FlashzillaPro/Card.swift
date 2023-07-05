//
//  Card.swift
//  FlashzillaPro
//
//  Created by Rishav Gupta on 04/07/23.
//

import Foundation

struct Card: Codable, Identifiable {
    let id: UUID
    let prompt: String
    let answer: String
    
    static let example = Card(id: UUID(), prompt: "Who played the 13th Doctor in Doctor Who?", answer: "Jordie Whittaker")
}
