//
//  DemoControllerAction.h
//  MMNotificationsDemo
//
//  Created by Matías Martínez on 1/30/18.
//  Copyright © 2018 Matías Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DemoControllerActionHandler)(void);

@interface DemoControllerAction : NSObject

+ (instancetype)actionWithTitle:(NSString *)title handler:(DemoControllerActionHandler)handler;

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) DemoControllerActionHandler handler;

@end
