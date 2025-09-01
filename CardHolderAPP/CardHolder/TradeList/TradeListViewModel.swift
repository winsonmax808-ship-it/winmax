//
//  TradeListViewModel.swift
//  CardHolderAPP
//
//  Created by D K on 13.08.2025.
//

import Foundation
import RealmSwift
import Combine
import SwiftUI

@MainActor
class TradeListViewModel: ObservableObject {
    @Published var itemSet: ItemSet
    @Published var items: Results<CollectibleItem>
    
    @Published var itemToShare: ShareableImage?
    @Published var isGeneratingShareImage = false
    
    private var token: NotificationToken?
    
    init(itemSet: ItemSet) {
        self.itemSet = itemSet
        self.items = itemSet.tradeListItems.sorted(byKeyPath: "title")
        
        token = self.items.observe { [weak self] _ in
            self?.objectWillChange.send()
        }
    }
    
    deinit {
        token?.invalidate()
    }
    
    @MainActor
    func prepareShareableImage() {
        isGeneratingShareImage = true
        
        Task {
            await MainActor.run {
                let viewToRender = ShareableSetView(itemSet: self.itemSet, listType: .trade)
                let renderer = ImageRenderer(content: viewToRender)
                
                let cardHeight: CGFloat = 140
                let cardSpacing: CGFloat = 16
                let verticalPadding: CGFloat = 20
                let headerHeight: CGFloat = 60
                let numberOfRows = ceil(Double(self.itemSet.tradeListItems.count) / 3.0)
                let totalHeight = (numberOfRows * cardHeight) + ((numberOfRows - 1) * cardSpacing) + headerHeight + (verticalPadding * 2)
                
                renderer.proposedSize = ProposedViewSize(width: 400, height: totalHeight)
                renderer.scale = UIScreen.main.scale
                
                if let image = renderer.uiImage {
                    self.itemToShare = ShareableImage(image: image)
                }
                
                isGeneratingShareImage = false
            }
        }
    }
}
