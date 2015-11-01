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

@interface ViewController () <UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *inputTextView;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomInputViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *maxInputTextViewConstraint;

@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) UIImage *placeholder;
@property (nonatomic, strong) NSMutableDictionary <NSNumber *, UIImage *> *images;

@end

@implementation ViewController

#pragma mark - Properties

- (UIImagePickerController *)imagePickerController {
    if (!_imagePickerController) {
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self;
    }
    return _imagePickerController;
}
- (UIImage *)placeholder {
    if (!_placeholder) {
        _placeholder = [UIImage imageNamed:@"placeholder"];
    }
    return _placeholder;
}
- (NSMutableDictionary *)images {
    if (!_images) {
        _images = [[NSMutableDictionary alloc] init];
    }
    return _images;
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self tuneUserInputView];
    [self addHideKeyboardGestureRecognizer];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    self.imagePickerController = nil;
    self.images = nil;
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
    id <ChatMessage> chatMessage = [self.chatManager objectAtIndexPath:indexPath];
    [(ChatTableViewCell *)cell updateWithChatMessage:chatMessage];
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self updateCell:(ChatTableViewCell *)cell atIndexPath:indexPath];
}

#pragma mark - Text view delegate

- (void)textViewDidChange:(UITextView *)textView {
    [self updateUserInputTextViewState:textView];
    [self updateSendButtonState];
}

#pragma mark - <UIImagePickerControllerDelegate>

- (void)imagePickerController:(UIImagePickerController * _Nonnull)picker didFinishPickingMediaWithInfo:(NSDictionary <NSString *, id> * _Nonnull)info {
    __weak __typeof(self) weakSelf = self;
    [self.imagePickerController dismissViewControllerAnimated:YES completion:^{
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        if (image) {
            [weakSelf.chatManager addNewChatMessageWithImage:image];
        }
    }];
}

#pragma mark - Actions

- (IBAction)sendButtonTap:(UIButton *)sender {
    NSString *text = [self processTextToSend];

    self.inputTextView.text = @"";
    self.inputTextView.scrollEnabled = NO;
    [self updateSendButtonState];
    [self.inputTextView updateConstraints];

    [self.chatManager addNewChatMessageWithText:text];
}
- (IBAction)geoButtonTap:(id)sender {
    [self.chatManager addNewChatMessageWithCoordinate:[self.coordinateManager currentCoordinate]];
}
- (IBAction)imageButtonTap:(id)sender {
    self.imagePickerController.allowsEditing = NO;
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

#pragma mark - Private

- (void)updateCell:(ChatTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    id <ChatMessage> chatMessage = [self.chatManager objectAtIndexPath:indexPath];
    if (!chatMessage.isTextMessage) {
        NSNumber *indexOfRow = [NSNumber numberWithInteger:indexPath.row];
        UIImage *image = self.images[indexOfRow];
        if (!image) {
            image = chatMessage.thumbnail;
            if (!image) {
                [self.chatManager thumbnailForChatMessageAtIndexPath:indexPath
                                                            withSize:self.placeholder.size
                                                       andCompletion:^(UIImage * _Nullable image, NSError * _Nullable error)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (image && !error) {
                            self.images[indexOfRow] = image;
                        } else {
                            NSLog(@"Error getting thumbnail for image: %@", error);
                        }
                    });
                }];
            } else {
                self.images[indexOfRow] = image;
            }
        }
        if (image) {
            [cell updateImage:image];
        }
    }
}
- (NSString *)processTextToSend {
    NSString *trimmedText = [self.inputTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return trimmedText;
}
- (CGSize)placeholderSize {
    return self.placeholder.size;
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
    [self.tableView addGestureRecognizer:tap];
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
- (void)updateUserInputTextViewState:(UITextView *)textView {
    CGRect rect = [textView.text boundingRectWithSize:CGSizeMake(textView.frame.size.width, CGFLOAT_MAX)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{NSFontAttributeName: textView.font}
                                              context:nil];
    self.inputTextView.scrollEnabled = rect.size.height >= self.maxInputTextViewConstraint.constant;
}

@end
