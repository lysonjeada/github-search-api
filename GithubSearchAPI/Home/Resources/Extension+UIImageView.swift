//
//  Extension+UIImageView.swift
//  GithubSearchAPI
//
//  Created by Amaryllis Baldrez on 09/06/25.
//

import UIKit

extension UIImageView {
    func load(url: URL?) {
        DispatchQueue.global().async {
            guard let imageURL = url else {
                return DispatchQueue.main.async { self.image = UIImage(named: "no-image-avaiable") }
            }
            if let data = try? Data(contentsOf: imageURL),
               let image = UIImage(data: data) {
                DispatchQueue.main.async { self.image = image }
            }
        }
    }
}
