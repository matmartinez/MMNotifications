//
//  ViewController.m
//  MMNotificationsDemo
//
//  Created by Matías Martínez on 1/30/18.
//  Copyright © 2018 Matías Martínez. All rights reserved.
//

#import "DemoViewController.h"
#import "DemoActionCollectionViewCell.h"
#import "DemoCustomNotificationView.h"
#import "DemoControllerAction.h"

#import "MMLocalNotification.h"
#import "MMNotificationPresentationController.h"

@interface DemoViewController ()

@property (copy, nonatomic) NSArray <DemoControllerAction *> *actions;

@end

@implementation DemoViewController

static NSString *DemoCellReuseIdentifier = @"DemoCellReuseIdentifier";

- (instancetype)init
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    self = [super initWithCollectionViewLayout:flowLayout];
    if (self) {
        self.title = NSLocalizedString(@"MMNotifications Examples", nil);
        
        [self setDemoActions];
    }
    return self;
}

- (void)setDemoActions
{
    MMNotificationPresentationController *controller = [MMNotificationPresentationController sharedPresentationController];
    
    self.actions =
    @[
      [DemoControllerAction actionWithTitle:NSLocalizedString(@"Show a simple notification", nil) handler:^{
          MMLocalNotification *notification = [[MMLocalNotification alloc] init];
          notification.title = @"This is a simple notification";
          notification.message = @"The message goes here.";
          notification.image = [UIImage imageNamed:@"ExampleIcon"];
          
          [controller presentLocalNotificationNow:notification];
      }],
      
      [DemoControllerAction actionWithTitle:NSLocalizedString(@"Show a notification with actions", nil) handler:^{
          MMLocalNotification *notification = [[MMLocalNotification alloc] init];
          notification.title = @"This is a notification with actions";
          notification.message = @"These can be dismissed by selecting an action.";
          
          // Add actions:
          MMNotificationAction *okay = [MMNotificationAction actionWithTitle:NSLocalizedString(@"Okay", nil) style:MMNotificationActionStyleDone handler:^(MMNotificationAction *action){
              // Handle the action...
          }];
          
          [notification addAction:okay];
          
          MMNotificationAction *nope = [MMNotificationAction actionWithTitle:NSLocalizedString(@"Nope", nil) style:MMNotificationActionStyleCancel handler:^(MMNotificationAction *action){
              // Handle the action...
          }];
          
          [notification addAction:nope];
          
          [controller presentLocalNotificationNow:notification];
      }],
      
      [DemoControllerAction actionWithTitle:NSLocalizedString(@"Show 3 notifications at a time", nil) handler:^{
          for (NSUInteger iteration = 0; iteration < 3; iteration += 1) {
              MMLocalNotification *notification = [[MMLocalNotification alloc] init];
              notification.title = [NSString stringWithFormat:@"Notification #%@", @(iteration + 1)];
              notification.message = @"Notifications are automatically queued and presented in order.";
              notification.image = [UIImage imageNamed:@"ExampleIcon"];
              
              [controller presentLocalNotificationNow:notification];
          }
      }],
      
      [DemoControllerAction actionWithTitle:NSLocalizedString(@"Delay a notification by 5s", nil) handler:^{
          NSDate *whenToFire = [NSDate dateWithTimeIntervalSinceNow:5000];
          
          MMLocalNotification *notification = [[MMLocalNotification alloc] init];
          notification.title = @"This notification was scheduled";
          notification.message = @"It should appear delayed.";
          notification.fireDate = whenToFire;
          
          [controller scheduleLocalNotification:notification];
      }],
      
      [DemoControllerAction actionWithTitle:NSLocalizedString(@"Cancel all scheduled notifications", nil) handler:^{
          [controller cancelAllLocalNotifications];
      }],
      
      [DemoControllerAction actionWithTitle:NSLocalizedString(@"Show a custom notification", nil) handler:^{
          NSString *myCustomCategory = @"MyCustomCategory";
          
          [controller registerViewClass:[DemoCustomNotificationView class] forNotificationCategory:myCustomCategory];
          
          MMLocalNotification *notification = [[MMLocalNotification alloc] init];
          notification.title = @"This is a custom notification";
          notification.category = myCustomCategory;
          
          [controller presentLocalNotificationNow:notification];
      }],
      
      ];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.collectionView registerClass:[DemoActionCollectionViewCell class] forCellWithReuseIdentifier:DemoCellReuseIdentifier];
    
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGRect bounds = (CGRect){
        .size = self.view.bounds.size
    };
    
    const CGFloat preferredItemDimension = 136.0f;
    const CGFloat interSpacing = 8.0f;
    const CGFloat padding = 16.0f;
    const CGFloat leadingForDemo = 36.0f;
    
    const NSUInteger itemsPerLine = floor(CGRectGetWidth(bounds) / preferredItemDimension);
    const CGFloat itemDimension = floor((CGRectGetWidth(bounds) - (padding * 2.0f) - ((itemsPerLine - 1) * interSpacing)) / itemsPerLine);
    
    UICollectionViewFlowLayout *flowLayout = (id)self.collectionViewLayout;
    flowLayout.itemSize = (CGSize){ itemDimension, itemDimension };
    flowLayout.minimumInteritemSpacing = interSpacing;
    flowLayout.minimumLineSpacing = interSpacing;
    flowLayout.sectionInset = (UIEdgeInsets){ padding + leadingForDemo, padding, padding, padding };
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.actions.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DemoActionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DemoCellReuseIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = self.actions[indexPath.item].title;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.actions[indexPath.item].handler();
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

@end
