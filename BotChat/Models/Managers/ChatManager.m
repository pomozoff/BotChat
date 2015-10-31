//
//  ChatManager.m
//  BotChat
//
//  Created by Антон on 31.10.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

#import "ChatManager.h"
#import "ChatMessage+CoreDataProperties.h"
#import "ChatMessageDecorator.h"

static NSUInteger const kBatchSize = 20;
static NSString * const kSortColumnName = @"date";
static NSString * const kChatMessageEntityName = @"ChatMessage";

@interface ChatManager()

@end

@implementation ChatManager

#pragma mark - Properties

@synthesize dataStore = _dataStore;

- (void)setDataStore:(CoreDataStore *)dataStore {
    if (_dataStore != dataStore) {
        _dataStore = dataStore;
        __weak __typeof(self) weakSelf = self;
        [_dataStore setupWithCompletion:^(BOOL succeeded, NSError *error) {
            [weakSelf didCompleteCoreDataSetup:succeeded withError:error];
        }];
    }
}

#pragma mark - Public

- (id <ChatMessage>)objectAtIndexPath:(NSIndexPath *)indexPath {
    ChatMessage *chatMessage = [self.dataSource objectAtIndexPath:indexPath];
    return [ChatMessageDecorator decoratedInstanceOf:chatMessage];
}
- (void)addNewChatMessageWithText:(NSString *)text {
    ChatMessage *chatMessage = [self addManagedObjectWithEntityName:kChatMessageEntityName];
    chatMessage.text = text;
    [self saveMessages];
}
- (void)addNewChatMessageWithImage:(UIImage *)image {
    
}
- (void)addNewChatMessageWithCoordinate:(CLLocationCoordinate2D)coordinate {
    
}

#pragma mark - Private

- (NSFetchedResultsController *)fetchedResultsControllerWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([ChatMessage class])];
    request.predicate = nil;
    request.fetchBatchSize = kBatchSize;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:kSortColumnName
                                                              ascending:YES
                                                               selector:nil]];
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                          managedObjectContext:managedObjectContext
                                                                            sectionNameKeyPath:nil
                                                                                     cacheName:nil];
    return frc;
}
- (ChatMessage *)addManagedObjectWithEntityName:(NSString *)entityName {
    return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.dataStore.addQueueManagedObjectContext];
}
- (void)saveMessages {
    NSError *error;
    [self.dataStore.addQueueManagedObjectContext save:&error];
    if (error) {
        NSLog(@"Save messages failed: %@", error);
    }
}

#pragma mark - Callback handlers

- (void)didCompleteCoreDataSetup:(BOOL)succeeded withError:(NSError *)error {
    if (succeeded) {
        NSFetchedResultsController *frc = [self fetchedResultsControllerWithManagedObjectContext:self.dataStore.mainQueueManagedObjectContext];
        __weak typeof(self) weakSelf = self;
        [self.dataSource updateFetchedResultsController:frc withCompletion:^(BOOL innerSucceeded, NSError *innerError) {
            [weakSelf didUpdateFetchedResultsController:innerSucceeded withError:innerError];
        }];
    } else {
        NSLog(@"Core Data Store setup failed: %@", error);
    }
}
- (void)didUpdateFetchedResultsController:(BOOL)succeeded withError:(NSError *)error {
    if (succeeded) {
        /*
         __weak __typeof(self) weakSelf = self;
         [self.dataFetcher fetchDataWithCompletion:^(id _Nullable collection, NSError * _Nullable innerError) {
         [weakSelf didFetchData:collection withError:innerError];
         }];
         */
    } else {
        NSLog(@"Setup Fetched Result Controller failed: %@", error);
    }
}

@end
