//
//  PrimarySetCard.swift
//  CardHolderAPP
//
//  Created by D K on 13.08.2025.
//

import SwiftUI
import RealmSwift

struct PrimarySetCard: View {
    @ObservedRealmObject var itemSet: ItemSet
    
    var body: some View {
        ZStack(alignment: .top) {
            Group {
                if let imageData = itemSet.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Image("artCol")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            }
            .frame(height: 200)
            
            
            VStack {
                HStack {
                    Text(itemSet.name)
                        .font(.headline)
                        .foregroundColor(.themePrimaryText)
                    
                    Spacer()
                    
                    Text("x\(itemSet.ownedItems.count)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.themePrimaryText)
                }
                .padding()
                .background(.thinMaterial)
                
                Spacer()
            }
        }
        .frame(height: 200)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
    }
}
