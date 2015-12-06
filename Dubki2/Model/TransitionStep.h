//
//  TransitionStep.h
//  Dubki2
//
//  Created by Игорь Моренко on 18.11.15.
//  Copyright © 2015 LionSoft LLC. All rights reserved.
//

#import "RouteStep.h"

@interface TransitionStep : RouteStep

- (id)initWithDeparture:(NSDate *)departure
                andFrom:(NSString *)from
                  andTo:(NSString *)to
            andDuration:(NSInteger)duration;

- (id)initWithArrival:(NSDate *)arrival
              andFrom:(NSString *)from
                andTo:(NSString *)to
          andDuration:(NSInteger)duration;

@end
