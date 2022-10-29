//
//  ErrorController.swift
//  rick&Morty
//
//  Created by Давид Тоноян  on 30.10.2022.
//

import UIKit

final class ErrorController {
    static let shared = ErrorController()
    
    func createErrorController(error: ApiError, action: @escaping (UIAlertAction) -> Void) -> UIAlertController {
        let errorMessage = "Ошибка - \(error.localizedDescription)"
        let alertController = UIAlertController(title: nil, message: errorMessage, preferredStyle: .actionSheet)
        let alertReloadAction = UIAlertAction(title: "Reload", style: .default, handler: action)
        let alertCancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(alertReloadAction)
        alertController.addAction(alertCancelAction)
        return alertController
    }
}
