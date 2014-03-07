//
//  FMProfileViewController.m
//  MatchedUp
//
//  Created by Fredrick Myers on 3/6/14.
//  Copyright (c) 2014 Fredrick Myers. All rights reserved.
//

#import "FMProfileViewController.h"

@interface FMProfileViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UILabel *tagLineLabel;

@end

@implementation FMProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    PFFile *pictureFile = self.photo[kFMPhotoPictureKey];
    [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        self.profilePictureImageView.image = [UIImage imageWithData:data];
    }];
    
    PFUser *user = self.photo[kFMPhotoUserKey];
    self.locationLabel.text = user[kFMUserProfileKey][kFMUserProfileLocationKey];
    self.ageLabel.text = [NSString stringWithFormat:@"%@", user[kFMUserProfileKey][kFMUserProfileAgeKey]];
    self.statusLabel.text = user[kFMUserProfileKey][kFMUserProfileRelationshipStatusKey];
    self.tagLineLabel.text = user[kFMUserTagLineKey];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
