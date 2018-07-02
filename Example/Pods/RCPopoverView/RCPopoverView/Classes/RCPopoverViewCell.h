//
//  RCPopoverViewCell.h
//  RCExtension
//
//  Created by dow-np-162 on 2018/6/28.
//  Copyright © 2018年 rc.com.ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCPopoverAction.h"

UIKIT_EXTERN float const RCPopoverViewCellHorizontalMargin;   ///< 水平间距边距
UIKIT_EXTERN float const RCPopoverViewCellVerticalMargin;     ///< 垂直边距
UIKIT_EXTERN float const RCPopoverViewCellTitleLeftEdge;      ///< 标题左边边距

@interface RCPopoverViewCell : UITableViewCell

@property (nonatomic, assign) RCPopoverViewStyle style;

/*
 ! @brief 标题字体
 */
+ (UIFont *)titleFont;

/*
 ! @brief 底部线条颜色
 */
+ (UIColor *)bottomLineColorForStyle:(RCPopoverViewStyle)style;

- (void)setAction:(RCPopoverAction *)action;

@end

