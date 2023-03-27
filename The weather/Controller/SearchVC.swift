
import UIKit
import Foundation
import CoreLocation


class SearchVC: UIViewController, UITextFieldDelegate {
    

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableViewSearch: UITableView!
    
    // Variable for perfomance
    
    var urlForSearch = ""
    var cityNameForSearch = ""
    var cityNameForLable = ""
    var temp_c = ""
    var condition = ""
    var conditionLink = ""
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
        
        var cityNameForLable: String
        var temp_c: String
        var conditionLink: String
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewSearch.delegate = self
        tableViewSearch.dataSource = self
        searchTextField.delegate = self
        searchTextField.keyboardAppearance = .dark
        searchTextField.clearsOnBeginEditing = true
        
    }

    @IBAction func searchButtonPressed(_ sender: UIButton) {
        
        searchTextField.endEditing(true)
      
    }
    
    // Function for request
    
    func searchRequestFromApi (city url: String) {
        guard let url = URL(string: url) else {
            nonCorrectCity()
            return
        }
        let session = URLSession.shared
        session.dataTask(with: url) { [self] ( data, response, error )  in
            if response != nil {
            } else { return }
            guard let data = data  else { return }
            do {
                _ = try JSONSerialization.jsonObject(with: data )
                let decoder = JSONDecoder()
                let weather: WeatherData = try decoder.decode( WeatherData.self, from: data)
                DispatchQueue.main.async { [self] in
                    cityNameForLable = weather.location.name
                    temp_c = String(weather.current.temp_c) + "°"
                    conditionLink = "https:" + weather.current.condition.icon
                    arraySearchData.append(SearchData(cityNameForLable: cityNameForLable, temp_c: temp_c, conditionLink: conditionLink))
                    tableViewSearch.reloadData()
                }
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
        searchTextField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "Назва міста"
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    
        cityNameForSearch = searchTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        urlForSearch = "https://api.weatherapi.com/v1/current.json?key=001aecb53c464f309e0205050232103&q=\(cityNameForSearch)&lang=uk"
        searchRequestFromApi(city: urlForSearch)
        searchTextField.text = ""
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
        
        cell.textLabel?.text = self.arraySearchData[indexPath.row].cityNameForLable + "                        " + self.arraySearchData[indexPath.row].temp_c
        cell.imageView?.load(urlString: self.arraySearchData[indexPath.row].conditionLink)

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



