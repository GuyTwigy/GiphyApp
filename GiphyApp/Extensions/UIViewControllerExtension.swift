//
//  UIViewControllerExtension.swift
//  GiphyApp
//
//  Created by Guy Twig on 04/04/2024.
//

import UIKit

extension UIViewController {
    
    func presentAlert(withTitle title: String, message : String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "אישור", style: .default) { action in
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func presentAlertWithAction(withTitle title: String, message : String, complition: @escaping () -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "אישור", style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.dismiss(animated: true, completion: complition)
        }
        let cancelAction = UIAlertAction(title: "ביטול", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func addRefreshControl(to scrollView: UIScrollView, action: Selector) {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: action, for: .valueChanged)
        scrollView.refreshControl = refreshControl
    }

    func endRefreshing(scrollView: UIScrollView) {
        scrollView.refreshControl?.endRefreshing()
    }
}
