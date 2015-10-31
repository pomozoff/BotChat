//
//  ChatMessage+CoreDataProperties.m
//  BotChat
//
//  Created by Антон on 31.10.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ChatMessage+CoreDataProperties.h"

@implementation ChatMessage (CoreDataProperties)

@dynamic date;
@dynamic incoming;
@dynamic text;
@dynamic latitude;
@dynamic longitude;
@dynamic hasLocation;
@dynamic thumbnail;
@dynamic image;

@end
