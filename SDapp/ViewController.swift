//
//  ViewController.swift
//  SDapp
//
//  Created by Hee Suk Yoon on 2021/02/05.
//

import UIKit
import MQTTClient
//import CocoaMQTT
import DropDown


struct DeviceStruct {
    var name : String?
    var state : Bool?
}

var DeviceIndex = -1
var DeviceList: [DeviceStruct] = [DeviceStruct(name:"Default", state: false)]
//var DeviceList: [DeviceStruct] = []
var volume = 3
var DeviceName: [String] = []
/*
class DeviceList {
    let streets = ["Albemarle", "Brandywine", "Chesapeake"]
}
*/

//The On/Off button class
class OnOffButton: UIButton {
    /*
    override var isSelected: Bool {
        didSet {
            self.backgroundColor = isSelected ? .blue : .clear
            //self.setTitle("my text here", for: .normal)
            //self.setTitle("my text here2", for: .highlighted)
            
        }
    }
   */


    override func awakeFromNib() {
        self.layer.cornerRadius = self.bounds.width * 0.5
        self.layer.masksToBounds = true
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.blue.cgColor
    }
}
class DropDownMenu: UIButton {
    
}
class ViewController: UIViewController {

    //let deviceList = DeviceList()
    let MQTT_HOST = "192.168.137.174" // IP address of the device where MQTT broker is setup.
    let MQTT_PORT: UInt32 = 1883 // Port number of the MQTT broker/
    let dropDown = DropDown()

    //@IBOutlet private weak var button: OnOffButton!
    //@IBOutlet private weak var mqttStatusLabel: UILabel!
    @IBOutlet weak var button: OnOffButton!
    @IBOutlet weak var mqttStatusLabel: UILabel!
    @IBOutlet weak var selectDevices: DropDownMenu!
    @IBOutlet weak var clickVolumeup: UIButton!
    @IBOutlet weak var clickVolumeDown: UIButton!
    @IBOutlet weak var volumeLevel: UILabel!
    
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
        //session?.subscribe(toTopic: "test/message", at: .atMostOnce)
        
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
        session?.subscribe(toTopic: "newDevice", at: .atMostOnce)
    }
    
    /*
    private func subscribe() {
        self.session?.subscribe(toTopic: "test/message", at: .exactlyOnce) { error, result in
            print("subscribe result error \(String(describing: error)) result \(result!)")
        }
        print("hehehehe")
    }
    */
    
    private func publishMessage(_ message: String, onTopic topic: String) {
        session?.publishData(message.data(using: .utf8, allowLossyConversion: false), onTopic: topic, retain: false, qos: .exactlyOnce)
    }
    
    func newMessage(_ session: MQTTSession!, data: Data!, onTopic topic: String!, qos: MQTTQosLevel, retained: Bool, mid: UInt32) {
        //text.append("\n topic - \(topic!) data - \(data!)")
        let str = String(decoding: data, as: UTF8.self)
        //var temp = DeviceStruct(Dname: str, Dstate: false)
        var DeviceNameTemp: [String] = []
        for i in DeviceList {
            DeviceNameTemp.append(i.name!)
        }
        if !DeviceNameTemp.contains(str) {
            DeviceList.append(DeviceStruct(name:str, state: false))
        }
        //DeviceName.append(str)
        //print(str)
    }
    
    @IBAction func OnOffButtonPressed(_ sender: OnOffButton) {
        
        if DeviceIndex != -1 {
            if DeviceList[DeviceIndex].state == true {
                sender.backgroundColor = .clear
                DeviceList[DeviceIndex].state = false
                sender.setTitle("OFF", for: .normal)
                publishMessage("off", onTopic: "test/message")
            } else {
                sender.backgroundColor = .blue
                DeviceList[DeviceIndex].state = true
                publishMessage("on", onTopic: "test/message")
                sender.setTitle("ON", for: .normal)
            }
            sender.isSelected.toggle()
        }
    }

    
    @IBAction func DropDownMenu(_ sender: DropDownMenu) {
        DeviceName = []
        for i in DeviceList {
            DeviceName.append(i.name!)
        }

        //dropDown.dataSource = ["LightFixture1", "LightFixture2", "LightFixture3", "LightFixture4", "LightFixture5"]
        dropDown.dataSource = DeviceName
        //dropDown.dataSource = deviceList.streets
        dropDown.anchorView = view
        dropDown.bottomOffset = CGPoint(x: 0, y: sender.frame.size.height) //6
        dropDown.show()
        // Action triggered on selection
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            sender.setTitle(item, for: .normal) //9
            DeviceIndex = index
            if DeviceList[DeviceIndex].state == false {
                button.setTitle("OFF", for: .normal)
                button.backgroundColor = .clear
            } else {
                button.setTitle("ON", for: .normal)
                button.backgroundColor = .blue
            }
            
            //print(index)
            
            
        }
    }
    
    
    @IBAction func volumeUp(_ sender: Any) {
        publishMessage("volumeUp", onTopic: "test/message")
        volume = volume+1
        self.volumeLevel.text = "volume: \(volume) dB"
    }
    
    
    @IBAction func volumeDown(_ sender: Any) {
        publishMessage("volumeDown", onTopic: "test/message")
        volume = volume-1
        self.volumeLevel.text = "volume: \(volume) dB"
    }
    
    
    
    
    
}

extension ViewController: MQTTSessionManagerDelegate, MQTTSessionDelegate {
    
}


