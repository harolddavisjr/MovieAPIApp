//
//  APIServices.swift
//  MovieAPIApp
//
//  Created by Harold Davis on 11/15/17.
//  Copyright © 2017 Zendoart. All rights reserved.
//

import Foundation


class APIServices {
    static var sharedInstance = APIServices()
    
    let databaseInterface = DatabaseInterface.sharedInstance
    
    var baseUrl: String = "https://data.sfgov.org/api/views/yitu-d5am/rows.json?accessType=DOWNLOAD"
    
    func getMovies(completion: @escaping(_ movieArr: [Movie]?, _ error: NSError?) -> Void) {
        
        guard let url = URL(string: baseUrl) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if error != nil {
                completion(nil, error as NSError?)
                return
            }
           
            // MovieArr to return in completion.
            var movies: [Movie] = []
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String : Any]
                    
                    if let moviesArr = json["data"] as? [[Any]] {
                        for movie in moviesArr {
                            movies.append(Movie(with: movie))
                            
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.databaseInterface.update {
                            self.databaseInterface.save(movies)
                        }
                        
                    }
                    
                    completion(movies, nil)
                }
                catch let jsonError {
                    completion(nil, jsonError as NSError)
                    print(jsonError)
                }
            }
            }.resume()
    }
    
    
}
