import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
  
    // MARK: - Properties
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        if let avatarImage = UIImage(named: "LaunchScreen") {
            imageView.image = avatarImage
        }
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        view.backgroundColor = .ypBackgroundIOS
        super.viewDidLoad()
        setupUI()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let token = oauth2TokenStorage.token  {
            fetchProfile(token)
        } else {
            presentAuthViewController()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - Setup Methods
    func setupUI() {
        view.addSubview(imageView)
        setupConstraint()
    }
    
    func setupConstraint() {
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 75),
            imageView.heightAnchor.constraint(equalToConstant: 78),
        ])
    }
    
    func presentAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController {
            authViewController.delegate = self
            authViewController.modalPresentationStyle = .fullScreen
            present(authViewController, animated: true, completion: nil)
        }
    }
    
   
    
    private func switchToTabBarController() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
            let tabBarController = UIStoryboard(name: "Main", bundle: .main)
                .instantiateViewController(withIdentifier: "TabBarViewController")
            window.rootViewController = tabBarController
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    
    func authViewController(_ vc: AuthViewController) {
        dismiss(animated: true) { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async{
                guard let token = self.oauth2TokenStorage.token else {
                    return
                }
                self.fetchProfile(token)
            }
        }
    }
    func fetchProfile(_ token: String ) {
        UIBlockProgressHUD.show()
        profileService.fetchProfile(token: token) { [weak self] result in
            UIBlockProgressHUD.dismiss()
            
            guard let self else { return }
            
            switch result {
            case .success(let profile ):
                self.switchToTabBarController()
                self.profileImageService.fetchProfileImageURL(username: profile.userName) { _ in }
                
            case .failure(let error):
                showAlert()
                print("[fetchProfile] - Ошибка получение профиля: \(error) ")
                break
            }
        }
    }
    func showAlert() {
        let alertController = UIAlertController(title: "Что-то пошло не так",
                                                message: "Не удалось войти в систему",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)

    }
}
