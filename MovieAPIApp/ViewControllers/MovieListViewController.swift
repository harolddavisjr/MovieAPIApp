//
//  MovieListViewController.swift
//  MovieAPIApp
//
//  Created by Harold Davis on 11/15/17.
//  Copyright © 2017 Zendoart. All rights reserved.
//

import Foundation
import UIKit

class MovieListViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    
    var appState = AppStateController.sharedInstance
    var movieMC = MovieModelController.sharedInstence

    var moviesArr: [Movie] = []
    
    
    
    //MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !appState.hasSeenWelcomePage {
            self.present(appState.presentWelcomeScreen(), animated: true)
        }
        
        DispatchQueue.main.async {
            self.getMovies()
        }
    }
    
    
    func getMovies() {
        print("Loading...")
        moviesArr = movieMC.getSavedMovies()
        
        appState.services.getMovies { moviesFromServer, error in
            if let moviesFromServer = moviesFromServer {
                // Check if database is not empty...
                if !self.moviesArr.isEmpty {
                    let movieIDs = self.moviesArr.map { $0.id }
                    for movie in moviesFromServer {
                        if !movieIDs.contains(movie.id) {
                            self.moviesArr.append(movie)
                        }
                    }
                }
                // If database is empty populate array with what is on the server and save all objects.
                else {
                    DispatchQueue.main.async {
                        self.moviesArr = moviesFromServer
                        self.appState.databaseInterface.update {
                            self.appState.databaseInterface.save(moviesFromServer)                            
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.moviesArr = self.filterMovies().sorted { $0.comparableName < $1.comparableName }
                self.tableView.reloadData()
                print("Loading complete...")
            }
        }
    }
    
    
    /// Uses remove duplicates method to return a unique list of movies.
    func filterMovies() -> [Movie] {
        var movieNames: [String] = self.moviesArr.map { $0.comparableName }
        movieNames = removeDuplicatesFrom(array: movieNames)
        
        var newMovieArr: [Movie] = []
        
        if !movieNames.isEmpty {
            for movie in moviesArr {
                if movieNames.contains(movie.name!) {
                    let index = movieNames.index(of: movie.name!)
                    newMovieArr.append(movie)
                    movieNames.remove(at: index!)
                }
            }
        }
        
        return newMovieArr
    }
    
    /**
     Remove Duplicates From an array of strings. Easy to use with an array of movie names.
     
     - parameter array: array of strings to be sorted for uniqueness.
     
     - returns: Unique Array of strings.
     */
    func removeDuplicatesFrom(array: [String]) -> [String] {
        //Create an empty Set to track unique items
        var set = Set<String>()
        let result = array.filter {
            guard !set.contains($0) else {
                //If the set already contains this object, return false
                //so we skip it
                return false
            }
            //Add this item to the set since it will now be in the array
            set.insert($0)
            //Return true so that filtered array will contain this item.
            return true
        }
        return result
    }
}

extension MovieListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moviesArr.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let movie = moviesArr[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as! MovieTableViewCell
        
        cell.configure(movie)
        
        return cell
    }
}

extension MovieListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = moviesArr[indexPath.row]
        
        let storyboard = UIStoryboard(name: "MovieDetails", bundle: nil)
        let movieDetailVC = storyboard.instantiateViewController(withIdentifier: "MovieDetailViewController") as! MovieDetailViewController
        
        movieDetailVC.selectedMovie = movie
        
        self.navigationController?.pushViewController(movieDetailVC, animated: true)
    }
}
