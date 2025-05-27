import UIKit

final class ProfileViewController: UIViewController {
    // MARK: - Properties
    private let imageView = UIImageView()
    private let labelName = UILabel()
    private let labelNik = UILabel()
    private let labelComment = UILabel()
    private let exitButton = UIButton()
    
    override func viewDidLoad() {
        // MARK: - Lifecycle
        super.viewDidLoad()
        setupImageView()
        setupLabelName()
        setupLabelNik()
        setupLabelComment()
        setupExitButton()
    }
    // MARK: - Setup Methods
    private func setupImageView() {
        guard let avatarImage = UIImage(named: "avatar") else { return }
        imageView.image = avatarImage
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.safeAreaLayoutGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            imageView.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    private func setupLabelName() {
        labelName.text = "Екатерина Новикова"
        labelName.textColor = .ypWhiteIOS
        labelName.translatesAutoresizingMaskIntoConstraints = false
        labelName.font = UIFont.boldSystemFont(ofSize: 23)
        view.addSubview(labelName)
        
        NSLayoutConstraint.activate([
            labelName.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            labelName.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            labelName.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupLabelNik() {
        labelNik.text = "@ekaterina_nov"
        labelNik.textColor = .ypGrayIOS
        labelNik.translatesAutoresizingMaskIntoConstraints = false
        labelNik.font = UIFont.systemFont(ofSize: 13)
        view.addSubview(labelNik)
        
        NSLayoutConstraint.activate([
            labelNik.leadingAnchor.constraint(equalTo: labelName.leadingAnchor),
            labelNik.trailingAnchor.constraint(equalTo: labelName.trailingAnchor),
            labelNik.topAnchor.constraint(equalTo: labelName.bottomAnchor, constant: 8)
        ])
    }
    private func setupLabelComment() {
        labelComment.text = "Hello, world!"
        labelComment.textColor = .ypWhiteIOS
        labelComment.translatesAutoresizingMaskIntoConstraints = false
        labelComment.font = UIFont.systemFont(ofSize: 13)
        view.addSubview(labelComment)
        
        NSLayoutConstraint.activate([
            labelComment.leadingAnchor.constraint(equalTo: labelNik.leadingAnchor),
            labelComment.trailingAnchor.constraint(equalTo: labelNik.trailingAnchor),
            labelComment.topAnchor.constraint(equalTo: labelNik.bottomAnchor, constant: 8)
        ])
    }
    private func setupExitButton() {
        guard let exitImage = UIImage(named: "Exit") else { return }
        exitButton.setImage(exitImage, for: .normal)
        exitButton.tintColor = .ypRedIOS
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exitButton)
        
        NSLayoutConstraint.activate([
            exitButton.widthAnchor.constraint(equalToConstant: 44),
            exitButton.heightAnchor.constraint(equalToConstant: 44),
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            exitButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
    }
}
