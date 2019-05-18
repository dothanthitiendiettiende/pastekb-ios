//
//  KeyboardViewController.m
//  Keyboard
//
//  Created by everettjf on 2019/5/14.
//  Copyright © 2019 everettjf. All rights reserved.
//

#import "KeyboardViewController.h"
#import "Masonry.h"
#import "TinyKeyboardView.h"
#include <pthread.h>
#import "ForEachWithRandomDelay.h"

@interface KeyboardViewController () <TinyKeyboardViewDelegate>
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *buttonView;

@property (nonatomic, strong) TinyKeyboardView *tinyView;

@property (nonatomic, strong) UIButton *nextKeyboardButton;
@property (nonatomic, strong) UIButton *tinyKeyboardButton;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIButton *returnButton;

@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIButton *inputButton;

@property (nonatomic, strong) NSString *pasteboardString;
@property (nonatomic, strong) ForEachWithRandomDelay *delayAction;

@property (strong, nonatomic) NSTimer *pasteboardCheckTimer;
@property (assign, nonatomic) NSInteger pasteboardChangeCount;

@property (strong, nonatomic) UIProgressView *progressView;
@property (strong, nonatomic) UISlider *speedSlider;

@end

@implementation KeyboardViewController

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    // Add custom view sizing constraints here
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    if ([self hasFullAccess]) {
        [self showStatusText:@"..."];
    } else {
        [self showFullAccessGuide];
    }
}

- (void)showFullAccessGuide{
    for(UIView * view in self.contentView.subviews){
        view.hidden = YES;
    }
    UITextView *textView = [[UITextView alloc] init];
    textView.backgroundColor = [UIColor clearColor];
    textView.editable = NO;
    textView.selectable = NO;
    textView.font = [UIFont systemFontOfSize:16];
    [self.contentView addSubview:textView];
    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    textView.text = @"Please go to Settings > General > Keyboard > Keyboards > Paste Keyboard, and make sure Allow Full Access is turned on.";
    
    [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_greaterThanOrEqualTo(120);
    }];
}

- (void)refreshDataFromPasteboard{
    self.pasteboardString = [UIPasteboard generalPasteboard].string;
    NSLog(@"text in pasteboard = %@",self.pasteboardString);
    if(!self.pasteboardString){
        return;
    }
    
    NSString *text = [self.pasteboardString copy];
    if(text.length > 30){
        text = [text substringToIndex:30];
        text = [text stringByAppendingString:@" ..."];
    }
    [self showStatusText:text];
}

- (void)initPasteboardData {
    if(![self hasFullAccess]){
        return;
    }
    
    [self refreshDataFromPasteboard];
    
    __weak typeof(self) wself = self;
    self.pasteboardCheckTimer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSInteger current = [[UIPasteboard generalPasteboard] changeCount];
        if(current != wself.pasteboardChangeCount) {
            wself.pasteboardChangeCount = current;
            
            // pasteboard changed
            [self refreshDataFromPasteboard];
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"appear");
    
    [self initPasteboardData];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    NSLog(@"disappear");
    
}
- (void)dealloc{
    NSLog(@"dealloc");
}

- (void)setupUI{
    self.contentView = [[UIView alloc] init];
    [self.view addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view);
        make.left.mas_equalTo(self.view);
        make.right.mas_equalTo(self.view);
    }];
    
    self.buttonView = [[UIView alloc] init];
    [self.view addSubview:self.buttonView];
    [self.buttonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_bottom).offset(2);
        make.left.mas_equalTo(self.view);
        make.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view);
        make.height.mas_equalTo(40);
    }];
    
    // button view
    {
        self.nextKeyboardButton = [[UIButton alloc]init];
        [self.nextKeyboardButton setTitle:NSLocalizedString(@"Next", @"Title for 'Next Keyboard' button") forState:UIControlStateNormal];
        [self.nextKeyboardButton addTarget:self action:@selector(handleInputModeListFromView:withEvent:) forControlEvents:UIControlEventAllTouchEvents];
        [self configButtonStyle:self.nextKeyboardButton];
        [self.buttonView addSubview:self.nextKeyboardButton];
        
        self.tinyKeyboardButton = [[UIButton alloc]init];
        [self.tinyKeyboardButton setTitle:NSLocalizedString(@"Tiny", @"Title for 'Tiny Keyboard' button") forState:UIControlStateNormal];
        [self.tinyKeyboardButton addTarget:self action:@selector(buttonTinyKeyboardTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self configButtonStyle:self.tinyKeyboardButton];
        [self.buttonView addSubview:self.tinyKeyboardButton];
        
        self.deleteButton = [[UIButton alloc]init];
        [self.deleteButton setTitle:NSLocalizedString(@"Delete", @"Title for 'Delete' button") forState:UIControlStateNormal];
        [self.deleteButton addTarget:self action:@selector(buttonBackwardTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self configButtonStyle:self.deleteButton];
        [self.buttonView addSubview:self.deleteButton];
        
        self.returnButton = [[UIButton alloc]init];
        [self.returnButton setTitle:NSLocalizedString(@"Return", @"Title for 'Return' button") forState:UIControlStateNormal];
        [self.returnButton addTarget:self action:@selector(buttonReturnTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self configButtonStyle:self.returnButton];
        [self.buttonView addSubview:self.returnButton];
        
        BOOL needSwitchKey = [self needsInputModeSwitchKey];
        if(needSwitchKey){
            [self.nextKeyboardButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.buttonView).offset(2);
                make.top.mas_equalTo(self.buttonView);
                make.bottom.mas_equalTo(self.buttonView);
            }];
            
            [self.tinyKeyboardButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.nextKeyboardButton.mas_right).offset(2);
                make.top.mas_equalTo(self.buttonView);
                make.bottom.mas_equalTo(self.buttonView);
                make.width.mas_equalTo(self.nextKeyboardButton);
            }];
            
        }else{
            [self.tinyKeyboardButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.buttonView).offset(2);
                make.top.mas_equalTo(self.buttonView);
                make.bottom.mas_equalTo(self.buttonView);
            }];
        }
        
        [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.tinyKeyboardButton.mas_right).offset(2);
            make.top.mas_equalTo(self.buttonView);
            make.bottom.mas_equalTo(self.buttonView);
            make.width.mas_equalTo(self.tinyKeyboardButton);
        }];
        
        [self.returnButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.deleteButton.mas_right).offset(2);
            make.top.mas_equalTo(self.buttonView);
            make.right.mas_equalTo(self.buttonView).offset(-2);
            make.bottom.mas_equalTo(self.buttonView);
            make.width.mas_equalTo(self.deleteButton);
        }];
    }
    
    // content view
    {
        self.progressView = [[UIProgressView alloc] init];
        self.progressView.progress = 0.0;
        [self.view addSubview:self.progressView];
        [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.contentView);
            make.right.mas_equalTo(self.contentView);
            make.top.mas_equalTo(self.contentView);
            make.height.mas_equalTo(3);
        }];
        
        self.inputButton = [[UIButton alloc]init];
        [self.inputButton setTitle:NSLocalizedString(@"Input", @"Title for 'Input' button") forState:UIControlStateNormal];
        [self.inputButton addTarget:self action:@selector(buttonInputTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self configButtonStyle:self.inputButton];
        [self.contentView addSubview:self.inputButton];
        [self.inputButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.progressView.mas_bottom);
            make.bottom.equalTo(self.contentView);
            make.right.equalTo(self.contentView);
            make.width.mas_equalTo(120);
        }];
        
        self.speedSlider = [[UISlider alloc] init];
        self.speedSlider.minimumValue = 0.0;
        self.speedSlider.maximumValue = 100.0;
        self.speedSlider.value = 50.0;
        self.speedSlider.continuous = YES;
        [self.speedSlider addTarget:self action:@selector(onSpeedSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:self.speedSlider];
        [self.speedSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.contentView);
            make.top.mas_equalTo(self.progressView.mas_bottom);
            make.right.mas_equalTo(self.inputButton.mas_left).offset(-10);
        }];
        
        self.textLabel = [[UILabel alloc] init];
        self.textLabel.numberOfLines = 0;
        self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.font = [UIFont systemFontOfSize:10];
        [self.contentView addSubview:self.textLabel];
        [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView);
            make.top.equalTo(self.speedSlider.mas_bottom).offset(10);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-10);
            make.right.mas_equalTo(self.inputButton.mas_left).offset(-10);
        }];
        
    }
    [self configColors:[UIColor blackColor]];
}
- (void)onSpeedSliderValueChanged:(id)sender{
    if(self.delayAction) {
        self.delayAction.speedThreshold = self.speedSlider.value;
    }
}

- (void)configColors:(UIColor *)textColor{
    [self.nextKeyboardButton setTitleColor:textColor forState:UIControlStateNormal];
    [self.tinyKeyboardButton setTitleColor:textColor forState:UIControlStateNormal];
    [self.deleteButton setTitleColor:textColor forState:UIControlStateNormal];
    [self.returnButton setTitleColor:textColor forState:UIControlStateNormal];
    [self.inputButton setTitleColor:textColor forState:UIControlStateNormal];
    
    self.textLabel.textColor = textColor;
}

- (void)configButtonStyle:(UIButton*)button{
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 5;
    button.layer.borderWidth = 1;
    button.layer.borderColor = [UIColor grayColor].CGColor;
}

- (void)textWillChange:(id<UITextInput>)textInput {
    // The app is about to change the document's contents. Perform any preparation here.
}

- (void)textDidChange:(id<UITextInput>)textInput {
    // The app has just changed the document's contents, the document context has been updated.
    
    if (self.textDocumentProxy.keyboardAppearance == UIKeyboardAppearanceDark) {
        [self configColors:[UIColor whiteColor]];
    } else {
        [self configColors:[UIColor blackColor]];
    }
}

- (void)buttonBackwardTapped:(id)sender{
    [self.textDocumentProxy deleteBackward];
}

- (void)buttonTinyKeyboardTapped:(id)sender{
    
    if (self.tinyView) {
        [self.tinyView removeFromSuperview];
        self.tinyView = nil;
        self.contentView.hidden = NO;
    } else {
        self.tinyView = [[TinyKeyboardView alloc] init];
        self.tinyView.delegate = self;
        [self.view addSubview:self.tinyView];
        [self.tinyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
        self.contentView.hidden = YES;
    }
}

- (void)buttonReturnTapped:(id)sender{
    [self.textDocumentProxy insertText:@"\n"];
}

- (void)showStatusText:(NSString*)text {
    if(pthread_main_np()){
        self.textLabel.text = text;
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.textLabel.text = text;
        });
    }
}

- (void)TinyKeyboardView:(TinyKeyboardView *)keyboardView characterTapped:(NSString *)character{
    [self.textDocumentProxy insertText:character];
}

- (NSArray<NSString*>*)splitIntoChars:(NSString*)str {
    NSMutableArray<NSString*> *chars = [[NSMutableArray alloc]initWithCapacity:10];
    
    for (NSUInteger idx = 0; idx < str.length; ++idx) {
        NSString *cur = [str substringWithRange:NSMakeRange(idx, 1)];
        [chars addObject:cur];
    }
    
    return chars;
}

- (void)buttonInputTapped:(id)sender{
    if(self.pasteboardString.length == 0){
        return;
    }
    
    NSArray<NSString*> *chars = [self splitIntoChars:self.pasteboardString];
    
    if(self.delayAction){
        self.delayAction.stopped = YES;
        self.delayAction = nil;
    }
    
    self.delayAction = [[ForEachWithRandomDelay alloc]init];
    self.delayAction.items = chars;
    
    __weak typeof(self) wself = self;
    self.delayAction.action = ^(NSString* str) {
        [wself.textDocumentProxy insertText:str];
    };
    self.delayAction.onProgress = ^(float progress) {
        if (progress == 1.0) {
            [wself.progressView setProgress:progress animated:YES];
        } else if (progress == 0.0) {
            [wself.progressView setProgress:progress animated:YES];
        } else {
            if (progress - wself.progressView.progress >= 0.01) {
                [wself.progressView setProgress:progress animated:NO];
            }
        }
    };
    
    [self.delayAction forEach];
}


@end
