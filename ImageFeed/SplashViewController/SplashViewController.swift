import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    
    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if oauth2TokenStorage.token != nil {
            switchToTabBarController()
            if let token = oauth2TokenStorage.token  {
                fetchProfile(token)
               
            }
            
        } else {
            performSegue(withIdentifier: ShowAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else { assertionFailure("Failed to prepare for \(ShowAuthenticationScreenSegueIdentifier)")
                return }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    
    func authViewController(_ vc: AuthViewController) {
        dismiss(animated: true) { [weak self] in
            guard let self else { return }
            guard let token = oauth2TokenStorage.token else {
                return
            }
            fetchProfile(token)
        }
        }
    func fetchProfile(_ token: String ) {
        UIBlockProgressHUD.show()
        profileService.fetchProfile(token: token) { [weak self] result in
            UIBlockProgressHUD.dismiss()
            
            guard let self = self else { return }
            
            switch result {
            case .success( let profile):
                self.profileImageService.fetchProfileImageURL(username:profile.userName) {_ in }
                self.switchToTabBarController()
                
            case .failure:
                // TODO [Sprint 11] Покажите ошибку получения профиля
                break
            }
        }
        
        
    }
    }
   
