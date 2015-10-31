//
//  CoreDataSource.h
//  Accounts List
//
//  Created by Anton Pomozov on 23.09.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

@import Foundation;

#import "DataManagement.h"
#import "CoreDataStore.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CoreDataSourceDelegate <NSObject>

- (void)updateFetchedResultsController:(NSFetchedResultsController *)newfrc withCompletion:(CompletionHandler)handler;
- (id)objectAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface CoreDataSource : NSObject <CoreDataSourceDelegate, TableDataSource, DataPresenterDelegate>

@end

NS_ASSUME_NONNULL_END
