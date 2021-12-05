//
//  ApiResponse.swift
//  prayerapp
//
//  Created by Ahmed Yacoob on 10/2/21.
//

import Foundation


struct ApiResponse: Decodable{
    let code: Int
    let status: String
    let data: [PrayerData]
    
}

struct PrayerData: Decodable{
    let timings: Timings
    let date: CurrentDate
}

struct CurrentDate: Decodable{
    let gregorian: DateIdentifier
    let hijri: DateIdentifier
}

struct DateIdentifier: Decodable{
    let year: String
    let day: String
    let month: Month
    //    let date: String
}

struct Month: Decodable{
    let number: Int
    let en: String
}

struct Timings: Decodable {
    let Fajr: String
    let Sunrise: String
    let Dhuhr: String
    let Asr: String
    let Maghrib: String
    let Isha: String
}


public enum Result<T, U> {
    case success(T)
    case failure(U)
}

public enum DateChecking: Error{
    case outofsync(msg: String)
}


struct PrayerFromModel {
    let islamicDate: String
    let gregorianDate: String
    let timings: [String]
}

class Model {
    var prayerURL = "https://api.aladhan.com/v1/calendar"
    var latitude = 34.0522
    var longitude = -118.2437
    var apiresponse: ApiResponse? = nil
    
    var prayerTimeIndex: Int = 0
    
    var prayerModel: [PrayerFromModel] = []
    var noapi=true
    
    
    var noapiModel: [PrayerFromModel] = [
        PrayerFromModel(islamicDate: "123", gregorianDate: "456", timings: ["1","2"]),
        PrayerFromModel(islamicDate: "1243", gregorianDate: "4526", timings: ["1234","2345"]),
        PrayerFromModel(islamicDate: "1233", gregorianDate: "4536", timings: ["23","24"])
    ]
    
    func fetchPrayerTimes(completion: @escaping (Result<String, Error>) -> ()){
        if noapi{
            completion(.success(""))
            return
        }
        let queryItems = [URLQueryItem(name: "latitude", value: String(self.latitude)), URLQueryItem(name: "longitude", value: String(self.longitude))]
        var urlComps = URLComponents(string: self.prayerURL)!
        urlComps.queryItems = queryItems
        let result = urlComps.url!
        let task = URLSession.shared.dataTask(with: result) {[weak self] data, _ ,err in
            print("In task")
            guard let data = data, err==nil else{
                completion(.failure(err!))
                return
            }
            do{
                let apiresponse = try JSONDecoder().decode(ApiResponse.self, from: data)
                self?.apiresponse = apiresponse
                //                self?.convertandInitializePrayerTime()
                completion(.success(""))
                return
            }
            catch{
                print("error in fetching prayers")
                print(error)
            }
            
        }
        task.resume()
    }
    
    
    func convertandInitializePrayerTime(completion: @escaping (Result<PrayerFromModel, Error>) -> ()){
        if noapi{
            completion(.success(noapiModel[0]))
            self.prayerTimeIndex = 0
            self.prayerModel = noapiModel
            return
        }
        guard let apiresponse = self.apiresponse else{
            completion(.failure(DateChecking.outofsync(msg: "Cannot connect to database")))
            return
        }
        
        var pt: [String] = []
        DispatchQueue.global().async {
            for i in 0..<apiresponse.data.count{
                pt = []
                let currtime = apiresponse.data[i].timings
                
                let tempPrayerTimings = [currtime.Fajr.split(separator: " ")[0], currtime.Sunrise.split(separator: " ")[0], currtime.Dhuhr.split(separator: " ")[0],currtime.Asr.split(separator: " ")[0], currtime.Maghrib.split(separator: " ")[0], currtime.Isha.split(separator: " ")[0]]
                
                
                for time in tempPrayerTimings {
                    //print("Time \(time)")
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "HH:mm"
                    
                    let date = dateFormatter.date(from: String(time))
                    
                    //check if date is nil and throw an error
                    guard let date = date else{
                        completion(.failure(DateChecking.outofsync(msg: "Database corrupted")))
                        return
                    }
                    dateFormatter.dateFormat = "h:mm a"
                    let Date12 = dateFormatter.string(from: date)
                    pt.append(Date12)
                }
                
                let ptm = PrayerFromModel(islamicDate: self.getIslamicDate(i: i), gregorianDate: self.getGregorianDate(i: i), timings: pt)
                self.prayerModel.append(ptm)
            }
            
            completion(.success(self.getCurrentPrayer()))
        }
    }
    
    func getIslamicDate(i: Int) -> String{
        guard let condensed = self.apiresponse?.data[i] else {
            return ""
        }
        return condensed.date.hijri.day + " " + condensed.date.hijri.month.en
            + " " + condensed.date.hijri.year
    }
    
    
    func getGregorianDate(i: Int) -> String{
        guard let condensed = self.apiresponse?.data[i] else {
            return ""
        }
        
        
        return condensed.date.gregorian.month.en + " " + condensed.date.gregorian.day
            + " " + condensed.date.gregorian.year
    }
    
    func getCurrentPrayer() -> PrayerFromModel{
        let date1 = Date()
        let calendar1 = Calendar.current
        let components1 = calendar1.dateComponents([.day], from: date1)
        let dayOfMonth = components1.day!
        prayerTimeIndex = dayOfMonth - 1
        return prayerModel[prayerTimeIndex]
    }
    
    func incrementPrayerDate() -> PrayerFromModel{
        if prayerTimeIndex < prayerModel.count - 1{
            prayerTimeIndex = prayerTimeIndex + 1
            return prayerModel[prayerTimeIndex]
        }
        return prayerModel[prayerTimeIndex]
    }
    
    func decrementPrayerDate() -> PrayerFromModel{
        if prayerTimeIndex > 0{
            prayerTimeIndex = prayerTimeIndex - 1
            return prayerModel[prayerTimeIndex]
        }
        return prayerModel[prayerTimeIndex]
    }
}

