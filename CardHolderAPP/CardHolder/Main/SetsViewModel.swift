//
//  SetsViewModel.swift
//  CardHolderAPP
//
//  Created by D K on 13.08.2025.
//

import Foundation
import RealmSwift
import Combine

@MainActor
class SetsViewModel: ObservableObject {
    
    @Published var primarySet: ItemSet?
    @Published var secondarySets: Results<ItemSet>?
    
    @Published var isAddSetSheetPresented = false
    @Published var isSettingsSheetPresented = false
    
    private var primaryToken: NotificationToken?
    private var secondaryToken: NotificationToken?
    
    init() {
        setupObservers()
        createMockDataIfNeeded()
    }
    
    deinit {
        primaryToken?.invalidate()
        secondaryToken?.invalidate()
    }
    
    private func setupObservers() {
        let realm = try? Realm()
        
        self.primarySet = StorageService.shared.fetchPrimarySet()
        self.secondarySets = StorageService.shared.fetchAllSecondarySets()
        
        let primaryResults = realm?.objects(ItemSet.self).filter("isPrimary == true")
        primaryToken = primaryResults?.observe { [weak self] changes in
            switch changes {
            case .initial, .update:
                self?.primarySet = StorageService.shared.fetchPrimarySet()
            case .error(let error):
                print("Error observing primary set: \(error)")
            }
        }
        
        secondaryToken = secondarySets?.observe { [weak self] _ in
            self?.secondarySets = StorageService.shared.fetchAllSecondarySets()
        }
    }
    
    private func createMockDataIfNeeded() {
        let isInitialLaunch = !UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        if isInitialLaunch {
            try? StorageService.shared.createMockData()
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        }
    }
    
    func deleteAllData() {
        try? StorageService.shared.deleteAllData()
    }
}
