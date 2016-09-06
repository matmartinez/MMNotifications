//
//  MMBannerNotificationView+MMBannerNotificationView_Private.h
//  MMNotifications
//
//  Created by Matías Martínez on 9/5/16.
//  Copyright © 2016 Matías Martínez. All rights reserved.
//

#import "MMBannerNotificationView.h"

@interface MMBannerNotificationView (Private)

// Appearance customization.
- (UIVisualEffect *)_backgroundVisualEffectForContentView:(UIView *)contentView;
- (UIColor *)_titleTextColor;
- (UIColor *)_messageTextColor;

// Layout customization.
- (UIEdgeInsets)_contentInsets;
- (CGSize)_preferredMaximumContentSize;

@end
