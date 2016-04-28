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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController!.navigationBar.barTintColor = UIColor.init(colorLiteralRed: (60/255), green: (119/255), blue: (255/255), alpha: 1)
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        if((prefs.objectForKey("TheData")) == nil){
            let data = NSKeyedArchiver.archivedDataWithRootObject(textbookArray)
            prefs.setObject(data, forKey: "TheData")
            prefs.synchronize()
        }
        else{
            let decodeData = prefs.objectForKey("TheData") as! NSData
            textbookArray = NSKeyedUnarchiver.unarchiveObjectWithData(decodeData) as! [Textbook]
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadList:",name:"load", object: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadList(notification: NSNotification){
        //load data here
        self.tableView.reloadData()
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
            
            
            
            return cell
        }
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
