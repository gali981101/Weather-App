//
//  WeatherManager.swift
//  Clima
//
//  Created by Terry Jason on 2023/9/19.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, _ weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    
    var delegate: WeatherManagerDelegate?
    
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=900348cc03864942607d88054b049ed6&units=metric"
    
}


// MARK: - Fetch Weather

extension WeatherManager{
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeatherWithCoordinate(lat: CLLocationDegrees, lon: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(lat)&lon=\(lon)"
        performRequest(with: urlString)
    }
    
}

// MARK: - Networking

extension WeatherManager {
    
    private func performRequest(with urlString: String) {
        //1. Create a URL
        if let url = URL(string: urlString) {
            //2. Create a URLSession
            createUrlSession(url: url)
        }
    }
    
    private func createUrlSession(url: URL) {
        let session = URLSession(configuration: .default)
        
        //3. Give the session a task
        giveTask(url: url, session: session)
    }
    
    private func giveTask(url: URL, session: URLSession) {
        let task = session.dataTask(with: url, completionHandler: handlerFunc(data:response:error:))
        
        //4. Start the task
        task.resume()
    }
    
    private func handlerFunc(data: Data?, response: URLResponse?, error: Error?) {
        if error != nil {
            delegate?.didFailWithError(error: error!)
            return
        }
        
        if let data = data {
            processWeather(parseJSON(data))
        }
    }
    
    private func processWeather(_ weather: WeatherModel?) {
        if let weather = weather {
            delegate?.didUpdateWeather(self, weather)
        }
    }
    
    private func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let weatherObject = WeatherModel(conditionId: decodedData.weather[0].id, cityName: decodedData.name, temperature: decodedData.main.temp)
            
            return weatherObject
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}
