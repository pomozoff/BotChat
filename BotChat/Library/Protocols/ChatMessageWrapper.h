//
//  ChatMessageWrapper.h
//  BotChat
//
//  Created by Антон on 31.10.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@protocol ChatMessage <NSObject>

@property (nullable, nonatomic, strong) NSString *message;
@property (nullable, nonatomic, strong) NSDate *date;
@property (nullable, nonatomic, strong) NSNumber *incoming;

@end

NS_ASSUME_NONNULL_END
