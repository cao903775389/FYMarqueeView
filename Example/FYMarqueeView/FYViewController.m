//
//  FYViewController.m
//  FYMarqueeView
//
//  Created by fengyangcao on 04/01/2019.
//  Copyright (c) 2019 fengyangcao. All rights reserved.
//

#import "FYViewController.h"
#import <FYMarqueeView/FYMarqueeView.h>

@interface FYViewController ()

@property (nonatomic, strong) FYMarqueeView *marqueeView;

@end

@implementation FYViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.marqueeView = [[FYMarqueeView alloc] initWithFrame:CGRectMake(10, 100, [UIScreen mainScreen].bounds.size.width - 20, 30)];
    [self.view addSubview:self.marqueeView];
    
    self.marqueeView.textColor = [UIColor whiteColor];
    self.marqueeView.fadeWidth = 30;
    self.marqueeView.textSpacing = 100;
    self.marqueeView.textScrollSpeed = 100;
    self.marqueeView.backgroundColor = [UIColor blackColor];
    self.marqueeView.textList = @[@"第一条消息", @"第二条消息", @"第三条消息", @"第四条消息", @"第五条消息", @"第六条消息", @"d最后一条消息"];
    
    [self.marqueeView run];
    
    
    UIButton *pause = [UIButton buttonWithType:UIButtonTypeCustom];
    [pause setTitle:@"暂停" forState:UIControlStateNormal];
    [pause setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    pause.backgroundColor = [UIColor greenColor];
    [pause addTarget:self action:@selector(pause) forControlEvents:UIControlEventTouchUpInside];
    pause.frame = CGRectMake(10, self.view.frame.size.height - 50, 40, 40);
    [self.view addSubview:pause];
    
    UIButton *play = [UIButton buttonWithType:UIButtonTypeCustom];
    [play setTitle:@"播放" forState:UIControlStateNormal];
    [play setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    play.backgroundColor = [UIColor greenColor];
    [play addTarget:self action:@selector(resume) forControlEvents:UIControlEventTouchUpInside];
    play.frame = CGRectMake(CGRectGetMaxX(pause.frame) + 10, self.view.frame.size.height - 50, 40, 40);
    [self.view addSubview:play];
    
    UIButton *stop = [UIButton buttonWithType:UIButtonTypeCustom];
    [stop setTitle:@"结束" forState:UIControlStateNormal];
    [stop setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    stop.backgroundColor = [UIColor greenColor];
    [stop addTarget:self action:@selector(stop) forControlEvents:UIControlEventTouchUpInside];
    stop.frame = CGRectMake(CGRectGetMaxX(play.frame) + 10, self.view.frame.size.height - 50, 40, 40);
    [self.view addSubview:stop];
    
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


- (void)pause {
    [self.marqueeView pause];
}

- (void)resume {
    [self.marqueeView run];
}

- (void)stop {
    [self.marqueeView stop];
}
@end
