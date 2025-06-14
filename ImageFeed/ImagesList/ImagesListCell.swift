import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet private var imageButton: UIImageView!
    @IBOutlet private var likeButton: UIButton!
    @IBOutlet private var dateLabel: UILabel!
    // MARK: - Properties
    let activeImage = UIImage(named: "Active")
    let noActiveImage = UIImage(named: "No Active")
    // MARK: - Setup Methods
    func configure ( image: UIImage, date: String, likes: Bool) {
        imageButton.image = image
        dateLabel.text = date
        let isLike = likes
        var like:UIImage?
        like = isLike ? activeImage : noActiveImage
        likeButton.setImage(like, for: .normal)        
    }
}
