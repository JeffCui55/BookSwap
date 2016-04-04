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
    
    var textbookList:[Textbook]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        //in print(NSString(data: data!, encoding: NSUTF8StringEncoding))
        let url = NSURL(string: "http://ec2-52-91-193-208.compute-1.amazonaws.com/textbooks/")
        
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {
            (data, response, error) -> Void in
            if let jsonData = data {
                
//                if let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) {
//                    print(jsonString)
                //NEED A CHECK TO MAKE SURE IT's JSON parse-able
                    do {
                        let json = try NSJSONSerialization.JSONObjectWithData(jsonData, options:NSJSONReadingOptions())
                        let book1 = json[0];
                        if let condition = book1["Condition"] as? String{
                            print(condition)
                        }
                        
//                        print(json[2])
//                        let jsonMirror = Mirror(reflecting: json)
//                        print(jsonMirror.subjectType)
                    } catch {
                        print(error)
                    }
                    //print(jsonString)
//                }
            }
            else if let requestError = error {
                print ("Error fetching data: \(requestError)")
            }
            else {
                print ("Unexpected error.")
            }
            
        }
        task.resume()
        
        // Do any additional setup after loading the view.
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
        return 0
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
    
        // Configure the cell
    
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
