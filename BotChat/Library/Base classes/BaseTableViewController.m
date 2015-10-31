//
//  BaseTableViewController.m
//  Accounts List
//
//  Created by Anton Pomozov on 24.09.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

#import "BaseTableViewController.h"
#import "DataManagement.h"

@interface BaseTableViewController () <DataSourceDelegate, DataPresenter>

@end

@implementation BaseTableViewController

#pragma mark - Properties

@synthesize dataSource = _dataSource;
@synthesize updateOperation = _updateOperation;

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.dataSource.presenter = self;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataSource numberOfSections];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource numberOfItemsInSection:section];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.dataSource titleForHeaderInSection:section];
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [self.dataSource sectionForSectionIndexTitle:title atIndex:index];
}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self.dataSource sectionIndexTitles];
}

#pragma mark - DataPresenter

- (void)reloadData {
    [self.tableView reloadData];
}
- (void)willChangeContent {
    [self.tableView beginUpdates];
    self.updateOperation = [[NSBlockOperation alloc] init];
    
    __weak UITableView *weakTableView = self.tableView;
    self.updateOperation.completionBlock = ^{
        [weakTableView endUpdates];
    };
}
- (void)didChangeSectionatIndex:(NSUInteger)sectionIndex
                  forChangeType:(TableChangeType)type
{
    __weak UITableView *weakTableView = self.tableView;
    switch(type) {
        case TableChangeInsert: {
            [self.updateOperation addExecutionBlock:^{
                [weakTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            }];
            break;
        }
        case TableChangeDelete: {
            [self.updateOperation addExecutionBlock:^{
                [weakTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            }];
            break;
        }
        case TableChangeUpdate: {
            [self.updateOperation addExecutionBlock:^{
                [weakTableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            }];
            break;
        }
        case TableChangeMove: {
            [self.updateOperation addExecutionBlock:^{
                [weakTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                [weakTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
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
    __weak UITableView *weakTableView = self.tableView;
    switch(type) {
        case TableChangeInsert: {
            [self.updateOperation addExecutionBlock:^{
                [weakTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            }];
            break;
        }
        case TableChangeDelete: {
            [self.updateOperation addExecutionBlock:^{
                [weakTableView deleteRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            }];
            break;
        }
        case TableChangeUpdate: {
            [self.updateOperation addExecutionBlock:^{
                [weakTableView reloadRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            }];
            break;
        }
        case TableChangeMove: {
            [self.updateOperation addExecutionBlock:^{
                [weakTableView deleteRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                [weakTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            }];
            break;
        }
        default:
            break;
    }
}
- (void)didChangeContent {
    [self.updateOperation start];
}

@end
