//
//  ProfileViewControllerTest.swift
//  ImageFeedTests
//
//  Created by Eduard Karimov on 18/10/2023.
//

import XCTest
@testable import ImageFeed

final class ProfileViewControllerTest: XCTestCase {
    func testProfileViewControllerCallsViewDidLoad() {
        //given
        let profileViewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        profileViewController.presenter = presenter
        presenter.view = profileViewController
        
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertNotNil(profileViewController.presenter)
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
}
