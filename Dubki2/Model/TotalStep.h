//
//  TotalStep.h
//  Dubki2
//
//  Created by Игорь Моренко on 18.11.15.
//  Copyright © 2015 LionSoft LLC. All rights reserved.
//

#import "RouteStep.h"

@interface TotalStep : RouteStep

- (id)initWithFrom:(NSString *)from
             andTo:(NSString *)to;

- (id)initWithDeparture:(NSDate *)departure
             andArrival:(NSDate *)arrival;

- (id)initWithFrom:(NSString *)from
             andTo:(NSString *)to
      andDeparture:(NSDate *)departure
        andArrival:(NSDate *)arrival;

- (void)setTimeByDeparture:(NSDate *)departure
                andArrival:(NSDate *)arrival;

@end
