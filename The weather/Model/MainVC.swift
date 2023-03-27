import UIKit
import Foundation
import CoreLocation


class MainVC: UIViewController, CLLocationManagerDelegate {
    
    
// Make outlets for main page
    
    @IBOutlet weak var cityNameLable: UILabel!
    @IBOutlet weak var tempLable: UILabel!
    @IBOutlet weak var conditionLable: UILabel!
    @IBOutlet weak var conditionImage: UIImageView!

    
// Variable for perfomance
    
    let locManager = CLLocationManager()
    var cityName = ""
    var temp_c = ""
    var cond = ""
    var condLink = ""
    var lat: Double = 0.0
    var long: Double = 0.0
    
    
    // MARK: Make structure for API data
        
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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locManager.delegate = self
        locManager.requestWhenInUseAuthorization()
        locManager.requestLocation()
 
        cityNameLable.text = ""
        tempLable.text = ""
        conditionLable.text = ""
        
    }
    
//MARK: Button for get current location
    
    @IBAction func currentLocationPressed(_ sender: UIButton) {
    
            locManager.requestLocation()
                          let alert = UIAlertController(title: "Увага", message: "Використати поточну геолокацію для прогнозу погоди?", preferredStyle: .actionSheet)
                                alert.addAction(UIAlertAction(title: "Ні", style: .cancel))
                                alert.addAction(UIAlertAction(title: "Добре", style: .default, handler: { _  in
            
                                self.setWeatherValue()
                                }))
                        present(alert, animated: true)
        }
    }
  
//MARK: Extention MainVC

extension MainVC {
    
    func getApiData (lattitude lat: Double, longitude long: Double) {
        
        let urlForLocation = "https://api.weatherapi.com/v1/current.json?key=001aecb53c464f309e0205050232103&q=\(lat),\(long)&lang=uk"
        let url = URL(string: urlForLocation)
        let session =  URLSession.shared
        session.dataTask(with: url!) { [self]( data, response, error )  in
            if response != nil {
    
            } else { return }
            
            guard let data = data  else { return }
            do {
                _ = try JSONSerialization.jsonObject(with: data )
                let decoder = JSONDecoder()
                let weather: WeatherData = try decoder.decode(WeatherData.self, from: data)
                
                    cityName = weather.location.name
                    temp_c = String(weather.current.temp_c) + "°"
                    cond = weather.current.condition.text
                    condLink = "https:" + weather.current.condition.icon
                    
                } catch {
                print(error)
            }
        }.resume()
    }
}

// Function to set visual information to the mainVC

extension MainVC {
    
    func setWeatherValue() {
        conditionImage.load(urlString: condLink)
        cityNameLable.text = cityName
        tempLable.text = temp_c
        conditionLable.text = cond
     }
}

// Functions of location manager

extension MainVC {

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
         print("error:: \(error.localizedDescription)")
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locManager.requestLocation()
            lat = locManager.location?.coordinate.latitude ?? 0.0
            long = locManager.location?.coordinate.longitude ?? 0.0
            getApiData(lattitude: lat, longitude: long)
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (locations.first != nil) && (locations.first != locations.last) {
            locManager.requestLocation()
            lat = locManager.location?.coordinate.latitude ?? 0.0
            long = locManager.location?.coordinate.longitude ?? 0.0
            getApiData(lattitude: lat, longitude: long)
        }
    }
}

//MARK: Extention UIImageView for download image from URL

extension UIImageView {
    func load(urlString : String) {
        guard let url = URL(string: urlString)else {
            return
        }
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}



