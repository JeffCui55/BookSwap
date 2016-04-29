//
//  SellTableViewController.swift
//  BookSwap
//
//  Created by John Zhang on 4/2/16.
//  Copyright © 2016 Jeffery Cui. All rights reserved.
//

import UIKit

class SellTableViewController: UITableViewController {
    let prefs = NSUserDefaults.standardUserDefaults()
    var textbookArray = [Textbook]()
    var customView: UIView!
    var refreshImage:UIImageView!
    var timer: NSTimer!
    var isAnimating = false
    let rdsEndPoint = "http://ec2-52-91-193-208.compute-1.amazonaws.com/textbooks"
    let deviceID = UIDevice.currentDevice().identifierForVendor!.UUIDString

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController!.navigationBar.barTintColor = UIColor.init(colorLiteralRed: (60/255), green: (119/255), blue: (255/255), alpha: 1)
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
//        if((prefs.objectForKey("TheData")) == nil){
//            let data = NSKeyedArchiver.archivedDataWithRootObject(textbookArray)
//            prefs.setObject(data, forKey: "TheData")
//            prefs.synchronize()
//        }
//        else{
//            let decodeData = prefs.objectForKey("TheData") as! NSData
//            textbookArray = NSKeyedUnarchiver.unarchiveObjectWithData(decodeData) as! [Textbook]
//        }
        
        getSellerData(deviceID){success in
            dispatch_sync(dispatch_get_main_queue()) {
                self.textbookArray = success
                self.tableView.reloadData()
            }
        }

        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SellTableViewController.refresh(_:)),name:"loadSell", object: nil)
        
        //refresh control things
        refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(SellTableViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        refreshControl!.backgroundColor = UIColor.clearColor()
        refreshControl!.tintColor = UIColor.clearColor()
        self.tableView!.addSubview(self.refreshControl!)
        loadCustomRefreshContents()
    }

    func loadCustomRefreshContents() {
        let refreshContents = NSBundle.mainBundle().loadNibNamed("Reload", owner: self, options: nil)
        customView = refreshContents[0] as! UIView
        refreshImage = (customView.viewWithTag(5) as! UIImageView)
        customView.frame = refreshControl!.bounds
        customView.clipsToBounds = true;
        refreshControl!.addSubview(customView)
        
    }
    
    func startTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(BuyCollectionViewController.endRefresh), userInfo: nil, repeats: true)
    }
    
    func endRefresh() {
        self.refreshControl!.endRefreshing()
        
        self.refreshImage.transform = CGAffineTransformIdentity
        timer.invalidate()
        timer = nil
        isAnimating = false
    }
    
    func refresh(sender:AnyObject)
    {
        print("in refresh")
        if refreshControl!.refreshing {
            if !isAnimating {
                startTimer()
                animate1()
                getSellerData(deviceID){success in
                    dispatch_sync(dispatch_get_main_queue()) {
                        self.textbookArray = success
                        self.tableView.reloadData()
                    }
                }

            }
        }
        self.tableView.reloadData()
        //print(textbookArray.count)
    }
    
    func animate1() {
        isAnimating = true
        
        UIView.animateWithDuration(0.5, delay: 0.1, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            self.refreshImage?.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
            
            }, completion: { (finished) -> Void in
                if self.refreshControl!.refreshing{
                    self.animate2()
                }
        })
    }
    
    func animate2() {
        
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            self.refreshImage?.transform = CGAffineTransformMakeRotation(CGFloat(M_PI*2))
            
            }, completion: { (finished) -> Void in
                if self.refreshControl!.refreshing{
                    self.animate1()
                }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getSellerData(deviceID: String, completion:(success:[Textbook]) -> Void){
        print("in getSellerData")
        let urlString:String = self.rdsEndPoint + "/sell"
        
        let request = NSMutableURLRequest(URL: (NSURL(string: urlString))!)
        request.HTTPMethod = "POST"
        
        
        let requestString: String = "deviceid=\(deviceID)"
        
        // Create Data from request
        let requestData: NSData = NSData(bytes: String(requestString.utf8), length: requestString.characters.count)
        // Set content-type
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        request.HTTPBody = requestData
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else {                                                          // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                //print("response = \(response)")
            }
            
            var list:[Textbook]? = []

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
//                    print(list?.count)
                }
            } catch let error as JSONError {
                print(error.rawValue)
            } catch {
                print(error)
            }
            completion(success: list!)
        }
        task.resume()
    }
    
    enum JSONError: String, ErrorType {
        case NoData = "ERROR: no data"
        case ConversionFailed = "ERROR: conversion from JSON failed"
    }
    
    func callupdate(bookID: Int){
        print("here")
        self.update(bookID){Status in
            dispatch_async(dispatch_get_main_queue()) {
                self.getSellerData(self.deviceID){success in
                    dispatch_sync(dispatch_get_main_queue()) {
                        self.textbookArray = success
                        self.tableView.reloadData()
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func update(bookID: Int, completion: (Status: Bool) -> Void){
            print("here")
            let urlString:String = self.rdsEndPoint + "/update/"
            
            let request = NSMutableURLRequest(URL: (NSURL(string: urlString))!)
            request.HTTPMethod = "POST"
            
            
            let requestString: String = "id=\(bookID)"

            // Create Data from request
            let requestData: NSData = NSData(bytes: String(requestString.utf8), length: requestString.characters.count)
            // Set content-type
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
            request.HTTPBody = requestData

            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
                guard error == nil && data != nil else {                                                          // check for fundamental networking error
                    print("error=\(error)")
                    return
                }
                //print(response)
                
                if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {           // check for http errors
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    //print("response = \(response)")
                }
                
//                let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
//                print("responseString = \(responseString)")
            }
            completion(Status: true)
            task.resume()
    }


    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1 + textbookArray.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCellWithIdentifier("AddSale", forIndexPath: indexPath)
            return cell
        }else{
            var currentRow = indexPath.row - 1
            let cell = tableView.dequeueReusableCellWithIdentifier("ItemSold", forIndexPath: indexPath) as! SellTableViewCell
            cell.bookTitle.text = textbookArray[currentRow].title
            cell.bookPrice.text = "$"+String(Int(textbookArray[currentRow].price))
            
            if(textbookArray[currentRow].sellStatus == 1){
                cell.checkImage.image = UIImage(named: "Check")
            }
            
            return cell
        }
    }

    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        print("here1")
        let sold = UITableViewRowAction(style: .Normal, title: "Mark as sold") { (action, indexPath) in
            let bookID = self.textbookArray[indexPath.row - 1].index
            self.tableView.reloadData()
            self.callupdate(bookID)
        }
        
        sold.backgroundColor = UIColor.init(colorLiteralRed: 74/255, green: 229/255, blue: 58/255, alpha: 1)
        
        return [sold]
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if(indexPath.row > 0){
            let status = self.textbookArray[indexPath.row - 1].sellStatus
            if(status == 0){
                return true
            }else{
                return false
            }
        }
        return false
    }
    
    // Override to support editing the table view.
//    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        print("here2")
//        if editingStyle == .Delete {
//            // Delete the row from the data source
//            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
//        } else if editingStyle == .Insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//        }    
//    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SellDetail" {
            if let destination = segue.destinationViewController as? BuyDetailedViewController {
                //if let indexPath = collectionView!.indexPathForCell(sender as! BuyCollectionViewCell) {
                if let indexPath = tableView!.indexPathForSelectedRow{
                    //print(indexPath.row)
                    
                    // Create more variables in detailed view and update them here for proper display
                    destination.titleName = textbookArray[indexPath.row - 1].title
                    destination.authorName = textbookArray[indexPath.row - 1].author
                    destination.ISBNName = textbookArray[indexPath.row - 1].ISBN
                    destination.ContactName = textbookArray[indexPath.row - 1].vendorEmail
                    destination.GPSY = textbookArray[indexPath.row - 1].GPSY
                    destination.GPSX = textbookArray[indexPath.row - 1].GPSX
                    destination.phoneNumName = textbookArray[indexPath.row - 1].vendorPhone
                    destination.priceName = textbookArray[indexPath.row - 1].price
                    destination.qualityName = textbookArray[indexPath.row - 1].condition
                    destination.editionName = textbookArray[indexPath.row - 1].edition
                    destination.subjectName = textbookArray[indexPath.row - 1].subject
                    destination.descriptionName = textbookArray[indexPath.row - 1].itemDescription
                    destination.dateName = textbookArray[indexPath.row - 1].date
                    destination.personName = textbookArray[indexPath.row - 1].vendorName
                    let base64String = textbookArray[indexPath.row - 1].imageSource
                    let fixedEncoding = base64String.stringByReplacingOccurrencesOfString(" ", withString: "+")
                    let decodedData = NSData(base64EncodedString: fixedEncoding, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
                    let decodedimage = UIImage(data: decodedData!)
                    destination.theImagevar = decodedimage
                }
            }
        }

    }
 

}
