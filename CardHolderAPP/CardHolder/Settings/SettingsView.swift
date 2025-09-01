//
//  SettingsView.swift
//  CardHolderAPP
//
//  Created by D K on 13.08.2025.
//

import SwiftUI

struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var onDataDeleted: () -> Void
    
    var body: some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HeaderView {
                    presentationMode.wrappedValue.dismiss()
                }
                
                List {
                    SettingsRow(icon: "envelope.fill", title: "Send Feedback") {
                        viewModel.showWebView(for: viewModel.contactUsURL)
                    }
                    
                    SettingsRow(icon: "lock.doc.fill", title: "Privacy Policy") {
                        viewModel.showWebView(for: viewModel.privacyPolicyURL)
                    }
                    
                    SettingsRow(icon: "trash.fill", title: "Delete All Data", isDestructive: true) {
                        viewModel.isDeleteAlertPresented = true
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .scrollContentBackground(.hidden)
            }
        }
        .alert("Are you sure?", isPresented: $viewModel.isDeleteAlertPresented) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                try? viewModel.deleteAllData()
                onDataDeleted()
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("All your collections and cards will be permanently deleted.")
        }
        .sheet(item: $viewModel.webViewURL) { url in
            SafariWebView(url: url)
        }
    }
}


private struct HeaderView: View {
    var onDismiss: () -> Void
    
    var body: some View {
        HStack {
            Text("Settings")
                .font(.largeTitle).bold()
                .foregroundColor(.themePrimaryText)
            
            Spacer()
            
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.themeSecondaryText)
            }
        }
        .padding()
    }
}


private struct SettingsRow: View {
    let icon: String
    let title: String
    var isDestructive: Bool = false
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.themeSecondaryText.opacity(0.5))
            }
        }
        .listRowBackground(Color(white: 1, opacity: 0.05))
        .foregroundColor(isDestructive ? .red : .themePrimaryText)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(onDataDeleted: {})
    }
}

import SwiftUI
import SafariServices

struct SafariWebView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

extension URL: Identifiable {
    public var id: String { self.absoluteString }
}
