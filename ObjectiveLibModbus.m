//
//  ObjectiveLibModbus.m
//  LibModbusTest
//
//  Created by Lars-Jørgen Kristiansen on 22.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

//#define modbusQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

#import "ObjectiveLibModbus.h"

@implementation ObjectiveLibModbus
@synthesize ipAddress=_ipAddress;

- (id) initWithTCP: (NSString *)ipAddress port: (int)port device:(int)device {
    self = [self init];
    
    if (self != nil)
    {
        // your code here
        modbusQueue = dispatch_queue_create("com.iModbus.modbusQueue", NULL);
        if ([self setupTCP:ipAddress port:port device:device])
            return self;
    }
    
    return NULL;
}

- (BOOL)setupTCP: (NSString *)ipAddress port: (int)port device:(int)device
{
	_ipAddress= ipAddress;
    mb = modbus_new_tcp([ipAddress cStringUsingEncoding: NSASCIIStringEncoding], port);
    modbus_set_error_recovery(mb,MODBUS_ERROR_RECOVERY_LINK | MODBUS_ERROR_RECOVERY_PROTOCOL);
    modbus_set_slave(mb, device);
	return YES;
}

- (BOOL) connectWithError:(NSError**)error {
    int ret = modbus_connect(mb);
    if (ret == -1) {
        NSString *errorString = [NSString stringWithUTF8String:modbus_strerror(errno)];
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:errorString forKey:NSLocalizedDescriptionKey];
        // populate the error object with the details
        *error = [NSError errorWithDomain:@"Modbus" code:errno userInfo:details];
        return NO;
    }
    return YES;
}

- (void) connect:(void (^)())success failure:(void (^)(NSError *error))failure {
    dispatch_async(modbusQueue, ^{
        int ret = modbus_connect(mb);
        if (ret == -1) {
            NSString *errorString = [NSString stringWithUTF8String:modbus_strerror(errno)];
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:errorString forKey:NSLocalizedDescriptionKey];
            // populate the error object with the details
            NSError *error = [NSError errorWithDomain:@"Modbus" code:errno userInfo:details];
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                success();
            });
        }
    });
}

- (void) disconnect {
    modbus_close(mb);
}

- (void) writeType:(functionType)type address:(int)address to:(int)value success:(void (^)())success failure:(void (^)(NSError *error))failure {
    if (type == kBits) {
        [self writeBit:address to:value success:^{
            success();
        } failure:^(NSError *error) {
            failure(error);
        }];
    }
    else if (type == kRegisters) {
        [self writeRegister:address to:value success:^{
            success();
        } failure:^(NSError *error) {
            failure(error);
        }];
    }
    else {
        NSString *errorString = @"Could not write. Function type is read only";
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:errorString forKey:NSLocalizedDescriptionKey];
        // populate the error object with the details
        NSError *error = [NSError errorWithDomain:@"Modbus" code:errno userInfo:details];
        failure(error);
    }
}

-(void)readType:(functionType)type startAddress:(int)address count:(int)count success:(void (^)(NSArray *array))success failure:(void (^)(NSError *error))failure {
    if (type == kInputBits) {
        [self readInputBitsFrom:address count:count success:^(NSArray *array) {
            success(array);
        } failure:^(NSError *error) {
            failure(error);
        }];
    }
    else if (type == kBits) {
        [self readBitsFrom:address count:count success:^(NSArray *array) {
            success(array);
        } failure:^(NSError *error) {
            failure(error);
        }];
    }
    else if (type == kInputRegisters) {
        [self readInputRegistersFrom:address count:count success:^(NSArray *array) {
            success(array);
        } failure:^(NSError *error) {
            failure(error);
        }];
    }
    else if (type == kRegisters) {
        [self readRegistersFrom:address count:count success:^(NSArray *array) {
            success(array);
        } failure:^(NSError *error) {
            failure(error);
        }];
    }
}

- (void) writeBit:(int)address to:(BOOL)status success:(void (^)())success failure:(void (^)(NSError *error))failure {
    dispatch_async(modbusQueue, ^{
        if(modbus_write_bit(mb, address, status) >= 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                success();
            });
        }
        else {
            NSString *errorString = [NSString stringWithUTF8String:modbus_strerror(errno)];
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:errorString forKey:NSLocalizedDescriptionKey];
            // populate the error object with the details
            NSError *error = [NSError errorWithDomain:@"Modbus" code:errno userInfo:details];
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });
        }
    });
    
}

- (void) writeRegister:(int)address to:(int)value success:(void (^)())success failure:(void (^)(NSError *error))failure {
    dispatch_async(modbusQueue, ^{
        if(modbus_write_register(mb, address, value) >= 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                success();
            });
        }
        else {
            NSString *errorString = [NSString stringWithUTF8String:modbus_strerror(errno)];
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:errorString forKey:NSLocalizedDescriptionKey];
            // populate the error object with the details
            NSError *error = [NSError errorWithDomain:@"Modbus" code:errno userInfo:details];
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });
        }
    });
    
}

- (void) readBitsFrom:(int)startAddress count:(int)count success:(void (^)(NSArray *array))success failure:(void (^)(NSError *error))failure {
    dispatch_async(modbusQueue, ^{
        
        uint8_t tab_reg[count*sizeof(uint8_t)];
        
        if (modbus_read_bits(mb, startAddress, count, tab_reg) >= 0) {
            NSMutableArray *returnArray = [NSMutableArray arrayWithCapacity:count];
            
            for(int i=0;i<count;i++)
            {
                [returnArray addObject:[NSNumber numberWithBool:tab_reg[i]]];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                success(returnArray);
            });
        }
        else {
            NSString *errorString = [NSString stringWithUTF8String:modbus_strerror(errno)];
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:errorString forKey:NSLocalizedDescriptionKey];
            // populate the error object with the details
            NSError *error = [NSError errorWithDomain:@"Modbus" code:errno userInfo:details];
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });
        }
        
    });
}

- (void) readInputBitsFrom:(int)startAddress count:(int)count success:(void (^)(NSArray *array))success failure:(void (^)(NSError *error))failure {
    dispatch_async(modbusQueue, ^{
        
        uint8_t tab_reg[count*sizeof(uint8_t)];
        
        if (modbus_read_input_bits(mb, startAddress, count, tab_reg) >= 0) {
            NSMutableArray *returnArray = [NSMutableArray arrayWithCapacity:count];
            
            for(int i=0;i<count;i++)
            {
                [returnArray addObject:[NSNumber numberWithBool: tab_reg[i]]];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                success(returnArray);
            });
        }
        else {
            NSString *errorString = [NSString stringWithUTF8String:modbus_strerror(errno)];
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:errorString forKey:NSLocalizedDescriptionKey];
            // populate the error object with the details
            NSError *error = [NSError errorWithDomain:@"Modbus" code:errno userInfo:details];
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });
        }
        
    });
}

- (void) readRegistersFrom:(int)startAddress count:(int)count success:(void (^)(NSArray *array))success failure:(void (^)(NSError *error))failure {
    dispatch_async(modbusQueue, ^{
        
        uint16_t tab_reg[count*sizeof(uint16_t)];
        
        if (modbus_read_registers(mb, startAddress, count, tab_reg) >= 0) {
            NSMutableArray *returnArray = [NSMutableArray arrayWithCapacity:count];
            
            for(int i=0;i<count;i++)
            {
                [returnArray addObject:[NSNumber numberWithInt: tab_reg[i]]];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                success(returnArray);
            });
        }
        else {
            NSString *errorString = [NSString stringWithUTF8String:modbus_strerror(errno)];
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:errorString forKey:NSLocalizedDescriptionKey];
            // populate the error object with the details
            NSError *error = [NSError errorWithDomain:@"Modbus" code:errno userInfo:details];
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });
        }        
    });
}

- (void) readInputRegistersFrom:(int)startAddress count:(int)count success:(void (^)(NSArray *array))success failure:(void (^)(NSError *error))failure {
    dispatch_async(modbusQueue, ^{
        
        uint16_t tab_reg[count*sizeof(uint16_t)];
        
        if (modbus_read_input_registers(mb, startAddress, count, tab_reg) >= 0) {
            NSMutableArray *returnArray = [NSMutableArray arrayWithCapacity:count];
            
            for(int i=0;i<count;i++)
            {
                [returnArray addObject:[NSNumber numberWithInt: tab_reg[i]]];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                success(returnArray);
            });
        }
        else {
            NSString *errorString = [NSString stringWithUTF8String:modbus_strerror(errno)];
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:errorString forKey:NSLocalizedDescriptionKey];
            // populate the error object with the details
            NSError *error = [NSError errorWithDomain:@"Modbus" code:errno userInfo:details];
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });
        } 
    });
}

- (void) dealloc {
    dispatch_release(modbusQueue);
    modbus_free(mb);
}

@end
