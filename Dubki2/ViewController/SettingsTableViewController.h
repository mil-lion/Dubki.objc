//
//  SettingsTableViewController.h
//  Dubki2
//
//  Created by Игорь Моренко on 19.11.15.
//  Copyright © 2015 LionSoft LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsTableViewController : UITableViewController

// selected campus
@property (assign, nonatomic) NSInteger campusIndex;
// selected autolocation
@property (assign, nonatomic) BOOL autolocation;

@end
