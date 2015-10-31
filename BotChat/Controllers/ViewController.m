//
//  ViewController.m
//  BotChat
//
//  Created by Антон on 31.10.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

#import "ViewController.h"
#import "ChatTableViewCell.h"

static NSString * const kCellReuseIdentifier = @"Chat Table Cell";

@interface ViewController ()

@end

@implementation ViewController

#pragma mark - Properties

- (void)setChatManager:(ChatManager *)chatManager {
    _chatManager = chatManager;
    [self reloadData];
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier forIndexPath:indexPath];
    [self updateCell:cell atIndexPath:indexPath];
    
    return cell;
}

#pragma mark - Private

- (void)updateCell:(ChatTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    id <ChatMessage> chatMessage = [self.chatManager objectAtIndexPath:indexPath];
    [cell updateWithChatMessage:chatMessage];
}

@end
