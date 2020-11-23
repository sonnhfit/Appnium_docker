const WebSocket = require("ws");

class VumSocket {
    constructor(address) {
        this.address = address;
    }

    connect() {
        this.socket = new WebSocket(this.address);
        this.socket.onopen = this.open;
        this.socket.onclose = this.close;
        this.socket.onmessage = this.message;
        this.socket.onerror = this.error;
    }

    open() {
        console.log("CONNECTED");
    }

    close(event) {
        console.log("DISCONNECTED", event.reason);
    }

    error(err) {
        console.error("ERROR: ", err.message, "Closing socket");
        this.socket.close();
    }

    message(event) {
        console.log(event.data);
    }

    send(data) {
        this.socket.send(JSON.stringify(data));
    }
}

module.exports = {
    VumSocket,
};
