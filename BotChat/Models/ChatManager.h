//
//  ChatManager.h
//  BotChat
//
//  Created by Антон on 31.10.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

@import Foundation;

#import "ChatMessageWrapper.h"
#import "DataStore.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatManager : NSObject <DataStoreDelegate>

- (id <ChatMessage>)objectAtIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
