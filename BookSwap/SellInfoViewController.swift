//
//  SellInfoViewController.swift
//  BookSwap
//
//  Created by John Zhang on 4/2/16.
//  Copyright © 2016 Jeffery Cui. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class SellInfoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var currentImage: UIImageView!
    weak var finalImage:UIImage?
    @IBOutlet weak var conditionPicker: UIPickerView!
    let imagePicker = UIImagePickerController()
    let rdsEndPoint = "http://ec2-52-91-193-208.compute-1.amazonaws.com/textbooks"
    let pickerData = ["New","Excellent","Good", "Fair", "Poor"]
    var locationManager:CLLocationManager!
    
    @IBOutlet weak var TitleField: UITextField!
    @IBOutlet weak var EditionField: UITextField!
    @IBOutlet weak var AuthorField: UITextField!
    @IBOutlet weak var ISBNField: UITextField!
    @IBOutlet weak var PriceField: UITextField!
    @IBOutlet weak var SubjectField: UITextField!
    @IBOutlet weak var DescriptionField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var submitButton: UIButton!
    var currentLocation:CLLocation!
    var annotation = MKPointAnnotation()
    
    let prefs = NSUserDefaults.standardUserDefaults()
    var textbookArray = [Textbook]()

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
        
        let decodeData = prefs.objectForKey("TheData") as! NSData
        textbookArray = NSKeyedUnarchiver.unarchiveObjectWithData(decodeData) as! [Textbook]
        //CLLocationManager.location.coordinate
//        if (CLLocationManager.locationServicesEnabled())
//        {
//            locationManager = CLLocationManager()
//            locationManager.delegate = self
//            locationManager.desiredAccuracy = kCLLocationAccuracyBest
//            locationManager.requestAlwaysAuthorization()
//            locationManager.startUpdatingLocation()
//            print("Location enabled")
//            //centerMapOnLocation(locationManager.location!)
//        }
        self.mapView.delegate = self
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
//        let latitude = locationManager.location!.coordinate.latitude
//        let longitude = locationManager.location!.coordinate.longitude
//        let latitude = currentLocation.coordinate.latitude
//        let longitude = currentLocation.coordinate.longitude
//        let initialLocation = CLLocation(latitude: latitude, longitude: longitude)
//        centerMapOnLocation(initialLocation)
//        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//        annotation.title = "Book Swap"
//        annotation.subtitle = "Meet to sell your book!"
//        mapView.addAnnotation(annotation)
        print(mapView.center)
    }
    
    override func viewDidAppear(animated: Bool) {
        /* Are location services available on this device? */
        if CLLocationManager.locationServicesEnabled(){
            
            /* Do we have authorization to access location services? */
            switch CLLocationManager.authorizationStatus(){
            case .AuthorizedAlways:
                /* Yes, always */
                createLocationManager(startImmediately: true)
            case .AuthorizedWhenInUse:
                /* Yes, only when our app is in use */
                createLocationManager(startImmediately: true)
            case .Denied:
                /* No */
                displayAlertWithTitle("Not Determined",
                                      message: "Location services are not allowed for this app")
            case .NotDetermined:
                /* We don't know yet, we have to ask */
                createLocationManager(startImmediately: false)
                if let manager = self.locationManager{
                    manager.requestWhenInUseAuthorization()
                }
            case .Restricted:
                /* Restrictions have been applied, we have no access
                 to location services */
                displayAlertWithTitle("Restricted",
                                      message: "Location services are not allowed for this app")
            }
            
            
        } else {
            /* Location services are not enabled.
             Take appropriate action: for instance, prompt the
             user to enable the location services */
            print("Location services are not enabled")
        }
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
            return isNumeric(prospectiveText) && doesNotContainCharactersIn(prospectiveText, matchCharacters: "-e") &&
                prospectiveText.characters.count <= 10
            
        case EditionField:
            return containsOnlyCharactersIn(prospectiveText, matchCharacters: "0123456789") &&
                prospectiveText.characters.count <= 3

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
    
    // MARK: MKMapViewDelegate Methods
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        print("Region set")
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? MKAnnotation? {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView { // 2
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                // 3
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
            }
            return view
        }
        return nil
    }
    
//    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
//    {
//        
//        let location = locations.last! as CLLocation
//        centerMapOnLocation(location)
////        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
////        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
//        print(location)
////        mapView.setRegion(region, animated: true)
//    }
    
    func displayAlertWithTitle(title: String, message: String){
        let controller = UIAlertController(title: title,
                                           message: message,
                                           preferredStyle: .Alert)
        
        controller.addAction(UIAlertAction(title: "OK",
            style: .Default,
            handler: nil))
        
        presentViewController(controller, animated: true, completion: nil)
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if locations.count == 0{
            //handle error here
            return
        }
        
        let newLocation = locations[0]
        currentLocation = newLocation
        //        print("Latitude = \(newLocation.coordinate.latitude)")
        //        print("Longitude = \(newLocation.coordinate.longitude)")
        //        lat.text = String(newLocation.coordinate.latitude)
        //        long.text = String(newLocation.coordinate.longitude)
        //lat.text = String(GPSY)
        //long.text = String(GPSX)
        
    }
    
    func locationManager(manager: CLLocationManager,
                         didFailWithError error: NSError){
        print("Location manager failed with error = \(error)")
    }
    
    func locationManager(manager: CLLocationManager,
                         didChangeAuthorizationStatus status: CLAuthorizationStatus){
        
        print("The authorization status of location services is changed to: ", terminator: "")
        
        switch CLLocationManager.authorizationStatus(){
        case .AuthorizedAlways:
            print("Authorized")
        case .AuthorizedWhenInUse:
            print("Authorized when in use")
        case .Denied:
            print("Denied")
        case .NotDetermined:
            print("Not determined")
        case .Restricted:
            print("Restricted")
        }
        
    }
    
    func createLocationManager(startImmediately startImmediately: Bool){
        locationManager = CLLocationManager()
        if let manager = locationManager{
            print("Successfully created the location manager")
            manager.delegate = self
            if startImmediately{
                manager.startUpdatingLocation()
            }
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
            prefs.objectForKey("BookSwapContactPhone") == nil || prefs.objectForKey("BookSwapContactPhone") as! String == "" //||
           // finalImage == nil || CGSizeEqualToSize(finalImage!.size, CGSizeZero)
            )){
            let alertString = "Please provide an image of your textbook, your name and a way to contact you!"
            let alert = UIAlertController(title: "Incomplete", message: alertString, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Got it!", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else {
            if(finalImage != nil){
                postData(finalImage!) { (Status) -> Void in
                    print("WE DONe IN EHRE")
                    print(Status)
                    if Status == true {
                        self.grabSellerData()
                    }
                    //self.navigationController?.popToRootViewControllerAnimated(true)
                }
                //self.navigationController?.popToRootViewControllerAnimated(true)
                print("WE DONE OUT HERE")
                //self.grabSellerData()

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

            let urlString:String = self.rdsEndPoint
            
            let request = NSMutableURLRequest(URL: (NSURL(string: urlString))!)
            request.HTTPMethod = "POST"
            

            let requestString: String = "isbn=\(ISBN)&title=\(Title)&author=\(Author)&edition=\(Edition)&dateposted=\(DatePosted)&condition=\(Condition)&price=\(Price)&gpsx=-157.824&gpsy=21.28&image=\(Image)&subject=\(Subject)&description=\(Description)&phone=\(Phone)&email=\(Email)&top=\(Top)&status=0&name=\(Name)&deviceid=\(SellerID)"
            
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
                
                //let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                //print("responseString = \(responseString)")
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
    
    func grabSellerData(){
        print("in grabSellerData")
        let deviceID = UIDevice.currentDevice().identifierForVendor!.UUIDString
        getSellerData(deviceID){success in
            dispatch_sync(dispatch_get_main_queue()) {
                self.textbookArray = success
                let data = NSKeyedArchiver.archivedDataWithRootObject(self.textbookArray)
                self.prefs.setObject(data, forKey: "TheData")
                self.prefs.synchronize()
                NSNotificationCenter.defaultCenter().postNotificationName("load", object: nil)
                //self.navigationController?.popToRootViewControllerAnimated(true)

            }
        }
        self.navigationController?.popToRootViewControllerAnimated(true)
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
            //print(response)
            
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                //print("response = \(response)")
            }
            
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString)")
        }
        task.resume()
    

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
