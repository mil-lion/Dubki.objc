//
//  TrainStep.m
//  Dubki2
//
//  Created by Игорь Моренко on 18.11.15.
//  Copyright © 2015 LionSoft LLC. All rights reserved.
//

#import "TrainStep.h"
#import "Date.h"
#import "String.h"
#import "ScheduleService.h"

#pragma mark - Private Interface

@interface TrainStep ()

@property (strong, nonatomic) NSString *trainName; // название поезда или ветки метро
@property (strong, nonatomic) NSString *stops;     // остановки ж/д или станции пересадки метро

@end

#pragma mark - Implementation

@implementation TrainStep

- (id)initWithDeparture:(NSDate *)departure
                andFrom:(NSDictionary<NSString *, NSObject *> *)from
                  andTo:(NSDictionary<NSString *, NSObject *> *)to {
    self = [super init];
    
    if (self) {
        [self setNearestTrainByDeparture:departure andFrom:from andTo:to];
    }
    
    return self;
}

- (id)initWithArrival:(NSDate *)arrival
              andFrom:(NSDictionary<NSString *, NSObject *> *)from
                andTo:(NSDictionary<NSString *, NSObject *> *)to {
    self = [super init];
    
    if (self) {
        [self setNearestTrainByArrival:arrival andFrom:from andTo:to];
    }
    
    return self;
}

- (NSString *)title {
    return NSLocalizedString(@"Train", comment: @""); // "🚊 Электричка"
}

- (NSString *)detail {
    NSString *timeDeparture = [self.departure stringByFormat:@"HH:mm"];
    NSString *timeArrival = [self.arrival stringByFormat:@"HH:mm"];
    NSString *detailFormat = NSLocalizedString(@"TrainDetailFormat", comment: @"");
    return [NSString stringWithFormat:detailFormat, self.trainName, timeDeparture, timeArrival, self.stops, self.to];
}

//NSString *RASP_YANDEX_URL = "https://rasp.yandex.ru/";
NSString *RASP_YANDEX_URL = @"https://rasp.yandex.ru/search/?when=%@&fromId=%@&toId=%@";

/*
 Returns the nearest train by departure time
 
 Args:
 from(Dictionary): place of departure
 to(Dictionary): place of arrival
 departure(NSDate): time of departure
 
 Note:
 'from' and 'to' should not be equal and should be in STATIONS
 */
- (void)setNearestTrainByDeparture:(NSDate *)departure
                           andFrom:(NSDictionary<NSString *, NSObject *> *)from
                             andTo:(NSDictionary<NSString *, NSObject *> *)to {
    //assert _from in STATIONS
    //assert _to in STATIONS
    
    NSString *fromCode = (NSString *)from[@"code"];
    NSString *toCode = (NSString *)to[@"code"];
    
    // получить расписание электричек
    NSArray *trains = [[ScheduleService sharedInstance] getScheduleTrainByFrom:fromCode
                                                                         andTo:toCode
                                                                  andTimestamp:departure];
    
    if (trains == nil || trains.count == 0) {
        //TODO: добавить сообщение об ошибки пользователю
        Log(@"Не получилось загрузить расписание электричек")
        return;
    }
    
    // поиск ближайшего рейса (минимум ожидания)
    NSTimeInterval minInterval = 24*60*60; // мин. интервал (сутки)
    NSDictionary *trainInfo = nil; // найденая информация о поезде
    for (NSDictionary *train in trains) {
        NSDate *departureTime = ((NSString *)train[@"departure"]).date;
        NSTimeInterval interval = [departureTime timeIntervalSinceDate:departure];
        if (interval > 0 && interval < minInterval) {
            minInterval = interval;
            trainInfo = train;
        }
    }
    
    if (trainInfo == nil) {
        //Log(@"Ближайшая электричка не найдена")
        // get nearest train on next day
        NSDate *newDeparture = [[departure dateByAddingDay:1] dateByWithTime:@"00:00"];
        [self setNearestTrainByDeparture:newDeparture andFrom:from andTo:to];
        return;
    }
    
    self.from = (NSString *)from[@"title"];
    self.to = (NSString *)to[@"title"];
    self.trainName = (NSString *)trainInfo[@"title"]; //"Кубинка 1 - Москва (Белорусский вокзал)"
    self.stops = (NSString *)trainInfo[@"stops"]; //"везде"
    self.departure = ((NSString *)trainInfo[@"departure"]).date;
    self.arrival = ((NSString *)trainInfo[@"arrival"]).date;
    self.duration = (NSInteger)([self.arrival timeIntervalSinceDate:self.departure] / 60.0 + 0.5);
    //self.duration = ((NSNumber *)trainInfo[@"duration"]).integerValue / 60;
    self.url = [NSString stringWithFormat:RASP_YANDEX_URL, [departure stringByFormat:@"yyyy-MM-dd"], fromCode, toCode];
}

/*
 Returns the nearest train by arrival time
 
 Args:
 from(Dictionary): place of departure
 to(Dictionary): place of arrival
 arrival(NSDate): time of arrival
 
 Note:
 'from' and 'to' should not be equal and should be in STATIONS
 */
- (void)setNearestTrainByArrival:(NSDate *)arrival
                         andFrom:(NSDictionary<NSString *, NSObject *> *)from
                           andTo:(NSDictionary<NSString *, NSObject *> *)to {
    //assert _from in STATIONS
    //assert _to in STATIONS
    
    NSString *fromCode = (NSString *)from[@"code"];
    NSString *toCode = (NSString *)to[@"code"];
    
    // получить расписание электричек
    NSArray<NSDictionary *> *trains = [[ScheduleService sharedInstance] getScheduleTrainByFrom:fromCode
                                                                                         andTo:toCode
                                                                                  andTimestamp:arrival];
    
    if (trains == nil || trains.count == 0) {
        //TODO: добавить сообщение об ошибки пользователю
        Log(@"Не получилось загрузить расписание электричек")
        return;
    }
    
    // поиск ближайшего рейса (минимум ожидания)
    NSTimeInterval minInterval = 24*60*60; // мин. интервал (сутки)
    NSDictionary *trainInfo = nil; // найденая информация о поезде
    for (NSDictionary *train in trains) {
        NSDate *arrivalTime = ((NSString *)train[@"arrival"]).date;
        NSTimeInterval interval = [arrival timeIntervalSinceDate:arrivalTime];
        if (interval > 0 && interval < minInterval) {
            minInterval = interval;
            trainInfo = train;
        }
    }
    
    if (trainInfo == nil) {
        //Log(@"Ближайшая электричка не найдена")
        // get nearest train on next day
        NSDate *newArrival = [[arrival dateByAddingDay:-1] dateByWithTime:@"23:59"];
        [self setNearestTrainByArrival:newArrival andFrom:from andTo:to];
         return;
    }
    
    self.from = (NSString *)from[@"title"];
    self.to = (NSString *)to[@"title"];
    self.trainName = (NSString *)trainInfo[@"title"]; //"Кубинка 1 - Москва (Белорусский вокзал)"
    self.stops = (NSString *)trainInfo[@"stops"]; //"везде"
    self.departure = ((NSString *)trainInfo[@"departure"]).date;
    self.arrival = ((NSString *)trainInfo[@"arrival"]).date;
    self.duration = (NSInteger)([self.arrival timeIntervalSinceDate:self.departure] / 60.0 + 0.5);
    //self.duration = ((NSNumber *)trainInfo[@"duration"]).integerValue / 60;
    self.url = [NSString stringWithFormat:RASP_YANDEX_URL, [arrival stringByFormat:@"yyyy-MM-dd"], fromCode, toCode];
}

@end
