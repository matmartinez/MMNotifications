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

@class _MMLocalNotificationWindow;
@class _MMLocalNotificationViewController;
@class _MMStockNotificationPresentationContext;

@interface _MMStockNotificationPresentationContext : NSObject <MMNotificationPresentationContext>

@property (nonatomic, readwrite, strong) MMLocalNotification *localNotification;
@property (nonatomic, readwrite, weak) MMNotificationPresentationController *presentationController;
@property (nonatomic, readwrite, strong) UIGestureRecognizer *interactiveDismissGestureRecognizer;
@property (weak, nonatomic) UIView <MMNotificationView> *notificationView;

@end

@interface _MMLocalNotificationViewController : UIViewController

@property (strong, nonatomic) UIView <MMNotificationView> *topView;
@property (strong, nonatomic) id <MMNotificationPresentationContext> currentContext;
@property (weak, nonatomic) _MMLocalNotificationWindow *window;

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

- (UIView *)_statusBarView
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
    if (@available(iOS 13.0, *)) {
        return nil;
    }
#endif
    
    id statusBarKey = [@[ @"sta", @"tusBa", @"rWind", @"ow" ] componentsJoinedByString:@""];
    return [[UIApplication sharedApplication] valueForKey:statusBarKey];
}

@end

@implementation _MMLocalNotificationViewController

- (void)setTopView:(UIView <MMNotificationView> *)topView
{
    if (topView == _topView) {
        return;
    }
    
    [self _transitionFromView:_topView toView:topView];
    
    _topView = topView;
}

- (void)_transitionFromView:(UIView <MMNotificationView> *)fromView toView:(UIView <MMNotificationView> *)toView
{
    if (!fromView && !toView) {
        return;
    }
    
    if (toView) {
        self.window.hidden = NO;
    }
    
    UIView *statusBar = self.window._statusBarView;

    CGRect bounds = self.view.bounds;
    const BOOL isFromViewCurrentlyVisible = CGRectIntersectsRect(fromView.frame, bounds);
    
    CGRect toViewRect = [self _rectForView:toView];
    CGRect fromViewRect = [self _rectForView:fromView];
    
    CGRect fromViewRectHidden = fromViewRect, toViewRectHidden = toViewRect;
    
    if ((fromView && isFromViewCurrentlyVisible) && toView) {
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
        
        if (isFromViewCurrentlyVisible) {
            fromView.frame = fromViewRectHidden;
        }
        
        const BOOL isInsetFromTop = (toViewRect.origin.y > 0.0f);
        const BOOL hidesStatusBar = toView.prefersStatusBarHidden && !isInsetFromTop;
        
        statusBar.alpha = !(hidesStatusBar);
        
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
    CGSize boundsSize = self.view.bounds.size;
    CGSize size = [view sizeThatFits:boundsSize];
    
    CGFloat margin = self.deviceInsets.top;
    
    CGRect rect = {
        .origin.x = roundf((boundsSize.width - size.width) / 2.0f),
        .origin.y = margin,
        .size = size
    };
    
    return rect;
}

- (UIEdgeInsets)deviceInsets
{
    NSString *peripheryInsetsString = [@[ @"_devic", @"ePeriphe", @"ryInsets" ] componentsJoinedByString:@""];
    if ([self respondsToSelector:NSSelectorFromString(peripheryInsetsString)]) {
        NSValue *value = [self valueForKeyPath:peripheryInsetsString];
        return value.UIEdgeInsetsValue;
    }
    return UIEdgeInsetsZero;
}

@end

@interface MMNotificationPresentationController ()

@property (strong, nonatomic) _MMLocalNotificationWindow *window;
@property (strong, nonatomic) NSMutableArray *notificationStack;
@property (strong, nonatomic) NSMutableArray *scheduledNotificationQueue;
@property (strong, nonatomic) NSTimer *automaticDismissTimer;

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
    
    if (self.notificationStack.count > 0) {
        _MMLocalNotificationViewController *controller = self.window.rootViewController;
        [controller setTopView:nil];
        [controller setCurrentContext:nil];
        
        [self.notificationStack removeAllObjects];
    }
}

- (void)cancelLocalNotification:(MMLocalNotification *)notification
{
    NSParameterAssert(notification);
    
    if ([self.scheduledNotificationQueue containsObject:notification]) {
        [self.scheduledNotificationQueue removeObject:notification];
    }
    
    if ([self.notificationStack containsObject:notification]) {
        [self.notificationStack removeObject:notification];
    }
    
    _MMLocalNotificationViewController *controller = self.window.rootViewController;
    if ([controller.currentContext.localNotification isEqual:notification]) {
        [controller setTopView:nil];
        [controller setCurrentContext:nil];
    }
}

- (void)scheduleLocalNotification:(MMLocalNotification *)notification
{
    NSParameterAssert(notification);
    
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
    NSParameterAssert(notification);
    
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
    _MMLocalNotificationViewController *controller = self.window.rootViewController;
    
    MMLocalNotification *notification = self.notificationStack.firstObject;
    if (notification) {
        MMBannerNotificationView *notificationView = [[[self _viewClassForNotification:notification] alloc] initWithFrame:CGRectZero];
        
        _MMStockNotificationPresentationContext *ctx = [[_MMStockNotificationPresentationContext alloc] init];
        ctx.presentationController = self;
        ctx.localNotification = notification;
        ctx.notificationView = notificationView;
        
        const BOOL automaticDismissing = (notification.actions.count == 0);
        
        if (automaticDismissing) {
            UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_interactiveDismissPanGestureRecognized:)];
            
            ctx.interactiveDismissGestureRecognizer = gestureRecognizer;
        }
        
        [notificationView awakeWithPresentationContext:ctx];
        
        [controller setTopView:notificationView];
        [controller setCurrentContext:ctx];
        
        [self.notificationStack removeObjectAtIndex:0];
        
        if (automaticDismissing) {
            [self _scheduleAutomaticDismiss];
        }
    } else {
        [controller setTopView:nil];
        [controller setCurrentContext:nil];
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

#pragma mark - Dismiss gesture.

- (void)_interactiveDismissPanGestureRecognized:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint velocity = [gestureRecognizer velocityInView:self.window];
    UIView *view = gestureRecognizer.view;
    
    CGPoint translation = [gestureRecognizer translationInView:view];
    CGFloat y = CGRectGetMinY(view.frame);
    
    const auto UIView *statusBar = self.window._statusBarView;
    const CGRect rectForView = [self.window.rootViewController _rectForView:view];
    const BOOL isInsetFromTop = (rectForView.origin.y > 0.0f);
    
    const BOOL affectingStatusBar = self._presentedNotificationPrefersStatusBarHidden && !isInsetFromTop;
    
    const UIGestureRecognizerState state = gestureRecognizer.state;
    
    if (state == UIGestureRecognizerStateChanged) {
        CGFloat proposedY = y + translation.y;
        
        const CGFloat dragCoefficient = 0.055;
        const BOOL bounces = (proposedY > CGRectGetMinY(rectForView));
        if (bounces) {
            proposedY = y + (dragCoefficient * translation.y);
        }
        
        CGRect frame = view.frame;
        frame.origin.y = proposedY;
        view.frame = frame;
        
        [gestureRecognizer setTranslation:CGPointZero inView:view];
        
        if (affectingStatusBar) {
            statusBar.alpha = MAX(MIN((-proposedY / CGRectGetHeight(frame)), 1.0f), 0.0f);
        }
        
    } else if (state == UIGestureRecognizerStateEnded) {
        const BOOL isDismissing = (y <= CGRectGetMinY(rectForView));
        
        CGFloat destinationY = isDismissing ? -(CGRectGetHeight(rectForView)) : CGRectGetMinY(rectForView);
        
        CGFloat distance = y - destinationY;
        CGFloat animationDuration = 1.0f;
        
        CGFloat springVelocity = -1.0f * velocity.y / distance;
        CGFloat springDampening = isDismissing ? 1.0f : 0.6f;
        
        [UIView animateWithDuration:animationDuration delay:0.0 usingSpringWithDamping:springDampening initialSpringVelocity:springVelocity options:UIViewAnimationOptionCurveLinear animations:^{
            
            CGRect frame = view.frame;
            frame.origin.y = destinationY;
            view.frame = frame;
            
            if (affectingStatusBar) {
                statusBar.alpha = (CGFloat)(isDismissing);
            }
            
        } completion:^(BOOL finished) {
            if (isDismissing) {
                [self _dismissPresentedNotification];
            } else {
                [self _scheduleAutomaticDismiss];
            }
        }];
    }
    
    [self _invalidateAutomaticDismiss];
}

- (void)_dismissPresentedNotification
{
    _MMLocalNotificationWindow *window = self.window;
    _MMLocalNotificationViewController *hostingViewController = window.rootViewController;
    _MMStockNotificationPresentationContext *context = hostingViewController.currentContext;
    
    [context dismissPresentationWithAction:nil];
}

- (BOOL)_presentedNotificationPrefersStatusBarHidden
{
    _MMLocalNotificationWindow *window = self.window;
    _MMLocalNotificationViewController *hostingViewController = window.rootViewController;
    _MMStockNotificationPresentationContext *context = hostingViewController.currentContext;
    
    return context.notificationView.prefersStatusBarHidden;
}

#pragma mark - Automatic dismiss.

- (void)_scheduleAutomaticDismiss
{
    [self _invalidateAutomaticDismiss];
    
    const NSTimeInterval delay = 4.0;
    
    _automaticDismissTimer = [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(_automaticDismissTimerDidFire:) userInfo:nil repeats:NO];
}

- (void)_invalidateAutomaticDismiss
{
    [_automaticDismissTimer invalidate];
    _automaticDismissTimer = nil;
}

- (void)_automaticDismissTimerDidFire:(NSTimer *)timer
{
    [self _invalidateAutomaticDismiss];
    [self _dismissPresentedNotification];
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
