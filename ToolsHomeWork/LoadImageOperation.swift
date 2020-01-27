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
                strongSelf.loadRandomImage { image in
                    let img: UIImage? = image ??
                        strongSelf.resizedImage(at: strongSelf.path, for: CGSize(width: 200, height: 200))
                    
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
    
    func loadRandomImage(completionHandler: @escaping (UIImage?) -> Void) {
        NetworkServise.getRandomImageUrl { (result) in
            switch result {
            case .success(let url):
                if let data = try? Data(contentsOf: url) {
                    if let image = UIImage(data: data) {
                        completionHandler(image)
                    } else {
                        completionHandler(nil)
                    }
                }
            case .failure(let error):
                debugPrint(error.localizedDescription)
                completionHandler(nil)
            }
        }
    }
}

enum RequestDataError: Error {
    case somethingWentWrong
    case parsingFailed
}

enum NetworkServise {
    static func getRandomImageUrl(completionHandler: @escaping (Result<URL, RequestDataError>) -> Void) {
        
        guard let url = URL(string:
        "https://6e2c8dd0-0b42-4ece-bdc2-1e98d7e1a017.mock.pstmn.io/randomImageUrl") else {
            completionHandler(.failure(RequestDataError.somethingWentWrong))
            return
        }
        
        requestImageUrlData(url: url) { result in
            switch result {
            case .failure(let error):
                debugPrint(error.localizedDescription)
                completionHandler(.failure(.somethingWentWrong))
            case .success(let data):
                if let result = parseImageUrl(data) {
                    completionHandler(.success(result))
                } else {
                    completionHandler(.failure(.parsingFailed))
                }
            }
        }
    }
    
    static private func parseImageUrl(_ data: Data) -> URL? {
        do{
            //here dataResponse received from a network request
            let jsonResponse = try JSONSerialization.jsonObject(with:
                data, options: [])
            debugPrint(jsonResponse) //Response result
            
            guard let jsonArray = jsonResponse as? [String: Any] else {
                return nil
            }
            debugPrint(jsonArray)
            guard let urlString = jsonArray["url"] as? String,
                let url = URL(string: urlString) else { return nil }
            return url
        } catch let parsingError {
            debugPrint("Error", parsingError)
        }
        return nil
    }
    
    static func requestImageUrlData(url: URL, completionHandler: @escaping (Result<Data, Error>) -> Void) {
        DispatchQueue.global().async {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    completionHandler(.failure(error))
                } else {
                    if let response = response as? HTTPURLResponse {
                        print("statusCode: \(response.statusCode)")
                    }
                    if let data = data {
                        completionHandler(.success(data))
                    }
                }
            }
            task.resume()
        }
    }
}
