//
//  AddNewItemView.swift
//  CardHolderAPP
//
//  Created by D K on 13.08.2025.
//

import SwiftUI
import PhotosUI

struct AddNewItemView: View {
    
    @StateObject private var viewModel: AddNewItemViewModel
        @Environment(\.presentationMode) var presentationMode
        
        init(itemSet: ItemSet, listType: ShareableListType = .owned) {
            _viewModel = StateObject(wrappedValue: AddNewItemViewModel(itemSet: itemSet, listType: listType))
        }
    
    var body: some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HeaderView {
                    presentationMode.wrappedValue.dismiss()
                }
                
                ScrollView {
                    VStack(spacing: 24) {
                        ImageSelector(
                            selectedImage: viewModel.selectedImage,
                            selectedItem: $viewModel.selectedPhotoPickerItem
                        )
                        
                        CustomTextField(placeholder: "Card Name", text: $viewModel.itemName)
                        
                        CustomTextEditor(placeholder: "Card Description", text: $viewModel.itemDescription)
                        
                        RarityPicker(selection: $viewModel.selectedRarity)
                    }
                    .padding()
                }
                
                Spacer()
                
                Button("Save") {
                    do {
                        try viewModel.saveItem()
                        presentationMode.wrappedValue.dismiss()
                    } catch {
                        print("Failed to save item: \(error)")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!viewModel.isSaveButtonEnabled)
                .opacity(viewModel.isSaveButtonEnabled ? 1 : 0.6)
                .padding()
            }
            .foregroundColor(.themePrimaryText)
        }
    }
}

private struct HeaderView: View {
    var onDismiss: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onDismiss) { Image(systemName: "xmark") }
            Spacer()
            Text("New Card").font(.title2).bold().foregroundColor(.themeAccentBlue)
            Spacer()
            Image(systemName: "xmark").opacity(0)
        }
        .font(.title2.weight(.semibold))
        .padding()
        .foregroundColor(.themePrimaryText)
    }
}

private struct ImageSelector: View {
    var selectedImage: UIImage?
    @Binding var selectedItem: PhotosPickerItem?
    
    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            ZStack {
                if let image = selectedImage {
                    Image(uiImage: image).resizable().aspectRatio(contentMode: .fill)
                } else {
                    Color(white: 1, opacity: 0.05)
                    VStack(spacing: 8) {
                        Image(systemName: "photo.badge.plus").font(.largeTitle)
                        Text("Add Image").font(.headline)
                    }
                    .foregroundColor(.themeSecondaryText)
                }
            }
            .frame(height: 200)
            .cornerRadius(16)
        }
    }
}

private struct RarityPicker: View {
    @Binding var selection: RarityTier
    
    var body: some View {
        HStack {
            Text("Rarity")
                .foregroundColor(.themeSecondaryText)
            
            Spacer()
            
            Picker("Rarity", selection: $selection) {
                ForEach(RarityTier.allCases, id: \.self) { tier in
                    Text(tier.rawValue.capitalized).tag(tier)
                }
            }
            .accentColor(.themeAccentYellow)
        }
        .padding()
        .background(Color(white: 1, opacity: 0.05))
        .cornerRadius(16)
    }
}

 struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.bold())
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.themeAccentBlue)
            .cornerRadius(16)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

private struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField("", text: $text, prompt: Text(placeholder).foregroundColor(.themeSecondaryText))
            .padding()
            .background(Color(white: 1, opacity: 0.05))
            .cornerRadius(16)
            .foregroundColor(.themePrimaryText)
    }
}


private struct CustomTextEditor: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .scrollContentBackground(.hidden)
                .padding()
                .frame(minHeight: 120)
                .background(Color(white: 1, opacity: 0.05))
                .cornerRadius(16)
                .foregroundColor(.themePrimaryText)
                .scrollContentBackground(.hidden)

            
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.themeSecondaryText)
                    .padding()
                    .allowsHitTesting(false)
            }
        }
    }
}
