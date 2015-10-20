//
//  GGDiscover.m
//  ECBLUE
//
//  Created by JIRUI on 14/12/25.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "GGDiscover.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface GGDiscover()<CBCentralManagerDelegate, GGPeripheralDelegate>{
    CBCentralManager *cm;
    GGPeripheral *currentPeripheral;
}
@end

@implementation GGDiscover

+ (id)sharedInstance
{
    static GGDiscover *instance	= nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken , ^{
        instance = [[GGDiscover alloc]init];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        cm = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        _foundPeripherals = [[NSMutableArray alloc] init];
        _connectedUARTPeripherals = [[NSMutableArray alloc] init];
    }
    return self;
}

- (BOOL)isConnectted
{
    return state==CONNECTED?YES:NO;
}

#pragma mark - 发送、请求数据方法

//请求数据
- (void) startRequestWithCmd:(NSString *)cmd_header index:(NSUInteger)index  finishedBlock:(void(^)(GGDataConversion *dataConversion))finished
{
    //发送请求
    if (state == CONNECTED) {
        
        //命令、验证头
        NSString *cmd = [cmd_header substringToIndex:4];
        NSString *header = [cmd_header substringFromIndex:cmd_header.length-2];
        
        //组合后命令、转换成二进制
        GGDataConversion *dataConver = [[GGDataConversion alloc]init];
        NSString *compo = [dataConver componentOfCmd:cmd index:index];
        NSData *data = [dataConver stringToByte:compo];
        
        NSLog(@"请求数据：%@", compo);
        [currentPeripheral startRequestWithCmd:data finished:^(NSString *reciveData) {
            //解析数据
            if ([[reciveData substringToIndex:2] isEqualToString:header]) {
                
                NSLog(@"块接收:%@", reciveData);
                GGDataConversion *manager = [[GGDataConversion alloc]initWithReciveData:reciveData validate:header];
                finished(manager);
            }
        }];

    } else {
        NSLog(@"未连接蓝牙...");
    }

}

//发送数据
- (void)sendCmd:(NSString *)cmd model:(JRModel *)model finishedBlock:(GGRequestFinishedBlock)finishedBlock
{
    //发送请求
    if (state == CONNECTED) {
        
        NSMutableString *willWriteData;
        GGDataConversion *dataConver = [[GGDataConversion alloc]init];
        NSMutableArray *data = model ? [model modelTransToArr] : nil ;
        
        //组合
        if ([cmd isEqual:CMD_SMOKE_CNT_HEADER]||[cmd isEqual:CMD_SMOKE_TIME_HEADER]) {
            willWriteData = [dataConver stringFromArrOfHighAndLow: data];
        }
        else{
            willWriteData = [dataConver stringFromArr:data];
        }
        
        //转换
        [willWriteData insertString:cmd atIndex:0];
        NSData *txData = [dataConver stringToByte:willWriteData];
        
        NSLog(@"发送命令：%@， 数据：%@", cmd, willWriteData);
        [currentPeripheral startRequestWithCmd:txData finished:^(NSString *reciveData) {
            //解析数据
            if ([reciveData isEqualToString:CMD_END_IDENTI]) {
                NSLog(@"块接收:%@",reciveData);
                finishedBlock(reciveData);
            }
        }];
    } else {
        NSLog(@"未连接蓝牙...");
    }
}


//搜索
- (void)startScanning
{
    state = SCANNING;
    [_foundPeripherals removeAllObjects];
    [cm scanForPeripheralsWithServices:@[GGPeripheral.uartServiceUUID]
                               options:@{CBCentralManagerScanOptionAllowDuplicatesKey: [NSNumber numberWithBool:NO]}];
}

//停止搜索
- (void) stopScanning
{
    [cm stopScan];
    if (currentPeripheral.peripheral.state == CBPeripheralStateConnected) {
        state = CONNECTED;
    }
}

//取消连接
- (void) cancelConnection
{
    if (currentPeripheral.peripheral.state == CBPeripheralStateConnected) {
        [cm cancelPeripheralConnection:currentPeripheral.peripheral];
    }
}

//连接蓝牙
- (void) connectPeripheral:(CBPeripheral*)peripheral
{
    if (currentPeripheral.peripheral.state == CBPeripheralStateConnected) {
        [cm cancelPeripheralConnection:currentPeripheral.peripheral];
    }
    if (peripheral.state == CBPeripheralStateDisconnected) {
        currentPeripheral = [[GGPeripheral alloc] initWithPeripheral:peripheral delegate:self];
        [cm connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey: [NSNumber numberWithBool:YES]}];
    }
}

//是否存储过蓝牙
- (BOOL) isExistDevice:(CBPeripheral *)peripheral
{
    NSArray	*storedDevices	= [S_USER_DEFAULTS arrayForKey:U_STORED_DEVICES];
    
    if (![storedDevices isKindOfClass:[NSArray class]]) {
        return NO;
    }
    
    BOOL result = [storedDevices containsObject:peripheral.identifier.UUIDString];
    return result;
}

//清除设备
- (void) clearDevices
{
    state = IDLE;
    GGPeripheral *periphe = nil;
    [_foundPeripherals removeAllObjects];
    
    for (periphe in _connectedUARTPeripherals) {
        [periphe reset];
    }
    
    [_connectedUARTPeripherals removeAllObjects];
}

#pragma mark - CBCentralManagerDelegate

//蓝牙状态
- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    
    switch ((NSInteger)central.state) {
        case CBCentralManagerStatePoweredOff:
        {
            
            [self clearDevices];
            [_discoveryDelegate discoveryStatePoweredOff];
            /* Tell user to power ON BT for functionality, but not on first run - the Framework will alert in that instance. */
            break;
        }
            
        case CBCentralManagerStateUnauthorized:
        {
            /* Tell user the app is not allowed. */
            break;
        }
            
        case CBCentralManagerStateUnknown:
        {
            /* Bad news, let's wait for another event. */
            break;
        }
            
        case CBCentralManagerStatePoweredOn:
        {
            [_discoveryDelegate discoveryStatePoweredOn];
            break;
        }
            
        case CBCentralManagerStateResetting:
        {
            [self clearDevices];
            [self startScanning];
            break;
        }
    }
}

//成功扫描到蓝牙
- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"Did discover peripheral %@", peripheral.name);
    if (![_foundPeripherals containsObject:peripheral]) {
        [_foundPeripherals addObject:peripheral];
    }
    [_discoveryDelegate discoveredDidRefresh];
    
    if ([self isExistDevice:peripheral]&&(currentPeripheral.peripheral.state!=CBPeripheralStateConnected)) {
        currentPeripheral = [[GGPeripheral alloc] initWithPeripheral:peripheral delegate:self];
        [cm connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey: [NSNumber numberWithBool:YES]}];
        return;
    }
}

//连接成功后
- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Did connect peripheral %@", peripheral.name);
    state = CONNECTED;
    [cm stopScan];
    
    if ([currentPeripheral.peripheral isEqual:peripheral])
    {
        //扫描服务
        [currentPeripheral didConnect];
        
        if (![_connectedUARTPeripherals containsObject:currentPeripheral])
            [_connectedUARTPeripherals addObject:currentPeripheral];
        
//        if ([_foundPeripherals containsObject:peripheral])
//            [_foundPeripherals removeObject:peripheral];

        [_discoveryDelegate connectedSuccess];
    }
}

//连接失败
- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Attempted connection to peripheral %@ failed: %@", [peripheral name], [error localizedDescription]);
    [_discoveryDelegate connectedFailure];
}

//断开连接后
- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Did disconnect peripheral %@", peripheral.name);
    [cm stopScan];
    state = IDLE;
    if ([currentPeripheral.peripheral isEqual:peripheral])
    {
        [currentPeripheral didDisconnect];
        GGPeripheral *uartPeriphe	= nil;
        
        for (uartPeriphe in _connectedUARTPeripherals) {
            if ([uartPeriphe peripheral] == peripheral) {
                [_connectedUARTPeripherals removeObject:uartPeriphe];

                break;
            }
        }
        
        if (![_foundPeripherals containsObject:peripheral]) {
            [_foundPeripherals insertObject:peripheral atIndex:0];
        }
        
        [_discoveryDelegate didCancelconnected];
    }
}


#pragma mark - UARTPeripheral 
//收到数据
- (void) didReceiveData:(NSString *)reciveData
{

    NSMutableString *receiveString;
    GGDataConversion *dataConver = [[GGDataConversion alloc]init];
    
    //烟弹使用时间 （每次抽烟完成产品发送数据给APP）
    if ([[reciveData substringWithRange:NSMakeRange(0, 2)] isEqualToString:CMD_SMOKE_USAGE_TIME]) {
        
        receiveString = [dataConver reserveseString:[reciveData substringFromIndex:2]];
        NSUInteger seconds = [dataConver allDataTransformToDecimal:receiveString];
        NSLog(@"烟弹使用时间: %lu 秒", (unsigned long)seconds);
        
    }

}

- (void) didReadHardwareRevisionString:(NSString *)string
{
    NSLog(@"ReceivedHardwareRevisionString.");
}

@end
