//
//  PXLVideoListView.swift
//  PixleeSDK
//
//  Created by Csaba Toth on 2020. 10. 11..
//

import UIKit
public protocol PXLVideoListViewDelegate {
    func setupPhotoCell(cell: PXLVideoListViewCell, photo: PXLPhoto)
    func onPhotoClicked(photo: PXLPhoto)
    func onPhotoButtonClicked(photo: PXLPhoto)
    func cellHeight() -> CGFloat
    func cellPadding() -> CGFloat
}

public class PXLVideoListView: UIView {
    var collectionView: UICollectionView?
    let flowLayout = UICollectionViewFlowLayout()

    public var items: [PXLPhoto] = [] {
        didSet {
            infiniteItems = items
        }
    }

    private var infiniteItems: [PXLPhoto] = [] {
        didSet {
            collectionView?.reloadData()
        }
    }

    public var delegate: PXLVideoListViewDelegate? {
        didSet {
            setupCellSize()
        }
    }

    func setupCellSize() {
        let width = ((collectionView?.frame.size.width ?? frame.width) - cellPadding) / 2
        let height = cellHeight

        guard width > 0, height > 0 else {
            return
        }

        flowLayout.itemSize = CGSize(width: width, height: height)
        flowLayout.minimumInteritemSpacing = cellPadding
        flowLayout.minimumLineSpacing = cellPadding

        print("Size: \(flowLayout.itemSize)")
        collectionView?.collectionViewLayout.invalidateLayout()
        collectionView?.reloadData()
    }

    private var cellHeight: CGFloat {
        return delegate?.cellHeight() ?? 200
    }

    private var cellPadding: CGFloat {
        return delegate?.cellPadding() ?? 4
    }

    override public init(frame: CGRect) {
        collectionView = UICollectionView(frame: frame, collectionViewLayout: flowLayout)
        flowLayout.scrollDirection = .vertical

        super.init(frame: frame)

        if let collectionView = collectionView {
            collectionView.dataSource = self
            collectionView.prefetchDataSource = self
            collectionView.isPrefetchingEnabled = true
            collectionView.delegate = self

            collectionView.register(UINib(nibName: PXLVideoListViewCell.identifier, bundle: Bundle(for: PXLVideoListViewCell.self)), forCellWithReuseIdentifier: PXLVideoListViewCell.identifier)

            addSubview(collectionView)
            backgroundColor = .clear
            collectionView.backgroundColor = .clear

            collectionView.translatesAutoresizingMaskIntoConstraints = false
            let constraints = [
                collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
                collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
                collectionView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
                collectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            ]
            NSLayoutConstraint.activate(constraints)
            
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (_) in
                self.adjustHighlight()
            }
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        setupCellSize()
        self.adjustHighlight()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var topLeftCellIndex: IndexPath?
    var topRightCellIndex: IndexPath?
}

extension PXLVideoListView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PXLVideoListViewCell.identifier, for: indexPath) as? PXLVideoListViewCell {
            delegate?.setupPhotoCell(cell: cell, photo: items[indexPath.row])
            cell.cellWidth.constant = flowLayout.itemSize.width
            cell.cellHeight.constant = flowLayout.itemSize.height
            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
                cell.alpha = 0.5
            }
            cell.alpha = 0.5

            return cell
        }
        fatalError()
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return infiniteItems.count
    }
}

extension PXLVideoListView: UICollectionViewDataSourcePrefetching {
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard let lastIndexPath = indexPaths.last, lastIndexPath.row == infiniteItems.count - 1 else { return }

        var items = infiniteItems
        items.append(contentsOf: self.items)
        self.items = items
    }
}

extension PXLVideoListView: UICollectionViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        adjustHighlight()
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        adjustHighlight()
    }

    func adjustHighlight() {
        guard let collectionView = collectionView else { return }

        // reset the previous hight light cell
        if let cellIndex = topLeftCellIndex, let cell = collectionView.cellForItem(at: cellIndex) as? PXLVideoListViewCell {
            cell.alpha = 0.5
            cell.photoView.stopPlaying()
        }
        if let cellIndex = topRightCellIndex, let cell = collectionView.cellForItem(at: cellIndex) as? PXLVideoListViewCell {
            cell.alpha = 0.5
            cell.photoView.stopPlaying()
        }

        // set hight light to a new center cell
        let rightX = collectionView.bounds.width - flowLayout.itemSize.width / 2
        let leftX = flowLayout.itemSize.width / 2
        let topLeft = convert(CGPoint(x: leftX, y: flowLayout.itemSize.height / 2), to: collectionView)
        let topRight = convert(CGPoint(x: rightX, y: flowLayout.itemSize.height / 2), to: collectionView)

        if let index = collectionView.indexPathForItem(at: topLeft), let cell = collectionView.cellForItem(at: index) as? PXLVideoListViewCell {
            cell.alpha = 1
            cell.photoView.continuePlaying()
            topLeftCellIndex = index
        }

        if let index = collectionView.indexPathForItem(at: topRight), let cell = collectionView.cellForItem(at: index) as? PXLVideoListViewCell {
            cell.alpha = 1
            cell.photoView.continuePlaying()
            topRightCellIndex = index
        }
    }
}
