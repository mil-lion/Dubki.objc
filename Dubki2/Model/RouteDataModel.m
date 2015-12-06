//
//  RouteDataModel.m
//  Dubki2
//
//  Created by Игорь Моренко on 18.11.15.
//  Copyright © 2015 LionSoft LLC. All rights reserved.
//

#import "RouteDataModel.h"
#import "RouteStep.h"
#import "BusStep.h"
#import "TrainStep.h"
#import "SubwayStep.h"
#import "OnFootStep.h"
#import "TransitionStep.h"
#import "TotalStep.h"
#import "Date.h"

#pragma mark - Private Interface

@interface RouteDataModel ()

@end

#pragma mark - Implementation

@implementation RouteDataModel

#pragma mark Implementing a Singleton Class

// Get the shared instance and create it if necessary.
+ (instancetype)sharedInstance {
    static dispatch_once_t pred;
    static id sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[super alloc] initUniqueInstance];
    });
    return sharedInstance;
}

- (instancetype)initUniqueInstance {
    self = [super init];
    
    if (self) {
        // load resource
        // dormitories
        NSString *dormitoriesPath = [[NSBundle mainBundle] pathForResource:@"Dormitories"
                                                                    ofType:@"plist"];
        self.dormitories = [[NSArray alloc] initWithContentsOfFile:dormitoriesPath];
        // campuses
        NSString *campusesPath = [[NSBundle mainBundle] pathForResource:@"Campuses"
                                                                 ofType:@"plist"];
        self.campuses = [[NSArray alloc] initWithContentsOfFile:campusesPath];
        // subways
        NSString *subwaysPath = [[NSBundle mainBundle] pathForResource:@"Subways"
                                                                ofType:@"plist"];
        self.subways = [[NSDictionary alloc] initWithContentsOfFile:subwaysPath];
        // subways
        NSString *stationsPath = [[NSBundle mainBundle] pathForResource:@"Stations"
                                                                 ofType:@"plist"];
        self.stations = [[NSDictionary alloc] initWithContentsOfFile:stationsPath];
        
        // route
        self.route = [[NSMutableArray alloc] init];
        [self.route addObject:[[RouteStep alloc] init]];
    }
    
    return self;
}

/**
 Calculates a route as if timestamp is the time of departure
 
 Args:
 direction (Int): flow from/to dormitory
 campus (Dictionary): place edu of arrival/departure
 timestamp(Optional[NSDate]): time of departure.
 Defaults to the current time plus 10 minutes.
 src(Optional[str]): function caller ID (used for logging)
 
 Returns:
 route (Array): a calculated route
 */
- (void)calculateRouteByDeparture:(NSDate *)departure
                     andDirection:(NSInteger)direction
                        andCampus:(NSDictionary<NSString *, NSObject*> *)campus {
    
    //self.direction = direction
    //self.campus = campus
    //self.when = when
    //if when == nil {
    //    self.when = NSDate().dateByAddingTimeInterval(600) // сейчас + 10 минут на сборы
    //}
    
    //if campus == nil {
    //    route = [RouteStep(type: .None)]
    //    return
    //}
    
    NSDictionary<NSString *, NSObject *> *dorm = self.dormitories[0]; // общежитие
    
    self.route = [[NSMutableArray alloc] init]; // очистка маршрута
    
    NSDate *timestamp = [departure dateByAddingMinute:10]; // 10 минут на сборы
    
    if (direction == 0) {
        // из Дубков
        // Маршрут: Автобус->Переход->Электричка->Переход->Метро->Пешком
        
        // автобусом
        BusStep *bus = [[BusStep alloc] initWithDeparture:timestamp
                                                  andFrom:@"Дубки"
                                                    andTo:@"Одинцово"];
        
        // станции метро
        NSString *subwayFrom;   // станция метро после транзита
        NSDate *transitArrival; // время пребытия к метро
        
        TransitionStep *transit1 = nil;
        TrainStep *train = nil;
        TransitionStep *transit2 = nil;
        
        if ([bus.to isEqualToString:@"Славянский бульвар"]) {
            // станции метро
            
            subwayFrom = @"slavyansky_bulvar";
            // переход Автобус->Метро
            transit1 = [[TransitionStep alloc] initWithDeparture:bus.arrival
                                                         andFrom:NSLocalizedString(@"Bus", comment: @"") // "Автобус"
                                                           andTo:bus.to
                                                     andDuration: 5]; // 5 minute
            
            // время прибытия
            transitArrival = transit1.arrival;
        } else {
            // станции ж/д
            NSDictionary<NSString *, NSObject *> *stationFrom = self.stations[(NSString *)dorm[@"station"]];
            NSDictionary<NSString *, NSObject *> *stationTo = self.stations[(NSString *)campus[@"station"]];
            
            // переход Автобус->Станция
            transit1 = [[TransitionStep alloc] initWithDeparture:bus.arrival
                                                         andFrom:NSLocalizedString(@"Bus", comment: @"") // "Автобус"
                                                           andTo:NSLocalizedString(@"Station", comment: @"") // "Станция"
                                                     andDuration:((NSNumber *)stationFrom[@"transit"]).integerValue];
            
            // электричкой
            train = [[TrainStep alloc] initWithDeparture:transit1.arrival
                                                 andFrom:stationFrom
                                                   andTo:stationTo];
            
            // станции метро
            subwayFrom = (NSString *)stationTo[@"subway"];
            
            // переход Станция->Метро
            transit2 = [[TransitionStep alloc] initWithDeparture:train.arrival
                                                         andFrom:(NSString *)stationTo[@"title"]
                                                           andTo:self.subways[subwayFrom]
                                                     andDuration:((NSNumber *)stationTo[@"transit"]).integerValue];
            
            // время прибытия
            transitArrival = transit2.arrival;
        }
        
        // на метро
        NSString *subwayTo = (NSString *)campus[@"subway"];
        SubwayStep *subway = [[SubwayStep alloc] initWithDeparture:transitArrival
                                                           andFrom:subwayFrom
                                                             andTo:subwayTo];
        
        // пешком
        OnFootStep *onfoot = [[OnFootStep alloc] initWithDeparture:subway.arrival
                                                            andEdu:campus];
        
        // общая информация о пути
        TotalStep *way = [[TotalStep alloc] initWithFrom:(NSString *)dorm[@"title"]
                                                   andTo:(NSString *)campus[@"title"]
                                            andDeparture:[bus.departure dateByAddingMinute:-10] // 10 минут на сборы
                                              andArrival: onfoot.arrival];
        
        // формирование информации о пути
        [self.route addObject:way];
        [self.route addObject:bus];
        if (transit1.duration > 0) {
            [self.route addObject:transit1];
        }
        if (train != nil) {
            [self.route addObject:train];
        }
        if (transit2 != nil && transit2.duration > 0) {
            [self.route addObject:transit2];
        }
        [self.route addObject:subway];
        [self.route addObject:onfoot];
    } else {
        // в Дубки
        // Маршрут: Пешком->Метро->Переход->Электричка->Переход->Автобус
        
        // станции ж/д
        NSDictionary<NSString *, NSObject *> *stationFrom = self.stations[(NSString *)campus[@"station"]];
        NSDictionary<NSString *, NSObject *> *stationTo = self.stations[(NSString *)dorm[@"station"]];
        
        // станции метро
        NSString *subwayFrom = (NSString *)campus[@"subway"];
        NSString *subwayTo = (NSString *)stationFrom[@"subway"];
        
        // пешком
        OnFootStep *onfoot = [[OnFootStep alloc] initWithDeparture:timestamp
                                                            andEdu:campus];
        
        // на метро
        SubwayStep *subway = [[SubwayStep alloc] initWithDeparture:onfoot.arrival
                                                           andFrom:subwayFrom
                                                             andTo:subwayTo];
        
        //TODO: добавить обработку автобуса от м.Славянский бульвар
        
        // переход Метро->Станция
        TransitionStep *transit1 = [[TransitionStep alloc] initWithDeparture:subway.arrival
                                                                     andFrom:(NSString *)self.subways[subwayTo]
                                                                       andTo:(NSString *)stationFrom[@"title"]
                                                                 andDuration:((NSNumber *)stationFrom[@"transit"]).integerValue];
        
        //электричкой
        TrainStep *train = [[TrainStep alloc] initWithDeparture:transit1.arrival
                                                        andFrom:stationFrom
                                                          andTo:stationTo];
        
        // переход Станция->Автобус
        TransitionStep *transit2 = [[TransitionStep alloc] initWithDeparture:train.arrival
                                                                     andFrom:NSLocalizedString(@"Station", comment: @"") // "Станция"
                                                                       andTo:NSLocalizedString(@"Bus", comment: @"") // "Автобус"
                                                                 andDuration:((NSNumber *)stationTo[@"transit"]).integerValue];
        
        // автобусом
        BusStep *bus = [[BusStep alloc] initWithDeparture:transit2.arrival
                                                  andFrom:@"Одинцово"
                                                    andTo:@"Дубки"];
        
        // общая информация о пути
        TotalStep *way = [[TotalStep alloc] initWithFrom:(NSString *)campus[@"title"]
                                                   andTo:(NSString *)dorm[@"title"]
                                            andDeparture:onfoot.departure
                                              andArrival:bus.arrival];
        
        // формирование информации о пути
        [self.route addObject:way];
        [self.route addObject:onfoot];
        [self.route addObject:subway];
        if (transit1.duration > 0) {
            [self.route addObject:transit1];
        }
        [self.route addObject:train];
        if (transit2.duration > 0) {
            [self.route addObject:transit2];
        }
        [self.route addObject:bus];
    }
}

/**
 Calculates a route as if timestamp is the time of arrival
 
 Args:
 direction (Int): flow from/to dormitory
 campus (Dictionary): place edu of arrival/departure
 timestampEnd(NSDate): expected time of arrival
 
 Returns:
 route (Array): a calculated route
 */
- (void)calculateRouteByArrival:(NSDate *)arrival
                   andDirection:(NSInteger)direction
                      andCampus:(NSDictionary<NSString *, NSObject*> *)campus {
    
    NSDictionary<NSString *, NSObject *> *dorm = self.dormitories[0]; // общежитие
    
    self.route = [[NSMutableArray alloc] init]; // очистка маршрута
    
    NSDate *timestamp = [arrival dateByAddingMinute:-10]; // прибыть за 10 минут до нужного времени
    
    if (direction == 0) {
        // из Дубков
        // Маршрут: Автобус->Переход->Электричка->Переход->Метро->Пешком
        
        // станции ж/д
        NSDictionary<NSString *, NSObject *> *stationFrom = self.stations[(NSString *)dorm[@"station"]];
        NSDictionary<NSString *, NSObject *> *stationTo = self.stations[(NSString *)campus[@"station"]];
        
        // станции метро
        NSString *subwayFrom = (NSString *)stationTo[@"subway"];
        NSString *subwayTo = (NSString *)campus[@"subway"];
        
        // пешком
        OnFootStep *onfoot = [[OnFootStep alloc] initWithArrival:timestamp
                                                          andEdu:campus];
        
        // на метро
        SubwayStep *subway = [[SubwayStep alloc] initWithArrival:onfoot.departure
                                                         andFrom:subwayFrom
                                                           andTo:subwayTo];
        
        // переход Станция->Метро
        TransitionStep *transit2 = [[TransitionStep alloc] initWithArrival:subway.departure
                                                                   andFrom:(NSString *)stationTo[@"title"]
                                                                     andTo:self.subways[subwayFrom]
                                                               andDuration:((NSNumber *)stationTo[@"transit"]).integerValue];
        
        // электричкой
        TrainStep *train = [[TrainStep alloc] initWithArrival:transit2.departure
                                                      andFrom:stationFrom
                                                        andTo:stationTo];
        
        // Коррекция времени отправления и прибытия в зависимости от расписания электрички
        transit2.departure = train.arrival;
        transit2.arrival = [transit2.departure dateByAddingMinute:transit2.duration];
        
        subway.departure = transit2.arrival;
        subway.arrival = [subway.departure dateByAddingMinute:subway.duration];
        
        onfoot.departure = subway.arrival;
        onfoot.arrival = [onfoot.departure dateByAddingMinute:onfoot.duration];
        
        // переход Автобус->Станция
        TransitionStep *transit1 = [[TransitionStep alloc] initWithArrival:train.departure
                                                                   andFrom:NSLocalizedString(@"Bus", comment: @"") // "Автобус"
                                                                     andTo:NSLocalizedString(@"Station", comment: @"") // "Станция"
                                                               andDuration:((NSNumber *)stationFrom[@"transit"]).integerValue];
        
        // автобусом
        BusStep *bus = [[BusStep alloc] initWithArrival:transit1.departure
                                                andFrom:@"Дубки"
                                                  andTo:@"Одинцово"];
        
        // общая информация о пути
        TotalStep *way = [[TotalStep alloc] initWithFrom:(NSString *)dorm[@"title"]
                                                   andTo:(NSString *)campus[@"title"]
                                            andDeparture:[bus.departure dateByAddingMinute:-10] // 10 минут на сборы
                                              andArrival:onfoot.arrival];
        
        // формирование информации о пути
        [self.route addObject:way];
        [self.route addObject:bus];
        if (transit1.duration > 0) {
            [self.route addObject:transit1];
        }
        [self.route addObject:train];
        if (transit2.duration > 0) {
            [self.route addObject:transit2];
        }
        [self.route addObject:subway];
        [self.route addObject:onfoot];
        
    } else {
        // в Дубки
        // Маршрут: Пешком->Метро->Переход->Электричка->Переход->Автобус
        
        // станции ж/д
        NSDictionary<NSString *, NSObject *> *stationFrom = self.stations[(NSString *)campus[@"station"]];
        NSDictionary<NSString *, NSObject *> *stationTo = self.stations[(NSString *)dorm[@"station"]];
        
        // станции метро
        NSString *subwayFrom = (NSString *)campus[@"subway"];
        NSString *subwayTo = (NSString *)stationFrom[@"subway"];
        
        // автобусом
        BusStep *bus = [[BusStep alloc] initWithArrival:timestamp
                                                andFrom:@"Одинцово"
                                                  andTo:@"Дубки"];
        
        // переход Станция->Автобус
        TransitionStep *transit2 = [[TransitionStep alloc] initWithArrival:bus.departure
                                                                   andFrom:NSLocalizedString(@"Station", comment: @"") // "Станция"
                                                                     andTo:NSLocalizedString(@"Bus", comment: @"") // "Автобус"
                                                               andDuration:((NSNumber *)stationTo[@"transit"]).integerValue];
        
        //электричкой
        TrainStep *train = [[TrainStep alloc] initWithArrival:transit2.departure
                                                      andFrom:stationFrom
                                                        andTo:stationTo];
        
        // переход Метро->Станция
        TransitionStep *transit1 = [[TransitionStep alloc] initWithArrival:train.departure
                                                                   andFrom:self.subways[subwayTo]
                                                                     andTo:(NSString *)stationFrom[@"title"]
                                                               andDuration:((NSNumber *)stationFrom[@"transit"]).integerValue];
        
        // на метро
        SubwayStep *subway = [[SubwayStep alloc] initWithArrival:transit1.departure
                                                         andFrom:subwayFrom
                                                           andTo:subwayTo];
        
        // пешком
        OnFootStep *onfoot = [[OnFootStep alloc] initWithArrival:subway.departure
                                                          andEdu:campus];
        
        // TODO: можно попробовать подобрать автобус после прибытия электрички
        
        // общая информация о пути
        TotalStep *way = [[TotalStep alloc] initWithFrom:(NSString *)campus[@"title"]
                                                   andTo:(NSString *)dorm[@"title"]
                                            andDeparture:[onfoot.departure dateByAddingMinute:-10] // 10 минут на сборы
                                              andArrival:bus.arrival];
        
        // формирование информации о пути
        [self.route addObject:way];
        [self.route addObject:onfoot];
        [self.route addObject:subway];
        if (transit1.duration > 0) {
            [self.route addObject:transit1];
        }
        [self.route addObject:train];
        if (transit2.duration > 0) {
            [self.route addObject:transit2];
        }
        [self.route addObject:bus];
    }
}

@end
