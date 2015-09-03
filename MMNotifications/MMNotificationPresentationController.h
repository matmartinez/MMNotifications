//
//  MMNotificationPresentationController.h
//  SuperPal
//
//  Created by Matías Martínez on 7/23/15.
//  Copyright © 2015 ShopPal. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMLocalNotification;
@protocol MMNotificationView;

/**
 A @c MMNotificationPresentationController manages the presentation of notifications to the user. You create @c MMLocalNotification objects and add it to a presentation controller to be displayed immediately or in a future date and time.
 */
@interface MMNotificationPresentationController : NSObject

/**
 *  The shared presentation controller instance.
 *
 *  @return A singleton object that represents the shared presentation controller.
 */
+ (instancetype)sharedPresentationController;

- (instancetype)init NS_UNAVAILABLE;

/**
 *  Presents a local notification immediately.
 *
 *  @param notification A local notification that the presentation controller presents for the app immediately, regardless of the value of the notification’s @c -fireDate property. Because the presentation controller copies notification, you may release it once you have scheduled it..
 */
- (void)presentLocalNotificationNow:(MMLocalNotification *)notification;

/**
 *  Schedules a local notification for delivery at its encapsulated date and time.
 *
 *  @param notification The local notification object that you want to schedule. This object contains information about when to deliver the notification and what to do when that date occurs. The presentation controller keeps a copy of this object so you may release the object once it is scheduled.
 */
- (void)scheduleLocalNotification:(MMLocalNotification *)notification;

/**
 *  Cancels the delivery of the specified scheduled local notification.
 *
 *  @param notification The local notification to cancel.
 */
- (void)cancelLocalNotification:(MMLocalNotification *)notification;

/**
 *  Cancels the delivery of all scheduled local notifications.
 */
- (void)cancelAllLocalNotifications;

/**
 *  All currently scheduled local notifications.
 */
@property (nonatomic, copy) NSArray <MMLocalNotification *> *scheduledLocalNotifications;

/**
 *  Registers a custom notification view for presenting notifications of a certain category.
 *
 *  @discussion The presentation controller will use the @c -category property of the @c MMLocalNotification class to display a custom notification view, if appropiate.
 *
 *  @param viewClass The custom notification view class to register.
 *  @param category  The category of the notification that identify the registered class.
 */
- (void)registerViewClass:(Class <MMNotificationView>)viewClass forNotificationCategory:(NSString *)category;

@end
