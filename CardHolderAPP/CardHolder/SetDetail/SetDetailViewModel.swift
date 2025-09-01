//
//  SetDetailViewModel.swift
//  CardHolderAPP
//
//  Created by D K on 13.08.2025.
//

import Foundation
import RealmSwift
import Combine

@MainActor
class SetDetailViewModel: ObservableObject {
    
    @Published var itemSet: ItemSet?
    
    private var setToken: NotificationToken?
    private var itemSetId: ObjectId
    
    init(itemSetId: ObjectId) {
        self.itemSetId = itemSetId
        setupObserver()
    }
    
    deinit {
        setToken?.invalidate()
    }
    
    private func setupObserver() {
        guard let realm = try? Realm() else { return }
        
        let results = realm.objects(ItemSet.self).filter("_id == %@", itemSetId)
        setToken = results.observe { [weak self] changes in
            switch changes {
            case .initial(let sets), .update(let sets, _, _, _):
                self?.itemSet = sets.first
            case .error(let error):
                print("Error observing ItemSet: \(error)")
            }
        }
    }
    
    func deleteSet() throws {
        guard let itemSet = itemSet else { return }
        try StorageService.shared.deleteItemSet(itemSet)
    }
}
