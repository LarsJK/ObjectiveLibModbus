//
//  ObjectiveLibModbus.h
//  LibModbusTest
//
//  Created by Lars-Jørgen Kristiansen on 22.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "modbus.h"

typedef enum {
    kInputBits,
    kBits,
    kInputRegisters,
    kRegisters
} functionType;

@interface ObjectiveLibModbus : NSObject {
    modbus_t *mb;
    dispatch_queue_t modbusQueue;
}

@property (strong, nonatomic) NSString *ipAddress;
- (id) initWithTCP: (NSString *)ipAddress port: (int)port device:(int)device;
- (BOOL) setupTCP: (NSString *)ipAddress port: (int)port device:(int)device;
- (BOOL) connectWithError:(NSError**)error;
- (void) connect:(void (^)())success failure:(void (^)(NSError *error))failure;
- (void) disconnect;

- (void) writeType:(functionType)type address:(int)address to:(int)value success:(void (^)())success failure:(void (^)(NSError *error))failure;
-(void)readType:(functionType)type startAddress:(int)address count:(int)count success:(void (^)(NSArray *array))success failure:(void (^)(NSError *error))failure;

- (void) writeBit:(int)address to:(BOOL)status success:(void (^)())success failure:(void (^)(NSError *error))failure;
- (void) writeRegister:(int)address to:(int)value success:(void (^)())success failure:(void (^)(NSError *error))failure;
- (void) readBitsFrom:(int)startAddress count:(int)count success:(void (^)(NSArray *array))success failure:(void (^)(NSError *error))failure;
- (void) readInputBitsFrom:(int)startAddress count:(int)count success:(void (^)(NSArray *array))success failure:(void (^)(NSError *error))failure;
- (void) readRegistersFrom:(int)startAddress count:(int)count success:(void (^)(NSArray *array))success failure:(void (^)(NSError *error))failure;
- (void) readInputRegistersFrom:(int)startAddress count:(int)count success:(void (^)(NSArray *array))success failure:(void (^)(NSError *error))failure;

- (void) writeRegistersFromAndOn:(int)address toValues:(NSArray*)numberArray success:(void (^)())success failure:(void (^)(NSError *error))failure;

@end
