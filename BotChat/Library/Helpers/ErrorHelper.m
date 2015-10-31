//
//  ErrorHelper.m
//  VidimoPlayer
//
//  Created by Anton Pomozov on 16/09/15.
//  Copyright (c) 2015 Akademon Ltd. All rights reserved.
//

#import "ErrorHelper.h"

@implementation ErrorHelper

+ (NSError *)createErrorWithCode:(NSInteger)code
                     description:(NSString *)description
                      suggestion:(NSString *)suggestion
                         options:(NSArray *)options
                     errorDomain:(NSString *)errorDomain
{
    NSParameterAssert(description);
    NSParameterAssert(suggestion);
    NSParameterAssert(options);
    
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : description,
                                NSLocalizedRecoverySuggestionErrorKey : suggestion,
                                NSLocalizedRecoveryOptionsErrorKey : options };
    NSError *error = [NSError errorWithDomain:errorDomain code:code userInfo:userInfo];
    return error;
}

@end
