//
//  ContentView.swift
//  FlashzillaPro
//
//  Created by Rishav Gupta on 04/07/23.
//

import SwiftUI

// Our custom view modifier to track rotation and
// call our action
//struct DeviceRotationViewModifier: ViewModifier {
//    let action: (UIDeviceOrientation) -> Void
//
//    func body(content: Content) -> some View {
//        content
//            .onAppear()
//            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
//                action(UIDevice.current.orientation)
//            }
//    }
//}

// A View wrapper to make the modifier easier to use
//extension View {
//    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
//        self.modifier(DeviceRotationViewModifier(action: action))
//    }
//}

extension View {
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = Double(total - position)
        return self.offset(x: 0, y: offset * 10)
    }
}

struct ContentView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.accessibilityVoiceOverEnabled) var voiceOverEnabled
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var cards = [Card]()
    
    @State private var timeRemaining = 100
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @Environment(\.scenePhase) var scenePhase
    
    @State private var isActive = true
    
    @State private var showingEditScreen = false
    
    @State private var orientation = UIDeviceOrientation.unknown
    
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .ignoresSafeArea()
            VStack {
                Text("Time remaining: \(timeRemaining) secs")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background(.black.opacity(0.75))
                    .clipShape(Capsule())
                
                ZStack {
                    ForEach(cards) { card in
                        let index = cards.firstIndex(where: { $0.id == card.id }) ?? 0
                        CardView(card: card, removal: { state in
                            withAnimation {
                                if state == false {
                                    if let card = removeCard(at: index) {
                                        addCardBack(card: card)
                                    }
                                } else {
                                    _ = removeCard(at: index)
                                }
                            }
                            isActive = true
                        }, showingAnswer: { showingAnswer in
                            if showingAnswer {
                                isActive = false
                            } else {
                                isActive = true
                            }
                        })
                        .stacked(at: index, in: cards.count)
                        .allowsHitTesting(index == cards.count - 1)
                        .accessibilityHidden(index < cards.count - 1)
                        .padding()
                    }
                }
                .allowsHitTesting(timeRemaining > 0)
                .padding()
                
                if cards.isEmpty {
                    Button("Start Again", action: resetCards)
                        .padding()
                        .background(.white)
                        .foregroundColor(.black)
                        .clipShape(Capsule())
                }
            }
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button {
                        showingEditScreen = true
                    } label: {
                        Image(systemName: "plus.circle")
                            .padding()
                            .background(.black.opacity(0.7))
                            .clipShape(Circle())
                    }
                    .padding()
                    .offset(x: -10, y: 0)
                }
                Spacer()
            }
            .foregroundColor(.white)
            .font(.largeTitle)
            .padding()
            
            if differentiateWithoutColor || voiceOverEnabled {
                VStack {
                    Spacer()
                    HStack {
                        Button {
                            withAnimation {
                                if let card = removeCard(at: cards.count - 1) {
                                    addCardBack(card: card)
                                }
                            }
                        } label: {
                            Image(systemName: "xmark.circle")
                                .padding()
                                .background(.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .accessibilityLabel("Wrong")
                        .accessibilityHint("Mark your answer as being incorrect")
                        
                        Spacer()
                        
                        Button {
                            withAnimation {
                                _ = removeCard(at: cards.count - 1)
                            }
                        } label: {
                            Image(systemName: "checkmark.circle")
                                .padding()
                                .background(.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .accessibilityLabel("Correct")
                        .accessibilityHint("Mark your answer as being correct")
                    }
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .padding()
                }
            }
        }
        .onReceive(timer) { time in
            guard isActive else { return }
            if timeRemaining > 0 {
                timeRemaining -= 1
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                if cards.isEmpty == false {
                    isActive = true
                }
            } else {
                isActive = false
            }
        }
//        .onRotate { newOrientation in
//            orientation = newOrientation
//        }
        .sheet(isPresented: $showingEditScreen, onDismiss: resetCards, content: EditCards.init)
        .onAppear(perform: resetCards)
        .onDisappear {
            AppDelegate.orientationLock = .all
        }
    }
    
//    var randomCards: [Card] {
//        return cards.shuffled()
//    }
    
    func removeCard(at index: Int) -> Card? {
        guard index >= 0 else { return nil }
        
        let card = cards.remove(at: index)
        
        if cards.isEmpty {
            isActive = false
        }
        return card
    }
    
    func resetCards() {
        loadData()
        timeRemaining = cards.count * 5
        isActive = true
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft, forKey: "orientation")
        AppDelegate.orientationLock = .landscape
    }
    
    func loadData() {
        if let data = UserDefaults.standard.data(forKey: "Cards") {
            if let decoded = try? JSONDecoder().decode([Card].self, from: data) {
                cards = decoded.shuffled()
            }
        }
    }
//    
//    func saveData() {
//        if let data = try? JSONEncoder().encode(cards) {
//            UserDefaults.standard.set(data, forKey: "Cards")
//        }
//    }
    
    func addCardBack(card: Card) {
        let card = Card(id: UUID(), prompt: card.prompt, answer: card.answer, statement: card.statement)
        print(cards)
        if cards.count == 0 {
            cards.insert(card, at: 0)
        } else {
            cards.insert(card, at: 0)
        }
        print(cards)
//        saveData()
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
         
    static var orientationLock = UIInterfaceOrientationMask.all //By default you want all your views to rotate freely
 
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
