//
//  ErrorHelper.h
//  VidimoPlayer
//
//  Created by Anton Pomozov on 16/09/15.
//  Copyright (c) 2015 Akademon Ltd. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface ErrorHelper : NSObject

+ (NSError *)createErrorWithCode:(NSInteger)code
                     description:(NSString *)description
                      suggestion:(NSString *)suggestion
                         options:(NSArray *)options
                     errorDomain:(NSString *)errorDomain;

@end

NS_ASSUME_NONNULL_END
