import Foundation
import SwiftKeychainWrapper
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    private init() {}
    
    private let profileImageService = ProfileImageService.shared
    private let profileService = ProfileService.shared
    private let imagesListService = ImagesListService()
    private var imageDeleteService: PhotoDeleteDelegate?
    private let token = OAuth2TokenStorage.shared.token
    
    func logout() {
        cleanCookies()
        let token: Bool = KeychainWrapper.standard.removeObject(forKey: "token")
        if token {
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
        DispatchQueue.main.async {
            if let window = UIApplication.shared.windows.first {
                let initialViewController = SplashViewController()
                window.rootViewController = initialViewController
                window.makeKeyAndVisible()
            }
        }
    }
    
    
}
