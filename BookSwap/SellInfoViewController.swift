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
    
    let imagePicker = UIImagePickerController()
    
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
