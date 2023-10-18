//
//  WebViewViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Eduard Karimov on 18/10/2023.
//

import ImageFeed
import Foundation

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var loadRequestCalled: Bool = false
    
    func setRequest(_ request: URLRequest) {
        
    }
    
    func load() {
        loadRequestCalled = true
    }
    
    var presenter: ImageFeed.WebViewPresenterProtocol?
    
    func setProgressValue(_ newValue: Float) {
        
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        
    }
}
