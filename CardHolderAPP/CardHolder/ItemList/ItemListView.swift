//
//  ItemListView.swift
//  CardHolderAPP
//
//  Created by D K on 13.08.2025.
//

import SwiftUI
import RealmSwift

struct ItemListView: View {
    
    @StateObject private var viewModel: ItemListViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isAddItemSheetPresented = false
    @State private var selectedItem: CollectibleItem?
    
    @State private var itemToDelete: CollectibleItem?
    @State private var isDeleteAlertPresented = false
    
    init(itemSet: ItemSet) {
        _viewModel = StateObject(wrappedValue: ItemListViewModel(itemSet: itemSet))
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
                    title: viewModel.itemSet.name,
                    onDismiss: { presentationMode.wrappedValue.dismiss() },
                    onShare: { viewModel.prepareShareableImage() }
                )
                
                Picker("View Mode", selection: $viewModel.viewMode.animation()) {
                    Text("Grid").tag(ItemListViewMode.grid)
                    Text("Cards").tag(ItemListViewMode.carousel)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                switch viewModel.viewMode {
                case .grid:
                    gridView
                case .carousel:
                    carouselView
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
            AddNewItemView(itemSet: viewModel.itemSet)
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
    
    private var gridView: some View {
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
    
    private var carouselView: some View {
        VStack {
            Spacer()
            
            TabView {
                ForEach(viewModel.items) { item in
                    Button(action: { selectedItem = item }) {
                        CarouselItemCard(item: item)
                            .padding(.horizontal, 32)
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 500)  
            
            Spacer()
        }
    }
}


struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
            
            VStack {
                ProgressView().tint(.white)
                Text("Generating Image...")
                    .foregroundColor(.white)
                    .padding(.top)
            }
            .padding(30)
            .background(.thinMaterial)
            .cornerRadius(20)
        }
    }
}

struct AddItemGridButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.themeAccentBlue.opacity(0.2))
                
                Image(systemName: "plus")
                    .font(.largeTitle)
                    .foregroundColor(.themeAccentBlue)
            }
        }
        .aspectRatio(2/3, contentMode: .fit)
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


struct GridItemCell: View {
    @ObservedRealmObject var item: CollectibleItem
    @State private var image: UIImage?
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                            if let image = image { // 2. Отображаем, если оно загружено
                                Image(uiImage: image)
                                    .resizable()
                                    .transition(.opacity.animation(.easeInOut)) // Плавное появление
                            } else {
                                ZStack {
                                    Rectangle()
                                        .foregroundStyle(.black)
                                    ProgressView()
                                        .tint(.white)
                                        .controlSize(.large)
                                }
                                
                            }
                        }
                        .aspectRatio(2/3, contentMode: .fill)
            
            VStack {
                Text(item.title)
                    .font(.caption).bold()
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .padding(8)
            .frame(maxWidth: .infinity)
            .background(.thinMaterial)
        }
        .cornerRadius(12)
        .foregroundColor(.white)
        .onAppear(perform: loadImage)
    }
    
    private func loadImage() {
            // Убедимся, что не загружаем одно и то же изображение повторно
            guard image == nil else { return }
            
            // ВАЖНО: Realm объекты привязаны к потоку.
            // Поэтому мы сначала извлекаем данные, а потом уходим в фон.
            guard let imageData = item.imageData else { return }

            // 4. Уходим в фоновый поток для декодирования
            DispatchQueue.global(qos: .userInitiated).async {
                let loadedImage = UIImage(data: imageData)
                
                // 5. Возвращаемся в главный поток для обновления UI
                DispatchQueue.main.async {
                    self.image = loadedImage

                }
            }
        }
}


private struct CarouselItemCard: View {
    @ObservedRealmObject var item: CollectibleItem
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                if let data = item.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage).resizable()
                        .clipShape(RoundedRectangle(cornerRadius: 20))

                } else {
                    Rectangle().fill(.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 20))

                }
            }
            .aspectRatio(0.7, contentMode: .fit)
            
            VStack {
                Spacer()
                HStack {
                    Text(item.title)
                        .font(.title).bold()
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.8), .black],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.4), radius: 10, y: 5)
    }
}
