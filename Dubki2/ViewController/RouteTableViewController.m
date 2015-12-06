//
//  RouteTableViewController.m
//  Dubki2
//
//  Created by Игорь Моренко on 19.11.15.
//  Copyright © 2015 LionSoft LLC. All rights reserved.
//

#import "RouteTableViewController.h"
#import "TrainRouteStepTableViewCell.h"
#import "RouteDataModel.h"
#import "RouteStep.h"
#import "TrainStep.h"
#import "OnFootStep.h"
#import "DetailViewController.h"

#pragma mark - Private Interface

@interface RouteTableViewController ()

@end

#pragma mark - Implementation

@implementation RouteTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    RouteStep *routeStep = [RouteDataModel sharedInstance].route[indexPath.row];
    
    if ([routeStep isKindOfClass:TrainStep.class]) {
        TrainStep *trainStep = (TrainStep *)routeStep;
        if (trainStep.url != nil) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:trainStep.url]];
        }
    }
    if ([routeStep isKindOfClass:OnFootStep.class]) {
        OnFootStep *onfootStep = (OnFootStep *)routeStep;
        if (onfootStep.map != nil) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            [self performSegueWithIdentifier:@"RouteDetail" sender: cell];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // #warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // #warning Incomplete implementation, return the number of rows
    return [RouteDataModel sharedInstance].route.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    RouteStep *routeStep = [RouteDataModel sharedInstance].route[indexPath.row];
    if ([routeStep isKindOfClass:TrainStep.class]) {
        return 120.0;
    } else {
        return 66.0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RouteStep *routeStep = [RouteDataModel sharedInstance].route[indexPath.row];
    
    if ([routeStep isKindOfClass:TrainStep.class]) {
        TrainRouteStepTableViewCell *cell = (TrainRouteStepTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"TrainRouteCell"
                                                                                                           forIndexPath:indexPath];
        
        // Configure the cell...
        cell.titleLabel.text = routeStep.title;
        cell.detailLabel.text = routeStep.detail;
        
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RouteCell"
                                                                forIndexPath:indexPath];
        
        // Configure the cell...
        cell.textLabel.text = routeStep.title;
        cell.detailTextLabel.text = routeStep.detail;
        if ([routeStep isKindOfClass:TrainStep.class] || [routeStep isKindOfClass:OnFootStep.class]) {
            cell.accessoryType = UITableViewCellAccessoryDetailButton;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        return cell;
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"RouteDetail"]) {
        DetailViewController *detailViewController = (DetailViewController *)segue.destinationViewController;
        UITableViewCell *cell = (UITableViewCell *)sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        OnFootStep *onfootStep = (OnFootStep *)[RouteDataModel sharedInstance].route[indexPath.row];
        detailViewController.imageName = onfootStep.map;
    }
}

@end
