import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet private var imageButton: UIImageView!
    @IBOutlet private var likeButton: UIButton!
    @IBOutlet private var dateLabel: UILabel!
    
    //вынес функцию сюда, что бы Outlet  сделать private
    func configure ( image: UIImage, date: String, like: Bool) {
        imageButton.image = image
        dateLabel.text = date
        let isLike = like
        var like:UIImage?
        if isLike == true { like = UIImage(named: "Active") }
        else { like = UIImage(named: "No Active")}
        likeButton.setImage(like, for: .normal)
        
    }
}
