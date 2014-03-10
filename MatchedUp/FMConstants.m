//
//  FMConstants.m
//  MatchedUp
//
//  Created by Fredrick Myers on 3/5/14.
//  Copyright (c) 2014 Fredrick Myers. All rights reserved.
//

#import "FMConstants.h"

@implementation FMConstants

#pragma mark - User Class

NSString *const kFMUserTagLineKey               = @"tagLine";

NSString *const kFMUserProfileKey               = @"profile";
NSString *const kFMUserProfileNameKey           = @"name";
NSString *const kFMUserProfileFirstNameKey      = @"firstName";
NSString *const kFMUserProfileLocationKey       = @"location";
NSString *const kFMUserProfileGenderKey         = @"gender";
NSString *const kFMUserProfileBirthdayKey       = @"birthday";
NSString *const kFMUserProfileInterestedInKey   = @"interestedIn";
NSString *const kFMUserProfilePictureURL        = @"pictureURL";
NSString *const kFMUserProfileAgeKey            = @"age";
NSString *const kFMUserProfileRelationshipStatusKey = @"relationShipStatus";

#pragma mark - Photo Class

NSString *const kFMPhotoClassKey                = @"Photo";
NSString *const kFMPhotoUserKey                 = @"user";
NSString *const kFMPhotoPictureKey              = @"image";

#pragma mark - Activity Class

NSString *const kFMActivityClassKey             = @"Activity";
NSString *const kFMActivityTypeKey              = @"type";
NSString *const kFMActivityFromUserKey          = @"fromUser";
NSString *const kFMActivityToUserKey            = @"toUser";
NSString *const kFMActivityPhotoKey             = @"photo";
NSString *const kFMActivityTypeLikeKey          = @"like";
NSString *const kFMActivityTypeDislikeKey       = @"dislike";

#pragma mark - Settings

NSString *const kFMMenEnabledKey                = @"men";
NSString *const kFMWomenEnabledKey              = @"women";
NSString *const kFMSingleEnableKey              = @"single";
NSString *const kFMAgeMaxKey                    = @"ageMax";

#pragma mark - ChatRoom Class

NSString *const kFMChatRoomClassKey             = @"ChatRoom";
NSString *const kFMChatRoomUser1Key             = @"user1";
NSString *const kFMChatRoomUser2Key             = @"user2";
NSString *const kFMChatRoomChatKey              = @"chat";

#pragma mark - Chat Class

NSString *const kFMChatClassKey                 = @"Chat";
NSString *const kFMChatChatRoomKey              = @"chatRoom";
NSString *const kFMChatFromUserKey              = @"fromUser";
NSString *const kFMChatToUserKey                = @"toUser";
NSString *const kFMChatTextKey                  = @"text";




@end
