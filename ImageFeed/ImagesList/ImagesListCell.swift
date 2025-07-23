import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet private var imageButton: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet private var dateLabel: UILabel!
    
    private var imageDownloadTask: DownloadTask?
    
    var setIsLiked: (() -> Void)?
    
    @IBAction private func likeTapped() {
        if let setIsLiked = setIsLiked {
            setIsLiked()
        }
        
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        imageButton.kf.cancelDownloadTask()
    }
    
    // MARK: - Properties
    let photoSet = UIImage(named:"Stuboff")
    let activeImage = UIImage(named: "Active")
    let noActiveImage = UIImage(named: "No Active")
    
    // MARK: - Setup Methods
    func configure (with url: URL, date: String, likes: Bool) {
        
        dateLabel.text = date
        
        var like:UIImage?
        like = likes ? activeImage : noActiveImage
        likeButton.setImage(like, for: .normal)
        
        imageButton.kf.indicatorType = .activity
        imageDownloadTask = imageButton.kf.setImage(
            with: url,
            placeholder: photoSet,
            options: [. transition(. fade(0.2))],
            completionHandler: { result in
                switch result {
                case .success:
                    print("Данные успешно загружаны ")
                case .failure(let error):
                    print("Error loading image: \(error)")
                }
            }
        )
    }
}
