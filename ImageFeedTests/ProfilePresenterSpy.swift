import ImageFeed
import Foundation

final class PresenterSpy: ProfilePresenterProtocol  {
    var view: ProfileView?
    var viewDidLoadCalled = false
    var didTapExitButtonCalled = false
    
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didTapExitButton() {
        didTapExitButtonCalled = true
    }
}
