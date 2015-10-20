//
//  CoreDataDAO.h
//  ECBLUE
//
//  Created by JIRUI on 15/1/10.
//  Copyright (c) 2015年 ecigarfan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataDAO : NSObject


//被管理的对象上下文
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
//被管理的对象模型
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
//持久化存储协调者
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory;

@end
