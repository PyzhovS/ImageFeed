import Foundation
import SwiftKeychainWrapper
import WebKit

final class ProfileLogoutService {
   static let shared = ProfileLogoutService()
  
   private init() { }
    
    private let profileImageService = ProfileImageService.shared
    private let profileService = ProfileService.shared
    private let imagesListService = ImagesListService()
    private var imageDeleteService: PhotoDeleteDelegate?

   func logout() {
      cleanCookies()
       let removeSuccessful: Bool = KeychainWrapper.standard.removeObject(forKey: "token")
       if removeSuccessful {
           print("токен удален")
       }
       profileService.profile = nil
       profileImageService.avatarURL?.removeAll()
       imageDeleteService = imagesListService
       imageDeleteService?.photos = []
       
       navigateToInitialScreen()
   }

   private func cleanCookies() {
      HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
      WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
         records.forEach { record in
            WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
         }
      }
   }
    
    func navigateToInitialScreen() {
        if let window = UIApplication.shared.windows.first {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController")
            window.rootViewController = initialViewController
            window.makeKeyAndVisible()
        }
    }
}
