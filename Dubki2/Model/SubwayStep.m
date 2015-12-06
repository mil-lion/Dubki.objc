//
//  SubwayStep.m
//  Dubki2
//
//  Created by Игорь Моренко on 18.11.15.
//  Copyright © 2015 LionSoft LLC. All rights reserved.
//

#import "SubwayStep.h"
#import "Date.h"
#import "RouteDataModel.h"

#pragma mark - Private Interface

@interface SubwayStep ()

@end

#pragma mark - Implementation

@implementation SubwayStep

// название станций метро
NSDictionary<NSString *, NSString *> *subways;
// время работы метро
NSString *subwayClosesTime = @"01:00";
NSString *subwayOpensTime = @"05:50";

- (id)initWithDeparture:(NSDate *)departure
                andFrom:(NSString *)from
                  andTo:(NSString *)to {
    self = [super init];
    
    if (self) {
        subways = [[RouteDataModel sharedInstance] subways];
        [self setNearestSubwayByDeparture:departure andFrom:from andTo:to];
    }
    
    return self;
}

- (id)initWithArrival:(NSDate *)arrival
              andFrom:(NSString *)from
                andTo:(NSString *)to {
    self = [super init];
    
    if (self) {
        subways = [RouteDataModel sharedInstance].subways;
        [self setNearestSubwayByArrival:arrival andFrom:from andTo:to];
    }

    return self;
}

- (NSString *)title {
    return NSLocalizedString(@"Subway", comment: @""); // "🚇 Метро"
}

- (NSString *)detail {
    NSString *timeDeparture = [self.departure stringByFormat:@"HH:mm"];
    NSString *timeArrival = [self.arrival stringByFormat:@"HH:mm"];
    return [NSString stringWithFormat:@"%@ (%@) → %@ (%@)", self.from, timeDeparture, self.to, timeArrival];
}

/**
 Returns the time required to get from one subway station to another
 
 Args:
 from(String): Russian name of station of departure
 to(String): Russian name of station of arrival
 
 Note:
 'from' and 'to' must exist in SUBWAY_DATA.keys or any of SUBWAY_DATA[key].values
 */
- (NSInteger)getSubwayDurationByFrom:(NSString *)from andTo:(NSString *)to {
    // Subway Route Data (timedelta in minutes)
    NSDictionary *subwayDuration = @{
                    @"kuntsevskaya": @{ // Кунцевская
                        @"strogino":           @16, // Строгино
                        @"semyonovskaya":      @28, // Семёновская
                        @"kurskaya":           @21, // Курская
                        @"leninsky_prospekt" : @28  // Ленинский проспект
                    },
                    @"belorusskaya": @{ // Белорусская
                        @"aeroport":  @6, // Аэропорт
                        @"tverskaya": @4  // Тверская
                    },
                    @"begovaya": @{ // Беговая
                        @"tekstilshchiki": @23, // Текстильщики
                        @"lubyanka":       @12, // Лубянка
                        @"shabolovskaya":  @20, // Шаболовская
                        @"kuznetsky_most":  @9, // Кузнецкий мост
                        @"paveletskaya":   @17, // Павелецкая
                        @"kitay-gorod":    @11  // Китай-город
                    },
                    @"slavyansky_bulvar": @{ // Славянский бульвар
                        @"strogino":          @18, // Строгино
                        @"semyonovskaya":     @25, // Семёновская
                        @"kurskaya":          @18, // Курская
                        @"leninsky_prospekt": @25, // Ленинский проспект
                        @"aeroport":          @26, // Аэропорт
                        @"tverskaya":         @22, // Тверская
                        @"tekstilshchiki":    @35, // Текстильщики
                        @"lubyanka":          @21, // Лубянка
                        @"shabolovskaya":     @22, // Шаболовская
                        @"kuznetsky_most":    @22, // Кузнецкий мост
                        @"paveletskaya":      @17, // Павелецкая
                        @"kitay-gorod":       @20  // Китай-город
                    }
                };

    NSDictionary<NSString *, NSNumber *> *station = subwayDuration[from];
    
    if (station) {
        NSNumber *result = station[to];
        if (result) {
            return result.integerValue;
        }
    }
    station = subwayDuration[to];
    if (station) {
        NSNumber *result = station[from];
        if (result) {
            return result.integerValue;
        }
    }
    Log(@"not fround subway data from: %@ to: %@", from, to)
    return 0;
}

/**
 Returns the nearest subway route by departure time
 
 Args:
 from(String): Russian name of station of departure
 to(String): Russian name of station of arrival
 departure(NSDate): time of departure
 
 Note:
 'from' and 'to' must exist in SUBWAY_DATA.keys or any of SUBWAY_DATA[key].values
 */
- (void)setNearestSubwayByDeparture:(NSDate *)departure
                            andFrom:(NSString *)from
                              andTo:(NSString *)to {
    self.from = subways[from];
    self.to = subways[to];
    self.duration = [self getSubwayDurationByFrom:from andTo: to];
    
    // проверка на время работы метро
    NSDate *subwayCloses = [departure dateByWithTime:subwayClosesTime];
    NSDate *subwayOpens = [departure dateByWithTime:subwayOpensTime];
    // subwayCloses <= timestamp <= subwayOpens
    if ([subwayCloses compare:departure] != NSOrderedDescending
        && [departure compare:subwayOpens] != NSOrderedDescending) {
        // subway is still closed
        self.departure = subwayOpens;
    } else {
        self.departure = departure;
    }
    self.arrival = [self.departure dateByAddingMinute:self.duration];
}

/**
 Returns the nearest subway route by arrival time
 
 Args:
 from(String): Russian name of station of departure
 to(String): Russian name of station of arrival
 arrival(NSDate): time of arrival
 
 Note:
 'from' and 'to' must exist in SUBWAY_DATA.keys or any of SUBWAY_DATA[key].values
 */
- (void)setNearestSubwayByArrival:(NSDate *)arrival
                          andFrom:(NSString *)from
                            andTo:(NSString *)to {
    self.from = subways[from];
    self.to = subways[to];
    self.duration = [self getSubwayDurationByFrom:from andTo: to];
    
    // проверка на время работы метро
    NSDate *subwayCloses = [arrival dateByWithTime:subwayClosesTime];
    NSDate *subwayOpens = [arrival dateByWithTime:subwayOpensTime];
    // subwayCloses <= timestamp <= subwayOpens
    if ([subwayCloses compare:arrival] != NSOrderedDescending
        && [arrival compare:subwayOpens] != NSOrderedDescending) {
        // subway is still closed
        self.departure = subwayOpens;
        self.arrival = [subwayOpens dateByAddingMinute:self.duration];
    } else {
        self.departure = [arrival dateByAddingMinute:-self.duration];
        self.arrival = arrival;
    }
    self.arrival = [self.departure dateByAddingMinute:self.duration];
}

@end
