//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Eduard Karimov on 18/10/2023.
//

import XCTest

class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication() // переменная приложения
    
    func configureLikeButton(_ button: XCUIElement, isLiked: Bool) {
        if isLiked {
            // Если изображение "liked", установите изображение "like_button_on"
            button.images["like_button_on"].tap()
        } else {
            // Иначе установите изображение "like_button_off"
            button.images["like_button_off"].tap()
        }
    }
    
    override func setUpWithError() throws {
        continueAfterFailure = false // настройка выполнения тестов, которая прекратит выполнения тестов, если в тесте что-то пошло не так
        
        app.launch() // запускаем приложение перед каждым тестом
    }
    
    func testAuth() throws {
        // тестируем сценарий авторизации
            app.buttons["Authenticate"].tap()
            
            let webView = app.webViews["UnsplashWebView"]
            
            XCTAssertTrue(webView.waitForExistence(timeout: 5))

            let loginTextField = webView.descendants(matching: .textField).element
            XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
            
            loginTextField.tap()
            loginTextField.typeText("eduardkarimov.rb@gmail.com")
            app.buttons["Done"].tap()
            XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
            let passwordTextField = webView.descendants(matching: .secureTextField).element
            XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
            
            passwordTextField.tap()
            passwordTextField.typeText("A2c2d2c2")
            XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))

            let webViewsQuery = webView.webViews
            webViewsQuery.buttons["Login"].tap()
            XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))

            app.buttons["Authenticate"].tap()

            let tablesQuery = app.tables
            let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
            
            XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables
        let indexPath = IndexPath(row: 0, section: 0)
        
        sleep(2)
        
        app.tables.element.swipeUp(velocity: .slow)
        
        sleep(2)
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: indexPath.row)
        configureLikeButton(cellToLike.buttons.element, isLiked: true)

        sleep(2)
        
        let dislikeButtonIdentifier = "like_button_off_\(indexPath.row)"
        app.buttons[dislikeButtonIdentifier].tap()
        
        let likeButtonIdentifier = "like_button_on_\(indexPath.row + 1)"
        app.buttons[likeButtonIdentifier].tap()
        
        sleep(2)
        
        cellToLike.tap()
        
        sleep(2)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        // Zoom in
        image.pinch(withScale: 3, velocity: 1)
        // Zoom out
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["didTapBackButton"]
        navBackButtonWhiteButton.tap()
    }

    
    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
        sleep(2)
        XCTAssertTrue(app.staticTexts["Eduard Karimov"].exists)
        XCTAssertTrue(app.staticTexts["@EduardKarimov"].exists)
        
        app.buttons["logOut"].tap()
        
        app.alerts["Вы точно хотите выйти?"].scrollViews.otherElements.buttons["Да"].tap()
    }
}
