// meeting-detect.swift — Check if microphone is in use or screen is being shared
// Queries CoreAudio for active input devices and CGWindowList for screen sharing indicators.
// Outputs "MIC_IN_USE" if either condition is true, "MIC_NOT_IN_USE" otherwise.
// Build: swiftc -O -o meeting-detect meeting-detect.swift -framework CoreAudio -framework CoreGraphics

import CoreAudio
import CoreGraphics
import Foundation

func isMicInUse() -> Bool {
    var propertySize: UInt32 = 0
    var propertyAddress = AudioObjectPropertyAddress(
        mSelector: kAudioHardwarePropertyDevices,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain
    )

    // Get the size of the device list
    var status = AudioObjectGetPropertyDataSize(
        AudioObjectID(kAudioObjectSystemObject),
        &propertyAddress,
        0, nil,
        &propertySize
    )
    guard status == noErr else { return false }

    let deviceCount = Int(propertySize) / MemoryLayout<AudioDeviceID>.size
    guard deviceCount > 0 else { return false }

    var deviceIDs = [AudioDeviceID](repeating: 0, count: deviceCount)
    status = AudioObjectGetPropertyData(
        AudioObjectID(kAudioObjectSystemObject),
        &propertyAddress,
        0, nil,
        &propertySize,
        &deviceIDs
    )
    guard status == noErr else { return false }

    for deviceID in deviceIDs {
        // Check if this device has input channels
        var inputAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyStreamConfiguration,
            mScope: kAudioDevicePropertyScopeInput,
            mElement: kAudioObjectPropertyElementMain
        )

        var bufferListSize: UInt32 = 0
        status = AudioObjectGetPropertyDataSize(deviceID, &inputAddress, 0, nil, &bufferListSize)
        guard status == noErr, bufferListSize > 0 else { continue }

        let bufferListPtr = UnsafeMutablePointer<AudioBufferList>.allocate(capacity: 1)
        defer { bufferListPtr.deallocate() }

        status = AudioObjectGetPropertyData(deviceID, &inputAddress, 0, nil, &bufferListSize, bufferListPtr)
        guard status == noErr else { continue }

        let bufferList = bufferListPtr.pointee
        var hasInputChannels = false
        let bufferCount = Int(bufferList.mNumberBuffers)
        if bufferCount > 0 {
            // Check first buffer for channels
            if bufferList.mBuffers.mNumberChannels > 0 {
                hasInputChannels = true
            }
        }

        guard hasInputChannels else { continue }

        // Check if this input device is running (mic in use)
        var isRunning: UInt32 = 0
        var runningSize = UInt32(MemoryLayout<UInt32>.size)
        var runningAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyDeviceIsRunningSomewhere,
            mScope: kAudioDevicePropertyScopeInput,
            mElement: kAudioObjectPropertyElementMain
        )

        status = AudioObjectGetPropertyData(deviceID, &runningAddress, 0, nil, &runningSize, &isRunning)
        if status == noErr && isRunning != 0 {
            return true
        }
    }

    return false
}

func isScreenShared() -> Bool {
    // Check for the macOS screen sharing/recording indicator window.
    // When any app captures the screen, macOS shows a status bar item
    // owned by "controlcenter" with the screen recording indicator.
    // We detect this by looking for active screen capture via CGDisplayStream
    // or by checking for known screen-sharing processes.

    // Method: Check if any process is actively screen-capturing by looking
    // for the "StatusIndicator" window that macOS creates during screen sharing.
    guard let windowList = CGWindowListCopyWindowInfo(
        [.optionOnScreenOnly, .excludeDesktopElements],
        kCGNullWindowID
    ) as? [[String: Any]] else {
        return false
    }

    for window in windowList {
        let ownerName = window[kCGWindowOwnerName as String] as? String ?? ""
        let windowName = window[kCGWindowName as String] as? String ?? ""

        // macOS shows a "StatusIndicator" window from controlcenter when screen is shared
        if ownerName == "controlcenter" && windowName == "StatusIndicator" {
            return true
        }
    }

    return false
}

let mic = isMicInUse()
let screen = isScreenShared()

if screen {
    print("SCREEN_SHARED")
} else if mic {
    print("MIC_IN_USE")
} else {
    print("MIC_NOT_IN_USE")
}
