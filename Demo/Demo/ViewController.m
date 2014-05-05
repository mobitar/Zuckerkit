//
//  ViewController.m
//  Demo
//
//  Created by Mo Bitar on 8/21/13.
//  Copyright (c) 2013 progenius. All rights reserved.
//

#import "ViewController.h"
#import "Zuckerkit.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self zuckerIn];
    });
}

- (void)zuckerIn
{
    [[Zuckerkit sharedInstance] openSessionWithBasicInfoThenRequestPublishPermissions:^(NSError *error) {
        if(error) {
            
            [[[UIAlertView alloc] initWithTitle:@"Fail" message:error.description
              delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            return;
        }
        [[Zuckerkit sharedInstance] getUserInfo:^(id<FBGraphUser> user, NSError *error) {
        
                [[Zuckerkit sharedInstance] storeFacebookId:user.id];
        
         }];
    }];
}
- (IBAction)downloadFacebookImage:(id)sender {
    
    [[Zuckerkit sharedInstance] getFacebookProfilePicture:^(NSError *error, UIImage *image) {
        
        NSLog(@"size--%@",NSStringFromCGSize(image.size));
        [self.imageView setImage:image];
    }];
}

@end
