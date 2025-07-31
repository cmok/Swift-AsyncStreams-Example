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
            for i in 0 ..< prices.count {
                let price = prices[i]
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(i)) {
                    continuation.yield(price)
                }
            }
        }
    }
    
    func getData(completeWith: @escaping (Int) -> Void) {
        for i in 0 ..< prices.count {
            let price = prices[i]
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(i)) {
                completeWith(price)
            }
        }
    }
}

class AsyncStreamViewModel: ObservableObject {
    @Published var price: Int = 0

    private let dataProvider = AsyncStreamDataProvider()
    
//    init() {
//        getDataWithCompletion()
//    }
    
    func getData() async {
        for await price in dataProvider.getAsyncStream() {
            self.price = price
        }
    }

    func getDataWithCompletion() {
        dataProvider.getData { [weak self] price in
            self?.price = price
        }
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
