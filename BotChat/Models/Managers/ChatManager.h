//
//  ChatManager.h
//  BotChat
//
//  Created by Антон on 31.10.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

@import Foundation;

#import "ChatMessageWrapper.h"
#import "CoreDataStore.h"
#import "CoreDataSource.h"
#import "LocationDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatManager : NSObject

@property (nonatomic, strong) CoreDataStore *dataStore;
@property (nonatomic, strong) id <CoreDataSource> dataSource;
@property (nonatomic, strong) id <LocationDataSource> locationDataSource;

- (id <ChatMessage>)objectAtIndexPath:(NSIndexPath *)indexPath;

- (void)addNewChatMessageWithText:(NSString *)text;
- (void)addNewChatMessageWithImage:(UIImage *)image;
- (void)addNewChatMessageWithCoordinate:(CLLocationCoordinate2D)coordinate;

- (void)thumbnailForChatMessageAtIndexPath:(NSIndexPath *)indexPath withSize:(CGSize)size andCompletion:(FetchImageCompletionHandler)handler;
- (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)newSize;

@end

NS_ASSUME_NONNULL_END
