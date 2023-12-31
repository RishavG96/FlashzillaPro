//
//  CardView.swift
//  FlashzillaPro
//
//  Created by Rishav Gupta on 04/07/23.
//

import SwiftUI

struct CardView: View {
    let card: Card
    var removal: ((Bool) -> Void)? = nil
    var showingAnswer: ((Bool) -> Void)
    
    @State private var feedback = UINotificationFeedbackGenerator()
    
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.accessibilityVoiceOverEnabled) var voidOverEnabled
    @State private var isShowingAnswer = false {
        didSet {
            isShowingAnswer ? showingAnswer(true) : showingAnswer(false)
        }
    }
    @State private var offset = CGSize.zero
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                .fill(
                    differentiateWithoutColor
                    ? .white
                    : .white.opacity(1 - Double(abs(offset.width / 50)))
                )
                .background(
                    differentiateWithoutColor
                    ? nil
                    : RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                        .fill(offset.width > 0 ? .green : .red)
                )
                .shadow(radius: 10)
            
            VStack {
                if voidOverEnabled {
                    Text(isShowingAnswer ? card.answer : card.prompt)
                        .font(.largeTitle)
                        .foregroundColor(.black)
                } else {
                    Text(card.prompt)
                        .font(.largeTitle)
                        .foregroundColor(.black)
                    
                    if isShowingAnswer {
                        Text(card.answer)
                            .font(.title3)
                            .foregroundColor(.gray)
                        
                        Text(card.statement)
                            .font(.caption).bold()
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .multilineTextAlignment(.center)
        }
        .frame(width: 400, height: 250)
        .padding()
        .rotationEffect(.degrees(Double(offset.width / 5)))
        .offset(x: offset.width * 2, y: 0)
        .opacity(3 - Double(abs(offset.width / 50)))
        .accessibilityAddTraits(.isButton)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                    feedback.prepare()
                }
                .onEnded { _ in
                    if abs(offset.width) > 100 {
                        // remove the card
                        if offset.width > 0 {
                            feedback.notificationOccurred(.success)
                            removal?(true)
                        } else {
                            feedback.notificationOccurred(.error)
                            removal?(false)
                        }
                    } else {
                        offset = .zero
                    }
                }
        )
        .onTapGesture {
            isShowingAnswer.toggle()
        }
        .animation(.spring(), value: offset)
        .onAppear {
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft, forKey: "orientation")
            AppDelegate.orientationLock = .landscape
        }
        .onDisappear {
            AppDelegate.orientationLock = .all
        }
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(card: Card.example, showingAnswer: { _ in })
    }
}
