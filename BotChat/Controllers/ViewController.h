//
//  ViewController.h
//  BotChat
//
//  Created by Антон on 31.10.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

@import UIKit;

#import "BaseTableViewController.h"
#import "ChatManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ViewController : BaseTableViewController

@property (nonatomic, strong) ChatManager *chatManager;

@end

NS_ASSUME_NONNULL_END
