//
//  MVVM.swift
//  FRPDemoApp
//
//  Created by Petr Šíma on 09/01/16.
//  Copyright © 2016 Petr Šíma. All rights reserved.
//

import UIKit
import ReactiveCocoa
import SDWebImage
import SnapKit
import Firebase
import Curry
import Argo

struct User {
    let firstName : String
    let lastName : String
    let photoUrl : String
}

//class ProfileViewModel {
//    let name = MutableProperty<String>("")
//    let image = MutableProperty<UIImage?>(nil)
//    
//    private let model : ConstantProperty<User>
//    init(user : User) {
//        model = ConstantProperty(user)
//        
//        name <~ model.producer.map { $0.firstName + " " + $0.lastName }
//        
//        image <~ model.producer
//            .flatMap(.Latest) { (model) -> SignalProducer<UIImage?, NoError> in
//                SignalProducer<UIImage?, NoError> { sink, dis in
//                   let operation =  SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string: model.photoUrl), options: SDWebImageOptions(), progress: nil) { image, _, _, _, _ in
//                        sink.sendNext(image); sink.sendCompleted()
//                    }
//                    dis.addDisposable {
//                        operation.cancel()
//                    }
//                }
//        }
//    }
//}


class ProfileViewController : UIViewController {
    
    let viewModel : ProfileViewModel
    init(viewModel : ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func loadView() {
        view = UIView(); view.backgroundColor = .whiteColor()
        let imageView = UIImageView()
        let label = UILabel()
        let vStack = UIStackView(arrangedSubviews: [imageView, label])
        vStack.axis = .Vertical
        view.addSubview(vStack)
        vStack.snp_makeConstraints { make in
            make.center.equalTo(view)
        }
        self.label = label
        self.imageView = imageView
    }
    
    weak var imageView : UIImageView!
    weak var label : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.rac_text <~ viewModel.name
        imageView.rac_image <~ viewModel.image
    }
    
}

extension User : Decodable {
    static func decode(json: JSON) -> Decoded<User> {
        return curry(self.init)
            <^> json <| "first_name"
            <*> json <| "last_name"
            <*> json <| "photo_url"
    }
}

extension FQuery {
    func rac_observeEventType(eventType: FEventType) -> SignalProducer<FDataSnapshot, NoError> {
        return SignalProducer { sink, dis in
            //observe firebase and send values to sink
            //use disposable to clean up
        }
    }
}


class ProfileViewModel {
    let name = MutableProperty<String>("")
    let image = MutableProperty<UIImage?>(nil)
    
    private let model : MutableProperty<User?>
    init(user : User) {
        model = MutableProperty(user)
        setupBindings()
    }
    init(firebase : Firebase) {
        model = MutableProperty(nil)
        model <~ firebase.rac_observeEventType(.Value)
            .map { snapshot in
                decode(snapshot.value).value
        }
        setupBindings()
    }
    
    private func setupBindings() {
        name <~ model.producer
            .ignoreNil()
            .map { $0.firstName + " " + $0.lastName }
        image <~ model.producer
            .ignoreNil()
            .flatMap(.Latest) { (model) -> SignalProducer<UIImage?, NoError> in
                return SignalProducer<UIImage?, NoError> { sink, dis in
                    SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string: model.photoUrl), options: SDWebImageOptions(), progress: nil) { image, _, _, _, _ in
                        sink.sendNext(image); sink.sendCompleted()
                    }
                }
        }
        
    }
    
    
    func updateName(newName : String) {
        //...
    }
    
}







