package com.example.beauty_cam;
import android.content.Context;
import android.content.res.AssetManager;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MessageCodec;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class CameraFlutterPluginViewFactory extends PlatformViewFactory{
    private BinaryMessenger messenger = null;
    public CameraFlutterPluginViewFactory(BinaryMessenger messenger) {
        super(StandardMessageCodec.INSTANCE);
        this.messenger = messenger;

    }

    /**
     * @param createArgsCodec the codec used to decode the args parameter of {@link #create}.
     */
    public CameraFlutterPluginViewFactory(MessageCodec<Object> createArgsCodec) {
        super(createArgsCodec);
    }

    @Override
    public PlatformView create(Context context, int viewId, Object args) {
        return new CameraFlutterPluginView(context, viewId, args, this.messenger,null);
    }
}