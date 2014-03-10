//
//  FMMatchesViewController.m
//  MatchedUp
//
//  Created by Fredrick Myers on 3/7/14.
//  Copyright (c) 2014 Fredrick Myers. All rights reserved.
//

#import "FMMatchesViewController.h"
#import "FMChatViewController.h"

@interface FMMatchesViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *avaliableChatRooms;

@end

@implementation FMMatchesViewController

- (NSMutableArray *)avaliableChatRooms
{
    if (!_avaliableChatRooms) {
        _avaliableChatRooms = [[NSMutableArray alloc] init];
    }
    return _avaliableChatRooms;
}

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
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self updateAvaliableChatRooms];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.avaliableChatRooms count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    PFObject *chatRoom = self.avaliableChatRooms[indexPath.row];
    PFUser *likedUser;
    PFUser *currentUser = [PFUser currentUser];
    PFUser *testUser1 = chatRoom[kFMChatRoomUser1Key];
    if ([testUser1.objectId isEqual:currentUser.objectId])
    {
        likedUser = [chatRoom objectForKey:kFMChatRoomUser2Key];
    }
    else
    {
        likedUser = [chatRoom objectForKey:kFMChatRoomUser1Key];
    }
    cell.textLabel.text = likedUser[kFMUserProfileKey][kFMUserProfileFirstNameKey];
    
    //cell.imageView.image = place holder image
    
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    PFQuery *queryForPhoto = [PFQuery queryWithClassName:kFMPhotoClassKey];
    [queryForPhoto whereKey:kFMPhotoUserKey equalTo:likedUser];
    [queryForPhoto findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] > 0) {
            PFObject *photo = objects[0];
            PFFile *photoFile = photo[kFMPhotoPictureKey];
            [photoFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                cell.imageView.image = [UIImage imageWithData:data];
                cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
            }];
        }
    }];
    return cell;
    
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"matchesToChatSeque" sender:indexPath];
}

#pragma mark - Helper Methods

- (void)updateAvaliableChatRooms
{
    PFQuery *query = [PFQuery queryWithClassName:kFMChatRoomClassKey];
    [query whereKey:kFMChatRoomUser1Key equalTo:[PFUser currentUser]];
    
    PFQuery *queryInverse = [PFQuery queryWithClassName:kFMChatRoomClassKey];
    [queryInverse whereKey:kFMChatRoomUser2Key equalTo:[PFUser currentUser]];
    
    PFQuery *combinedQuery = [PFQuery orQueryWithSubqueries:@[query, queryInverse]];
    [combinedQuery includeKey:kFMChatRoomChatKey];
    [combinedQuery includeKey:kFMChatRoomUser1Key];
    [combinedQuery includeKey:kFMChatRoomUser2Key];
    [combinedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [self.avaliableChatRooms removeAllObjects];
            self.avaliableChatRooms = [objects mutableCopy];
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - Navigation Helpers

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"matchesToChatSeque"]) {
        FMChatViewController *targetVC = segue.destinationViewController;
        NSIndexPath *indexPath = sender;
        targetVC.chatRoom = self.avaliableChatRooms[indexPath.row];
    }
}



@end
