package de.jalixdesign.plugins.capactiorjdudp;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

@CapacitorPlugin(name = "jdudp")
public class jdudpPlugin extends Plugin {

    private jdudp implementation = new jdudp();

    @PluginMethod
    public void echo(PluginCall call) {
        String value = call.getString("value");

        JSObject ret = new JSObject();
        ret.put("value", implementation.echo(value));
        call.resolve(ret);
    }

    @PluginMethod
    public void searchCams(PluginCall call) {
        JSObject ret = new JSObject();
        ret.put("test", "test");

        JSObject data = new JSObject();
        data.put("id", "unique-id-1234");
        ret.put("data", data);

        call.resolve(ret);
    }
}
