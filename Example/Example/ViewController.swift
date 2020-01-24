//
//  ViewController.swift
//  Example
//
//  Created by Csaba Toth on 2020. 01. 08..
//  Copyright © 2020. Pixlee. All rights reserved.
//

import PixleeSDK
import UIKit

class ViewController: UIViewController {
    let album = PXLAlbum(identifier: "5984962")

    override func viewDidLoad() {
        super.viewDidLoad()
        //        #warning Replace with your Pixlee API key.
        PXLClient.sharedClient.apiKey = "ccWQFNExi4gQjyNYpOEf"
        //        #warning Replace with your Secret Key if you are making POST requests.
        PXLClient.sharedClient.secretKey = "b3b38f4322877060b2e4f390fd"

//        var filterOptions = PXLAlbumFilterOptions(minInstagramFollowers: 1)
//        let dateString = "20190101"
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyyMMdd"
//        let date = dateFormatter.date(from: dateString)
//
//        filterOptions = filterOptions.changeSubmittedDateStart(newSubmittedDateStart: date)
//
//        PXLAlbumFilterOptions(submittedDateStart: date)
//        album.filterOptions = filterOptions
        album.sortOptions = PXLAlbumSortOptions(sortType: .popularity, ascending: false)

        // Get one photo example
        _ = PXLClient.sharedClient.getPhotoWithPhotoAlbumId(photoAlbumId: "353880700") { newPhoto, error in
            guard error == nil else {
                print("Error during load of image with Id \(String(describing: error))")
                return
            }
            guard let photo = newPhoto else {
                print("cannot find photo")
                return
            }
            print("New Photo: \(photo.albumPhotoId)")
            
            _ = PXLAnalyitcsService.sharedAnalyitcs.logEvent(event: PXLAnalyticsEventOpenedLightBox(photo: photo)) { error in
                if let error = error {
                    print("🛑 Error during analyitcs call:\(error)")
                }
            }
            _ = PXLAnalyitcsService.sharedAnalyitcs.logEvent(event: PXLAnalyticsEventActionClicked(photo: photo, actionLink: "Linkecske")) { error in
                if let error = error {
                    print("🛑 Error during analyitcs call:\(error)")
                }
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        let albumVC = PXLAlbumViewController.viewControllerForAlbum(album:album)
        showViewController(VC: albumVC)
    }

    func showViewController(VC: UIViewController) {
        VC.willMove(toParent: self)
        addChild(VC)
        VC.view.frame = view.bounds
        view.addSubview(VC.view)
        VC.didMove(toParent: self)
    }
}
