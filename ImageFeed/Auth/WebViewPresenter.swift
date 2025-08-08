import Foundation
import UIKit

public protocol WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol? { get set }
    func loadAuthView()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
}

class WebViewPresenter: WebViewPresenterProtocol {
    
    var authHelper: AuthHelperProtocol
    
    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }
    
    func code(from url: URL) -> String? {
        authHelper.code(from: url)
    }
    
    func loadAuthView() {
        guard let request = authHelper.authRequest() else {
            return
        }
        
        didUpdateProgressValue(0)
        view?.load(request: request)
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)
        
        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }
    
    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
    
    weak var view: (any WebViewViewControllerProtocol)?
    
}
