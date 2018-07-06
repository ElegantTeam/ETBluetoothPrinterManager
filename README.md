# ETBluetoothPrinterManager

It can help you discover and connect printer.You also can manage the bluetooth status.

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
Through these delegate methods, you can do something dealing.
```
- (void)bluetoothStatusHasChange:(BOOL)isOn;
- (void)didDiscoverPeripherals:(NSArray *)peripherals;
- (void)didConnectPeripheral;
- (void)writeValueSuccess;
- (void)didFailConnectPeripheral;
```
### Recent Peripherals
You can get the recent matched peripherals in the filtered Peripherals  which discovered.
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
