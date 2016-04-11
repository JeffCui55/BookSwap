//
//  BuyCollectionViewController.swift
//  BookSwap
//
//  Created by John Zhang on 4/2/16.
//  Copyright © 2016 Jeffery Cui. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class BuyCollectionViewController: UICollectionViewController {
    
    var textbookList:[Textbook]? = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        //in print(NSString(data: data!, encoding: NSUTF8StringEncoding))
//        let url = NSURL(string: "http://ec2-52-91-193-208.compute-1.amazonaws.com/textbooks/")
//        var jsonOuter:AnyObject!
//        var thing:Int!
//        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {
//            (data, response, error) -> Void in
//            if let jsonData = data {
//                
////                if let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) {
////                    print(jsonString)
//                //NEED A CHECK TO MAKE SURE IT's JSON parse-able
//                    do {
//                        let json = try NSJSONSerialization.JSONObjectWithData(jsonData, options:NSJSONReadingOptions())
//                        jsonOuter = json;
////                        print(jsonOuter)
//                        let jsonL = json.count as Int
//                        thing = jsonL
//                        for i in 0..<jsonL {
//                            let tempBook = json[i]
//                            let newBook = Textbook()
//                            newBook.condition = tempBook["Condition"] as! String
//                            
//                            let dateFormatter = NSDateFormatter()
//                            dateFormatter.dateFormat = "MM/dd/YY"
//                            newBook.date = dateFormatter.dateFromString(tempBook["DatePosted"] as! String)
//                            
//                            newBook.itemDescription = tempBook["Description"] as! String
//                            newBook.edition = tempBook["Edition"] as! String
//                            newBook.vendorEmail = tempBook["Email"] as! String
//                            // Will need to do GPS X and Y coordinates
//                            newBook.GPS = tempBook["GPS"] as! NSDecimalNumber
//                            newBook.index = tempBook["ID"] as! Int
//                            newBook.ISBN = tempBook["ISBN"] as! String
//                            //newBook.imageSource = tempBook["Image"] as? String
//                            newBook.imageSource = "No Image Selected"
//                            newBook.vendorPhone = tempBook["Phone"] as! String
//                            newBook.subject = tempBook["Subject"] as! String
//                            newBook.title = tempBook["Title"] as! String
//                            newBook.vendorType = tempBook["TypeOfPerson"] as! String
//                            newBook.price = Double(tempBook["price"] as! NSNumber)
//                            
//                            print(newBook.condition, newBook.date, newBook.itemDescription, newBook.edition)
//                            print(newBook.vendorEmail, newBook.GPS, newBook.index, newBook.ISBN)
//                            print(newBook.imageSource, newBook.vendorPhone, newBook.subject, newBook.title, newBook.vendorType, newBook.price)
//                            print("\n")
//                            
//                            self.textbookList?.append(newBook)
//                            print(self.textbookList?.count)
//                        }
//                    } catch {
//                        print(error)
//                    }
//                    //print(jsonString)
////                }
//            }
//            else if let requestError = error {
//                print ("Error fetching data: \(requestError)")
//            }
//            else {
//                print ("Unexpected error.")
//            }
//            
//        }
//        task.resume()
//        print(thing)
//        let jsonL = jsonOuter.count as Int
//        for i in 0..<jsonL {
//            let tempBook = jsonOuter[i]
//            let newBook = Textbook()
//            newBook.condition = tempBook["Condition"] as! String
//
//            let dateFormatter = NSDateFormatter()
//            dateFormatter.dateFormat = "MM/dd/YY"
//            newBook.date = dateFormatter.dateFromString(tempBook["DatePosted"] as! String)
//
//            newBook.itemDescription = tempBook["Description"] as! String
//            newBook.edition = tempBook["Edition"] as! String
//            newBook.vendorEmail = tempBook["Email"] as! String
//            // Will need to do GPS X and Y coordinates
//            newBook.GPS = tempBook["GPS"] as! NSDecimalNumber
//            newBook.index = tempBook["ID"] as! Int
//            newBook.ISBN = tempBook["ISBN"] as! String
//            //newBook.imageSource = tempBook["Image"] as? String
//            newBook.imageSource = "No Image Selected"
//            newBook.vendorPhone = tempBook["Phone"] as! String
//            newBook.subject = tempBook["Subject"] as! String
//            newBook.title = tempBook["Title"] as! String
//            newBook.vendorType = tempBook["TypeOfPerson"] as! String
//            newBook.price = Double(tempBook["price"] as! NSNumber)
//
//            print(newBook.condition, newBook.date, newBook.itemDescription, newBook.edition)
//            print(newBook.vendorEmail, newBook.GPS, newBook.index, newBook.ISBN)
//            print(newBook.imageSource, newBook.vendorPhone, newBook.subject, newBook.title, newBook.vendorType, newBook.price)
//            print("\n")
//            
//            self.textbookList?.append(newBook)
//            print(self.textbookList?.count)
//        }
        // Do any additional setup after loading the view.
        let url = NSURL(string: "http://ec2-52-91-193-208.compute-1.amazonaws.com/textbooks/")

       
//        jsonParser();
        getBooks(url!){success in
            dispatch_sync(dispatch_get_main_queue()) {
                self.textbookList = success;
                self.collectionView?.reloadData()
            }
        }
        
//        loadBooks(url!){ data in
//            dispatch_sync(dispatch_get_main_queue()) {
//                jsonOuter = data;
//            }
//        }
    }
    
    func getBooks(url:NSURL, completion:(success:[Textbook]) -> Void) {
        var list:[Textbook]? = []
        let urlPath = "http://ec2-52-91-193-208.compute-1.amazonaws.com/textbooks/"
        guard let endpoint = NSURL(string: urlPath) else { print("Error creating endpoint");return }
        let request = NSMutableURLRequest(URL:endpoint)
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            do {
                guard let dat = data else { throw JSONError.NoData }
                
                let json = try NSJSONSerialization.JSONObjectWithData(dat, options: NSJSONReadingOptions())
                //                    as? NSDictionary else { throw JSONError.ConversionFailed }
                let jsonL = json.count as Int
                for i in 0..<jsonL {
                    let tempBook = json[i]
                    let newBook = Textbook()
                    newBook.condition = tempBook["Condition"] as! String
                    
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "MM/dd/YY"
                    newBook.date = dateFormatter.dateFromString(tempBook["DatePosted"] as! String)
                    
                    newBook.itemDescription = tempBook["Description"] as! String
                    newBook.edition = tempBook["Edition"] as! String
                    newBook.vendorEmail = tempBook["Email"] as! String
                    // Will need to do GPS X and Y coordinates
                    newBook.GPSX = Double(tempBook["GPSX"] as! NSNumber)
                    newBook.GPSY = Double(tempBook["GPSY"] as! NSNumber)
                    newBook.index = tempBook["ID"] as! Int
                    newBook.ISBN = tempBook["ISBN"] as! String
                    newBook.imageSource = tempBook["Image"] as? String
                    //newBook.imageSource = "No Image Selected"
                    newBook.vendorPhone = tempBook["Phone"] as! String
                    newBook.subject = tempBook["Subject"] as! String
                    newBook.title = tempBook["Title"] as! String
                    newBook.vendorType = tempBook["TypeOfPerson"] as! String
                    newBook.price = Double(tempBook["price"] as! NSNumber)
                    newBook.sellStatus = Int(tempBook["Status"] as! NSNumber)
                    list?.append(newBook)
                    print(list?.count)
                }
            } catch let error as JSONError {
                print(error.rawValue)
            } catch {
                print(error)
            }
            completion(success: list!)
        }.resume()

    }
    
    enum JSONError: String, ErrorType {
        case NoData = "ERROR: no data"
        case ConversionFailed = "ERROR: conversion from JSON failed"
    }
    
//    func jsonParser() {
//        let urlPath = "http://ec2-52-91-193-208.compute-1.amazonaws.com/textbooks/"
//        guard let endpoint = NSURL(string: urlPath) else { print("Error creating endpoint");return }
//        let request = NSMutableURLRequest(URL:endpoint)
//        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
//            do {
//                guard let dat = data else { throw JSONError.NoData }
//
//                 let json = try NSJSONSerialization.JSONObjectWithData(dat, options: NSJSONReadingOptions())
////                    as? NSDictionary else { throw JSONError.ConversionFailed }
//                let jsonL = json.count as Int
//                for i in 0..<jsonL {
//                    let tempBook = json[i]
//                    let newBook = Textbook()
//                    newBook.condition = tempBook["Condition"] as! String
//                    
//                    let dateFormatter = NSDateFormatter()
//                    dateFormatter.dateFormat = "MM/dd/YY"
//                    newBook.date = dateFormatter.dateFromString(tempBook["DatePosted"] as! String)
//                    
//                    newBook.itemDescription = tempBook["Description"] as! String
//                    newBook.edition = tempBook["Edition"] as! String
//                    newBook.vendorEmail = tempBook["Email"] as! String
//                    // Will need to do GPS X and Y coordinates
//                    newBook.GPS = tempBook["GPS"] as! NSDecimalNumber
//                    newBook.index = tempBook["ID"] as! Int
//                    newBook.ISBN = tempBook["ISBN"] as! String
//                    //newBook.imageSource = tempBook["Image"] as? String
//                    newBook.imageSource = "No Image Selected"
//                    newBook.vendorPhone = tempBook["Phone"] as! String
//                    newBook.subject = tempBook["Subject"] as! String
//                    newBook.title = tempBook["Title"] as! String
//                    newBook.vendorType = tempBook["TypeOfPerson"] as! String
//                    newBook.price = Double(tempBook["price"] as! NSNumber)
//                    self.textbookList?.append(newBook)
//                    print(self.textbookList?.count)
//                }
//            } catch let error as JSONError {
//                print(error.rawValue)
//            } catch {
//                print(error)
//            }
//            }.resume()
//    }
//    
//    func loadBooks(url: NSURL, completion: ((data: AnyObject?) -> Void)){
//        
//        let task = NSURLSession.sharedSession().dataTaskWithURL(url) {
//            (data, response, error) -> Void in
//            if let jsonData = data {
//                print(jsonData)
//                //                if let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) {
//                //                    print(jsonString)
//                //NEED A CHECK TO MAKE SURE IT's JSON parse-able
//                do {
//                    let json = try NSJSONSerialization.JSONObjectWithData(jsonData, options:NSJSONReadingOptions())
//                    let jsonL = json.count as Int
//                    for i in 0..<jsonL {
//                        let tempBook = json[i]
//                        let newBook = Textbook()
//                        newBook.condition = tempBook["Condition"] as! String
//                        
//                        let dateFormatter = NSDateFormatter()
//                        dateFormatter.dateFormat = "MM/dd/YY"
//                        newBook.date = dateFormatter.dateFromString(tempBook["DatePosted"] as! String)
//                        
//                        newBook.itemDescription = tempBook["Description"] as! String
//                        newBook.edition = tempBook["Edition"] as! String
//                        newBook.vendorEmail = tempBook["Email"] as! String
//                        // Will need to do GPS X and Y coordinates
//                        newBook.GPS = tempBook["GPS"] as! NSDecimalNumber
//                        newBook.index = tempBook["ID"] as! Int
//                        newBook.ISBN = tempBook["ISBN"] as! String
//                        //newBook.imageSource = tempBook["Image"] as? String
//                        newBook.imageSource = "No Image Selected"
//                        newBook.vendorPhone = tempBook["Phone"] as! String
//                        newBook.subject = tempBook["Subject"] as! String
//                        newBook.title = tempBook["Title"] as! String
//                        newBook.vendorType = tempBook["TypeOfPerson"] as! String
//                        newBook.price = Double(tempBook["price"] as! NSNumber)
//                        
////                        print(newBook.condition, newBook.date, newBook.itemDescription, newBook.edition)
////                        print(newBook.vendorEmail, newBook.GPS, newBook.index, newBook.ISBN)
////                        print(newBook.imageSource, newBook.vendorPhone, newBook.subject, newBook.title, newBook.vendorType, newBook.price)
////                        print("\n")
//                        
//                        self.textbookList?.append(newBook)
////                        print(self.textbookList?.count)
//                    }
//                } catch {
//                    print(error)
//                }
//                //print(jsonString)
//                //                }
//            }
//            else if let requestError = error {
//                print ("Error fetching data: \(requestError)")
//            }
//            else {
//                print ("Unexpected error.")
//            }
//            
//        }
//        task.resume()
//    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        self.collectionView?.reloadData();
//        print("this is in the viewill appear \(textbookList?.count)")

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        print(textbookList?.count)
        return (self.textbookList?.count)!
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("BuyCell", forIndexPath: indexPath) as! BuyCollectionViewCell
        
        cell.itemTitle.text = textbookList![indexPath.row].title
        cell.itemPrice.text = String(textbookList![indexPath.row].price)
        
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
