//
//  OnFootStep.m
//  Dubki2
//
//  Created by Игорь Моренко on 18.11.15.
//  Copyright © 2015 LionSoft LLC. All rights reserved.
//

#import "OnFootStep.h"
#import "Date.h"

#pragma mark - Private Interface

@interface OnFootStep ()

@end

#pragma mark - Implementation

@implementation OnFootStep

- (id)initWithDeparture:(NSDate *)departure
                 andEdu:(NSDictionary<NSString *, NSObject *> *)edu {
    self = [super init];
    
    if (self) {
        [self setNearestOnFootByDeparture:departure andEdu:edu];
    }
    
    return self;
}

- (id)initWithArrival:(NSDate *)arrival
               andEdu:(NSDictionary<NSString *, NSObject *> *)edu {
    self = [super init];
    
    if (self) {
        [self setNearestOnFootByArrival:arrival andEdu:edu];
    }
    
    return self;
}

- (NSString *)title {
    return NSLocalizedString(@"OnFoot", comment: @""); // "🚶 Пешком"
}

- (NSString *)detail {
    NSString *detailFormat = NSLocalizedString(@"OnfootDetailFormat", comment: @"");
    return [NSString stringWithFormat:detailFormat, self.duration];
}

/**
 Returns a map url for displaying in a webpage
 
 Args:
 edu(Dictionary): which education campus the route's destination is
 urlType(Optional[String]): whether the map should be interactive
 
 Note:
 'edu' should be a value from EDUS
 'urlType' should be in {'static', 'js'}
 */

- (NSString *)formMapUrlByEdu:(NSDictionary<NSString *, NSObject *> *)edu {
    return [self formMapUrlByEdu:edu andUrlType:@"static"];
}

- (NSString *)formMapUrlByEdu:(NSDictionary<NSString *, NSObject *> *)edu
                   andUrlType:(NSString *)urlType {
    NSString *mapAPI = @"https://api-maps.yandex.ru/services/constructor/1.0/%@/?sid=%@";
    NSString *mapSource = (NSString *)edu[@"mapsrc"];
    return [NSString stringWithFormat:mapAPI, urlType, mapSource];
}

/**
 Returns the nearest onfoot route by departure time
 
 Args:
 edu(Dictionary): place of arrival
 departure(NSDate): time of departure from subway exit
 
 Note:
 'edu' should be a value from EDUS
 */
- (void)setNearestOnFootByDeparture:(NSDate *)departure
                             andEdu:(NSDictionary<NSString *, NSObject *> *)edu {
    self.duration = [(NSNumber *)edu[@"onfoot"] integerValue];
    self.departure = departure;
    self.arrival = [departure dateByAddingMinute:self.duration];
    //self.map = [self formMapUrlByEdu:edu];
    self.map = [NSString stringWithFormat:@"%@.png", (NSString *)edu[@"name"]];
}

/**
 Returns the nearest onfoot route by arrival time
 
 Args:
 edu(Dictionary): place of arrival
 arrival(NSDate): time of arrival from campus exit
 
 Note:
 'edu' should be a value from EDUS
 */
- (void)setNearestOnFootByArrival:(NSDate *)arrival
                           andEdu:(NSDictionary<NSString *, NSObject *> *)edu {
    self.duration = [(NSNumber *)edu[@"onfoot"] integerValue];
    self.departure = [arrival dateByAddingMinute:-self.duration];
    self.arrival = arrival;
    //onfoot.map = [self formMapUrlByEdu:edu];
    self.map = [NSString stringWithFormat:@"%@.png", (NSString *)edu[@"name"]];
}

@end
