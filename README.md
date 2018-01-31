# MMNotifications
A simple and customizable way to display in-app notifications. They match the system's look and feel, fully supporting iPhone X and the iPad.

![MMNotifications](https://github.com/matmartinez/MMNotifications/blob/master/Screenshot.png)

## Installation

### From CocoaPods 
[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like `MMNotifications` in your projects. First, add the following line to your [Podfile](http://guides.cocoapods.org/using/using-cocoapods.html):

```ruby
pod 'MMNotifications'
```

Second, install `MMNotifications` into your project:

```ruby
pod install
```

## Usage

If you ever tried the local notifications API, this will be easy as pie.

You create a `MMLocalNotification` object and set a title, message, and image:

```objective-c
// Create and configure the notification.
MMLocalNotification *notification = [[MMLocalNotification alloc] init];
notification.title = @"This is a simple notification";
notification.message = @"The message goes here.";
notification.image = [UIImage imageNamed:@"ExampleIcon"];
```

You can optionally add some actions! These will be displayed in the notification itself:

```objective-c
// Add action an "Okay" button:
MMNotificationAction *okay = [MMNotificationAction actionWithTitle:@"Okay" style:MMNotificationActionStyleDone handler:^(MMNotificationAction *action){
	// Handle this action.
}];

[notification addAction:okay];
```

Finally, you can schedule the notification for a future date or present it right away:

```objective-c
// Grab the presentation controller:
MMNotificationPresentationController *controller = [MMNotificationPresentationController sharedPresentationController];

// Present it right away...
[controller presentLocalNotificationNow:notification];

// ...or schedule it for a future date.
notification.fireDate = [NSDate dateWithDateIntervalSinceNow:(4000)];

[controller scheduleLocalNotification:notification];

```

The presentation controller will handle the hard stuff for you! For example, it will queue and delay notifications.

## Customization

You can create a custom notification view. Much like an `UICollectionView`, you can register a custom view class for your notifications.

 ```objective-c
// Implement an UIView subclass that conforms to the <MMNotificationView> protocol:
Class notificationViewClass = [MyCustomNotificationView class];

// Set a category to identify notifications that will use your custom class:
NSString *category = @"MyCategory";

// Register your class with the presentation controller:
MMNotificationPresentationController *controller = [MMNotificationPresentationController sharedPresentationController];

[controller registerViewClass:notificationViewClass forNotificationCategory:category];
```

Please refer to the documentation from the `<MMNotificationView>` protocol on how to configure your custom view.

## Development
Pull requests are welcome and mostly appreciated.

