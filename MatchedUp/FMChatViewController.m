//
//  FMChatViewController.m
//  MatchedUp
//
//  Created by Fredrick Myers on 3/7/14.
//  Copyright (c) 2014 Fredrick Myers. All rights reserved.
//

#import "FMChatViewController.h"

@interface FMChatViewController () 

@property (strong, nonatomic) PFUser *withUser;
@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) NSTimer *chatsTimer;
@property (nonatomic) BOOL initialLoadComplete;
@property (strong, nonatomic) NSMutableArray *chats;

@end

@implementation FMChatViewController

- (NSMutableArray *)chats
{
    if (!_chats) {
        _chats = [[NSMutableArray alloc] init];
    }
    return _chats;
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
    
    self.delegate = self;
    self.dataSource = self;
    
    [[JSBubbleView appearance] setFont:[UIFont systemFontOfSize:16.0f]];
    self.messageInputView.textView.placeHolder = @"New Message";
    [self setBackgroundColor:[UIColor whiteColor]];
    self.currentUser = [PFUser currentUser];
    PFUser *testUser1 = self.chatRoom[kFMChatRoomUser1Key];
    
    if ([testUser1.objectId isEqual:self.currentUser.objectId])
    {
        self.withUser = self.chatRoom[kFMChatRoomUser2Key];
    }
    else
    {
        self.withUser = self.chatRoom[kFMChatRoomUser1Key];
    }
    
    self.title = self.withUser[kFMUserProfileKey][kFMUserProfileFirstNameKey];
    self.initialLoadComplete = NO;
    
    [self checkForNewChats];
    self.chatsTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(checkForNewChats) userInfo:nil repeats:YES];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.chatsTimer invalidate];
    self.chatsTimer = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.chats count];
}

#pragma mark - TableView Delegates

- (void)didSendText:(NSString *)text
{
    if (text.length != 0) {
        PFObject *chat = [PFObject objectWithClassName:kFMChatClassKey];
        [chat setObject:self.chatRoom forKey:kFMChatChatRoomKey];
        [chat setObject:self.currentUser forKey:kFMChatFromUserKey];
        [chat setObject:self.withUser forKey:kFMChatToUserKey];
        [chat setObject:text forKey:kFMChatTextKey];
        [chat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self.chats addObject:chat];
            [JSMessageSoundEffect playMessageSentSound];
            [self.tableView reloadData];
            [self finishSend];
            [self scrollToBottomAnimated:YES];
        }];
    }
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *chat = self.chats[indexPath.row];
    PFUser *testFromUser = chat[kFMChatFromUserKey];
    if ([testFromUser.objectId isEqual:self.currentUser.objectId])
    {
        return JSBubbleMessageTypeOutgoing;
    }
    else
    {
        return JSBubbleMessageTypeIncoming;
    }
}

- (UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type forRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *chat = self.chats[indexPath.row];
    PFUser *testFromUser = chat[kFMChatFromUserKey];
    if ([testFromUser.objectId isEqual:self.currentUser.objectId])
    {
        return [JSBubbleImageViewFactory bubbleImageViewForType:type color:[UIColor js_bubbleGreenColor]];
    }
    else
    {
        return [JSBubbleImageViewFactory bubbleImageViewForType:type color:[UIColor js_bubbleBlueColor]];
    }
    
}

- (UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (JSMessageInputViewStyle)inputViewStyle
{
    return JSMessageInputViewStyleFlat;
}

- (JSMessagesViewTimestampPolicy)timestampPolicy
{
    return JSMessagesViewTimestampPolicyEveryFive;
}

- (JSMessagesViewAvatarPolicy)avatarPolicy
{
    return JSMessagesViewAvatarPolicyNone;
}

-(JSMessagesViewSubtitlePolicy)subtitlePolicy
{
    return JSMessagesViewSubtitlePolicyNone;
}

-(BOOL)shouldPreventScrollToBottomWhileUserScrolling
{
    return YES;
}

-(NSString *)subtitleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

-(NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - Messages View Data Source

- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *chat = self.chats[indexPath.row];
    NSString *message = chat[kFMChatTextKey];
    return (id)message;
}

#pragma mark - HelperMethods

- (void)checkForNewChats
{
    int oldChatCount = [self.chats count];
    PFQuery *queryForChats = [PFQuery queryWithClassName:kFMChatClassKey];
    [queryForChats whereKey:kFMChatChatRoomKey equalTo:self.chatRoom];
    [queryForChats orderByAscending:@"createdAt"];
    [queryForChats findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (self.initialLoadComplete == NO || oldChatCount != [objects count]) {
                self.chats = [objects mutableCopy];
                [self.tableView reloadData];
                
                if (self.initialLoadComplete == YES)
                {
                    [JSMessageSoundEffect playMessageReceivedSound];
                }
                
                self.initialLoadComplete = YES;
                [self scrollToBottomAnimated:YES];
            }
        }
    }];
}

@end
