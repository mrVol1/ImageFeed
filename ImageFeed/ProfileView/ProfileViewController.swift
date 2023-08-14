//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Eduard Karimov on 14/08/2023.
//

import Foundation
import UIKit

final class ProfileViewController: UIViewController {
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var labelNameView: UILabel!
    @IBOutlet private var tagNameView: UILabel!
    @IBOutlet private var discriptionView: UILabel!
    @IBOutlet private var exitButton: UIButton!
    @IBAction private func exitButton(sender: UIButton){}
}
