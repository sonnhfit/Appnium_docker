# Android auto pilot using Appium

## Installation
 - Run `docker-compose up -d` or `make up` command.
 - That's all.

## Check connected devices
 - Make sure you have your smartphone with USB debug mode enabled and plugged in to the PC.
 - Get into docker bash using `make bash`.
 - Run `adb devices -l` to list all available devices.
 - If you see a device with status `unauthorized`, it means your PC doesn't have permission to access the phone. Unlock your phone and Tap `accept` if there's a promp showing up. If not, try unplug and plug it in again.


## Usage
 - Create task using `webdriverio` with the correct device id and send it to the Appium server. The server should connect to the device and start the process.