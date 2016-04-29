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
    
    var textbookList:[Textbook]! = []
    var refreshControl: UIRefreshControl!
    let url = NSURL(string: "http://ec2-52-91-193-208.compute-1.amazonaws.com/textbooks/")
    var customView: UIView!
    var refreshImage:UIImageView!
    var timer: NSTimer!
    var isAnimating = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.alwaysBounceVertical = true
        self.collectionView!.contentInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)

        // Do any additional setup after loading the view.

        getBooks(url!){success in
            dispatch_sync(dispatch_get_main_queue()) {
                self.textbookList = success;
                self.collectionView?.reloadData()
            }
        }
        
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController!.navigationBar.barTintColor = UIColor.init(colorLiteralRed: (60/255), green: (119/255), blue: (255/255), alpha: 1)
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.collectionView?.backgroundColor = UIColor.init(colorLiteralRed: (242/255), green: (242/255), blue: (242/255), alpha: 1)
        
        // = UIColor.init(colorLiteralRed: (131/255), green: (169/255), blue: (255/255), alpha: 1)
        // self.collectionView?.backgroundColor = UIColor.init(colorLiteralRed: (60/255), green: (119/255), blue: (255/255), alpha: 1)
        
        //refresh control things
        refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(BuyCollectionViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        refreshControl.backgroundColor = UIColor.clearColor()
        refreshControl.tintColor = UIColor.clearColor()
        self.collectionView!.addSubview(self.refreshControl)
        loadCustomRefreshContents()
        

    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    func loadCustomRefreshContents() {
        let refreshContents = NSBundle.mainBundle().loadNibNamed("Reload", owner: self, options: nil)
        customView = refreshContents[0] as! UIView
        refreshImage = (customView.viewWithTag(5) as! UIImageView)
        customView.frame = refreshControl.bounds
        customView.clipsToBounds = true;
        refreshControl.addSubview(customView)
        
    }
    
    func startTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(BuyCollectionViewController.endRefresh), userInfo: nil, repeats: true)
    }
    
    func endRefresh() {
        self.refreshControl.endRefreshing()
        
        self.refreshImage.transform = CGAffineTransformIdentity
        timer.invalidate()
        timer = nil
        isAnimating = false
    }
    
    func refresh(sender:AnyObject)
    {
        if refreshControl.refreshing {
            if !isAnimating {
                startTimer()
                animate1()
            }
        }
        getBooks(url!){success in
            dispatch_sync(dispatch_get_main_queue()) {
                self.textbookList = success;
                self.collectionView?.reloadData()
            }
        }
    }
    
    func animate1() {
        isAnimating = true
        
        UIView.animateWithDuration(0.5, delay: 0.1, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            self.refreshImage?.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
            
            }, completion: { (finished) -> Void in
                if self.refreshControl.refreshing{
                    self.animate2()
                }
        })
    }
    
    func animate2() {
        
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            self.refreshImage?.transform = CGAffineTransformMakeRotation(CGFloat(M_PI*2))
            
            }, completion: { (finished) -> Void in
                if self.refreshControl.refreshing{
                    self.animate1()
                }
        })
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
                    let tempBook = (json as! NSArray)[i]
                    let newBook = Textbook()
                    newBook.condition = tempBook["Condition"] as! String
                    
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                    let datestr = (tempBook["DatePosted"] as! String)
                    let fixeddatestr = datestr.stringByReplacingOccurrencesOfString(" 0000", withString: "+0000")
                    newBook.date = dateFormatter.dateFromString(fixeddatestr)
                    
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
                    newBook.author = tempBook["Author"] as! String
                    newBook.vendorType = tempBook["TypeOfPerson"] as! String
                    newBook.price = Double(tempBook["Price"] as! NSNumber)
                    newBook.sellStatus = Int(tempBook["Status"] as! NSNumber)
                    newBook.vendorName = tempBook["Name"] as! String
                    newBook.vendorDeviceID = tempBook["DeviceID"] as! String
                    list?.append(newBook)
                    //print(list?.count)
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
        if(self.textbookList?.count == nil){
            return 0;
        }else{
            return (self.textbookList?.count)!
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("BuyCell", forIndexPath: indexPath) as! BuyCollectionViewCell
        
        cell.itemTitle.text = textbookList![indexPath.row].title
        cell.itemPrice.text = String(textbookList![indexPath.row].price)
        cell.textBackground.backgroundColor = UIColor.init(colorLiteralRed: (131/255), green: (169/255), blue: (255/255), alpha: 1)
        self.collectionView?.sendSubviewToBack(cell.textBackground)
        cell.itemPrice.layer.zPosition = 1
        cell.itemTitle.layer.zPosition = 1
        let base64String = textbookList![indexPath.row].imageSource
        let fixedEncoding = base64String!.stringByReplacingOccurrencesOfString(" ", withString: "+")
        let decodedData = NSData(base64EncodedString: fixedEncoding, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
        let decodedimage = UIImage(data: decodedData!)
        
        cell.itemImage.image = decodedimage
        cell.itemImage.contentMode = UIViewContentMode.ScaleAspectFill
//        cell.itemImage.clipsToBounds = true
//
//        if(indexPath.row > 1){
//            let PreviousIndexPath:NSIndexPath = NSIndexPath(forRow: indexPath.row - 1, inSection: indexPath.section)
//            let cell2 = collectionView.dequeueReusableCellWithReuseIdentifier("BuyCell", forIndexPath: PreviousIndexPath ) as! BuyCollectionViewCell
//            let pOriginY = cell2.frame.origin.y
//            let pCellHeight = cell2.frame.height
//            let totalWidth = self.collectionView!.frame.size.width
//            let cellDimension = (totalWidth - 16.0 - 10.0) / 2.0
//            let cellHeight = (decodedimage?.size.height)! * 0.05
//            cell.frame = CGRectMake(cell.frame.origin.x, pOriginY + pCellHeight, cellDimension, cellHeight)
//        }else{
        
        let currentDevice: UIDevice = UIDevice.currentDevice()
        let orientation: UIDeviceOrientation = currentDevice.orientation
        if orientation.isLandscape {
            let totalWidth = self.collectionView!.frame.size.height
            let cellDimension = (totalWidth - 23.0) / 2.0
            //let cellHeight = (decodedimage?.size.height)! * 0.05
            cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cellDimension, cellDimension)
        } else {
            let totalWidth = self.collectionView!.frame.size.width
            let cellDimension = (totalWidth - 26.0) / 2.0
            //let cellHeight = (decodedimage?.size.height)! * 0.05
            cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cellDimension, cellDimension)
        }
        
//        }
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        
        return cell
    }

    let buyDetailedViewIdentifier = "ShowBuyDetailViewSegue"
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        let point : CGPoint = sender.convertPoint(CGPointZero, toView:collectionView)
        if segue.identifier == buyDetailedViewIdentifier {
            if let destination = segue.destinationViewController as? BuyDetailedViewController {
                //if let indexPath = collectionView!.indexPathForCell(sender as! BuyCollectionViewCell) {
                if let indexPath = collectionView!.indexPathForItemAtPoint(point){
                    //print(indexPath.row)
                    
                    // Create more variables in detailed view and update them here for proper display
                    destination.titleName = textbookList![indexPath.row].title
                    destination.authorName = textbookList![indexPath.row].author
                    destination.ISBNName = textbookList![indexPath.row].ISBN
                    destination.ContactName = textbookList![indexPath.row].vendorEmail
                    destination.GPSY = textbookList![indexPath.row].GPSY
                    destination.GPSX = textbookList![indexPath.row].GPSX
                    destination.phoneNumName = textbookList![indexPath.row].vendorPhone
                    destination.priceName = textbookList![indexPath.row].price
                    destination.qualityName = textbookList![indexPath.row].condition
                    destination.editionName = textbookList![indexPath.row].edition
                    destination.subjectName = textbookList![indexPath.row].subject
                    destination.descriptionName = textbookList![indexPath.row].itemDescription
                    destination.dateName = textbookList![indexPath.row].date
                    destination.personName = textbookList![indexPath.row].vendorName
                    let base64String = textbookList![indexPath.row].imageSource
                    let fixedEncoding = base64String!.stringByReplacingOccurrencesOfString(" ", withString: "+")
                    let decodedData = NSData(base64EncodedString: fixedEncoding, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
                    let decodedimage = UIImage(data: decodedData!)
                    destination.theImagevar = decodedimage
                }
            }
        }
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
