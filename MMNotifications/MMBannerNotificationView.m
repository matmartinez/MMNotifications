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

@interface MMBannerNotificationView () {
    UIView *_backgroundView;
    UIView *_contentView;
    NSArray *_contentContainerViews;
    
    UILabel *_titleLabel;
    UILabel *_messageLabel;
    UIImageView *_imageView;
    
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

- (void)awakeWithPresentationContext:(id<MMNotificationPresentationContext>)context
{
    [self _configureWithNotification:context.localNotification];
    
    self.notification = context.localNotification;
    self.context = context;
}

- (void)_configureWithNotification:(MMLocalNotification *)notification
{
    // Create views.
    const BOOL visualEffectsSupported = [UIVisualEffectView class] != nil;
    
    // Background view.
    UIView *backgrondView = nil;
    if (visualEffectsSupported) {
        UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        
        backgrondView = effectView;
    } else {
        UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectZero];
        navigationBar.barStyle = UIBarStyleBlack;
        navigationBar.clipsToBounds = YES;
        
        backgrondView = navigationBar;
    }
    
    _backgroundView = backgrondView;
    
    [self addSubview:backgrondView];
    
    // Content view.
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (visualEffectsSupported) {
        [[(UIVisualEffectView *)backgrondView contentView] addSubview:contentView];
    } else {
        [self addSubview:contentView];
    }
    
    _contentView = contentView;
    
    // Setup containers.
    NSMutableArray *contentContainers = [NSMutableArray array];
    
    _contentContainerViews = contentContainers;
    
    // Title label.
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.text = notification.title;
    titleLabel.font = _titleTextFont;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.numberOfLines = 0;
    
    _titleLabel = titleLabel;
    
    [contentView addSubview:titleLabel];
    
    // Message label.
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    messageLabel.text = notification.message;
    messageLabel.font = _messageTextFont;
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.numberOfLines = 0;
    
    _messageLabel = messageLabel;
    
    if (visualEffectsSupported) {
        UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:(UIBlurEffect *)[(id)backgrondView effect]];
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
        
        if (visualEffectsSupported) {
            UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:(UIBlurEffect *)[(id)backgrondView effect]];
            
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
    _titleLabel.frame = titleRect;
    _messageLabel.frame = messageRect;
    _contentView.frame = contentRect;
    _backgroundView.frame = bounds;
}

- (CGRect)contentRectForBounds:(CGRect)bounds
{
    const CGFloat maximumWidth = 465.0f;
    
    CGRect rect = bounds;
    rect.origin = CGPointZero;
    rect.size.width = MIN(maximumWidth, CGRectGetWidth(bounds));
    
    if (CGRectGetWidth(rect) == maximumWidth) {
        rect.origin.x = roundf((float)((CGRectGetWidth(bounds) - maximumWidth) / 2.0f));
    }
    
    return CGRectInset(rect, 15.0f, 10.0f);
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

- (CGSize)sizeThatFits:(CGSize)size
{
    CGRect proposedBounds = (CGRect){ .size = size };
    CGRect contentRect = [self contentRectForBounds:proposedBounds];
    CGRect actionsRect = [self actionsRectForContentRect:contentRect];
    
    size.height = CGRectGetMinY(contentRect) + CGRectGetMaxY(actionsRect) + 10.0f;
    
    return size;
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
