//
//  ViewController.swift
//  Filmbase
//
//  Created by Ernest Chechelski on 12/12/2023.
//

import UIKit
import App
import Combine

class ViewController: UIViewController {
    
    
    var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        let repo = MovieDBMoviesRepository()
        repo.firstTitle().sink { completion in
            print(completion)
        } receiveValue: { title in
            print(title)
        }.store(in: &cancellables)

      
        // Do any additional setup after loading the view.
    }
}

