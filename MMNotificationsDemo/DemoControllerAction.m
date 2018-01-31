//
//  DemoControllerAction.m
//  MMNotificationsDemo
//
//  Created by Matías Martínez on 1/30/18.
//  Copyright © 2018 Matías Martínez. All rights reserved.
//

#import "DemoControllerAction.h"

@implementation DemoControllerAction

+ (instancetype)actionWithTitle:(NSString *)title handler:(DemoControllerActionHandler)handler
{
    DemoControllerAction *action = [[DemoControllerAction alloc] init];
    action->_handler = [handler copy];
    action->_title = [title copy];
    
    return action;
}

@end
