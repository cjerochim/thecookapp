//
//  EventHelper.h
//  Cook
//
//  Created by Jeff Tan-Ang on 11/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventHelper : NSObject

+ (void)registerLoginSucessful:(id)observer selector:(SEL)selector;
+ (void)postLoginSuccessful:(BOOL)success;
+ (void)unregisterLoginSucessful:(id)observer;
+ (BOOL)loginSuccessfulForNotification:(NSNotification *)notification;

+ (void)registerBenchtopFreeze:(id)observer selector:(SEL)selector;
+ (void)postBenchtopFreeze:(BOOL)freeze;
+ (void)unregisterBenchtopFreeze:(id)observer;
+ (BOOL)benchFreezeForNotification:(NSNotification *)notification;

@end
