//
//  RCPopoverView.h
//  RCExtension
//
//  Created by dow-np-162 on 2018/6/28.
//  Copyright © 2018年 rc.com.ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCPopoverAction.h"

// 弹窗箭头的样式
typedef NS_ENUM(NSUInteger, RCPopoverViewArrowStyle) {
    RCPopoverViewArrowStyleRound = 0, // 圆角
    RCPopoverViewArrowStyleTriangle   // 菱角
};

// 菜单边界样式
typedef NS_ENUM(NSUInteger, RCPopoverViewBorderStyle) {
    RCPopoverViewBorderStyleDark = 0, // 半透明背景
    RCPopoverViewBorderStyleBoarder,  // 边界
    RCPopoverViewBorderStyleShadow    // 边框阴影
};


typedef struct RCPopoverShadow {
    CGFloat   shadowOpacity;
    CGFloat   shadowRadius;
    CGSize    shadowOffset;
}RCPopoverShadow;

@interface RCPopoverView : UIView

/**
 是否开启点击外部隐藏弹窗, 默认为YES.
 */
@property (nonatomic, assign) BOOL hideAfterTouchOutside;

/**
 弹出窗风格, 默认为 RCPopoverViewStyleDefault(白色).
 */
@property (nonatomic, assign) RCPopoverViewStyle style;

/**
 菜单边框圆角
 */
@property (nonatomic, assign) CGFloat cornerRadius;

/**
 箭头宽度
 */
@property (nonatomic, assign) CGFloat arrowWidth;

/**
 箭头高度
 */
@property (nonatomic, assign) CGFloat arrowHeight;

/**
 菜单高度
 */
@property (nonatomic, assign) CGFloat itemHeight;

/**
 箭头样式, 默认为 RCPopoverViewArrowStyleRound.  如果要修改箭头的样式, 需要在显示先设置.
 */
@property (nonatomic, assign) RCPopoverViewArrowStyle arrowStyle;

/**  以下属性对 非 RCPopoverViewStyleDark 有效 */
/**
 菜单框样式 背景蒙版/实线边框/边界阴影
 */
@property (nonatomic, assign) RCPopoverViewBorderStyle borderStyle;

/**
 阴影参数
 */
@property (nonatomic, assign) RCPopoverShadow  shadowParam;

/**
 阴影颜色
 */
@property (nonatomic, strong) UIColor *shadowColor;

/**
 分割线颜色
 */
@property (nonatomic, strong) UIColor *separatorColor;

/**
 分割线左边距
 */
@property (nonatomic, assign) CGFloat separatorLeftMargin;

/**
 实例
 */
+ (instancetype)popoverView;

/**
 指向指定的View来显示弹窗
 
 @param pointView 箭头指向的View
 @param actions 动作对象集合<PopoverAction>
 */
- (void)showToView:(UIView *)pointView withActions:(NSArray<RCPopoverAction *> *)actions;

/**
 指向指定的点来显示弹窗
 @param toPoint 箭头指向的点(这个点的坐标需按照keyWindow的坐标为参照)
 @param actions 动作对象集合<PopoverAction>
 */
- (void)showToPoint:(CGPoint)toPoint withActions:(NSArray<RCPopoverAction *> *)actions;

@end
