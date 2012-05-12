//
//  LJKViewController.m
//  ModbusDemo
//
//  Created by Lars-Jørgen Kristiansen on 11.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LJKViewController.h"
#import "ObjectiveLibModbus.h"

@interface LJKViewController () {
    ObjectiveLibModbus *objLibModbus;
}

@end

@implementation LJKViewController
@synthesize connectedLabel;
@synthesize writeRegisterButton;
@synthesize writeRegistersButton;
@synthesize errorLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    objLibModbus = [[ObjectiveLibModbus alloc] initWithTCP:@"10.0.1.200" port:1502 device:1];
    [objLibModbus connect:^{
        connectedLabel.text = @"Connected!";
        writeRegisterButton.enabled = YES;
        writeRegistersButton.enabled = YES;
    } failure:^(NSError *error) {
        connectedLabel.text = @"Failed to connect!";
        errorLabel.text = [NSString stringWithFormat:@"Error Connecting: %@", error.localizedDescription];
    }];
    
}

- (void)viewDidUnload
{
    [self setWriteRegisterButton:nil];
    [self setConnectedLabel:nil];
    [self setErrorLabel:nil];
    [self setWriteRegistersButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (IBAction)writeRegister:(id)sender {
    //Writes register 0 on the connected device to 12345
    [objLibModbus writeRegister:0 to:12345 success:^{
        NSLog(@"Written!");
    } failure:^(NSError *error) {
        errorLabel.text = [NSString stringWithFormat:@"Error writing single register: %@", error.localizedDescription];
    }];
}

- (IBAction)writeRegisters:(id)sender {
    //Writes registers 0, 1, 2, 3, 4 to values 1, 2, 3, 4, 5.
    NSArray *valuesToWrite = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:1], [NSNumber numberWithInt:2], [NSNumber numberWithInt:3], [NSNumber numberWithInt:4], [NSNumber numberWithInt:5], nil];
    [objLibModbus writeRegistersFromAndOn:0 toValues:valuesToWrite success:^{
        NSLog(@"Written!");
    } failure:^(NSError *error) {
        errorLabel.text = [NSString stringWithFormat:@"Error writing multiple registers: %@", error.localizedDescription];

    }];
    
}
@end
