import UIKit
import RealmSwift

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let searchController = UISearchController(searchResultsController: nil)
    var filtredPlaces: Results<Place>!
    var places: Results<Place>!
    var isSearchBarEmpty: Bool {
        guard let text = searchController.searchBar.text else {return false}
        return text.isEmpty
    }
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    var ascendingSorting = true
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var reversedSortingButton: UIBarButtonItem!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        places = realm.objects(Place.self)
        // setup the search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filtredPlaces.count
        } else {
            return places.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath) as! CustomTableViewCell
        
        var place = Place()
        
        if isFiltering{
            place = filtredPlaces[indexPath.row]
        } else {
            place = places[indexPath.row]
        }
        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.width / 2
        cell.imageOfPlace.clipsToBounds = true
        return cell
    }
    
    //MARK: - Table view delegate
    
     func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let place = places[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _,_  in
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .none)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue){
        
        guard let newPlaceVC = segue.source as? NewPlaceViewController else {return}
        newPlaceVC.savePlace()
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail"{
            guard let indexPath = tableView.indexPathForSelectedRow else {return}
            
            var place = Place()
            if isFiltering{
                place = filtredPlaces[indexPath.row]
            } else {
                place = places[indexPath.row]
            }
            let vc = segue.destination as! NewPlaceViewController
            vc.currentPlace = place
        }
    }
    
    
    @IBAction func sortSelectionSegmentedControl(_ sender: UISegmentedControl) {
        sorting()
    }
    
    @IBAction func reversedSortingBarButtonItem(_ sender: UIBarButtonItem) {
        ascendingSorting.toggle()
        reversedSortingButton.image = ascendingSorting ? UIImage(systemName: "arrow.up") : UIImage(systemName: "arrow.down")
        sorting()
    }
    
    private func sorting(){
        if segmentedControl.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
        } else {
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
        tableView.reloadData()
    }
}

extension MainViewController: UISearchResultsUpdating {
    
    public func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func filterContentForSearchText(_ searchText: String){
        filtredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        tableView.reloadData()
    }
}
