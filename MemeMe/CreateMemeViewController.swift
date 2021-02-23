//
//  ViewController.swift
//  MemeMe
//
//  Created by Olive Iosello on 2/5/21.
//

import UIKit

struct Meme {
    var topText: String
    var bottomText: String
    var originalImage: UIImage
    var memedImage: UIImage
    
}

class CreateMemeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var memeImage: UIImageView!
    @IBOutlet weak var takeImageButton: UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var cancelButton: UIButton!
    
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.strokeWidth: Float(-6),
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 50)!
    ]
    
    func createInitialView() {
        topText.text = "TOP"
        topText.defaultTextAttributes = memeTextAttributes
        topText.textAlignment = .center
        self.topText.delegate = self
        bottomText.text = "BOTTOM"
        bottomText.defaultTextAttributes = memeTextAttributes
        bottomText.textAlignment = .center
        memeImage.image = nil
        self.bottomText.delegate = self
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        createInitialView()
        shareButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        takeImageButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if bottomText.isFirstResponder {
          view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    @IBAction func cancelMeme(_ sender: Any) {
        print("CANCELLED")
        createInitialView()
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @IBAction func pickImageFromAlbum(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickImageFromCamera(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            memeImage.image = image
            shareButton.isEnabled = true
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func generateMeme() -> UIImage {
        toolbar.isHidden = true
        shareButton.isEnabled = true
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        toolbar.isHidden = false
        shareButton.isEnabled = false
        return memedImage
    }

    @IBAction func shareAction(_sender: Any) {
        let meme = generateMeme()
        let shareMeme = UIActivityViewController(activityItems: [meme], applicationActivities: nil)
        shareMeme.completionWithItemsHandler = { [self] (activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) -> Void in
            if completed {
                _ = Meme(topText: topText.text!, bottomText: self.bottomText.text!, originalImage: memeImage.image!, memedImage: meme)
            }
        }
        present(shareMeme, animated: true, completion: nil)
    }
    
}

