//
//  TransitionStep.m
//  Dubki2
//
//  Created by Игорь Моренко on 18.11.15.
//  Copyright © 2015 LionSoft LLC. All rights reserved.
//

#import "TransitionStep.h"
#import "Date.h"

#pragma mark - Private Interface

@interface TransitionStep ()

@end

#pragma mark - Implementation

@implementation TransitionStep

- (id)initWithDeparture:(NSDate *)departure
                andFrom:(NSString *)from
                  andTo:(NSString *)to
            andDuration:(NSInteger)duration {
    self = [super init];
    
    if (self) {
        self.from = from;
        self.to = to;
        self.duration = duration;
        self.departure = departure;
        self.arrival = [departure dateByAddingMinute:duration];
    }
    
    return self;
}

- (id)initWithArrival:(NSDate *)arrival
              andFrom:(NSString *)from
                andTo:(NSString *)to
          andDuration:(NSInteger)duration {
    self = [super init];
    
    if (self) {
        self.from = from;
        self.to = to;
        self.duration = duration;
        self.departure = [arrival dateByAddingMinute:-duration];
        self.arrival = arrival;
    }
    
    return self;
}

- (NSString *)title {
    return NSLocalizedString(@"Transition", comment: @""); // "🚶 Переход"
}

- (NSString *)detail {
    NSString *detailFormat = NSLocalizedString(@"TransitDetailFormat", comment: @"");
    return [NSString stringWithFormat:detailFormat, self.from, self.to, self.duration];
}

@end
