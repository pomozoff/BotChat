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
static NSString * const kImageEntityName = @"Image";

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
    __weak __typeof(self) weakSelf = self;
    [self addManagedObjectWithEntityName:kChatMessageEntityName withOperation:^(NSManagedObject *object) {
        ChatMessage *outgoingChatMessage = (ChatMessage *)object;
        outgoingChatMessage.text = text;
        [weakSelf processOutgoingChatMessage:outgoingChatMessage];
    }];
}
- (void)addNewChatMessageWithImage:(UIImage *)image {
    __weak __typeof(self) weakSelf = self;
    [self addManagedObjectWithEntityName:kChatMessageEntityName withOperation:^(NSManagedObject *object) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        ChatMessage *outgoingChatMessage = (ChatMessage *)object;
        outgoingChatMessage.hasImage = [NSNumber numberWithBool:YES];
        outgoingChatMessage.image = [NSEntityDescription insertNewObjectForEntityForName:kImageEntityName
                                                                  inManagedObjectContext:strongSelf.dataStore.addQueueManagedObjectContext];
        outgoingChatMessage.image.image = UIImageJPEGRepresentation(image, 1.0f);
        [strongSelf processOutgoingChatMessage:outgoingChatMessage];
}];
}
- (void)addNewChatMessageWithCoordinate:(CLLocationCoordinate2D)coordinate {
    __weak __typeof(self) weakSelf = self;
    [self addManagedObjectWithEntityName:kChatMessageEntityName withOperation:^(NSManagedObject *object) {
        ChatMessage *outgoingChatMessage = (ChatMessage *)object;
        outgoingChatMessage.hasLocation = [NSNumber numberWithBool:YES];
        outgoingChatMessage.latitude = [NSNumber numberWithDouble:coordinate.latitude];
        outgoingChatMessage.longitude = [NSNumber numberWithDouble:coordinate.longitude];
        [weakSelf processOutgoingChatMessage:outgoingChatMessage];
    }];
}
- (void)thumbnailForChatMessageAtIndexPath:(NSIndexPath *)indexPath withSize:(CGSize)size andCompletion:(FetchImageCompletionHandler)handler {
    ChatMessage *chatMessageInMainQueue = [self.dataSource objectAtIndexPath:indexPath];
    NSManagedObjectID *objectID = chatMessageInMainQueue.objectID;

    __weak __typeof(self) weakSelf = self;
    [self.dataStore.addQueueManagedObjectContext performBlock:^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        UIImage *image = nil;
        ChatMessage *chatMessage = [self.dataStore.addQueueManagedObjectContext objectWithID:objectID];
        if ([chatMessage.hasImage boolValue]) {
            UIImage *bigImage = [UIImage imageWithData:chatMessage.image.image];
            image = [strongSelf resizeImage:bigImage toSize:size];
            handler(image, nil);
            chatMessage.thumbnail = UIImageJPEGRepresentation(image, 1.0f);
            [self saveNewMessages];
        } else if ([chatMessage.hasLocation boolValue]) {
            [strongSelf.locationDataSource makeImageLocationForChatMessage:[ChatMessageDecorator decoratedInstanceOf:chatMessage]
                                                                   forSize:size
                                                            withCompletion:^(UIImage * _Nullable image, NSError * _Nullable error)
             {
                 handler(image, nil);
                 [self.dataStore.addQueueManagedObjectContext performBlock:^{
                     chatMessage.thumbnail = UIImageJPEGRepresentation(image, 1.0f);
                     [self saveNewMessages];
                 }];
             }];
        }
    }];
}
- (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0f);
    [image drawInRect:CGRectMake(0.0f, 0.0f, newSize.width, newSize.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
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
- (void)addManagedObjectWithEntityName:(NSString *)entityName withOperation:(void(^)(NSManagedObject *object))block {
    [self.dataStore.addQueueManagedObjectContext performBlock:^{
        NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.dataStore.addQueueManagedObjectContext];
        block(object);
    }];
}
- (ChatMessage *)duplicateMessage:(ChatMessage *)chatMessage {
    ChatMessage *newChatMessage = [NSEntityDescription insertNewObjectForEntityForName:kChatMessageEntityName
                                                                inManagedObjectContext:self.dataStore.addQueueManagedObjectContext];
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
- (void)saveNewMessages {
    [self.dataStore saveNewObjectsWithCompletion:^(BOOL succeeded, NSError * __nullable error) {
        if (!succeeded && error) {
            NSLog(@"Save messages failed: %@", error);
        }
    }];
}
- (void)processOutgoingChatMessage:(ChatMessage *)outgoingChatMessage {
    outgoingChatMessage.incoming = [NSNumber numberWithBool:NO];
    outgoingChatMessage.date = [NSDate date];
    
    ChatMessage *incomingChatMessage = [self duplicateMessage:outgoingChatMessage];
    incomingChatMessage.incoming = [NSNumber numberWithBool:YES];
    incomingChatMessage.date = [NSDate date];
    
    [self saveNewMessages];
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
