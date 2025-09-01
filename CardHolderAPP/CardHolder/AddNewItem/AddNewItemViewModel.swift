//
//  AddNewItemViewModel.swift
//  CardHolderAPP
//
//  Created by D K on 13.08.2025.
//

//import Foundation
//import SwiftUI
//import PhotosUI
//import RealmSwift
//
//@MainActor
//class AddNewItemViewModel: ObservableObject {
//    
//    @Published var itemName: String = ""
//    @Published var itemDescription: String = ""
//    @Published var selectedRarity: RarityTier = .common
//    
//    @Published var selectedImage: UIImage?
//    @Published var selectedPhotoPickerItem: PhotosPickerItem? {
//        didSet {
//            Task { await loadImage(from: selectedPhotoPickerItem) }
//        }
//    }
//    
//    var isSaveButtonEnabled: Bool {
//        !itemName.trimmingCharacters(in: .whitespaces).isEmpty && selectedImage != nil
//    }
//    
//    private var itemSet: ItemSet
//    
//    init(itemSet: ItemSet) {
//        self.itemSet = itemSet
//    }
//    
//    func saveItem() throws {
//        guard isSaveButtonEnabled else { return }
//        
//        let newItem = CollectibleItem()
//        newItem.title = itemName
//        newItem.itemDescription = itemDescription
//        newItem.imageData = selectedImage?.jpegData(compressionQuality: 0.8)
//        newItem.rarityRaw = selectedRarity
//        
//        try StorageService.shared.addItem(newItem, to: \.ownedItems, inSet: itemSet)
//    }
//    
//    private func loadImage(from item: PhotosPickerItem?) async {
//        guard let item = item else { return }
//        do {
//            if let data = try await item.loadTransferable(type: Data.self),
//               let uiImage = UIImage(data: data) {
//                selectedImage = uiImage
//            }
//        } catch {
//            print("Failed to load image: \(error)")
//        }
//    }
//}


import Foundation
import SwiftUI
import PhotosUI
import RealmSwift

@MainActor
class AddNewItemViewModel: ObservableObject {
    
    @Published var itemName: String = ""
    @Published var itemDescription: String = ""
    @Published var selectedRarity: RarityTier = .common
    
    @Published var selectedImage: UIImage?
    @Published var selectedPhotoPickerItem: PhotosPickerItem? {
        didSet {
            Task { await loadImage(from: selectedPhotoPickerItem) }
        }
    }
    
    var isSaveButtonEnabled: Bool {
        !itemName.trimmingCharacters(in: .whitespaces).isEmpty && selectedImage != nil
    }
    
    private var itemSet: ItemSet
    private var listType: ShareableListType
    
    init(itemSet: ItemSet, listType: ShareableListType = .owned) {
        self.itemSet = itemSet
        self.listType = listType
    }
    
    func saveItem() throws {
        guard isSaveButtonEnabled else { return }
        
        let newItem = CollectibleItem()
        newItem.title = itemName
        newItem.itemDescription = itemDescription
        newItem.imageData = selectedImage?.jpegData(compressionQuality: 0.8)
        newItem.rarityRaw = selectedRarity
        
        let listKeyPath: WritableKeyPath<ItemSet, RealmSwift.List<CollectibleItem>>
        switch listType {
        case .owned:
            listKeyPath = \ItemSet.ownedItems
        case .wishlist:
            listKeyPath = \ItemSet.wishListItems
        case .trade:
            listKeyPath = \ItemSet.tradeListItems
        }
        
        try StorageService.shared.addItem(newItem, to: listKeyPath, inSet: itemSet)
    }
    
        private func loadImage(from item: PhotosPickerItem?) async {
            guard let item = item else { return }
            do {
                if let data = try await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedImage = uiImage
                }
            } catch {
                print("Failed to load image: \(error)")
            }
        }
}
