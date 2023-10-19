//
//  ImageListViewTest.swift
//  ImageFeedTests
//
//  Created by Eduard Karimov on 18/10/2023.
//

import XCTest
@testable import ImageFeed

final class ImageListViewTest: XCTestCase {
    func testImageListViewCallsViewDidLoad() {
        // Given
        let imageListViewController = ImagesListViewController() // Создайте контроллер вручную
        let presenter = WebViewPresenterSpy()
        imageListViewController.presenter = presenter as? any ImageListViewPresenterProtocol
        presenter.view = imageListViewController as? any WebViewViewControllerProtocol
        
        // When
        presenter.viewDidLoad()
        
        // Then
        XCTAssertNotNil(imageListViewController.presenter)
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
}
