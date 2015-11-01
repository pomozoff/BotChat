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
@property (weak, nonatomic) IBOutlet UIImageView *chatImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingBubbleViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingBubbleViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *aspectImageViewConstraint;

@end

@implementation ChatTableViewCell

#pragma mark - Public

- (void)updateWithChatMessage:(id <ChatMessage>)chatMessage {
    [self setupValuesForChatMessage:chatMessage];
    [self setupAppearanceForChatMessage:chatMessage];
}
- (void)updateImage:(UIImage *)image {
    UIImage *newImage = image != nil ? image : [UIImage imageNamed:@"placeholder"];
    if (self.chatImageView.image != newImage) {
        self.chatImageView.image = newImage;
    }
}

#pragma mark - Lifecycle

- (void)awakeFromNib {
    // Initialization code
    self.bubbleView.layer.cornerRadius = 10.0f;
    self.bubbleView.layer.masksToBounds = YES;
}

#pragma mark - Private

- (void)setupValuesForChatMessage:(id <ChatMessage>)chatMessage {
    if (chatMessage.isTextMessage) {
        self.chatTextLabel.text = chatMessage.text;
        self.chatImageView.image = nil;
    } else {
        self.chatTextLabel.text = @"";
        [self updateImage:chatMessage.thumbnail];
    }
    self.chatImageView.hidden = chatMessage.isTextMessage;
}
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
    self.bubbleView.backgroundColor = chatMessage.isTextMessage ? backgroundColor : [UIColor clearColor];
    self.chatTextLabel.textColor = textColor;
    self.leadingBubbleViewConstraint.priority = leadingPriority;
    self.trailingBubbleViewConstraint.priority = trailingPriority;
    
    self.aspectImageViewConstraint.priority = chatMessage.isTextMessage ? kLowPriority : kHighPriority;
}

@end
