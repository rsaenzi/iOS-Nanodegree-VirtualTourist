//
//  UIViewController+Load.swift
//  VirtualTourist
//
//  Created by Rigoberto Sáenz Imbacuán on 12/30/17.
//  Copyright © 2017 Rigoberto Sáenz Imbacuán. All rights reserved.
//

import UIKit

extension UIViewController {
    
    /**
     This function works if the UIViewController class, the Storyboard file,
     and the Storyboard Id of the Scene are the same
     */
    func loadViewController<T: UIViewController>(from bundle: Bundle = .main) -> T {
        
        let identifier = className(some: T.self)
        let storyboard = UIStoryboard(name: identifier, bundle: bundle)
        
        guard let screen = storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
            fatalError("UIViewController with identifier '\(identifier)' was not found")
        }
        return screen
    }
}

private func className(some: Any) -> String {
    return (some is Any.Type) ? "\(some)" : "\(type(of: some))"
}
