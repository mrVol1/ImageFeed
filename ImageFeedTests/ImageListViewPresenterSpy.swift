//
//  ImageListViewPresenterSpy.swift
//  ImageListViewPresenterSpy
//
//  Created by Eduard Karimov on 19/10/2023.
//

import ImageFeed
import Foundation

final class ImageListViewPresenterSpy: ImageListViewControllerProtocol {
    var photos: [ImageFeed.Photo] = []
    
    func updateTableViewAnimated(withIndexPaths indexPaths: [IndexPath]) {
        
    }
    
    var presenter: ImageFeed.ImageListViewPresenterProtocol?
    var prepareResult: ImageFeed.ImageListViewPresenterProtocol?
    
    var view: ImageListViewControllerProtocol?
    var viewDidLoadCalled: Bool = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
    
    }
    
    func reloadTableView() {
        
    }
    
    func code(from url: URL) -> String? {
        return nil
    }
}
