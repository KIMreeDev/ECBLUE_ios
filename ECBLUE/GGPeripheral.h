//
//  GGPeripheral.h
//
//  Created by JIRUI on 14/12/25.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

/*
    ***协议
 */
@protocol GGPeripheralDelegate
- (void) didReceiveData:(NSString *) string;
@optional
- (void) didReadHardwareRevisionString:(NSString *) string;
@end


/*
    ***块
 */
typedef void (^GGRequestFinishedBlock)(NSString *reciveData);


/*
    ***GGPeripheral类
 */
@interface GGPeripheral : NSObject <CBPeripheralDelegate>
//请求完成回调
@property (nonatomic, copy) GGRequestFinishedBlock finishedBlock;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, weak) id<GGPeripheralDelegate> delegate;

- (GGPeripheral *) initWithPeripheral:(CBPeripheral*)peripheral delegate:(id<GGPeripheralDelegate>) delegate;
//服务UUID
+ (CBUUID *) uartServiceUUID;
//请求
- (void)startRequestWithCmd:(NSData *)data finished:(GGRequestFinishedBlock)finishedBlock;
//写数据
- (void) writeRawData:(NSData *) data;
- (void) didConnect;
- (void) didDisconnect;
- (void) reset;

@end
