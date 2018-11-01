//
//  ViewController.swift
//  MeMeV1.0
//
//  Created by Ohud Alessa on 25/10/2018.
//  Copyright © 2018 OHUD. All rights reserved.
//

import UIKit

class ViewController: UIViewController , UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextFieldDelegate  {

    

    @IBOutlet weak var toolBar: UIToolbar!
    
    // image view to show the image
    @IBOutlet weak var image: UIImageView!
 
    // Text Fields
    @IBOutlet weak var topTxt: UITextField!
    @IBOutlet weak var bottomTxt: UITextField!
    
    // bar buttons
    @IBOutlet weak var camBtn: UIBarButtonItem!
    

    // Delegate
//    let memeDelegate = MeMeDelegates()
    
    // ----------------------------------------------------
    
    
    @IBOutlet weak var shareBtn: UIBarButtonItem!
    @IBOutlet weak var clearBtn: UIBarButtonItem!
    
     func toggleShareAndClear(_ allowed: Bool) {
        shareBtn.isEnabled = allowed
        clearBtn.isEnabled = allowed
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    

    override func viewDidLoad() {
       
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
         toggleShareAndClear(false)
        camBtn.isEnabled =  UIImagePickerController.isSourceTypeAvailable(.camera)
        
        topTxt.defaultTextAttributes = memeTextAttributes
        bottomTxt.defaultTextAttributes = memeTextAttributes
        topTxt.delegate = self
        bottomTxt.delegate = self
    }
    
    // MARK: MEME STRUCT
    
    struct MeMe {
       var original: UIImage
        var topTxt: String
        var bottomTxt: String
        var memedImage: UIImage
        
        init(_ original: UIImage, _ topTxt: String, _ bottomTxt: String, _ memedImage: UIImage) {
           self.original = original
           self.topTxt = topTxt
            self.bottomTxt = bottomTxt
            self.memedImage = memedImage
        }
    }
    
    func saveMeMe(){
      let meme = MeMe(image.image!, topTxt.text!, bottomTxt.text!,generateMemedImage())
       
    }
    
    
   
    func generateMemedImage() -> UIImage {
        
        // TODO: Hide toolbar and navbar
        toolBar.isHidden = true
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.bounds, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // TODO: Show toolbar and navbar
        toolBar.isHidden = false
        return memedImage
    }
    
   
    // MARK: Keybaord managment funcs ..
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        // to make sure that the view will slide up only when we edit the bottom text field :)
        if bottomTxt.isEditing{
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        
        if view.frame.origin.y != 0
        {
            view.frame.origin.y = 0
            
        }
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    
    
    // action for both photo library button an camera button : we check for tags to specify the source type
    
    @IBAction func pickImage(_ sender: UIButton) {
    
        let ctr  = UIImagePickerController()
        ctr.delegate = self  as UIImagePickerControllerDelegate & UINavigationControllerDelegate
     
        let isPhotoLibrary = sender.tag == 1
        
        ctr.sourceType =  isPhotoLibrary ?  .photoLibrary : .camera
        
        ctr.allowsEditing = false
        present(ctr, animated: true)
        toggleShareAndClear(true)
    }

    
    
    @IBAction func clearMeme(_ sender: Any) {
        image.image = nil
        topTxt.text = "TOP"
        bottomTxt.text = "BOTTOM"
         toggleShareAndClear(false)
    }
    
    func success (_ succeed: Bool){
       
        let title: String = succeed ? "Success": "Canceled"
        
        let message: String = succeed ? "MeMe has been shared correctly" : "Nothing has been shared..."
        
        // UIAlertController. (n.d.). Retrieved November 1, 2018, from https://developer.apple.com/documentation/uikit/uialertcontroller
        let alert = UIAlertController(title: title, message: message , preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("GOT IT", comment: "Default action"), style: .default, handler:nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func shareMeme(_ sender: Any) {

        let ctr = UIActivityViewController(activityItems: [generateMemedImage()], applicationActivities: nil)
        
        ctr.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if !completed {
                self.success(false)
                return
            }
        
            self.saveMeMe()
            self.success(true)
            
        }
    
        present(ctr, animated: true, completion: nil)
   
    }
    
    
    // imagePickerControl Protocol funcs
    // 1
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    // 2
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
       
        dismiss(animated: true, completion: nil)
        
         image.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
   }
    
    
    // Text Protocol
    
    let memeTextAttributes:[NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.white,
        NSAttributedString.Key.foregroundColor: UIColor.black ,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 16)!,
        
        // using the minus sign was of a help from StackOverFlow : https://stackoverflow.com/questions/47774748/swift-nsattributedstringkey-not-applying-foreground-color-correctly
        NSAttributedString.Key.strokeWidth: -4.0 ]
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        textField.defaultTextAttributes = memeTextAttributes
        
        if textField.text!.count > 24 {
            
            // Probasco, T. (2015, August 23). Swiftly Learning. Retrieved October 29, 2018, from http://swiftlylearning.blogspot.com/2015/08/limiting-number-of-characters-in-text.html
            
            textField.deleteBackward()
            
        }
        
        return true
        
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField.text == "TOP" || textField.text == "BOTTOM" {
            textField.text = ""
            toggleShareAndClear(true)
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true;
    }
    
}

