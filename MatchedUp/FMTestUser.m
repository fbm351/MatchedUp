//
//  FMTestUser.m
//  MatchedUp
//
//  Created by Fredrick Myers on 3/7/14.
//  Copyright (c) 2014 Fredrick Myers. All rights reserved.
//

#import "FMTestUser.h"

@implementation FMTestUser

+ (void)saveTestUserToParse
{
    PFUser *newUser = [PFUser user];
    newUser.username = @"user1";
    newUser.password = @"password1";
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSDictionary *profile = @{kFMUserProfileAgeKey : @28, kFMUserProfileBirthdayKey : @"12/26/1980", kFMUserProfileFirstNameKey : @"John", kFMUserProfileGenderKey : @"male", kFMUserProfileLocationKey : @"Berlin, Germany", kFMUserProfileNameKey : @"John Doe"};
            [newUser setObject:profile forKey:kFMUserProfileKey];
            [newUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                UIImage *profileImage = [UIImage imageNamed:@"IMG_2425.jpeg"];
                NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.8);
                PFFile *photoFile = [PFFile fileWithData:imageData];
                [photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        PFObject *photo = [PFObject objectWithClassName:kFMPhotoClassKey];
                        [photo setObject:newUser forKey:kFMPhotoUserKey];
                        [photo setObject:photoFile forKey:kFMPhotoPictureKey];
                        [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            NSLog(@"Photo Saved");
                        }];
                    }
                }];
            }];
        }
    }];
}

@end
