//
//  ImageView.swift
//  ChatApp
//
//  Created by CubezyTech on 09/07/24.
//

import Foundation
import UIKit


class ImageLoader {
    static let shared = ImageLoader()
    
    private init() {}

    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Failed to load image:", error ?? "Unknown error")
                completion(nil)
                return
            }
            let image = UIImage(data: data)
            completion(image)
        }.resume()
    }
}
