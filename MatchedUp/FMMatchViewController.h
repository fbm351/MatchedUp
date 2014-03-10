//
//  FMMatchViewController.h
//  MatchedUp
//
//  Created by Fredrick Myers on 3/7/14.
//  Copyright (c) 2014 Fredrick Myers. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FMMatchViewControllerDelegate <NSObject>

- (void)presentMatchesViewController;

@end

@interface FMMatchViewController : UIViewController

@property (weak) id <FMMatchViewControllerDelegate>delegate;
@property (strong, nonatomic) UIImage *matchedUserImage;

@end
