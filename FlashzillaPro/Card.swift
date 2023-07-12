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
    let statement: String
    
    static let example = Card(id: UUID(), prompt: "Who played the 13th Doctor in Doctor Who?", answer: "Jordie Whittaker", statement: "A Statement can be as alooo ooong as this one and again it can go on and on and on")
}
