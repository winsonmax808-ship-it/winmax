//
//  MainView.swift
//  CardHolderAPP
//
//  Created by D K on 13.08.2025.
//

import SwiftUI
import RealmSwift

struct SetsView: View {
    
    @StateObject private var viewModel = SetsViewModel()
    @State private var isShown = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Color.themeBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        HeaderView {
                            viewModel.isSettingsSheetPresented = true
                        }
                        
                        TitledSection(title: "Main Collection", accentColor: .themeAccentYellow)
                        
                        if let primarySet = viewModel.primarySet {
                            NavigationLink(value: primarySet) {
                                PrimarySetCard(itemSet: primarySet)
                            }
                        } else {
                            EmptyStateCard(message: "You don't have a main collection.")
                        }
                        
                        TitledSection(title: "Other Collections", accentColor: .themeAccentBlue)
                        
                        if let secondarySets = viewModel.secondarySets, !secondarySets.isEmpty {
                            ForEach(secondarySets) { set in
                                NavigationLink(value: set) {
                                    SecondarySetRow(itemSet: set)
                                }
                            }
                        } else {
                            // Пустое состояние для "Other Collections"
                        }
                    }
                    .padding()
                    .padding(.bottom, 80)
                }
                .scrollIndicators(.hidden)
                
                FloatingActionButton {
                    viewModel.isAddSetSheetPresented = true
                }
            }
            .navigationDestination(for: ItemSet.self) { itemSet in
                SetDetailView(itemSet: itemSet)
            }
           
            .sheet(isPresented: $viewModel.isAddSetSheetPresented) {
                AddNewSetView()
            }
            .fullScreenCover(isPresented: $viewModel.isSettingsSheetPresented) {
                SettingsView {
                    viewModel.deleteAllData()
                }
            }
        }
        .onAppear {
            if !UserDefaults.standard.bool(forKey: "isOnboardingShown") {
                isShown.toggle()
                UserDefaults.standard.set(true, forKey: "isOnboardingShown")
            }
        }
        .fullScreenCover(isPresented: $isShown) {
            OnboardingView()
        }
    }
}


private struct HeaderView: View {
    var onSettingsTapped: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("WINMAX")
                    .font(.largeTitle).bold()
                    .foregroundColor(.themeAccentYellow)
//                Text("Card Keeper")
//                    .font(.largeTitle).bold()
//                    .foregroundColor(.themePrimaryText)
            }

            Spacer()
            
            Button(action: onSettingsTapped) {
                Image(systemName: "gearshape.fill")
                    .font(.title)
                    .foregroundColor(.themeAccentYellow)
            }
        }
    }
}


private struct TitledSection: View {
    let title: String
    let accentColor: Color
    
    var body: some View {
        Text(title)
            .font(.title2).bold()
            .foregroundColor(.themePrimaryText)
            .shadow(color: accentColor.opacity(0.8), radius: 10)
            .shadow(color: accentColor.opacity(0.5), radius: 20)
    }
}

//private struct PrimarySetCard: View {
//    @ObservedRealmObject var itemSet: ItemSet
//    
//    var body: some View {
//        ZStack(alignment: .top) {
//            if let imageData = itemSet.imageData, let uiImage = UIImage(data: imageData) {
//                Image(uiImage: uiImage)
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(height: 200)
//            } else {
//                Rectangle().fill(Color.gray).frame(height: 200)
//            }
//            
//            VStack {
//                HStack {
//                    Text(itemSet.name)
//                        .font(.headline)
//                    Spacer()
//                    Text("x\(itemSet.ownedItems.count)")
//                        .font(.headline)
//                }
//                .padding()
//                .background(.thinMaterial)
//                
//                Spacer()
//            }
//        }
//        .frame(height: 200)
//        .cornerRadius(20)
//    }
//}


private struct SecondarySetRow: View {
    @ObservedRealmObject var itemSet: ItemSet
    
    var body: some View {
        HStack {
            if let imageData = itemSet.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .cornerRadius(12)
            } else {
                Rectangle().fill(Color.gray).frame(width: 60, height: 60).cornerRadius(12)
            }
            
            VStack(alignment: .leading) {
                Text(itemSet.name)
                    .font(.headline)
                Text("\(itemSet.ownedItems.count) cards")
                    .font(.subheadline)
                    .foregroundColor(.themeSecondaryText)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.themeSecondaryText)
        }
        .padding()
        .background(Color(white: 1, opacity: 0.05))
        .cornerRadius(16)
    }
}

private struct EmptyStateCard: View {
    let message: String
    
    var body: some View {
        Text(message)
            .foregroundColor(.themeSecondaryText)
            .font(.headline)
            .frame(maxWidth: .infinity, minHeight: 200)
            .background(Color(white: 1, opacity: 0.05))
            .cornerRadius(20)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }
}

private struct FloatingActionButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.title.weight(.semibold))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(Color.themeAccentBlue)
                .clipShape(Circle())
                .shadow(color: .themeAccentBlue.opacity(0.8), radius: 10)
        }
        .padding()
    }
}

struct SetsView_Previews: PreviewProvider {
    static var previews: some View {
        SetsView()
    }
}
