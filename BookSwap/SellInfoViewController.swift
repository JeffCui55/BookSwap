//
//  SellInfoViewController.swift
//  BookSwap
//
//  Created by John Zhang on 4/2/16.
//  Copyright © 2016 Jeffery Cui. All rights reserved.
//

import UIKit

class SellInfoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var currentImage: UIImageView!
    weak var finalImage:UIImage?
    let imagePicker = UIImagePickerController()
    let rdsEndPoint = "http://ec2-52-91-193-208.compute-1.amazonaws.com/textbooks"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        self.currentImage.contentMode = .ScaleAspectFill         // maintain aspect ratio, fill space
        self.currentImage.clipsToBounds = true

        // Do any additional setup after loading the view.
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    // MARK: UIImagePickerControllerDelegate Methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.currentImage.image = pickedImage
            self.finalImage = pickedImage
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
            var urlString:String = self.rdsEndPoint + requestString;
            let request = NSMutableURLRequest(URL: (NSURL(string: urlString)!))
            request.HTTPMethod = "POST"
            print(urlString)
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
