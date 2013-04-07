//
//  EventHelper.m
//  Cook
//
//  Created by Jeff Tan-Ang on 11/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "EventHelper.h"

@implementation EventHelper

#define kEventBenchtopFreeze        @"CKEventBenchtopFreeze"
#define kBoolBenchtopFreeze         @"CKBoolBenchtopFreeze"
#define kEventLoginSuccessful       @"CKEventLoginSuccessful"
#define kBoolLoginSuccessful        @"CKBoolLoginSuccessful"
#define kEventOpenBook              @"CKEventOpenBook"
#define kBoolOpenBook               @"CKBoolOpenBook"
#define kEventEditMode              @"CKEventEditMode"
#define kBoolEditMode               @"CKBoolEditMode"
#define kBoolEditModeSave           @"CKBoolEditModeSave"
#define kEventFollowUpdated         @"CKEventFollowUpdated"
#define kBoolFollow                 @"CKBoolFollow"
#define kBoolFriendsFollow          @"CKBoolFriends"
#define kEventLogout                @"CKEventLogout"

#pragma mark - Login successful event

+ (void)registerLoginSucessful:(id)observer selector:(SEL)selector {
    [EventHelper registerObserver:observer withSelector:selector toEventName:kEventLoginSuccessful];
}

+ (void)postLoginSuccessful:(BOOL)success {
    [EventHelper postEvent:kEventLoginSuccessful
              withUserInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:success]
                                                       forKey:kBoolLoginSuccessful]];
}

+ (void)unregisterLoginSucessful:(id)observer {
    [EventHelper unregisterObserver:observer toEventName:kEventLoginSuccessful];
}

+ (BOOL)loginSuccessfulForNotification:(NSNotification *)notification {
    return [[[notification userInfo] valueForKey:kBoolLoginSuccessful] boolValue];
}

#pragma mark - Logout 

+ (void)registerLogout:(id)observer selector:(SEL)selector {
    [EventHelper registerObserver:observer withSelector:selector toEventName:kEventLogout];
}

+ (void)postLogout {
    [EventHelper postEvent:kEventLogout];
}

+ (void)unregisterLogout:(id)observer {
    [EventHelper unregisterObserver:observer toEventName:kEventLogout];
}

#pragma mark - Benchtop events

+ (void)registerBenchtopFreeze:(id)observer selector:(SEL)selector {
    [EventHelper registerObserver:observer withSelector:selector toEventName:kEventBenchtopFreeze];
}

+ (void)postBenchtopFreeze:(BOOL)freeze {
    [EventHelper postEvent:kEventBenchtopFreeze
              withUserInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:freeze]
                                                       forKey:kBoolBenchtopFreeze]];
}

+ (void)unregisterBenchtopFreeze:(id)observer {
    [EventHelper unregisterObserver:observer toEventName:kEventBenchtopFreeze];
}

+ (BOOL)benchFreezeForNotification:(NSNotification *)notification {
    return [[[notification userInfo] valueForKey:kBoolBenchtopFreeze] boolValue];
}

#pragma mark - Book events

+ (void)registerOpenBook:(id)observer selector:(SEL)selector {
    [EventHelper registerObserver:observer withSelector:selector toEventName:kEventOpenBook];
}

+ (void)postOpenBook:(BOOL)open {
    [EventHelper postEvent:kEventOpenBook
              withUserInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:open]
                                                       forKey:kBoolOpenBook]];
}

+ (void)unregisterOpenBook:(id)observer {
    [EventHelper unregisterObserver:observer toEventName:kEventOpenBook];
}

+ (BOOL)openBookForNotification:(NSNotification *)notification {
    return [[[notification userInfo] valueForKey:kBoolOpenBook] boolValue];
}

#pragma mark - Edit mode

+ (void)registerEditMode:(id)observer selector:(SEL)selector {
    [EventHelper registerObserver:observer withSelector:selector toEventName:kEventEditMode];
}

+ (void)postEditMode:(BOOL)editMode {
    [self postEditMode:editMode save:NO];
}

+ (void)postEditMode:(BOOL)editMode save:(BOOL)save {
    [EventHelper postEvent:kEventEditMode
              withUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:editMode], kBoolEditMode,
                            [NSNumber numberWithBool:save], kBoolEditModeSave,
                            nil]];
}

+ (void)unregisterEditMode:(id)observer {
    [EventHelper unregisterObserver:observer toEventName:kEventEditMode];
}

+ (BOOL)editModeForNotification:(NSNotification *)notification {
    return [[[notification userInfo] valueForKey:kBoolEditMode] boolValue];
}

+ (BOOL)editModeSaveForNotification:(NSNotification *)notification {
    return [[[notification userInfo] valueForKey:kBoolEditModeSave] boolValue];
}

#pragma mark - Follows

+ (void)registerFollowUpdated:(id)observer selector:(SEL)selector {
    [EventHelper registerObserver:observer withSelector:selector toEventName:kEventFollowUpdated];
}

+ (void)postFollow:(BOOL)follow friends:(BOOL)friends {
    [EventHelper postEvent:kEventFollowUpdated
              withUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithBool:follow], kBoolFollow,
                            [NSNumber numberWithBool:friends], kBoolFriendsFollow,
                            nil]];
}

+ (void)unregisterFollowUpdated:(id)observer {
    [EventHelper unregisterObserver:observer toEventName:kEventFollowUpdated];
}

+ (BOOL)followForNotification:(NSNotification *)notification {
    return [[[notification userInfo] valueForKey:kBoolFollow] boolValue];
}

+ (BOOL)friendsBookFollowUpdatedForNotification:(NSNotification *)notification {
    return [[[notification userInfo] valueForKey:kBoolFriendsFollow] boolValue];
}

#pragma mark - Private

+ (void)registerObserver:(id)observer withSelector:(SEL)selector toEventName:(NSString *)eventName {
    [[NSNotificationCenter defaultCenter] addObserver:observer
                                             selector:selector
                                                 name:eventName object:nil];
}

+ (void)postEvent:(NSString *)eventName {
    [EventHelper postEvent:eventName withUserInfo:nil];
}

+ (void)postEvent:(NSString *)eventName withUserInfo:(NSDictionary *)theUserInfo {
    [[NSNotificationCenter defaultCenter] postNotificationName:eventName object:nil userInfo:theUserInfo];
}

+ (void)unregisterObserver:(id)observer toEventName:(NSString *)eventName {
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:eventName object:nil];
}

@end
