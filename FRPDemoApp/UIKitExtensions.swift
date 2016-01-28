//
//  Util.swift
//  ReactiveTwitterSearch
//
//  Created by Colin Eberhardt on 10/05/2015.
//  Copyright (c) 2015 Colin Eberhardt. All rights reserved.
//

import UIKit
import ReactiveCocoa

private struct AssociationKey {
	static var hidden: UInt8 = 1
	static var alpha: UInt8 = 2
	static var text: UInt8 = 3
	static var image: UInt8 = 4
	static var enabled : UInt8 = 5
    static var progress : UInt8 = 6
}

// lazily creates a gettable associated property via the given factory
func lazyAssociatedProperty<T: AnyObject>(host: AnyObject, _ key: UnsafePointer<Void>, factory: ()->T) -> T {
  var associatedProperty = objc_getAssociatedObject(host, key) as? T
  
  if associatedProperty == nil {
    associatedProperty = factory()
    objc_setAssociatedObject(host, key, associatedProperty, .OBJC_ASSOCIATION_RETAIN)
  }
  return associatedProperty!
}

func lazyMutableProperty<T>(host: AnyObject, _ key: UnsafePointer<Void>, _ setter: T -> (), _ getter: () -> T) -> MutableProperty<T> {
	return lazyAssociatedProperty(host, key) {
    let property = MutableProperty<T>(getter())
    property.producer
      .startWithNext {
        newValue in
        setter(newValue)
      }
    return property
  }
}

extension UIView {
  public var rac_alpha: MutableProperty<CGFloat> {
    return lazyMutableProperty(self, &AssociationKey.alpha, { [unowned self] in self.alpha = $0 }, { [unowned self] in self.alpha  })
  }
  
  public var rac_hidden: MutableProperty<Bool> {
    return lazyMutableProperty(self, &AssociationKey.hidden, { [unowned self] in self.hidden = $0 }, { [unowned self] in self.hidden  })
  }
}

extension UIImageView {
  public var rac_image: MutableProperty<UIImage?> {
    return lazyMutableProperty(self, &AssociationKey.image, { [unowned self] in self.image = $0 }, { [unowned self] in self.image })
  }
}

extension UILabel {
  public var rac_text: MutableProperty<String> {
    return lazyMutableProperty(self, &AssociationKey.text, { [unowned self] in self.text = $0 }, { [unowned self] in self.text ?? "" })
  }
}

extension UITextField {
  public var rac_text: MutableProperty<String> {
    return lazyAssociatedProperty(self, &AssociationKey.text) {
      
      self.addTarget(self, action: "changed", forControlEvents: UIControlEvents.EditingChanged)
      
      let property = MutableProperty<String>(self.text ?? "")
      property.producer
        .startWithNext { [unowned self]
          newValue in
          self.text = newValue
        }
      return property
    }
  }
  
  func changed() {
    rac_text.value = self.text ?? ""
  }
}

extension UIControl {
	public var rac_enabled : MutableProperty<Bool> {
		return lazyMutableProperty(self, &AssociationKey.enabled, { [unowned self] in self.enabled = $0 }, { [unowned self] in self.enabled })
	}
}

extension UIProgressView {
    public var rac_progress : MutableProperty<Float> {
        return lazyMutableProperty(self, &AssociationKey.progress, { [unowned self] in self.progress = $0 }, { [unowned self] in self.progress })
    }
}