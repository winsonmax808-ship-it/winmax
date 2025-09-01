//
//  TradeListView.swift
//  CardHolderAPP
//
//  Created by D K on 13.08.2025.
//

import SwiftUI
import RealmSwift

struct TradeListView: View {
    
    @StateObject private var viewModel: TradeListViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isAddItemSheetPresented = false
    @State private var selectedItem: CollectibleItem?
    
    @State private var itemToDelete: CollectibleItem?
    @State private var isDeleteAlertPresented = false
    
    init(itemSet: ItemSet) {
        _viewModel = StateObject(wrappedValue: TradeListViewModel(itemSet: itemSet))
    }
    
    private let gridColumns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HeaderView(
                    title: "Trade List",
                    onDismiss: { presentationMode.wrappedValue.dismiss() },
                    onShare: { viewModel.prepareShareableImage() }
                )
                
                if viewModel.items.isEmpty {
                    EmptyStateView(
                        message: "Your trade list is empty.",
                        buttonTitle: "Add First Card",
                        action: { isAddItemSheetPresented = true }
                    )
                } else {
                    ScrollView {
                        LazyVGrid(columns: gridColumns, spacing: 16) {
                            AddItemGridButton {
                                isAddItemSheetPresented = true
                            }
                            
                            ForEach(viewModel.items) { item in
                                Button(action: { selectedItem = item }) {
                                    GridItemCell(item: item)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            
            if viewModel.isGeneratingShareImage {
                LoadingOverlay()
            }
        }
        .navigationBarHidden(true)
        .sheet(item: $viewModel.itemToShare) { shareableImage in
            ShareSheet(activityItems: [shareableImage.image])
        }
        .sheet(isPresented: $isAddItemSheetPresented) {
            AddNewItemView(itemSet: viewModel.itemSet, listType: .trade)
        }
        .fullScreenCover(item: $selectedItem) { item in
            ItemDetailView(item: item, onDelete: {
                self.itemToDelete = item
                self.isDeleteAlertPresented = true
            })        }
        .alert("Delete Card", isPresented: $isDeleteAlertPresented) {
            Button("Cancel", role: .cancel) { itemToDelete = nil }
            Button("Delete", role: .destructive) {
                if let item = itemToDelete {
                    try? StorageService.shared.deleteItem(item)
                }
                itemToDelete = nil
            }
        } message: {
            Text("Are you sure you want to permanently delete this card?")
        }
    }
}


private struct HeaderView: View {
    let title: String
    var onDismiss: () -> Void
    var onShare: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onDismiss) { Image(systemName: "xmark") }
            Spacer()
            Text(title).font(.title2).bold().foregroundColor(.themeAccentBlue)
            Spacer()
            Button(action: onShare) { Image(systemName: "square.and.arrow.up") }
        }
        .font(.title2.weight(.semibold))
        .padding()
        .foregroundColor(.themePrimaryText)
    }
}

private struct EmptyStateView: View {
    let message: String
    let buttonTitle: String
    var action: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "star.fill")
                .font(.system(size: 60))
                .foregroundColor(.themeAccentYellow.opacity(0.5))
            Text(message)
                .font(.headline)
                .foregroundColor(.themeSecondaryText)
                .multilineTextAlignment(.center)
            
            Button(action: action) {
                Label(buttonTitle, systemImage: "plus")
                    .font(.headline.bold())
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding()
            
            Spacer()
        }
        .padding()
    }
}
