//
//  ViewController.swift
//  TheGallery
//
//  Created by Javid Poornasir on 9/17/16.
//  Copyright © 2016 Javid Poornasir. All rights reserved.
//

import UIKit
import CoreData
import StoreKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var gallery = [Art]()
    var products = [SKProduct]()
    
    // -------------------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        updateGallery()
        
        if gallery.count == 0 {
            createArt("Horse", productIdentifier: "", imageName: "horse.jpeg", purchased: true)
            createArt("Bird", productIdentifier: "com.cleandev.artgallery.art", imageName: "bird.jpeg", purchased: false)
            createArt("Baby", productIdentifier: "ARTGALLERY2", imageName: "baby.jpeg", purchased: false)
            updateGallery()
            self.collectionView.reloadData()
        }
        
        requestProducts()
    }
    // -------------------------------------------------------------------------------------------
    func requestProducts() {
        let ids : Set<String> = ["com.cleandev.artgallery.art", "ARTGALLERY2"]
        let productsRequest = SKProductsRequest(productIdentifiers: ids)
        productsRequest.delegate = self
        productsRequest.start()
    }
    // -------------------------------------------------------------------------------------------
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Products ready: \(response.products.count)")
        print("Products not ready: \(response.invalidProductIdentifiers.count)")
        self.products = response.products
        self.collectionView.reloadData()
    }
    // -------------------------------------------------------------------------------------------
    @IBAction func restoreTapped(_ sender: AnyObject) {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    // -------------------------------------------------------------------------------------------
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                print("Purchased")
                unlockArt(transaction.payment.productIdentifier)
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            case .failed:
                print("Failed")
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            case .restored:
                print("Restored")
                unlockArt(transaction.payment.productIdentifier)
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            case .purchasing:
                print("Purchasing")
                break
            case .deferred:
                print("Deffered")
                break
            }
        }
    }
    // -------------------------------------------------------------------------------------------
    func unlockArt(_ productIdentifier:String) {
        
        for art in self.gallery {
            if art.productIdentifier == productIdentifier {
                art.purchased = 1
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.managedObjectContext
                do {
                    try context.save()
                } catch {}
                self.collectionView.reloadData()
            }
        }
        
    }
    // -------------------------------------------------------------------------------------------
    func createArt(_ title:String, productIdentifier:String, imageName:String, purchased:Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        
        if let entity = NSEntityDescription.entity(forEntityName: "Art", in: context) {
            let art = NSManagedObject(entity: entity, insertInto: context) as! Art
            art.title = title
            art.productIdentifier = productIdentifier
            art.imageName = imageName
            art.purchased = NSNumber(value: purchased as Bool)
        }
        
        do {
            try context.save()
        } catch {}
    }
    // -------------------------------------------------------------------------------------------
    func updateGallery() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        
        //let fetch = NSFetchRequest(entityName: "Art")
        let fetch: NSFetchRequest<Art> = Art.fetchRequest() as! NSFetchRequest<Art>
        do {
            let artPieces = try context.fetch(fetch)
            self.gallery = artPieces 
        } catch {}
    }
    // -------------------------------------------------------------------------------------------
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.gallery.count
    }
    // -------------------------------------------------------------------------------------------
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "artCell", for: indexPath) as! ArtCollectionViewCell
        
        let art = self.gallery[(indexPath as NSIndexPath).row]
        
        cell.imageView.image = UIImage(named: art.imageName!)
        cell.titleLabel.text = art.title!
        
        for subview in cell.imageView.subviews {
            subview.removeFromSuperview()
        }
        
        for subview in cell.imageView.subviews {
            subview.removeFromSuperview()
        }
        
        if art.purchased!.boolValue {
            cell.purchasedLabel.isHidden = true
        } else {
            cell.purchasedLabel.isHidden = false
            
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
            let blurView = UIVisualEffectView(effect: blurEffect)
            cell.layoutIfNeeded()
            blurView.frame = cell.imageView.bounds
            cell.imageView.addSubview(blurView)
            
            for product in self.products {
                if product.productIdentifier == art.productIdentifier {
                    
                    let formatter = NumberFormatter()
                    formatter.numberStyle = NumberFormatter.Style.currency
                    formatter.locale = product.priceLocale
                    if let price = formatter.string(from: product.price) {
                        cell.purchasedLabel.text = "Buy for \(price)"
                    }
                }
            }
        }
        
        return cell
    }
    // -------------------------------------------------------------------------------------------
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let art = self.gallery[(indexPath as NSIndexPath).row]
        if !art.purchased!.boolValue {
            for product in self.products {
                if product.productIdentifier == art.productIdentifier {
                    SKPaymentQueue.default().add(self)
                    let payment = SKPayment(product: product)
                    SKPaymentQueue.default().add(payment)
                }
            }
        }
    }
    // -------------------------------------------------------------------------------------------
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.bounds.size.width - 80, height: self.collectionView.bounds.size.height - 40)
    }
    
}
