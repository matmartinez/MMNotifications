//
//  MMBannerDragableView.m
//  MMNotifications
//
//  Created by Matías Martínez on 9/5/16.
//  Copyright © 2016 Matías Martínez. All rights reserved.
//

#import "MMBannerDragableView.h"

@interface MMBannerDragableView () {
    UIVisualEffectView *_backgroundContainerView;
    UIImageView *_imageView;
}

@end

@implementation MMBannerDragableView

+ (UIImage *)notificationDragIndicatorImage
{
    __weak static UIImage *_cachedImage;
    UIImage *image = _cachedImage;
    
    if (!image) {
        const CGSize size = { 36.0, 5.0f };
        const CGFloat radius = 3.0f;
        
        UIColor *color = nil;
        if ([UIVisualEffectView class]) {
            color = [UIColor colorWithWhite:1.0f alpha:0.45f];
        } else {
            color = [UIColor colorWithWhite:1.0f alpha:0.25f];
        }
        
        UIGraphicsBeginImageContextWithOptions(size, NO, 0); {
            [color setFill];
            
            UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:(CGRect){ .size = size } cornerRadius:radius];
            [bezierPath fill];
            
            image = UIGraphicsGetImageFromCurrentImageContext();
        }; UIGraphicsEndImageContext();
        
        _cachedImage = image;
    }
    
    return image;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        
        // Container view.
        UIVisualEffectView *containerView = nil;
        if ([UIVisualEffectView class]) {
            containerView = [[UIVisualEffectView alloc] initWithFrame:CGRectZero];
        } else {
            containerView = (id)[[UIView alloc] initWithFrame:CGRectZero];
        }
        containerView.userInteractionEnabled = NO;
        
        _backgroundContainerView = containerView;
        
        [self addSubview:containerView];
        
        // Indicator view.
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[self.class notificationDragIndicatorImage]];
        
        _imageView = imageView;
        
        if ([UIVisualEffectView class]) {
            [containerView.contentView addSubview:imageView];
        } else {
            [containerView addSubview:imageView];
        }
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize imageSize = [_imageView sizeThatFits:size];
    
    size.width = imageSize.width;
    size.height = imageSize.height + 10.0f;
    
    return size;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = (CGRect){
        .size = self.bounds.size
    };
    
    if (_backgroundContainerView) {
        [self sendSubviewToBack:_backgroundContainerView];
    }
    
    CGSize imageSize = [_imageView sizeThatFits:bounds.size];
    CGRect imageRect = (CGRect){
        .origin.x = CGRectGetMidX(bounds) - roundf((float)imageSize.width / 2.0f),
        .origin.y = CGRectGetMidY(bounds) - roundf((float)imageSize.height / 2.0f),
        .size = imageSize
    };
    
    _imageView.frame = imageRect;
    _backgroundContainerView.frame = bounds;
}

- (void)setBackgroundVisualEffect:(UIVisualEffect *)visualEffect
{
    if (![_backgroundVisualEffect isEqual:visualEffect]) {
        _backgroundVisualEffect = visualEffect;
        
        _backgroundContainerView.effect = visualEffect;
    }
}

@end
