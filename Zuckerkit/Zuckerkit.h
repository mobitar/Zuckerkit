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
#import <FacebookSDK/FacebookSDK.h>

typedef enum {
    ZuckerImageSizeSquare, // 50px Wide  50px High
    ZuckerImageImageSizeSmall, // 50px Wide  Variable Height
    ZuckerImageImageSizeNormal, // 100px Width Variable Height
    ZuckerImageImageSizeLarge // 200px Wide Variable Height
} ZuckerImageSize;

typedef NS_ENUM(NSInteger, FacebookAudienceType)
{
    FacebookAudienceTypeSelf = 0,
    FacebookAudienceTypeFriends,
    FacebookAudienceTypeEveryone
};

BOOL FacebookAudienceTypeIsRestricted(FacebookAudienceType type);

@interface Zuckerkit : NSObject

+ (instancetype)sharedInstance;

- (void)openSessionWithBasicInfo:(void(^)( NSError *error))completionBlock;
- (void)requestPublishPermissions:(void(^)( NSError *error))completionBlock;
- (void)getUserInfo:(void(^)(id<FBGraphUser> user, NSError *error))completionBlock;
- (void)openSessionWithBasicInfoThenRequestPublishPermissions:(void(^)(NSError *error))completionBlock;
- (void)openSessionWithBasicInfoThenRequestPublishPermissionsAndGetAudienceType:(void(^)(NSError *error, FacebookAudienceType))completionBlock;

- (void)getFriends:(void(^)(NSArray *friends, NSError *error))completionBlock;
- (void)getAppAudienceType:(void(^)(FacebookAudienceType audienceType, NSError *error))completionBlock;
- (void)showAppRequestDialogueWithMessage:(NSString*)message toUserId:(NSString*)userId;
- (void)facebookImageBlockWithCompletionHandler:(void(^)(UIImage *profilePicture, NSError *error))completionHandler;

- (void)postFeedToUserFacebookWall:(NSString*)postFeed;

/////token management
- (void)saveUserInformation:(NSDictionary*)userInfo;
- (NSDictionary*)loadUserInfo;
- (BOOL)isAuthorized;
- (NSString*)accessToken;

- (void)logout;
- (BOOL)handleOpenUrl:(NSURL*)url;
- (void)handleDidBecomeActive;

@end
