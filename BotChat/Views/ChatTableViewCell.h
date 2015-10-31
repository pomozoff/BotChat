//
//  ChatTableViewCell.h
//  BotChat
//
//  Created by Антон on 31.10.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

@import UIKit;

#import "ChatMessageWrapper.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatTableViewCell : UITableViewCell

- (void)updateWithChatMessage:(id <ChatMessage>)chatMessage;

@end

NS_ASSUME_NONNULL_END
