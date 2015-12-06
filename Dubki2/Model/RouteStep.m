//
//  RouteStep.m
//  Dubki2
//
//  Created by Игорь Моренко on 18.11.15.
//  Copyright © 2015 LionSoft LLC. All rights reserved.
//

#import "RouteStep.h"

#pragma mark - Private Interface

@interface RouteStep ()

@end

#pragma mark - Implementation

@implementation RouteStep

- (id)init {
    self = [super init];
    
    if (self) {
        // Work your initialising magic here as you normally would
        self.duration = 0;
        self.departure = [NSDate date];
        self.arrival = [NSDate date];
    }
    
    return self;
}

- (NSString *)title {
    return NSLocalizedString(@"NoneParameter", comment: @"");
}

- (NSString *)detail {
    return @"";
}

@end
