//
//  FindViewController.m
//  Dubki2
//
//  Created by Игорь Моренко on 18.11.15.
//  Copyright © 2015 LionSoft LLC. All rights reserved.
//

#import "FindViewController.h"
#import "Date.h"
#import "LocationService.h"
#import "RouteDataModel.h"
#import "CampusPickerViewController.h"
#import "TimePickerViewController.h"
#import "SettingsTableViewController.h"

#pragma mark - Private Interface

@interface FindViewController () <LocationServiceDelegate>
{
    IBOutlet UISegmentedControl *directionSegmentControl;
    IBOutlet UILabel *campusLabel;
    IBOutlet UILabel *whenLabel;
    IBOutlet UILabel *fortuneQuoteLabel;
}
// variable of view controller
// selected campus
@property (strong, nonatomic) NSDictionary<NSString *, NSObject *> *campus;
// selected departure time
@property (strong, nonatomic) NSDate *departureTime;
// selected arrival time
@property (strong, nonatomic) NSDate *arrivalTime;

@end

#pragma mark - Implementation

@implementation FindViewController

NSArray *fortuneQuotes;
LocationService *locationService;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    fortuneQuotes = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"FortuneQuotes"
                                                                                            ofType:@"plist"]];
    
    locationService = [[LocationService alloc] init];
    locationService.delegate = self;
    
    [self setDefaultCampus];
    
    // autolocation
    [[NSUserDefaults standardUserDefaults] synchronize];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"autolocation"]) {
        [locationService requestLocation];
    }
    
    // set rounded border button
    //campusButton.layer.cornerRadius = 5
    //campusButton.layer.borderWidth = 1
    //campusButton.layer.borderColor = UIColor.blueColor().CGColor
    
    //fromToLabel = tableView.headerViewForSection(1)?.textLabel
    //fromToLabel?.text = NSLocalizedString("ToCampus", comment: "").uppercaseString
}

// generate randomize int from mil to max
//func randomInt(min: Int, max:Int) -> Int {
//    return min + Int(arc4random_uniform(UInt32(max - min + 1)))
//}

// before view on screen for update fortune quote
- (void)viewWillAppear:(BOOL)animated {
    //int fq = randomInt(0, max: ((fortuneQuotes?.count)! - 1));
    int fq = (int)arc4random_uniform((UInt32)fortuneQuotes.count);
    fortuneQuoteLabel.text = fortuneQuotes[fq];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Variable of view controller

// selected campus
- (void)setCampus:(NSDictionary<NSString *, NSObject *> *)campus {
    _campus = campus;
    // after set value of when need set label text
    if (campusLabel) {
        if (campus) {
            campusLabel.text = (NSString *)campus[@"title"];
        } else {
            campusLabel.text = @"";
        }
    }
}

// selected departure time
- (void)setDepartureTime:(NSDate *)departureTime {
    // after set value of when need set label text
    if ([departureTime timeIntervalSinceDate:[NSDate date]] < 600) { // 10 minute
        _departureTime = nil;
    } else {
        _departureTime = departureTime;
    }
    [self updateWhenLabel];
}

// selected arrival time
- (void)setArrivalTime:(NSDate *)arrivalTime {
    _arrivalTime = arrivalTime;
    // after set value of when need set label text
    [self updateWhenLabel];
}

- (void)setDefaultCampus {
    // clear campus TODO: get from setting or location
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSInteger defaultCampus = [[NSUserDefaults standardUserDefaults] integerForKey:@"campus"];
    if (defaultCampus == 0) {
        defaultCampus = 2; // Strogino
    }
    self.campus = [RouteDataModel sharedInstance].campuses[defaultCampus];
}

- (void)updateWhenLabel {
    if (whenLabel) {
        if (self.arrivalTime) {
            whenLabel.text = [self.arrivalTime stringByFormat:@"dd MMM HH:mm"];
        } else if (self.departureTime) {
            whenLabel.text = [self.departureTime stringByFormat:@"dd MMM HH:mm"];
        } else {
            whenLabel.text = NSLocalizedString(@"Now", comment: @"");
        }
    }
}

// when direction segment change value
- (IBAction)directionValueChanged:(id)sender {
    [self.tableView reloadData];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"RouteShow"]) {
        // посторить маршрут
        if (self.arrivalTime) {
            // по времени прибытия
            [[RouteDataModel sharedInstance] calculateRouteByArrival:self.arrivalTime
                                                        andDirection:directionSegmentControl.selectedSegmentIndex
                                                           andCampus:self.campus];
        } else {
            // по времени отправления
            NSDate *timestamp = (self.departureTime ? self.departureTime : [NSDate date]);
            [[RouteDataModel sharedInstance] calculateRouteByDeparture:timestamp
                                                          andDirection:directionSegmentControl.selectedSegmentIndex
                                                             andCampus:self.campus];
        }
        //tabBarController.selectedIndex = 1; // Route Tab
    }
    
    if ([segue.identifier isEqualToString:@"CampusPick"]) {
        CampusPickerViewController *campusPicker = (CampusPickerViewController *)segue.destinationViewController;
        if (campusPicker) {
            campusPicker.selectedCampusIndex = ((NSNumber *)self.campus[@"id"]).integerValue - 2;
        }
    }
    
    if ([segue.identifier isEqualToString:@"TimePick"]) {
        TimePickerViewController *timePicker = (TimePickerViewController *)segue.destinationViewController;
        if (timePicker) {
            timePicker.departureTime = self.departureTime;
            timePicker.arrivalTime = self.arrivalTime;
        }
    }
    
    if ([segue.identifier isEqualToString:@"SettingsPick"]) {
        SettingsTableViewController *settings = (SettingsTableViewController *)segue.destinationViewController;
        if (settings) {
            [[NSUserDefaults standardUserDefaults] synchronize];
            NSInteger campusIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"campus"];
            settings.campusIndex = (campusIndex == 0 ? 0 : campusIndex - 1);
            settings.autolocation = [[NSUserDefaults standardUserDefaults] boolForKey:@"autolocation"];
        }
    }
}

// when press button done on campus picker view controller
- (IBAction)unwindWithSelectedCampus:(UIStoryboardSegue *)segue {
    CampusPickerViewController *campusPicker = (CampusPickerViewController *)segue.sourceViewController;
    if (campusPicker) {
        self.campus = [RouteDataModel sharedInstance ].campuses[campusPicker.selectedCampusIndex + 1];
    }
}

// when press button done on time picker view controller
- (IBAction)unwindSelectedTime:(UIStoryboardSegue *)segue {
    TimePickerViewController *timePicker = (TimePickerViewController *)segue.sourceViewController;
    if (timePicker) {
        //Log(timePickerViewController.selectedDate)
        self.departureTime = timePicker.departureTime;
        self.arrivalTime = timePicker.arrivalTime;
    }
}

// when press button save on settings view controller
- (IBAction)saveSettings:(UIStoryboardSegue *)segue {
    SettingsTableViewController *settings = (SettingsTableViewController *)segue.sourceViewController;
    if (settings) {
        [[NSUserDefaults standardUserDefaults] setInteger:(settings.campusIndex + 1)
                                                   forKey:@"campus"];
        [[NSUserDefaults standardUserDefaults] setBool:settings.autolocation
                                                forKey:@"autolocation"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated: YES];
}

#pragma mark - Table View Data Source

// заголовки секций таблицы
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return NSLocalizedString(@"IWantToReach", comment: @""); // Я хочу добраться
        case 1:
            if (directionSegmentControl.selectedSegmentIndex == 0) {
                return NSLocalizedString(@"ToCampus", comment: @""); // в Кампус
            } else {
                return NSLocalizedString(@"FromCampus", comment: @""); // из Кампуса
            }
        case 2:
            //return NSLocalizedString(@"ThePlannedTime", comment: @""); // Планируемое время
            if (self.arrivalTime != nil) {
                return NSLocalizedString(@"ThePlannedArrivalTime", comment: @""); // Планируемое время прибытия
            } else {
                return NSLocalizedString(@"ThePlannedDepartureTime", comment: @""); // Планируемое время отправления
            }
        default:
            return @"";
    }
}

#pragma mark - Location Service Delegate

- (void)locationService:(LocationService *)service
      didUpdateLocation:(CLLocation *)location {
    //Log(@"Current location: %@", location)
    CLLocationDegrees locationLatitude = location.coordinate.latitude;
    CLLocationDegrees locationLongitude = location.coordinate.longitude;
    
    NSDictionary<NSString *, NSObject *> *findItem = nil;
    for (NSDictionary<NSString *, NSObject *> *item in [RouteDataModel sharedInstance].campuses) {
        CLLocationDegrees latitude = ((NSString *)item[@"lat"]).doubleValue;
        CLLocationDegrees longitude = ((NSString *)item[@"lon"]).doubleValue;
        // Градусы   Дистанция
        // --------- ----------
        // 1         111 km
        // 0.1       11.1 km
        // 0.01      1.11 km
        //*0.001     111 m
        // 0.0001    11.1 m
        // 0.00001   1.11 m
        // 0.000001  11.1 cm
        // 0.0005 - 55.5m
        if (fabs(locationLatitude - latitude) < 0.001 && fabs(locationLongitude - longitude) < 0.001) {
            findItem = item;
            break;
        }
    }
    if (findItem) {
        //Log(@"Find Current Campus: %@", findItem)
        int campusId = ((NSNumber *)findItem[@"id"]).intValue;
        if (campusId == 1) {
            // dormitories
            directionSegmentControl.selectedSegmentIndex = 0; // из Дубков
            [self setDefaultCampus];
        } else {
            // campus
            directionSegmentControl.selectedSegmentIndex = 1; // в Дубки
            self.campus = findItem;
        }
    }
}

- (void)locationService:(LocationService *)service
       didFailWithError:(NSError *)error {
    Log(@"didFailWithError: %@", error.localizedDescription)
    // show error alert
    /* if #available(iOS 8.0, *) {
     let errorAlert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
     errorAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
     errorAlert.dismissViewControllerAnimated(true, completion: nil)
     }))
     presentViewController(errorAlert, animated: true, completion: nil)
     } else {
     // Fallback on earlier versions
     let alertView = UIAlertView(title: "Error", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "Ok")
     alertView.show()
     } */
}

@end
