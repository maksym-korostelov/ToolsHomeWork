//
//  TimeEaterFlowController.swift
//  MealTime
//
//  Created by Igor Kupreev on 9/16/18.
//  Copyright © 2018 Igor Kupreev. All rights reserved.
//

import UIKit


class TimeEaterFlowController: UIViewController {

    @IBOutlet private var table: UITableView!
    var files = [String]()
    var isNeedToReload: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let fm = FileManager.default
        if let path = Bundle.main.resourcePath,
            let items = try? fm.contentsOfDirectory(atPath: path){
            for item in items where item.hasPrefix("img"){
                files.append(item)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isNeedToReload ?? false {
            isNeedToReload = nil
            table.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func didTapCloseButton(sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}


extension TimeEaterFlowController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "ImageCell")
        
        let file = files[indexPath.row]
        if let path = Bundle.main.path(forResource: file, ofType: ""){
            let img = UIImage(contentsOfFile: path)
            cell.imageView?.image = img
            if let loadedImg = img {
                MemoryCache.shared.set(loadedImg, forKey: path)
            }
        }
        
        if let iv = cell.imageView {
            iv.contentMode = .scaleAspectFill
            iv.layer.shadowColor = UIColor.darkGray.cgColor
            iv.layer.shadowOpacity = 0.8
            iv.layer.shadowRadius = 12
        }
        
        return cell
    }

}

extension TimeEaterFlowController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let details = TimeEaterChildViewController()
        
        details.file = files[indexPath.row]
        details.owner = self
        
        navigationController?.pushViewController(details, animated: true)
        
    }
}
