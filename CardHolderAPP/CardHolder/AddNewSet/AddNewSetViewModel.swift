//
//  AddNewSetViewModel.swift
//  CardHolderAPP
//
//  Created by D K on 13.08.2025.
//

import Foundation
import SwiftUI
import PhotosUI

@MainActor
class AddNewSetViewModel: ObservableObject {
    
    @Published var setName: String = ""
    @Published var setDescription: String = ""
    @Published var selectedImage: UIImage?
    @Published var isPrimarySet: Bool = false
    
    @Published var selectedPhotoPickerItem: PhotosPickerItem? {
        didSet {
            Task {
                await loadImage(from: selectedPhotoPickerItem)
            }
        }
    }
    
    var isSaveButtonEnabled: Bool {
        !setName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    func saveSet() throws {
        guard isSaveButtonEnabled else { return }
        
        try StorageService.shared.createItemSet(
            name: setName,
            description: setDescription,
            image: selectedImage?.jpegData(compressionQuality: 0.8),
            isPrimary: isPrimarySet
        )
    }
    
    private func loadImage(from item: PhotosPickerItem?) async {
        guard let item = item else { return }
        
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                if let uiImage = UIImage(data: data) {
                    selectedImage = uiImage
                }
            }
        } catch {
            print("Failed to load image: \(error)")
        }
    }
}
