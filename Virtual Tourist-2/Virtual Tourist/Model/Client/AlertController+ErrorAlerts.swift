//
//  AlertController+ErrorAlerts.swift
//  Virtual Tourist
//
//  Created by bhuvan on 20/04/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import UIKit

struct Alert {
    static let titleText = "Error"
    static let okayActionText = "OK"
    static let defaultErrorMessage = "Oops! something went wrong. Try again."
    
    static func show(on vc: UIViewController, message: String? = defaultErrorMessage) {
        let alertController = UIAlertController(title: titleText, message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: okayActionText, style: .default, handler: nil)
        alertController.addAction(okayAction)
        vc.present(alertController, animated: true, completion: nil)
    }
}
