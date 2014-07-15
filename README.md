#Zuckerkit

Zuckerkit is a wrapper around the Facebook SDK that makes common tasks easy. Things you can do:


Open session with basic info

```
- (void)openSessionWithBasicInfo:(void(^)( NSError *error))completionBlock;
```

Request publish permissions

```
- (void)requestPublishPermissions:(void(^)( NSError *error))completionBlock;
```

Get user info (name, email, id, etc)

```
- (void)getUserInfo:(void(^)(id<FBGraphUser> user, NSError *error))completionBlock;
```

Open session with basic info then request publish permissions 

```
- (void)openSessionWithBasicInfoThenRequestPublishPermissions:(void(^)(NSError *error))completionBlock;
```

Get friends
	
```
- (void)getFriends:(void(^)(NSArray *friends, NSError *error))completionBlock;
```

Get app audience type (The visibility for the app, i.e Public, Friends, Only Me)

```
- (void)getAppAudienceType:(void(^)(FacebookAudienceType audienceType, NSError *error))completionBlock;
```

Invite friend to app via request dialogue (sends a request to a friend to join the current app)
	
```
- (void)showAppRequestDialogueWithMessage:(NSString*)message toUserId:(NSString*)userId;
```

#Usage

1. In your AppDelegate.m, implement the following methods (or add to them if they already exist):

	``` objective-c
	- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
	{
		[[Zuckerkit sharedInstance] setAppDisplayName:@"app_display_name"];
        [[Zuckerkit sharedInstance] setAppId:@"app_id"];
	}
	
	- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
	   sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
	{	
	    if([url.absoluteString rangeOfString:@"fb"].location != NSNotFound) {
	        return [[Zuckerkit sharedInstance] handleOpenUrl:url];
	    }
	    return NO;
	}
	
	- (void)applicationDidBecomeActive:(UIApplication *)application
	{
	    [[Zuckerkit sharedInstance] handleDidBecomeActive];
	}
	```
	   
2. As part of the normal FacebookSDK integration, register your Facebook App Id in your app's URL schemes (in your plist file):
	  
	  URL types: (Array)
 	  - Item 0 (Dictionary)
    	- URL Schemes (Array)
    		- Item 0 (String, set equal to your Facebook App Id)
    		
	   


#Contribution
I've added methods to this kit as I've needed them, and haven't yet crossed path with all parts of the SDK. If you're familiar with various parts of the SDK and know of some methods that may be helpful, please feel free to contribute.