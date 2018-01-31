//
//  DemoCustomNotificationView.m
//  MMNotificationsDemo
//
//  Created by Matías Martínez on 1/31/18.
//  Copyright © 2018 Matías Martínez. All rights reserved.
//

#import "DemoCustomNotificationView.h"
#import "MMLocalNotification.h"
#import "MMNotificationPresentationContext.h"

@interface DemoCustomNotificationView ()

@property (nonatomic) UILabel *exampleTitleLabel;

@end

@implementation DemoCustomNotificationView

#pragma mark - <MMNotificationView>

- (void)awakeWithPresentationContext:(id<MMNotificationPresentationContext>)context
{
    // Handle the presentation context here.
    // You should configure your user interface with information contained in the context.
    //
    // For example, you can get the notification's title like this:
    NSString *title = context.localNotification.title;
    
    [self.exampleTitleLabel setText:title];
    
    // If desired, you can add the interactive dismiss behavior with the gesture recognizer provided by the context:
    [self addGestureRecognizer:context.interactiveDismissGestureRecognizer];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Example rainbow implementation.

+ (Class)layerClass
{
    return [CAGradientLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CAGradientLayer *layer = (id)self.layer;
        layer.startPoint = CGPointZero;
        layer.endPoint = CGPointMake(1, 0);
        layer.colors = @[ (id)[UIColor colorWithRed:1.000 green:0.154 blue:0.316 alpha:1.000].CGColor,
                          (id)[UIColor colorWithRed:1.000 green:0.221 blue:0.143 alpha:1.000].CGColor,
                          (id)[UIColor colorWithRed:1.000 green:0.588 blue:0.000 alpha:1.000].CGColor,
                          (id)[UIColor colorWithRed:1.000 green:0.806 blue:0.000 alpha:1.000].CGColor,
                          (id)[UIColor colorWithRed:0.264 green:0.860 blue:0.366 alpha:1.000].CGColor,
                          (id)[UIColor colorWithRed:0.327 green:0.783 blue:0.989 alpha:1.000].CGColor,
                          (id)[UIColor colorWithRed:0.163 green:0.664 blue:0.870 alpha:1.000].CGColor,
                          (id)[UIColor colorWithRed:0.000 green:0.463 blue:1.000 alpha:1.000].CGColor,
                          (id)[UIColor colorWithRed:0.341 green:0.320 blue:0.854 alpha:1.000].CGColor
                          ]
        ;
        
        UILabel *exampleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        exampleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        exampleLabel.textAlignment = NSTextAlignmentCenter;
        exampleLabel.textColor = [UIColor whiteColor];
        exampleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
        exampleLabel.textAlignment = NSTextAlignmentCenter;
        exampleLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.25f];
        exampleLabel.shadowOffset = (CGSize){ .height = 1.0f };
        
        self.exampleTitleLabel = exampleLabel;
        
        [self addSubview:exampleLabel];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    size.height = 88.0f; // You can calculate an appropiate size here.
    
    return size;
}

@end
