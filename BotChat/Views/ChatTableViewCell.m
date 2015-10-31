//
//  ChatTableViewCell.m
//  BotChat
//
//  Created by Антон on 31.10.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

#import "ChatTableViewCell.h"

@interface ChatTableViewCell ()

@property (weak, nonatomic) IBOutlet UIView *bubbleView;
@property (weak, nonatomic) IBOutlet UILabel *chatTextLabel;

@end

@implementation ChatTableViewCell

#pragma mark - Public

- (void)updateWithChatMessage:(id <ChatMessage>)chatMessage {
    self.chatTextLabel.text = chatMessage.text;
}


#pragma mark - Lifecycle

- (void)awakeFromNib {
    // Initialization code
    self.bubbleView.layer.cornerRadius = 10.0f;
    self.bubbleView.layer.masksToBounds = YES;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
