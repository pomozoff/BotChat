//
//  ChatMessageDecorator.m
//  BotChat
//
//  Created by Антон on 31.10.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

#import "ChatMessageDecorator.h"

@interface ChatMessageDecorator ()

@property (nonatomic, strong) ChatMessage *instance;

@end

@implementation ChatMessageDecorator

#pragma mark - Properties

@dynamic date;
@dynamic incoming;
@dynamic text;
@dynamic latitude;
@dynamic longitude;
@dynamic hasLocation;
@dynamic thumbnail;
@dynamic image;
@dynamic isTextMessage;

#pragma mark - Lifecycle

+ (instancetype)decoratedInstanceOf:(ChatMessage *)instance {
    return [[self alloc] initWithObject:instance];
}
- (instancetype)initWithObject:(ChatMessage *)chatMessage {
    _instance = chatMessage;
    return self;
}
- (id)forwardingTargetForSelector:(SEL)aSelector {
    return self.instance;
}

#pragma mark - Decorated methods

- (CLLocationDegrees)latitude {
    return [self.instance.latitude doubleValue];
}
- (CLLocationDegrees)longitude {
    return [self.instance.longitude doubleValue];
}
- (BOOL)hasLocation {
    return [self.instance.hasLocation boolValue];
}
- (BOOL)hasImage {
    return [self.instance.hasImage boolValue];
}
- (BOOL)incoming {
    return [self.instance.incoming boolValue];
}
- (BOOL)isTextMessage {
    return ![self hasLocation] && ![self hasImage];
}
- (UIImage *)thumbnail {
    return [UIImage imageWithData:self.instance.thumbnail];
}
- (UIImage *)image {
    return [UIImage imageWithData:self.instance.image.image];
}

@end
