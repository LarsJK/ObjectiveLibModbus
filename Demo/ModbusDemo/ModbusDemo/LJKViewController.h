//
//  LJKViewController.h
//  ModbusDemo
//
//  Created by Lars-Jørgen Kristiansen on 11.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LJKViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *connectedLabel;
@property (weak, nonatomic) IBOutlet UIButton *writeRegisterButton;
@property (weak, nonatomic) IBOutlet UIButton *writeRegistersButton;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
- (IBAction)writeRegister:(id)sender;
- (IBAction)writeRegisters:(id)sender;

@end
