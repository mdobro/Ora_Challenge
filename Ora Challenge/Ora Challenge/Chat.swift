//
//  Chat.swift
//  Ora Challenge
//
//  Created by Mike Dobrowolski on 9/18/17.
//  Copyright © 2017 Ora. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class Chat {
    
    let baseURL = "https://private-e46dd-orachallenge.apiary-mock.com/api/v1/"
    var headers = [ "Content-Type" : "application/vnd.api+json", "Accept" : "application/vnd.api+json"]
    
    var delegate:ViewController!
    var username:String!
    var messages = [Message]()
    
    func startSession() {
        Alamofire.request(baseURL+"sessions", method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch(response.result) {
            case .success(let value): //success
                let json = JSON(value)
                //print(json)
                let responseHeaders = response.response!.allHeaderFields
                self.headers["Authorization"] = (responseHeaders["Authorization"] as! String)
                self.username = json["included"][0]["attributes"]["username"].stringValue
                self.getMessage(url: self.baseURL + "messages?page[number]=1&page[size]=10")
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func getMessage(url:String) {
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch(response.result) {
            case .success(let value): //success
                let json = JSON(value)
                //print(json)
                let date = json["data"][0]["attributes"]["created_at"].stringValue
                let formattedDate = self.formatISODate(isoDateString: date)
                let user = json["included"][0]["attributes"]["username"].stringValue
                let message = json["data"][0]["attributes"]["message"].stringValue
                self.messages.append(Message(user: user, date: formattedDate.0, time: formattedDate.1, message: message))
                self.delegate.reloadChat()
                //call again if there is another message
                //TODO: Test with production API
                if let nextLink = json["links"]["next"].string {
                    self.getMessage(url: nextLink)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func formatISODate(isoDateString:String) -> (String, String) {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.timeZone = TimeZone(abbreviation: "UTC")
        if let date = isoFormatter.date(from: isoDateString) {
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = "MMM d"
            let dateString = dateFormatter.string(from: date)
            dateFormatter.dateFormat = "hh:mma"
            let timeString = dateFormatter.string(from: date)
            return (dateString, timeString)
        }
        return ("", "")
    }
}
