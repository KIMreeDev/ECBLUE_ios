//
//  GGDiscover.h
//  ECBLUE
//
//  Created by JIRUI on 14/12/25.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GGPeripheral.h"
#import "GGDataConversion.h"
#import "JRModel.h"
typedef enum
{
    IDLE = 0,
    SCANNING,
    CONNECTED,
} ConnectionState;

@protocol GGDiscoveryDelegate <NSObject>
- (void) discoveredDidRefresh;
- (void) discoveryStatePoweredOff;
- (void) discoveryStatePoweredOn;
- (void) connectedSuccess;
- (void) connectedFailure;
- (void) didCancelconnected;
@end

@interface GGDiscover : NSObject{
    ConnectionState state;
}

//单例
+ (id)sharedInstance;

//代理
@property (nonatomic, weak) id<GGDiscoveryDelegate> discoveryDelegate;

//发现的设备、 连接的设备
@property (strong, nonatomic) NSMutableArray *foundPeripherals;
@property (strong, nonatomic) NSMutableArray *connectedUARTPeripherals;

//请求数据（块）
- (void)startRequestWithCmd:(NSString *)cmd_header index:(NSUInteger)index finishedBlock:(void(^)(GGDataConversion *dataConversion))finished;
//设置数据
- (void)sendCmd:(NSString *)cmd model:(JRModel *)model finishedBlock:(GGRequestFinishedBlock)finishedBlock;

//搜索、停止、断开
- (void)startScanning;
- (void)stopScanning;
- (void)cancelConnection;
- (void)connectPeripheral:(CBPeripheral*)peripheral;
- (BOOL)isConnectted;
@end
