const { execSync } = require("child_process");

class ADB {
    _run = (command) => {
        return execSync(command, { encoding: "utf8", stdio: [process.stdout] });
    };

    _adb = (args, device = null) => {
        var base = ["adb"];
        if (device) {
            base.push("-s", device);
        }
        args = base.concat(args);

        return this._run(args.join(" "));
    };

    _getprop = (device, property, defaultValue) => {
        var out;
        try {
            out = this._adb(["shell", "getprop", property], device);
        } catch {
            return defaultValue;
        }

        if (out.trim()) {
            return out.trim();
        }
        return defaultValue;
    };

    _getname = (device, defaultValue) => {
        var out;
        try {
            out = this._adb(["shell", "settings get global device_name"], device);
        } catch {
            return defaultValue;
        }

        if (out.trim()) {
            return out.trim();
        }
        return defaultValue;
    };

    get_devices = () => {
        const out = this._adb(["devices"]);

        var devices = [];

        out.split("\n").forEach((l) => {
            let tokens = l.split("\t");
            if (tokens.length === 2) {
                let id = tokens[0];
                devices.push({
                    id: id,
                    version: this._getprop(id, "ro.build.version.release", "unauthorized"),
                    manufacturer: this._getprop(id, "ro.product.manufacturer", "unauthorized"),
                    model: this._getprop(id, "ro.product.model", "unauthorized"),
                    name: this._getname(id, "unauthorized"),
                });
            }
        });

        return devices;
    };
}

module.exports = {
    ADB,
};
