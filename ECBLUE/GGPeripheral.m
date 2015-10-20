//
//  GGPeripheral.m
//
//  Created by JIRUI on 14/12/25.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "GGPeripheral.h"

@interface GGPeripheral ()
@property CBService *uartService;
@property CBCharacteristic *rxCharacteristic;
@property CBCharacteristic *txCharacteristic;

@end

@implementation GGPeripheral
@synthesize peripheral = _peripheral;
@synthesize delegate = _delegate;

@synthesize uartService = _uartService;
@synthesize rxCharacteristic = _rxCharacteristic;
@synthesize txCharacteristic = _txCharacteristic;

+ (CBUUID *) uartServiceUUID
{
    return [CBUUID UUIDWithString:@"0000F481-0000-1000-8000-00805F9B34FB"];/*[CBUUID UUIDWithString:@"6e400001-b5a3-f393-e0a9-e50e24dcca9e"];*/
}

+ (CBUUID *) txCharacteristicUUID
{
    return [CBUUID UUIDWithString:@"0000F482-0000-1000-8000-00805F9B34FB"];/*[CBUUID UUIDWithString:@"6e400002-b5a3-f393-e0a9-e50e24dcca9e"];*/
}

+ (CBUUID *) rxCharacteristicUUID
{
    return [CBUUID UUIDWithString:@"0000F483-0000-1000-8000-00805F9B34FB"];/*[CBUUID UUIDWithString:@"6e400003-b5a3-f393-e0a9-e50e24dcca9e"];*/
}

+ (CBUUID *) deviceInformationServiceUUID
{
    return [CBUUID UUIDWithString:@"180A"];
}

+ (CBUUID *) hardwareRevisionStringUUID
{
    return [CBUUID UUIDWithString:@"2A27"];
}

- (GGPeripheral *) initWithPeripheral:(CBPeripheral*)peripheral delegate:(id<GGPeripheralDelegate>) delegate
{
    if (self = [super init])
    {
        _peripheral = peripheral;
        _peripheral.delegate = self;
        _delegate = delegate;
    }
    return self;
}

- (void) didConnect
{
    [_peripheral discoverServices:@[self.class.uartServiceUUID/*self.class.deviceInformationServiceUUID*/]];
    NSLog(@"Did start service discovery.");
}

- (void) didDisconnect
{
    
}

//请求
- (void)startRequestWithCmd:(NSData *)data finished:(GGRequestFinishedBlock)finishedBlock
{
    [self writeRawData:data];
    self.finishedBlock = finishedBlock;
}

//写数据
- (void) writeRawData:(NSData *) data
{
    if ((self.txCharacteristic.properties & CBCharacteristicPropertyWriteWithoutResponse) != 0)
    {
        [self.peripheral writeValue:data forCharacteristic:self.txCharacteristic type:CBCharacteristicWriteWithoutResponse];
    }
    else if ((self.txCharacteristic.properties & CBCharacteristicPropertyWrite) != 0)
    {
        [self.peripheral writeValue:data forCharacteristic:self.txCharacteristic type:CBCharacteristicWriteWithResponse];
    }
    else
    {
        NSLog(@"No write property on TX characteristic, %lu.", (unsigned long)self.txCharacteristic.properties);
    }
}

//发现服务
- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{

    if (error)
    {
        NSLog(@"Error discovering services: %@", error);
        return;
    }
    
    for (CBService *s in [peripheral services])
    {
        if ([s.UUID isEqual:self.class.uartServiceUUID])
        {
            NSLog(@"Found correct service");
            self.uartService = s;
            
            [self.peripheral discoverCharacteristics:@[self.class.txCharacteristicUUID, self.class.rxCharacteristicUUID] forService:self.uartService];
        }
        else if ([s.UUID isEqual:self.class.deviceInformationServiceUUID])
        {
            [self.peripheral discoverCharacteristics:@[self.class.hardwareRevisionStringUUID] forService:s];
        }
    }
}

//发现特征
- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Error discovering characteristics: %@", error);
        return;
    }
    
    for (CBCharacteristic *c in [service characteristics])
    {
        if ([c.UUID isEqual:self.class.rxCharacteristicUUID])
        {
            NSLog(@"Found RX characteristic");
            self.rxCharacteristic = c;
            [self.peripheral setNotifyValue:YES forCharacteristic:self.rxCharacteristic];
            //发送时间
            [self sendTime:service Peripheral:peripheral];

        }
        else if ([c.UUID isEqual:self.class.txCharacteristicUUID])
        {
            NSLog(@"Found TX characteristic");
            self.txCharacteristic = c;
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CHARACTER_DISCOVER object:@{@"name":service.peripheral.name, @"uuid": peripheral.identifier.UUIDString, @"characteristic":@(1)}];
        }
        else if ([c.UUID isEqual:self.class.hardwareRevisionStringUUID])
        {
            NSLog(@"Found Hardware Revision String characteristic");
            [self.peripheral readValueForCharacteristic:c];
        }
    }
}

//接收
- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Error receiving notification for characteristic %@: %@", characteristic, error);
        return;
    }
    
    if (characteristic == self.rxCharacteristic)
    {
        
        NSString *receiveData = [self stringFromData:[characteristic value]];

        //代理返回(产品发送给app)
        if ([receiveData isEqualToString:CMD_SMOKE_USAGE_TIME]) {
            [self.delegate didReceiveData:receiveData];
        }
        //块方式返回(app发送请求，产品返回)
        else {
            if (self.finishedBlock) {
                self.finishedBlock(receiveData);
            }
        }
        
    }
    else if ([characteristic.UUID isEqual:self.class.hardwareRevisionStringUUID])
    {
        
        NSString *hwRevision = @"";
        const uint8_t *bytes = characteristic.value.bytes;
        for (int i = 0; i < characteristic.value.length; i++)
        {
            NSLog(@"%x", bytes[i]);
            hwRevision = [hwRevision stringByAppendingFormat:@"0x%02x, ", bytes[i]];
        }
        NSLog(@"Hardware revision:%@", [hwRevision substringToIndex:hwRevision.length-2]);

    }
}

//NSData转NSString*
- (NSString *) stringFromData:(NSData *)data
{
    Byte *bytes = (Byte *)[data bytes];
    
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[data length];i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}

//发送时间
- (void) sendTime:(CBService *)service Peripheral:(CBPeripheral *)peripheral
{
    TimeModel *timeModel = [[TimeModel alloc] init];
    timeModel.date = [NSDate date];
    [[GGDiscover sharedInstance] sendCmd:CMD_TIME_HEADER model:timeModel finishedBlock:^(NSString *reciveData) {
        //通知返回
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CHARACTER_DISCOVER object:@{@"name":service.peripheral.name, @"uuid": peripheral.identifier.UUIDString, @"characteristic":@(0)}];
    }];
}

//重起
- (void) reset
{
    if (_peripheral) {
        _peripheral = nil;
    }
}
@end
