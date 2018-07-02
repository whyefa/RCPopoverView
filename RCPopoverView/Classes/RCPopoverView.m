//
//  RCPopoverView.m
//  RCExtension
//
//  Created by dow-np-162 on 2018/6/28.
//  Copyright © 2018年 rc.com.ltd. All rights reserved.
//

#import "RCPopoverView.h"
#import "RCPopoverViewCell.h"

static CGFloat const kPopoverViewMargin = 8.f;        ///< 边距
static CGFloat const kRCPopoverViewCellHeight = 40.f;   ///< cell指定高度
static CGFloat const kRCPopoverViewArrowHeight = 10.f;  ///< 箭头高度

static NSString *kPopoverCellReuseId = @"_RCPopoverCellReuseId";

float RCPopoverViewDegreesToRadians(float angle)
{
    return angle*M_PI/180;
}

@interface RCPopoverView () <UITableViewDelegate, UITableViewDataSource>

#pragma mark - UI
@property (nonatomic, weak)     UIWindow *keyWindow;                ///< 当前窗口
@property (nonatomic, strong)   UITableView *tableView;
@property (nonatomic, strong)   UIView *shadeView;                ///< 遮罩层
@property (nonatomic, weak)     CAShapeLayer *borderLayer;          ///< 边框Layer
@property (nonatomic, weak)     UITapGestureRecognizer *tapGesture; ///< 点击背景阴影的手势

#pragma mark - Data
@property (nonatomic, copy)     NSArray<RCPopoverAction *> *actions;
@property (nonatomic, assign)   CGFloat windowWidth;   ///< 窗口宽度
@property (nonatomic, assign)   CGFloat windowHeight;  ///< 窗口高度
@property (nonatomic, assign)   BOOL isUpward;         ///< 箭头指向, YES为向上, 反之为向下, 默认为YES.

@end

@implementation RCPopoverView

#pragma mark - Lift Cycle
- (instancetype)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame])) return nil;
    [self initialize];
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _tableView.frame = CGRectMake(0, _isUpward ? _arrowHeight : 0,
                                  CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - _arrowHeight);
}

#pragma mark - init
+ (instancetype)popoverView {
    return [[self alloc] init];
}

/*
 ! @brief 初始化相关
 */
- (void)initialize {
    _actions = @[];
    _isUpward = YES;
    _style = RCPopoverViewStyleDefault;
    _arrowStyle = RCPopoverViewArrowStyleRound;
    self.backgroundColor = [UIColor whiteColor];
    _keyWindow = [UIApplication sharedApplication].keyWindow;
    _windowWidth = CGRectGetWidth(_keyWindow.bounds);
    _windowHeight = CGRectGetHeight(_keyWindow.bounds);
    _shadeView = [[UIView alloc] initWithFrame:_keyWindow.bounds];
    _borderStyle = RCPopoverViewBorderStyleDark;
    _separatorLeftMargin = 15;
    _shadowParam = (RCPopoverShadow){0.2, 2, CGSizeZero};
    _shadowColor = [UIColor colorWithWhite:0 alpha:0.5];
    _arrowWidth = 18;
    _arrowHeight = kRCPopoverViewArrowHeight;
    _cornerRadius = 3.f;
    _itemHeight = kRCPopoverViewCellHeight;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [_shadeView addGestureRecognizer:tapGesture];
    _tapGesture = tapGesture;
    [self addSubview:self.tableView];
}

#pragma mark- private
/**
 显示弹窗指向某个点
 */
- (void)showToPoint:(CGPoint)toPoint {
    if (self.separatorColor) {
        self.tableView.separatorColor = self.separatorColor;
    }
    // 截取弹窗时相关数据
    CGFloat arrowWidth = _arrowWidth;
    CGFloat cornerRadius = _cornerRadius;
    CGFloat arrowCornerRadius = 2.5f;
    CGFloat arrowBottomCornerRadius = 4.f;
    
    // 如果是菱角箭头的话, 箭头宽度需要小点.
    if (_arrowStyle == RCPopoverViewArrowStyleTriangle) {
        arrowWidth = 18.0;
    }
    
    // 如果箭头指向的点过于偏左或者过于偏右则需要重新调整箭头 x 轴的坐标
    CGFloat minHorizontalEdge = kPopoverViewMargin + cornerRadius + arrowWidth/2 + 2;
    if (toPoint.x < minHorizontalEdge) {
        toPoint.x = minHorizontalEdge;
    }
    if (_windowWidth - toPoint.x < minHorizontalEdge) {
        toPoint.x = _windowWidth - minHorizontalEdge;
    }
    
    // 遮罩层
    _shadeView.alpha = 0.f;
    [_keyWindow addSubview:_shadeView];
    
    // 刷新数据以获取具体的ContentSize
    [_tableView reloadData];
    // 根据刷新后的ContentSize和箭头指向方向来设置当前视图的frame
    CGFloat currentW = [self calculateMaxWidth]; // 宽度通过计算获取最大值
    CGFloat currentH = _tableView.contentSize.height;
    
    // 如果 actions 为空则使用默认的宽高
    if (_actions.count == 0) {
        currentW = 150.0;
        currentH = 20.0;
    }
    
    // 箭头高度
    currentH += _arrowHeight;
    
    // 限制最高高度, 免得选项太多时超出屏幕
    CGFloat maxHeight = _isUpward ? (_windowHeight - toPoint.y - kPopoverViewMargin) : (toPoint.y - CGRectGetHeight([UIApplication sharedApplication].statusBarFrame));
    if (currentH > maxHeight) { // 如果弹窗高度大于最大高度的话则限制弹窗高度等于最大高度并允许tableView滑动.
        currentH = maxHeight;
        _tableView.scrollEnabled = YES;
        if (!_isUpward) { // 箭头指向下则移动到最后一行
            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_actions.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    }
    
    CGFloat currentX = toPoint.x - currentW/2, currentY = toPoint.y;
    // x: 窗口靠左
    if (toPoint.x <= currentW/2 + kPopoverViewMargin) {
        currentX = kPopoverViewMargin;
    }
    // x: 窗口靠右
    if (_windowWidth - toPoint.x <= currentW/2 + kPopoverViewMargin) {
        currentX = _windowWidth - kPopoverViewMargin - currentW;
    }
    // y: 箭头向下
    if (!_isUpward) {
        currentY = toPoint.y - currentH;
    }
    
    self.frame = CGRectMake(currentX, currentY, currentW, currentH);
    
    // 截取箭头
    CGPoint arrowPoint = CGPointMake(toPoint.x - CGRectGetMinX(self.frame), _isUpward ? 0 : currentH); // 箭头顶点在当前视图的坐标
    CGFloat maskTop = _isUpward ? _arrowHeight : 0; // 顶部Y值
    CGFloat maskBottom = _isUpward ? currentH : currentH - _arrowHeight; // 底部Y值
    UIBezierPath *maskPath = [UIBezierPath bezierPath];
    // 左上圆角
    [maskPath moveToPoint:CGPointMake(0, cornerRadius + maskTop)];
    [maskPath addArcWithCenter:CGPointMake(cornerRadius, cornerRadius + maskTop)
                        radius:cornerRadius
                    startAngle:RCPopoverViewDegreesToRadians(180)
                      endAngle:RCPopoverViewDegreesToRadians(270)
                     clockwise:YES];
    // 箭头向上时的箭头位置
    if (_isUpward) {
        [maskPath addLineToPoint:CGPointMake(arrowPoint.x - arrowWidth/2, _arrowHeight)];
        // 菱角箭头
        if (_arrowStyle == RCPopoverViewArrowStyleTriangle) {
            [maskPath addLineToPoint:arrowPoint];
            [maskPath addLineToPoint:CGPointMake(arrowPoint.x + arrowWidth/2, _arrowHeight)];
        }
        else {
            
            [maskPath addQuadCurveToPoint:CGPointMake(arrowPoint.x - arrowCornerRadius, arrowCornerRadius)
                             controlPoint:CGPointMake(arrowPoint.x - arrowWidth/2 + arrowBottomCornerRadius, _arrowHeight)];
            [maskPath addQuadCurveToPoint:CGPointMake(arrowPoint.x + arrowCornerRadius, arrowCornerRadius)
                             controlPoint:arrowPoint];
            [maskPath addQuadCurveToPoint:CGPointMake(arrowPoint.x + arrowWidth/2, _arrowHeight)
                             controlPoint:CGPointMake(arrowPoint.x + arrowWidth/2 - arrowBottomCornerRadius, _arrowHeight)];
        }
    }
    // 右上圆角
    [maskPath addLineToPoint:CGPointMake(currentW - cornerRadius, maskTop)];
    [maskPath addArcWithCenter:CGPointMake(currentW - cornerRadius, maskTop + cornerRadius)
                        radius:cornerRadius
                    startAngle:RCPopoverViewDegreesToRadians(270)
                      endAngle:RCPopoverViewDegreesToRadians(0)
                     clockwise:YES];
    // 右下圆角
    [maskPath addLineToPoint:CGPointMake(currentW, maskBottom - cornerRadius)];
    [maskPath addArcWithCenter:CGPointMake(currentW - cornerRadius, maskBottom - cornerRadius)
                        radius:cornerRadius
                    startAngle:RCPopoverViewDegreesToRadians(0)
                      endAngle:RCPopoverViewDegreesToRadians(90)
                     clockwise:YES];
    // 箭头向下时的箭头位置
    if (!_isUpward) {
        [maskPath addLineToPoint:CGPointMake(arrowPoint.x + arrowWidth/2, currentH - _arrowHeight)];
        // 菱角箭头
        if (_arrowStyle == RCPopoverViewArrowStyleTriangle) {
            [maskPath addLineToPoint:arrowPoint];
            [maskPath addLineToPoint:CGPointMake(arrowPoint.x - arrowWidth/2, currentH - _arrowHeight)];
        }
        else {
            [maskPath addQuadCurveToPoint:CGPointMake(arrowPoint.x + arrowCornerRadius, currentH - arrowCornerRadius)
                             controlPoint:CGPointMake(arrowPoint.x + arrowWidth/2 - arrowBottomCornerRadius, currentH - _arrowHeight)];
            [maskPath addQuadCurveToPoint:CGPointMake(arrowPoint.x - arrowCornerRadius, currentH - arrowCornerRadius)
                             controlPoint:arrowPoint];
            [maskPath addQuadCurveToPoint:CGPointMake(arrowPoint.x - arrowWidth/2, currentH - _arrowHeight)
                             controlPoint:CGPointMake(arrowPoint.x - arrowWidth/2 + arrowBottomCornerRadius, currentH - _arrowHeight)];
        }
    }
    // 左下圆角
    [maskPath addLineToPoint:CGPointMake(cornerRadius, maskBottom)];
    [maskPath addArcWithCenter:CGPointMake(cornerRadius, maskBottom - cornerRadius)
                        radius:cornerRadius
                    startAngle:RCPopoverViewDegreesToRadians(90)
                      endAngle:RCPopoverViewDegreesToRadians(180)
                     clockwise:YES];
    [maskPath closePath];
    // 截取圆角和箭头
    if (self.borderStyle == RCPopoverViewBorderStyleDark || self.style == RCPopoverViewStyleDark) {
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = self.bounds;
        maskLayer.path = maskPath.CGPath;
        self.layer.mask = maskLayer;
    } else {
        // 边框样式
        if (self.borderStyle == RCPopoverViewBorderStyleBoarder) {
            self.layer.backgroundColor = UIColor.clearColor.CGColor;
            CAShapeLayer *borderLayer = [CAShapeLayer layer];
            borderLayer.frame = self.bounds;
            borderLayer.path = maskPath.CGPath;
            borderLayer.lineWidth = 1;
            borderLayer.fillColor = [UIColor whiteColor].CGColor;
            borderLayer.strokeColor = self.separatorColor.CGColor;
            [self.layer insertSublayer:borderLayer below:self.tableView.layer];
            _borderLayer = borderLayer;
        }
        if (self.borderStyle == RCPopoverViewBorderStyleShadow) {
            self.layer.backgroundColor = UIColor.clearColor.CGColor;
            CAShapeLayer *borderLayer = [CAShapeLayer layer];
            borderLayer.frame = self.bounds;
            borderLayer.path = maskPath.CGPath;
            borderLayer.fillColor = UIColor.whiteColor.CGColor;
            [self.layer insertSublayer:borderLayer below:self.tableView.layer];
            borderLayer.shadowPath = maskPath.CGPath;
            borderLayer.shadowColor = _shadowColor.CGColor;
            borderLayer.shadowOpacity = _shadowParam.shadowOpacity;
            borderLayer.shadowRadius = _shadowParam.shadowRadius;
            borderLayer.shadowOffset = _shadowParam.shadowOffset;
            _borderLayer = borderLayer;
        }
    }
    
    [_keyWindow addSubview:self];
    // 弹出动画
    CGRect oldFrame = self.frame;
    self.layer.anchorPoint = CGPointMake(arrowPoint.x/currentW, _isUpward ? 0.f : 1.f);
    self.frame = oldFrame;
    self.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
    [UIView animateWithDuration:0.25f animations:^{
        self.transform = CGAffineTransformIdentity;
        self->_shadeView.alpha = 1.f;
    }];
}

/*! @brief 计算最大宽度 */
- (CGFloat)calculateMaxWidth {
    CGFloat maxWidth = 0.f, titleLeftEdge = 0.f, imageWidth = 0.f, imageMaxHeight = _itemHeight - RCPopoverViewCellVerticalMargin*2;
    CGSize imageSize = CGSizeZero;
    UIFont *titleFont = [RCPopoverViewCell titleFont];
    
    for (RCPopoverAction *action in _actions) {
        imageWidth = 0.f;
        titleLeftEdge = 0.f;
        if (action.image) { // 存在图片则根据图片size和图片最大高度来重新计算图片宽度
            titleLeftEdge = RCPopoverViewCellTitleLeftEdge; // 有图片时标题才有左边的边距
            imageSize = action.image.size;
            
            if (imageSize.height > imageMaxHeight) {
                
                imageWidth = imageMaxHeight*imageSize.width/imageSize.height;
            }
            else {
                
                imageWidth = imageSize.width;
            }
        }
        
        CGFloat titleWidth;
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) { // iOS7及往后版本
            titleWidth = [action.title sizeWithAttributes:@{NSFontAttributeName : titleFont}].width;
        } else { // iOS6
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
            titleWidth = [action.title sizeWithFont:titleFont].width;
#pragma GCC diagnostic pop
        }
        
        CGFloat contentWidth = RCPopoverViewCellHorizontalMargin*2 + imageWidth + titleLeftEdge + titleWidth;
        if (contentWidth > maxWidth) {
            maxWidth = ceil(contentWidth); // 获取最大宽度时需使用进一取法, 否则Cell中没有图片时会可能导致标题显示不完整.
        }
    }
    
    // 如果最大宽度大于(窗口宽度 - kPopoverViewMargin*2)则限制最大宽度等于(窗口宽度 - kPopoverViewMargin*2)
    if (maxWidth > CGRectGetWidth(_keyWindow.bounds) - kPopoverViewMargin*2) {
        maxWidth = CGRectGetWidth(_keyWindow.bounds) - kPopoverViewMargin*2;
    }
    
    return maxWidth;
}

/**
 点击外部隐藏弹窗
 */
- (void)hide {
    [UIView animateWithDuration:0.25f animations:^{
        self.alpha = 0.f;
        self->_shadeView.alpha = 0.f;
        self.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
    } completion:^(BOOL finished) {
        [self->_shadeView removeFromSuperview];
        [self removeFromSuperview];
    }];
}

#pragma mark - Public
- (void)showToView:(UIView *)pointView withActions:(NSArray<RCPopoverAction *> *)actions {
    // 判断 pointView 是偏上还是偏下
    CGRect pointViewRect = [pointView.superview convertRect:pointView.frame toView:_keyWindow];
    CGFloat pointViewUpLength = CGRectGetMinY(pointViewRect);
    CGFloat pointViewDownLength = _windowHeight - CGRectGetMaxY(pointViewRect);
    // 弹窗箭头指向的点
    CGPoint toPoint = CGPointMake(CGRectGetMidX(pointViewRect), 0);
    // 弹窗在 pointView 顶部
    if (pointViewUpLength > pointViewDownLength) {
        toPoint.y = pointViewUpLength - 5;
    }
    // 弹窗在 pointView 底部
    else {
        toPoint.y = CGRectGetMaxY(pointViewRect) + 5;
    }
    
    // 箭头指向方向
    _isUpward = pointViewUpLength <= pointViewDownLength;
    
    if (!actions) {
        _actions = @[];
    } else {
        _actions = [actions copy];
    }
    
    [self showToPoint:toPoint];
}

- (void)showToPoint:(CGPoint)toPoint withActions:(NSArray<RCPopoverAction *> *)actions {
    if (!actions) {
        _actions = @[];
    } else {
        _actions = [actions copy];
    }
    // 计算箭头指向方向
    _isUpward = toPoint.y <= _windowHeight - toPoint.y;
    [self showToPoint:toPoint];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _actions.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return _itemHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCPopoverViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPopoverCellReuseId];
    cell.style = _style;
    [cell setAction:_actions[indexPath.row]];
    if (indexPath.row == _actions.count-1) {
        cell.separatorInset = UIEdgeInsetsMake(0, self.windowWidth, 0, 0);
    } else {
       cell.separatorInset = UIEdgeInsetsMake(0, self.separatorLeftMargin, 0, 0);
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [UIView animateWithDuration:0.25f animations:^{
        self.alpha = 0.f;
        self->_shadeView.alpha = 0.f;
    } completion:^(BOOL finished) {
        RCPopoverAction *action = self->_actions[indexPath.row];
        action.handler ? action.handler(action) : NULL;
        self->_actions = nil;
        [self->_shadeView removeFromSuperview];
        [self removeFromSuperview];
    }];
}

#pragma mark- getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = NO;
        _tableView.separatorColor = [RCPopoverViewCell bottomLineColorForStyle: RCPopoverViewStyleDefault];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.estimatedRowHeight = 0.0;
        _tableView.showsVerticalScrollIndicator = NO;
        [_tableView registerClass:[RCPopoverViewCell class] forCellReuseIdentifier:kPopoverCellReuseId];
    }
    return _tableView;
}

- (void)setHideAfterTouchOutside:(BOOL)hideAfterTouchOutside {
    _hideAfterTouchOutside = hideAfterTouchOutside;
    _tapGesture.enabled = _hideAfterTouchOutside;
}


- (void)setBorderStyle:(RCPopoverViewBorderStyle)borderStyle {
    _borderStyle = borderStyle;
    if (_borderLayer) {
        _borderLayer.strokeColor = (borderStyle != RCPopoverViewBorderStyleBoarder) ? [UIColor clearColor].CGColor : _tableView.separatorColor.CGColor;
    }
}

- (void)setStyle:(RCPopoverViewStyle)style {
    _style = style;
    _tableView.separatorColor = [RCPopoverViewCell bottomLineColorForStyle:_style];
    _shadeView.backgroundColor = (style == RCPopoverViewStyleDefault) ? [UIColor colorWithWhite:0.f alpha:0.18f] : UIColor.clearColor;
    if (_style == RCPopoverViewStyleDefault) {
        self.backgroundColor = [UIColor whiteColor];
    }
    else {
        self.backgroundColor = [UIColor colorWithRed:0.29 green:0.29 blue:0.29 alpha:1.00];
    }
}

@end

