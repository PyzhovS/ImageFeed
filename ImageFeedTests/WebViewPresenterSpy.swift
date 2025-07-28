import ImageFeed
import Foundation

final class WebViewPresenterSpy: WebViewPresenterProtocol {
    var view: (any ImageFeed.WebViewViewControllerProtocol)?
    var loadAuthViewCalles: Bool = false
  
    
    
    func loadAuthView() {
        loadAuthViewCalles = true
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
     
    }
    
    func code(from url: URL) -> String? {
      return nil
    }
    
   
}
