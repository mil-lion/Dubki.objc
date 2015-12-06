//
//  LocationService.m
//  Dubki2
//
//  Created by Игорь Моренко on 19.11.15.
//  Copyright © 2015 LionSoft LLC. All rights reserved.
//

#import "LocationService.h"

#pragma mark - Private Interface

@interface LocationService () <CLLocationManagerDelegate>

@end

#pragma mark - Implementation

@implementation LocationService
{
    CLLocationManager *locationManager;
}

- (id)init {
    self = [super init];
  
    if (self) {
        // Work your initialising magic here as you normally would
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    }
    
    return self;
}

- (void)requestLocation {
    [locationManager requestWhenInUseAuthorization];
    [locationManager requestLocation];
    //[locationManager startUpdatingLocation]; // for iOS 7.0
}

#pragma mark - CoreLocation Location Manager Delegate

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations {

    CLLocation *location = [locations firstObject];
    if (location != nil) {
        Log(@"Current location: %@", location)
        [self.delegate locationService:self didUpdateLocation:location];
    }
    [locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    Log(@"Error finding location: %@", error.localizedDescription);
    [self.delegate locationService:self didFailWithError:error];
}

@end
