//
//  Zuckerkit.m
//  Zuckerkit
//
//  Created by Mo Bitar on 8/21/13.
//  Copyright (c) 2014 Mo Bitar. All rights reserved.
//
//  See LICENSE for full license agreement.
//

#import "Zuckerkit.h"

#import <FacebookSDK/FacebookSDK.h>
#import <FacebookSDK/FBDialogs.h>
#import <FacebookSDK/FBWebDialogs.h>

@interface Zuckerkit ()
// single use blocks. these blocks are immediatly nulled after they are used
@property (nonatomic, copy) void(^openBlock)(NSError *error);
@property (nonatomic, copy) void(^permissionsBlock)(NSError *error);
@property (nonatomic) FBSession *session;
@end

@implementation Zuckerkit

+ (instancetype)sharedInstance
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self.class new];
    });
    return instance;
}

- (void)setAppId:(NSString *)appId
{
    [FBSettings setDefaultAppID:appId];
}

- (void)setAppDisplayName:(NSString *)displayName
{
    [FBSettings setDefaultDisplayName:displayName];
}

- (void)enablePlatformCompatibility:(BOOL)state
{
    [FBSettings enablePlatformCompatibility:state];
}

- (BOOL)handleOpenUrl:(NSURL*)url
{
   return [FBSession.activeSession handleOpenURL:url];
}

- (void)handleDidBecomeActive
{
    [FBSession.activeSession handleDidBecomeActive];
}

NSString *NSStringFromFBSessionState(FBSessionState state)
{
    switch (state) {
        case FBSessionStateClosed:
            return @"FBSessionStateClosed";
        case FBSessionStateClosedLoginFailed:
            return @"FBSessionStateClosedLoginFailed";
        case FBSessionStateCreated:
            return @"FBSessionStateCreated";
        case FBSessionStateCreatedOpening:
            return @"FBSessionStateCreatedOpening";
        case FBSessionStateCreatedTokenLoaded:
            return @"FBSessionStateCreatedTokenLoaded";
        case FBSessionStateOpen:
            return @"FBSessionStateOpen";
        case FBSessionStateOpenTokenExtended:
            return @"FBSessionStateOpenTokenExtended";
            
    }
    return @"Not Found";
}

- (void)openSessionWithBasicInfoThenRequestPublishPermissions:(void(^)(NSError *error))completionBlock
{
    [self openSessionWithPublicProfilePermissionsAsWellAs:nil completion:^(NSError *error) {
        if(error) {
            completionBlock(error);
            return;
        }
        
        [self requestPublishPermissions:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(error);
            });
        }];
    }];
}

- (void)openSessionWithPublicProfilePermissionsAsWellAs:(NSArray *)extraPermissions completion:(void(^)(NSError *error))completionBlock
{
    NSAssert([FBSettings defaultAppID], nil);
    NSAssert([FBSettings defaultDisplayName], nil);
    
    if(self.session.isOpen) {
        completionBlock(nil);
        return;
    }
    
    FBSessionLoginBehavior behavior = FBSessionLoginBehaviorUseSystemAccountIfPresent;
    
    // create a session object, with defaults accross the board, except that we provide a custom
    // instance of FBSessionTokenCachingStrategy
    FBSession *session = [[FBSession alloc] initWithAppID:nil
                                              permissions:[@[@"public_profile", @"user_birthday"] arrayByAddingObjectsFromArray:extraPermissions]
                                          urlSchemeSuffix:nil
                                       tokenCacheStrategy:nil];
    
    self.session = session;
    
    self.openBlock = completionBlock;
    
    [session openWithBehavior:behavior completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self sessionStateChanged:session state:status error:error open:YES permissions:NO];
        });
    }];
}

static NSString *const publish_actions = @"publish_actions";

- (void)requestPublishPermissions:(void(^)(NSError *error))completionBlock
{
    if([[self.session permissions] indexOfObject:publish_actions] != NSNotFound) {
        completionBlock(nil);
        return;
    }
    
    if([self.session isOpen] == NO) {
        // error
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Attempting to request publish permissions on unopened session." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        return;
    }
    
    self.permissionsBlock = completionBlock;
    
    [self.session requestNewPublishPermissions:@[publish_actions] defaultAudience:FBSessionDefaultAudienceEveryone completionHandler:^(FBSession *session, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self sessionStateChanged:session state:session.state error:error open:NO permissions:YES];
        });
    }];
}

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error open:(BOOL)open permissions:(BOOL)permissions
{
    if(self.openBlock && open) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.openBlock(error);
            self.openBlock = nil;
        });
    }
    else if(self.permissionsBlock && permissions) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.permissionsBlock(error);
            self.permissionsBlock = nil;
        });
    }
}

- (void)openSessionWithBasicInfoThenRequestPublishPermissionsAndGetAudienceType:(void(^)(NSError *error, FacebookAudienceType))completionBlock
{
    [self openSessionWithBasicInfoThenRequestPublishPermissions:^(NSError *error) {
        if(error) {
            completionBlock(error, 0);
            return;
        }
        
        [self getAppAudienceType:^(FacebookAudienceType audienceType, NSError *error) {
            if(error) {
                completionBlock(error, 0);
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(nil, audienceType);
            });
        }];
    }];
}

- (void)getUserInfo:(void(^)(id<FBGraphUser> user, NSError *error))completionBlock
{
    FBRequest *me = [[FBRequest alloc] initWithSession:self.session
                                             graphPath:@"me"];
    [me startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        completionBlock(result, error);
    }];
}

- (void)getFriends:(void(^)(NSArray *friends, NSError *error))completionBlock
{
    FBRequest* friendsRequest = [FBRequest requestForMyFriends];
    friendsRequest.session = [self session];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection, NSDictionary* result, NSError *error) {
        if(error) {
            completionBlock(nil, error);
            return;
        }
        
        NSArray* friends = result[@"data"];
        completionBlock(friends, nil);
    }];
}

- (void)showAppRequestDialogueWithMessage:(NSString*)message toUserId:(NSString*)userId
{
    [FBWebDialogs presentDialogModallyWithSession:[self session] dialog:@"apprequests"
      parameters:@{@"to" : userId, @"message" : message}
      handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
        
    }];
}

- (NSString*)accessToken
{
    return [[[self session] accessTokenData] accessToken];
}

- (void)logout
{
    [FBSession.activeSession closeAndClearTokenInformation];
}

#pragma mark - Other

FacebookAudienceType AudienceTypeForValue(NSString *value)
{
    if([value isEqualToString:@"ALL_FRIENDS"])        return FacebookAudienceTypeFriends;
    if([value isEqualToString:@"SELF"])               return FacebookAudienceTypeSelf;
    if([value isEqualToString:@"EVERYONE"])           return FacebookAudienceTypeEveryone;
    if([value isEqualToString:@"FRIENDS_OF_FRIENDS"]) return FacebookAudienceTypeFriends;
    if([value isEqualToString:@"NO_FRIENDS"])         return FacebookAudienceTypeSelf;
    return FacebookAudienceTypeSelf;
}

BOOL FacebookAudienceTypeIsRestricted(FacebookAudienceType type)
{
    return type == FacebookAudienceTypeSelf;
}

- (void)getAppAudienceType:(void(^)(FacebookAudienceType audienceType, NSError *error))completionBlock
{
    if(![[[self session] accessTokenData] accessToken]) {
        completionBlock(0, [NSError new]);
        return;
    }
    
    NSString *query = @"SELECT value FROM privacy_setting WHERE name = 'default_stream_privacy'";
    NSDictionary *queryParam = @{ @"q": query, @"access_token" :  [[[self session] accessTokenData] accessToken]};
    
    [FBRequestConnection startWithGraphPath:@"/fql" parameters:queryParam HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if(error) {
            completionBlock(0, error);
            return;
        }
        
        FBGraphObject *object = result;
        id type = [object objectForKey:@"data"][0][@"value"];
        completionBlock(AudienceTypeForValue(type), nil);
    }];
}

- (void)requestProfilePictureURLWithCompletionBlock:(void(^)(NSURL *imageURL, NSError *error))completionBlock
{
    FBRequest *request = [FBRequest requestForMe];
    request.session = [self session];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *FBuser, NSError *error) {
        if (error) {
            completionBlock(nil, error);
            return;
        }
        
        NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [FBuser username]];
        completionBlock([NSURL URLWithString:userImageURL], nil);
    }];
}

@end
