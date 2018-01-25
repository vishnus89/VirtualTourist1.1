//
//  CoreDataCollectionVC.swift
//  VirtualTourist1.1
//
//  Created by Vishnu Deep Samikeri on 6/20/17.
//  Copyright © 2017 Vishnu Deep Samikeri. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CoreDataCollectionVC: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var newItemsIndexPath = [IndexPath]()
    var deletedItemsIndexPath = [IndexPath]()
    var updatedItemsIndexPath = [IndexPath]()
    
    var delegate = UIApplication.shared.delegate as! AppDelegate
    
    var fResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            fResultsController?.delegate = self
            executeSearch()
        
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension CoreDataCollectionVC {
   
    @objc(numberOfSectionsInCollectionView:) func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        if let fC = fResultsController {
            return (fC.sections?.count)!
        } else {
            return 0
        }
    }
    
    func colletionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let fC = fResultsController {
            return fC.sections![section].numberOfObjects
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let fC = fResultsController {
            fC.managedObjectContext.delete(fC.object(at: indexPath) as! NSManagedObject)
            delegate.stack?.save()
        }
    }
    
    func executeSearch() {
        if let fC = fResultsController {
            do {
                try fC.performFetch()
            } catch let err as NSError {
                print("search leads Error: \(err) \n \(String(describing: fResultsController))")
                }
            }
        }
      }

extension CoreDataCollectionVC: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        newItemsIndexPath.removeAll()
        deletedItemsIndexPath.removeAll()
        updatedItemsIndexPath.removeAll()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch (type) {
        case .insert:
            newItemsIndexPath.append(newIndexPath!)
        case .delete:
            deletedItemsIndexPath.append(indexPath!)
        case .update:
            updatedItemsIndexPath.append(indexPath!)
        case .move:
            deletedItemsIndexPath.append(indexPath!)
            newItemsIndexPath.append(newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates({ () -> Void in
            self.collectionView.insertItems(at: self.newItemsIndexPath)
            self.collectionView.deleteItems(at: self.deletedItemsIndexPath)
            self.collectionView.reloadItems(at: self.updatedItemsIndexPath)
        }, completion: nil)
    }
}
