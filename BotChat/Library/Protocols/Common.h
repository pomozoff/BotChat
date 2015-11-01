//
//  Common.h
//  Accounts List
//
//  Created by Anton Pomozov on 18.09.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

#ifndef Common_h
#define Common_h

@import Foundation;
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

typedef void (^CompletionHandler)(BOOL succeeded, NSError * __nullable error);
typedef void (^FetchImageCompletionHandler)(UIImage * _Nullable image, NSError * _Nullable error);

NS_ASSUME_NONNULL_END

#endif /* Common_h */
