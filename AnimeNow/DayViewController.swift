//
//  DayViewController.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 7/4/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import ANParseKit
import SDWebImage
import Alamofire
import ANCommonKit
import XLPagerTabStrip


class DayViewController: UIViewController {
    
    var animator: ZFModalTransitionAnimator!
    var dayString: String = ""
    var dataSource: [[Anime]] = []
    var section: Int = 0
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    func initWithTitle(title: String, section: Int) {
        dayString = title
        self.section = section
    }

    func updateDataSource(dataSource: [Anime]) {
        
        
        let ids = dataSource.map() { (var anime) -> Int in
            return anime.myAnimeListID
        }
        
        // Find existing on library
        
        LibrarySyncController.fetchAnimeFromLocalDatastore(ids).continueWithExecutor( BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task: BFTask!) -> AnyObject! in
            
            if let result = task.result as? [Anime] {
                
                LibrarySyncController.matchAnimeWithProgress(result)
                
                let filtered = dataSource.filter({ (anime: Anime) -> Bool in
                    return !contains(result, anime)
                })
                
                self.dataSource = [result, filtered]
                self.sort()
                if self.isViewLoaded() {
                    self.collectionView.reloadData()
                }
            }
            return nil
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LibraryAnimeCell.registerNibFor(collectionView: collectionView, style: .CheckInCompact, reuseIdentifier: "CheckInCompact")
        AnimeCell.registerNibFor(collectionView: collectionView, style: .Poster, reuseIdentifier: "AnimeCellPoster")
        updateLayout()
    }
    
    // MARK: - Utility Functions
    
    func sort() {
        
        let today = NSDate()
        var index = 0
        
        dataSource = dataSource.map() { (var animeArray) -> [Anime] in
            
            if index == 0 {
                animeArray.sort({ (anime1: Anime, anime2: Anime) in
                    let anime1IsToday = anime1.nextEpisodeDate.timeIntervalSinceDate(today) < 60*60*24
                    let anime2IsToday = anime2.nextEpisodeDate.timeIntervalSinceDate(today) < 60*60*24
                    if anime1IsToday && anime2IsToday {
                        return anime1.nextEpisodeDate.compare(anime2.nextEpisodeDate) == .OrderedAscending
                    } else if !anime1IsToday && !anime2IsToday {
                        return anime1.nextEpisodeDate.compare(anime2.nextEpisodeDate) == .OrderedDescending
                    } else if anime1IsToday && !anime2IsToday {
                        return false
                    } else {
                        return true
                    }
                    
                })
            } else {
                animeArray.sort({ $0.nextEpisodeDate.compare($1.nextEpisodeDate) == .OrderedAscending })
            }
            
            index += 1
            
            return animeArray
        }
    }
    
    func updateLayout() {
        
        var size: CGSize?
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        let margin: CGFloat = 2
        let columns: CGFloat = 2
        let totalSize: CGFloat = view.bounds.size.width - (margin * (columns + 1))
        let width = totalSize / columns
        size = CGSize(width: width, height: width/164*164)
        
        layout.sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
        layout.minimumLineSpacing = margin
        layout.minimumInteritemSpacing = margin
        
        layout.itemSize = size!

    }
    
}


extension DayViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return dataSource.count
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource[section].count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let reuseIdentifier: String
        if indexPath.section == 0 {
            reuseIdentifier = "CheckInCompact"
        } else {
            reuseIdentifier = "AnimeCellPoster"
        }
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! AnimeCell
        
        let anime = dataSource[indexPath.section][indexPath.row]

        let nextDate = anime.nextEpisodeDate
        let showEtaAsAired = nextDate.timeIntervalSinceNow > 60*60*24 && section == 0
        
        cell.configureWithAnime(anime, canFadeImages: true, showEtaAsAired: showEtaAsAired, showShortEta: true)
        
        if let libraryCell = cell as? LibraryAnimeCell {
            libraryCell.delegate = self
        } else {
            
        }
        
        cell.layoutIfNeeded()
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        var reusableView: UICollectionReusableView!
        
        if kind == UICollectionElementKindSectionHeader {
            
            var headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", forIndexPath: indexPath) as! BasicCollectionReusableView
            
            if indexPath.section == 0 {
                headerView.titleLabel.text = "In Library"
            } else {
                headerView.titleLabel.text = "All"
            }
            
            reusableView = headerView;
        }
        
        return reusableView
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if dataSource[section].count == 0 {
            return CGSizeZero
        } else {
            return CGSize(width: view.bounds.size.width, height: 44.0)
        }
    }
    
}

extension DayViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if indexPath.section == 0 {

            let totalSize: CGFloat = view.bounds.size.width - (2 * (2 + 1))
            let width = totalSize / 2
            return CGSize(width: width, height: width/164*164)
            
        } else {
            
            let totalSize: CGFloat = view.bounds.size.width - (2 * (4 + 1))
            let width = totalSize / 4
            return CGSize(width: width, height: width/100*176)
            
        }
        
    }
}
extension DayViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let anime = dataSource[indexPath.section][indexPath.row]
        self.animator = presentAnimeModal(anime)
    }
}

extension DayViewController: LibraryAnimeCellDelegate {
    func cellPressedWatched(cell: LibraryAnimeCell, anime: Anime) {
        if let progress = anime.progress,
            let indexPath = collectionView.indexPathForCell(cell) {
            
            collectionView.reloadItemsAtIndexPaths([indexPath])
        }
    }
}

extension DayViewController: XLPagerTabStripChildItem {
    func titleForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController!) -> String! {
        return dayString
    }
    
    func colorForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController!) -> UIColor! {
        return UIColor.whiteColor()
    }
}

