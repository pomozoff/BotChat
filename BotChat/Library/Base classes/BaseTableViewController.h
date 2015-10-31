//
//  BaseTableViewController.h
//  Accounts List
//
//  Created by Anton Pomozov on 24.09.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

@import UIKit;

#import "DataManagement.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    ScrollDirectionUp = 1,
    ScrollDirectionDown = 2,
} ScrollDirection;

@interface BaseTableViewController : UIViewController <TableDataSourceDelegate, DataPresenter>

@property (nonatomic, strong) IBOutlet UITableView *tableView;

- (void)scrollMessages:(ScrollDirection)scrollDirection;

@end

NS_ASSUME_NONNULL_END
