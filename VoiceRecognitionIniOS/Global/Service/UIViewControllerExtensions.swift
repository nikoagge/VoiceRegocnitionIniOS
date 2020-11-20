//
//  UIViewControllerExtensions.swift
//  VoiceRecognitionIniOS
//
//  Created by Nikolas Aggelidis on 20/11/20.
//

import UIKit

extension UIViewController {
    func displayAlertController(with message: String) {
        let alertController = UIAlertController(title: "Error occured!", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            alertController.dismiss(animated: true)
        }))
        self.present(alertController, animated: true)
    }
}
