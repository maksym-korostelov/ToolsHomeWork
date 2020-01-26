//
//  LoadImageOperation.swift
//  ToolsHomeWork
//
//  Created by Maksym Korostelov on 1/17/20.
//  Copyright © 2020 Igor Kupreev. All rights reserved.
//

import UIKit

typealias ImageOperationCompletion = (() -> Void)?

final class LoadImageOperation: AsyncOperation {
    var image: UIImage?
    
    private let path: String
    private let completion: ImageOperationCompletion
    
    init(path: String, completion: ImageOperationCompletion = nil) {
        self.path = path
        self.completion = completion
        
        super.init()
    }
    
    func resizedImage(at path: String, for size: CGSize) -> UIImage? {
        guard let image = UIImage(contentsOfFile: path) else {
            return nil
        }

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    override func main() {
        if let img = MemoryCache.shared.image(forKey: path) {
            image = img
            completion?()
            self.state = .finished
        } else {
            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                guard let strongSelf = self else { return }
                let img = strongSelf.resizedImage(at: strongSelf.path, for: CGSize(width: 200, height: 200))
                strongSelf.image = img
                if let loadedImg = img {
                    MemoryCache.shared.set(loadedImg, forKey: strongSelf.path)
                }
                strongSelf.completion?()
                strongSelf.state = .finished
            }
        }
    }
}
