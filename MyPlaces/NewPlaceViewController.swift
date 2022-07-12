//
//  NewPlaceViewController.swift
//  MyPlaces
//
//  Created by Artyom Potapov on 12.07.2022.
//

import UIKit

class NewPlaceViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // для удаления слабовидимых серых разлиновочных линий в нижней части экрана, присвоим свойству tableView.tableFooterView значение чистого пустого UIView()
        
        tableView.tableFooterView = UIView()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let ac = UIAlertController(title: nil,
                                       message: nil,
                                       preferredStyle: .actionSheet)
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.chooseImagePicker(source: UIImagePickerController.SourceType.camera)
            }
            
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                self.chooseImagePicker(source: UIImagePickerController.SourceType.photoLibrary)
                }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            ac.addAction(camera)
            ac.addAction(photo)
            ac.addAction(cancel)
            present(ac, animated: true)

            
        } else {
            view.endEditing(true)
        }
    }
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesBegan(touches, with: event)
//        view.endEditing(true)
//
//    }
}

extension NewPlaceViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

//MARK: - работа с изображениями

extension NewPlaceViewController {
    
    func chooseImagePicker(source: UIImagePickerController.SourceType){
        if UIImagePickerController.isSourceTypeAvailable(source){
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: true)
        }
    }
    
}
