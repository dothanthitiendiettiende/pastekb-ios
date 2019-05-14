//
//  ForEachWithRandomDelay.m
//  Keyboard
//
//  Created by everettjf on 2019/5/15.
//  Copyright © 2019 everettjf. All rights reserved.
//

#import "ForEachWithRandomDelay.h"

@interface ForEachWithRandomDelay ()
@property (nonatomic,assign) NSUInteger currentIndex;
@end

@implementation ForEachWithRandomDelay

- (void)forEach{
    self.currentIndex = 0;
    [self next];
}

- (void)next{
    
    double delayMs = 50+ arc4random() % 100;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayMs/1000 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(self.stopped){
            return;
        }
        
        if(self.currentIndex >= self.items.count){
            return;
        }
        
        self.action(self.items[self.currentIndex]);
        self.currentIndex += 1;
        
        [self next];
    });
}

@end
