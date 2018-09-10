//
//  GoProCommandController.swift
//  dorsaViGoPro
//
//  Created by dorsaVi Hardware on 9/9/18.
//  Copyright © 2018 dorsaVi Hardware. All rights reserved.
//

import UIKit

class GoProCommandController {
    static let controller = GoProCommandController()
    private init(){
    }
    
    // Video Mode
    func GoProViedoMode(on: Bool) -> String
    {
        return "http://10.5.5.9/gp/gpControl/setting/10/" + (on ? "0" : "1")
    }
    // Photo Mode
    func GoProPhotoMode(on: Bool) -> String
    {
        return "http://10.5.5.9/gp/gpControl/setting/21/" + (on ? "0" : "1")
    }
    // Multishot Mode
    func GoProMultishotMode(on: Bool) -> String
    {
        return "http://10.5.5.9/gp/gpControl/setting/34/" + (on ? "0" : "1")
    }
    // Viedo White Balance
    func GoProVideoWhiteBalance(value: String) -> String
    {
        let valueTemp = value.lowercased()
        var command = "http://10.5.5.9/gp/gpControl/setting/11/"
        switch valueTemp
        {
            case "auto":
                command += "0"
            case "3000k":
                command += "1"
            case "4000k":
                command += "5"
            case "4800k":
                command += "6"
            case "5500k":
                command += "2"
            case "6000k":
                command += "7"
            case "6500k":
                command += "3"
            case "native":
                command += "4"
            default:
                command = "Invalid Value!"
        }
        return command
    }
    // Photo White Balance
    func GoProPhotoWhiteBalance(value: String) -> String
    {
        let valueTemp = value.lowercased()
        var command = "http://10.5.5.9/gp/gpControl/setting/22/"
        switch (valueTemp)
        {
            case "auto":
                command += "0"
            case "3000k":
                command += "1"
            case "4000k":
                command += "5"
            case "4800k":
                command += "6"
            case "5500k":
                command += "2"
            case "6000k":
                command += "7"
            case "6500k":
                command += "3"
            case "native":
                command += "4"
            default:
                command = "Invalid Value!"
        }
        return command
    }
    // Multishot White Balance
    func GoProMultiShotWhiteBalance(value: String) -> String
    {
        let valueTemp = value.lowercased()
        var command = "http://10.5.5.9/gp/gpControl/setting/35/"
        switch (valueTemp)
        {
            case "auto":
                command += "0"
            case "3000k":
                command += "1"
            case "4000k":
                command += "5"
            case "4800k":
                command += "6"
            case "5500k":
                command += "2"
            case "6000k":
                command += "7"
            case "6500k":
                command += "3"
            case "native":
                command += "4"
            default:
                command = "Invalid Value!"
        }
        return command
    }
    // Vedio Color
    func GoProVideoColor(useGroProColor: Bool) -> String
    {
        return "http://10.5.5.9/gp/gpControl/setting/12/" + (useGroProColor ? "0" : "1")
    }
    // Photo Color
    func GoProPhotoColor(useGroProColor: Bool) -> String
    {
        return "http://10.5.5.9/gp/gpControl/setting/23/" + (useGroProColor ? "0" : "1")
    }
    // Multishot Color
    func GoProMultishotColor(useGroProColor: Bool) -> String
    {
        return "http://10.5.5.9/gp/gpControl/setting/36/" + (useGroProColor ? "0" : "1")
    }
    // Video ISO Limit
    func GoProVideoISO(ISO: Int) -> String
    {
        var command = "http://10.5.5.9/gp/gpControl/setting/13/"
        switch (ISO)
        {
            case 6400:
                command += "0"
            case 1600:
                command += "1"
            case 400:
                command += "2"
            case 3200:
                command += "3"
            case 800:
                command += "4"
            case 200:
                command += "7"
            case 100:
                command += "8"
            default:
                command = "Invalid Value!"
        }
        return command
    }
    // Photo ISO Limit
    func GoProPhotoISO(ISO: Int) -> String
    {
        var command = "http://10.5.5.9/gp/gpControl/setting/24/"
        switch (ISO)
        {
            case 800:
                command += "0"
            case 400:
                command += "1"
            case 200:
                command += "2"
            case 100:
                command += "3"
            default:
                command = "Invalid Value!"
        }
        return command
    }
    // MultiShot ISO Limit
    func GoProMultiShotISO(ISO: Int) -> String
    {
        var command = "http://10.5.5.9/gp/gpControl/setting/37/"
        switch (ISO)
        {
            case 800:
                command += "0"
            case 400:
                command += "1"
            case 200:
                command += "2"
            case 100:
                command += "3"
            default:
                command = "Invalid Value!"
        }
        return command
    }
    // Video ISO Mode
    func GoProVideoISOMode(max: Bool) -> String
    {
        return "http://10.5.5.9/gp/gpControl/setting/74/" + (max ? "0" : "1")
    }
    // Photo ISO Min
    func GoProPhotoISOMin(ISO: Int) -> String
    {
        var command = "http://10.5.5.9/gp/gpControl/setting/75/"
        switch (ISO)
        {
            case 800:
                command += "0"
            case 400:
                command += "1"
            case 200:
                command += "2"
            case 100:
                command += "3"
            default:
                command = "Invalid Value!"
        }
        return command
    }
    // MultiShot ISO Min
    func GoProMultiShotISOMin(ISO: Int) -> String
    {
        var command = "http://10.5.5.9/gp/gpControl/setting/76/"
        switch (ISO)
        {
            case 800:
                command += "0"
            case 400:
                command += "1"
            case 200:
                command += "2"
            case 100:
                command += "3"
            default:
                command = "Invalid Value!"
        }
        return command
    }
    // Video Sharpness
    func GoProVideoSharpness(sharpness: String) -> String
    {
        let sharpnessTemp = sharpness.lowercased()
        var command = "http://10.5.5.9/gp/gpControl/setting/14"
        switch (sharpnessTemp)
        {
            case "high":
                command += "0"
            case "med":
                command += "1"
            case "low":
                command += "2"
            default:
                command = "Invalid Value!"
        }
        return command
    }
    // Photo Sharpness
    func GoProPhotoSharpness(sharpness: String) -> String
    {
        let sharpnessTemp = sharpness.lowercased()
        var command = "http://10.5.5.9/gp/gpControl/setting/25"
        switch (sharpnessTemp)
        {
            case "high":
                command += "0"
            case "med":
                command += "1"
            case "low":
                command += "2"
            default:
                command = "Invalid Value!"
        }
        return command
    }
    // Video Sharpness
    func GoProMultiShotSharpness(sharpness: String) -> String
    {
        let sharpnessTemp = sharpness.lowercased()
        var command = "http://10.5.5.9/gp/gpControl/setting/38"
        switch (sharpnessTemp)
        {
            case "high":
                command += "0"
            case "med":
                command += "1"
            case "low":
                command += "2"
            default:
                command = "Invalid Value!"
        }
        return command
    }
    // Video Exposure Auto Mode
    func GoProVideoManualExposureAutoMode() -> String
    {
        return "http://10.5.5.9/gp/gpControl/setting/73/0"
    }
    // Video Manual Exposure
    func GoProVideoManualExposure(fps: Int, evc: String) -> String
    {
        var command = "http://10.5.5.9/gp/gpControl/setting/73/"
        let fpsevc = String(fps) + ":evc"
        switch (fpsevc)
        {
            case "24:1/24":
                command += "3"
            case "24:1/48":
                command += "6"
            case "24:1/96":
                command += "11"
            case "30:1/30":
                command += "5"
            case "30:1/60":
                command += "8"
            case "30:1/120":
                command += "13"
            case "48:1/48":
                command += "6"
            case "48:1/96":
                command += "11"
            case "48:1/192":
                command += "16"
            case "60:1/60":
                command += "8"
            case "60:1/120":
                command += "13"
            case "60:1/240":
                command += "18"
            case "90:1/90":
                command += "10"
            case "90:1/180":
                command += "15"
            case "90:1/360":
                command += "20"
            case "120:1/120":
                command += "13"
            case "120:1/240":
                command += "18"
            case "120:1/480":
                command += "22"
            case "240:1/120":
                command += "18"
            case "240:1/240":
                command += "22"
            case "240:1/480":
                command += "23"
            default:
                command = "Invalid Value!"
        }
        return command
    }
    // Video EV compensation (enabled ONLY in Auto mode)
    func GoProVideoEVCompensation(value: Double) -> String
    {
        var command = "http://10.5.5.9/gp/gpControl/setting/15/"
        switch (value)
        {
            case 2:
                command += "0"
            case 1.5:
                command += "1"
            case 1:
                command += "2"
            case 0.5:
                command += "3"
            case 0:
                command += "4"
            case -0.5:
                command += "5"
            case -1:
                command += "6"
            case -1.5:
                command += "7"
            case -2:
                command += "8"
            default:
                command = "Invalid Value!"
        }
        return command
    }
    // Photo EV compensation (enabled ONLY in Auto mode)
    func GoProPhotoEVCompensation(value: Double) -> String
    {
        var command = "http://10.5.5.9/gp/gpControl/setting/26/"
        switch (value)
        {
            case 2:
                command += "0"
            case 1.5:
                command += "1"
            case 1:
                command += "2"
            case 0.5:
                command += "3"
            case 0:
                command += "4"
            case -0.5:
                command += "5"
            case -1:
                command += "6"
            case -1.5:
                command += "7"
            case -2:
                command += "8"
            default:
                command = "Invalid Value!"
            }
            return command
        }
    // MultiShot EV compensation (enabled ONLY in Auto mode)
    func GoProMultiShotEVCompensation(value: Double) -> String
    {
        var command = "http://10.5.5.9/gp/gpControl/setting/39/"
        switch (value)
        {
            case 2:
                command += "0"
            case 1.5:
                command += "1"
            case 1:
                command += "2"
            case 0.5:
                command += "3"
            case 0:
                command += "4"
            case -0.5:
                command += "5"
            case -1:
                command += "6"
            case -1.5:
                command += "7"
            case -2:
                command += "8"
            default:
                command = "Invalid Value!"
        }
        return command
    }
    // Default Boot Mode
    func GoProDefaultBootMode(mode: String) -> String
    {
        var command = "http://10.5.5.9/gp/gpControl/setting/53/"
        let modeTemp = mode.lowercased()
        switch (modeTemp)
        {
            case "video":
                command += "0"
            case "photo":
                command += "1"
            case "multishot":
                command += "2"
            default:
                command = "Invalid Value!"
        }
        return command
    }
    // Primary Mode
    func GoProPrimaryMode(mode: String) -> String
    {
        var command = "http://10.5.5.9/gp/gpControl/command/mode?p="
        let modeTemp = mode.lowercased()
        switch (modeTemp)
        {
            case "video":
                command += "0"
            case "photo":
                command += "1"
            case "multishot":
                command += "2"
            default:
                command = "Invalid Value!"
        }
        return command
    }
    // Secondary Mode
    func GoProSecondaryMode(mode: String) -> String
    {
        var command = " http://10.5.5.9/gp/gpControl/command/sub_mode?mode="
        let modeTemp = mode.lowercased()
        switch (modeTemp)
        {
            case "video":
                command += "0&sub_mode=0"
            case "timelapse_video":
                command += "0&sub_mode=1"
            case "video+photo":
                command += "0&sub_mode=2"
            case "looping":
                command += "0&sub_mode=3"
            case "single":
                command += "1&sub_mode=0"
            case "continuous":
                command += "1&sub_mode=1"
            case "night":
                command += "1&sub_mode=2"
            case "burst":
                command += "2&sub_mode=0"
            case "timelapse_multishot":
                command += "2&sub_mode=1"
            case "nightlapse":
                command += "2&sub_mode=2"
            default:
                command = "Invalid Value!"
        }
        return command
    }
    // Power Off (Sleep)
    func GoProSleep() -> String
    {
        return "http://10.5.5.9/gp/gpControl/command/system/sleep"
    }
    // Set GoPro WiFi SSID
    func GoProSetWiFiName(name: String) -> String
    {
        return "http://10.5.5.9/gp/gpControl/command/wireless/ap/ssid?ssid=" + name
    }
    // Change GroPro WiFi SSID and password
    func GoProSetWiFiSSIDPassword(ssid: String, password: String) -> String
    {
        return "http://10.5.5.9/gp/gpControl/command/wireless/ap/ssid?ssid=" + ssid + "&pw=" + password
    }
    // Shutter
    func GoProShutter(trigger: Bool) -> String
    {
        return "http://10.5.5.9/gp/gpControl/command/shutter?p=" + (trigger ? String(1) : String(0))
    }
    // Streaming BitRate (Supports any number ( like 7000000), but limited by wifi throughput, packet loss and video glitches may appear)
    func GoProStreamBitRate(bitRate: Int) -> String
    {
        // in bps unit
        return "http://10.5.5.9/gp/gpControl/setting/62/" + String(bitRate)
    }
    // Streaming Window size
    func GoProStreamWindowSize(windowSize: String) -> String
    {
        var command = "http://10.5.5.9/gp/gpControl/setting/64/"
        let windowSizeTemp = windowSize.lowercased()
        switch (windowSizeTemp)
        {
            case "default":
                command += "0"
            case "240":
                command += "1"
            case "240,3:4":
                command += "2"
            case "240,1:2":
                command += "3"
            case "480":
                command += "4"
            case "480,3:4":
                command += "5"
            case "480,1:2":
                command += "6"
            case "720":
                command += "7"
            case "720,3:4":
                command += "8"
            case "720,1:2":
                command += "9"
            default:
                command = "Invalid Value!"
        }
    return command
    }
    // Start Streaming
    func GoProStartStreaming() -> String
    {
        return "http://10.5.5.9/gp/gpControl/execute?p1=gpStream&a1=proto_v2&c1=restart"
    }
    // GoPro UDP address
    func GoProUDPAddress() -> String
    {
        return "udp://10.5.5.100:8554"
    }
    // Turn off Wi-Fi
    func GoProTurnOffWiFi() -> String
    {
        return "http://10.5.5.9/gp/gpControl/setting/63/0"
    }
    // WiFi mode
    func GoProSwitchWiFiMode(mode: String) -> String
    {
        var command = "http://10.5.5.9/gp/gpControl/setting/63/"
        let modeTemp = mode.lowercased()
        switch (modeTemp)
        {
        case "off":
            command += "0"
        case "app",
             "smartphone":
            command += "1"
        case "rc":
            command += "2"
        case "smartremoterc":
            command += "4"
        default:
            command = "Invalid Value!"
        }
        return command
    }
    // Locate
    func GoProSwitchLocate(on: Bool) -> String
    {
        return "http://10.5.5.9/gp/gpControl/command/system/locate?p=" + (on ? "1" : "0")
    }
    // Media List
    func GoProGetMediaList() -> String
    {
        return "http://10.5.5.9:8080/gp/gpMediaList"
    }

}
