//
//  KTLoadingBar.h
//  kt_foundation
//
//  Created by Jayden Zhao on 15/9/21.
//  Copyright © 2015年 xingbin. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger,KTLoadingBarPosition) {
    KTLoadingBarPosition_Top,
    KTLoadingBarPosition_Center,
    KTLoadingBarPosition_Bottom
};

@interface KTLoadingBar : UIView
@property (weak,nonatomic)UIView *view;
@property (assign,nonatomic)KTLoadingBarPosition position;
@property (strong,nonatomic)UIColor *rectItemColor          UI_APPEARANCE_SELECTOR;
@property (assign,nonatomic)CGFloat height                  UI_APPEARANCE_SELECTOR;;
+ (void)popActivity; 
+ (void)dismiss;
+ (void)showLoadingWith:(UIView *)view atPosition:(KTLoadingBarPosition)position;
@end
