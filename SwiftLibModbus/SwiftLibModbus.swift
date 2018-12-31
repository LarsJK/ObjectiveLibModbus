//
//  SwiftLibModbus.swift
//  SwiftLibModbus
//
//  Ported to Swift by Kei Sakaguchi on 2/22/16. It's a bit weird that the project was started on the same date 4 years ago...
//  Created by Lars-Jørgen Kristiansen on 22.02.12.
//  Copyright © 2012 __MyCompanyName__. All rights reserved.
//

import Foundation

enum FunctionType {
    case kInputBits
    case kBits
    case kInputRegisters
    case kRegisters
}

class SwiftLibModbus: NSObject {
    
    var mb: OpaquePointer?
    var modbusQueue: DispatchQueue?
    var ipAddress: NSString?
    
    init(ipAddress: NSString, port: Int32, device: Int32) {
        super.init()
        modbusQueue = DispatchQueue(label: "com.iModbus.modbusQueue", attributes: .concurrent)
        let _ = self.setupTCP(ipAddress: ipAddress, port: port, device: device)
    }
    
    func setupTCP(ipAddress: NSString, port: Int32, device: Int32) -> Bool {
        self.ipAddress = ipAddress
        mb = modbus_new_tcp(ipAddress.cString(using: String.Encoding.ascii.rawValue) , port)
        var modbusErrorRecoveryMode = modbus_error_recovery_mode(0)
        modbusErrorRecoveryMode = modbus_error_recovery_mode(rawValue: MODBUS_ERROR_RECOVERY_LINK.rawValue | MODBUS_ERROR_RECOVERY_PROTOCOL.rawValue)
        modbus_set_error_recovery(mb!, modbusErrorRecoveryMode)
        modbus_set_slave(mb!, device)
        return true
    }
    
    func connectWithError(_ error: NSError) -> Bool {
        let ret = modbus_connect(mb!)
        if ret == -1 {
            var error = error
            error = self.buildNSError(errno: errno)
            return false
        }
        return true
    }
    
    func connect(success: @escaping () -> Void, failure: @escaping (NSError) -> Void) {
        modbusQueue?.async {
            let ret = modbus_connect(self.mb!)
            if ret == -1 {
                let error = self.buildNSError(errno: errno)
                DispatchQueue.main.async {
                    failure(error)
                }
            } else {
                DispatchQueue.main.async {
                    success()
                }
            }
        }
    }
    
    func disconnect() {
        modbus_close(mb!)
    }
    
    func writeType(type: FunctionType, address: Int32, value: Int32, success: @escaping () -> Void, failure: @escaping (NSError) -> Void) {
        if type == .kBits {
            let status = value != 0
            self.writeBit(address: address, status: status,
                          success: { () -> Void in
                            success()
            },
                          failure: { (error: NSError) -> Void in
                            failure(error)
            })
        }
        else if type == .kRegisters {
            self.writeRegister(address: address, value: value,
                               success: { () -> Void in
                                success()
            },
                               failure: { (error: NSError) -> Void in
                                failure(error)
            })
        }
        else {
            let error = self.buildNSError(errno: errno, errorString: "Could not write. Function type is read only")
            failure(error)
        }
    }
    
    func readType(type: FunctionType, startAddress: Int32, count: Int32, success: @escaping ([AnyObject]) -> Void, failure: @escaping (NSError) -> Void) {
        if type == .kInputBits {
            self.readInputBitsFrom(startAddress: startAddress, count: count,
                                   success: { (array: [AnyObject]) -> Void in
                                    success(array)
            },
                                   failure: { (error: NSError) -> Void in
                                    failure(error)
            })
        }
        else if type == .kBits {
            self.readBitsFrom(startAddress: startAddress, count: count,
                              success: { (array: [AnyObject]) -> Void in
                                success(array)
            },
                              failure: { (error: NSError) -> Void in
                                failure(error)
            })
        }
        else if type == .kInputRegisters {
            self.readInputRegistersFrom(startAddress: startAddress, count: count,
                                        success: { (array: [AnyObject]) -> Void in
                                            success(array)
            },
                                        failure: { (error: NSError) -> Void in
                                            failure(error)
            })
        }
        else if type == .kRegisters {
            self.readRegistersFrom(startAddress: startAddress, count: count,
                                   success: { (array: [AnyObject]) -> Void in
                                    success(array)
            },
                                   failure: { (error: NSError) -> Void in
                                    failure(error)
            })
        }
    }
    
    func writeBit(address: Int32, status: Bool, success: @escaping () -> Void, failure: @escaping (NSError) -> Void) {
        modbusQueue?.async {
            if modbus_write_bit(self.mb!, address, status ? 1 : 0) >= 0 {
                DispatchQueue.main.async {
                    success()
                }
            } else {
                let error = self.buildNSError(errno: errno)
                DispatchQueue.main.async {
                    failure(error)
                }
            }
        }
    }
    
    func writeRegister(address: Int32, value: Int32, success: @escaping () -> Void, failure: @escaping (NSError) -> Void) {
        modbusQueue?.async {
            if modbus_write_register(self.mb!, address, value) >= 0 {
                DispatchQueue.main.async {
                    success()
                }
            } else {
                let error = self.buildNSError(errno: errno)
                DispatchQueue.main.async {
                    failure(error)
                }
            }
        }
    }
    
    func readBitsFrom(startAddress: Int32, count: Int32, success: @escaping ([AnyObject]) -> Void, failure: @escaping (NSError) -> Void) {
        modbusQueue?.async {
            let tab_reg: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(count))
            if modbus_read_bits(self.mb!, startAddress, count, tab_reg) >= 0 {
                let returnArray: NSMutableArray = NSMutableArray(capacity: Int(count))
                for i in 0..<Int(count) {
                    returnArray.add(Int(tab_reg[i]))
                }
                DispatchQueue.main.async {
                    success(returnArray as [AnyObject])
                }
            } else {
                let error = self.buildNSError(errno: errno)
                DispatchQueue.main.async {
                    failure(error)
                }
            }
        }
    }
    
    func readInputBitsFrom(startAddress: Int32, count: Int32, success: @escaping ([AnyObject]) -> Void, failure: @escaping (NSError) -> Void) {
        modbusQueue?.async {
            let tab_reg: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(count))
            if modbus_read_input_bits(self.mb!, startAddress, count, tab_reg) >= 0 {
                let returnArray: NSMutableArray = NSMutableArray(capacity: Int(count))
                for i in 0..<Int(count) {
                    returnArray.add(Int(tab_reg[i]))
                }
                DispatchQueue.main.async {
                    success(returnArray as [AnyObject])
                }
            } else {
                let error = self.buildNSError(errno: errno)
                DispatchQueue.main.async {
                    failure(error)
                }
            }
        }
    }
    
    
    func readRegistersFrom(startAddress: Int32, count: Int32, success: @escaping ([AnyObject]) -> Void, failure: @escaping (NSError) -> Void) {
        modbusQueue?.async {
            let tab_reg: UnsafeMutablePointer<UInt16> = UnsafeMutablePointer<UInt16>.allocate(capacity: Int(count))
            if modbus_read_registers(self.mb!, startAddress, count, tab_reg) >= 0 {
                let returnArray: NSMutableArray = NSMutableArray(capacity: Int(count))
                for i in 0..<Int(count) {
                    returnArray.add(Int(tab_reg[i]))
                }
                DispatchQueue.main.async {
                    success(returnArray as [AnyObject])
                }
            }
            else {
                let error = self.buildNSError(errno: errno)
                DispatchQueue.main.async {
                    failure(error)
                }
            }
        }
    }
    
    func readInputRegistersFrom(startAddress: Int32, count: Int32, success: @escaping ([AnyObject]) -> Void, failure: @escaping (NSError) -> Void) {
        modbusQueue?.async {
            let tab_reg: UnsafeMutablePointer<UInt16> = UnsafeMutablePointer<UInt16>.allocate(capacity: Int(count))
            if modbus_read_input_registers(self.mb!, startAddress, count, tab_reg) >= 0 {
                let returnArray: NSMutableArray = NSMutableArray(capacity: Int(count))
                for i in 0..<Int(count) {
                    returnArray.add(Int(tab_reg[i]))
                }
                DispatchQueue.main.async {
                    success(returnArray as [AnyObject])
                }
            } else {
                let error = self.buildNSError(errno: errno)
                DispatchQueue.main.async {
                    failure(error)
                }
            }
        }
    }
    
    func writeRegistersFromAndOn(address: Int32, numberArray: NSArray, success: @escaping () -> Void, failure: @escaping (NSError) -> Void) {
        modbusQueue?.async {
            let valueArray: UnsafeMutablePointer<UInt16> = UnsafeMutablePointer<UInt16>.allocate(capacity: numberArray.count)
            for i in 0..<numberArray.count {
                valueArray[i] = UInt16(numberArray[i] as! Int)
            }
            
            if modbus_write_registers(self.mb!, address, Int32(numberArray.count), valueArray) >= 0 {
                DispatchQueue.main.async {
                    success()
                }
            } else {
                let error = self.buildNSError(errno: errno)
                DispatchQueue.main.async {
                    failure(error)
                }
            }
        }
    }
    
    private func buildNSError(errno: Int32, errorString: NSString) -> NSError {
        var details: [String: Any] = [:]
        details[NSLocalizedDescriptionKey] = errorString
        let error = NSError(domain: "Modbus", code: Int(errno), userInfo: details)
        return error
    }
    
    private func buildNSError(errno: Int32) -> NSError {
        let errorString = NSString(utf8String: modbus_strerror(errno))
        return self.buildNSError(errno: errno, errorString: errorString!)
    }
    
    deinit {
        // dispatch_release(modbusQueue);
        modbus_free(mb!);
    }
}
