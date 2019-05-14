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
    
    self.navigationItem.title = @"Paste Keyboard";
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    NSString *shortVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *buildVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString *appVersion = [NSString stringWithFormat:@"%@.%@",shortVersion,buildVersion];
    
    
    __weak typeof(self) wself = self;
    self.groups = @[
                    @{
                        @"title":@"General",
                        @"rows" : @[
                                @{
                                    @"title":@"User Guide",
                                    @"action":^(){
                                        [wself openInBrowser:@"https://pastekeyboard.github.io"];
                                    },
                                    },
                                ]
                        },
                    @{
                        @"title":@"Feedback",
                        @"rows" : @[
                                @{
                                    @"title":@"Email",
                                    @"action":^(){
                                        [wself openURL:@"mailto://everettjf@live.com"];
                                    },
                                    },
                                ]
                        },
                    @{
                        @"title":@"Author",
                        @"rows" : @[
                                @{
                                    @"title":@"Twitter",
                                    @"action":^(){
                                        [wself openInBrowser:@"https://twitter.com/everettjf"];
                                    },
                                    },
                                @{
                                    @"title":@"Weibo",
                                    @"action":^(){
                                        [wself openInBrowser:@"https://weibo.com/everettjf"];
                                    },
                                    },
                                @{
                                    @"title":@"Blog",
                                    @"action":^(){
                                        [wself openInBrowser:@"https://everettjf.github.io"];
                                    },
                                    },
                                ]
                        },
                    @{
                        @"title":@"More",
                        @"rows" : @[
                                @{
                                    @"title":[NSString stringWithFormat:@"Version : %@",appVersion],
                                    @"action":^(){
                                    },
                                    },
                                ]
                        },
                    ];
}


@end
