//
//  FYMarqueeView.h
//  FYMarqueeView
//
//  Created by admin on 2019/4/1.
//  Copyright © 2019 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, FYMarqueeState) {
    FYMarqueeStateRunning = 0,
    FYMarqueeStatePaused,
    FYMarqueeStateStopped
};

@interface FYMarqueeView : UIView

@property (nonatomic, assign) FYMarqueeState state;

@property (nonatomic, assign) IB_DESIGNABLE CGFloat fadeWidth; //default 15

@property (nonatomic, strong) IB_DESIGNABLE UIFont *textFont; //default 15

@property (nonatomic, strong) IB_DESIGNABLE UIColor *textColor; //default black

@property (nonatomic, assign) IB_DESIGNABLE CGFloat textScrollSpeed; //default 50pt/s

@property (nonatomic, assign) IB_DESIGNABLE CGFloat textSpacing; //default 40

@property (nonatomic, strong, nullable) NSArray <NSString *> *textList;

- (void)run;
- (void)pause;
- (void)stop;
@end

NS_ASSUME_NONNULL_END
