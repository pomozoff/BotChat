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

@property (nonatomic, strong, nullable) NSString *message;
@property (nonatomic, strong, nullable) NSDate *date;
@property (nonatomic, strong, nullable) NSNumber *incoming;
@property (nonatomic, strong, nullable) UIImage *image;
@property (nonatomic, assign) CLLocationDegrees latitude;
@property (nonatomic, assign) CLLocationDegrees longitude;
@property (nonatomic, assign) BOOL hasLocation;
@property (nonatomic, assign) BOOL hasImage;

@end

NS_ASSUME_NONNULL_END
