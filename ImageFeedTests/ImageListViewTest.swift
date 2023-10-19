//
//  ImageListViewTest.swift
//  ImageFeedTests
//
//  Created by Eduard Karimov on 18/10/2023.
//

import XCTest
@testable import ImageFeed

final class ImageListViewTest: XCTestCase {
    func testImageListViewCallsViewDidLoad () {
        //given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let imageListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let presenter = WebViewPresenterSpy()
        imageListViewController.presenter = presenter as? any ImageListViewPresenterProtocol
        presenter.view = imageListViewController as? any WebViewViewControllerProtocol
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertNotNil(imageListViewController.presenter)
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
}
