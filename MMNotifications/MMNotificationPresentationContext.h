//
//  MMNotificationPresentationContext.h
//  SuperPal
//
//  Created by Matías Martínez on 9/2/15.
//  Copyright © 2015 ShopPal. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMNotificationPresentationController;
@class MMNotificationAction;
@class MMLocalNotification;

/**
 *  An object that conforms to the @c MMNotificationPresentationContext protocol provides information about an active notification presentation. Do not adopt this protocol in your own classes. A presentation controller creates an object that adopts this protocol and makes it available to your code when you implement a custom view for displaying notifications.
 */
@protocol MMNotificationPresentationContext <NSObject>

/**
 *  Dismisses the presentation selecting the specified action.
 *
 *  @discussion This method should be called when the user taps the button corresponding to an action in your notification interface. The presentation controller will dismiss the presented notification and execute the action.
 *
 *  @param action The action that is being acted upon.
 */
- (void)dismissPresentationWithAction:(MMNotificationAction *)action;

/**
 *  The local notification object that is being presented.
 */
@property (readonly, nonatomic) MMLocalNotification *localNotification;

/**
 *  The presentation controller that manages this presentation context.
 */
@property (readonly, nonatomic) MMNotificationPresentationController *presentationController;

@end
