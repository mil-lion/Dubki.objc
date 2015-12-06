//
//  TotalStep.m
//  Dubki2
//
//  Created by Игорь Моренко on 18.11.15.
//  Copyright © 2015 LionSoft LLC. All rights reserved.
//

#import "TotalStep.h"
#import "Date.h"

#pragma mark - Private Interface

@interface TotalStep ()

@end

#pragma mark - Implementation

@implementation TotalStep

- (id)initWithFrom:(NSString *)from
             andTo:(NSString *)to {
    self = [super init];
    
    if (self) {
        self.from = from;
        self.to = to;
    }
    
    return self;
}

- (id)initWithDeparture:(NSDate *)departure
             andArrival:(NSDate *)arrival {
    self = [super init];
    
    if (self) {
        [self setTimeByDeparture:departure andArrival:arrival];
    }
    
    return self;
}

- (id)initWithFrom:(NSString *)from
             andTo:(NSString *)to
      andDeparture:(NSDate *)departure
        andArrival:(NSDate *)arrival {
    self = [super init];

    if (self) {
        self.from = from;
        self.to = to;
        [self setTimeByDeparture:departure andArrival:arrival];
    }
    
    return self;
}

- (NSString *)title {
    return [NSString stringWithFormat:@"🏁 %@ → %@", self.from, self.to];
}

- (NSString *)detail {
    //NSString *timeDeparture = [self.departure stringByFormat:@"HH:mm"]
    NSString *dateDeparture = [self.departure stringByFormat:@"dd MMM HH:mm"];
    NSString *timeArrival = [self.arrival stringByFormat:@"HH:mm"];
    //NSString *dateArrival = [self.arrival stringByFormat:@"dd MMM HH:mm"];
    NSString *detailFormat = NSLocalizedString(@"TotalDetailFormat", comment: @"");
    return [NSString stringWithFormat:detailFormat, dateDeparture, timeArrival, self.duration];
}

- (void)setTimeByDeparture:(NSDate *)departure
                andArrival:(NSDate *)arrival {
    self.departure = departure;
    self.arrival = arrival;
    self.duration = (NSInteger)([arrival timeIntervalSinceDate:departure] / 60.0 + 0.5);
}

@end
