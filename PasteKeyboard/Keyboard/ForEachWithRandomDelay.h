//
//  ForEachWithRandomDelay.h
//  Keyboard
//
//  Created by everettjf on 2019/5/15.
//  Copyright © 2019 everettjf. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ForEachWithRandomDelay : NSObject
@property (nonatomic,strong) NSArray<NSString*>* items;
@property (nonatomic,strong) void (^action)(NSString*);
@property (nonatomic,assign) BOOL stopped;

- (void)forEach;

@end

NS_ASSUME_NONNULL_END
