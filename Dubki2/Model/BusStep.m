//
//  BusStep.m
//  Dubki2
//
//  Created by Игорь Моренко on 18.11.15.
//  Copyright © 2015 LionSoft LLC. All rights reserved.
//

#import "BusStep.h"
#import "Date.h"
#import "ScheduleService.h"

#pragma mark - Private Interface

@interface BusStep ()

@end

#pragma mark - Implementation

@implementation BusStep

- (id)initWithDeparture:(NSDate *)departure
                andFrom:(NSString *)from
                  andTo:(NSString *)to {
    self = [super init];
    
    if (self) {
        [self setNearestBusByDeparture:departure andFrom:from andTo:to];
    }
    
    return self;
}

- (id)initWithArrival:(NSDate *)arrival
              andFrom:(NSString *)from
                andTo:(NSString *)to {
    self = [super init];
    
    if (self) {
        [self setNearestBusByArrival:arrival andFrom:from andTo:to];
    }
    
    return self;
}


- (NSString *)title {
    return NSLocalizedString(@"Bus", comment: @""); // "🚌 Автобус"
}

- (NSString *)detail {
    NSString *timeDeparture = [self.departure stringByFormat:@"HH:mm"];
    NSString *timeArrival = [self.arrival stringByFormat:@"HH:mm"];
    return [NSString stringWithFormat:@"%@ (%@) → %@ (%@)", self.from, timeDeparture, self.to, timeArrival];
}

/**
 Returns the nearest bus by departure time
 
 Args:
 from(String): place of departure
 to(String): place of arrival
 departure(NSDate): time of departure
 
 Note:
 'from' and 'to' should not be equal and should be in {'Одинцово', 'Дубки'}
 */
- (void)setNearestBusByDeparture:(NSDate *)departure
                         andFrom:(NSString *)from
                           andTo:(NSString *)to {
    [self setNearestBusByDeparture:departure andFrom:from andTo:to andUseAsterisk:YES];
}

- (void)setNearestBusByDeparture:(NSDate *)departure
                         andFrom:(NSString *)from
                           andTo:(NSString *)to
                  andUseAsterisk:(BOOL)useAsterisk {
    // from and to should be in {'Одинцово', 'Дубки'}
    //assert from in {'Одинцово', 'Дубки'}
    //assert to in {'Одинцово', 'Дубки'}
    //assert(from != to)
    
    // получить расписание автобуса (время отправления)
    NSArray<NSString *> *times = [[ScheduleService sharedInstance] getScheduleBusByFrom:from
                                                                                  andTo:to
                                                                           andTimestamp:departure];
    
    if (times == nil || times.count == 0) {
        //TODO: добавить сообщение об ошибки пользователю
        Log(@"Не получилось загрузить расписание автобуса")
        return;
    }
    
    // поиск ближайшего рейса (минимум ожидания)
    NSTimeInterval minInterval = 24*60*60; // мин. интервал (сутки)
    NSDate *busDeparture = nil;            // время отправления
    BOOL slBlvdBus = NO;                   // автобус до м.Славянский бульвара
    
    for (NSString *time in times) {
        NSString *timeWithoutAsteriks = time;
        // asterisk indicates bus arrival/departure station is 'Славянский бульвар'
        // it needs special handling
        if ([time containsString:@"*"]) {
            if (!useAsterisk) continue; // не использовать автобус до м. Славянский бульвар
            timeWithoutAsteriks = [time substringToIndex:(time.length - 1)];
        }
        NSDate *departureTime = [departure dateByWithTime:timeWithoutAsteriks];
        NSTimeInterval interval = [departureTime timeIntervalSinceDate:departure];
        //TODO: # FIXME works incorrectly between weekday 6-7-1
        if (interval > 0 && interval < minInterval) {
            minInterval = interval;
            busDeparture = departureTime;
            slBlvdBus = [time containsString:@"*"];
        }
    }
    if (busDeparture == nil) {
        //Log(@"Ближайший автобус не найден")
        // get nearest bus on next day
        NSDate *newDeparture = [[departure dateByAddingDay:1] dateByWithTime:@"00:00"];
        [self setNearestBusByDeparture:newDeparture andFrom:from andTo:to];
        return;
    }
    
    self.from = from;
    if (useAsterisk && slBlvdBus) {
        self.to = @"Славянский бульвар";
        self.duration = 50; // время автобуса в пути
    } else {
        self.to = to;
        self.duration = 15; // время автобуса в пути
    }
    self.departure = busDeparture;
    //TODO: # FIXME: more real arrival time?
    self.arrival = [self.departure dateByAddingMinute:self.duration];
}

/**
 Returns the nearest bus by arrival time
 
 Args:
 from(String): place of departure
 to(String): place of arrival
 arrival(NSDate): time of arrival
 
 Note:
 'from' and 'to' should not be equal and should be in {'Одинцово', 'Дубки'}
 */
- (void)setNearestBusByArrival:(NSDate *)arrival
                       andFrom:(NSString *)from
                         andTo:(NSString *)to {
    [self setNearestBusByArrival:arrival andFrom:from andTo:to andUseAsterisk:YES];
}

- (void)setNearestBusByArrival:(NSDate *)arrival
                       andFrom:(NSString *)from
                         andTo:(NSString *)to
                andUseAsterisk:(BOOL)useAsterisk {
    // получить расписание автобуса (время отправления)
    NSArray<NSString *> *times = [[ScheduleService sharedInstance] getScheduleBusByFrom:from
                                                                                  andTo:to
                                                                           andTimestamp:arrival];
    
    if (times == nil || times.count == 0) {
        //TODO: добавить сообщение об ошибки пользователю
        Log(@"Не получилось загрузить расписание автобуса")
        return;
    }
    
    self.from = from;
    self.to = to;
    self.duration = 15; // время автобуса в пути
    
    // поиск ближайшего рейса (минимум ожидания)
    NSTimeInterval minInterval = 24*60*60; // мин. интервал (сутки)
    NSDate *busDeparture = nil;            // время отправления
    NSDate *busArrival = nil;              // время прибытия
    //BOOL slBlvdBus = NO;                   // автобус до м.Славянский бульвара
    
    for (NSString *time in times) {
        NSString *timeWithoutAsteriks = time;
        // asterisk indicates bus arrival/departure station is 'Славянский бульвар'
        // it needs special handling
        if ([time containsString:@"*"]) {
            if (!useAsterisk) continue; // не использовать автобус до м. Славянский бульвар
            timeWithoutAsteriks = [time substringToIndex:(time.length - 1)];
        }
        NSDate *departureTime = [arrival dateByWithTime:timeWithoutAsteriks];
        NSDate *arrivalTime = [departureTime dateByAddingMinute:self.duration]; // 15 minute
        NSTimeInterval interval = [arrival timeIntervalSinceDate:arrivalTime];
        //TODO: # FIXME works incorrectly between weekday 6-7-1
        if (interval > 0 && interval < minInterval) {
            minInterval = interval;
            busDeparture = departureTime;
            busArrival = arrivalTime;
            //slBlvdBus = [time containsString:@"*"];
        }
    }
    if (busDeparture == nil) {
        //Log(@"Ближайший автобус не найден")
        // get nearest bus on next day
        NSDate *newArrival = [[arrival dateByAddingDay:-1] dateByWithTime:@"23:59"];
        [self setNearestBusByArrival:newArrival andFrom:from andTo:to];
        return;
    }
    
    self.departure = busDeparture;
    //TODO: # FIXME: more real arrival time?
    self.arrival = busArrival;
}

@end
