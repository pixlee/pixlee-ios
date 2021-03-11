//
//  PXLAdvancedProductCell.swift
//  PixleeSDK
//
//  Created by Csaba Toth on 2020. 09. 17..
//

import Nuke
import UIKit

class PXLAdvancedProductCell: UICollectionViewCell {
    static var defaultIdentifier = "PXLAdvancedProductCell"

    @IBOutlet var cellContainer: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!

    @IBOutlet var shopBackground: UIView!
    @IBOutlet var shopIcon: UIImageView!
    @IBOutlet var bookmarkButton: UIButton!
    @IBOutlet var actionButton: UIButton!
    @IBOutlet var itemImageView: UIImageView!
    @IBOutlet var timestampButton: UIButton!
    
    var configuration: PXLProductCellConfiguration? {
        didSet {
            guard let config = configuration else { return }

            if let _ = config.bookmarkOffImage, let _ = config.bookmarkOnImage{
                bookmarkButton.isHidden = false
            }else{
                bookmarkButton.isHidden = true
            }
            
            bookmarkButton.setImage(config.bookmarkOffImage, for: .normal)

            shopIcon.image = config.shopImage

            shopBackground.backgroundColor = config.shopBackgroundColor

            if config.shopBackgroundHidden {
                shopBackground.backgroundColor = .clear
            }
        }
    }

    var onBookmarkClicked: ((_ product: PXLProduct, _ isSelected: Bool) -> Void)?

    var isBookmarked: Bool = false {
        didSet {
            guard let config = configuration else { return }

            if isBookmarked {
                bookmarkButton.setImage(config.bookmarkOnImage, for: .normal)
            } else {
                bookmarkButton.setImage(config.bookmarkOffImage, for: .normal)
            }
        }
    }

    var pxlProduct: PXLProduct? {
        didSet {
            guard let pxlProduct = pxlProduct else { return }

            cellContainer.layer.cornerRadius = 4
            cellContainer.backgroundColor = .white
            itemImageView.layer.cornerRadius = 4
            shopBackground.layer.cornerRadius = 20

            if let imageUrl = pxlProduct.imageThumbUrl {
                Nuke.loadImage(with: imageUrl, into: itemImageView)
            }else{
                itemImageView.image = nil
            }

            actionButton.setAttributedTitle(pxlProduct.attributedPrice, for: .normal)
            titleLabel.text = pxlProduct.title
            
            timestampButton.setAttributedTitle(pxlProduct.attributedTimestamp, for: .normal)
            descriptionLabel.text = pxlProduct.productDescription
        }
    }

    var actionButtonPressed: ((_ product: PXLProduct) -> Void)?

    @IBAction func actionButtonPressed(_ sender: Any) {
        if let actionPressed = actionButtonPressed, let pxlProduct = pxlProduct {
            debugPrint("actionButtonPressed")
            actionPressed(pxlProduct)
        }
    }

    @IBAction func timestampPressed(_ sender: Any) {
        debugPrint("timestampPressed")
    }
    
    @IBAction func bookmarkPressed(_ sender: Any) {
        isBookmarked.toggle()
        if let bookmarkHandling = onBookmarkClicked, let pxlProduct = pxlProduct {
            bookmarkHandling(pxlProduct, isBookmarked)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cellContainer.layer.cornerRadius = 4
    }
}
