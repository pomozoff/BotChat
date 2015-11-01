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
    ChatMessage *outgoingChatMessage = [self addManagedObjectWithEntityName:kChatMessageEntityName];
    outgoingChatMessage.text = text;
    [self processOutgoingChatMessage:outgoingChatMessage];
}
- (void)addNewChatMessageWithImage:(UIImage *)image {
    ChatMessage *outgoingChatMessage = [self addManagedObjectWithEntityName:kChatMessageEntityName];
    outgoingChatMessage.hasImage = [NSNumber numberWithBool:YES];
    
    __weak __typeof(self) weakSelf = self;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        CGSize newSize = CGSizeMake(image.size.width / 2, image.size.height / 2);
        NSData *data = UIImageJPEGRepresentation([self resizeImage:image toSize:newSize], 0.5);
        dispatch_async(dispatch_get_main_queue(), ^{
            outgoingChatMessage.image = [self addManagedObjectWithEntityName:kImageEntityName];
            outgoingChatMessage.image.image = data;
            [weakSelf processOutgoingChatMessage:outgoingChatMessage];
        });
    });

}
- (void)addNewChatMessageWithCoordinate:(CLLocationCoordinate2D)coordinate {
    ChatMessage *outgoingChatMessage = [self addManagedObjectWithEntityName:kChatMessageEntityName];
    outgoingChatMessage.hasLocation = [NSNumber numberWithBool:YES];
    outgoingChatMessage.latitude = [NSNumber numberWithDouble:coordinate.latitude];
    outgoingChatMessage.longitude = [NSNumber numberWithDouble:coordinate.longitude];
    [self processOutgoingChatMessage:outgoingChatMessage];
}
- (void)createThumbnailForChatMessageAtIndexPath:(NSIndexPath *)indexPath withSize:(CGSize)size andCompletion:(FetchImageCompletionHandler)handler {
    __weak __typeof(self) weakSelf = self;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        UIImage *image = nil;
        ChatMessage *chatMessage = [strongSelf.dataSource objectAtIndexPath:indexPath];
        if ([chatMessage.hasImage boolValue]) {
            image = [strongSelf resizeImage:[UIImage imageWithData:chatMessage.image.image] toSize:size];
            chatMessage.thumbnail = UIImageJPEGRepresentation(image, 0.5);
            handler(image, nil);
        } else if ([chatMessage.hasLocation boolValue]) {
            [strongSelf.locationDataSource makeImageLocationForChatMessage:[ChatMessageDecorator decoratedInstanceOf:chatMessage]
                                                             forSize:size
                                                      withCompletion:^(UIImage * _Nullable image, NSError * _Nullable error) {
                                                          chatMessage.thumbnail = UIImageJPEGRepresentation(image, 0.5);
                                                          handler(image, error);
                                                      }];
        }
    });
}
- (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)newSize {
    CGFloat scale = newSize.width / image.size.width;
    UIImage *scaledImage = [UIImage imageWithCGImage:[image CGImage]
                                               scale:(image.scale * scale)
                                         orientation:image.imageOrientation];
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
- (id)addManagedObjectWithEntityName:(NSString *)entityName {
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
    [self.dataStore.addQueueManagedObjectContext performBlock:^{
    NSError *error;
    [self.dataStore.addQueueManagedObjectContext save:&error];
    if (error) {
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
