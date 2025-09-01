//
//  SettingsViewModel.swift
//  CardHolderAPP
//
//  Created by D K on 13.08.2025.
//

import Foundation
import SwiftUI
import StoreKit

@MainActor
class SettingsViewModel: ObservableObject {
    
    @Published var isDeleteAlertPresented = false
    @Published var webViewURL: URL?
    @Published var isWebViewPresented = false
    
    let privacyPolicyURL = URL(string: "https://sites.google.com/view/winmaxapp/privacy-policy")
    let contactUsURL = URL(string: "https://sites.google.com/view/winmaxapp/contact-us")
    
    func showWebView(for url: URL?) {
        guard let url = url else { return }
        webViewURL = url
        isWebViewPresented = true
    }
    
    func deleteAllData() throws {
        try StorageService.shared.deleteAllData()
    }
}
