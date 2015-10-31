//
//  ChatTableViewCell.m
//  BotChat
//
//  Created by Антон on 31.10.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

#import "ChatTableViewCell.h"

static NSUInteger const kHighPriority = 750;
static NSUInteger const kLowPriority = 250;

@interface ChatTableViewCell ()

@property (weak, nonatomic) IBOutlet UIView *bubbleView;
@property (weak, nonatomic) IBOutlet UILabel *chatTextLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingBubbleViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingBubbleViewConstraint;

@end

@implementation ChatTableViewCell

#pragma mark - Public

- (void)updateWithChatMessage:(id <ChatMessage>)chatMessage {
    self.chatTextLabel.text = chatMessage.text;
    [self setupAppearanceForChatMessage:chatMessage];
}

#pragma mark - Lifecycle

- (void)awakeFromNib {
    // Initialization code
    self.bubbleView.layer.cornerRadius = 10.0f;
    self.bubbleView.layer.masksToBounds = YES;
}

#pragma mark - Private

- (void)setupAppearanceForChatMessage:(id <ChatMessage>)chatMessage {
    UIColor *backgroundColor;
    UIColor *textColor;
    CGFloat leadingPriority, trailingPriority;
    
    if (chatMessage.incoming) {
        backgroundColor = [UIColor colorWithRed:224.0f/255.0f green:222.0f/255.0f blue:230.0f/255.0f alpha:1.0f];
        textColor = [UIColor blackColor];
        leadingPriority = kHighPriority;
        trailingPriority = kLowPriority;
    } else {
        backgroundColor = [UIColor colorWithRed:0.0f green:122.0f/255.0f blue:1.0f alpha:1.0f];
        textColor = [UIColor whiteColor];
        leadingPriority = kLowPriority;
        trailingPriority = kHighPriority;
    }
    self.bubbleView.backgroundColor = backgroundColor;
    self.chatTextLabel.textColor = textColor;
    self.leadingBubbleViewConstraint.priority = leadingPriority;
    self.trailingBubbleViewConstraint.priority = trailingPriority;
}

@end
