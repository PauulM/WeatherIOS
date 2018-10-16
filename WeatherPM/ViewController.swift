//
//  ViewController.swift
//  WeatherPM
//
//  Created by Student on 09/10/2018.
//  Copyright © 2018 Student. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var forecasts = [DayConditions]()
    var currentDayIndex = 0;
    let maxDayIndex = 5;
    @IBOutlet weak var dateOutlet: UITextField!
    @IBOutlet weak var conditionsOutlet: UITextField!
    @IBOutlet weak var conditionsImageOutlet: UIImageView!
    @IBOutlet weak var tempOutlet: UITextField!
    @IBOutlet weak var maxTempOutlet: UITextField!
    @IBOutlet weak var minTempOutlet: UITextField!
    @IBOutlet weak var windDirOutlet: UITextField!
    @IBOutlet weak var windSpeedOutlet: UITextField!
    @IBOutlet weak var airPressureOutlet: UITextField!
    @IBOutlet weak var imageOutlet: UIImageView!
    
    @IBOutlet weak var nextButtonOutlet: UIButton!
    @IBOutlet weak var previousButtonOutlet: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var url = URL(string : "https://www.metaweather.com/api/location/523920/")!
        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            if error != nil {
                return
            }
            let responseJson = data
            do{
                let response = try JSONSerialization.jsonObject(with: responseJson!) as! [String: Any]
                let array = response["consolidated_weather"] as! [[String:Any]]
                for i in 0...self.maxDayIndex{
                    let currentDayForecast = array[i]
                    let dateString = (currentDayForecast["applicable_date"] as! String)
                    let dateArray = dateString.split(separator: "-").map(String.init)
                    var dayForecast = DayConditions()
                    dayForecast.day = Int(dateArray[2])
                    dayForecast.month = Int(dateArray[1])
                    dayForecast.year = Int(dateArray[0])
                    dayForecast.conditionType = (currentDayForecast["weather_state_name"] as! String)
                    dayForecast.conditionTypeAbbr = (currentDayForecast["weather_state_abbr"] as! String)
                    dayForecast.temp = (currentDayForecast["the_temp"] as! Double)
                    dayForecast.windSpeed = (currentDayForecast["wind_speed"] as! Double)
                    dayForecast.maxTemp = (currentDayForecast["max_temp"] as! Double)
                    dayForecast.minTemp = (currentDayForecast["min_temp"] as! Double)
                    dayForecast.windDirection = (currentDayForecast["wind_direction_compass"] as! String)
                    //dayForecast.rainfall = first["weather_state_abbr"] as! String
                    dayForecast.airPressure = (currentDayForecast["air_pressure"] as! Double)
                    self.forecasts.append(dayForecast)
                    if i==0 {
                        DispatchQueue.main.async {
                            self.updateView(dayNo: 0)
                        }
                    }
                }
            }
            catch{
                return
            }
        }
        task.resume()
        self.previousButtonOutlet.isEnabled = false;
    }

    func updateView(dayNo : Int) -> Void {
        let forecast = forecasts[dayNo]
        self.dateOutlet.text = "\(String(forecast.year))-\(String(forecast.month))-\(String(forecast.day))"
        self.conditionsOutlet.text = forecasts[dayNo].conditionType
        self.tempOutlet.text = String(format: "%.0f", forecast.temp) + " C"
        self.maxTempOutlet.text = String(format: "%.0f", forecast.maxTemp) + " C"
        self.minTempOutlet.text = String(format: "%.0f", forecast.minTemp) + " C"
        self.windDirOutlet.text = forecast.windDirection
        self.windSpeedOutlet.text = String(format: "%.0f", forecast.windSpeed) + " mph"
        self.airPressureOutlet.text = String(format: "%.0f", forecast.airPressure) + " mbar"
        self.loadImage(abbr: forecast.conditionTypeAbbr)
    }
    
    @IBAction func nextButtonAction() {
        self.previousButtonOutlet.isEnabled = true
        self.currentDayIndex += 1
        self.updateView(dayNo: currentDayIndex)
        if currentDayIndex == self.maxDayIndex {
            self.nextButtonOutlet.isEnabled = false
        }
    }

    @IBAction func previousButtonAction() {
        self.nextButtonOutlet.isEnabled = true
        self.currentDayIndex -= 1
        self.updateView(dayNo: currentDayIndex)
        if currentDayIndex == 0 {
            self.previousButtonOutlet.isEnabled = false
        }
    }
    
    func loadImage(abbr : String){
        print(abbr)
        var url = URL(string : "https://www.metaweather.com/static/img/weather/png/\(abbr).png")!
        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            if error != nil {
                return
            }
            if let res = response as? HTTPURLResponse {
                if let imageData = data {
                    let image = UIImage(data: imageData)
                    DispatchQueue.main.async {
                        self.imageOutlet.image = image
                    }

                } else {
                    return
                }
            }
        }
        task.resume()
    }
}

class DayConditions{
    var day : Int!
    var month : Int!
    var year : Int!
    var conditionType : String!
    var conditionTypeAbbr : String!
    var temp : Double!
    var maxTemp : Double!
    var minTemp : Double!
    var windSpeed : Double!
    var windDirection : String!
    var rainfall : String!
    var airPressure : Double!
}
