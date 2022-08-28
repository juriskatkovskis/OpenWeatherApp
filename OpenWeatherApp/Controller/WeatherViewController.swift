//
//  ViewController.swift
//  OpenWeatherApp
//
//  Created by juris.katkovskis on 28/08/2022.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    
    
    let weatherDataModel = WeatherDataModal()
        let locationManager = CLLocationManager()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            let location = locations[locations.count - 1]
            
            if location.horizontalAccuracy > 0{
                locationManager.stopUpdatingLocation()
                
                print("long: \(location.coordinate.longitude), lat: \(location.coordinate.latitude)")
                let long = String(location.coordinate.longitude)
                let lat = String(location.coordinate.latitude)
                
                let params: [String: String] = ["lat": lat, "lon": long, "appid": weatherDataModel.apiID]
                
                getWeatherData(url: weatherDataModel.apiUrl, params: params)
            }
        }
        
        func getWeatherData(url: String, params: [String: String]){
            AF.request(url, method: .get, parameters: params).responseData { response in
                if response.value != nil {
                    let waetherJSON: JSON = JSON(response.value!)
                    print("waetherJSON:", waetherJSON)
                    self.updateWeatherData(json: waetherJSON)
                }else{
                    self.cityLabel.text = "Weather unavailible 😢"
                }
            }
        }
        
        func updateWeatherData(json: JSON){
            
            if let tempResult = json["main"]["temp"].double {
                weatherDataModel.temp = Int(tempResult - 273.13)
                weatherDataModel.name = json["name"].stringValue
                weatherDataModel.condition = json["weather"][0]["id"].intValue
                weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
                updateUI()
            }else{
                self.cityLabel.text = "Weather unavailible 😢"
            }
            
        }
        
        func updateUI(){
            cityLabel.text = weatherDataModel.name
            tempLabel.text = "\(weatherDataModel.temp)º"
        }


    }
