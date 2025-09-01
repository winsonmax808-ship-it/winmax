//
//  AddNewSetView.swift
//  CardHolderAPP
//
//  Created by D K on 13.08.2025.
//

import SwiftUI
import PhotosUI

struct AddNewSetView: View {
    
    @StateObject private var viewModel = AddNewSetViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HeaderView {
                    presentationMode.wrappedValue.dismiss()
                }
                
                ScrollView {
                    VStack(spacing: 24) {
                        CustomTextField(placeholder: "Collection Name", text: $viewModel.setName)
                        
                        ImageSelector(
                            selectedImage: viewModel.selectedImage,
                            selectedItem: $viewModel.selectedPhotoPickerItem
                        )
                        
                        CustomTextEditor(placeholder: "Collection Description", text: $viewModel.setDescription)
                        
                        Toggle(isOn: $viewModel.isPrimarySet) {
                            Text("Set as Main Collection")
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .themeAccentBlue))
                        .padding()
                        .background(Color(white: 1, opacity: 0.05))
                        .cornerRadius(16)
                    }
                    .padding()
                }
                
                Spacer()
                
                Button("Save") {
                    do {
                        try viewModel.saveSet()
                        presentationMode.wrappedValue.dismiss()
                    } catch {
                        print("Failed to save set: \(error)")
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


private struct ImageSelector: View {
    var selectedImage: UIImage?
    @Binding var selectedItem: PhotosPickerItem?
    
    var body: some View {
        PhotosPicker(
            selection: $selectedItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
            ZStack {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Color(white: 1, opacity: 0.05)
                    VStack(spacing: 8) {
                        Image(systemName: "photo.badge.plus")
                            .font(.largeTitle)
                        Text("Add Image")
                            .font(.headline)
                    }
                    .foregroundColor(.themeSecondaryText)
                }
            }
            .frame(height: 170)
            .cornerRadius(16)
        }
    }
}


private struct HeaderView: View {
    var onDismiss: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.title2.weight(.semibold))
            }
            
            Spacer()
            
            Text("New Collection")
                .font(.title2).bold()
                .foregroundColor(.themeAccentBlue)
            
            Spacer()
            
            Image(systemName: "xmark").opacity(0)
        }
        .padding()
        .foregroundColor(.themePrimaryText)
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


struct AddNewSetView_Previews: PreviewProvider {
    static var previews: some View {
        AddNewSetView()
    }
}
