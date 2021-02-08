//
//  ViewController.swift
//  SDapp
//
//  Created by Hee Suk Yoon on 2021/02/05.
//

import UIKit
import MQTTClient

//The On/Off button class
class OnOffButton: UIButton {
    override var isSelected: Bool {
        didSet {
            self.backgroundColor = isSelected ? .blue : .clear
        }
    }

    override func awakeFromNib() {
        self.layer.cornerRadius = self.bounds.width * 0.5
        self.layer.masksToBounds = true
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.blue.cgColor
    }
}

class ViewController: UIViewController {

    let MQTT_HOST = "10.211.55.4" // IP address of the device where MQTT broker is setup.
    let MQTT_PORT: UInt32 = 1883 // Port number of the MQTT broker/
    
    //@IBOutlet private weak var button: OnOffButton!
    //@IBOutlet private weak var mqttStatusLabel: UILabel!
    @IBOutlet weak var button: OnOffButton!
    @IBOutlet weak var mqttStatusLabel: UILabel!
    
    var transport = MQTTCFSocketTransport() //holds the TCP/IP network configuration for connecting to the MQTT broker.
    var session = MQTTSession() //used to handle message events.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //initialize MQTT Client
        self.session?.delegate = self
        self.transport.host = MQTT_HOST
        self.transport.port = MQTT_PORT
        session?.transport = transport
        
        //updateUI(for: self.session?.status ?? .created)
        session?.connect() { error in
            print("connection completed with status \(String(describing: error))")
            if error != nil {
                self.updateUI(for: self.session?.status ?? .created)
            } else {
                self.updateUI(for: self.session?.status ?? .error)
            }
        }
    }
    
    func updateUI (for mqttStatus: MQTTSessionStatus) {
        DispatchQueue.main.async {
            if mqttStatus == .connected {
                self.mqttStatusLabel.text = "Connected"
                //print("hello")
            }
            else if mqttStatus == .connecting || mqttStatus == .created {
                self.mqttStatusLabel.text = "Connecting..."
            }
            else {
                self.mqttStatusLabel.text = "Connection Failed"
            }
        }
    }
    
    private func subscribe() {
        self.session?.subscribe(toTopic: "test/message", at: .exactlyOnce) { error, result in
            print("subscribe result error \(String(describing: error)) result \(result!)")
        }
    }
    
    private func publishMessage(_ message: String, onTopic topic: String) {
        session?.publishData(message.data(using: .utf8, allowLossyConversion: false), onTopic: topic, retain: false, qos: .exactlyOnce)
    }
    
    @IBAction func OnOffButtonPressed(_ sender: OnOffButton) {
        if sender.isSelected == true {
            sender.isSelected = false
            //sender.isEnabled = false
            publishMessage("off", onTopic: "test/message")
        } else {
            sender.isSelected = true
            //sender.isEnabled = true
            publishMessage("on", onTopic: "test/message")
        }
        
    }
    
    
}

extension ViewController: MQTTSessionManagerDelegate, MQTTSessionDelegate {
    
}


