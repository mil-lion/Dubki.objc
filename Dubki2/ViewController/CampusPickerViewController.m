//
//  CampusPickerViewController.m
//  Dubki2
//
//  Created by Игорь Моренко on 19.11.15.
//  Copyright © 2015 LionSoft LLC. All rights reserved.
//

#import "CampusPickerViewController.h"
#import "RouteDataModel.h"

#pragma mark - Private Interface

@interface CampusPickerViewController ()

@end

#pragma mark - Implementation

@implementation CampusPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"SaveSelectedCampus"]) {
        UITableViewCell *cell = (UITableViewCell *)sender;
        if (cell) {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            self.selectedCampusIndex = indexPath.row;
        }
    }
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //Other row is selected - need to deselect it
    NSInteger index = self.selectedCampusIndex;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    //selectedCampus = campuses![indexPath.row] as? Dictionary<String, AnyObject>
    self.selectedCampusIndex = indexPath.row;
    
    //update the checkmark for the current row
    cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [RouteDataModel sharedInstance].campuses.count - 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CampusCell"
                                                            forIndexPath:indexPath];
    
    NSDictionary *campus = [RouteDataModel sharedInstance].campuses[indexPath.row + 1];
    
    cell.textLabel.text = campus[@"title"];
    cell.detailTextLabel.text = campus[@"description"];
    if (indexPath.row == self.selectedCampusIndex) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

@end
