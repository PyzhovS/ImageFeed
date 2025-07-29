import UIKit
import SwiftKeychainWrapper

public protocol ProfileView: AnyObject {
    func displayProfile(name: String, loginName: String, bio: String, image: UIImage?)
    func showLogoutConfirmation()
}


final class ProfileViewController: UIViewController, ProfileView {
    
    
    private var presenter: ProfilePresenterProtocol!
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let token = OAuth2TokenStorage.shared.token
    private var profileImageServiceObserver: NSObjectProtocol?
    private var profileLogoutService = ProfileLogoutService.shared
    
    // MARK: - Properties
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        if let avatarImage = UIImage(named: "avatar") {
            imageView.image = avatarImage
        }
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    lazy var labelName: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .ypWhiteIOS
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 23)
        return label
    }()
    lazy var labelNik: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.textColor = .ypGrayIOS
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    lazy var labelComment: UILabel = {
        let label = UILabel()
        label.text = "Hello, world!"
        label.textColor = .ypWhiteIOS
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    private lazy var exitButton: UIButton = {
        let button = UIButton()
        if let exitImage = UIImage(named: "Exit") {
            button.setImage(exitImage, for: .normal)
        }
        button.tintColor = .ypRedIOS
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //    presenter = ProfilePresenter(view: self)
        presenter.viewDidLoad()
        view.backgroundColor = .ypBlackIOS
        setupUI()
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
        
    }
    // MARK: - Setup Methods
    func configure(_ presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        self.presenter = presenter
    }
    
    func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
    }
    func setupUI() {
        view.addSubview(imageView)
        view.addSubview(labelName)
        view.addSubview(labelNik)
        view.addSubview(labelComment)
        view.addSubview(exitButton)
        
        setupConstraint()
        
        exitButton.addTarget(self, action: #selector(exitButtonTapped), for: .touchUpInside)
    }
    
    func setupConstraint() {
        NSLayoutConstraint.activate([
            imageView.safeAreaLayoutGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            imageView.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70),
            
            labelName.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            labelName.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            labelName.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            labelNik.leadingAnchor.constraint(equalTo: labelName.leadingAnchor),
            labelNik.trailingAnchor.constraint(equalTo: labelName.trailingAnchor),
            labelNik.topAnchor.constraint(equalTo: labelName.bottomAnchor, constant: 8),
            
            labelComment.leadingAnchor.constraint(equalTo: labelNik.leadingAnchor),
            labelComment.trailingAnchor.constraint(equalTo: labelNik.trailingAnchor),
            labelComment.topAnchor.constraint(equalTo: labelNik.bottomAnchor, constant: 8),
            
            exitButton.widthAnchor.constraint(equalToConstant: 44),
            exitButton.heightAnchor.constraint(equalToConstant: 44),
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            exitButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
    }
    
    func displayProfile(name: String,
                        loginName: String,
                        bio: String,
                        image: UIImage?)
    {
        labelName.text = name
        labelNik.text = loginName
        labelComment.text = bio
        imageView.image = image
    }
    
    func showLogoutConfirmation() {
        alertExit()
    }
    
    @objc func exitButtonTapped() {
        print("Нажал кнопку выхода")
        presenter.didTapExitButton()
    }
    func alertExit(){
        
        let alert = UIAlertController(title: "Пока, Пока!", message: "Уверены что хотите выйти?", preferredStyle: .alert)
        let exitProfileYes = UIAlertAction(title: "Да", style: .cancel) { _ in
            self.profileLogoutService.logout()
        }
        let exitProfileNo = UIAlertAction(title: "Нет", style: .default, handler: nil)
        
        alert.addAction(exitProfileYes)
        alert.addAction(exitProfileNo)
        
        present(alert, animated: true, completion: nil)
    }
}
