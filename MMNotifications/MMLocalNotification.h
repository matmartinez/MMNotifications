//
//  MMNotificationView.h
//  SuperPal
//
//  Created by Matías Martínez on 7/17/15.
//  Copyright © 2015 ShopPal. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MMNotificationAction;

/**
 *  A @c MMLocalNotification object specifies a notification that an app can schedule for presentation at a specific date and time.
 */
@interface MMLocalNotification : NSObject <NSCopying>

/**
 *  A short description of the reason for the notification.
 */
@property (copy, nonatomic) NSString *title;

/**
 *  The message displayed in the notification interface.
 */
@property (copy, nonatomic) NSString *message;

/**
 *  An image to display in the notification interface.
 */
@property (strong, nonatomic) UIImage *image;

/**
 *  The date and time when the presentation controller should deliver the notification.
 */
@property (copy, nonatomic) NSDate *fireDate;

/**
 *  Adds an user action to the notification.
 *
 *  @param action An instance of the @c MMNotificationAction class describing the action.
 */
- (void)addAction:(MMNotificationAction *)action;

/**
 *  An array of possible actions to display in the notification.
 */
@property (readonly, nonatomic) NSArray <MMNotificationAction *> *actions;

/**
 *  The user action to trigger when the user selects the notification.
 */
@property (copy, nonatomic) MMNotificationAction *selectionAction;

/**
 *  A category to identify this notification.
 */
@property (copy, nonatomic) NSString *category;

@end

/**
 *  Styles to apply to action buttons in a notification.
 */
typedef NS_ENUM(NSUInteger, MMNotificationActionStyle){
    /**
     *  Apply the default style to the action's button.
     */
    MMNotificationActionStyleDefault = 0,
    /**
     *  Apply a style that indicates the action cancels the operation and leaves things unchanged.
     */
    MMNotificationActionStyleCancel,
    /**
     *  Apply a style that indicates a done button—for example, a button that completes some task and returns to the previous view.
     */
    MMNotificationActionStyleDone,
    /**
     *  Apply a style that indicates the action might change or delete data.
     */
    MMNotificationActionStyleDestructive
};

/**
 *  A @c MMNotificationAction object represents an action that can be taken when tapping a button in a notification. You use this class to configure information about a single action, including the title to display in the button, any styling information, and a handler to execute when the user taps the button. After creating a notification action object, add it to a @c MMLocalNotification object before displaying it to the user.
 */
@interface MMNotificationAction : NSObject <NSCopying>

/**
 *  Create and return an action with the specified title and behavior.
 *
 *  @param title   The text to use for the button title. This parameter must not be @c nil.
 *  @param style   Additional styling information to apply to the button. Use the style information to convey the type of action that is performed by the button. For a list of possible values, see the constants in @c MMNotificationActionStyle.
 *  @param handler A block to execute when the user selects the action. This block has no return value and takes the selected action object as its only parameter.
 *
 *  @return A new notification action object.
 */
+ (instancetype)actionWithTitle:(NSString *)title style:(MMNotificationActionStyle)style handler:(void (^)(MMNotificationAction *))handler;

/**
 *  The text to use for the button title.
 */
@property (copy, readonly, nonatomic) NSString *title;

/**
 *  Styling information to apply to the button.
 */
@property (assign, readonly, nonatomic) MMNotificationActionStyle style;

@end
