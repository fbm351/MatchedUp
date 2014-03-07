//
//  FMHomeViewController.m
//  MatchedUp
//
//  Created by Fredrick Myers on 3/5/14.
//  Copyright (c) 2014 Fredrick Myers. All rights reserved.
//

#import "FMHomeViewController.h"
#import "FMTestUser.h"
#import "FMProfileViewController.h"

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
    
    //[FMTestUser saveTestUserToParse];
    
    self.likeButton.enabled = NO;
    self.dislikeButton.enabled = NO;
    self.infoButton.enabled = NO;
    self.currentPhotoIndex = 0;
    
    PFQuery *query = [PFQuery queryWithClassName:kFMPhotoClassKey];
    [query whereKey:kFMPhotoUserKey notEqualTo:[PFUser currentUser]];
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
    [self performSegueWithIdentifier:@"homeToProfileSegue" sender:nil];
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
        
        PFQuery *queryForLike = [PFQuery queryWithClassName:kFMActivityClassKey];
        [queryForLike whereKey:kFMActivityTypeKey equalTo:kFMActivityTypeLikeKey];
        [queryForLike whereKey:kFMActivityPhotoKey equalTo:self.photo];
        [queryForLike whereKey:kFMActivityFromUserKey equalTo:[PFUser currentUser]];
        
        PFQuery *queryForDisLike = [PFQuery queryWithClassName:kFMActivityClassKey];
        [queryForDisLike whereKey:kFMActivityTypeKey equalTo:kFMActivityTypeDislikeKey];
        [queryForDisLike whereKey:kFMActivityPhotoKey equalTo:self.photo];
        [queryForDisLike whereKey:kFMActivityFromUserKey equalTo:[PFUser currentUser]];
        
        PFQuery *likeAndDisLikeQuery = [PFQuery orQueryWithSubqueries:@[queryForDisLike, queryForLike]];
        [likeAndDisLikeQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                self.activities = [objects mutableCopy];
                if ([self.activities count] == 0) {
                    self.isLikedByCurrentUser = NO;
                    self.isDisLikedByCurrentUser = NO;
                }
                else
                {
                    PFObject *activity = self.activities[0];
                    if ([activity[kFMActivityTypeKey] isEqualToString:kFMActivityTypeLikeKey])
                    {
                        self.isLikedByCurrentUser = YES;
                        self.isDisLikedByCurrentUser = NO;
                    }
                    else if ([activity[kFMActivityTypeKey] isEqualToString:kFMActivityTypeDislikeKey])
                    {
                        self.isLikedByCurrentUser = NO;
                        self.isDisLikedByCurrentUser = YES;
                    }
                    else
                    {
                        //Not used yet
                    }
                }
                self.likeButton.enabled = YES;
                self.dislikeButton.enabled = YES;
                self.infoButton.enabled = YES;
            }
        }];
    }
}

- (void)updateView
{
    self.firstNameLabel.text = self.photo[kFMPhotoUserKey][kFMUserProfileKey][kFMUserProfileFirstNameKey];
    self.ageLabel.text = [NSString stringWithFormat:@"%@", self.photo[kFMPhotoUserKey][kFMUserProfileKey][kFMUserProfileAgeKey]];
    self.tagLineLabel.text = self.photo[kFMUserProfileKey][kFMUserTagLineKey];

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
    PFObject *likeActivity = [PFObject objectWithClassName:kFMActivityClassKey];
    [likeActivity setObject:kFMActivityTypeLikeKey forKey:kFMActivityTypeKey];
    [likeActivity setObject:[PFUser currentUser] forKey:kFMActivityFromUserKey];
    [likeActivity setObject:[self.photo objectForKey:kFMPhotoUserKey] forKey:kFMActivityToUserKey];
    [likeActivity setObject:self.photo forKey:kFMActivityPhotoKey];
    [likeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.isLikedByCurrentUser = YES;
        self.isDisLikedByCurrentUser = NO;
        [self.activities addObject:likeActivity];
        [self setupNextPhoto];
    }];
}

- (void)saveDisLike
{
    PFObject *disLikeActivity = [PFObject objectWithClassName:kFMActivityClassKey];
    [disLikeActivity setObject:kFMActivityTypeDislikeKey forKey:kFMActivityTypeKey];
    [disLikeActivity setObject:[PFUser currentUser] forKey:kFMActivityFromUserKey];
    [disLikeActivity setObject:[self.photo objectForKey:kFMPhotoUserKey] forKey:kFMActivityToUserKey];
    [disLikeActivity setObject:self.photo forKey:kFMActivityPhotoKey];
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
    else if (self.isDisLikedByCurrentUser)
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
    else if (self.isLikedByCurrentUser)
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

- (void)checkForPhotoUserLikes
{
    PFQuery *query = [PFQuery queryWithClassName:kFMActivityClassKey];
    [query whereKey:kFMActivityFromUserKey equalTo:self.photo[kFMPhotoUserKey]];
    [query whereKey:kFMActivityToUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kFMActivityTypeKey equalTo:kFMActivityTypeLikeKey];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        if ([objects count] > 0) {
            //creat our chatroom
        }
    }];
}

#pragma mark - Navigation Helpers

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"homeToProfileSegue"])
    {
        FMProfileViewController *targetVC = segue.destinationViewController;
        targetVC.photo = self.photo;
    }
}

@end
