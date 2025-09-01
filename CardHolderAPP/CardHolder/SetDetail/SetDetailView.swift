//
//  SetDetailView.swift
//  CardHolderAPP
//
//  Created by D K on 13.08.2025.
//

import SwiftUI
import RealmSwift

struct SetDetailView: View {
    
    @StateObject private var viewModel: SetDetailViewModel
    @Environment(\.presentationMode) var presentationMode
    
    init(itemSet: ItemSet) {
        _viewModel = StateObject(wrappedValue: SetDetailViewModel(itemSetId: itemSet._id))
    }
    
    var body: some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            if let itemSet = viewModel.itemSet {
                content(for: itemSet)
            } else {
                ProgressView()
            }
        }
        .navigationBarHidden(true)
       
    }
    
    @ViewBuilder
    private func content(for itemSet: ItemSet) -> some View {
        VStack(spacing: 0) {
            HeaderView(itemSet: itemSet) {
                presentationMode.wrappedValue.dismiss()
            }
            
            List {
                NavigationLink(destination: ItemListView(itemSet: itemSet)) {
                    DetailRow(
                        icon: "square.stack.3d.up.fill",
                        title: "All Cards",
                        count: itemSet.ownedItems.count,
                        color: .themeAccentBlue
                    )
                }
                
                NavigationLink(destination: WishlistView(itemSet: itemSet)) {
                    DetailRow(
                        icon: "star.fill",
                        title: "Wishlist",
                        count: itemSet.wishListItems.count,
                        color: .themeAccentYellow
                    )
                }
                
                NavigationLink(destination: TradeListView(itemSet: itemSet)) {
                    DetailRow(
                        icon: "arrow.2.squarepath",
                        title: "Trade List",
                        count: itemSet.tradeListItems.count,
                        color: .green
                    )

                }
            }
            .listStyle(InsetGroupedListStyle())
            .scrollContentBackground(.hidden)
            .background(Color(white: 1, opacity: 0.05))
            .cornerRadius(16)

            
            Spacer()
        }
    }
}

private struct HeaderView: View {
    @ObservedRealmObject var itemSet: ItemSet
    var onDismiss: () -> Void
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Group {
                if let imageData = itemSet.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Image("artCol").resizable().aspectRatio(contentMode: .fill)
                }
            }
            .overlay {
                Rectangle()
                    .foregroundStyle(.black).opacity(0.5)
            }
            .frame(height: 240)
            .clipped()
            
            LinearGradient(colors: [.clear, .black], startPoint: .top, endPoint: .bottom)
            
            VStack(alignment: .leading) {
                Text(itemSet.name)
                    .font(.largeTitle).bold()
                Text(itemSet.setDescription)
                    .font(.subheadline)
                    .foregroundColor(.themeSecondaryText)
                    .lineLimit(4)
            }
            .padding()
            .foregroundColor(.themePrimaryText)
            
            HStack {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                }
                .buttonStyle(HeaderButtonStyle())
                
                Spacer()
                
                // TODO: Добавить кнопку удаления с алертом
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding()
        }
        .frame(height: 240)
    }
}

private struct DetailRow: View {
    let icon: String
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .frame(width: 40)
                .foregroundColor(color)
            
            Text(title)
                .font(.headline)
            
            Spacer()
            
            Text("\(count)")
                .font(.body)
                .foregroundColor(.themeSecondaryText)
        }
        .padding(.vertical, 8)
        .foregroundColor(.themePrimaryText)
    }
}

private struct HeaderButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.bold))
            .padding(10)
            .background(.thinMaterial)
            .clipShape(Circle())
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
    }
}

struct SetDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SetDetailView(itemSet: ItemSet())
    }
}
