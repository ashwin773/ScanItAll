//
//  ViewController.swift
//  ScanItAll
//
//  Created by Ebpearls on 20/04/2016.
//  Copyright © 2016 Ebpearls. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UITextViewDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var txtDocumentTxtView: UITextView!
    @IBOutlet weak var activityIndicatorView: UIView!
    @IBOutlet weak var changeTxtView: UIView!
    @IBOutlet weak var changeTxtTopConstant: NSLayoutConstraint!
    @IBOutlet weak var findTxtField: UITextField!
    @IBOutlet weak var checkBoxBtn: UIButton!
    @IBOutlet weak var replaceTxtField: UITextField!
    
    var isCheckBoxChecked = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    func addActivityIndicator() {
        self.activityIndicatorView.hidden = false
    }
    
    func removeActivityIndicator() {
         self.activityIndicatorView.hidden = true
    }
    
    

}

extension ViewController{
    
    //MARK: Tessaract specific functions
    
    func performImageRecognition(image: UIImage) {
        
        let tesseract = G8Tesseract()
        tesseract.language = "eng+fra"
        tesseract.engineMode = .TesseractCubeCombined
        tesseract.pageSegmentationMode = .Auto
        tesseract.maximumRecognitionTime = 60.0
        tesseract.image = image.g8_blackAndWhite()
        tesseract.recognize()
        txtDocumentTxtView.text = tesseract.recognizedText
        txtDocumentTxtView.editable = true
        removeActivityIndicator()
    }
    
    func scaleImage(image: UIImage, maxDimension: CGFloat) -> UIImage {
        
        var scaledSize = CGSizeMake(maxDimension, maxDimension)
        var scaleFactor:CGFloat
        
        if image.size.width > image.size.height {
            scaleFactor = image.size.height / image.size.width
            scaledSize.width = maxDimension
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            scaleFactor = image.size.width / image.size.height
            scaledSize.height = maxDimension
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        image.drawInRect(CGRectMake(0, 0, scaledSize.width, scaledSize.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
}



extension ViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let selectedPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
        let scaledImage = scaleImage(selectedPhoto, maxDimension: 640)
        
        addActivityIndicator()
        
        dismissViewControllerAnimated(true, completion: {
            self.performImageRecognition(scaledImage)
        })
    }
    
}

extension ViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
     
        return true
    
    }
    
    
}

extension ViewController {
    
    //MARK: Button Click Events
    
    
    @IBAction func changeTxtBtnClick(sender: UIButton) {
        
        if txtDocumentTxtView.text.characters.count > 0 {
            if findTxtField.text?.characters.count > 0 && replaceTxtField.text?.characters.count > 0 {
                
                let mainString = self.txtDocumentTxtView.text
                var modifiedString = ""
                let findString = " \(findTxtField.text!) "
                let replaceString = " \(replaceTxtField.text!) "
                if isCheckBoxChecked{
                    
                        modifiedString = mainString.stringByReplacingOccurrencesOfString(findString, withString: replaceString)
                }
                else{
                    
                        modifiedString = mainString.stringByReplacingOccurrencesOfString(findString, withString: replaceString, options: .CaseInsensitiveSearch)
                }
                
                self.txtDocumentTxtView.text = modifiedString
                
                UIView.animateWithDuration(0.35, animations: { () -> Void in
                    self.changeTxtTopConstant.constant = -70;
                    self.view.layoutIfNeeded()
                    }, completion: { (finished) -> Void in
                        self.findTxtField.text = ""
                        self.replaceTxtField.text = ""
                        
                })
                
            }
        }
    }
    
    @IBAction func checkBoxBtnClick(sender: UIButton) {
        
        if !isCheckBoxChecked{
            
            checkBoxBtn.setImage(UIImage(named: "select-tick"), forState: .Normal)
        }
        else{
            checkBoxBtn.setImage(UIImage(named: "uncheck-tick"), forState: .Normal)
        }
        isCheckBoxChecked = !isCheckBoxChecked
        
    }
    
    @IBAction func editBtnClick(sender: UIButton) {
        
        UIView.animateWithDuration(0.35, animations: { () -> Void in
            self.changeTxtTopConstant.constant = 0;
            self.view.layoutIfNeeded()
            }, completion: { (finished) -> Void in
                
        })
        
        
    }
    
    @IBAction func uploadBtnClick(sender: UIButton) {
        let imagePickerActionSheet = UIAlertController(title: "Snap/Upload Photo",
                                                       message: nil, preferredStyle: .ActionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            let cameraButton = UIAlertAction(title: "Take Photo",
                                             style: .Default) { (alert) -> Void in
                                                let imagePicker = UIImagePickerController()
                                                imagePicker.delegate = self
                                                imagePicker.sourceType = .Camera
                                                self.presentViewController(imagePicker,
                                                                           animated: true,
                                                                           completion: nil)
            }
            imagePickerActionSheet.addAction(cameraButton)
        }
        let libraryButton = UIAlertAction(title: "Choose Existing",
                                          style: .Default) { (alert) -> Void in
                                            let imagePicker = UIImagePickerController()
                                            imagePicker.delegate = self
                                            imagePicker.sourceType = .PhotoLibrary
                                            self.presentViewController(imagePicker,
                                                                       animated: true,
                                                                       completion: nil)
        }
        imagePickerActionSheet.addAction(libraryButton)
        let cancelButton = UIAlertAction(title: "Cancel",
                                         style: .Cancel) { (alert) -> Void in
        }
        imagePickerActionSheet.addAction(cancelButton)
        presentViewController(imagePickerActionSheet, animated: true,
                              completion: nil)
        
    }


    
}


