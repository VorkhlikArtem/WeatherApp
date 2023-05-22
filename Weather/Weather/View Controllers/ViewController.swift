//
//  ViewController.swift
//  Weather
//
//  Created by Артём on 11.11.2022.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var feelsLikeTemperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    var networkWeatherManager = NetworkWeatherManager()
    
    lazy var locationManager: CLLocationManager = {
        let lm = CLLocationManager()
        lm.delegate = self
        lm.desiredAccuracy = kCLLocationAccuracyKilometer
        lm.requestWhenInUseAuthorization()
        return lm
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        networkWeatherManager.delegate = self
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
        }
    }

    @IBAction func searchButtonTapped(_ sender: UIButton) {
        presentSearchAlertController(withTitle: "Enter city name", message: nil, style: .alert) { [weak self] city in
            self?.networkWeatherManager.fetchCurrentWeather(for: .cityName(city: city))
        }
    }
}

 //MARK: - NetworkWeatherManagerDelegate
extension ViewController: NetworkWeatherManagerDelegate {
    func updateInterface(_: NetworkWeatherManager, with currentWeather: CurrentWeather) {
        weatherIconImageView.image = UIImage(systemName: currentWeather.systemIconNameString)
        temperatureLabel.text = currentWeather.temperatureString
        feelsLikeTemperatureLabel.text = currentWeather.feelsLikeTemperatureString 
        cityLabel.text = currentWeather.cityName
    }
}

//MARK: - CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        networkWeatherManager.fetchCurrentWeather(for: .coordinate(latitude: latitude, longitude: longitude))
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        networkWeatherManager.fetchCurrentWeather(for: .cityName(city: "London"))
    }
}
