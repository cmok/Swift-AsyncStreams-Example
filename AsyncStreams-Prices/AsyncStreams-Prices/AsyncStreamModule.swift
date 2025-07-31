//
//  ContentView.swift
//  AsyncStreams-Prices
//
//  Created by Casper Mok on 7/31/25.
//

import SwiftUI

class AsyncStreamDataProvider {
    let prices = [13259, 43532, 34154, 98765, 43210]
    
    func getAsyncStream() -> AsyncStream<Int> {
        AsyncStream { continuation in
            for (i, price) in prices.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(i)) {
                    continuation.yield(price)
                    
                    if i == self.prices.count - 1 {
                        continuation.finish()
                    }
                }
            }
        }
    }
}

class AsyncStreamViewModel: ObservableObject {
    @Published var price: Int = 0

    private let dataProvider = AsyncStreamDataProvider()
        
    @MainActor
    func getData() async {
        print("Start streaming...")
        
        for await price in dataProvider.getAsyncStream() {
            print("Stream price: \(price)")
            self.price = price
        }
        
        print("Streaming finished.")
    }
}

struct AsyncStreamModule: View {
    @StateObject private var viewModel = AsyncStreamViewModel()
    
    var body: some View {
        HStack {
            Text("BTC")
            Spacer()
            Text("$\(viewModel.price)")
        }
        .task {
            await viewModel.getData()
        }
        .padding()
    }
}

#Preview {
    AsyncStreamModule()
}
