//
//  MMBannerNotificationView_Rounded.m
//  MMNotifications
//
//  Created by Matías Martínez on 9/5/16.
//  Copyright © 2016 Matías Martínez. All rights reserved.
//

#import "MMBannerNotificationView_Rounded.h"

@interface MMBannerNotificationView_Rounded () {
    UIEdgeInsets _backgroundInsets;
    UIVisualEffectView *_backgroundView;
    UIImageView *_shadowBackgroundView;
}

@end

@implementation MMBannerNotificationView_Rounded

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _backgroundInsets = (UIEdgeInsets){ 8.0f, 8.0f, 8.0f, 8.0f };
        
        _shadowBackgroundView = [[UIImageView alloc] initWithImage:[self.class roundedShadowImage]];
        
        [self addSubview:_shadowBackgroundView];
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)awakeWithPresentationContext:(id<MMNotificationPresentationContext>)context
{
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    effectView.userInteractionEnabled = NO;
    
    _backgroundView = effectView;
    
    [self addSubview:effectView];
    
    [super awakeWithPresentationContext:context];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = (CGRect){
        .size = self.bounds.size
    };
    
    const CGRect backgroundRect = UIEdgeInsetsInsetRect(bounds, _backgroundInsets);
    
    CGRect maskRect = backgroundRect;
    maskRect.origin = CGPointZero;
    
    UIImageView *maskView = [[UIImageView alloc] initWithFrame:maskRect];
    maskView.image = [self.class roundedMaskImage];
    
    _backgroundView.maskView = maskView;
    _backgroundView.frame = backgroundRect;
    
    UIImage *shadowImage = _shadowBackgroundView.image;
    CGRect shadowRect = UIEdgeInsetsInsetRect(backgroundRect, shadowImage.alignmentRectInsets);
    
    _shadowBackgroundView.frame = shadowRect;
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];
    
    if (newWindow != nil) {
        [self layoutIfNeeded];
    }
}

#pragma mark - Layout override.

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize inheritedSize = [super sizeThatFits:size];
    CGSize preferredSize = inheritedSize;
    preferredSize.width = MIN(preferredSize.width, self._preferredMaximumContentSize.width);
    
    return preferredSize;
}

- (CGRect)dragIndicatorRectForContentRect:(CGRect)contentRect
{
    CGRect rect = [super dragIndicatorRectForContentRect:contentRect];
    rect.origin.y -= _backgroundInsets.bottom;
    
    return rect;
}

#pragma mark - Appearance override.

- (UIEdgeInsets)_contentInsets
{
    return (UIEdgeInsets){ 20.0f, 24.0f, 20.0f, 24.0f };
}

- (UIVisualEffect *)_backgroundVisualEffectForContentView:(UIView *)contentView
{
    if ([_backgroundView isKindOfClass:[UIVisualEffectView class]]) {
        UIVisualEffectView *effectView = (id)_backgroundView;
        
        return effectView.effect;
    }
    return nil;
}

#pragma mark - Assets.

+ (CGFloat)cornerRadius
{
    return 14.0f;
}

+ (CGSize)getRectSizeWithCornerRadius:(CGFloat)cornerRadius capSize:(CGFloat *)cs
{
    const CGFloat continousCurvesSizeFactor = 1.528665f;
    
    CGFloat capSize = ceilf(cornerRadius * continousCurvesSizeFactor);
    CGFloat rectSize = 2.0f * capSize + 1.0f;
    
    if (cs) {
        *cs = capSize;
    }
    
    return (CGSize){ rectSize, rectSize };
}

+ (UIImage *)roundedShadowImage
{
    __weak static UIImage *_cachedShadowImage;
    
    UIImage *image = _cachedShadowImage;
    if (!image) {
        CGSize templateSize = [self getRectSizeWithCornerRadius:self.cornerRadius capSize:NULL];
        
        static const CGSize offset = { 0.0f, 2.0f };
        static const CGFloat radius = 15.0f;
        
        CGFloat pad = MAX(offset.width, offset.height) + radius;
        
        CGFloat capSize = floorf(MAX(templateSize.width, templateSize.height) / 2.0f) + pad;
        CGFloat rectSize = 2.0f * capSize + 1.0f;
        CGRect rect = CGRectMake(0.0, 0.0, rectSize, rectSize);
        
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0); {
            CGContextRef ctx = UIGraphicsGetCurrentContext();
            
            // 1. Save the initial state so we can fill later.
            CGContextSaveGState(ctx);
            
            // 2. Stroke a thin line around the path.
            CGRect fillingRect = (CGRect){ .origin = { pad, pad }, .size = templateSize };
            UIBezierPath *fillingBezierPath = [UIBezierPath bezierPathWithRoundedRect:fillingRect cornerRadius:self.cornerRadius + 1.0f];
            
            [[UIColor colorWithWhite:0.0f alpha:0.02f] setStroke];
            [fillingBezierPath setLineWidth:2.0f];
            [fillingBezierPath stroke];
            
            // 3. Clip by excluding the fill path.
            UIBezierPath *reverseBezierPath = [UIBezierPath bezierPathWithRect:rect];
            reverseBezierPath.usesEvenOddFillRule = YES;
            [reverseBezierPath appendPath:fillingBezierPath];
            [reverseBezierPath addClip];
            
            // 4. Fill to draw the outer shadow.
            CGContextSetShadow(ctx, offset, radius);
            [[UIColor colorWithWhite:0.0f alpha:0.7f] setFill];
            [fillingBezierPath fill];
            
            // 5. Restore the state.
            CGContextRestoreGState(ctx);
            
            // 6. Fill with the light gray.
            [[UIColor colorWithWhite:0.0f alpha:0.45f] setFill];
            [fillingBezierPath fill];
            
            image = UIGraphicsGetImageFromCurrentImageContext();
        }; UIGraphicsEndImageContext();
        
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(capSize, capSize, capSize, capSize)];
        image = [image imageWithAlignmentRectInsets:UIEdgeInsetsMake(-pad, -pad, -pad, -pad)];
        
        _cachedShadowImage = image;
    }
    
    return image;
}

+ (UIImage *)roundedMaskImage
{
    __weak static UIImage *_cachedRoundedImage;
    
    UIImage *image = _cachedRoundedImage;
    if (!image) {
        const CGFloat cornerRadius = self.cornerRadius;
        
        CGFloat capSize = 0.0f;
        CGSize rectSize = [self getRectSizeWithCornerRadius:cornerRadius capSize:&capSize];
        CGRect rect = (CGRect){ .size = rectSize };
        
        UIGraphicsBeginImageContextWithOptions(rectSize, NO, 0.0); {
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];
            
            [[UIColor blackColor] set];
            [path fill];
            
            image = UIGraphicsGetImageFromCurrentImageContext();
        }; UIGraphicsEndImageContext();
        
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(capSize, capSize, capSize, capSize)];
        
        _cachedRoundedImage = image;
    }
    
    return image;
}

@end
