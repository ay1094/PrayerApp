//
//  ContentView.swift
//  prayerapp
//
//  Created by Ahmed Yacoob on 9/25/21.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var viewModel = PrayerViewModel()
    @State private var isShowingNotificationsView = false
    var body: some View {
        let columns: [GridItem] =
            Array(repeating: .init(.flexible(), spacing: -100), count: 2)
        
        NavigationView{
//            NavigationLink(destination: NotificationsView(),
//                           isActive: self.$isShowingNotificationsView)
//                { EmptyView() }.frame(width: 0, height: 0).disabled(true)
            ZStack{
                Rectangle()
                    .fill(Color.green)
                VStack{
                    Text(viewModel.prayerfromModel.gregorianDate)
                    Text(viewModel.prayerfromModel.islamicDate)
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(0..<viewModel.prayerfromModel.timings.count, id: \.self) { i in
                            Text(viewModel.prayers[i])
                            Text(viewModel.prayerfromModel.timings[i])
                        }
                    }
                    .padding()
                    ButtonView(viewModel: viewModel)
                }
                .animation(.spring())
                .padding(10)
                .border(Color.black)
                .background(Color.white)
            }.navigationTitle(Text("Prayer Times"))
            .navigationBarItems(
                  trailing: Button(action: {}, label: {
                    NavigationLink(destination: NotificationsView()) {
                          Image(systemName: "bell")
                     }
                  }))
        }
        //            }.navigationBarItems(
        //                trailing: Button(action:{self.isShowingNotificationsView = true }) { Image(systemName: "bell") }
        //)
        
    }
}


struct ButtonView: View{
    var viewModel: PrayerViewModel
    var body: some View {
        HStack{
            Button {
                viewModel.decrementPrayerDate()
            } label: {
                Image(systemName: "arrow.left")
            }
            Spacer()
            Button {
                viewModel.incrementPrayerDate()
            } label: {
                Image(systemName: "arrow.right")
            }
        }
    }
}


struct NotificationsView: View{
    @State private var isShowingSheet = false
    @State private var notificationsManager = NotificationsManager()
    var body: some View{
        Group{
            List(notificationsManager.notifications, id: \.identifier){ notification in
                Text(notification.content.title)
            }
                .navigationTitle("Notifications")
                .navigationBarItems(trailing: Button(action: {isShowingSheet = true}, label: {Image(systemName: "plus")}))
        }
        .onAppear(perform: {
            notificationsManager.reloadauthorizationStatus()
        })
        .onChange(of: notificationsManager.authorizationStatus, perform: { authorizationStatus in
            switch authorizationStatus{
            case .notDetermined:
                notificationsManager.requestAuthorization()
            case .authorized:
                notificationsManager.reloadLocalNotifications()
            default:
                break
            }
        })
        .sheet(isPresented: $isShowingSheet){
                CreateNotificationView(isShowingSheet: $isShowingSheet)
        
    }
    
    }
}


struct CreateNotificationView: View{
    @Binding var isShowingSheet: Bool
    @State private var title: String = ""
    @State private var date = Date()
    var body: some View{
        NavigationView{
            Form{
                TextField("Title", text: $title)
                DatePicker("Time", selection: $date, displayedComponents: [.hourAndMinute])
                if self.isUserInformationValid() {
                    Button(action: {
                        print("Updated profile")
                    }, label: {
                        Text("Create")
                    })
                }
            }
                .navigationTitle("Add Notification")
                .navigationBarItems(trailing: Button(action: {isShowingSheet = false}, label: {Image(systemName: "xmark")}))
        }
           
        
    }
    private func isUserInformationValid() -> Bool{
        if self.title.isEmpty{
            return false
        }
        return true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
