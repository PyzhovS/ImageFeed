import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    
    
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Properties
    private let imagesListService = ImagesListService()
    private let showSingleImageIdentifier = "ShowSingleImage"
    private let currentDate = Date()
    var photos: [Photo] = []
    var image: UIImage?
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
            imagesListService.fetchPhotosNextPage()
        

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTableViewAnimated),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    // MARK: - Setup Methods
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
   
        let photo = photos[indexPath.row]
        guard let url = URL(string: photo.thumbImageURL) else { return }
  
        cell.configure(with: url, date: DateFormatter.longStyle.string(from: photo.createdAt!), likes: photo.isLiked)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == showSingleImageIdentifier else {
            super.prepare(for: segue, sender: sender)
            return
        }
        guard
            let viewController = segue.destination as? SingleImageViewController,
            let indexPath = sender as? IndexPath
        else {
            assertionFailure("Invalid segue destination")
            return
        }
        viewController.image = image
    }
    
    @objc func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == imagesListService.photos.count  {
            imagesListService.fetchPhotosNextPage()
        }
        print("indexPath \(indexPath.row)")
        print(" photos\(imagesListService.photos.count)")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat  {
        
        let photo = photos[indexPath.row]
        let imageSet = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let scale = (tableView.bounds.width - imageSet.left - imageSet.right) / photo.size.width
        let cellHeight = photo.size.height * scale + imageSet.top + imageSet.bottom
        return cellHeight
    }
}

extension DateFormatter {
    static let longStyle: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
}
