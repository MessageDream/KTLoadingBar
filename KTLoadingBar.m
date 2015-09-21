//
//  KTLoadingBar.m
//  kt_foundation
//
//  Created by Jayden Zhao on 15/9/21.
//  Copyright © 2015年 xingbin. All rights reserved.
//

#import "KTLoadingBar.h"

@interface KTLoadingBar()
@property (assign,nonatomic) NSInteger activityCount;
@property (assign,nonatomic) BOOL isShown;
@property (strong,nonatomic) NSLayoutConstraint *showConstraint;
+(KTLoadingBar *)shared;
@end

@implementation KTLoadingBar


- (void)setupAnimationInLayer:(CALayer *)layer  tintColor:(UIColor *)tintColor {
    CGFloat rectSpacing = 10.0f;
    CGFloat rectCount = 5;
    CGSize size = CGSizeMake((self.layer.bounds.size.width - (rectCount - 1) * rectSpacing)/rectCount, self.layer.bounds.size.height);
    
    NSTimeInterval beginTime = CACurrentMediaTime();
    
    for (int i = 0; i < rectCount; i++) {
        CAShapeLayer *rect= [CAShapeLayer layer];
        
        rect.backgroundColor = tintColor.CGColor;
        rect.frame = CGRectMake(-(size.width + rectSpacing)/2, 0, size.width, size.height);
        
        CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        transformAnimation.duration = 1.0f;
        transformAnimation.beginTime = beginTime - (i * transformAnimation.duration / rectCount);
        transformAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0.0f, 0.0f, 0.0f)];
        transformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(rectCount * (size.width + rectSpacing), 0.0f, 0.0f)];
        transformAnimation.repeatCount = HUGE_VALF;
        transformAnimation.removedOnCompletion = NO;
        transformAnimation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionLinear];
        
        [layer addSublayer:rect];
        
        [rect addAnimation:transformAnimation forKey:@"animation"];
    }
}

- (void)setupAnimation{
    if (!self.superview && self.view) {
        [self.view addSubview:self];
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.view.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[self(==%g)]",self.height] options:0 metrics:nil views:NSDictionaryOfVariableBindings(self)]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[self]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(self)]];
        
        if (self.position == KTLoadingBarPosition_Top) {
            self.showConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:-self.height];
            [self.view addConstraint:self.showConstraint];
            
            [self setNeedsLayout];
            [self layoutIfNeeded];
            
            self.showConstraint.constant = 0;
        }else if (self.position == KTLoadingBarPosition_Center) {
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
            [self setNeedsLayout];
            [self layoutIfNeeded];
        }else{
            self.showConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:self.height];
            [self.view addConstraint:self.showConstraint];
            [self setNeedsLayout];
            [self layoutIfNeeded];
            
            self.showConstraint.constant = 0;
        }
        
        [self setupAnimationInLayer:self.layer  tintColor:self.rectItemColor];
        
        [self setNeedsLayout];
        [UIView animateWithDuration:0.1 animations:^{
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)startAnimating {
    if (!self.layer.sublayers) {
        self.layer.masksToBounds = YES;
        [self setupAnimation];
    }
    self.layer.speed = 1.0f;
}

- (void)stopAnimating {
    if (self.position == KTLoadingBarPosition_Top) {
        self.showConstraint.constant = -self.height;
    }else if(self.position == KTLoadingBarPosition_Bottom){
        self.showConstraint.constant = self.height;
    }
    
    [self setNeedsLayout];
    
    [UIView animateWithDuration:0.1 animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.isShown = NO;
        self.layer.speed = 0.0f;
        [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
        [self removeFromSuperview];
    }];
}

+(void)initialize{
    if (self != [KTLoadingBar class])
        return;
    
    KTLoadingBar *appearance = [self appearance];
    appearance.rectItemColor = [UIColor colorWithRed:41.f/255.f green:182.f/255.f blue:246.f/255.f alpha:1];
    //    appearance.backgroundColor = [UIColor whiteColor];
    appearance.height = 2.f;
}

+ (KTLoadingBar *)shared {
    static KTLoadingBar *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[self alloc] init];
    });
    
    return _shared;
}

+(void)popActivity{
    [self shared].activityCount -= 1;
    if ([self shared].activityCount == 0) {
        [[self shared] stopAnimating];
    }
}

+(void)dismiss{
    [[self shared] stopAnimating];
    [self shared].activityCount = 0;
}

+(void)showLoadingWith:(UIView *)view atPosition:(KTLoadingBarPosition)position{
    [self shared].activityCount += 1;
    if ([self shared].isShown) {
        return;
    }
    [self shared].view = view;
    [self shared].position = position;
    [self shared].isShown = YES;
    [[self shared] startAnimating];
    
}
@end

