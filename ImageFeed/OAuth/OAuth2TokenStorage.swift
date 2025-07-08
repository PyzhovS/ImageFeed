import UIKit
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private init() {}
    
    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: "token")
        }
        set {
            let token = newValue
            guard let token else {
                print("Ошибка сохранение токена в KeychainWrapper")
                return}
            KeychainWrapper.standard.set(token , forKey: "token")
        }
    }
}
