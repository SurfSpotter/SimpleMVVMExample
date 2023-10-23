//
//  ContentView.swift
//  MVVMExample(Time)
//
//  Created by Алексей Чигарских on 23.10.2023.
//

import SwiftUI
import Combine

struct ContentView : View {
    @ObservedObject var viewModel = ContentViewModel(provider: TimeProvider())
    var body: some View {
        Text(viewModel.time)
    }
}


final class ContentViewModel : ObservableObject {
    @Published var time : String = ""
    @Published var provider : TimeProvider
    var cancellabel = Set<AnyCancellable>()
    
    init(provider : TimeProvider) {
        self.provider = provider
        setupBindings()
    }
    
    func setupBindings() {
        provider
        .actualText()
            .sink { [weak self] text in
                self?.time = text
            }
            .store(in: &cancellabel)
    }
}

final class TimeProvider : ObservableObject {
    private var cancellable = Set<AnyCancellable>()
    var timer = Timer.publish(every: 1, on: .main, in: .common)
    var pSomeText = PassthroughSubject<String, Never>()

    
    init() {
        // Начать генерировать случайный текст каждую секунду
        Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] text in
                guard let self = self else { return }
                let now = Date.now
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm:ss"
                pSomeText.send(dateFormatter.string(from: now))
                            
            }
            .store(in: &cancellable)
    }
    
    func actualText() -> AnyPublisher<String, Never> {
        return pSomeText.eraseToAnyPublisher()
    }
}







struct Preview_ContentView : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
    
    
}
