//
//  WebSocketManager.swift
//  Coin
//
//  Created by 김하은 on 12/26/23.
//

import Foundation
import Combine

final class WebSocketManager: NSObject {
    static let shared = WebSocketManager()
    
    private override init() { 
        super.init()
    }
    
    private var timer: Timer? //5초마다 ping을 하기 위해 생성
    private var webSocket: URLSessionWebSocketTask?
    private var isOpen = false //소켓 연결 상태
    
    //Rx PublishSubject -> Combine PassthroughSubject
    //Rx BehaviorSubject -> Combine CurrentValueubject
    //Combine - <데이터타입, 오류 타입>
    var orderBookSbj = PassthroughSubject<OrderBookWS, Never>()
    
    func openWebSocket() {
        let baseURL = "wss://api.upbit.com/websocket/v1"
        
        if let url = URL(string: baseURL) {
            let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            webSocket = session.webSocketTask(with: url)
            webSocket?.resume()
            ping()
        }
    }
    
    func closeWebSocket() {
        if isOpen {
            webSocket?.cancel(with: .goingAway, reason: nil)
            webSocket = nil
            timer?.invalidate() //RunLoop
            timer = nil
            isOpen.toggle()
        }
    }
    
    func send() {
        let send = """
           [{"ticket":"test"},{"type":"orderbook","codes":["KRW-BTC"]}]
        """
        
        webSocket?.send(.string(send), completionHandler: { error in
            guard let error else { return }
            print("send Error:", error)
        })
    }
    
    func receive() {
        webSocket?.receive(completionHandler: { [weak self] result in
            switch result {
            case .success(let success):
                //print("receive Success:", success)
                
                switch success {
                case .data(let data):
                    if let decodedData = try? JSONDecoder().decode(OrderBookWS.self, from: data) {
                        self?.orderBookSbj.send(decodedData) //onNext -> send
                    }
                case .string(let string): print(string)
                @unknown default: print("unknown error")
                }
                
            case .failure(let error):
                print("receive Failure:", error)
                self?.closeWebSocket()
            }
            self?.receive()
        })
    }
    
    //서버에 의해 연결이 끊어지지 않도록 주기적으로 ping을 서버에 보냄
    private func ping() {
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { [weak self] _ in
            self?.webSocket?.sendPing(pongReceiveHandler: { error in
                guard let error else { return }
                print("ping error:", error)
            })
        })
    }
}

extension WebSocketManager: URLSessionWebSocketDelegate {
    //웹소켓 연결
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Open")
        isOpen = true
        receive()
    }
    
    //웹소켓 연결 해제
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Close")
        isOpen = false
    }
}
