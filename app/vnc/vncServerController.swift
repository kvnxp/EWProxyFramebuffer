//
//  vncServerController.swift
//  EWProxyframeBufferApp
//
//  Created by kvnxp on 17/07/22.
//

import Cocoa

class vncServerController: NSObject {
    @IBOutlet weak var StartVNCButton: NSButton!
    @IBOutlet weak var referenteMenssaje: NSTextField!
    override init(){}
    
    let vncExecutable = Bundle.main.bundlePath+"/Contents/Resources/OSXvnc-server";
    var argsVnc : [String:String] = [:];
    let proc = Process();
    
    @IBAction func startVnc(_ sender: Any) {
       
        let pipe = Pipe();
        let button : NSButton = sender as! NSButton;
        
        if ( proc.isRunning){
            proc.terminate();
            button.title = "Start VNC";
            return ;
        }
        
            proc.standardError = pipe;
            proc.standardOutput = pipe;
            proc.launchPath = self.vncExecutable;
            proc.standardInput = nil;
            proc.arguments = ["-rfbnoauth"];
        
        do{
           try proc.run();
            
            button.title="Stop VNC";
            
            
        }catch{
            print("error to run process");
        }
      
    }
   
}
