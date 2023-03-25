
import UIKit
import Foundation
import CoreLocation



class SearchVC: UIViewController, UITextFieldDelegate {
    

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableViewSearch: UITableView!
    
    // Variable for perfomance
    
    var urlForSearch = ""
    var cityNameForSearch = ""
    var cityName = ""
    var temp_c = ""
    var cond = ""
    var condLink = ""
    var isFavorite = false
    var arraySearchData: [SearchData] = []
    

// MARK: Make structure for API data and storage api information
    
    struct WeatherData: Codable {
        let location: Location
        let current: Current
    }
    struct Current: Codable {
        let temp_c: Double
        let condition: Condition
    }
    struct Condition: Codable {
        let text, icon: String
        let code: Int
    }
    struct Location: Codable {
        let name: String
        let lat: Double
        let lon: Double
        let localtime: String
    }
    
    struct SearchData {
        
        var titleCity: String
        var tempCity: String
        var imageUrl: String
        var linkUrl: String
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewSearch.delegate = self
        tableViewSearch.dataSource = self
        searchTextField.delegate = self
        searchTextField.keyboardAppearance = .dark
        searchTextField.backgroundColor = .lightGray
  
    }

    @IBAction func searchButtonPressed(_ sender: UIButton) {
        
        searchTextField.endEditing(true)
        
        cityNameForSearch = searchTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        urlForSearch = "https://api.weatherapi.com/v1/current.json?key=001aecb53c464f309e0205050232103&q=\(cityNameForSearch)&lang=uk"
        searchRequestFromApi(city: urlForSearch)
        
        let dataForCell = SearchData(titleCity: cityName, tempCity: temp_c, imageUrl: condLink, linkUrl: urlForSearch)
            arraySearchData.append(dataForCell)
            tableViewSearch.reloadData()
        
    }
    
    // Function for request
    
    func searchRequestFromApi (city url: String) {
        guard let url = URL(string: url) else {
            nonCorrectCity()
            return
        }
        let session = URLSession.shared
        session.dataTask(with: url) { [self]( data, response, error )  in
            if response != nil {
            } else { return }
            guard let data = data  else { return }
            do {
                _ = try JSONSerialization.jsonObject(with: data )
                let decoder = JSONDecoder()
                let weather: WeatherData = try decoder.decode( WeatherData.self, from: data)
                cityName = weather.location.name
                temp_c = String(weather.current.temp_c) + "°"
                cond = weather.current.condition.text
                condLink = "https:" + weather.current.condition.icon
            } catch {
                print("Ошибка \(error)")
            }
        }.resume()
    }
    
    // Alert for non-correct cityname
    
    func nonCorrectCity () {
        let alert = UIAlertController(title: "Увага", message: "Введенно некоректну назву міста", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            present(alert, animated: true)
        
    }
    
    // Functions for textField
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
}
//MARK: Tableview functionality

extension SearchVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tap me! ")
    }
    
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arraySearchData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = arraySearchData[indexPath.row].titleCity + "                        " + arraySearchData[indexPath.row].tempCity
        cell.imageView!.load(urlString: arraySearchData[indexPath.row].imageUrl)
        
        if isFavorite {
            cell.backgroundColor = .systemBlue
        } else {
            cell.backgroundColor = nil
        }
        
        cell.textLabel?.textAlignment = .right
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let favoriteActionTitle = isFavorite ? "Необрані" : "До обраних"
        let favoriteAction = UITableViewRowAction(style: .normal, title: favoriteActionTitle, handler: {_, indexPath in
            self.isFavorite.toggle()
            tableView.reloadRows(at: [indexPath], with: .automatic)
        })
        favoriteAction.backgroundColor = .systemYellow

        let deleteAction = UITableViewRowAction(style: .destructive, title: "Видалити", handler: {action, indexPath in
            self.arraySearchData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
           
        })
        deleteAction.backgroundColor = .systemRed
        return [favoriteAction, deleteAction]
    }
}



