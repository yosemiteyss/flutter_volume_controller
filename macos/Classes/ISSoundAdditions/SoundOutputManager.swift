//
//  SoundOutputManager.swift
//
//
//  Created by Alessio Moiso on 08.03.22.
//
//  This file is forked and modified from ISSoundAdditions.
//  Source: `https://github.com/InerziaSoft/ISSoundAdditions`.

import CoreAudio
import AudioToolbox
import Cocoa

final class SoundOutputManager {
    
    static let shared: SoundOutputManager = SoundOutputManager()
    
    private init() {}
    
    private var onVolumeChanged: ((Float) -> Void)?
    private var onDefaultOutputDeviceChanged: ((OutputDevice) -> Void)?
    
    private let volumeChangeListener: AudioObjectPropertyListenerProc = { inObjectID, inNumberAddresses, inAddresses, inClientData in
        var size = UInt32(MemoryLayout<Float32>.size)
        var volume: Float = 0
        
        let error = AudioObjectGetPropertyData(inObjectID, inAddresses, 0, nil, &size, &volume)
        guard error == noErr else { return error }
        
        guard let selfPtr = inClientData else { return kAudio_ParamError }
        
        let manager: SoundOutputManager = bridge(ptr: selfPtr)
        let normalizedVolume = min(max(0, volume), 1)
        
        manager.onVolumeChanged?(normalizedVolume)
        
        return noErr
    }
    
    private let defaultOuputDeviceListener: AudioObjectPropertyListenerProc = { inObjectID, inNumberAddresses, inAddresses, inClientData in
        var size = UInt32(MemoryLayout<AudioDeviceID>.size)
        var deviceId = kAudioObjectUnknown
        
        let error = AudioObjectGetPropertyData(inObjectID, inAddresses, 0, nil, &size, &deviceId)
        guard error == noErr else { return error }
        
        guard let selfPtr = inClientData else { return kAudio_ParamError }
        
        let manager: SoundOutputManager = bridge(ptr: selfPtr)
        let deviceName = try? manager.retrieveOutputDeviceName(deviceId)
        let outputDevice = OutputDevice(id: String(deviceId), name: deviceName)
        
        manager.onDefaultOutputDeviceChanged?(outputDevice)
        
        return noErr
    }
    
    /// Get the system default output device.
    ///
    /// You can use this value to interact with the device directly
    /// via other system calls.
    ///
    /// - throws:
    /// `Errors.operationFailed` if the system fails to return the default output device.
    /// `Errors.noDevice` if no default output device can be found.
    ///
    /// - returns: the default device ID or `nil` if none is set.
    func retrieveDefaultOutputDeviceId() throws -> AudioDeviceID? {
        var size = UInt32(MemoryLayout<AudioDeviceID>.size)
        var id = kAudioObjectUnknown
        var address = PropertyAddress.defaultOutputDevice
        
        // Ensure that a default device exists.
        guard AudioObjectHasProperty(AudioObjectID(kAudioObjectSystemObject), &address) else { return nil }
        
        // Attempt to get the default output device.
        let error = AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &size, &id)
        guard error == noErr else {
            throw Errors.operationFailed(error)
        }
        
        if id == kAudioObjectUnknown {
            throw Errors.noDevice
        }
        
        return id
    }
    
    func retrieveDefaultOutputDevice() throws -> OutputDevice {
        guard let deviceID = try retrieveDefaultOutputDeviceId() else {
            throw Errors.noDevice
        }
        
        let deviceName = try retrieveOutputDeviceName(deviceID)
        return OutputDevice(id: String(deviceID), name: deviceName)
    }
    
    /// Set the system default output device.
    ///
    /// - throws:
    /// `Errors.unsupportedProperty` if the given device doesn't have a default output device property.
    /// `Errors.operationFailed` if setting default output device is failed.
    func setDefaultOutputDevice(_ deviceID: String) throws {
        guard var id = AudioDeviceID(deviceID) else {
            throw Errors.noDevice
        }
        
        let size = UInt32(MemoryLayout<AudioDeviceID>.size)
        var address = PropertyAddress.defaultOutputDevice
        
        guard AudioObjectHasProperty(AudioObjectID(kAudioObjectSystemObject), &address) else {
            throw Errors.unsupportedProperty
        }
        
        let error = AudioObjectSetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, size, &id)
        guard error == noErr else {
            throw Errors.operationFailed(error)
        }
    }
    
    /// Get a list of audio output devices.
    ///
    /// - returns: a list of audio device ids.
    func retrieveOutputDeviceList() throws -> [OutputDevice] {
        var size: UInt32 = 0
        var address = PropertyAddress.devices
        
        guard AudioObjectHasProperty(AudioObjectID(kAudioObjectSystemObject), &address) else {
            throw Errors.unsupportedProperty
        }
        
        // Get audio device list size.
        var error = AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &size)
        guard error == noErr else {
            throw Errors.operationFailed(error)
        }
        
        // Get the audio device list.
        let nDevices = Int(size) / MemoryLayout<AudioDeviceID>.size
        var deviceIDs = [AudioDeviceID](repeating: 0, count: nDevices)
        
        error = AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &size, &deviceIDs)
        guard error == noErr else {
            throw Errors.operationFailed(error)
        }
        
        // For each id, get the device name.
        let deviceList = try deviceIDs.map { id in
            let name = try retrieveOutputDeviceName(id)
            return OutputDevice(id: String(id), name: name)
        }
        
        return deviceList
    }
    
    func retrieveOutputDeviceName(_ deviceID: AudioDeviceID) throws -> String? {
        var size = UInt32(MemoryLayout<CFString>.size)
        var name: CFString = "" as CFString
        var address = PropertyAddress.deviceNameCFString
        
        guard AudioObjectHasProperty(deviceID, &address) else {
            throw Errors.unsupportedProperty
        }
        
        let error = AudioObjectGetPropertyData(deviceID, &address, 0, nil, &size, &name)
        guard error == noErr else {
            throw Errors.operationFailed(error)
        }
        
        return String(describing: name)
    }
    
    /// Get the volume of the system default output device.
    ///
    /// - throws:
    /// `Errors.noDevice` if the system doesn't have a default output device;
    /// `Errors.unsupportedProperty` if the current device doesn't have a volume property;
    /// `Errors.operationFailed` if the system is unable to read the property value.
    /// - returns: The current volume in a range between 0 and 1.
    func readVolume() throws -> Float {
        guard let deviceID = try retrieveDefaultOutputDeviceId() else {
            throw Errors.noDevice
        }
        
        var size = UInt32(MemoryLayout<Float32>.size)
        var volume: Float = 0
        var address = PropertyAddress.virtualMainVolume
        
        // Ensure the device has a volume property.
        guard AudioObjectHasProperty(deviceID, &address) else {
            throw Errors.unsupportedProperty
        }
        
        let error = AudioObjectGetPropertyData(deviceID, &address, 0, nil, &size, &volume)
        guard error == noErr else {
            throw Errors.operationFailed(error)
        }
        
        return min(max(0, volume), 1)
    }
    
    /// Set the volume of the system default output device.
    ///
    /// - parameter newValue: The volume to set in a range between 0 and 1.
    /// - throws:
    /// `Erors.noDevice` if the system doesn't have a default output device;
    /// `Errors.unsupportedProperty` or `Errors.immutableProperty` if the output device doesn't support setting or doesn't currently allow changes to its volume;
    /// `Errors.operationFailed` if the system is unable to apply the volume change.
    func setVolume(_ newValue: Float) throws {
        guard let deviceID = try retrieveDefaultOutputDeviceId() else {
            throw Errors.noDevice
        }
        
        var normalizedValue = min(max(0, newValue), 1)
        var address = PropertyAddress.virtualMainVolume
        
        // Ensure the device has a volume property.
        guard AudioObjectHasProperty(deviceID, &address) else {
            throw Errors.unsupportedProperty
        }
        
        var canChangeVolume = DarwinBoolean(true)
        let size = UInt32(MemoryLayout<Float>.size(ofValue: normalizedValue))
        let isSettableError = AudioObjectIsPropertySettable(deviceID, &address, &canChangeVolume)
        
        // Ensure the volume property is editable.
        guard isSettableError == noErr else {
            throw Errors.operationFailed(isSettableError)
        }
        
        guard canChangeVolume.boolValue else {
            throw Errors.immutableProperty
        }
        
        let error = AudioObjectSetPropertyData(deviceID, &address, 0, nil, size, &normalizedValue)
        
        if error != noErr {
            throw Errors.operationFailed(error)
        }
    }
    
    /// Get whether the system default output device is currently muted or not.
    ///
    /// - throws:
    /// `Errors.noDevice` if the system doesn't have a default output device;
    /// `Errors.unsupportedProperty` if the current device doesn't have a mute property;
    /// `Errors.operationFailed` if the system is unable to read the property value.
    /// - returns: Whether the device is muted or not.
    func readMute() throws -> Bool {
        guard let deviceID = try retrieveDefaultOutputDeviceId() else {
            throw Errors.noDevice
        }
        
        var isMuted: UInt32 = 0
        var size = UInt32(MemoryLayout<UInt32>.size(ofValue: isMuted))
        var address = PropertyAddress.mute
        
        // Ensure the device supports the option to be muted.
        guard AudioObjectHasProperty(deviceID, &address) else {
            throw Errors.unsupportedProperty
        }
        
        let error = AudioObjectGetPropertyData(deviceID, &address, 0, nil, &size, &isMuted)
        
        guard error == noErr else {
            throw Errors.operationFailed(error)
        }
        
        return isMuted == 1
    }
    
    /// Mute or unmute the system default output device.
    ///
    /// - parameter isMuted: Mute or unmute.
    /// - throws:
    /// `Errors.noDevice` if the system doesn't have a default output device;
    /// `Errors.unsupportedProperty` or `Errors.immutableProperty` if the output device doesn't
    /// support setting or doesn't currently allow changes to its mute property;
    /// `Errors.operationFailed` if the system is unable to apply the change.
    func mute(_ isMuted: Bool) throws {
        guard let deviceID = try retrieveDefaultOutputDeviceId() else {
            throw Errors.noDevice
        }
        
        var normalizedValue: UInt = isMuted ? 1 : 0
        var address = PropertyAddress.mute
        
        // Ensure the device supports the option to be muted.
        guard AudioObjectHasProperty(deviceID, &address) else {
            throw Errors.unsupportedProperty
        }
        
        var canMute = DarwinBoolean(true)
        let size = UInt32(MemoryLayout<UInt>.size(ofValue: normalizedValue))
        let isSettableError = AudioObjectIsPropertySettable(deviceID, &address, &canMute)
        
        // Ensure that the mute property is editable.
        guard isSettableError == noErr, canMute.boolValue else {
            throw Errors.immutableProperty
        }
        
        let error = AudioObjectSetPropertyData(deviceID, &address, 0, nil, size, &normalizedValue)
        
        if error != noErr {
            throw Errors.operationFailed(error)
        }
    }
    
    /// Attach a volume change listener.
    ///
    /// - parameter onChanged: the volume change callback.
    /// - throws:
    /// `Errors.noDevice` if the system doesn't have a default output device;
    /// `Errors.unsupportedProperty` if the output device doesn't support setting or doesn't currently allow changes to its volume property;
    /// `Errors.operationFailed` if the system is unable to apply the change.
    func addVolumeChangeListener(_ onChanged: @escaping (Float) -> Void) throws {
        guard let deviceID = try retrieveDefaultOutputDeviceId() else {
            throw Errors.noDevice
        }
        
        var address = PropertyAddress.virtualMainVolume
        
        guard AudioObjectHasProperty(deviceID, &address) else {
            throw Errors.unsupportedProperty
        }
        
        self.onVolumeChanged = onChanged
        
        let selfPtr = UnsafeMutableRawPointer(mutating: bridge(obj: self))
        let error = AudioObjectAddPropertyListener(deviceID, &address, volumeChangeListener, selfPtr)
        
        if error != noErr {
            throw Errors.operationFailed(error)
        }
    }
    
    /// Remove the volume change listener.
    ///
    /// - throws:
    /// `Errors.noDevice` if the system doesn't have a default output device;
    /// `Errors.unsupportedProperty` if the output device doesn't support setting or doesn't currently allow changes to its volume property;
    /// `Errors.operationFailed` if the system is unable to apply the change.
    func removeVolumeChangeListener() throws {
        guard let deviceID = try retrieveDefaultOutputDeviceId() else {
            throw Errors.noDevice
        }
        
        var address = PropertyAddress.virtualMainVolume
        
        // Ensure the device has a volume property.
        guard AudioObjectHasProperty(deviceID, &address) else {
            throw Errors.unsupportedProperty
        }
        
        self.onVolumeChanged = nil
        
        let selfPtr = UnsafeMutableRawPointer(mutating: bridge(obj: self))
        let error = AudioObjectRemovePropertyListener(deviceID, &address, volumeChangeListener, selfPtr)
        
        if error != noErr {
            throw Errors.operationFailed(error)
        }
    }
    
    func addDefaultOutputDeviceListener(_ onChanged: @escaping (OutputDevice) -> Void) throws {
        var address = PropertyAddress.defaultOutputDevice
        
        guard AudioObjectHasProperty(AudioObjectID(kAudioObjectSystemObject), &address) else {
            throw Errors.unsupportedProperty
        }
        
        self.onDefaultOutputDeviceChanged = onChanged
        
        let selfPtr = UnsafeMutableRawPointer(mutating: bridge(obj: self))
        let error = AudioObjectAddPropertyListener(AudioObjectID(kAudioObjectSystemObject), &address, defaultOuputDeviceListener, selfPtr)
        
        if error != noErr {
            throw Errors.operationFailed(error)
        }
    }
    
    func removeDefaultOutputDeviceListener() throws {
        var address = PropertyAddress.defaultOutputDevice
        
        guard AudioObjectHasProperty(AudioObjectID(kAudioObjectSystemObject), &address) else {
            throw Errors.unsupportedProperty
        }
        
        self.onDefaultOutputDeviceChanged = nil
        
        let selfPtr = UnsafeMutableRawPointer(mutating: bridge(obj: self))
        let error = AudioObjectRemovePropertyListener(AudioObjectID(kAudioObjectSystemObject), &address, defaultOuputDeviceListener, selfPtr)
        
        if error != noErr {
            throw Errors.operationFailed(error)
        }
    }
}
