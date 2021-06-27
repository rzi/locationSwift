//
//  ViewController.swift
//  Get user Location
//
//  Created by Rafał Ziętak on 30/05/2021.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate,UITextFieldDelegate{

    @IBOutlet weak var TF1: UITextField!
    @IBOutlet weak var TF2: UITextField!
    
    @IBOutlet weak var animalTableView: UITableView!
    private var locationManager:CLLocationManager?
    var animals = Array<String>(repeating: "", count: 1)
    var refreshControl = UIRefreshControl()
    var dateFormatter = DateFormatter()
    var isChecked = false
    var IdIndex:String = "KOL1234"
    var IdLine:String = "1"
    @IBAction func clearButton(_ sender: UIButton) {
        animals.removeAll()
        animalTableView.reloadData()
    }
    
   
    private let latLngLabel: UILabel = {
            let label = UILabel()
            label.backgroundColor = .systemFill
            label.numberOfLines = 0
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 26)
            return label
    }()
        override func viewDidLoad() {
            super.viewDidLoad()
            self.TF1.delegate = self
            self.TF2.delegate = self
            animalTableView.delegate = self
            animalTableView.dataSource = self
            TF1.delegate = self
            TF2.delegate = self

            latLngLabel.frame = CGRect(x: 20, y: view.bounds.height / 2.7 - 50, width: view.bounds.width - 40, height: 100)
            view.addSubview(latLngLabel)
            getUserLocation()
        }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("allow editing")
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("begin editing")
        textField.becomeFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("editing is done")
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        print("enter was pressed")
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        print("textField: \(textField.text!)")
    }
    
    @IBAction func didTapButton(){
        let vc = storyboard?.instantiateViewController(identifier: "second") as! SecondViewController
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.idName = TF1.text!
        vc.idIndex = TF2.text!
        navigationController?.pushViewController(vc, animated:true)
    }
    @IBAction func start_stop(_ sender: UISwitch) {
        print ("fff")
        if TF1.text != "" && TF2.text != "" {
        isChecked = !isChecked
                  if isChecked {
                        print("ON")
                  } else {
                      print ("OFF")
                  }
        }
        else{
            let alert = UIAlertController(title: "Alert", message: "Wypałnij pola numer linii oraz numer trasy ", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            sender.setOn(false, animated: true)
        }
    }
 
    func getUserLocation() {
        locationManager = CLLocationManager()
        locationManager?.requestAlwaysAuthorization()
        locationManager?.startUpdatingLocation()
        locationManager?.delegate = self
        }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            if(isChecked){
                let date = Date()
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let dateString = df.string(from: date)
                print(dateString)

                latLngLabel.text = " \(dateString) \nLat : \(location.coordinate.latitude) \nLng :  \(location.coordinate.longitude)"
                animals.insert(contentsOf: [" nr:\(animals.count) data: \(dateString)\nLat : \(location.coordinate.latitude) \nLng :  \(location.coordinate.longitude)"], at: 0)
                print ("nr: \(animals.count) , coords: \(latLngLabel.text)")

                self.viewWillAppear(true)
                animalTableView.reloadData()
                let myTimeStamp :Int64 = Int64((date.timeIntervalSince1970).rounded())
                    print("myTimeStamp: \(myTimeStamp)")
                saveToDB(time: myTimeStamp, lat: location.coordinate.latitude, longitude: location.coordinate.longitude, s: location.speed, idName: TF1.text!, idIndex: TF2.text!)
            }
        }
    }
    func saveToDB (time:Int64,lat:Double,longitude:Double,s:Double,idName:String,idIndex:String){
        print("czas: \(time)")
        let session = URLSession.shared
        let url = URL(string: "https://busmapa.ct8.pl/saveToDB.php?time=\(time)&lat=\(lat)&longitude=\(longitude)&s=\(s)&idName=\(idName)&idIndex=\(idIndex)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        print("request: \(request)")
        let task = session.dataTask(with: request as URLRequest as URLRequest, completionHandler: {(data, response, error) in
                if let response = response {
                    let nsHTTPResponse = response as! HTTPURLResponse
                    let statusCode = nsHTTPResponse.statusCode
                    print ("status code = \(statusCode)")
                }
//                  print ("response: \(response)")
                if let error = error {
                    print ("error: \(error)")
                }
                        
                if let data = data {
                   
                }
                })
                task.resume()
    }
}
class SecondViewController: UIViewController{
    var idName:String = ""
    var idIndex: String = ""
    @IBOutlet private var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print ("idName \(idName)")
        print ("idIndex \(idIndex)")
        view.backgroundColor = .blue
        title = "Mapa"
        getFromDB(idName: idName, idIndex: idIndex)
    }
    
    func getFromDB(idName: String, idIndex: String) {
        let session = URLSession.shared
        let url = URL(string: "https://busmapa.ct8.pl/getBus.php?idName=\(idName)&idIndex=\(idIndex)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        print("request: \(request)")
        let task = session.dataTask(with: request as URLRequest as URLRequest, completionHandler: {(data, response, error) in
                if let response = response {
                    let nsHTTPResponse = response as! HTTPURLResponse
                    let statusCode = nsHTTPResponse.statusCode
                    print ("status code = \(statusCode)")
                }
//                  print ("response: \(response)")
                if let error = error {
                    print ("error: \(error)")
                }
                struct Coordinates: Decodable {
                    var time: String
                    var lat:String
                    var longitude:String
                    var s:String
                    var idName:String
                    var idIndex:String
                }
                        
                if let data = data {
                    do {
                        let response = try JSONDecoder().decode([Coordinates].self, from: data)
                        let index = response.count
                        for n in 0...index-1 {
                            print(response[n].time,response[n].lat,response[n].longitude,response[n].s, response[n].idIndex, response[n].idName)
                            self.putPin(idName: response[n].idName, idIndex: response[n].idIndex, lat: response[n].lat, lon: response[n].longitude)
                        }
                    } catch {
                        print(error)
                    }
                }
                })
                task.resume()
    }
    
    func putPin(idName:String, idIndex:String, lat:String, lon:String){
        let coordinate = CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(lon)!)
        let region = MKCoordinateRegion(center: coordinate,latitudinalMeters: 10000,longitudinalMeters: 10000)
        mapView.setRegion(region, animated: true)
        let pin = pin(
          title: idName,
          locationName: idIndex,
          discipline: "Flag",
            coordinate: CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(lon)!))
        mapView.addAnnotation(pin)
    }
 
}
extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected one of the row")
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return animals.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = animalTableView.dequeueReusableCell(withIdentifier: "animalCell",for : indexPath )
        cell.textLabel?.text = animals[indexPath.row]

        //MARK: word wrapping in cell
         cell.textLabel?.numberOfLines=0 // line wrap
         cell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        return cell
    }
}
