import UIKit

final class ProfileViewController: UIViewController {
    
    private let profileService = ProfileService()
    private let token = OAuth2TokenStorage.shared.token
    
  
    
    // MARK: - Properties
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        if let avatarImage = UIImage(named: "avatar") {
            imageView.image = avatarImage
        }
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private lazy var labelName: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.textColor = .ypWhiteIOS
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 23)
        return label
    }()
    private lazy var labelNik: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.textColor = .ypGrayIOS
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    private lazy var labelComment: UILabel = {
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
        fetchUserProfile()
        setupUI()
    }
    // MARK: - Setup Methods
    
    func setupUI() {
        view.addSubview(imageView)
        view.addSubview(labelName)
        view.addSubview(labelNik)
        view.addSubview(labelComment)
        view.addSubview(exitButton)
        
        setupConstraint()
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
    
    private func fetchUserProfile() {
        profileService.fetchProfile(token: token!) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let profile):
                        self?.labelName.text = "\(profile.firstName) \(profile.lastName)"
                        self?.labelNik.text = "@\(profile.userName)"
                        self?.labelComment.text = profile.bio
                        print("Профиль успешно загружен.")
                    case .failure(let error):
                        print("Ошибка загрузки профиля: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

