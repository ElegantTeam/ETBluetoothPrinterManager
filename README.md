# ETBluetoothPrinterManager

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Usage
1.At first, create manager instance.
```
self.manager = [ETBluetoothPrinterManager shareInstance];
```
2.Begin scan Peripheral use `[self.manager scanPeripherals];` after creating instance 
or
implement the proxy in **viewWillAppear** and scan in **bluetoothStatusHasChange**.
```
self.manager.delegate = self;
```

### Delegate
```
- (void)bluetoothStatusHasChange:(BOOL)isOn;
- (void)didDiscoverPeripherals:(NSArray *)peripherals;
- (void)didConnectPeripheral;
- (void)writeValueSuccess;
- (void)didFailConnectPeripheral;
```
### Recent Peripherals
You can get the recent paired peripherals in the discovered Peripherals of filtering through filtering.
```
self.pairedDevices = [self.manager recentConnectedPeriplerals:filters];
```

## Installation

ETBluetoothPrinterManager is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ETBluetoothPrinterManager'
```

## Requirements
·iOS 9.0+ 
·Objective-C

## License

ETBluetoothPrinterManager is available under the MIT license. See the LICENSE file for more info.
