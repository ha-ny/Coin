//
//  ContentView.swift
//  Coin
//
//  Created by 김하은 on 12/26/23.
//

import SwiftUI

struct ContentView: View {
    
    @State
    private var showNextPage = false
    
    var body: some View {
        VStack {
            Button("데이터 보여주기") {
                showNextPage = true
            }
        }
        .padding()
        .sheet(isPresented: $showNextPage, content: {
            SocketView()
        })
    }
}

#Preview {
    ContentView()
}
