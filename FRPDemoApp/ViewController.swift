//
//  ViewController.swift
//  FRPDemoApp
//
//  Created by Petr Šíma on 05/01/16.
//  Copyright © 2016 Petr Šíma. All rights reserved.
//

import UIKit
import ReactiveCocoa

class FRPDemoViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var vStack: UIStackView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //functional reactive
//        let strings = SignalProducer<String,NoError>(values:["m", "Dev", "Talk"])
        let strings = textField.rac_text.producer

//        label.rac_text <~ strings
//            .filter { $0.characters.count > 1 }
//            .map { $0.uppercaseString }

        
//        label.rac_text <~ strings
//            .reduce("", +)


//        label.rac_text <~ strings
//            .scan("", +)

        

//        label.rac_text <~ strings
//            .flatMap(.Latest) {
//                search($0)
//            }
//            .observeOn(UIScheduler())
        
//        label.rac_text <~ strings
//            .flatMap(.Latest) {
//                search($0)
//                    .flatMapError{ (error) -> SignalProducer<String,NoError> in
//                        switch error {
//                        case .QueryEmpty:
//                            return SignalProducer<String, NoError>(value: "No Results")
//                        case let .Other(underlyingError: e):
//                            return SignalProducer<String,NoError>(value: "\(e)")
//                        }
//                    }
//            }
//            .observeOn(UIScheduler())

//        label.rac_text <~ strings
//            .throttle(0.5, onScheduler: QueueScheduler.mainQueueScheduler)
//            .flatMap(.Latest) {
//                search($0)
//                    .retry(2)
//                    .flatMapError{ (error) -> SignalProducer<String,NoError> in
//                        switch error {
//                        case .QueryEmpty:
//                            return SignalProducer<String, NoError>(value: "No Results")
//                        case let .Other(underlyingError: e):
//                            return SignalProducer<String,NoError>(value: "\(e)")
//                        }
//                }
//            }
//            .observeOn(UIScheduler())

        label.rac_text <~ strings
            .throttle(0.5, onScheduler: QueueScheduler.mainQueueScheduler)
            .flatMap(.Latest) {
                search($0)
                    .on(started: { [weak self] in self?.activityIndicator.startAnimating() }, terminated: { [weak self] in self?.activityIndicator.stopAnimating() })
                    .retry(1)
                    .flatMapError{ (error) -> SignalProducer<String,NoError> in
                        switch error {
                        case .QueryEmpty:
                            return SignalProducer<String, NoError>(value: "No Results")
                        case let .Other(underlyingError: e):
                            return SignalProducer<String,NoError>(value: "\(e)")
                        }
                }
            }
            .observeOn(UIScheduler())

//            .on(started: { print("start") }, failed: { e in print("failed: \(e)") }, completed: { print("completed") }, interrupted: { print("interrupted") }, disposed: { print("disposed") } , next: { print("next: \($0)") })
        
        
        
    }

}

private let searchQueue = NSOperationQueue()

//func search(query: String) -> SignalProducer<String, NoError> {
//    return SignalProducer { sink, disposable in
//        let op = NSBlockOperation {
//            sleep(2)
//            sink.sendNext(query.uppercaseString)
//            sink.sendCompleted()
//        }
//        
//        disposable.addDisposable { op.cancel() }
//        
//        searchQueue.addOperation(op)
//    }
//}


func search(query: String) -> SignalProducer<String, SearchError> {
    return SignalProducer { sink, disposable in
        
        guard !query.isEmpty else { sink.sendFailed(.QueryEmpty); return }
        
        let op = NSBlockOperation {
            sleep(2)
            guard random() % 2 != 0 else { sink.sendFailed(.Other(underlyingError: connectionError)); return }
            sink.sendNext(query.uppercaseString)
            sink.sendCompleted()
        }

        disposable.addDisposable { op.cancel() }

        searchQueue.addOperation(op)
    }
}


var connectionError : NSError {
    return NSError(domain: "nejde net", code: 0, userInfo: nil)
}


enum SearchError: ErrorType {
    case QueryEmpty
    case Other(underlyingError: NSError)
}


//go to AppDelegate to switch to MVVM demo