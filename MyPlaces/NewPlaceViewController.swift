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
