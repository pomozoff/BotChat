//
//  ChatMessageDecorator.h
//  BotChat
//
//  Created by Антон on 31.10.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

@import Foundation;

#import "ChatMessage+CoreDataProperties.h"
#import "ChatMessageWrapper.h"

@interface ChatMessageDecorator : NSProxy <ChatMessage>

+ (instancetype)decoratedInstanceOf:(ChatMessage *)instance;

@end
