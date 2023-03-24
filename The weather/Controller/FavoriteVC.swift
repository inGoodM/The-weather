//
//  FavoriteVC.swift
//  The weather
//
//  Created by InGMood on 21.03.2023.
//

import UIKit

class FavoriteVC: UIViewController {

    
    @IBOutlet weak var tableViewFavor: UITableView!
    
    struct FavorData {
        var titleCity: String
        var imageWeather: UIImage
        var tempCity: Int
    }
    
    var arrayFavorData: [FavorData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewFavor.dataSource = self
        
        var firstElement = FavorData(titleCity: "Mykolaiv", imageWeather: UIImage(systemName: "star")!, tempCity: 12)
        arrayFavorData.append(firstElement)
        
    }
 
 
}

extension FavoriteVC:  UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayFavorData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableViewFavor.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FavoriteCell
        cell.lableFavor.text = arrayFavorData[0].titleCity + String(arrayFavorData[0].tempCity)
        cell.imageFavor.image = arrayFavorData[0].imageWeather
        
        return cell
    }
    
    
}
