//
//  PrayerViewModel.swift
//  prayerapp
//
//  Created by Ahmed Yacoob on 10/1/21.
//

import Foundation
import SwiftUI
import CoreLocation

class PrayerViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    
    private let locationManager = CLLocationManager()
    private var authorizationStatus: CLAuthorizationStatus
    private var lastSeenLocation: CLLocation?
    
    //keep
    let prayers = ["Fajr", "Sunrise", "Dhuhr", "Asr", "Maghrib", "Isha"]
    
    //keep
    @Published var prayerfromModel = PrayerFromModel(islamicDate: "", gregorianDate: "", timings:[String]())
    
    var model = Model()
    
    override init(){
        authorizationStatus = locationManager.authorizationStatus
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //requestPermission()
        
        
        fetchPrayerTimes() //call on a separate thread
        
    }
    
    
    
    func requestPermission() {
        print("requesting authorization")
        locationManager.requestWhenInUseAuthorization()
    }

//    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//        print("Did change authorization")
//        authorizationStatus = manager.authorizationStatus
//
//        switch authorizationStatus{
//        case .denied, .notDetermined, .restricted:
//            print("denied")
//        case .authorizedAlways, .authorizedWhenInUse:
//            print("accepted")
//            locationManager.requestLocation()
//        default:
//            print("unknown")
//        }
//    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastSeenLocation = locations.first
        guard let lsl = lastSeenLocation else{return}
        model.latitude = lsl.coordinate.latitude
        model.longitude = lsl.coordinate.longitude
        
        print("Latitude: \(model.latitude)")
        print("Longitude: \(model.longitude)")
       // fetchPrayerTimes()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        print(error)
    }
    
    func fetchPrayerTimes(){
        print("in fetch prayer times")
        model.fetchPrayerTimes(){[weak self]
            result in
            switch result{
            case .failure(let err):
                print(err)
            case .success(_):
                print("success 1")
                self?.model.convertandInitializePrayerTime(){
                    r in
                    switch r {
                    case .failure(let error):
                        print(error)
                    case .success(let pm):
//                        for t in pm.timings{
//                            print(t)
//                        }
                        print("success 2")
                        DispatchQueue.main.async {
                            self?.prayerfromModel = pm
                        }
                    }
                    
                }
            }
        }
    }
    
    func decrementPrayerDate(){
        let prayerTime = model.decrementPrayerDate()
        DispatchQueue.main.async{
            self.prayerfromModel = prayerTime
        }
    }
    
    func incrementPrayerDate(){
        let prayerTime = model.incrementPrayerDate()
        DispatchQueue.main.async{
            self.prayerfromModel = prayerTime
        }
    }
    
//    func getCurrentDayPrayer(){
////        let date1 = Date()
////        let calendar1 = Calendar.current
////        let components1 = calendar1.dateComponents([.day], from: date1)
////        let dayOfMonth = components1.day!
//
//    }
    
}
