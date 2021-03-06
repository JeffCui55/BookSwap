//
//  SellInfoViewController.swift
//  BookSwap
//
//  Created by John Zhang on 4/2/16.
//  Copyright © 2016 Jeffery Cui. All rights reserved.
//

import UIKit

class SellInfoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate,ChooseLocationViewControllerDelegate {
    
    @IBOutlet weak var currentImage: UIImageView!
    weak var finalImage:UIImage?
    @IBOutlet weak var conditionPicker: UIPickerView!
    let imagePicker = UIImagePickerController()
    let rdsEndPoint = "http://ec2-52-91-193-208.compute-1.amazonaws.com/textbooks"
    let pickerData = ["New","Excellent","Good", "Fair", "Poor"]
    
    @IBOutlet weak var TitleField: UITextField!
    @IBOutlet weak var EditionField: UITextField!
    @IBOutlet weak var AuthorField: UITextField!
    @IBOutlet weak var ISBNField: UITextField!
    @IBOutlet weak var PriceField: UITextField!
    @IBOutlet weak var SubjectField: UITextField!
    @IBOutlet weak var DescriptionField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    var meetLatitude:Float?
    var meetLongitude:Float?
    
    let prefs = NSUserDefaults.standardUserDefaults()
//    var textbookArray = [Textbook]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController!.navigationBar.barTintColor = UIColor.init(colorLiteralRed: (60/255), green: (119/255), blue: (255/255), alpha: 1)
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        
        // Do any additional setup after loading the view.
        self.currentImage.contentMode = .ScaleAspectFill
        self.currentImage.clipsToBounds = true
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SellSignInViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        submitButton.enabled = false
        
        //delegate setup
        imagePicker.delegate = self
        self.conditionPicker.delegate = self
        self.conditionPicker.dataSource = self
        self.TitleField.delegate = self
        self.AuthorField.delegate = self
        self.ISBNField.delegate = self
        self.PriceField.delegate = self
        self.EditionField.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SellInfoViewController.fieldsFull(_:)), name: UITextFieldTextDidChangeNotification, object: nil)
        
//        let decodeData = prefs.objectForKey("TheData") as! NSData
//        textbookArray = NSKeyedUnarchiver.unarchiveObjectWithData(decodeData) as! [Textbook]

        print(meetLongitude)
        print(meetLatitude)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Method that makes submit button unclickable/clickable depending on if the fields are full
    func fieldsFull(sender: NSNotification) {
        if TitleField.hasText() && AuthorField.hasText() && ISBNField.hasText() && PriceField.hasText()
            /*&& finalImage != nil*/{
            submitButton.enabled = true
        }
        else {
            submitButton.enabled = false
        }
    }
    
    // Called when trying add image, gives choice of camera or gallery
    @IBAction func selectAction(sender:AnyObject){
        let actionSheet: UIAlertController = UIAlertController(title: "Choose An Image", message: "", preferredStyle: .ActionSheet)
        
        let cancelActionButton: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            print("Cancel")
        }
        actionSheet.addAction(cancelActionButton)
        
        let takePhoto: UIAlertAction = UIAlertAction(title: "Take a photo", style: .Default)
        { action -> Void in
            self.takePicture()
        }
        actionSheet.addAction(takePhoto)
        
        let choosePhoto: UIAlertAction = UIAlertAction(title: "Choose from gallery", style: .Default)
        { action -> Void in
            self.selectPhoto()
        }
        actionSheet.addAction(choosePhoto)
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    //MARK: UIPickerView delegate methods
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 5
    }
    
//    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        var thing = pickerData[row]
//        
//        return pickerData[row]
//    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        
        var pickerLabel = view as? UILabel;
        
        if (pickerLabel == nil)
        {
            pickerLabel = UILabel()
            
            pickerLabel?.font = UIFont(name: "Montserrat", size: 16)
            pickerLabel?.textAlignment = NSTextAlignment.Center
        }
        
        pickerLabel?.text = pickerData[row]
        
        return pickerLabel!;
    }
    
    // MARK: UITextFieldDelegate Methods
    func textFieldDidEndEditing(textField: UITextField) {
        print("textFieldDidEndEditing called")
        if !textField.hasText() {
            textField.layer.borderWidth = 1.5
            textField.layer.borderColor = UIColor.redColor().CGColor
            print("textField has text")
        }
        else {
            textField.layer.borderWidth = 0
        }
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String)-> Bool {
   
        if string.characters.count == 0 {
            return true
        }
       
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).stringByReplacingCharactersInRange(range, withString: string)
        
        switch textField {
            
            // Allow only upper- and lower-case vowels in this field,
        // and limit its contents to a maximum of 6 characters.
        case ISBNField:
            return containsOnlyCharactersIn(prospectiveText, matchCharacters: "0123456789") &&
                prospectiveText.characters.count <= 13
        
        case PriceField:
            return containsOnlyCharactersIn(prospectiveText, matchCharacters: "0123456789") &&
                prospectiveText.characters.count <= 4
        case EditionField:
            return containsOnlyCharactersIn(prospectiveText, matchCharacters: "0123456789") &&
                prospectiveText.characters.count <= 2

        default:
            return true
        }
        
    }
    
    func containsOnlyCharactersIn(prospText: String, matchCharacters: String) -> Bool {
        let disallowedCharacterSet = NSCharacterSet(charactersInString: matchCharacters).invertedSet
        return prospText.rangeOfCharacterFromSet(disallowedCharacterSet) == nil
    }
    
    func doesNotContainCharactersIn(prospText: String, matchCharacters: String) -> Bool {
        let characterSet = NSCharacterSet(charactersInString: matchCharacters)
        return prospText.rangeOfCharacterFromSet(characterSet) == nil
    }
    
    func isNumeric(prospectiveText: String) -> Bool {
        let scanner = NSScanner(string: prospectiveText)
        scanner.locale = NSLocale.currentLocale()
        return scanner.scanDecimal(nil) && scanner.atEnd
    }
    
    // MARK: UIImagePickerControllerDelegate Methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.currentImage.image = pickedImage
            self.finalImage = pickedImage
            print("Image has been picked")
            if(imagePicker.sourceType == .Camera){
                let selectorToCall = #selector(SellInfoViewController.imageWasSavedSuccessfully(_:didFinishSavingWithError:context:))
                UIImageWriteToSavedPhotosAlbum(pickedImage, self, selectorToCall, nil)
            }
            
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // launch UIImagePickerController for user to select an image
    func selectPhoto(){
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    // launch camera to take a picture
    func takePicture() {
        if (UIImagePickerController.isSourceTypeAvailable(.Camera)) {
            if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .Camera
                imagePicker.cameraCaptureMode = .Photo
                presentViewController(imagePicker, animated: true, completion: {})
            } else {
                print("Rear camera does not exist")
            }
        } else {
            print("camera is inaccessible")
        }
    }
    
    //found from tutorial from http://www.deegeu.com/how-to-access-the-ios-camera-using-swift-2-0/
    func imageWasSavedSuccessfully(image: UIImage, didFinishSavingWithError error: NSError!, context: UnsafeMutablePointer<()>){
                print("Image saved")
                if let theError = error {
                    print("An error happened while saving the image = \(theError)")
                } else {
                    print("Displaying")
                }
            }
    
    // called when submit button is pressed, checks to make sure seller info and image is complete
    @IBAction func submit(){
        if((prefs.objectForKey("BookSwapContactName")  == nil || prefs.objectForKey("BookSwapContactName")  as! String == "" ) && (prefs.objectForKey("BookSwapContactEmail")  == nil || prefs.objectForKey("BookSwapContactEmail") as! String == "" ||
            prefs.objectForKey("BookSwapContactPhone") == nil || prefs.objectForKey("BookSwapContactPhone") as! String == "")
            || meetLatitude == nil){
            let alertString = "Please provide a location, your name and a way to contact you!"
            let alert = UIAlertController(title: "Incomplete", message: alertString, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Got it!", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else {
            if(finalImage != nil){
                print(meetLatitude)
                postData(finalImage!) { (Status) -> Void in
                    print("WE DONe IN EHRE")
//                    print(Status)
                    if Status == true {
                        //NSNotificationCenter.defaultCenter().postNotificationName("load", object: nil)
                    }
                    //self.navigationController?.popToRootViewControllerAnimated(true)
                }
                let seconds = 2.0
                let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
                let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                
                dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                    NSNotificationCenter.defaultCenter().postNotificationName("loadSell", object: nil)
                })
                
                self.navigationController?.popToRootViewControllerAnimated(true)
                print("WE DONE OUT HERE")

            }else{
                let alertString = "Please provide an image of your textbook!"
                let alert = UIAlertController(title: "Incomplete", message: alertString, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Got it!", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }

    }
    
    // called from submit() and posts data to server
    func postData(image: UIImage, completion: (Status: Bool) -> Void){
        
        if let imageData = UIImageJPEGRepresentation(image, 0.1)
        {
        
            let ISBN = ISBNField.text!
            let Title = TitleField.text!
            let Author = AuthorField.text!
            print(Author)
            let Edition = EditionField.text!
            let DatePosted = NSDate()
            let Condition = pickerData[conditionPicker.selectedRowInComponent(0)]
            let Price = PriceField.text!
            let Image = imageData.base64EncodedStringWithOptions([])
            //let Image = NSString(data: imageData.base64EncodedDataWithOptions([]), encoding: NSUTF8StringEncoding)
            //let Image = imageData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)

            let Subject = SubjectField.text!
            let Description = DescriptionField.text!
            let Phone = prefs.objectForKey("BookSwapContactPhone") as! String
            let Email = prefs.objectForKey("BookSwapContactEmail") as! String
            let Name = prefs.objectForKey("BookSwapContactName") as! String
            let Top = "Student"
            let SellerID = UIDevice.currentDevice().identifierForVendor!.UUIDString
            let latitude = meetLatitude!
            let longitude = meetLongitude!
            
            let urlString:String = self.rdsEndPoint
            
            let request = NSMutableURLRequest(URL: (NSURL(string: urlString))!)
            request.HTTPMethod = "POST"
            

            let requestString: String = "isbn=\(ISBN)&title=\(Title)&author=\(Author)&edition=\(Edition)&dateposted=\(DatePosted)&condition=\(Condition)&price=\(Price)&gpsx=\(longitude)&gpsy=\(latitude)&image=\(Image)&subject=\(Subject)&description=\(Description)&phone=\(Phone)&email=\(Email)&top=\(Top)&status=0&name=\(Name)&deviceid=\(SellerID)"
            
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
        else {
            let alertString = "The image you provided was not valid, please try again"
            let alert = UIAlertController(title: "Incomplete", message: alertString, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Got it!", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
//            completion(error:NSError(domain:"ImageData", code: 477, userInfo: nil));
        }
    }

    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func setMeetLocation(latitude: Double, longitude: Double){
        meetLatitude = Float(latitude)
        meetLongitude = Float(longitude)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? ChooseLocationViewController {
            destinationViewController.delegate = self
        }
    }
   

}
