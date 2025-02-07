"use strict";

const { VumSocket } = require("./core/websocket");
const { ADB } = require("./core/adb");

const socket = new VumSocket("ws://pydev.vn:8002/facebook/");
const adb = new ADB();

const send_devices_info = () => {
    console.log("SENDING DEVICES INFO");
    socket.send(adb.get_devices());
    this.updateDevicesTimeout = setTimeout(send_devices_info, 300000);
};

socket.open = () => {
    console.log("CONNECTED");
    clearTimeout(this.reconnectTimeout);

    send_devices_info();
};

socket.close = (event) => {
    console.log("DISCONNECTED", event.reason);
    clearTimeout(this.updateDevicesTimeout);

    this.reconnectTimeout = setTimeout(() => {
        console.log("RECONNECTING...");
        this.connect(this.address);
    }, 5000);
};

socket.connect();
