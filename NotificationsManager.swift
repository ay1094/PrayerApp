//
//  NotificationsManager.swift
//  prayerapp
//
//  Created by Ahmed Yacoob on 12/2/21.
//

import Foundation
import UserNotifications

class NotificationsManager: ObservableObject{
    @Published private(set) var notifications: [UNNotificationRequest] = []
    @Published private(set) var authorizationStatus: UNAuthorizationStatus?
    
    func reloadauthorizationStatus(){
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.authorizationStatus = settings.authorizationStatus
            }
            
        }
    }
    
    func requestAuthorization(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { isGranted, _ in
            self.authorizationStatus = isGranted ? .authorized : .denied
        }
    }
    
    func reloadLocalNotifications(){
        UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
            DispatchQueue.main.async {
                self.notifications = notifications
            }
        }
    }
}
