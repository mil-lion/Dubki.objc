//
//  ScheduleService.m
//  Dubki2
//
//  Created by Игорь Моренко on 18.11.15.
//  Copyright © 2015 LionSoft LLC. All rights reserved.
//

#import "ScheduleService.h"
#import "Date.h"

#pragma mark - Private Interface

@interface ScheduleService ()

@property (strong, nonatomic) NSDate *lastUpdate;

@end

#pragma mark - Implementation

@implementation ScheduleService

// API Keys
NSDictionary<NSString *, NSString *> *apikeys;

NSString *BUS_SCHEDULE_FILE = @"bus.json";
NSString *TRAIN_SCHEDULE_FILE = @"train.json";

NSURL *busFileURL;   // путь к файлу bus.json
NSURL *trainFileURL; // путь к файлу train.json

NSDictionary *busSchedule;
NSMutableDictionary *trainSchedule;

- (NSDate *)lastUpdate {
    [[NSUserDefaults standardUserDefaults] synchronize];
    return (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:@"last_update"];
}

- (void)setLastUpdate:(NSDate *)lastUpdate {
    [[NSUserDefaults standardUserDefaults] setObject:lastUpdate forKey:@"last_update"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

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
        // Initialize
        NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                      inDomains:NSUserDomainMask] firstObject];
        busFileURL = [documentsURL URLByAppendingPathComponent:BUS_SCHEDULE_FILE];
        trainFileURL = [documentsURL URLByAppendingPathComponent:TRAIN_SCHEDULE_FILE];

        apikeys = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"apikeys"
                                                                                               ofType:@"plist"]];
        
        //let fileManager = NSFileManager.defaultManager()
        //if fileManager.fileExistsAtPath(filePath) {
        
        // загрузка расписания из файла bus.json
        NSData *busData = [NSData dataWithContentsOfURL:busFileURL];
        if (busData) {
            // Parse JSON Data (deserialized)
            NSError *error = nil;
            busSchedule = [NSJSONSerialization JSONObjectWithData:busData
                                                          options:NSJSONReadingAllowFragments
                                                            error:&error];
            if (error) {
                [self showError:error];
            }
        }
        // загрузка расписания из файла train.json
        NSData *trainData = [NSData dataWithContentsOfURL:trainFileURL];
        if (trainData) {
            // Parse JSON Data (deserialized)
            NSError *error = nil;
            trainSchedule = [NSJSONSerialization JSONObjectWithData:trainData
                                                            options:NSJSONReadingAllowFragments
                                                              error:&error];
            if (error) {
                [self showError:error];
            }
        }
        
        [self cacheSchedules];
    }
    
    return self;
}

- (void)showError:(NSError *)error {
    Log(@"Error JSON deserialized: %@", error.localizedDescription)
//    NSString *title = [[NSString alloc] initWithFormat:@"Error (%ld)", (long)error.code];
//#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 8000
//    // Only COMPILE this if compiled against BaseSDK iOS8.0 or greater
//    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
//                                                                   message:error.localizedDescription
//                                                            preferredStyle:UIAlertControllerStyleAlert];
//    
//    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
//                                                          handler:^(UIAlertAction * action) {}];
//    
//    [alert addAction:defaultAction];
//    [self presentViewController:alert animated:YES completion:nil];
//#else
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
//                                                        message:[error localizedDescription]
//                                                       delegate:nil
//                                              cancelButtonTitle:@"Ok"
//                                              otherButtonTitles:nil];
//    [alertView show];
//#endif
}

// Кэширование расписания автобуса и электрички на сегодня
- (void)cacheSchedules {
    NSString *today = [[NSDate date] stringByFormat:@"yyyyMMdd"];
    if (self.lastUpdate != nil && [[self.lastUpdate stringByFormat:@"yyyyMMdd"] isEqualToString:today]) {
        if (busSchedule != nil && trainSchedule != nil) {
            return;
        }
    }
    
    //[[UIApplication sharedApplication] networkActivityIndicatorVisible:YES];
    [self cacheScheduleBus];
    [self cacheTrainSchedule];
    //[[UIApplication sharedApplication] networkActivityIndicatorVisible:YES];
    if (busSchedule != nil && trainSchedule != nil) {
        // update schedule successfull
        self.lastUpdate = [NSDate date];
    }
}

#pragma mark - Train Schedule

/*
 Caches a schedule between all stations
 */
- (void)cacheTrainSchedule {
    trainSchedule = [[NSMutableDictionary alloc] init];
    NSString *date = [[NSDate date] stringByFormat:@"yyyy-MM-dd"];
    NSString *from = @"c10743"; //"Одинцово" = "s9600721"
    NSArray *toStations = @[@"s9601728", @"s9600821", @"s9601666", @"s2000006"]; //["Кунцево", "Фили", "Беговая", "Белорусская"]
    for (NSString *to in toStations) {
        NSArray *fromTo = [self loadScheduleTrainByFrom:from
                                                  andTo:to
                                                andDate:date];
        if (fromTo) {
            NSString *key = [NSString stringWithFormat:@"%@:%@:%@", from, to, date];
            trainSchedule[key] = fromTo;
        }
        NSArray *toFrom = [self loadScheduleTrainByFrom:to
                                                  andTo:from
                                                andDate:date];
        if (toFrom) {
            NSString *key = [NSString stringWithFormat:@"%@:%@:%@", to, from, date];
            trainSchedule[key] = toFrom;
        }
    }
    // сохранить в файл train.json
    // Create JSON data from dictionary (serialized)
    NSError *error = nil;
    NSData *myJSONData = [NSJSONSerialization dataWithJSONObject:trainSchedule
                                                         options:NSJSONWritingPrettyPrinted
                                                           error:&error];
    if (myJSONData) {
        [myJSONData writeToURL:trainFileURL atomically:YES];
    }
}

/*
 Caches a schedule between stations from arguments starting with certain day
 Writes the cached schedule for day and two days later to train_cached_* files
 
 Args:
 from(String): departure train station
 to(String): arrival train station
 timestamp(NSDate): date to cache schedule for
 */
- (NSArray *)loadScheduleTrainByFrom:(NSString *)from
                                    andTo:(NSString *)to
                                  andDate:(NSString *)date {
    NSString *YANDEX_API_KEY = apikeys[@"rasp.yandex.ru"];
    // URL of train schedule API provider
    NSString *TRAIN_API_URL = @"https://api.rasp.yandex.net/v1.0/search/?apikey=%@&format=json&date=%@&from=%@&to=%@&lang=ru&transport_types=suburban";
    
    NSString *apiURL = [NSString stringWithFormat:TRAIN_API_URL, YANDEX_API_KEY, date, from, to];
    
    // загрузка распияния из интернета
    NSData *trainScheduleData = [NSData dataWithContentsOfURL:[NSURL URLWithString:apiURL]];
    if (trainScheduleData) {
        // Parse JSON Data (deserialized)
        NSError *error = nil;
        NSDictionary *schedule = [NSJSONSerialization JSONObjectWithData:trainScheduleData
                                                                 options:NSJSONReadingAllowFragments
                                                                   error:&error];
        if (error) {
            [self showError:error];
            return nil;
        }
        
        NSMutableArray *trains = [[NSMutableArray alloc] init];
        for (NSDictionary *item in ((NSArray<NSDictionary *> *)schedule[@"threads"])) {
            NSMutableDictionary *train = [[NSMutableDictionary alloc] init];
            train[@"arrival"] = item[@"arrival"];
            train[@"departure"] = item[@"departure"];
            train[@"duration"] = item[@"duration"];
            train[@"stops"] = item[@"stops"];
            train[@"title"] = item[@"thread"][@"title"];
            train[@"number"] = item[@"thread"][@"number"];
            [trains addObject:train];
        }
        return trains;
    }
    return nil;
}

/*
 Returns a cached schedule between stations in arguments
 If no cached schedule is available, download and return a fresh one
 
 Args:
 from(String): departure train station
 to(String): arrival train station
 timestamp(NSDate): date to get schedule for
 */
- (NSArray<NSDictionary *> *)getScheduleTrainByFrom:(NSString *)from
                                              andTo:(NSString *)to
                                       andTimestamp:(NSDate *)timestamp {
    [self cacheSchedules];
    if (trainSchedule == nil) {
        return nil;
    }
    
    NSString *date = [timestamp stringByFormat:@"yyyy-MM-dd"];
    //let key = "\(from):\(to):\(date)"
    NSString *key = [NSString stringWithFormat:@"%@:%@:%@", from, to, date];
    if (trainSchedule[key] != nil) {
        return trainSchedule[key];
    }
    NSArray *schedule = schedule = [self loadScheduleTrainByFrom:from
                                                           andTo:to
                                                         andDate: date];
    if (schedule) {
        trainSchedule[key] = schedule;
        return schedule;
    }
    return nil;
}

#pragma mark - Bus Schedule

/**
 Caches the bus schedule to `SCHEDULE_FILE`
 Загрузить расписание автобуса из интернета
 */
- (void)cacheScheduleBus {
    NSString *BUS_API_URL = @"https://dubkiapi2.appspot.com/sch";
    
    // загрузка распияния из интернета
    NSData *busData = [NSData dataWithContentsOfURL:[NSURL URLWithString:BUS_API_URL]];
    if (busData) {
        // сохранить расписание в файл bus.json
        [busData writeToURL:busFileURL atomically:YES];
        
        // Parse JSON Data (deserialized)
        NSError *error = nil;
        busSchedule = [NSJSONSerialization JSONObjectWithData:busData
                                                      options:NSJSONReadingAllowFragments
                                                        error:&error];
        if (error) {
            [self showError:error];
            return;
        }
    }
}

// загрузка расписания автобусов Дубки-Одинцово в файл bus.json
- (NSArray<NSString *> *)getScheduleBusByFrom:(NSString *)from
                                        andTo:(NSString *)to
                                 andTimestamp:(NSDate *)timestamp {
    [self cacheSchedules];
    if (busSchedule == nil) {
        return nil;
    }
    
    NSString *_from = from;
    NSString *_to = to;
    
    // today is either {'', '*Суббота', '*Воскресенье'}
    if (timestamp.weekday == 7) {
        if ([from isEqualToString:@"Дубки"]) {
            _from = @"ДубкиСуббота";
        } else if ([to isEqualToString:@"Дубки"]) {
            _to = @"ДубкиСуббота";
        }
    } else if (timestamp.weekday == 1) {
        if ([from isEqualToString:@"Дубки"]) {
            _from = @"ДубкиВоскресенье";
        } else if ([to isEqualToString:@"Дубки"]) {
            _to = @"ДубкиВоскресенье";
        }
    }
    
    NSMutableArray *times = [[NSMutableArray alloc] init]; // время отправления автобуса
    // find current schedule
    for (NSDictionary *elem in busSchedule) {
        NSString *elemFrom = elem[@"from"];
        NSString *elemTo = elem[@"to"];
        if ([elemFrom isEqualToString:_from] && [elemTo isEqualToString:_to]) {
            NSArray *currentSchedule = elem[@"hset"];
            // convert to array of time
            for (NSDictionary *time in currentSchedule) {
                [times addObject:time[@"time"]];
            }
            break;
        }
    }
    
    return times;
}

/*
 // MARK: - Function for URL request
 
 // Synchronous Request
 func synchronousRequest(url: NSURL) -> NSData? {
 var result: NSData? = nil
 
 let session = NSURLSession.sharedSession()
 
 // set semaphore
 let sem = dispatch_semaphore_create(0)
 
 let task1 = session.dataTaskWithURL(url, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
 //print(response)
 //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
 
 //let jsonData = JSON(data: data!)
 result = data
 
 // delete semophore
 dispatch_semaphore_signal(sem)
 })
 // run parallel thread
 task1.resume()
 
 // white delete semophore
 dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER)
 
 return result
 }
 */

@end
