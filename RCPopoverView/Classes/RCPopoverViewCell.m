//
//  RCPopoverViewCell.m
//  RCExtension
//
//  Created by dow-np-162 on 2018/6/28.
//  Copyright © 2018年 rc.com.ltd. All rights reserved.
//

#import "RCPopoverViewCell.h"

// extern
float const RCPopoverViewCellHorizontalMargin = 15.f;     ///< 水平边距
float const RCPopoverViewCellVerticalMargin = 3.f;        ///< 垂直边距
float const RCPopoverViewCellTitleLeftEdge = 20.f;        ///< 标题左边边距


@interface RCPopoverViewCell()

@property (nonatomic, strong) UIButton *button;

@end

@implementation RCPopoverViewCell

#pragma mark - Life Cycle
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = self.backgroundColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self initialize];
    return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        self.backgroundColor = _style == RCPopoverViewStyleDefault ? [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.00] : [UIColor colorWithRed:0.23 green:0.23 blue:0.23 alpha:1.00];
    } else {
        [UIView animateWithDuration:0.3f animations:^{
            self.backgroundColor = [UIColor clearColor];
        }];
    }
}

#pragma mark - Setter
- (void)setStyle:(RCPopoverViewStyle)style {
    _style = style;
    if (_style == RCPopoverViewStyleDefault) {
        [_button setTitleColor:[UIColor colorWithRed:0.33 green:0.33 blue:0.33 alpha:1.00] forState:UIControlStateNormal];
    } else {
        [_button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    }
}

#pragma mark - Private
// 初始化
- (void)initialize {
    // UI
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.userInteractionEnabled = NO; // has no use for UserInteraction.
    _button.translatesAutoresizingMaskIntoConstraints = NO;
    _button.titleLabel.font = [self.class titleFont];
    _button.backgroundColor = self.contentView.backgroundColor;
    _button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_button setTitleColor:[UIColor colorWithRed:54/255.0 green:54/255.0 blue:54/255.0 alpha:1] forState:UIControlStateNormal];
    [self.contentView addSubview:_button];
    // Constraint
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[_button]-margin-|" options:kNilOptions metrics:@{@"margin" : @(RCPopoverViewCellHorizontalMargin)} views:NSDictionaryOfVariableBindings(_button)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[_button]-margin-|" options:kNilOptions metrics:@{@"margin" : @(RCPopoverViewCellVerticalMargin)} views:NSDictionaryOfVariableBindings(_button)]];
}

#pragma mark - Public
/*! @brief 标题字体 */
+ (UIFont *)titleFont {
    return [UIFont systemFontOfSize:14.f];
}

/*! @brief 底部线条颜色 */
+ (UIColor *)bottomLineColorForStyle:(RCPopoverViewStyle)style {
    return style == RCPopoverViewStyleDefault ? [UIColor colorWithRed:0.91 green:0.93 blue:0.94 alpha:1.00] : [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.00];
}

- (void)setAction:(RCPopoverAction *)action {
    [_button setImage:action.image forState:UIControlStateNormal];
    [_button setTitle:action.title forState:UIControlStateNormal];
    _button.titleEdgeInsets = action.image ? UIEdgeInsetsMake(0, RCPopoverViewCellTitleLeftEdge, 0, -RCPopoverViewCellTitleLeftEdge) : UIEdgeInsetsZero;
}

@end
