//
//  NetworkWeatherManager.swift
//  Weather
//
//  Created by Артём on 11.11.2022.
//

import Foundation
import CoreLocation

protocol NetworkWeatherManagerDelegate: AnyObject {
    func updateInterface(_: NetworkWeatherManager, with currentWeather: CurrentWeather)
}

class NetworkWeatherManager {
    
    enum RequestType {
        case cityName(city: String)
        case coordinate(latitude: CLLocationDegrees, longitude: CLLocationDegrees)
    }
    
    weak var delegate: NetworkWeatherManagerDelegate?
    
    func fetchCurrentWeather(for requestType: RequestType) {
      
        var params = ["apiKey": "\(API.apiKey)", "units": "metric"]
        
        switch requestType {
        case .cityName(let city):
            params["q"] = "\(city)"
            
        case .coordinate(let latitude, let longitude):
            params["lat"] = "\(latitude)"
            params["lon"] = "\(longitude)"
        }
        
        guard let url = url(params: params) else { return }
        performRequest(with: url)
    }
    
    fileprivate func performRequest(with url: URL?) {
        guard let url = url else { return }
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { data, response, error in
            if let data = data {
                if let currentWeather = self.parseJSON(withData: data) {
                    DispatchQueue.main.async {
                        self.delegate?.updateInterface(self, with: currentWeather)
                    }
                }
            }
        }
        task.resume()
    }
    
    private func url(params: [String:String]) -> URL? {
        var components = URLComponents()
        components.scheme = API.scheme
        components.host = API.host
        components.path = API.weather
        components.queryItems = params.map{ URLQueryItem(name: $0, value: $1) }
        return components.url
        
    }

    private func parseJSON(withData data: Data) -> CurrentWeather? {
        let decoder = JSONDecoder()
        do {
            let currentWeatherData = try decoder.decode(CurrentWeatherData.self, from: data)
            guard let currentWeather = CurrentWeather(currentWeatherData: currentWeatherData) else {
                return nil
            }
            return currentWeather
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return nil
    }
}
