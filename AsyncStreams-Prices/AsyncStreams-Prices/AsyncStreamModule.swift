//
//  ContentView.swift
//  AsyncStreams-Prices
//
//  Created by Casper Mok on 7/31/25.
//

import SwiftUI

class AsyncStreamDataProvider {    
    func getAsyncStream() -> AsyncStream<Int> {
        AsyncStream { continuation in
            
            continuation.onTermination = { _ in
                print("Handle termination event... such as tear down")
            }
            
            Task {
                while !Task.isCancelled {
                    try? await Task.sleep(for: .milliseconds(1000))
                    continuation.yield(Int.random(in: 10000...99999))
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
        
        print("Streaming finished...")
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
