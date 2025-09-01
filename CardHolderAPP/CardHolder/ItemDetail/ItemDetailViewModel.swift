//
//  ItemDetailViewModel.swift
//  CardHolderAPP
//
//  Created by D K on 13.08.2025.
//

import Foundation
import SwiftUI
import RealmSwift

@MainActor
class ItemDetailViewModel: ObservableObject {
    @Published var item: CollectibleItem?
    @Published var isFlipped = false
    
    private var itemToken: NotificationToken?
    private var itemID: ObjectId
    
    init(itemID: ObjectId) {
        self.itemID = itemID
        setupObserver()
    }
    
    deinit {
        itemToken?.invalidate()
    }
    
    var rarityColor: Color {
        guard let item = item else { return .gray }
        switch item.rarityRaw {
        case .common: return .white
        case .uncommon: return .green
        case .rare: return .blue
        case .superRare: return .purple
        case .ultraRare: return .red
        case .secretRare: return .black
        }
    }
    
    private func setupObserver() {
        guard let realm = try? Realm() else { return }
        let results = realm.objects(CollectibleItem.self).filter("_id == %@", itemID)
        itemToken = results.observe { [weak self] changes in
            switch changes {
            case .initial(let items), .update(let items, _, _, _):
                self?.item = items.first
            case .error(let error):
                print("Error observing CollectibleItem: \(error)")
            }
        }
    }
}
