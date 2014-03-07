//
//  FMSettingsViewController.m
//  MatchedUp
//
//  Created by Fredrick Myers on 3/6/14.
//  Copyright (c) 2014 Fredrick Myers. All rights reserved.
//

#import "FMSettingsViewController.h"

@interface FMSettingsViewController ()
@property (strong, nonatomic) IBOutlet UISlider *ageSlider;
@property (strong, nonatomic) IBOutlet UISwitch *menSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *womenSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *singleSwitch;
@property (strong, nonatomic) IBOutlet UIButton *logoutButton;
@property (strong, nonatomic) IBOutlet UIButton *editProfileButton;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;

@end

@implementation FMSettingsViewController

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
    
    self.ageSlider.value = [[NSUserDefaults standardUserDefaults] integerForKey:kFMAgeMaxKey];
    self.menSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kFMMenEnabledKey];
    self.womenSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kFMWomenEnabledKey];
    self.singleSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kFMSingleEnableKey];
    self.ageLabel.text = [NSString stringWithFormat:@"%i", (int)self.ageSlider.value];
    
    [self.ageSlider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.menSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.womenSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.singleSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)logoutButtonPressed:(UIButton *)sender
{
    [PFUser logOut];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)editProfileButtonPressed:(UIButton *)sender
{
    
}

#pragma mark - Helper Methods

- (void)valueChanged:(id)sender
{
    if (sender == self.ageSlider)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:(int)self.ageSlider.value forKey:kFMAgeMaxKey];
        self.ageLabel.text = [NSString stringWithFormat:@"%i", (int)self.ageSlider.value];
    }
    else if (sender == self.menSwitch)
    {
        [[NSUserDefaults standardUserDefaults] setBool:self.menSwitch.isOn forKey:kFMMenEnabledKey];
    }
    else if (sender == self.womenSwitch)
    {
        [[NSUserDefaults standardUserDefaults] setBool:self.womenSwitch.isOn forKey:kFMWomenEnabledKey];
    }
    else if (sender == self.singleSwitch)
    {
        [[NSUserDefaults standardUserDefaults] setBool:self.singleSwitch.isOn forKey:kFMSingleEnableKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
