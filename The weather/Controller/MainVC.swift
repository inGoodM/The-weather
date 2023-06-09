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
    var urlForCurrentLocation = ""
    var cityName = ""
    var temp_c = ""
    var cond = ""
    var condLink = ""
    var lat: Double = 0.0
    var long: Double = 0.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locManager.delegate = self
        locManager.requestWhenInUseAuthorization()
        locManager.requestLocation()
 
        cityNameLable.text = ""
        tempLable.text = ""
        conditionLable.text = ""
    
    }
    
    
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

    
    
//MARK: Button for get current location
    
    @IBAction func currentLocationPressed(_ sender: UIButton) {
   
        locManager.requestLocation()
    
        lat = locManager.location?.coordinate.latitude ?? 77
        long = locManager.location?.coordinate.longitude ?? 88
    
        let alert  = UIAlertController(title: "Увага", message: "Використати поточну геолокацію для прогнозу погоди?", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Ні", style: .cancel))
            alert.addAction(UIAlertAction(title: "Добре", style: .default, handler: { _  in
                
                DispatchQueue.main.async {
                    self.urlForCurrentLocation = "https://api.weatherapi.com/v1/current.json?key=001aecb53c464f309e0205050232103&q=\(self.lat),\(self.long)&lang=uk"
                    self.getApiData(currentLocation: self.urlForCurrentLocation)
                    self.setWeatherValue()
                }
                }))
                present(alert, animated: true)
            
        }
    
    }
  
//MARK: Extention MainVC

extension MainVC {
    
    func getApiData (currentLocation url: String) {
        
        let url = URL(string: url)
        let session = URLSession.shared
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

// Функція встановлення параметрів поточної локації

extension MainVC {
    
    func setWeatherValue() {
        conditionImage.load(urlString: condLink)
        cityNameLable.text = cityName
        tempLable.text = temp_c
        conditionLable.text = cond
     }
}

extension MainVC {

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
         print("error:: \(error.localizedDescription)")
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locManager.requestLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.first != nil {
    
        }
    }
}

//MARK: Розширення UIImageView для загрузки картинки з URL


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



