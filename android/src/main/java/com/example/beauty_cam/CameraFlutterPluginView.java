package com.example.beauty_cam;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.ContextWrapper;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.hardware.Camera;
import android.net.Uri;
import android.os.Build;
import android.util.AttributeSet;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import androidx.annotation.NonNull;

import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.core.view.ViewCompat;

import org.wysaid.common.Common;
import org.wysaid.myUtils.FileUtil;
import org.wysaid.myUtils.ImageUtil;
import org.wysaid.nativePort.CGENativeLibrary;
import org.wysaid.view.CameraRecordGLSurfaceView;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.platform.PlatformView;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Objects;

public class CameraFlutterPluginView extends CameraRecordGLSurfaceView implements MethodChannel.MethodCallHandler, PlatformView {

    private static final String TAG = CameraFlutterPluginView.class.getSimpleName();
    public  Context mContext;
    /**
     * 通道
     */
    private  MethodChannel methodChannel = null;// controls button state//1.capture 2.record

    //当前滤镜
    private String mCurrentConfig="";
    //美颜配置
    private String beautyConfig="";
    private String  recordFilename="";
    String path=ImageUtil.getPath();
    String loadImageResource="";
    private CameraRecordGLSurfaceView mCameraView;
    public final static String LOG_TAG = CameraRecordGLSurfaceView.LOG_TAG;
    float level;
    private float mOldDistance;

    @SuppressLint({"NewApi", "ClickableViewAccessibility"})
    public CameraFlutterPluginView(Context context, int viewId, Object args, BinaryMessenger messenger, AttributeSet attrs) {
        super(context,attrs);
        //注册
        methodChannel = new MethodChannel(messenger, "beauty_cam");
        methodChannel.setMethodCallHandler(this);
        this.mContext = context;



        CGENativeLibrary.setLoadImageCallback(new CGENativeLibrary.LoadImageCallback() {
            //Notice: the 'name' passed in is just what you write in the rule, e.g: 1.jpg
            //注意， 这里回传的name不包含任何路径名， 仅为具体的图片文件名如 1.jpg
            @Override
            public Bitmap loadImage(String name, Object arg) {
                Log.i(Common.LOG_TAG, "Loading file: " + name);

                InputStream is;
                try {

                    if(loadImageResource==""){
                        loadImageResource=context.getCacheDir().getPath();
                        Log.e(TAG,"*******************"+loadImageResource);
                    }
                    File file = new File(loadImageResource+"/"+name);
                    is = new FileInputStream(file);
                } catch (IOException e) {
                    Log.e(Common.LOG_TAG, "Can not open file " + name);
                    return null;
                }
                return BitmapFactory.decodeStream(is);
            }

            @Override
            public void loadImageOK(Bitmap bmp, Object arg) {
                Log.i(Common.LOG_TAG, "Loading bitmap over, you can choose to recycle or cache");
                //The bitmap is which you returned at 'loadImage'.
                //You can call recycle when this function is called, or just keep it for further usage.
                //唯一不需要马上recycle的应用场景为 多个不同的滤镜都使用到相同的bitmap
                //那么可以选择缓存起来。
                bmp.recycle();
            }
        }, null);
        mCameraView =this;
        mCameraView.presetCameraForward(false);
        mCameraView.presetRecordingSize(1080, 1920);
        //Taking picture size.
        mCameraView.setPictureSize(2048, 2048, true); // > 4MP
        mCameraView.setZOrderOnTop(false);
        mCameraView.setZOrderMediaOverlay(true);
        mCameraView.setOnCreateCallback(new CameraRecordGLSurfaceView.OnCreateCallback() {
            @Override
            public void createOver() {
                Log.i(LOG_TAG, "view onCreate");
            }
        });

        //TODO:增加放大缩小

        mCameraView.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, final MotionEvent event) {

                switch (event.getActionMasked()) {
                    case MotionEvent.ACTION_DOWN: {
                        Log.i(LOG_TAG, String.format("Tap to focus: %g, %g", event.getX(), event.getY()));
                        final float focusX = event.getX() / mCameraView.getWidth();
                        final float focusY = event.getY() / mCameraView.getHeight();

                        mCameraView.focusAtPoint(focusX, focusY, new Camera.AutoFocusCallback() {
                            @Override
                            public void onAutoFocus(boolean success, Camera camera) {
                                if (success) {
                                    Log.e(LOG_TAG, String.format("Focus OK, pos: %g, %g", focusX, focusY));
                                } else {
                                    Log.e(LOG_TAG, String.format("Focus failed, pos: %g, %g", focusX, focusY));
                                    mCameraView.cameraInstance().setFocusMode(Camera.Parameters.FOCUS_MODE_CONTINUOUS_VIDEO);

                                }
                            }
                        });
                    }
                    break;
                    default:
                        break;
                }

                if (event.getPointerCount() == 2) { // 当触碰点有2个时，才去放大缩小
                    int maxZoom = getCameraMaxZoom();
                    int currentZoom = getCameraCurrentZoom();
                    switch (event.getAction() & MotionEvent.ACTION_MASK) {
                        case MotionEvent.ACTION_POINTER_DOWN:
                            // 点下时，得到两个点间的距离为mOldDistance
                            mOldDistance = getFingerSpacing(event);
                            break;
                        case MotionEvent.ACTION_MOVE:
                            // 移动时，根据距离是变大还是变小，去放大还是缩小预览画面
                            float newDistance = getFingerSpacing(event);
                            if (newDistance > mOldDistance) {

                                // 放大
                                if (currentZoom < maxZoom) {
                                    currentZoom++;
                                    setCameraZoom(currentZoom);
                                }

                            } else if (newDistance < mOldDistance) {
                                // 缩小
                                if (currentZoom > 0) {
                                    currentZoom--;
                                    setCameraZoom(currentZoom);
                                }
                            }
                            // 更新mOldDistance
                            mOldDistance = newDistance;
                            break;
                            case MotionEvent.ACTION_UP:
                                mCameraView.cameraInstance().getCameraDevice().stopSmoothZoom();
                        default:
                            break;
                    }
                }

                return true;
            }
        });

    }


    private void setCameraZoom(int zoomValue) {
        Camera.Parameters params = mCameraView.cameraInstance().getCameraDevice().getParameters();
        params.setZoom(zoomValue);
        mCameraView.cameraInstance().getCameraDevice().setParameters(params);
    }

    private int getCameraMaxZoom() {
        Camera.Parameters params = mCameraView.cameraInstance().getCameraDevice().getParameters();
        return params.getMaxZoom();
    }

    private int getCameraCurrentZoom() {
        Camera.Parameters params = mCameraView.cameraInstance().getCameraDevice().getParameters();
        return params.getZoom();
    }


    private static float getFingerSpacing(MotionEvent event) {
        float x = event.getX(0) - event.getX(1);
        float y = event.getY(0) - event.getY(1);
        return (float) Math.sqrt(x * x + y * y);
    }
    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        handleCall(call, result);

    }
    private void handleCall(MethodCall methodCall, MethodChannel.Result result) {

        switch (methodCall.method) {
            //切换镜头
            case "switchCamera":
                mCameraView.switchCamera();
                break;
            //切换滤镜
            case "addFilter":
                mCurrentConfig= methodCall.argument("filter");
                mCameraView.setFilterWithConfig(beautyConfig+mCurrentConfig);
                break;
            //开启或关闭美颜
            case "enableBeauty":
               Boolean enableBeauty= methodCall.argument("isEnableBeauty");
               if(enableBeauty){
                   beautyConfig="@beautify face "+level+" 480 640 ";

               }else{
                   beautyConfig="";


               }
                mCameraView.setFilterWithConfig(beautyConfig+mCurrentConfig);

                break;
            //美颜程度（0~100）
            case "setBeautyLevel":
                level = Float.parseFloat(Objects.requireNonNull(methodCall.argument("level")).toString());
                float currentIntensity = level * 2.0f - 1.0f; //[-1, 1]
                mCameraView.setFilterIntensity(currentIntensity);
                beautyConfig="@beautify face "+currentIntensity+" 480 640 ";
                mCameraView.setFilterWithConfig(beautyConfig+mCurrentConfig);
//                mCameraView.setFilterIntensity(level);
                break;
            //拍照
            case "takePicture":
                String image = path + "/beauty_" + System.currentTimeMillis() + ".jpg";
                mCameraView.takeShot(new CameraRecordGLSurfaceView.TakePictureCallback() {
                    @Override
                    public void takePictureOK(Bitmap bmp) {
                        if (bmp != null) {
                            ImageUtil.saveBitmap(bmp,image);
                            bmp.recycle();
                            result.success(image);
                        }
                    }
                });
                break;
            //录制视频
            case "takeVideo":
                 recordFilename = path + "/beauty_" + System.currentTimeMillis() + ".mp4";
                mCameraView.startRecording(recordFilename);
                break;
            case "stopVideo":
                mCameraView.endRecording(new CameraRecordGLSurfaceView.EndRecordingCallback() {
                    @Override
                    public void endRecordingOK() {
                        result.success(recordFilename);
                        recordFilename="";
                    }
                });
                break;
            //设置文件保存路径
            case "setOuPutFilePath":
                 path=methodCall.argument("path");

                break;
            //设置图片纹理加载路径（默认存放在Caches目录）
            case "setLoadImageResource":
                loadImageResource=methodCall.argument("path");
                break;
            default:

                break;
        }
    }

    @Nullable
    @Override
    public View getView() {
        return this;
    }

    @Override
    public void dispose() {

    }
}
