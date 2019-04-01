//
//  FYMarqueeView.m
//  FYMarqueeView
//
//  Created by admin on 2019/4/1.
//  Copyright © 2019 admin. All rights reserved.
//

#import "FYMarqueeView.h"

@interface FYMarqueeView ()

@property (nonatomic, strong) UIView *textContainerView;
@property (nonatomic, strong) CAGradientLayer *leftGradientMask;
@property (nonatomic, strong) CAGradientLayer *rightGradientMask;
@property (nonatomic, weak) CADisplayLink *displayLink;

@property (nonatomic, strong) NSMutableArray <UILabel *> *onScreenTextLabels;
@property (nonatomic, strong) NSMutableArray <UILabel *> *offScreenTextLabels;

@property (nonatomic, assign, readonly) BOOL isPaused;
@property (nonatomic, assign, readonly) BOOL isRunning;
@property (nonatomic, assign, readonly) BOOL isStopped;

@property (nonatomic, assign) NSInteger nextIndex;

@end

@implementation FYMarqueeView

- (void)dealloc {
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self _setUp];
    return self;
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    if (newWindow == nil) {
        [self pauseDisplayLink];
    } else if (self.isRunning) {
        [self resumeDisplayLink];
    }
}

#pragma mark - setter
- (void)setFrame:(CGRect)frame {
    CGSize oldSize = self.bounds.size;
    [super setFrame:frame];
    CGSize newSize = self.bounds.size;
    if (!CGSizeEqualToSize(oldSize, newSize)) {
        [self _layoutView];
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    [self adjustGradientMaskColor];
}

- (void)setTextList:(NSArray<NSString *> *)textList {
    _textList = textList;
    [self stop];
    [self resetIndex];
}

- (void)setTextFont:(UIFont *)textFont {
    _textFont = textFont;
    if (!self.isStopped) {
        return;
    }
    [self adjustTextSizeAndFont];
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    if (!self.isStopped) {
        return;
    }
    [self adjustTextSizeAndFont];
}

- (void)setFadeWidth:(CGFloat)fadeWidth {
    _fadeWidth = fadeWidth;
    [self _layoutGradientMasks];
    CGColorRef color = self.backgroundColor.CGColor;
    [self setGradientMaskLayerHidden:CGColorGetAlpha(color) <= 0 || self.fadeWidth <= 0];
}

- (void)setTextSpacing:(CGFloat)textSpacing {
    if (self.isStopped) {
        _textSpacing = textSpacing;
    }
}

- (void)setTextScrollSpeed:(CGFloat)textScrollSpeed {
    if (self.isStopped) {
        _textScrollSpeed = textScrollSpeed;
    }
}

#pragma mark - public methods
- (void)stop {
    if (self.isStopped) {
        return;
    }
    [self reset];
    self.state = FYMarqueeStateStopped;
}

- (void)run {
    if (self.isRunning || self.textList.count == 0) {
        return;
    }
    if (self.state == FYMarqueeStateStopped) {
        [self addOnScreentTextLabel];
    }
    if (self.window != nil) {
        [self resumeDisplayLink];
    }
    self.state = FYMarqueeStateRunning;
}

- (void)pause {
    if (!self.isRunning) {
        return;
    }
    [self pauseDisplayLink];
    self.state = FYMarqueeStatePaused;
}

- (BOOL)isRunning {
    return self.state == FYMarqueeStateRunning;
}

- (BOOL)isPaused {
    return self.state == FYMarqueeStatePaused;
}

- (BOOL)isStopped {
    return self.state == FYMarqueeStateStopped;
}

#pragma mark - layout
- (void)_layoutView {
    [self _layoutTextContainerView];
    [self _layoutGradientMasks];
    [self _layoutOnScreentTextLabels];
}

- (void)_layoutTextContainerView {
    self.textContainerView.frame = self.bounds;
}

- (void)_layoutGradientMasks {
    self.leftGradientMask.frame = CGRectMake(0, 0, _fadeWidth, self.bounds.size.height);
    self.rightGradientMask.frame = CGRectMake(CGRectGetMaxX(self.bounds) - _fadeWidth, 0, _fadeWidth, self.bounds.size.height);
}

- (void)_layoutOnScreentTextLabels {
    for (UILabel *label in self.onScreenTextLabels) {
        CGPoint originCenter = label.center;
        originCenter.y = CGRectGetMidY(self.textContainerView.bounds);
        label.center = originCenter;
    }
}

#pragma mark - DisplayLink
- (void)resumeDisplayLink {
    if (!_displayLink) {
        CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateTextOffset:)];
        [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        self.displayLink = displayLink;
    }
    self.displayLink.paused = NO;
}

- (void)pauseDisplayLink {
    self.displayLink.paused = YES;
}

- (void)invalidateDisplayLink {
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (void)updateTextOffset:(CADisplayLink *)displayLink {
    CGFloat originXOffset = self.textScrollSpeed * displayLink.duration;
    CGRect originBounds = self.textContainerView.bounds;
    originBounds.origin.x += originXOffset;
    self.textContainerView.bounds = originBounds;
    UILabel *firstLabel = self.onScreenTextLabels.firstObject;
    
    if (CGRectGetMaxX(firstLabel.frame) <= self.textContainerView.bounds.origin.x) {
        //第一个文本完全移出屏幕
        [self removeOffScreentTextLabel];
    }

    UILabel *lastLabel = self.onScreenTextLabels.lastObject;
    if (CGRectGetMaxX(self.textContainerView.bounds) - CGRectGetMaxX(lastLabel.frame) >= self.textSpacing) {
        //最后一个文本刚出现
        [self addOnScreentTextLabel];
    }
}

#pragma mark - private methods
- (void)addOnScreentTextLabel {
    NSInteger currentIndex = self.nextIndex;
    [self increasedIndex];
    
    UILabel *label = [self dequeueResuableTextLabel];
    label.text = self.textList[currentIndex];
    [label sizeToFit];
    CGPoint originalCenter = label.center;
    originalCenter.y = self.textContainerView.frame.size.height/2;
    label.center = originalCenter;
    CGRect originFrame = label.frame;
    
    if (self.onScreenTextLabels.count) {
        UILabel *lastLabel = self.onScreenTextLabels.lastObject;
        originFrame.origin.x = CGRectGetMaxX(lastLabel.frame) + _textSpacing;
    }else {
        originFrame.origin.x = 0;
    }
    label.frame = originFrame;
    
    [self.onScreenTextLabels addObject:label];
    [self.textContainerView addSubview:label];
}

- (void)removeOffScreentTextLabel {
    UILabel *label = self.onScreenTextLabels.firstObject;
    [self.onScreenTextLabels removeObjectAtIndex:0];
    [label removeFromSuperview];
    [self recycle:label];
}

- (void)recycle:(UILabel *)label {
    [self.offScreenTextLabels addObject:label];
}

- (UILabel *)dequeueResuableTextLabel {
    UILabel *label = [self.offScreenTextLabels lastObject];
    [self.offScreenTextLabels removeLastObject];
    if (label) {
        return label;
    }
    label = [UILabel new];
    label.font = self.textFont;
    label.textColor = self.textColor;
    return label;
}

- (void)increasedIndex {
    self.nextIndex = (_nextIndex + 1) % self.textList.count;
}

- (void)resetIndex {
    self.nextIndex = _textList.count == 0 ? NSNotFound : 0;
}

- (void)reset {
    [self resetIndex];
    [self pauseDisplayLink];
    [self clearOnScreenTextLabels];
    CGRect currentBounds = self.textContainerView.bounds;
    currentBounds.origin = CGPointZero;
    self.textContainerView.bounds = currentBounds;
}

- (void)clearOnScreenTextLabels {
    [self.onScreenTextLabels enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
        [self recycle:obj];
    }];
    [self.onScreenTextLabels removeAllObjects];
}

#pragma mark - adaptor
- (void)adjustGradientMaskColor {
    CGColorRef startColor = self.backgroundColor.CGColor;
    if (CGColorGetAlpha(startColor) <= 0) {
        [self setGradientMaskLayerHidden:YES];
        return;
    }
    CGColorRef endColor = CGColorCreateCopyWithAlpha(startColor, 0.0);
    
    self.leftGradientMask.hidden = self.fadeWidth <= 0;
    self.rightGradientMask.hidden = self.fadeWidth <= 0;
    self.leftGradientMask.colors = @[(__bridge id)startColor, (__bridge id)endColor];
    self.rightGradientMask.colors = @[(__bridge id)endColor, (__bridge id)startColor];
}

- (void)adjustTextSizeAndFont {
    for (UILabel *label in self.onScreenTextLabels) {
        label.font = self.textFont;
        label.textColor = self.textColor;
    }
    for (UILabel *label in self.offScreenTextLabels) {
        label.font = self.textFont;
        label.textColor = self.textColor;
    }
}

- (void)setGradientMaskLayerHidden:(BOOL)hidden {
    self.leftGradientMask.hidden = hidden;
    self.rightGradientMask.hidden = hidden;
}

#pragma mark - set up
- (void)_setUp {
    self.fadeWidth = 15;
    self.state = FYMarqueeStateStopped;
    self.textScrollSpeed = 50;
    self.textSpacing = 40;
    self.nextIndex = NSNotFound;
    self.textFont = [UIFont systemFontOfSize:15];
    self.textColor = [UIColor blackColor];
    
    self.textContainerView = [UIView new];
    self.textContainerView.frame = self.bounds;
    self.textContainerView.clipsToBounds = YES;
    [self addSubview:self.textContainerView];
    
    self.leftGradientMask = [CAGradientLayer layer];
    self.rightGradientMask = [CAGradientLayer layer];
    [self _layoutView];

    _leftGradientMask.startPoint = CGPointMake(0, 0.5);
    _leftGradientMask.endPoint = CGPointMake(1, 0.5);
    [self.layer addSublayer:_leftGradientMask];

    _rightGradientMask.startPoint = CGPointMake(0, 0.5);
    _rightGradientMask.endPoint = CGPointMake(1, 0.5);
    [self.layer addSublayer:_rightGradientMask];
    
    [self adjustGradientMaskColor];
}

- (NSMutableArray<UILabel *> *)onScreenTextLabels {
    if (!_onScreenTextLabels) {
        _onScreenTextLabels = [NSMutableArray array];
    }
    return _onScreenTextLabels;
}

- (NSMutableArray<UILabel *> *)offScreenTextLabels {
    if (!_offScreenTextLabels) {
        _offScreenTextLabels = [NSMutableArray array];
    }
    return _offScreenTextLabels;
}

@end
