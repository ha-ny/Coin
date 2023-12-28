//
//  SocketView.swift
//  Coin
//
//  Created by 김하은 on 12/26/23.
//

import SwiftUI

struct SocketView: View {
    
    @StateObject
    private var viewModel = SocketViewModel()
    
    var body: some View {
        VStack {
            ForEach(viewModel.askOrderBook, id: \.id) { item in
                Text("\(item.price)")
            }
        }.padding()
    }
}

#Preview {
    SocketView()
}
