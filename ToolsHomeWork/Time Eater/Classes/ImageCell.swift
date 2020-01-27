//
//  ImageCell.swift
//  ToolsHomeWork
//
//  Created by Maksym Korostelov on 1/17/20.
//  Copyright © 2020 Igor Kupreev. All rights reserved.
//

import UIKit

class ImageCell: UITableViewCell {
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var isLoading: Bool {
      get { return activityIndicator.isAnimating }
      set {
        if newValue {
          activityIndicator.startAnimating()
        } else {
          activityIndicator.stopAnimating()
          activityIndicator.isHidden = true
        }
      }
    }


    func display(image: UIImage?) {
      imgView.image = image
    }

}
