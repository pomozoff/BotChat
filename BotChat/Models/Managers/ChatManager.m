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
static NSString * const kSortColumnDate = @"date";
static NSString * const kSortColumnIncoming = @"incoming";
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
    ChatMessage *outgoingChatMessage = [self addManagedObjectWithEntityName:kChatMessageEntityName];
    outgoingChatMessage.text = text;
    [self processOutgoingChatMessage:outgoingChatMessage];
}
- (void)addNewChatMessageWithImage:(UIImage *)image {
    ChatMessage *outgoingChatMessage = [self addManagedObjectWithEntityName:kChatMessageEntityName];
    outgoingChatMessage.hasImage = [NSNumber numberWithBool:YES];
    //outgoingChatMessage.image.image = UIImagePNGRepresentation(image);
    [self processOutgoingChatMessage:outgoingChatMessage];
}
- (void)addNewChatMessageWithCoordinate:(CLLocationCoordinate2D)coordinate {
    ChatMessage *outgoingChatMessage = [self addManagedObjectWithEntityName:kChatMessageEntityName];
    outgoingChatMessage.hasLocation = [NSNumber numberWithBool:YES];
    outgoingChatMessage.latitude = [NSNumber numberWithDouble:coordinate.latitude];
    outgoingChatMessage.longitude = [NSNumber numberWithDouble:coordinate.longitude];
    [self processOutgoingChatMessage:outgoingChatMessage];
}

#pragma mark - Private

- (NSFetchedResultsController *)fetchedResultsControllerWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([ChatMessage class])];
    request.predicate = nil;
    request.fetchBatchSize = kBatchSize;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:kSortColumnDate ascending:YES]];
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                          managedObjectContext:managedObjectContext
                                                                            sectionNameKeyPath:nil
                                                                                     cacheName:nil];
    return frc;
}
- (ChatMessage *)addManagedObjectWithEntityName:(NSString *)entityName {
    return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.dataStore.addQueueManagedObjectContext];
}
- (ChatMessage *)duplicateMessage:(ChatMessage *)chatMessage {
    ChatMessage *newChatMessage = [self addManagedObjectWithEntityName:kChatMessageEntityName];
    
    for (NSAttributeDescription *attribute in chatMessage.entity.properties) {
        if([attribute isKindOfClass:[NSAttributeDescription class]]) {
            id value = [chatMessage valueForKey:attribute.name];
            [newChatMessage setValue:value forKey:attribute.name];
        }
    }
    [chatMessage.image addChatMessageObject:newChatMessage];
    newChatMessage.image = chatMessage.image;

    return newChatMessage;
}
- (void)saveMessages {
    NSError *error;
    [self.dataStore.addQueueManagedObjectContext save:&error];
    if (error) {
        NSLog(@"Save messages failed: %@", error);
    }
}
- (void)processOutgoingChatMessage:(ChatMessage *)outgoingChatMessage {
    outgoingChatMessage.incoming = [NSNumber numberWithBool:NO];
    outgoingChatMessage.date = [NSDate date];
    
    ChatMessage *incomingChatMessage = [self duplicateMessage:outgoingChatMessage];
    incomingChatMessage.incoming = [NSNumber numberWithBool:YES];
    incomingChatMessage.date = [NSDate date];
    
    [self saveMessages];
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
