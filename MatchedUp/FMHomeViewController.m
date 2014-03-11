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
#import "FMMatchViewController.h"

@interface FMHomeViewController () <FMMatchViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *chatBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingBarButtonItem;
@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) IBOutlet UIButton *infoButton;
@property (strong, nonatomic) IBOutlet UIButton *dislikeButton;
@property (strong, nonatomic) IBOutlet UIView *labelContainerView;
@property (strong, nonatomic) IBOutlet UIView *buttonContainerView;

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

    [self setUpViews];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.photoImageView.image = nil;
    self.firstNameLabel.text = nil;
    self.ageLabel.text = nil;
    
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
            
            if (![self allowPhoto])
            {
                [self setupNextPhoto];
            }
            else
            {
                [self queryForCurrentPhotoIndex];
            }
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


#pragma mark - Navigation Helpers

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"homeToProfileSegue"])
    {
        FMProfileViewController *targetVC = segue.destinationViewController;
        targetVC.photo = self.photo;
    }
    else if ([segue.identifier isEqualToString:@"homeToMatchSegue"])
    {
        FMMatchViewController *targetVC = segue.destinationViewController;
        targetVC.matchedUserImage = self.photoImageView.image;
        targetVC.delegate = self;
    }
}

#pragma mark - FMMatchViewController Delegate
- (void)presentMatchesViewController
{
    [self dismissViewControllerAnimated:NO completion:^
    {
        [self performSegueWithIdentifier:@"homeToMatchesSegue" sender:nil];
    }];
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
    
}

- (void)setupNextPhoto
{
    if (self.currentPhotoIndex + 1 < self.photos.count) {
        self.currentPhotoIndex ++;
        
        if (![self allowPhoto])
        {
            [self setupNextPhoto];
        }
        else
        {
            [self queryForCurrentPhotoIndex];
        }
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
        [self checkForPhotoUserLikes];
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
             [self createChatRoom];
         }
     }];
}

- (void)createChatRoom
{
    PFQuery *queryForChatRoom = [PFQuery queryWithClassName:kFMChatRoomClassKey];
    [queryForChatRoom whereKey:kFMChatRoomUser1Key equalTo:[PFUser currentUser]];
    [queryForChatRoom whereKey:kFMChatRoomUser2Key equalTo:self.photo[kFMPhotoUserKey]];
    
    PFQuery *queryForChatRoomInverse = [PFQuery queryWithClassName:kFMChatRoomClassKey];
    [queryForChatRoomInverse whereKey:kFMChatRoomUser1Key equalTo:self.photo[kFMPhotoUserKey]];
    [queryForChatRoomInverse whereKey:kFMChatRoomUser2Key equalTo:[PFUser currentUser]];
    
    PFQuery *combinedQuery = [PFQuery orQueryWithSubqueries:@[queryForChatRoom, queryForChatRoomInverse]];
    [combinedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] == 0) {
            PFObject *chatRoom = [PFObject objectWithClassName:kFMChatRoomClassKey];
            [chatRoom setObject:[PFUser currentUser] forKey:kFMChatRoomUser1Key];
            [chatRoom setObject:self.photo[kFMPhotoUserKey] forKey:kFMChatRoomUser2Key];
            [chatRoom saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [self performSegueWithIdentifier:@"homeToMatchSegue" sender:nil];
            }];
        }
    }];
}

- (BOOL)allowPhoto
{
    int maxAge = [[NSUserDefaults standardUserDefaults] integerForKey:kFMAgeMaxKey];
    BOOL men = [[NSUserDefaults standardUserDefaults] boolForKey:kFMMenEnabledKey];
    BOOL women = [[NSUserDefaults standardUserDefaults] boolForKey:kFMWomenEnabledKey];
    BOOL single = [[NSUserDefaults standardUserDefaults] boolForKey:kFMSingleEnableKey];
    
    PFObject *photo = self.photos[self.currentPhotoIndex];
    PFUser *user = photo[kFMPhotoUserKey];
    
    int userAge = [user[kFMUserProfileKey][kFMUserProfileAgeKey] intValue];
    NSString *gender = user[kFMUserProfileKey][kFMUserProfileGenderKey];
    NSString *relationShipStatus = user[kFMUserProfileKey][kFMUserProfileRelationshipStatusKey];
    
    if (userAge > maxAge)
    {
        return NO;
    }
    else if (men == NO && [gender isEqualToString:@"male"])
    {
        return NO;
    }
    else if (women == NO && [gender isEqualToString:@"female"])
    {
        return NO;
    }
    else if (single == NO && ([relationShipStatus isEqualToString:@"single"] || relationShipStatus == nil))
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (void)setUpViews
{
    [self addShadowForView:self.buttonContainerView];
    [self addShadowForView:self.labelContainerView];
    self.photoImageView.layer.masksToBounds = YES;
    self.view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
}

- (void)addShadowForView:(UIView *)view
{
    view.layer.masksToBounds = NO;
    view.layer.cornerRadius = 4;
    view.layer.shadowRadius = 1;
    view.layer.shadowOffset = CGSizeMake(0, 1);
    view.layer.shadowOpacity = 0.25;
}


@end
