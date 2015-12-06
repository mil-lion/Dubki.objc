//
//  SubwayStep.h
//  Dubki2
//
//  Created by Игорь Моренко on 18.11.15.
//  Copyright © 2015 LionSoft LLC. All rights reserved.
//

#import "RouteStep.h"

@interface SubwayStep : RouteStep

- (id)initWithDeparture:(NSDate *)departure
                andFrom:(NSString *)from
                  andTo:(NSString *)to;

- (id)initWithArrival:(NSDate *)arrival
              andFrom:(NSString *)from
                andTo:(NSString *)to;

- (void)setNearestSubwayByDeparture:(NSDate *)departure
                            andFrom:(NSString *)from
                              andTo:(NSString *)to;

- (void)setNearestSubwayByArrival:(NSDate *)arrival
                          andFrom:(NSString *)from
                            andTo:(NSString *)to;

@end
