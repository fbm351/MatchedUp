//
//  FMConstants.h
//  MatchedUp
//
//  Created by Fredrick Myers on 3/5/14.
//  Copyright (c) 2014 Fredrick Myers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMConstants : NSObject

#pragma mark - User Class

extern NSString *const kFMUserTagLineKey;

extern NSString *const kFMUserProfileKey;
extern NSString *const kFMUserProfileNameKey;
extern NSString *const kFMUserProfileFirstNameKey;
extern NSString *const kFMUserProfileLocationKey;
extern NSString *const kFMUserProfileGenderKey;
extern NSString *const kFMUserProfileBirthdayKey;
extern NSString *const kFMUserProfileInterestedInKey;
extern NSString *const kFMUserProfilePictureURL;
extern NSString *const kFMUserProfileRelationshipStatusKey;
extern NSString *const kFMUserProfileAgeKey;




#pragma mark - Photo Class

extern NSString *const kFMPhotoClassKey;
extern NSString *const kFMPhotoUserKey;
extern NSString *const kFMPhotoPictureKey;

#pragma mark - Activity Class

extern NSString *const kFMActivityClassKey;
extern NSString *const kFMActivityTypeKey;
extern NSString *const kFMActivityFromUserKey;
extern NSString *const kFMActivityToUserKey;
extern NSString *const kFMActivityPhotoKey;
extern NSString *const kFMActivityTypeLikeKey;
extern NSString *const kFMActivityTypeDislikeKey;



#pragma mark - Settings

extern NSString *const kFMMenEnabledKey;
extern NSString *const kFMWomenEnabledKey;
extern NSString *const kFMSingleEnableKey;
extern NSString *const kFMAgeMaxKey;

#pragma mark - ChatRoom Class

extern NSString *const kFMChatRoomClassKey;
extern NSString *const kFMChatRoomUser1Key;
extern NSString *const kFMChatRoomUser2Key;
extern NSString *const kFMChatRoomChatKey;

#pragma mark - Chat Class

extern NSString *const kFMChatClassKey;
extern NSString *const kFMChatChatRoomKey;
extern NSString *const kFMChatFromUserKey;
extern NSString *const kFMChatToUserKey;
extern NSString *const kFMChatTextKey;






@end
