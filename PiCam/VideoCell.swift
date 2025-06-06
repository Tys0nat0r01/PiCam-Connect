//
//  VideoCell.swift
//  PiCam
//
//  Created by Tyson Miles on 6/3/2025.
//


import UIKit

class VideoCell: UICollectionViewCell {
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var fileNameLabel: UILabel!
    
    var onViewTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //private func setupCardView() {
        //cardView.layer.cornerRadius = 12
        //cardView.layer.shadowColor = UIColor.black.cgColor
        //cardView.layer.shadowOpacity = 0.2
        //cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        //cardView.layer.shadowRadius = 4
        //thumbnailImage.layer.cornerRadius = 8
        //thumbnailImage.clipsToBounds = true
    //}
    
    func configure(fileName: String, thumbnailURL: URL?) {
        fileNameLabel.text = fileName
        loadThumbnail(url: thumbnailURL)
    }
    
    private func loadThumbnail(url: URL?) {
        guard let url = url else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.thumbnailImage.image = image
                }
            }
        }.resume()
    }
    
    @IBAction func viewTapped(_ sender: UIButton) {
        onViewTapped?()
    }
}
