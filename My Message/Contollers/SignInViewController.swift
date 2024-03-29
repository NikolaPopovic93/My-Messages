//
//  SignInViewController.swift
//  My Message
//
//  Created by Nikola Popovic on 2/21/18.
//  Copyright © 2018 Nikola Popovic. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class SignInViewController: UIViewController {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameTextFiled: UITextField!
    @IBOutlet weak var surnameTextFiled: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    fileprivate var imageData = Data()
    fileprivate var user = UserModel()
    fileprivate var isImageChoosen = false
    fileprivate var overly = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setViews()
    }
    
    func setViews() {
        setGestureForImage()
        Utilites.buttonWithRadius(button: signUpButton)
        overly = Utilites.setOverly(view: self.view)
    }
    
    @IBAction func SignIn(_ sender: Any) {
        signIn()
    }
    
    // MARK: UITapGestureRecognizer for image
    func setGestureForImage(){
        userImage.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.chooseImage(_:)))
        userImage.addGestureRecognizer(gesture)
    }
    
    @objc func chooseImage(_ sender: UITapGestureRecognizer){
        popUpForImagePicker()
    }
}

// MARK: UIImagePickerDelegate
extension SignInViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            userImage.contentMode = .scaleAspectFit
            userImage.image = chosenImage
            user.image = userImage.image!
            isImageChoosen = true
        }
        dismiss(animated:true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func popUpForImagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        let popUp = UIAlertController(title: "Choose image", message: "", preferredStyle: .actionSheet)
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { (UIAlertAction) in
            picker.allowsEditing = false
            picker.sourceType = .photoLibrary
            picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
            self.present(picker, animated: true, completion: nil)
        }
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (UIAlertAction) in
            picker.allowsEditing = false
            picker.sourceType = .camera
            picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)!
            self.present(picker, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
        }
        
        popUp.addAction(photoLibraryAction)
        popUp.addAction(cameraAction)
        popUp.addAction(cancelAction)
        present(popUp, animated: true, completion: nil)
    }
}

// MARK: API
extension SignInViewController {
    
    func uplaodImage(){
        //let nsId = NSUUID()
        SVProgressHUD.show()
        FireBaseHelper.sharedInstance.uploadImage(image: imageData, imageName: "newImage") { (error) in
            if error == nil {
                SVProgressHUD.dismiss()
            } else {
                SVProgressHUD.dismiss()
                Utilites.errorAlert(title: "Error", message: "Can not upload image, try later", controller: self)
            }
        }
    }
    
    func signIn(){
        SVProgressHUD.show()
        Utilites.showOverly(isOverlay: true, view: overly)
        user = UserModel(name: self.nameTextFiled.text!, surname: self.surnameTextFiled.text!, userName: self.userNameTextField.text!, email: self.emailTextField.text!, img : isImageChoosen == true ? userImage.image : nil, isUserHasImage : isImageChoosen == true ? true : false)
        FireBaseHelper.sharedInstance.createUser(email: emailTextField.text!, password: passwordTextField.text!, userModel: user) { (error) in
            if error == nil {
                // Move to next Screen
                SVProgressHUD.dismiss()
                Utilites.showOverly(isOverlay: false, view: self.overly)
                Defaults.setEmailPassword(email: self.emailTextField.text!, pass: self.passwordTextField.text!)
                let vc = self.storyboard?.instantiateViewController(withIdentifier: homeVC)
                self.navigationController?.pushViewController(vc!, animated: true)
            } else {
                // Show pop up
                SVProgressHUD.dismiss()
                Utilites.showOverly(isOverlay: false, view: self.overly)
                Utilites.errorAlert(title: "Error", message: error!.localizedDescription, controller: self)
            }
        }
    }
}
