//
//  ChatMessageWrapper.h
//  BotChat
//
//  Created by Антон on 31.10.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

@import Foundation;
@import UIKit;
@import CoreLocation;

NS_ASSUME_NONNULL_BEGIN

@protocol ChatMessage <NSObject>

@property (nonatomic, strong, nullable, readonly) NSString *text;
@property (nonatomic, strong, nullable, readonly) NSDate *date;
@property (nonatomic, strong, nullable, readonly) UIImage *image;
@property (nonatomic, strong, nullable, readonly) UIImage *thumbnail;
@property (nonatomic, assign, readonly) CLLocationDegrees latitude;
@property (nonatomic, assign, readonly) CLLocationDegrees longitude;
@property (nonatomic, assign, readonly) BOOL hasLocation;
@property (nonatomic, assign, readonly) BOOL hasImage;
@property (nonatomic, assign, readonly) BOOL incoming;
@property (nonatomic, assign, readonly) BOOL isTextMessage;

@end

NS_ASSUME_NONNULL_END
