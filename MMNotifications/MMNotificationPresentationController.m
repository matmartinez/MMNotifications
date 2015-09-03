//
//  MMNotificationPresentationController.m
//  SuperPal
//
//  Created by Matías Martínez on 7/23/15.
//  Copyright © 2015 ShopPal. All rights reserved.
//

#import "MMNotificationPresentationController.h"
#import "MMLocalNotification.h"
#import "MMBannerNotificationView.h"
#import "MMNotificationPresentationContext.h"

#import <objc/runtime.h>

@interface _MMStockNotificationPresentationContext : NSObject <MMNotificationPresentationContext>

@property (nonatomic, readwrite, strong) MMLocalNotification *localNotification;
@property (nonatomic, readwrite, weak) MMNotificationPresentationController *presentationController;
@property (weak, nonatomic) UIView <MMNotificationView> *notificationView;

@end

@interface _MMLocalNotificationViewController : UIViewController

@property (strong, nonatomic) UIView *topView;
@property (weak, nonatomic) UIWindow *window;

@end

@interface _MMLocalNotificationWindow : UIWindow

@property (strong, readwrite, nonatomic) _MMLocalNotificationViewController *rootViewController;

@end

@implementation _MMLocalNotificationWindow

@dynamic rootViewController;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.windowLevel = UIWindowLevelStatusBar + 100.0;
        self.backgroundColor = [UIColor clearColor];
        
        _MMLocalNotificationViewController *viewController = [[_MMLocalNotificationViewController alloc] init];
        viewController.window = self;
        
        self.rootViewController = viewController;
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if (view == self.rootViewController.view) {
        return nil;
    }
    return view;
}

- (BOOL)shouldAffectStatusBarAppearance
{
    return NO;
}

- (void)becomeKeyWindow
{
    // Don't do anything.
}

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // This window shouldn't affect status bar appearance. This is a private API.
        NSString *canAffectSelectorString = [@[@"_can", @"Affect", @"Status", @"Bar", @"Appearance"] componentsJoinedByString:@""];
        SEL canAffectSelector = NSSelectorFromString(canAffectSelectorString);
        Method shouldAffectMethod = class_getInstanceMethod(self, @selector(shouldAffectStatusBarAppearance));
        IMP canAffectImplementation = method_getImplementation(shouldAffectMethod);
        class_addMethod(self, canAffectSelector, canAffectImplementation, method_getTypeEncoding(shouldAffectMethod));
    });
}

@end

@implementation _MMLocalNotificationViewController

- (void)setTopView:(UIView *)topView
{
    if (topView == _topView) {
        return;
    }
    
    [self _transitionFromView:_topView toView:topView];
    
    _topView = topView;
}

- (void)_transitionFromView:(UIView *)fromView toView:(UIView *)toView
{
    if (!fromView && !toView) {
        return;
    }
    
    if (toView) {
        self.window.hidden = NO;
    }
    
    CGRect bounds = self.view.bounds;
    CGRect toViewRect = [self _rectForView:toView];
    CGRect fromViewRect = [self _rectForView:fromView];
    
    CGRect fromViewRectHidden = fromViewRect, toViewRectHidden = toViewRect;
    
    if (fromView && toView) {
        const CGFloat pagingSpacing = 10.0f;
        
        fromViewRectHidden.origin.x = -CGRectGetWidth(fromViewRect) - pagingSpacing;
        toViewRectHidden.origin.x = CGRectGetWidth(bounds) + pagingSpacing;
    } else {
        toViewRectHidden.origin.y = -CGRectGetHeight(toViewRect);
        fromViewRectHidden.origin.y = -CGRectGetHeight(fromViewRect);
    }
    
    toView.frame = toViewRectHidden;
    
    if (toView) {
        [self.view addSubview:toView];
    }
    
    [UIView animateWithDuration:0.5f delay:0 usingSpringWithDamping:1.0f initialSpringVelocity:1.0f options:UIViewAnimationOptionAllowUserInteraction animations:^{
        toView.frame = toViewRect;
        fromView.frame = fromViewRectHidden;
    } completion:^(BOOL finished) {
        if (fromView) {
            [fromView removeFromSuperview];
        }
        
        if (!toView && !self.topView) {
            self.window.hidden = YES;
        }
    }];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.topView.frame = [self _rectForView:self.topView];
}

- (CGRect)_rectForView:(UIView *)view
{
    CGSize size = [view sizeThatFits:self.view.bounds.size];
    CGRect rect = { .size = size };
    
    return rect;
}

@end

@interface MMNotificationPresentationController ()

@property (strong, nonatomic) _MMLocalNotificationWindow *window;
@property (strong, nonatomic) NSMutableArray *notificationStack;
@property (strong, nonatomic) NSMutableArray *scheduledNotificationQueue;

@property (strong, nonatomic) NSMutableDictionary *registeredViewClasses;

@end

@implementation MMNotificationPresentationController

+ (instancetype)sharedPresentationController
{
    static MMNotificationPresentationController *sharedPresentationController;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPresentationController = [[MMNotificationPresentationController alloc] _init];
    });
    return sharedPresentationController;
}

- (instancetype)_init
{
    self = [super init];
    if (self) {
        self.window = [[_MMLocalNotificationWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.scheduledNotificationQueue = [NSMutableArray array];
        self.notificationStack = [NSMutableArray array];
        self.registeredViewClasses = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSArray<MMLocalNotification *> *)scheduledLocalNotifications
{
    return self.scheduledNotificationQueue.copy;
}

- (void)cancelAllLocalNotifications
{
    [self.scheduledNotificationQueue removeAllObjects];
    [self _popNotification];
}

- (void)cancelLocalNotification:(MMLocalNotification *)notification
{
    if (!notification) {
        return;
    }
    
    if ([self.scheduledNotificationQueue containsObject:notification]) {
        [self.scheduledNotificationQueue removeObject:notification];
    }
}

- (void)scheduleLocalNotification:(MMLocalNotification *)notification
{
    if (!notification) {
        return;
    }
    
    NSDate *fireDate = notification.fireDate;
    
    const NSComparisonResult dateComparison = [fireDate compare:[NSDate date]];
    const BOOL dateFiresNow = (dateComparison == NSOrderedSame || dateComparison == NSOrderedAscending);
    
    if (!fireDate || dateFiresNow) {
        [self presentLocalNotificationNow:notification];
    } else {
        MMLocalNotification *scheduledNotification = [notification copy];
        
        [self.scheduledNotificationQueue addObject:scheduledNotification];
        
        __weak typeof(self)weakSelf = self;
        
        NSTimeInterval delay = [scheduledNotification.fireDate timeIntervalSinceNow] / 1000;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __strong __typeof(&*weakSelf)strongSelf = weakSelf;
            if (strongSelf && [strongSelf.scheduledNotificationQueue containsObject:scheduledNotification]) {
                [strongSelf.scheduledNotificationQueue removeObject:scheduledNotification];
                [strongSelf _pushNotification:notification];
            }
        });
    }
}

- (void)presentLocalNotificationNow:(MMLocalNotification *)notification
{
    if (!notification) {
        return;
    }
    
    [self _pushNotification:[notification copy]];
}

- (void)setScheduledLocalNotifications:(NSArray<MMLocalNotification *> *)scheduledLocalNotifications
{
    if (![scheduledLocalNotifications isEqualToArray:self.scheduledLocalNotifications]) {
        [self cancelAllLocalNotifications];
        
        for (MMLocalNotification *notification in scheduledLocalNotifications) {
            [self scheduleLocalNotification:notification];
        }
    }
}

#pragma mark - Firing.

- (void)_pushNotification:(MMLocalNotification *)notification
{
    NSAssert([notification isKindOfClass:[MMLocalNotification class]], @"*** error: Expected object of class MMLocalNotification.");
    
    [self.notificationStack addObject:notification];
    
    if (![self _presentedNotificationView]) {
        [self _popNotification];
    }
}

- (void)_popNotification
{
    MMLocalNotification *notification = self.notificationStack.firstObject;
    if (notification) {
        MMBannerNotificationView *notificationView = [[[self _viewClassForNotification:notification] alloc] initWithFrame:CGRectZero];
        
        _MMStockNotificationPresentationContext *ctx = [[_MMStockNotificationPresentationContext alloc] init];
        ctx.presentationController = self;
        ctx.localNotification = notification;
        ctx.notificationView = notificationView;
        
        [notificationView awakeWithPresentationContext:ctx];
        
        [self.window.rootViewController setTopView:notificationView];
        [self.notificationStack removeObjectAtIndex:0];
    } else {
        [self.window.rootViewController setTopView:nil];
    }
}

- (MMBannerNotificationView *)_presentedNotificationView
{
    return (id)self.window.rootViewController.topView;
}

#pragma mark - Registering view classes.

- (void)registerViewClass:(Class<MMNotificationView>)viewClass forNotificationCategory:(NSString *)category
{
    NSParameterAssert(category);
    
    if (viewClass != nil) {
        if (viewClass == [MMBannerNotificationView class]) {
            return;
        }
        
        [self.registeredViewClasses setObject:viewClass forKey:category];
    } else {
        [self.registeredViewClasses removeObjectForKey:category];
    }
}

- (Class)_viewClassForNotification:(MMLocalNotification *)notification
{
    NSString *category = notification.category;
    
    if (category && self.registeredViewClasses.count > 0) {
        Class notificationClass = self.registeredViewClasses[category];
        if (notificationClass != nil) {
            return notificationClass;
        }
    }
    
    return [MMBannerNotificationView class];
}

@end

@interface MMNotificationAction (Private)

- (void)performAction;

@end

@implementation _MMStockNotificationPresentationContext

- (void)dismissPresentationWithAction:(MMNotificationAction *)action
{
    [action performAction];
    
    MMNotificationPresentationController *presentationController = self.presentationController;
    if ([presentationController _presentedNotificationView] == self.notificationView) {
        [presentationController _popNotification];
    }
}

@end
