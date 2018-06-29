//
//  RCPopoverAction.h
//  RCExtension
//
//  Created by dow-np-162 on 2018/6/28.
//  Copyright © 2018年 rc.com.ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, RCPopoverViewStyle) {
    RCPopoverViewStyleDefault = 0, // 默认风格, 白色
    RCPopoverViewStyleDark,        // 黑色风格
};

@interface RCPopoverAction : NSObject

@property (nonatomic, strong, readonly) UIImage *image; ///< 图标 (建议使用 60pix*60pix 的图片)
@property (nonatomic, copy, readonly)   NSString *title; ///< 标题
@property (nonatomic, copy, readonly)   void(^handler)(RCPopoverAction *action); ///< 选择回调, 该Block不会导致内存泄露, Block内代码无需刻意去设置弱引用.

+ (instancetype)actionWithTitle:(NSString *)title handler:(void (^)(RCPopoverAction *action))handler;

+ (instancetype)actionWithImage:(UIImage *)image title:(NSString *)title handler:(void (^)(RCPopoverAction *action))handler;

@end
