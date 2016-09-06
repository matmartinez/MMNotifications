//
//  MMBannerNotificationView.m
//  SuperPal
//
//  Created by Matías Martínez on 7/23/15.
//  Copyright © 2015 ShopPal. All rights reserved.
//

#import "MMBannerNotificationView.h"
#import "MMLocalNotification.h"
#import "MMNotificationPresentationContext.h"

#import "Private/MMBannerNotificationView_Private.h"
#import "Private/MMBannerNotificationView_Wide.h"
#import "Private/MMBannerNotificationView_Rounded.h"
#import "Private/MMBannerDragableView.h"

@interface MMBannerNotificationView () {
    UIView *_contentView;
    NSArray *_contentContainerViews;
    
    UILabel *_titleLabel;
    UILabel *_messageLabel;
    UIImageView *_imageView;
    UIView *_dragIndicatorView;
    
    NSArray *_buttons;
}

@property (strong, nonatomic) MMLocalNotification *notification;
@property (strong, nonatomic) id <MMNotificationPresentationContext> context;

@end

@interface _MMBannerNotificationButton : UIButton {
    UIVisualEffectView *_backgroundContainerView;
    UIImageView *_roundedBackgroundView;
}

@property (strong, nonatomic) UIVisualEffect *backgroundVisualEffect;
@property (assign, nonatomic) CGFloat backgroundBorderRadius;
@property (strong, nonatomic) UIColor *backgroundTintColor;

@end

@implementation MMBannerNotificationView

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) \
([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

+ (instancetype)alloc
{
    if ([MMBannerNotificationView class] == self) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")) {
            return [MMBannerNotificationView_Rounded alloc];
        } else {
            return [MMBannerNotificationView_Wide alloc];
        }
    }
    return [super alloc];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _titleTextFont = [UIFont boldSystemFontOfSize:15.0f];
        _messageTextFont = [UIFont systemFontOfSize:14.0f];
        _buttonTextFont = [UIFont systemFontOfSize:15.0f];
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)awakeWithPresentationContext:(id<MMNotificationPresentationContext>)context
{
    [self _configureViewsWithPresentationContext:context];
    
    self.notification = context.localNotification;
    self.context = context;
}

- (void)_configureViewsWithPresentationContext:(id<MMNotificationPresentationContext>)context
{
    MMLocalNotification *notification = context.localNotification;
    
    // Content view.
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self addSubview:contentView];
    
    _contentView = contentView;
    
    const BOOL visualEffectsSupported = [UIVisualEffectView class] != nil;
    UIBlurEffect *backgroundBlurEffect = nil;
    if (visualEffectsSupported) {
        UIVisualEffect *backgroundEffect = [self _backgroundVisualEffectForContentView:contentView];
        if ([backgroundEffect isKindOfClass:[UIBlurEffect class]]) {
            backgroundBlurEffect = (id)backgroundEffect;
        }
    }
    
    // Setup containers.
    NSMutableArray *contentContainers = [NSMutableArray array];
    
    _contentContainerViews = contentContainers;
    
    // Title label.
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.text = notification.title;
    titleLabel.font = _titleTextFont;
    titleLabel.textColor = [self _titleTextColor];
    titleLabel.numberOfLines = 0;
    
    _titleLabel = titleLabel;
    
    [contentView addSubview:titleLabel];
    
    // Message label.
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    messageLabel.text = notification.message;
    messageLabel.font = _messageTextFont;
    messageLabel.textColor = [self _messageTextColor];
    messageLabel.numberOfLines = 0;
    
    _messageLabel = messageLabel;
    
    if (visualEffectsSupported && backgroundBlurEffect) {
        UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:backgroundBlurEffect];
        UIVisualEffectView *messageContainer = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
        
        [contentContainers addObject:messageContainer];
        
        [messageContainer.contentView addSubview:messageLabel];
        [contentView addSubview:messageContainer];
    } else {
        [contentView addSubview:messageLabel];
    }
    
    // Image view.
    UIImageView *imageView = [[UIImageView alloc] initWithImage:notification.image];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    _imageView = imageView;
    
    [contentView addSubview:imageView];
    
    // Buttons.
    UIFont *buttonTextFont = _buttonTextFont;
    UIFont *boldButtonTextFont = [UIFont fontWithDescriptor:[buttonTextFont.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold] size:buttonTextFont.pointSize] ?: buttonTextFont;
    
    NSMutableArray *buttons = [NSMutableArray array];
    
    for (MMNotificationAction *action in notification.actions) {
        _MMBannerNotificationButton *button = [_MMBannerNotificationButton buttonWithType:UIButtonTypeSystem];
        
        if (visualEffectsSupported && backgroundBlurEffect) {
            UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:backgroundBlurEffect];
            
            button.backgroundVisualEffect = vibrancyEffect;
        }
        
        if (action.style == MMNotificationActionStyleDone) {
            [button.titleLabel setFont:boldButtonTextFont];
        } else {
            [button.titleLabel setFont:buttonTextFont];
        }
        
        [button setTitle:action.title forState:UIControlStateNormal];
        [button addTarget:self action:@selector(_actionButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        
        [contentView addSubview:button];
        [buttons addObject:button];
    }
    
    _buttons = buttons;
    
    // Drag indicator.
    UIGestureRecognizer *dismissGestureRecognizer = context.interactiveDismissGestureRecognizer;
    if (dismissGestureRecognizer) {
        MMBannerDragableView *dragView = [[MMBannerDragableView alloc] initWithFrame:CGRectZero];
        
        if (visualEffectsSupported && backgroundBlurEffect) {
            UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:backgroundBlurEffect];
            
            dragView.backgroundVisualEffect = vibrancyEffect;
        }
        
        _dragIndicatorView = dragView;
        
        [contentView addSubview:dragView];
        
        [self addGestureRecognizer:dismissGestureRecognizer];
    }
}

#pragma mark - Appearance.

- (void)setTitleTextFont:(UIFont *)titleTextFont
{
    if (_titleTextFont != titleTextFont) {
        _titleTextFont = titleTextFont;
        
        _titleLabel.font = titleTextFont;
    }
}

- (void)setMessageTextFont:(UIFont *)messageTextFont
{
    if (_messageTextFont != messageTextFont) {
        _messageTextFont = messageTextFont;
        
        _messageLabel.font = messageTextFont;
    }
}

- (void)setButtonTextFont:(UIFont *)buttonTextFont
{
    if (_buttonTextFont != buttonTextFont) {
        _buttonTextFont = buttonTextFont;
        
        UIFont *boldButtonTextFont = [UIFont fontWithDescriptor:[buttonTextFont.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold] size:buttonTextFont.pointSize] ?: buttonTextFont;
        
        MMLocalNotification *notification = self.context.localNotification;
        NSArray *buttons = _buttons;
        [notification.actions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MMNotificationAction *action = obj;
            _MMBannerNotificationButton *button = buttons[idx];
            
            if (action.style == MMNotificationActionStyleDone) {
                [button.titleLabel setFont:boldButtonTextFont];
            } else {
                [button.titleLabel setFont:buttonTextFont];
            }
        }];
    }
}

#pragma mark - Actions.

- (void)_actionButtonTouchUpInside:(UIButton *)sender
{
    NSUInteger idx = [_buttons indexOfObject:sender];
    MMNotificationAction *action = self.notification.actions[idx];
    
    [self.context dismissPresentationWithAction:action];
}

#pragma mark - Layout.

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = (CGRect){
        .size = self.bounds.size
    };
    
    CGRect contentRect = [self contentRectForBounds:bounds];
    CGRect titleRect = [self titleRectForContentRect:contentRect];
    CGRect messageRect = [self messageRectForContentRect:contentRect];
    CGRect dragIndicatorRect = [self dragIndicatorRectForContentRect:contentRect];
    
    // Layout buttons
    CGRect actionsRect = [self actionsRectForContentRect:contentRect];
    
    const NSInteger numberOfButtons = _buttons.count;
    if (numberOfButtons > 0) {
        const CGFloat spacing = 10.0f;
        const CGFloat buttonWidth = floorf((float)(CGRectGetWidth(actionsRect) - (spacing * (numberOfButtons - 1))) / numberOfButtons);
        
        NSInteger i = 0;
        for (UIButton *button in _buttons) {
            CGSize size = [button sizeThatFits:actionsRect.size];
            size.width = buttonWidth;
            
            CGRect rect = actionsRect;
            rect.size = size;
            rect.origin.x = (buttonWidth * i) + (spacing * i);
            
            button.frame = rect;
            
            i++;
        }
    }
    
    // Content containers.
    CGRect contentContainerRect = contentRect;
    contentContainerRect.origin = CGPointZero;
    for (UIView *view in _contentContainerViews) {
        view.frame = contentContainerRect;
    }
    
    // Rest of views.
    _dragIndicatorView.frame = dragIndicatorRect;
    _titleLabel.frame = titleRect;
    _messageLabel.frame = messageRect;
    _contentView.frame = contentRect;
}

- (CGRect)contentRectForBounds:(CGRect)bounds
{
    const CGFloat maximumWidth = [self _preferredMaximumContentSize].width;
    
    CGRect rect = bounds;
    rect.origin = CGPointZero;
    rect.size.width = MIN(maximumWidth, CGRectGetWidth(bounds));
    
    if (CGRectGetWidth(rect) == maximumWidth) {
        rect.origin.x = roundf((float)((CGRectGetWidth(bounds) - maximumWidth) / 2.0f));
    }
    
    return UIEdgeInsetsInsetRect(rect, [self _contentInsets]);
}

- (CGRect)textRectForContentRect:(CGRect)contentRect
{
    const CGRect imageRect = [self imageRectForContentRect:contentRect];
    const CGFloat origin = CGRectIsEmpty(imageRect) ? 0.0f : CGRectGetMaxX(imageRect) + 10.0f;
    
    contentRect.origin = CGPointZero;
    
    CGRect textRect = UIEdgeInsetsInsetRect(contentRect, (UIEdgeInsets){
        .left = origin,
    });
    
    return textRect;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    const CGRect textRect = [self textRectForContentRect:contentRect];
    
    CGSize titleSize = [_titleLabel sizeThatFits:textRect.size];
    CGRect titleRect = (CGRect){
        .origin = textRect.origin,
        .size = titleSize
    };
    
    return titleRect;
}

- (CGRect)messageRectForContentRect:(CGRect)contentRect
{
    const CGRect textRect = [self textRectForContentRect:contentRect];
    const CGRect titleRect = [self titleRectForContentRect:contentRect];
    
    CGSize messageSize = [_messageLabel sizeThatFits:textRect.size];
    CGRect messageRect = (CGRect){
        .origin.x = CGRectGetMinX(textRect),
        .origin.y = CGRectGetMaxY(titleRect) + 5.0f,
        .size = messageSize
    };
    
    return messageRect;
}

- (CGRect)actionsRectForContentRect:(CGRect)contentRect
{
    CGFloat buttonHeight = 32.0f;
    
    if (self.notification.actions.count == 0) {
        buttonHeight = 0.0f;
    }
    
    const CGRect messageRect = [self messageRectForContentRect:contentRect];
    
    CGRect actionsRect = (CGRect){
        .origin.y = CGRectGetMaxY(messageRect) + 15.0f,
        .size.width = CGRectGetWidth(contentRect),
        .size.height = buttonHeight
    };
    
    return actionsRect;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    const CGSize maximumImageSize = { 44.0f, 44.0f };
    
    CGSize imageSize = [_imageView sizeThatFits:contentRect.size];
    imageSize.width = MIN(maximumImageSize.width, imageSize.width);
    imageSize.height = MIN(maximumImageSize.height, imageSize.height);
    
    CGRect imageRect = (CGRect){
        .size = imageSize
    };
    
    return imageRect;
}

- (CGRect)dragIndicatorRectForContentRect:(CGRect)contentRect
{
    CGSize indicatorSize = [_dragIndicatorView sizeThatFits:contentRect.size];
    CGRect indicatorRect = (CGRect){
        .origin.x = roundf((float)((CGRectGetWidth(contentRect) - indicatorSize.width) / 2.0f)),
        .origin.y = CGRectGetMaxY(contentRect) - indicatorSize.height,
        .size = indicatorSize
    };
    
    return indicatorRect;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGRect proposedBounds = (CGRect){ .size = size };
    CGRect contentRect = [self contentRectForBounds:proposedBounds];
    CGRect actionsRect = [self actionsRectForContentRect:contentRect];
    CGRect dragIndicatorRect = [self dragIndicatorRectForContentRect:contentRect];
    
    size.height = CGRectGetMinY(contentRect) + CGRectGetMaxY(actionsRect) + [self _contentInsets].bottom;
    
    if (!CGRectIsEmpty(dragIndicatorRect)) {
        size.height += CGRectGetHeight(dragIndicatorRect);
    }
    
    return size;
}

#pragma mark - Private.

- (UIEdgeInsets)_contentInsets
{
    return (UIEdgeInsets){ 15.0f, 10.0f, 15.0f, 10.0f };
}

- (CGSize)_preferredMaximumContentSize
{
    return (CGSize){ 465.0f, CGFLOAT_MAX };
}

- (UIVisualEffect *)_backgroundVisualEffectForContentView:(UIView *)contentView
{
    return nil;
}

- (UIColor *)_messageTextColor
{
    return nil;
}

- (UIColor *)_titleTextColor
{
    return nil;
}

@end

@implementation _MMBannerNotificationButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _backgroundBorderRadius = 4.0f;
        
        self.tintColor = [UIColor whiteColor];
        
        // Container view.
        UIVisualEffectView *containerView = nil;
        if ([UIVisualEffectView class]) {
            containerView = [[UIVisualEffectView alloc] initWithFrame:CGRectZero];
        } else {
            containerView = (id)[[UIView alloc] initWithFrame:CGRectZero];
        }
        containerView.userInteractionEnabled = NO;
        
        _backgroundContainerView = containerView;
        
        [self addSubview:containerView];
        
        // Background view.
        UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
        
        _roundedBackgroundView = backgroundView;
        
        if ([UIVisualEffectView class]) {
            [containerView.contentView addSubview:backgroundView];
        } else {
            [containerView addSubview:backgroundView];
        }
        
        [self _invalidateBackgroundImage];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    size.height = 32.0f;
    
    return size;
}

- (void)_invalidateBackgroundImage
{
    UIColor *color = nil;
    if ([UIVisualEffectView class]) {
        color = [UIColor colorWithWhite:1.0f alpha:0.45f];
    } else {
        color = [UIColor colorWithWhite:1.0f alpha:0.25f];
    }
    
    const CGFloat radius = self.backgroundBorderRadius;
    
    const CGFloat dimension = radius * 2.0f;
    const CGFloat dimensionHalf = dimension / 2.0f;
    
    CGRect rect = CGRectMake(0, 0, dimension, dimension);
    
    UIImage *image = nil;
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius];
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0); {
        [color setFill];
        [bezierPath fill];
        
        image = UIGraphicsGetImageFromCurrentImageContext();
    }; UIGraphicsEndImageContext();
    
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(dimensionHalf, dimensionHalf, dimensionHalf, dimensionHalf)];
    
    [_roundedBackgroundView setImage:image];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = (CGRect){
        .size = self.bounds.size
    };
    
    if (_backgroundContainerView) {
        [self sendSubviewToBack:_backgroundContainerView];
    }
    
    _roundedBackgroundView.frame = bounds;
    _backgroundContainerView.frame = bounds;
}

- (void)setBackgroundVisualEffect:(UIVisualEffect *)visualEffect
{
    if (![_backgroundVisualEffect isEqual:visualEffect]) {
        _backgroundVisualEffect = visualEffect;
        
        _backgroundContainerView.effect = visualEffect;
    }
}

- (void)setBackgroundBorderRadius:(CGFloat)radius
{
    if (radius != _backgroundBorderRadius) {
        _backgroundBorderRadius = radius;
        
        [self _invalidateBackgroundImage];
    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    NSTimeInterval animationDuration = highlighted ? 0.1f : 0.25f;
    
    [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction animations:^{
        self->_roundedBackgroundView.alpha = highlighted ? 0.8f : 1.0f;
    } completion:NULL];
}

@end
