import Foundation
import UIKit


public protocol ProfilePresenterProtocol: AnyObject {
func viewDidLoad()
func didTapExitButton()
}

final class ProfilePresenter:ProfilePresenterProtocol{
    func viewDidLoad() {
        if let profile = profileService.profile {
            view?.displayProfile(name: profile.name, loginName: profile.loginName, bio: profile.bio, image: profileImageService.image)
        }
    }
    
    func didTapExitButton() {
        view?.showLogoutConfirmation()
    }
    
    
    private weak var view: ProfileView?
        private let profileService: ProfileService
        private let profileImageService: ProfileImageService
        private let profileLogoutService: ProfileLogoutService

        init(view: ProfileView,
             profileService: ProfileService = .shared,
             profileImageService: ProfileImageService = .shared,
             profileLogoutService: ProfileLogoutService = .shared) {
            self.view = view
            self.profileService = profileService
            self.profileImageService = profileImageService
            self.profileLogoutService = profileLogoutService
        }

    
}
