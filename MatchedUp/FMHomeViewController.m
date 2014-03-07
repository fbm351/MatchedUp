//
//  FMHomeViewController.m
//  MatchedUp
//
//  Created by Fredrick Myers on 3/5/14.
//  Copyright (c) 2014 Fredrick Myers. All rights reserved.
//

#import "FMHomeViewController.h"

@interface FMHomeViewController ()

@property (strong, nonatomic) IBOutlet UIBarButtonItem *chatBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingBarButtonItem;
@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UILabel *tagLineLabel;
@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) IBOutlet UIButton *infoButton;
@property (strong, nonatomic) IBOutlet UIButton *dislikeButton;

@property (strong, nonatomic) NSArray *photos;
@property (strong, nonatomic) PFObject *photo;
@property (strong, nonatomic) NSMutableArray *activities;

@property (nonatomic) int currentPhotoIndex;
@property (nonatomic) BOOL isLikedByCurrentUser;
@property (nonatomic) BOOL isDisLikedByCurrentUser;

@end

@implementation FMHomeViewController

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
    
    //self.likeButton.enabled = NO;
    //self.dislikeButton.enabled = NO;
    self.infoButton.enabled = NO;
    self.currentPhotoIndex = 0;
    
    PFQuery *query = [PFQuery queryWithClassName:kFMPhotoClassKey];
    [query includeKey:kFMPhotoUserKey];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            self.photos = objects;
            [self queryForCurrentPhotoIndex];
        }
        else
        {
            NSLog(@"%@", error);
        }
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)chatBarButtonItemPressed:(UIBarButtonItem *)sender
{
    
}

- (IBAction)settingsBarButtonItemPressed:(UIBarButtonItem *)sender
{
    
}

- (IBAction)likeButtonPressed:(UIButton *)sender
{
    [self checkLike];
}

- (IBAction)dislikeButtonPressed:(UIButton *)sender
{
    [self checkDisLike];
}

- (IBAction)infoButtonPressed:(UIButton *)sender
{
    
}

#pragma mark - Helper Methods

- (void)queryForCurrentPhotoIndex
{
    if ([self.photos count] > 0) {
        self.photo = self.photos[self.currentPhotoIndex];
        PFFile *file = self.photo[kFMPhotoPictureKey];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:data];
                self.photoImageView.image = image;
                [self updateView];
            }
            else
            {
                NSLog(@"%@", error);
            }
        }];
    }
}

- (void)updateView
{
    self.firstNameLabel.text = self.photo[kFMPhotoUserKey][kFMUserProfileKey][kFMUserProfileFirstNameKey];
    self.ageLabel.text = [NSString stringWithFormat:@"%@", self.photo[kFMPhotoUserKey][kFMUserProfileKey][kFMUserProfileAgeKey]];
    self.tagLineLabel.text = self.photo[kFMUserProfileKey][@"tagLine"];

}

- (void)setupNextPhoto
{
    if (self.currentPhotoIndex + 1 < self.photos.count) {
        self.currentPhotoIndex ++;
        [self queryForCurrentPhotoIndex];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No More Users" message:@"Check back later for more people!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alertView show];
    }
}

- (void)saveLike
{
    PFObject *likeActivity = [PFObject objectWithClassName:@"Activity"];
    [likeActivity setObject:@"like" forKey:@"type"];
    [likeActivity setObject:[PFUser currentUser] forKey:@"fromUser"];
    [likeActivity setObject:[self.photo objectForKey:@"user"] forKey:@"toUser"];
    [likeActivity setObject:self.photo forKey:@"photo"];
    [likeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.isLikedByCurrentUser = YES;
        self.isDisLikedByCurrentUser = NO;
        [self.activities addObject:likeActivity];
        [self setupNextPhoto];
    }];
}

- (void)saveDisLike
{
    PFObject *disLikeActivity = [PFObject objectWithClassName:@"Activity"];
    [disLikeActivity setObject:@"dislike" forKey:@"type"];
    [disLikeActivity setObject:[PFUser currentUser] forKey:@"fromUser"];
    [disLikeActivity setObject:[self.photo objectForKey:@"user"] forKey:@"toUser"];
    [disLikeActivity setObject:self.photo forKey:@"photo"];
    [disLikeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.isLikedByCurrentUser = NO;
        self.isDisLikedByCurrentUser = YES;
        [self.activities addObject:disLikeActivity];
        [self setupNextPhoto];
    }];
}

- (void)checkLike
{
    if (self.isLikedByCurrentUser)
    {
        [self setupNextPhoto];
        return;
    }
    else if (self.isLikedByCurrentUser)
    {
        for (PFObject *activity in self.activities)
        {
            [activity deleteInBackground];
        }
        [self.activities removeLastObject];
        [self saveLike];
    }
    else
    {
        [self saveLike];
    }
}

- (void)checkDisLike
{
    if (self.isDisLikedByCurrentUser) {
        [self setupNextPhoto];
        return;
    }
    else if (self.isDisLikedByCurrentUser)
    {
        for (PFObject *activity in self.activities) {
            [activity deleteInBackground];
        }
        [self.activities removeLastObject];
        [self saveDisLike];
    }
    else
    {
        [self saveDisLike];
    }
}

@end
