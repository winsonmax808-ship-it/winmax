//
//  OnboardingView.swift
//  CardHolderAPP
//
//  Created by D K on 13.08.2025.
//

import SwiftUI


private struct OnboardingStep: Identifiable {
    let id: Int
    let title: String
    let description: String
    let imageName: String
}

struct OnboardingView: View {
    
    
    @Environment(\.dismiss) var dismiss
    @State private var currentStep = 0
    
    private let steps: [OnboardingStep] = [
        OnboardingStep(id: 0,
                       title: "Welcome to Winmax",
                       description: "Your ultimate digital locker room for your entire sports card collection.",
                       imageName: "1"),
                       
        OnboardingStep(id: 1,
                       title: "Build Your Roster",
                       description: "Quickly add cards, upload your scans, and track key details like rookie status and condition.",
                       imageName: "2"),
                       
        OnboardingStep(id: 2,
                       title: "Scout Your Targets",
                       description: "Create a hot list of the cards you're hunting for, from missing set pieces to your ultimate grails.",
                       imageName: "3"),
                       
        OnboardingStep(id: 3,
                       title: "Set Your Trade Block",
                       description: "Easily manage the cards you're ready to trade and negotiate deals to complete your collection.",
                       imageName: "4")
    ]
    
    var body: some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            VStack {
                HeaderView()
                
                Spacer()
                
                CardCarouselView(steps: steps, currentStep: currentStep)
                    .frame(height: 320)
                
                StepDescriptionView(step: steps[currentStep])
                    .padding(.horizontal)
                
                Spacer()
                
                OnboardingButton(isLastStep: currentStep == steps.count - 1) {
                    if currentStep < steps.count - 1 {
                        withAnimation(.spring()) {
                            currentStep += 1
                        }
                    } else {
                        dismiss()
                    }
                }
                .padding(30)
            }
        }
    }
}


private struct HeaderView: View {
    var body: some View {
        VStack {
            Text("WINMAX")
                .font(.largeTitle).bold()
                .foregroundColor(.themeAccentYellow)
//            Text("Cards")
//                .font(.largeTitle)
//                .foregroundColor(.themePrimaryText)
        }
        .padding(.top)
    }
}

private struct CardCarouselView: View {
    let steps: [OnboardingStep]
    let currentStep: Int
    
    var body: some View {
        ZStack {
            ForEach(steps) { step in
                OnboardingCardView(step: step)
                    .rotationEffect(rotationAngle(for: step.id))
                    .offset(y: -abs(CGFloat(step.id - currentStep)) * 20)
                    .zIndex(Double(steps.count - abs(step.id - currentStep)))
            }
        }
    }
    
    private func rotationAngle(for index: Int) -> Angle {
        let rotationPerCard: Double = 10
        let currentAngle = Double(index - currentStep) * rotationPerCard
        return Angle(degrees: currentAngle)
    }
}


private struct OnboardingCardView: View {
    let step: OnboardingStep
    
    var body: some View {
        Image(step.imageName)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 150, height: 210)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.5), radius: 20, y: 10)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
    }
}

private struct StepDescriptionView: View {
    let step: OnboardingStep
    
    var body: some View {
        VStack(spacing: 8) {
            Text(step.title)
                .font(.title2).bold()
                .foregroundColor(.themePrimaryText)
            
            Text(step.description)
                .foregroundColor(.themeSecondaryText)
                .multilineTextAlignment(.center)
        }
        .id(step.id)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
}

private struct OnboardingButton: View {
    let isLastStep: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(isLastStep ? "Get Started" : "Next")
                .font(.headline.bold())
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.themeAccentBlue)
                .cornerRadius(16)
        }
    }
}


#Preview {
    OnboardingView()
}
