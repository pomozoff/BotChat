//
//  CoreDataStore.h
//  Accounts List
//
//  Created by Anton Pomozov on 18.09.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

@import Foundation;
@import CoreData;

#import "DataStore.h"

NS_ASSUME_NONNULL_BEGIN

@interface CoreDataStore : NSObject <DataStore>

- (instancetype)initWithModelName:(NSString *)modelName NS_DESIGNATED_INITIALIZER;

@property (nullable, nonatomic, strong, readonly) NSManagedObjectContext *mainQueueManagedObjectContext;

@end

NS_ASSUME_NONNULL_END
