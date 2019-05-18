//
//  ViewController.m
//  PasteKeyboard
//
//  Created by everettjf on 2019/5/14.
//  Copyright © 2019 everettjf. All rights reserved.
//

#import "ViewController.h"
#import <UIView+Toast.h>

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.navigationItem.title = NSLocalizedString(@"Paste Keyboard",nil);
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    NSString *shortVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *buildVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString *appVersion = [NSString stringWithFormat:@"%@.%@",shortVersion,buildVersion];
    
    
    __weak typeof(self) wself = self;
    self.groups = @[
                    @{
                        @"title":NSLocalizedString(@"General", nil),
                        @"rows" : @[
                                @{
                                    @"title":NSLocalizedString(@"User Guide (How To Use)", nil),
                                    @"action":^(){
                                        [wself openInBrowser:@"https://pastekeyboard.github.io"];
                                    },
                                    },
                                @{
                                    @"title":NSLocalizedString(@"Enable Allow Full Access",nil),
                                    @"action":^(){
                                        NSURL *settingUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                        [[UIApplication sharedApplication] openURL:settingUrl options:@{} completionHandler:^(BOOL success) {}];
                                    },
                                    },
                                ]
                        },
                    @{
                        @"title":NSLocalizedString(@"Feedback",nil),
                        @"rows" : @[
                                @{
                                    @"title":NSLocalizedString(@"Email",nil),
                                    @"action":^(){
                                        [wself openURL:@"mailto://everettjf@live.com"];
                                    },
                                    },
                                ]
                        },
                    @{
                        @"title":NSLocalizedString(@"Author",nil),
                        @"rows" : @[
                                @{
                                    @"title":NSLocalizedString(@"Weibo",nil),
                                    @"action":^(){
                                        [wself openInBrowser:@"https://weibo.com/everettjf"];
                                    },
                                    },
                                @{
                                    @"title":NSLocalizedString(@"Follow Wechat",nil),
                                    @"action":^(){
                                        [wself openInBrowser:@"https://everettjf.github.io/bukuzao/"];
                                    },
                                    },
                                @{
                                    @"title":NSLocalizedString(@"Twitter",nil),
                                    @"action":^(){
                                        [wself openInBrowser:@"https://twitter.com/everettjf"];
                                    },
                                    },
                                ]
                        },
                    @{
                        @"title":NSLocalizedString(@"More",nil),
                        @"rows" : @[
                                @{
                                    @"title":[NSString stringWithFormat:@"%@ : %@",NSLocalizedString(@"Version",nil),appVersion],
                                    @"action":^(){
                                    },
                                    },
                                ]
                        },
                    ];
}


@end
