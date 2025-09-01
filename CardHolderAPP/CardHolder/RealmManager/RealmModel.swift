//
//  RealmModel.swift
//  CardHolderAPP
//
//  Created by D K on 13.08.2025.
//

import Foundation
import RealmSwift

enum RarityTier: String, PersistableEnum {
    case common, uncommon, rare, superRare, ultraRare, secretRare
}

class CollectibleItem: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var title: String
    @Persisted var itemDescription: String
    @Persisted var imageData: Data?
    @Persisted var rarityRaw: RarityTier = .common
}

class ItemSet: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var name: String
    @Persisted var setDescription: String
    @Persisted var imageData: Data?
    @Persisted var isPrimary: Bool = false
    @Persisted var ownedItems: List<CollectibleItem>
    @Persisted var wishListItems: List<CollectibleItem>
    @Persisted var tradeListItems: List<CollectibleItem>
}


