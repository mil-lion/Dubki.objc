//
//  TimePickerViewController.m
//  Dubki2
//
//  Created by Игорь Моренко on 19.11.15.
//  Copyright © 2015 LionSoft LLC. All rights reserved.
//

#import "TimePickerViewController.h"
#import "Date.h"

#pragma mark - Private Interface

@interface TimePickerViewController ()
{
    IBOutlet UIDatePicker *datePicker;
    IBOutlet UIView *lessonView;
    IBOutlet UISegmentedControl *departureArrivalSegmentControl;
}

@end

#pragma mark - Implementation

@implementation TimePickerViewController

//    let lessonTitles = ["I (9:00)", "II (10:30)", "III (12:10)", "IV (13:40)", "V (15:10)", "VI (16:40)", "VII (18:10)", "VIII (19:40)"]
NSDictionary<NSString *, NSString *> *lessonTimes;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    lessonTimes = @{@"I":@"09:00", @"II":@"10:30", @"III":@"12:10", @"IV":@"13:40", @"V":@"15:10", @"VI":@"16:40", @"VII":@"18:10", @"VIII":@"19:40"};
    
    datePicker.minimumDate = [NSDate date];
    datePicker.maximumDate = [[NSDate date] dateByAddingDay:30]; // +30 day
    if (self.departureTime != nil) {
        datePicker.date = self.departureTime;
        departureArrivalSegmentControl.selectedSegmentIndex = 0;
    }
    if (self.arrivalTime != nil) {
        datePicker.date = self.arrivalTime;
        departureArrivalSegmentControl.selectedSegmentIndex = 1;
    }
    lessonView.hidden = (departureArrivalSegmentControl.selectedSegmentIndex == 0);
}

- (IBAction)departureArrivalValueChange:(id)sender {
    lessonView.hidden = (departureArrivalSegmentControl.selectedSegmentIndex == 0);
}

- (IBAction)lessonButtonPress:(UIButton *)sender {
    // change time for lesson
    NSString *lessonTime = lessonTimes[sender.titleLabel.text];
    NSDate *date = [datePicker.date dateByWithTime:lessonTime];
    
    if ([date compare:[NSDate date]] == NSOrderedDescending) {
        datePicker.date = date;
    } else {
        // next day
        datePicker.date = [date dateByAddingDay:1];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"SaveSelectedTime"]) {
        if (departureArrivalSegmentControl.selectedSegmentIndex == 0) {
            self.departureTime = datePicker.date;
            self.arrivalTime = nil;
        } else {
            self.departureTime = nil;
            self.arrivalTime = datePicker.date;
        }
    }
}

@end
