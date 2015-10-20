//
//  EcblueDAO.m
//  ECBLUE
//
//  Created by JIRUI on 15/1/12.
//  Copyright (c) 2015年 ecigarfan. All rights reserved.
//

#import "EcblueDAO.h"

@implementation EcblueDAO
static EcblueDAO *sharedManager = nil;

+ (EcblueDAO *)sharedManager
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        
        sharedManager = [[self alloc] init];
        [sharedManager managedObjectContext];

    });
    return sharedManager;
}

/*
    增
 */
- (int) createStep:(StepModel *)model
{
    NSManagedObjectContext *cxt = [self managedObjectContext];

    StepEntity *entity = [NSEntityDescription insertNewObjectForEntityForName:@"StepEntity" inManagedObjectContext:cxt];
    entity.indexOfDay = [NSNumber numberWithInteger:model.indexOfDay];
    entity.date = model.date;
    entity.minutes = [NSNumber numberWithInteger:model.minutes];
    entity.steps = [NSNumber numberWithInteger:model.steps];
    entity.kcals = [NSNumber numberWithInteger:model.kcals];
    entity.distances = [NSNumber numberWithFloat:model.distances];
    entity.blueUUID = model.blueUUID;
    NSError *savingError = nil;
    if (![cxt save:&savingError]){
        NSLog(@"插入数据失败");
        return -1;
    }
    
    return 0;
}

- (int) createSleep:(SleepModel *)model
{
    NSManagedObjectContext *cxt = [self managedObjectContext];
    
    SleepEntity *entity = [NSEntityDescription insertNewObjectForEntityForName:@"SleepEntity" inManagedObjectContext:cxt];
    entity.indexOfSleep = [NSNumber numberWithInteger:model.indexOfSleep];
    entity.startDate = model.startDate;
    entity.endDate = model.endDate;
    entity.minutes = [NSNumber numberWithInteger:model.minutes];
    entity.blueUUID = model.blueUUID;
    NSError *savingError = nil;
    if (![cxt save:&savingError]){
        NSLog(@"插入数据失败");
        return -1;
    }
    
    return 0;
}

- (int) createSmoke:(SmokeModel *)model
{
    NSManagedObjectContext *cxt = [self managedObjectContext];
    
    SmokeEntity *entity = [NSEntityDescription insertNewObjectForEntityForName:@"SmokeEntity" inManagedObjectContext:cxt];
    entity.indexOfDay = [NSNumber numberWithInteger:model.indexOfDay];
    entity.date = model.date;
    entity.mouths = [NSNumber numberWithInteger:model.mouths];
    entity.mouths = [NSNumber numberWithInteger:model.seconds];
    entity.blueUUID = model.blueUUID;
    NSError *savingError = nil;
    if (![cxt save:&savingError]){
        NSLog(@"插入数据失败");
        return -1;
    }
    return 0;
}

/*
    删
 */
- (void) removeAllInfo
{
    NSManagedObjectContext *cxt = [self managedObjectContext];
    NSArray *arr = [NSArray arrayWithObjects:@"StepEntity", @"SleepEntity", @"SmokeEntity", nil];
    
    for (NSUInteger i = 0; i < arr.count; i ++) {
        NSEntityDescription *StepEntity = [NSEntityDescription entityForName:[arr objectAtIndex:i]
                                                      inManagedObjectContext:cxt];
        [self deleteAllObjectsInContext:cxt usingModel:StepEntity.managedObjectModel];
    }
}

/*
    查询所有
 */
- (NSMutableArray *) findAllOfStep
{
    NSManagedObjectContext *cxt = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"StepEntity" inManagedObjectContext:cxt];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"blueUUID = %@", [S_USER_DEFAULTS valueForKey:F_BLUE_UUID]];
    [request setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSError *error = nil;
    NSArray *listData = [cxt executeFetchRequest:request error:&error];
    NSMutableArray *resListData = [NSMutableArray array];
    
    for (StepEntity *entity in listData) {
        StepModel *model = [[StepModel alloc]init];
        model.indexOfDay = [entity.indexOfDay integerValue];
        model.date = entity.date;
        model.minutes = [entity.minutes unsignedIntegerValue];
        model.steps = [entity.steps unsignedIntegerValue];
        model.kcals = [entity.kcals unsignedIntegerValue];
        model.distances = [entity.distances integerValue];
        [resListData addObject:model];
    }
    return resListData;
}

- (NSMutableArray *) findAllOfSleep
{
    NSManagedObjectContext *cxt = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"SleepEntity" inManagedObjectContext:cxt];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"blueUUID = %@", [S_USER_DEFAULTS valueForKey:F_BLUE_UUID]];
    [request setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startDate" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSError *error = nil;
    NSArray *listData = [cxt executeFetchRequest:request error:&error];
    NSMutableArray *resListData = [NSMutableArray array];
    
    for (SleepEntity *entity in listData) {
        SleepModel *model = [[SleepModel alloc]init];
        model.indexOfSleep = [entity.indexOfSleep integerValue];
        model.startDate = entity.startDate;
        model.endDate = entity.startDate;
        model.minutes = [entity.minutes unsignedIntegerValue];
        [resListData addObject:model];
    }
    return resListData;
}

- (NSMutableArray *) findAllOfSmoke
{
    NSManagedObjectContext *cxt = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"SmokeEntity" inManagedObjectContext:cxt];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"blueUUID = %@", [S_USER_DEFAULTS valueForKey:F_BLUE_UUID]];
    [request setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSError *error = nil;
    NSArray *listData = [cxt executeFetchRequest:request error:&error];
    NSMutableArray *resListData = [NSMutableArray array];
    
    for (SmokeEntity *entity in listData) {
        SmokeModel *model = [[SmokeModel alloc]init];
        model.indexOfDay = [entity.indexOfDay integerValue];
        model.date = entity.date;
        model.mouths = [entity.mouths unsignedIntegerValue];
        model.seconds = [entity.seconds unsignedIntegerValue];
        [resListData addObject:model];
    }
    return resListData;
}

/*
    查询单个
 */
- (StepModel *) findStepByID:(StepModel *)model
{
    NSManagedObjectContext *cxt = [self managedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"StepEntity" inManagedObjectContext:cxt];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"blueUUID = %@ AND date = %@", model.blueUUID, model.date];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *listData = [cxt executeFetchRequest:request error:&error];
    
    if ([listData count] > 0) {
        StepEntity *entity = [listData lastObject];
        StepModel *model = [[StepModel alloc] init];
        model.indexOfDay = [entity.indexOfDay integerValue];
        model.date = entity.date;
        model.minutes = [entity.minutes unsignedIntegerValue];
        model.steps = [entity.steps unsignedIntegerValue];
        model.kcals = [entity.kcals unsignedIntegerValue];
        model.distances = [entity.distances floatValue];
        
        return model;
    }
    
    return nil;
}

- (SleepModel *) findSleepByID:(SleepModel *)model
{
    NSManagedObjectContext *cxt = [self managedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"SleepEntity" inManagedObjectContext:cxt];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"blueUUID = %@ AND startDate = %@", model.blueUUID, model.startDate];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *listData = [cxt executeFetchRequest:request error:&error];
    
    if ([listData count] > 0) {
        SleepEntity *entity = [listData lastObject];
        SleepModel *model = [[SleepModel alloc] init];
        model.indexOfSleep = [entity.indexOfSleep integerValue];
        model.startDate = entity.startDate;
        model.endDate = entity.startDate;
        model.minutes = [entity.minutes unsignedIntegerValue];
        
        return model;
    }
    
    return nil;
}

- (SmokeModel *) findSmokeByID:(SmokeModel *)model
{
    NSManagedObjectContext *cxt = [self managedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"SmokeEntity" inManagedObjectContext:cxt];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"blueUUID = %@ AND date = %@", model.blueUUID, model.date];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *listData = [cxt executeFetchRequest:request error:&error];
    
    if ([listData count] > 0) {
        SmokeEntity *entity = [listData lastObject];
        SmokeModel *model = [[SmokeModel alloc] init];
        model.indexOfDay = [entity.indexOfDay integerValue];
        model.date = entity.date;
        model.mouths = [entity.mouths unsignedIntegerValue];
        model.seconds = [entity.seconds unsignedIntegerValue];
        
        return model;
    }
    
    return nil;
}

/*
    改
 */
- (int) modifyStep:(StepModel *)model
{
    NSManagedObjectContext *cxt = [self managedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"StepEntity" inManagedObjectContext:cxt];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"blueUUID = %@ AND date =  %@", model.blueUUID, model.date];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *listData = [cxt executeFetchRequest:request error:&error];
    if ([listData count] > 0) {
        StepEntity *entity = [listData lastObject];
        entity.indexOfDay = [NSNumber numberWithInteger:model.indexOfDay];
        entity.minutes = [NSNumber numberWithInteger:model.minutes];
        entity.steps = [NSNumber numberWithInteger:model.steps];
        entity.kcals = [NSNumber numberWithInteger:model.kcals];
        entity.distances = [NSNumber numberWithInteger:model.distances];
        
        NSError *savingError = nil;
        if ([self.managedObjectContext save:&savingError]){
            NSLog(@"修改数据成功");
        } else {
            NSLog(@"修改数据失败");
            return -1;
        }
    }
    return 0;
}

- (int) modifySleep:(SleepModel *)model
{
    NSManagedObjectContext *cxt = [self managedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"SleepEntity" inManagedObjectContext:cxt];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"blueUUID = %@ AND startDate =  %@", model.blueUUID, model.startDate];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *listData = [cxt executeFetchRequest:request error:&error];
    if ([listData count] > 0) {
        SleepEntity *entity = [listData lastObject];
        entity.indexOfSleep = [NSNumber numberWithInteger:model.indexOfSleep];
        entity.endDate = model.endDate;
        entity.minutes = [NSNumber numberWithInteger:model.minutes];
        
        NSError *savingError = nil;
        if ([self.managedObjectContext save:&savingError]){
            NSLog(@"修改数据成功");
        } else {
            NSLog(@"修改数据失败");
            return -1;
        }
    }
    return 0;
}

- (int) modifySmoke:(SmokeModel *)model
{
    NSManagedObjectContext *cxt = [self managedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"SmokeEntity" inManagedObjectContext:cxt];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"blueUUID = %@ AND date =  %@", model.blueUUID, model.date];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *listData = [cxt executeFetchRequest:request error:&error];
    if ([listData count] > 0) {
        SmokeEntity *entity = [listData lastObject];
        entity.indexOfDay = [NSNumber numberWithInteger:model.indexOfDay];
        entity.mouths = [NSNumber numberWithInteger:model.mouths];
        entity.seconds = [NSNumber numberWithInteger:model.seconds];
        
        NSError *savingError = nil;
        if ([self.managedObjectContext save:&savingError]){
            NSLog(@"修改数据成功");
        } else {
            NSLog(@"修改数据失败");
            return -1;
        }
    }
    return 0;
}

#pragma mark - 删除实体

- (void)deleteAllObjectsWithEntityName:(NSString *)entityName
                             inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    fetchRequest.includesPropertyValues = NO;
    fetchRequest.includesSubentities = NO;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"blueUUID = %@", [S_USER_DEFAULTS valueForKey:F_BLUE_UUID]];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject *managedObject in items) {
        [context deleteObject:managedObject];
        NSLog(@"Deleted %@", entityName);
    }
}

- (void)deleteAllObjectsInContext:(NSManagedObjectContext *)context
                       usingModel:(NSManagedObjectModel *)model
{
    NSArray *entities = model.entities;
    for (NSEntityDescription *entityDescription in entities) {
        [self deleteAllObjectsWithEntityName:entityDescription.name
                                   inContext:context];
    }
}


@end
