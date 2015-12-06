//
//  LocationService.h
//  Dubki2
//
//  Created by Игорь Моренко on 19.11.15.
//  Copyright © 2015 LionSoft LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class LocationService;

@protocol LocationServiceDelegate <NSObject>

- (void)locationService:(LocationService *)service
      didUpdateLocation:(CLLocation *)location;

//@optional
- (void)locationService:(LocationService *)service
       didFailWithError:(NSError *)error;

@end

@interface LocationService : NSObject

@property (strong,nonatomic) id<LocationServiceDelegate> delegate;

- (void)requestLocation;

@end
