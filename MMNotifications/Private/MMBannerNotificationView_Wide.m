//
//  MMBannerNotificationView_Wide.m
//  MMNotifications
//
//  Created by Matías Martínez on 9/5/16.
//  Copyright © 2016 Matías Martínez. All rights reserved.
//

#import "MMBannerNotificationView_Wide.h"

@interface MMBannerNotificationView_Wide () {
    UIView *_backgroundView;
    BOOL _attachesTopBackground;
}

@end

@implementation MMBannerNotificationView_Wide

- (void)awakeWithPresentationContext:(id<MMNotificationPresentationContext>)context
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
    
    [super awakeWithPresentationContext:context];
}

#pragma mark - Private override.

- (UIColor *)_titleTextColor
{
    return [UIColor whiteColor];
}

- (UIColor *)_messageTextColor
{
    return [UIColor whiteColor];
}

- (UIVisualEffect *)_backgroundVisualEffectForContentView:(UIView *)contentView
{
    if ([_backgroundView isKindOfClass:[UIVisualEffectView class]]) {
        UIVisualEffectView *effectView = (id)_backgroundView;
        
        return effectView.effect;
    }
    return nil;
}

#pragma mark - Layout.

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = (CGRect){
        .size = self.bounds.size
    };
    
    // Insets.
    CGRect statusBarRect = [self convertRect:[UIApplication sharedApplication].statusBarFrame fromView:nil];
    
    CGFloat attachedLength = -MIN(CGRectGetMinY(statusBarRect), 0);
    
    if (_attachesTopBackground || attachedLength > 0) {
        _attachesTopBackground = YES;
        
        attachedLength = CGRectGetHeight(self.window.screen.bounds);
    }
    
    UIEdgeInsets insets = (UIEdgeInsets){
        .top = -attachedLength,
    };
    // Background.
    CGRect backgroundRect = UIEdgeInsetsInsetRect(bounds, insets);
    
    _backgroundView.frame = backgroundRect;
}

- (void)setFrame:(CGRect)frame
{
    const BOOL backgroundNeedsLayout = !CGRectEqualToRect(frame, self.frame);
    
    [super setFrame:frame];
    
    if (backgroundNeedsLayout) {
        [self setNeedsLayout];
    }
}

@end
