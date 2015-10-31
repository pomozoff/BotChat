//
//  Image+CoreDataProperties.h
//  BotChat
//
//  Created by Антон on 01.11.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Image.h"

NS_ASSUME_NONNULL_BEGIN

@interface Image (CoreDataProperties)

@property (nullable, nonatomic, retain) NSData *image;
@property (nullable, nonatomic, retain) NSSet<ChatMessage *> *chatMessage;

@end

@interface Image (CoreDataGeneratedAccessors)

- (void)addChatMessageObject:(ChatMessage *)value;
- (void)removeChatMessageObject:(ChatMessage *)value;
- (void)addChatMessage:(NSSet<ChatMessage *> *)values;
- (void)removeChatMessage:(NSSet<ChatMessage *> *)values;

@end

NS_ASSUME_NONNULL_END
