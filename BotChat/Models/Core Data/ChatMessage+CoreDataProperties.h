//
//  ChatMessage+CoreDataProperties.h
//  BotChat
//
//  Created by Антон on 01.11.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ChatMessage.h"
#import "Image.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatMessage (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSNumber *incoming;
@property (nullable, nonatomic, retain) NSString *text;
@property (nullable, nonatomic, retain) NSNumber *latitude;
@property (nullable, nonatomic, retain) NSNumber *longitude;
@property (nullable, nonatomic, retain) NSNumber *hasLocation;
@property (nullable, nonatomic, retain) NSData *thumbnail;
@property (nullable, nonatomic, retain) NSNumber *hasImage;
@property (nullable, nonatomic, retain) Image *image;

@end

NS_ASSUME_NONNULL_END
