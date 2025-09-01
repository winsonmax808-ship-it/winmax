//
//  RealmManager.swift
//  CardHolderAPP
//
//  Created by D K on 13.08.2025.
//

import Foundation
import RealmSwift
import UIKit

final class StorageService {
    static let shared = StorageService()
    
    private let realm: Realm
    
    private init() {
        do {
            realm = try Realm()
        } catch {
            fatalError("Failed to initialize Realm: \(error)")
        }
    }
    
    private func write<T>(_ block: () throws -> T) throws -> T {
        return try realm.write(block)
    }
    
    func createItemSet(name: String, description: String, image: Data?, isPrimary: Bool) throws {
        if isPrimary {
            try write {
                let allSets = realm.objects(ItemSet.self)
                for set in allSets {
                    set.isPrimary = false
                }
            }
        }
        
        let newSet = ItemSet()
        newSet.name = name
        newSet.setDescription = description
        newSet.imageData = image
        newSet.isPrimary = isPrimary
        
        try write {
            realm.add(newSet)
        }
    }
    
    func fetchPrimarySet() -> ItemSet? {
        return realm.objects(ItemSet.self).first(where: { $0.isPrimary })
    }
    
    func fetchAllSecondarySets() -> Results<ItemSet> {
        return realm.objects(ItemSet.self).filter("isPrimary == false")
    }
    
    func deleteItemSet(_ itemSet: ItemSet) throws {
        try write {
            realm.delete(itemSet.ownedItems)
            realm.delete(itemSet.wishListItems)
            realm.delete(itemSet.tradeListItems)
            realm.delete(itemSet)
        }
    }
    
    func addItem(_ item: CollectibleItem, to list: WritableKeyPath<ItemSet, List<CollectibleItem>>, inSet itemSet: ItemSet) throws {
        try write {
            itemSet[keyPath: list].append(item)
        }
    }
    
    func removeItem(_ item: CollectibleItem, from list: WritableKeyPath<ItemSet, List<CollectibleItem>>, inSet itemSet: ItemSet) throws {
        guard let index = itemSet[keyPath: list].firstIndex(of: item) else { return }
        try write {
            itemSet[keyPath: list].remove(at: index)
        }
    }
    
    func fetchItems(from list: KeyPath<ItemSet, List<CollectibleItem>>, inSet itemSet: ItemSet) -> List<CollectibleItem> {
        return itemSet[keyPath: list]
    }
    
    func deleteAllData() throws {
        try write {
            realm.deleteAll()
        }
    }
    
    func createMockData() throws {
        guard realm.objects(ItemSet.self).isEmpty else { return }
        
        let mockSet = generateMockItemSet()
        try write {
            realm.add(mockSet)
        }
    }
    
    private func generateMockItemSet() -> ItemSet {
        let rarityTiers: [RarityTier] = [.common, .uncommon, .rare, .superRare, .ultraRare, .secretRare]
        
        let set = ItemSet()
        set.name = "Inaugural Edition"
        set.setDescription = "A groundbreaking set of cards featuring the next generation of superstars, top draft picks, and breakout rookies destined to define an era."
        set.imageData = UIImage(named: "artCol")?.jpegData(compressionQuality: 0.8)
        set.isPrimary = true
        
        // Structure: (Player Name, Description, Image ID)
        let mockItems: [(String, String, String)] = [
            // --- Soccer / Football ---
            ("Antoine Dubo", "A midfield maestro whose field vision and precise passing can unlock any defense. A true artist with the ball.", "1"),
            ("Marco Diager", "A cold-blooded striker with a predator's instinct. Give him half a chance in the box, and the ball will find the back of the net.", "5"),
            ("Lucas Marton", "The team's tireless engine. Known for his incredible work rate, covering every blade of grass from box to box.", "8"),

            // --- Basketball ---
            ("Victor Morey", "An explosive playmaker with unmatched speed and agility. His crossover is considered one of the most unstoppable moves in the league.", "3"),
            ("Leo Petiter", "A dominant force under the hoop. His shot-blocking ability and powerful rebounds make him the anchor of his team's defense.", "9"),
            ("Lars Jansenyok", "A natural-born sniper with lethal accuracy from beyond the three-point arc. His quick release makes him a constant threat on the perimeter.", "7"),

            // --- Baseball ---
            ("John 'The Hammer' Riley", "A legendary power hitter, known for his crushing home runs. When he steps up to the plate, outfielders take a step back.", "2"),
            ("Keni Tanka", "A defensive genius in the outfield with lightning-fast reflexes. His speed on the bases turns singles into extra-base hits.", "6"),

            // --- Hockey ---
            ("Sven van der Ger", "An unbreakable defenseman with a bone-crushing check. He protects the goal like a fortress and is a leader on the penalty kill.", "10")
        ]
        
        for mock in mockItems {
            let item = CollectibleItem()
            item.title = mock.0
            item.itemDescription = mock.1
            item.imageData = UIImage(named: mock.2)?.jpegData(compressionQuality: 0.8)
            item.rarityRaw = rarityTiers.randomElement()!
            set.ownedItems.append(item)
        }
        return set
    }
    
    func deleteItem(_ item: CollectibleItem) throws {
        try write {
            realm.delete(item)
        }
    }
}
