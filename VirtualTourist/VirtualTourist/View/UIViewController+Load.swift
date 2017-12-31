//
//  UIViewController+Load.swift
//  VirtualTourist
//
//  Created by Rigoberto Sáenz Imbacuán on 12/30/17.
//  Copyright © 2017 Rigoberto Sáenz Imbacuán. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let actionOk = UIAlertAction(title: "OK", style: .default)
        alert.addAction(actionOk)
        present(alert, animated: true)
    }
}

private func className(some: Any) -> String {
    return (some is Any.Type) ? "\(some)" : "\(type(of: some))"
}
