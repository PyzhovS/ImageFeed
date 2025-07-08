import UIKit

final class ImagesListViewController: UIViewController {
    
    
    @IBOutlet private var tableView: UITableView!
 
    // MARK: - Properties
    private let showSingleImageIdentifier = "ShowSingleImage"
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    private let currentDate = Date()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    // MARK: - Setup Methods
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return
        }
        cell.configure(image: image,
                       date: DateFormatter.longStyle.string(from: currentDate),
                       likes: indexPath.row % 2 == 0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == showSingleImageIdentifier else {
            super.prepare(for: segue, sender: sender)
            return
        }
        guard
            let viewController = segue.destination as? SingleImageViewController, // 2
            let indexPath = sender as? IndexPath
        else {
            assertionFailure("Invalid segue destination")
            return
        }
        
        let image = UIImage(named: photosName[indexPath.row])
        viewController.image = image
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photosName.count
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
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return 0
        }
        let imageSet = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let scale = (tableView.bounds.width - imageSet.left - imageSet.right) / image.size.width
        let cellHeight = image.size.height * scale + imageSet.top + imageSet.bottom
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
