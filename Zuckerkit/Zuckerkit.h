
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <FacebookSDK/FBGraphObject.h>
#import <FacebookSDK/FBGraphUser.h>
#import <FacebookSDK/FacebookSDK.h>

typedef NS_ENUM(NSInteger, FacebookAudienceType)
{
    FacebookAudienceTypeSelf = 0,
    FacebookAudienceTypeFriends,
    FacebookAudienceTypeEveryone
};
// Image sizes
typedef enum {
    FacebookImageSizeMini, // 24px by 24px
    FacebookImageSizeNormal, // 48x48
    FacebookImageSizeBigger, // 73x73
    FacebookImageSizeOriginal // original size of image
} FacebookImageSize;
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
- (void)getFacebookProfilePicture:(void(^)(NSError *error, UIImage *image))completionBlock;

/////manage facebook access token
- (void)storeAccessToken:(NSString*)accessToken;
- (NSString*)loadAccessToken;
////manage user info
- (void)storeFacebookId:(NSString*)facebookId;
- (NSString*)loadFacebookId;

- (NSString*)accessToken;
- (BOOL)handleOpenUrl:(NSURL*)url;
- (void)handleDidBecomeActive;
- (void)logout;
@end
