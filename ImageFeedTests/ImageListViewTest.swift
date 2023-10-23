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
        let imageListViewControllerTest = ImagesListViewController()
        let presenter = ImageListViewPresenterSpy()
        imageListViewControllerTest.presenter = presenter as ImageListViewPresenterProtocol
        presenter.view = imageListViewControllerTest as ImageListViewControllerProtocol
        
        // When
        presenter.viewDidLoad()
        
        // Then
        XCTAssertNotNil(imageListViewControllerTest.presenter)
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
}
