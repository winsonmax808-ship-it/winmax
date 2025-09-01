//
//  ItemDetailView.swift
//  CardHolderAPP
//
//  Created by D K on 13.08.2025.
//

import SwiftUI
import RealmSwift


struct ItemDetailView: View {
    @StateObject private var viewModel: ItemDetailViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var onDelete: () -> Void
    
    init(item: CollectibleItem, onDelete: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: ItemDetailViewModel(itemID: item._id))
        self.onDelete = onDelete
    }
    
    var body: some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.gray.opacity(0.8))
                    }
                }
                .padding()
                
                if let item = viewModel.item {
                    FlippableCardView(
                        item: item,
                        isFlipped: $viewModel.isFlipped,
                        rarityColor: viewModel.rarityColor,
                        onDelete: {
                            presentationMode.wrappedValue.dismiss()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                onDelete()
                            }
                        }
                    )
                } else {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                
                Spacer(minLength: 20)
            }
            .padding()
        }
    }
}


private struct FlippableCardView: View {
    @ObservedRealmObject var item: CollectibleItem
    @Binding var isFlipped: Bool
    let rarityColor: Color
    var onDelete: () -> Void
    
    var body: some View {
        ZStack {
            CardBackView(item: item, rarityColor: rarityColor, onDelete: onDelete)
            .rotation3DEffect(.degrees(isFlipped ? 0 : 180), axis: (x: 0, y: 1, z: 0))
            .opacity(isFlipped ? 1 : 0)
            
            CardFrontView(item: item, rarityColor: rarityColor)
            .rotation3DEffect(.degrees(isFlipped ? -180 : 0), axis: (x: 0, y: 1, z: 0))
            .opacity(isFlipped ? 0 : 1)
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                isFlipped.toggle()
            }
        }
    }
}

private struct CardFrontView: View {
    @ObservedRealmObject var item: CollectibleItem
    let rarityColor: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let data = item.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                } else {
                    Rectangle().fill(.gray)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(rarityColor, lineWidth: 4)
                    .shadow(color: rarityColor, radius: 10)
            )
        }
    }
}

private struct CardBackView: View {
    @ObservedRealmObject var item: CollectibleItem
    let rarityColor: Color
    var onDelete: () -> Void
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text(item.title).font(.largeTitle).bold().multilineTextAlignment(.center)
                    
                    VStack {
                        Text("Description").font(.headline).foregroundColor(.themeSecondaryText)
                        Text(item.itemDescription).font(.body).multilineTextAlignment(.center)
                    }
                    
                    VStack {
                        Text("Rarity").font(.headline).foregroundColor(.themeSecondaryText)
                        Text(item.rarityRaw.rawValue.capitalized)
                            .font(.title2).bold()
                            .foregroundColor(rarityColor)
                    }
                }
                .padding(32)
            }
            
            Spacer(minLength: 20)
            
            Button("Delete Card", role: .destructive, action: onDelete)
                .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(white: 1, opacity: 0.05))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(rarityColor, lineWidth: 4)
                .shadow(color: rarityColor, radius: 10)
        )
    }
}
