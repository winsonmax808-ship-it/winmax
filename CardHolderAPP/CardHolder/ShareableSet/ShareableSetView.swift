//
//  ShareableSetView.swift
//  CardHolderAPP
//
//  Created by D K on 13.08.2025.
//

import SwiftUI
import RealmSwift


enum ShareableListType {
    case owned, wishlist, trade
}

struct ShareableSetView: View {
    let itemSet: ItemSet
    var listType: ShareableListType = .owned
    
    private let gridColumns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
    private var itemsToDisplay: RealmSwift.List<CollectibleItem> {
        switch listType {
        case .owned:
            return itemSet.ownedItems
        case .wishlist:
            return itemSet.wishListItems
        case .trade:
            return itemSet.tradeListItems
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text(itemSet.name)
                .font(.largeTitle).bold()
                .foregroundColor(.white)
            
            LazyVGrid(columns: gridColumns, spacing: 16) {
                ForEach(itemsToDisplay) { item in
                    GridItemCell(item: item)
                }
            }
        }
        .padding()
        .background(Color.themeBackground)
    }
}
