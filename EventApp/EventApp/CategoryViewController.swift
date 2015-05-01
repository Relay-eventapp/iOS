//
//  CategoryViewController.swift
//  EventApp
//
//  Created by Mike Zhao on 4/30/15.
//  Copyright (c) 2015 Mike Zhao. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return eventCategories.count/2
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: CategoryCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("categoryCell", forIndexPath: indexPath)
        as! CategoryCollectionViewCell
     
        cell.categoryLabel.text = eventCategories[indexPath.section*2+indexPath.row]
        cell.backgroundImage.image = UIImage(named: "sback_\(eventCategories[indexPath.section*2+indexPath.row].lowercaseString)")
        cell.backgroundImage.alpha = 0.5
        return cell
    }
}
