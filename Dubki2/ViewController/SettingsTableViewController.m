//
//  SettingsTableViewController.m
//  Dubki2
//
//  Created by Игорь Моренко on 19.11.15.
//  Copyright © 2015 LionSoft LLC. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "RouteDataModel.h"
#import "CampusPickerViewController.h"

#pragma mark - Private Interface

@interface SettingsTableViewController ()
{
    IBOutlet UILabel *campusLabel;
    IBOutlet UISwitch *autolocationSwitch;
}
@end

#pragma mark - Implementation

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSDictionary *campus = [RouteDataModel sharedInstance].campuses[self.campusIndex + 1];
    campusLabel.text = campus[@"title"];
    
    autolocationSwitch.on = self.autolocation;
}

// selected campus
- (void)setCampusIndex:(NSInteger)campusIndex {
    _campusIndex = campusIndex;
    // after set value of when need set label text
    if (campusLabel != nil) {
        NSDictionary *campus = [RouteDataModel sharedInstance].campuses[campusIndex + 1];
        campusLabel.text = campus[@"title"];
//        campusLabel.text = @"";
    }
}

// when press button done on campus picker view controller
- (IBAction)unwindWithSelectedCampus:(UIStoryboardSegue *)segue {
    CampusPickerViewController *campusPickerViewController = (CampusPickerViewController *)segue.sourceViewController;
    self.campusIndex = campusPickerViewController.selectedCampusIndex;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"CampusPick"]) {
        CampusPickerViewController *campusPicker = (CampusPickerViewController *)segue.destinationViewController;
        campusPicker.selectedCampusIndex = self.campusIndex;
    }
    
    if ([segue.identifier isEqualToString:@"SaveSettings"]){
        self.autolocation = autolocationSwitch.on;
    }
}

@end
