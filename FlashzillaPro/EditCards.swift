//
//  EditCards.swift
//  FlashzillaPro
//
//  Created by Rishav Gupta on 05/07/23.
//

import SwiftUI

struct EditCards: View {
    @Environment(\.dismiss) var dismiss
    @State private var cards = [Card]()
    @State private var newPrompt = ""
    @State private var newAnswer = ""
    @State private var newStatement = ""
    
    var body: some View {
        NavigationView {
            List {
                Section("Add new card") {
                    TextField("New Word", text: $newPrompt)
                    TextField("Meaning", text: $newAnswer)
                    TextField("Statement", text: $newStatement)
                    Button("Add Card", action: addCard)
                }
                
                Section {
                    ForEach(0..<cards.count, id: \.self) { index in
                        VStack(alignment: .leading) {
                            Text(cards[index].prompt)
                                .font(.headline)
                            
                            Text(cards[index].answer)
                                .bold()
                                .foregroundColor(.secondary)
                            
                            Text(cards[index].statement)
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    .onDelete(perform: removeCards)
                }
            }
            .navigationTitle("Edit Cards")
            .toolbar {
                Button("Done", action: done)
            }
            .listStyle(.grouped)
            .onAppear(perform: loadData)
            .onDisappear {
                AppDelegate.orientationLock = .landscape
            }
        }
    }
    
    func done() {
        addCard()
        dismiss()
    }
    
    func loadData() {
        if let data = UserDefaults.standard.data(forKey: "Cards") {
            if let decoded = try? JSONDecoder().decode([Card].self, from: data) {
                cards = decoded
            }
        }
        UIDevice.current.setValue(UIInterfaceOrientation.portrait, forKey: "orientation")
        AppDelegate.orientationLock = .portrait
    }
    
    func saveData() {
        if let data = try? JSONEncoder().encode(cards) {
            UserDefaults.standard.set(data, forKey: "Cards")
        }
    }
    
    func addCard() {
        let trimmedPrompt = newPrompt.trimmingCharacters(in: .whitespaces)
        let trimmedAnswer = newAnswer.trimmingCharacters(in: .whitespaces)
        let trimmedStatement = newStatement.trimmingCharacters(in: .whitespaces)
        guard trimmedAnswer.isEmpty == false && trimmedPrompt.isEmpty == false else { return }
        
        let card = Card(id: UUID(), prompt: trimmedPrompt, answer: trimmedAnswer, statement: trimmedStatement)
        cards.insert(card, at: 0)
        saveData()
        
        newPrompt = ""
        newAnswer = ""
        newStatement = ""
    }
    
    func removeCards(at offsets: IndexSet) {
        cards.remove(atOffsets: offsets)
        saveData()
    }
}

struct EditCards_Previews: PreviewProvider {
    static var previews: some View {
        EditCards()
    }
}
