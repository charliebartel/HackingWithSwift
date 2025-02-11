//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by Paul Hudson on 20/10/2021.
//

import SwiftUI

struct ContentView: View {
    @State private var showingScore = false
    @State private var showingTotal = false
    @State private var scoreTitle = ""
    @State private var totalScore = 0
    @State private var questionCount = 0
    @State private var animationAmount = 0.0
    @State private var fadeAmount = 1.0
    @State private var scaleAmount = 1.0
    @State private var flagSelected = 0

    @State private var countries = ["Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Russia", "Spain", "UK", "US"].shuffled()
    @State private var correctAnswer = Int.random(in: 0...2)

    var body: some View {
        ZStack {
            RadialGradient(stops: [
                .init(color: Color(red: 0.1, green: 0.2, blue: 0.45), location: 0.3),
                .init(color: Color(red: 0.76, green: 0.15, blue: 0.26), location: 0.3)
            ], center: .top, startRadius: 200, endRadius: 700)
                .ignoresSafeArea()

            VStack {
                Spacer()

                Text("Guess the Flag")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)

                VStack(spacing: 15) {
                    VStack {
                        Text("Tap the flag of")
                            .foregroundStyle(.secondary)
                            .font(.subheadline.weight(.heavy))

                        Text(countries[correctAnswer])
                            .font(.largeTitle.weight(.semibold))
                    }

                    ForEach(0..<3) { number in
                        Button {
                            flagTapped(number)
                            withAnimation(.interpolatingSpring(stiffness: 5, damping: 1)) {
                                self.animationAmount += 360
                            }
                            withAnimation(.easeInOut(duration: 1)) {
                                self.fadeAmount = 0.25
                                self.scaleAmount = 0.25
                            }
                        } label: {
                            Image(countries[number])
                                .renderingMode(.original)
                                .clipShape(Capsule())
                                .shadow(radius: 5)
                                .rotation3DEffect(.degrees(flagSelected == number ? animationAmount: 0), axis: (x: 0, y: 1, z: 0))
                                .opacity(flagSelected == number ? 1.0 : fadeAmount)
                                .scaleEffect(flagSelected == number ? 1.0 : scaleAmount)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))

                Spacer()
                Spacer()

                Text("Score: \(totalScore)")
                    .foregroundColor(.white)
                    .font(.title.bold())

                Spacer()
            }
            .padding()
        }
        .alert(scoreTitle, isPresented: $showingScore) {
            Button("Continue", action: askQuestion)
        } message: {
            Text("Your score is \(totalScore)")
        }
        .alert(scoreTitle, isPresented: $showingTotal) {
            Button("Reset", action: reset)
        } message: {
            Text("Your total score is \(totalScore)")
        }
    }

    func flagTapped(_ number: Int) {
        flagSelected = number
        if number == correctAnswer {
            scoreTitle = "Correct!"
            totalScore += 1
        } else {
            scoreTitle = "Wrong! That’s the flag of \(countries[number])"
            totalScore -= 1
        }
        questionCount += 1
        if questionCount == 3 {
            showingTotal = true
        } else {
            showingScore = true
        }
    }

    func reset() {
        totalScore = 0
        questionCount = 0
        askQuestion()
    }

    func askQuestion() {
        withAnimation(.easeInOut(duration: 1)) {
            self.fadeAmount = 1.0
            self.scaleAmount = 1.0
        }
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
