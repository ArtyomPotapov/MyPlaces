//
//  NewPlaceViewController.swift
//  MyPlaces
//
//  Created by Artyom Potapov on 12.07.2022.
//

import UIKit

class NewPlaceViewController: UITableViewController {
    
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var placeName: UITextField!
    @IBOutlet weak var placeLocation: UITextField!
    @IBOutlet weak var placeType: UITextField!
    
    
    var isImagePicked = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        tableView.tableFooterView = UIView()
        saveButton.isEnabled = false
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
    }
    
    @objc private func textFieldChanged(){
        let checkingTheFillingOfTheTextField = placeName.text?.isEmpty
        saveButton.isEnabled = checkingTheFillingOfTheTextField == true ? false : true
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let cameraIcon = UIImage(systemName: "camera")
            let photoIcon = UIImage(systemName: "photo")
        
            let ac = UIAlertController(title: nil,
                                       message: nil,
                                       preferredStyle: .actionSheet)
            
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.chooseImagePicker(source: UIImagePickerController.SourceType.camera)
            }
            
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            camera.setValue(UIColor.systemMint, forKey: "titleTextColor")
            
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                self.chooseImagePicker(source: UIImagePickerController.SourceType.photoLibrary)
                }
            photo.setValue(photoIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            photo.setValue(UIColor.systemYellow, forKey: "titleTextColor")
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            ac.addAction(camera)
            ac.addAction(photo)
            ac.addAction(cancel)
            
            present(ac, animated: false)

        } else {
            view.endEditing(true)
        }
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: false)
    }
    
    func saveNewPlace(){
        let image = placeImage.image
//        let newPlace = Place()
        let imageData = image?.pngData()
        
        let newPlace = Place(name: placeName.text!, location: placeLocation.text, type: placeType.text, imageData: imageData)
        StorageManager.saveObject(newPlace)
        
//        newPlace.name = placeName.text!
//        newPlace.location = placeLocation.text
//        newPlace.type = placeType.text
//        newPlace.imageData = imageData
    }
    
}

extension NewPlaceViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: - работа с изображениями

extension NewPlaceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func chooseImagePicker(source: UIImagePickerController.SourceType){
        if UIImagePickerController.isSourceTypeAvailable(source){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: false)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        placeImage.image = info[.editedImage] as? UIImage
        placeImage.contentMode = .scaleAspectFit
        placeImage.clipsToBounds = true
        isImagePicked = true
        dismiss(animated: false)
    }
    
    
    
    
}
