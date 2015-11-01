//
//  BaseTableViewController.m
//  Accounts List
//
//  Created by Anton Pomozov on 24.09.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

#import "BaseTableViewController.h"

@interface BaseTableViewController ()

@end

@implementation BaseTableViewController

#pragma mark - Properties

@synthesize updateOperation = _updateOperation;
@synthesize tableDataSource = _tableDataSource;

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableDataSource.presenter = self;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.tableDataSource numberOfSections];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableDataSource numberOfItemsInSection:section];
}

#pragma mark - Data presenter

- (void)reloadData {
    [self.tableView reloadData];

    [CATransaction begin];
    [self.tableView beginUpdates];

    __weak __typeof(self) weakSelf = self;
    [CATransaction setCompletionBlock: ^{
        [weakSelf scrollMessages:ScrollDirectionDown];
    }];
    
    [self.tableView endUpdates];
    [CATransaction commit];
}
- (void)reloadDataInSections:(NSIndexSet *)indexSet {
    NSAssert([NSThread isMainThread], @"Not in main thread!");
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
}
- (void)willChangeContent {
    NSAssert([NSThread isMainThread], @"Not in main thread!");

    [self.tableView beginUpdates];
    self.updateOperation = [[NSBlockOperation alloc] init];

    __weak __typeof(self) weakSelf = self;
    self.updateOperation.completionBlock = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView endUpdates];
        });
    };
}
- (void)didChangeSectionAtIndex:(NSUInteger)sectionIndex
                  forChangeType:(TableChangeType)type
{
    __weak __typeof(self) weakSelf = self;
    switch(type) {
        case TableChangeInsert: {
            [self.updateOperation addExecutionBlock:^{
                [weakSelf.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            }];
            break;
        }
        case TableChangeDelete: {
            [self.updateOperation addExecutionBlock:^{
                [weakSelf.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            }];
            break;
        }
        case TableChangeMove: {
            [self.updateOperation addExecutionBlock:^{
                [weakSelf.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                [weakSelf.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            }];
            break;
        }
        case TableChangeUpdate: {
            [self.updateOperation addExecutionBlock:^{
                [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            }];
            break;
        }
        default:
            break;
    }
}
- (void)didChangeObject:(id)anObject
            atIndexPath:(NSIndexPath *)indexPath
          forChangeType:(TableChangeType)type
           newIndexPath:(NSIndexPath *)newIndexPath
{
    __weak __typeof(self) weakSelf = self;
    switch(type) {
        case TableChangeInsert: {
            [self.updateOperation addExecutionBlock:^{
                [weakSelf.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            }];
            break;
        }
        case TableChangeDelete: {
            [self.updateOperation addExecutionBlock:^{
                [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }];
            break;
        }
        case TableChangeMove: {
            [self.updateOperation addExecutionBlock:^{
                [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [weakSelf.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            }];
            break;
        }
        case TableChangeUpdate: {
            [self.updateOperation addExecutionBlock:^{
                [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }];
            break;
        }
        default:
            break;
    }
}
- (void)didChangeContent {
    NSAssert([NSThread isMainThread], @"Not in main thread!");
    [self.updateOperation start];
}

- (void)scrollMessages:(ScrollDirection)scrollDirection {
    NSInteger sectionsNumber = [self.tableDataSource numberOfSections];
    if (sectionsNumber > 0) {
        NSInteger rowsNumber = [self.tableDataSource numberOfItemsInSection:sectionsNumber - 1];
        if (rowsNumber > 0) {
            NSLog(@"Scrolling %@", scrollDirection == ScrollDirectionUp ? @"up" : @"down");

            NSInteger rowIndex = scrollDirection == ScrollDirectionUp ? 0 : rowsNumber - 1;
            UITableViewScrollPosition scrollPosition = scrollDirection == ScrollDirectionUp ? UITableViewScrollPositionTop : UITableViewScrollPositionBottom;
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:rowIndex inSection:sectionsNumber - 1];

            CGPoint offset = self.tableView.contentOffset;
            [self.tableView beginUpdates];
            [self.tableView endUpdates];
            
            [self.tableView.layer removeAllAnimations];
            [self.tableView setContentOffset:offset animated:NO];
            
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:YES];
        }
    }
}

@end
