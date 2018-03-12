//
//  MMBannerNotificationView.h
//  SuperPal
//
//  Created by Matías Martínez on 7/23/15.
//  Copyright © 2015 ShopPal. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MMNotificationPresentationContext;

/**
 *  The @c MMNotificationView protocol defines methods that notification view classes must implement. The methods in this protocol are called only once when the notification is presented. All methods of this protocol are required.
 */
@protocol MMNotificationView <NSObject>

/**
 *  Initializes the notification view with the specified context properties.
 *
 *  @param context The context object provided by the presentation controller. You are responsible for saving a reference to the provided object and using it to configure your notification view.
 *
 *  @discuss The presentation controller calls this method at initialization time to provide the notification view with contextual data relevant to the notification. Use this method to configure your interface and to dismiss your interface when the user selects an action.
 */
- (void)awakeWithPresentationContext:(id <MMNotificationPresentationContext>)context;

/**
 *  If @c YES, the status bar will be hidden. If @c NO, the status bar will be displayed behind the notification.
 */
- (BOOL)prefersStatusBarHidden;

@end

/**
 *  The @c MMBannerNotificationView class provides the controls for displaying a notification. The default implementation of this class resembles the appearance of the system notifications, including blur and vibrancy visual effects.
 */
@interface MMBannerNotificationView : UIView <MMNotificationView>

@property (strong, nonatomic, null_resettable) UIFont *titleTextFont UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic, null_resettable) UIFont *messageTextFont UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic, null_resettable) UIFont *buttonTextFont UI_APPEARANCE_SELECTOR;

- (CGRect)contentRectForBounds:(CGRect)bounds;
- (CGRect)titleRectForContentRect:(CGRect)contentRect;
- (CGRect)messageRectForContentRect:(CGRect)contentRect;
- (CGRect)imageRectForContentRect:(CGRect)contentRect;
- (CGRect)dragIndicatorRectForContentRect:(CGRect)contentRect;

@end

NS_ASSUME_NONNULL_END
