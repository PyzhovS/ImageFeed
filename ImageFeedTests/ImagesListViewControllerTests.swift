import XCTest
@testable import ImageFeed

final class ImagesListViewControllerTests: XCTestCase {
    func testViewDidLoadCallsPresenter() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as! ImagesListViewController
        
        let imagePresenterSpy = ImagePresenterSpy()
        viewController.presenter = imagePresenterSpy
        
        
        viewController.loadViewIfNeeded()
        
        XCTAssertTrue(imagePresenterSpy.viewDidLoadCalled)
    }
    
    func testTableViewDelegatesSetup() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as! ImagesListViewController
        
        let imagePresenterSpy = ImagePresenterSpy()
        viewController.presenter = imagePresenterSpy
        
        
        viewController.loadViewIfNeeded()
        
        XCTAssertNotNil(viewController.tableView.dataSource)
        XCTAssertNotNil(viewController.tableView.delegate)
    }
    
    func testCellConfiguration() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as! ImagesListViewController
        
        let imagePresenterSpy = ImagePresenterSpy()
        viewController.presenter = imagePresenterSpy
        
        
        
        let testPhoto = Photo(
            id: "test",
            size: CGSize(width: 100, height: 100),
            createdAt: Date(),
            welcomeDescription: "Test",
            thumbImageURL: "https://example.com/thumb.jpg",
            largeImageURL: "https://example.com/large.jpg",
            fullUmageUrl: "https://example.com/full.jpg",
            isLiked: false
        )
        imagePresenterSpy.photos = [testPhoto]
        
        
        viewController.loadViewIfNeeded()
        let tableView = viewController.tableView!
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = tableView.dataSource?.tableView(
            tableView,
            cellForRowAt: indexPath
        ) as! ImagesListCell
        
        
        XCTAssertEqual(cell.likeButton.currentImage, cell.noActiveImage)
    }
}
