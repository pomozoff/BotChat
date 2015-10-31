//
//  DataStore.h
//  Accounts List
//
//  Created by Anton Pomozov on 18.09.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

typedef void (^CompletionHandler)(BOOL succeeded, NSError * __nullable error);

@protocol DataStore <NSObject>

- (void)setupWithCompletion:(CompletionHandler)handler;
- (void)saveDataWithCompletion:(CompletionHandler)handler;

@end

@protocol DataStoreDelegate <NSObject>

@property (nonatomic, strong) id <DataStore> dataStore;

@end

NS_ASSUME_NONNULL_END
