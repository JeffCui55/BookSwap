//
//  BuyDetailedViewController.swift
//  BookSwap
//
//  Created by John Zhang on 4/2/16.
//  Copyright © 2016 Jeffery Cui. All rights reserved.
//

import UIKit

class BuyDetailedViewController: UIViewController {

    @IBOutlet weak var titleText: UILabel!
    var titleName = String()
    @IBOutlet weak var ISBNText: UILabel!
    var ISBNName = String()
    @IBOutlet weak var ContactText: UILabel!
    var ContactName = String()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        titleText.text = titleName
        ISBNText.text = ISBNName
        ContactText.text = ContactName
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
