//
//  AboutViewController.m
//  Dubki2
//
//  Created by Игорь Моренко on 19.11.15.
//  Copyright © 2015 LionSoft LLC. All rights reserved.
//

#import "AboutViewController.h"

#pragma mark - Private Interface

@interface AboutViewController ()
{
    IBOutlet UILabel *versionLabel;
}

@end

#pragma mark - Implementation

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *build = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    
    versionLabel.text = [NSString stringWithFormat:@"ver. %@ (build %@)", version, build];
}

- (IBAction)donatePressButton:(id)sender {
    //NSURL *moneyURL = [NSURL URLWithString:@"https://money.yandex.ru/embed/shop.xml?account=41001824209175&quickpay=shop&payment-type-choice=on&writer=seller&targets=Dubki&targets-hint=&default-sum=100&button-text=03&comment=on&hint=&successURL="];
    NSURL *moneyURL = [NSURL URLWithString:@"http://yasobe.ru/na/dubki_app"];
    [[UIApplication sharedApplication] openURL:moneyURL];
}

@end
