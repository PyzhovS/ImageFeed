import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet private var imageButton: UIImageView!
    @IBOutlet private var likeButton: UIButton!
    @IBOutlet private var dateLabel: UILabel!
    var delegate : ImagesList?
    var indexPatch: IndexPath?
    var imagesListService: ImagesListService?
    var imageDownloadTask: DownloadTask?
    private var photoId: String?

    @IBAction private func likeTapped() {
      
        guard let imagesListService, let photoId else {return}
        
        let isLike = likeButton.currentImage == noActiveImage
        
        imagesListService.changeLike(photoId: photoId, isLike: isLike) { result in
            DispatchQueue.main.async {
                self.delegate = ImagesListViewController()
            switch result {
                case .success:
                    print("Лайк успешно изменён.")
                self.delegate?.photos = imagesListService.photos
                var newLikeImage: UIImage?
                let likes = self.delegate?.photos[self.indexPatch!.row].isLiked
                guard let likes else {return}
                newLikeImage = likes ? self.activeImage : self.noActiveImage
                self.likeButton.setImage(newLikeImage, for: .normal)
                case .failure(let error):
                    print("Ошибка изменения лайка: \(error.localizedDescription)")
                }
            }
            
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
    func configure (with url: URL, date: String, likes: Bool, photoId : String , service: ImagesListService,indexPath: IndexPath  ) {
        self.indexPatch = indexPath
        self.photoId = photoId
        self.imagesListService = service
        
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

