//
//  ChatTableViewCell.m
//  BotChat
//
//  Created by Антон on 31.10.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

#import "ChatTableViewCell.h"

@implementation ChatTableViewCell

#pragma mark - Public

- (void)updateWithChatMessage:(id <ChatMessage>)chatMessage {
    
}

#pragma mark - Lifecycle

- (void)awakeFromNib {
    // Initialization code
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
