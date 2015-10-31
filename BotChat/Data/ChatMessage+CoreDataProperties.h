//
//  ChatMessage+CoreDataProperties.h
//  BotChat
//
//  Created by Антон on 31.10.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ChatMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatMessage (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *message;
@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSNumber *incoming;

@end

NS_ASSUME_NONNULL_END
