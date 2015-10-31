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

NS_ASSUME_NONNULL_BEGIN

@interface ChatManager : NSObject

@property (nonatomic, strong) CoreDataStore *dataStore;
@property (nonatomic, strong) id <CoreDataSourceDelegate> dataSourceDelegate;

- (id <ChatMessage>)objectAtIndexPath:(NSIndexPath *)indexPath;

- (void)addNewChatMessageWithText:(NSString *)text;
- (void)addNewChatMessageWithImage:(UIImage *)image;
- (void)addNewChatMessageWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end

NS_ASSUME_NONNULL_END
