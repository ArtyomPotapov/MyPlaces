//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Artyom Potapov on 11.07.2022.
//

import UIKit

class MainViewController: UITableViewController {
    
    let restaursnts = [ "Ресторан 1", "Ресторан 2", "Ресторан 3", "Ресторан 4", "Ресторан 5",  "Ресторан 6", "Ресторан 7", "Ресторан 8", "Ресторан 9", "Ресторан 10" ]

    override func viewDidLoad() {
        super.viewDidLoad()

     
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaursnts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = restaursnts[indexPath.row]
        cell.imageView?.image = UIImage(named: restaursnts[indexPath.row])
        let heightCell = cell.frame.size.height

        cell.imageView?.layer.cornerRadius = heightCell / 2
        
        
        cell.imageView?.clipsToBounds = true
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
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
