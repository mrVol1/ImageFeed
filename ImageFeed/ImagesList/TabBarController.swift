//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Eduard Karimov on 21/09/2023.
//

import Foundation
import UIKit

import Foundation
import UIKit

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        print("TabBarController viewDidLoad")
        
        // Экземпляры контроллеров
        let imagesListViewController = ImagesListViewController()
        let profileViewController = ProfileViewController()
        
        // Настройка вкладок (TabBarItem) для активной и неактивной иконок
        let activeImage = UIImage(named: "tab_editorial_active")
        let inactiveImage = UIImage(named: "no_active_main")
        
        imagesListViewController.tabBarItem = UITabBarItem(
            title: nil,
            image: inactiveImage,
            selectedImage: activeImage
        )
        
        let profileActiveImage = UIImage(named: "tab_profile_active")
        let profileInactiveImage = UIImage(named: "no_active_profile")
       
        profileViewController.tabBarItem = UITabBarItem(
            title: nil,
            image: profileInactiveImage,
            selectedImage: profileActiveImage
        )
        let imagesListNavigationController = UINavigationController(rootViewController: imagesListViewController)

        let profileNavigationController = UINavigationController(rootViewController: profileViewController)

        // Установка начальных контроллеров
        self.viewControllers = [imagesListNavigationController, profileNavigationController]
        print("TabBarController: View controllers are set up.")
        
        // Устанавливаем цвет фона таббара
        tabBar.barTintColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)
        
        if let navController = viewControllers?.first as? UINavigationController {
            print("Navigation stack for tab 0:")
            for viewController in navController.viewControllers {
                print(" - \(String(describing: type(of: viewController)))")
            }
        }
        
    }
    
    
    func changeImageColor(image: UIImage?, color: UIColor) -> UIImage? {
        guard let image = image else { return nil }
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        color.setFill()
        let bounds = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        UIRectFill(bounds)
        image.draw(at: .zero, blendMode: .destinationIn, alpha: 1.0)
        let modifiedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return modifiedImage
    }
    
    func modifyImage(_ image: UIImage?, withAlpha alpha: CGFloat) -> UIImage? {
        guard let image = image else { return nil }
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(at: .zero, blendMode: .normal, alpha: alpha)
        let modifiedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return modifiedImage
    }
}
