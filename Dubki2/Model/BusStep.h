//
//  BusStep.h
//  Dubki2
//
//  Created by Игорь Моренко on 18.11.15.
//  Copyright © 2015 LionSoft LLC. All rights reserved.
//

#import "RouteStep.h"

@interface BusStep : RouteStep

- (id)initWithDeparture:(NSDate *)departure
                andFrom:(NSString *)from
                  andTo:(NSString *)to;

- (id)initWithArrival:(NSDate *)arrival
              andFrom:(NSString *)from
                andTo:(NSString *)to;

- (void)setNearestBusByDeparture:(NSDate *)departure
                         andFrom:(NSString *)from
                           andTo:(NSString *)to;

- (void)setNearestBusByDeparture:(NSDate *)departure
                         andFrom:(NSString *)from
                           andTo:(NSString *)to
                  andUseAsterisk:(BOOL)useAsterisk;

- (void)setNearestBusByArrival:(NSDate *)arrival
                       andFrom:(NSString *)from
                         andTo:(NSString *)to;

- (void)setNearestBusByArrival:(NSDate *)arrival
                       andFrom:(NSString *)from
                         andTo:(NSString *)to
                andUseAsterisk:(BOOL)useAsterisk;
@end
