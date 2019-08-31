//
//  NewSightViewController.swift
//  A1ver2_zhiyan
//
//  Created by steven liu on 30/8/19.
//  Copyright © 2019 steven liu. All rights reserved.
//

import UIKit

protocol AddSightDelegate : AnyObject {
    func addSight(newSight : Sight) -> Bool
}

class NewSightViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    weak var addSightDelegate: AddSightDelegate?
    
    @IBOutlet weak var sightDesc: UITextView!
    @IBOutlet weak var sightName: UITextField!
    @IBOutlet weak var sightLat: UITextField!
    @IBOutlet weak var sightLon: UITextField!
    @IBOutlet weak var sightImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func addSightBtn(_ sender: Any) {
        
        if sightName.text != "" && sightDesc.text != "" && sightImage.image != nil{
            let name = sightName.text!
            let desc = sightDesc.text!
            let image = sightImage.image!
            let lat = sightLat.text!
            let lon = sightLon.text!
            let sight = Sight(image: image, name: name, desc: desc, lat: lat, lon: lon)
            let _ = addSightDelegate!.addSight(newSight: sight)
            navigationController?.popViewController(animated: true)
            return
        }
        var errorMsg = "Please ensure all fields are filled:\n"
        if sightName.text == "" {
            errorMsg += "- Must provide a name\n"
        }
        if sightDesc.text == "" {
            errorMsg += "- Must provide abilities"
        }
        displayMessage(title: "Not all fields filled", message: errorMsg)
        
    }
    
    
    @IBAction func cameraBtn(_ sender: Any) {
        let imagePicker: UIImagePickerController = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
        } else {
            imagePicker.sourceType = .savedPhotosAlbum
        }
        
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    func displayMessage(title: String, message: String) {
        // Setup an alert to show user details about the Person
        // UIAlertController manages an alert instance
        let alertController = UIAlertController(title: title, message: message, preferredStyle:
            UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler:
            nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        
        let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        sightImage.image = pickedImage
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

