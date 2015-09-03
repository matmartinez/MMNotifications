//
//  MMNotificationView.m
//  SuperPal
//
//  Created by Matías Martínez on 7/17/15.
//  Copyright © 2015 ShopPal. All rights reserved.
//

#import "MMLocalNotification.h"
#import "MMBannerNotificationView.h"

@interface MMNotificationAction ()

@property (copy, readwrite, nonatomic) NSString *title;
@property (assign, readwrite, nonatomic) MMNotificationActionStyle style;
@property (copy, nonatomic) void (^block)(MMNotificationAction *);

@end

@implementation MMNotificationAction

+ (instancetype)actionWithTitle:(NSString *)title style:(MMNotificationActionStyle)style handler:(void (^)(MMNotificationAction *))handler
{
    NSParameterAssert(title);
    
    MMNotificationAction *action = [[self alloc] init];
    action.title = title;
    action.block = handler;
    action.style = style;
    
    return action;
}

- (void)performAction
{
    void (^block)(MMNotificationAction *) = self.block;
    if (block) {
        block(self);
    }
}

- (id)copyWithZone:(NSZone *)zone
{
    MMNotificationAction *action = [[[self class] allocWithZone:zone] init];
    action->_title = [self.title copyWithZone:zone];
    action->_block = [self.block copyWithZone:zone];
    action->_style = self.style;
    
    return action;
}

- (NSUInteger)hash
{
    return self.title.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Title: %@, Actionable: %@", self.title, [NSNumber numberWithBool:self.block != nil].stringValue];
}

@end

@interface MMLocalNotification ()

@property (readwrite, strong, nonatomic) NSMutableArray <MMNotificationAction *> *actions;

@end

@implementation MMLocalNotification

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.actions = [NSMutableArray array];
    }
    return self;
}

- (void)addAction:(MMNotificationAction *)action
{
    NSParameterAssert(action);
    NSAssert([action isKindOfClass:[MMNotificationAction class]], @"*** error: Expected object of class MMNotificationAction");
    
    [(NSMutableArray *)self.actions addObject:action];
}

- (id)copyWithZone:(NSZone *)zone
{
    MMLocalNotification *notification = [[[self class] allocWithZone:zone] init];
    notification.title = [self.title copyWithZone:zone];
    notification.message = [self.message copyWithZone:zone];
    notification.fireDate = [self.fireDate copyWithZone:zone];
    notification.image = self.image;
    notification.actions = self.actions.mutableCopy;
    notification.category = [self.category copyWithZone:zone];
    
    return notification;
}

- (BOOL)isEqual:(id)object
{
    if (object == self) {
        return YES;
    }
    
    if (![object isKindOfClass:[MMLocalNotification class]]) {
        return NO;
    }
    
    return [self isEqualToNotification:object];
}

- (BOOL)isEqualToNotification:(MMLocalNotification *)notification
{
    if (!notification) {
        return NO;
    }
    
    BOOL haveEqualTitles = (!self.title && !notification.title) || [self.title isEqualToString:notification.title];
    BOOL haveEqualMessages = (!self.message && !notification.message) || [self.message isEqualToString:notification.message];
    
    return haveEqualTitles && haveEqualMessages;
}

- (NSUInteger)hash
{
    return [self.title hash] ^ [self.message hash];
}

@end
