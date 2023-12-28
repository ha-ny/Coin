//
//  SocketViewModel.swift
//  Coin
//
//  Created by 김하은 on 12/26/23.
//

import Foundation
import Combine

class SocketViewModel: ObservableObject {
    
    @Published
    var askOrderBook: [OrderbookItem] = []
    
    @Published
    var bidOrderBook: [OrderbookItem] = []
    
    private var cancellabel = Set<AnyCancellable>() //dispose
    
    init() {
        WebSocketManager.shared.openWebSocket()
        WebSocketManager.shared.send()
        //subscribe -> sink
        //schedular main -> receive
        WebSocketManager.shared.orderBookSbj
            .receive(on: DispatchQueue.main)
            .sink { [weak self] order in
                guard let self else { return }
                self.askOrderBook = order.orderbookUnits
                    .map { .init(price: $0.askPrice, size: $0.askSize) }
                    .sorted { $0.price > $1.price }
                self.bidOrderBook = order.orderbookUnits
                    .map { .init(price: $0.bidPrice, size: $0.bidSize) }
                    .sorted { $0.price > $1.price }
            }
            .store(in: &cancellabel)
    }
    
    deinit {
        WebSocketManager.shared.closeWebSocket()
    }
}
