//
//  ChatManager.m
//  BotChat
//
//  Created by Антон on 31.10.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

#import "ChatManager.h"
#import "ChatMessage+CoreDataProperties.h"

static NSUInteger const kBatchSize = 20;

@interface ChatManager()

@end

@implementation ChatManager

#pragma mark - Properties

@synthesize dataStore = _dataStore;

- (void)setDataStore:(CoreDataStore *)dataStore {
    if (_dataStore != dataStore) {
        _dataStore = dataStore;
        [_dataStore setupWithCompletion:^(BOOL succeeded, NSError *error) {
            [self didCompleteCoreDataSetup:succeeded withError:error];
        }];
    }
}

#pragma mark - Public

- (id <ChatMessage>)objectAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

#pragma mark - Private

- (NSFetchedResultsController *)fetchedResultsControllerWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([ChatMessage class])];
    request.predicate = nil;
    request.fetchBatchSize = kBatchSize;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date"
                                                              ascending:YES
                                                               selector:nil]];
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                          managedObjectContext:managedObjectContext
                                                                            sectionNameKeyPath:nil
                                                                                     cacheName:nil];
    return frc;
}

#pragma mark - Callback handlers

- (void)didCompleteCoreDataSetup:(BOOL)succeeded withError:(NSError *)error {
    if (succeeded) {
        NSFetchedResultsController *frc = [self fetchedResultsControllerWithManagedObjectContext:self.dataStore.mainQueueManagedObjectContext];
        __weak typeof(self) weakSelf = self;
        [self.dataSourceDelegate updateFetchedResultsController:frc withCompletion:^(BOOL innerSucceeded, NSError *innerError) {
            [weakSelf didUpdateFetchedResultsController:innerSucceeded withError:innerError];
        }];
    } else {
        NSLog(@"Core Data Store setup failed: %@", error);
    }
}
- (void)didUpdateFetchedResultsController:(BOOL)succeeded withError:(NSError *)error {
    if (succeeded) {
        /*
         [self.dataFetcher fetchDataWithCompletion:^(id _Nullable collection, NSError * _Nullable innerError) {
         [self didFetchData:collection withError:innerError];
         }];
         */
    } else {
        NSLog(@"Setup Fetched Result Controller failed: %@", error);
    }
}

@end
