//
//  SellInfoViewController.swift
//  BookSwap
//
//  Created by John Zhang on 4/2/16.
//  Copyright © 2016 Jeffery Cui. All rights reserved.
//

import UIKit

class SellInfoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
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
    

    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SellInfoViewController.fieldsFull(_:)), name: UITextFieldTextDidChangeNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fieldsFull(sender: NSNotification) {
        if TitleField.hasText() && AuthorField.hasText() && ISBNField.hasText() && PriceField.hasText()
            /*&& finalImage != nil*/{
            submitButton.enabled = true
        }
        else {
            submitButton.enabled = false
        }
    }
    
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
            
            //setting up image encoding
//            if let imageData = UIImageJPEGRepresentation(finalImage!, 0.5)
//            {
//                let base64String = imageData.base64EncodedStringWithOptions([])
//                print(base64String)
//            }
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
    
    @IBAction func submit(){
        postData(finalImage!) { (error) -> Void in
            print(error)
        }
    }
    
    func postData(image: UIImage, completion: (error: NSError?) -> Void){
        let session = NSURLSession.sharedSession()
        if let imageData = UIImageJPEGRepresentation(image, 0.5)
        {
            //let requestString:String = "?isbn=1234567891123&title=OnlyInAmerica&edition=2&dateposted=4/21/16&condition=goodish&price=19.99&gpsx=-157.824&gpsy=21.28&image=\(imageData.base64EncodedStringWithOptions([]))&subject=maths&description=pretty_good_but_ive_read_better&phone=4349119111&email=guy@guy.com&top=vendor&status=0";
            
            let requestString:String = "?isbn=1234567891123&title=OnlyInAmerica&edition=2&dateposted=4/21/16&condition=goodish&price=19.99&gpsx=-157.824&gpsy=21.28&image=thing.png&subject=maths&description=pretty_good_but_ive_read_better&phone=4349119111&email=guy@guy.com&top=vendor&status=0";
            let urlString:String = self.rdsEndPoint + requestString;
            
            let request = NSMutableURLRequest(URL: (NSURL(string: urlString))!)
            request.HTTPMethod = "POST"
            let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                print("Response: \(response)")
                print("Error: \(error)")
                if (data != nil){
                    if let strData = NSString(data: data!, encoding: NSUTF8StringEncoding){
                        print("Body: \(strData)")
                        if (strData == "success")
                        {
                            completion(error:nil)
                        }else{
                            completion(error:NSError(domain: "HTTP POST", code: 478, userInfo: nil));
                        }
                    }else{
                        completion(error:NSError(domain: "HTTP POST", code: 479, userInfo: nil));
                    }
                }else{
                    completion(error:NSError(domain: "HTTP POST", code: 480, userInfo: nil));
                }            })
            
            task.resume()
        }
        else{
            completion(error:NSError(domain:"ImageData", code: 477, userInfo: nil));
        }
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
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
