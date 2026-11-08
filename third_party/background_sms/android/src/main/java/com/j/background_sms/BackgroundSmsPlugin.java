package com.j.background_sms;

import android.app.Activity;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.telephony.SmsManager;

import java.util.ArrayList;
import java.util.concurrent.atomic.AtomicInteger;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** BackgroundSmsPlugin */
public class BackgroundSmsPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private Context applicationContext;
  private final Handler mainHandler = new Handler(Looper.getMainLooper());
  private final AtomicInteger nextRequestId = new AtomicInteger(1);
  private static final long SEND_TIMEOUT_MS = 60000;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    applicationContext = flutterPluginBinding.getApplicationContext();
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "background_sms");
    channel.setMethodCallHandler(this);
  }


  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("sendSms")) {
      String num = call.argument("phone");
      String msg = call.argument("msg");
      Integer simSlot = call.argument("simSlot");
      sendSMS(num, msg, simSlot, result);
    }else if(call.method.equals("isSupportMultiSim")) {
      isSupportCustomSim(result);
    } else{
      result.notImplemented();
    }
  }

  private void isSupportCustomSim(Result result){
    if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
      result.success(true);
    }else{
      result.success(false);
    }
  }

  private void sendSMS(String num, String msg, Integer simSlot,Result result) {
    SendResultReceiver receiver = null;
    try {
      if (num == null || num.isEmpty() || msg == null || msg.isEmpty()) {
        result.error("InvalidSms", "Phone number and message are required", null);
        return;
      }
      SmsManager smsManager = smsManagerFor(simSlot);
      ArrayList<String> parts = smsManager.divideMessage(msg);
      if (parts.isEmpty()) {
        result.error("InvalidSms", "Message is empty", null);
        return;
      }

      Context context = applicationContext;
      String action = context.getPackageName() + ".SMS_SENT." + nextRequestId.getAndIncrement();
      receiver = new SendResultReceiver(context, result, parts.size());
      receiver.register(action);

      ArrayList<PendingIntent> sentIntents = new ArrayList<>();
      for (int i = 0; i < parts.size(); i++) {
        Intent sentIntent = new Intent(action).setPackage(context.getPackageName());
        sentIntents.add(PendingIntent.getBroadcast(
            context,
            nextRequestId.getAndIncrement(),
            sentIntent,
            PendingIntent.FLAG_ONE_SHOT | PendingIntent.FLAG_IMMUTABLE));
      }
      if (parts.size() == 1) {
        smsManager.sendTextMessage(num, null, parts.get(0), sentIntents.get(0), null);
      } else {
        smsManager.sendMultipartTextMessage(num, null, parts, sentIntents, null);
      }
    } catch (Exception ex) {
      if (receiver == null) {
        result.error("Failed", "SMS could not be started", ex.getMessage());
      } else {
        receiver.fail(ex);
      }
    }
  }

  private final class SendResultReceiver extends BroadcastReceiver {
    private final Context context;
    private final Result result;
    private final int expectedParts;
    private Runnable timeout;
    private int receivedParts;
    private boolean failed;
    private boolean registered;
    private boolean finished;

    SendResultReceiver(Context context, Result result, int expectedParts) {
      this.context = context;
      this.result = result;
      this.expectedParts = expectedParts;
    }

    void register(String action) {
      IntentFilter filter = new IntentFilter(action);
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
        context.registerReceiver(this, filter, Context.RECEIVER_NOT_EXPORTED);
      } else {
        context.registerReceiver(this, filter);
      }
      registered = true;
      timeout = () -> finish("Unknown");
      mainHandler.postDelayed(timeout, SEND_TIMEOUT_MS);
    }

    @Override
    public void onReceive(Context context, Intent intent) {
      if (finished) return;
      if (getResultCode() != Activity.RESULT_OK) failed = true;
      if (++receivedParts >= expectedParts) finish(failed ? "Failed" : "Sent");
    }

    void fail(Exception error) {
      if (finished) return;
      cleanup();
      result.error("Failed", "SMS could not be sent", error.getMessage());
    }

    private void finish(String status) {
      if (finished) return;
      cleanup();
      result.success(status);
    }

    private void cleanup() {
      finished = true;
      if (timeout != null) mainHandler.removeCallbacks(timeout);
      if (registered) {
        context.unregisterReceiver(this);
        registered = false;
      }
    }
  }

  private SmsManager smsManagerFor(Integer simSlot) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
      SmsManager smsManager = applicationContext.getSystemService(SmsManager.class);
      if (smsManager == null) {
        throw new IllegalStateException("SMS service unavailable");
      }
      return simSlot == null ? smsManager : smsManager.createForSubscriptionId(simSlot);
    }
    return legacySmsManager(simSlot);
  }

  @SuppressWarnings("deprecation")
  private static SmsManager legacySmsManager(Integer simSlot) {
    if (simSlot != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      return SmsManager.getSmsManagerForSubscriptionId(simSlot);
    }
    return SmsManager.getDefault();
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    channel = null;
    applicationContext = null;
  }
}
