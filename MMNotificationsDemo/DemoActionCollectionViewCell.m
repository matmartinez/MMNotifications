//
//  DemoActionCollectionViewCell.m
//  MMNotificationsDemo
//
//  Created by Matías Martínez on 1/31/18.
//  Copyright © 2018 Matías Martínez. All rights reserved.
//

#import "DemoActionCollectionViewCell.h"

@implementation DemoActionCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        backgroundView.backgroundColor = [UIColor whiteColor];
        backgroundView.layer.cornerRadius = 8.0f;
        backgroundView.layer.shadowColor = [UIColor blackColor].CGColor;
        backgroundView.layer.shadowOffset = (CGSize){ .height = 4.0f };
        backgroundView.layer.shadowRadius = 16.0f;
        backgroundView.layer.shadowOpacity = 0.15f;
        backgroundView.layer.shouldRasterize = YES;
        
#if defined(__has_attribute) && __has_attribute(availability)
        if (@available(iOS 13.0, *)) {
            backgroundView.backgroundColor = UIColor.secondarySystemGroupedBackgroundColor;
        }
#endif
        
        self.backgroundView = backgroundView;
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        textLabel.font = [UIFont boldSystemFontOfSize:17.0f];
        textLabel.numberOfLines = 4;
        textLabel.textColor = self.tintColor;
        
        _textLabel = textLabel;
        
        [self.contentView addSubview:textLabel];
    }
    return self;
}

- (void)tintColorDidChange
{
    [super tintColorDidChange];
    
    self.textLabel.textColor = self.tintColor;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = (CGRect){
        .size = self.bounds.size
    };
    
    const CGFloat spacing = 16.0f;
    const CGRect boundingRect = CGRectInset(bounds, spacing, spacing);
    
    CGSize textSize = [self.textLabel sizeThatFits:boundingRect.size];
    CGRect textRect = (CGRect){
        .origin = boundingRect.origin,
        .size = textSize
    };
    
    self.textLabel.frame = textRect;
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self setHighlightedOrSelected];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self setHighlightedOrSelected];
}

- (void)setHighlightedOrSelected
{
    const CGAffineTransform transform = (self.isHighlighted || self.isSelected) ? CGAffineTransformMakeScale(0.95f, 0.95f) : CGAffineTransformIdentity;
    
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction animations:^{
        self.transform = transform;
    } completion:nil];
}

@end
