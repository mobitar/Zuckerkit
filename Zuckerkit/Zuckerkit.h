//
//  Zuckerkit.h
//  Zuckerkit
//
//  Created by Mo Bitar on 8/21/13.
//  Copyright (c) 2014 Mo Bitar. All rights reserved.
//
//  See LICENSE for full license agreement.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FBGraphObject.h>
#import <FacebookSDK/FBGraphUser.h>

typedef NS_ENUM(NSInteger, FacebookAudienceType)
{
    FacebookAudienceTypeSelf = 0,
    FacebookAudienceTypeFriends,
    FacebookAudienceTypeEveryone
};

BOOL FacebookAudienceTypeIsRestricted(FacebookAudienceType type);

@interface Zuckerkit : NSObject

+ (instancetype)sharedInstance;

/** Opens the session with the "public_profile" read permissions. You can pass in extra permissions, like "email" to request additional read permissions */
- (void)openSessionWithPublicProfilePermissionsAsWellAs:(NSArray *)extraPermissions completion:(void(^)(NSError *error))completionBlock;

- (void)requestPublishPermissions:(void(^)( NSError *error))completionBlock;
- (void)getUserInfo:(void(^)(id<FBGraphUser> user, NSError *error))completionBlock;
- (void)openSessionWithBasicInfoThenRequestPublishPermissions:(void(^)(NSError *error))completionBlock;
- (void)openSessionWithBasicInfoThenRequestPublishPermissionsAndGetAudienceType:(void(^)(NSError *error, FacebookAudienceType))completionBlock;

- (void)getFriends:(void(^)(NSArray *friends, NSError *error))completionBlock;
- (void)getAppAudienceType:(void(^)(FacebookAudienceType audienceType, NSError *error))completionBlock;
- (void)showAppRequestDialogueWithMessage:(NSString*)message toUserId:(NSString*)userId;

- (void)requestProfilePictureURLWithCompletionBlock:(void(^)(NSURL *imageURL, NSError *error))completionBlock;

// Config
- (void)setAppId:(NSString *)appId;
- (void)setAppDisplayName:(NSString *)displayName;

- (NSString*)accessToken;
- (BOOL)handleOpenUrl:(NSURL*)url;
- (void)handleDidBecomeActive;
- (void)logout;
@end
