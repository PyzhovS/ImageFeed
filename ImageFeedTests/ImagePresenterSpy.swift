import Foundation
import UIKit
@testable import ImageFeed

class ImagePresenterSpy: ImagesListViewPresenterProtocol {
    var photos: [Photo] = []
    
    var view: (any ImageFeed.ImagesListViewProtocol)?
    var viewDidLoadCalled = false
    var willDisplayCellCalled = false
    var calculateCellHeightCalled = false
    var changeLikeCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func willDisplayCell(at indexPath: IndexPath) {
        willDisplayCellCalled = true
    }
    
    func calculateCellHeight(for indexPath: IndexPath, tableView: UITableView) -> CGFloat {
        calculateCellHeightCalled = true
        return 100.0
    }
    
    func changeLike(at indexPath: IndexPath, isLikes: Bool) {
        changeLikeCalled = true
    }
}
