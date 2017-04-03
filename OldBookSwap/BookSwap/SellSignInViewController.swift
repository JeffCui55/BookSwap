//
//  SellSignInViewController.swift
//  BookSwap
//
//  Created by John Zhang on 4/2/16.
//  Copyright © 2016 Jeffery Cui. All rights reserved.
//

import UIKit

class SellSignInViewController: UIViewController {

    @IBOutlet weak var ContactName: UITextField!
    @IBOutlet weak var ContactEmail: UITextField!
    @IBOutlet weak var ContactPhone: UITextField!
    
    @IBOutlet weak var SellSignInScrollView: UIScrollView!
    
    let prefs = NSUserDefaults.standardUserDefaults()
    
    @IBAction func SubmitContactInfo(sender: AnyObject) {
        if(ContactName.text != "" && (ContactEmail.text != "" || ContactPhone.text != "")){
            let encodeName = ContactName.text!
            let encodeEmail = ContactEmail.text!
            let encodePhone = ContactPhone.text!
            
            prefs.setObject(encodeName, forKey: "BookSwapContactName")
            prefs.setObject(encodeEmail, forKey: "BookSwapContactEmail")
            prefs.setObject(encodePhone, forKey: "BookSwapContactPhone")
            prefs.synchronize()
            
            navigationController?.popViewControllerAnimated(true)
            
        }
        else{
            let alert = UIAlertController(title: "Incomplete",
                                          message: "Please provide your name and a way to contact you!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Got it!", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController!.navigationBar.barTintColor = UIColor.init(colorLiteralRed: (60/255), green: (119/255), blue: (255/255), alpha: 1)
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SellSignInViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
        if((prefs.objectForKey("BookSwapContactName")) == nil || (prefs.objectForKey("BookSwapContactEmail")) == nil
            || (prefs.objectForKey("BookSwapContactPhone")) == nil ){
            let encodeName = ContactName.text!
            let encodeEmail = ContactEmail.text!
            let encodePhone = ContactPhone.text!
            prefs.setObject(encodeName, forKey: "BookSwapContactName")
            prefs.setObject(encodeEmail, forKey: "BookSwapContactEmail")
            prefs.setObject(encodePhone, forKey: "BookSwapContactPhone")
            prefs.synchronize()
        }
        else{
            let decodeName = prefs.objectForKey("BookSwapContactName") as! String
            let decodeEmail = prefs.objectForKey("BookSwapContactEmail") as! String
            let decodePhone = prefs.objectForKey("BookSwapContactPhone") as! String
            self.ContactName.text = decodeName
            self.ContactEmail.text = decodeEmail
            self.ContactPhone.text = decodePhone

        }
    }

    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }
    */

}
