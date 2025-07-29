@testable import ImageFeed
import XCTest

final class ProfileTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoadOnPresenter() {
        let presenterSpy = PresenterSpy()
        let sut = ProfileViewController()
        
        sut.configure(presenterSpy)
        sut.viewDidLoad()
        
        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }

    func testViewControllerCallsDidTapExitButtonOnPresenter() {
        let presenterSpy = PresenterSpy()
        let sut = ProfileViewController()
        
        sut.configure(presenterSpy)
        sut.exitButtonTapped()
        
        XCTAssertTrue(presenterSpy.didTapExitButtonCalled)
    }
    
    func testUpdateLabel() {
        let sut = ProfileViewController()
        
        sut.displayProfile(name: "тест", loginName:"тест", bio: "тест", image: UIImage(named: "тест"))
        
        XCTAssertEqual(sut.labelName.text, "тест")
        XCTAssertEqual(sut.labelNik.text, "тест")
        XCTAssertEqual(sut.labelComment.text, "тест")
        XCTAssertEqual(sut.imageView.image, UIImage(named: "тест"))
    
    }

}

