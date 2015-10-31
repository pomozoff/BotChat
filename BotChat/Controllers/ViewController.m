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
static NSUInteger const kPercentOfInputTextViewHeight = 10;

typedef enum : NSUInteger {
    ScrollDirectionUp = 1,
    ScrollDirectionDown = 2,
} ScrollDirection;

@interface ViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *inputTextView;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIView *transparentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomInputViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *maxInputTextViewConstraint;

@end

@implementation ViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self tuneUserInputView];
    [self addHideKeyboardGestureRecognizer];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self registerForKeyboardNotification];
    [self updateSendButtonState];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self deregisterKeyboardNotifications];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier forIndexPath:indexPath];
    [self updateCell:cell atIndexPath:indexPath];
    
    return cell;
}

#pragma mark - Text view delegate

- (void)textViewDidChange:(UITextView *)textView {
    [self updateUserInputTextViewState:textView];
    [self updateSendButtonState];
}

#pragma mark - Private

- (void)updateCell:(ChatTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    id <ChatMessage> chatMessage = [self.chatManager objectAtIndexPath:indexPath];
    [cell updateWithChatMessage:chatMessage];
}

#pragma mark - Private keyboard

- (void)registerForKeyboardNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChangeFrame:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChangeFrame:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}
- (void)deregisterKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGRect endFrame = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    BOOL isShowing = notification.name == UIKeyboardWillShowNotification;
    self.transparentView.hidden = !isShowing;
    
    NSTimeInterval duration = [info[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSNumber *animationCurveRawNSN = info[UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationOptions animationCurve = animationCurveRawNSN == nil ? UIViewAnimationOptionCurveEaseInOut : [animationCurveRawNSN unsignedLongValue];
    
    self.bottomInputViewConstraint.constant = isShowing ? endFrame.size.height : 0.0f;
    [self.view setNeedsUpdateConstraints];
    
    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:animationCurve
                     animations: ^{
                         [weakSelf.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         if (finished && isShowing) {
                             [weakSelf scrollMessages:ScrollDirectionDown];
                         }
                     }];
}
- (void)addHideKeyboardGestureRecognizer {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(hideOpenedViews)];
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(hideOpenedViews)];
    swipe.direction = UISwipeGestureRecognizerDirectionDown;
    [self.transparentView addGestureRecognizer:tap];
    [self.transparentView addGestureRecognizer:swipe];
}
- (void)hideOpenedViews {
    [self dismissKeyboard];
}
- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - Private interface

- (void)tuneUserInputView {
    self.inputTextView.layer.borderWidth = 0.2f;
    self.inputTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.inputTextView.layer.cornerRadius = 5.0f;
}
- (void)updateSendButtonState {
    self.sendButton.enabled = self.inputTextView.text.length > 0;
}
- (void)scrollMessages:(ScrollDirection)scrollDirection {
    //NSLog(@"Scrolling %@", scrollDirection == ScrollDirectionUp ? @"up" : @"down");
    NSInteger sectionsNumber = [self.tableDataSource numberOfSections];
    NSInteger rowsNumber = [self.tableDataSource numberOfItemsInSection:sectionsNumber - 1];
    if (sectionsNumber > 0 && rowsNumber > 0) {
        NSInteger rowIndex = scrollDirection == ScrollDirectionUp ? 0 : rowsNumber - 1;
        UITableViewScrollPosition scrollPosition = scrollDirection == ScrollDirectionUp ? UITableViewScrollPositionTop : UITableViewScrollPositionBottom;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:rowIndex inSection:sectionsNumber - 1]
                                  atScrollPosition:scrollPosition animated:YES];
        });
    }
}
- (void)updateUserInputTextViewState:(UITextView *)textView {
    CGRect rect = [textView.text boundingRectWithSize:CGSizeMake(textView.frame.size.width, CGFLOAT_MAX)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{NSFontAttributeName: textView.font}
                                              context:nil];
    CGFloat maxHeight = self.maxInputTextViewConstraint.constant - self.maxInputTextViewConstraint.constant / kPercentOfInputTextViewHeight;
    self.inputTextView.scrollEnabled = rect.size.height > maxHeight;
}

@end
