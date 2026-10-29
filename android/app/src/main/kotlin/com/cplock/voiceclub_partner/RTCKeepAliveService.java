package com.cplock.voiceclub_partner;

import android.app.Service;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.IBinder;
import android.util.Log;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import org.json.JSONObject;

public class RTCKeepAliveService extends Service {
    private static final String TAG = "RTCKeepAliveService";

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.d(TAG, "RTCKeepAliveService started");
        return START_NOT_STICKY;
    }

    @Override
    public void onTaskRemoved(Intent rootIntent) {
        super.onTaskRemoved(rootIntent);
        Log.d(TAG, "App swiped away from recents! Sending endCall payload via native connection...");

        SharedPreferences prefs = getSharedPreferences("RTC_PREFS", MODE_PRIVATE);
        
        final String channelId = prefs.getString("channel_id", "");
        final int endedBy = prefs.getInt("ended_by", 0);
        final String jwtToken = prefs.getString("jwt_token", "");
        final String endCallUrl = prefs.getString("end_call_url", "");
        final boolean callAlreadyEnded = prefs.getBoolean("call_already_ended", false);

        Log.d(TAG, "Loaded call config from prefs:"
                + " channel_id=" + channelId
                + ", ended_by=" + endedBy
                + ", jwt_token=" + jwtToken
                + ", end_call_url=" + endCallUrl
                + ", call_already_ended=" + callAlreadyEnded);

        if (callAlreadyEnded) {
            Log.d(TAG, "Skipping endCall request: call was already ended in-app");
            stopSelf();
            return;
        }

        // Only fire if we have a valid token, active channel id, and end call URL
        if (!channelId.isEmpty() && !jwtToken.isEmpty() && !endCallUrl.isEmpty()) {
            Thread thread = new Thread(new Runnable() {
                @Override
                public void run() {
                    try {
                        URL url = new URL(endCallUrl);
                        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                        
                        conn.setRequestMethod("POST");
                        
                        // Injecting JWT authentication header
                        String authHeader = jwtToken.startsWith("Bearer ") ? jwtToken : "Bearer " + jwtToken;
                        conn.setRequestProperty("Authorization", authHeader);
                        conn.setRequestProperty("Content-Type", "application/json");

                        conn.setDoOutput(true);
                        conn.setConnectTimeout(3000); 
                        conn.setReadTimeout(3000);

                        // Match Retrofit/Dio endCall payload (JSON body with @Field keys)
                        JSONObject jsonBody = new JSONObject();
                        jsonBody.put("channel_id", channelId);
                        jsonBody.put("call_rejected", false);
                        jsonBody.put("ended_by", endedBy);
                        jsonBody.put("decline_reason", "App killed by partner");
                        String postData = jsonBody.toString();

                        Log.d(TAG, "Sending endCall request:"
                                + " url=" + url
                                + ", authorization=" + authHeader
                                + ", postData=" + postData);

                        try (OutputStream os = conn.getOutputStream()) {
                            byte[] input = postData.getBytes("UTF-8");
                            os.write(input, 0, input.length);
                            os.flush();
                        }

                        int responseCode = conn.getResponseCode();
                        String responseBody = readResponseBody(conn, responseCode);
                        String responseMessage = conn.getResponseMessage();

                        Log.d(TAG, "Emergency endCall API response:"
                                + " code=" + responseCode
                                + ", message=" + responseMessage
                                + ", body=" + responseBody);

                    } catch (Exception e) {
                        Log.e(TAG, "Failed executing native fallback endCall endpoint", e);
                    }
                }
            });
            
            thread.start();
            
            try {
                // Keep main execution process alive up to 1.5s to guarantee delivery to your backend
                thread.join(1500); 
            } catch (InterruptedException e) {
                Log.e(TAG, "Thread join error", e);
            }
        } else {
            Log.w(TAG, "Skipping endCall request: missing channel_id, jwt_token, or end_call_url");
        }

        stopSelf();
    }

    private String readResponseBody(HttpURLConnection conn, int responseCode) {
        StringBuilder body = new StringBuilder();
        try {
            InputStream stream = responseCode >= 400 ? conn.getErrorStream() : conn.getInputStream();
            if (stream == null) {
                return "";
            }

            try (BufferedReader reader = new BufferedReader(new InputStreamReader(stream, "UTF-8"))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    body.append(line);
                }
            }
        } catch (IOException e) {
            Log.e(TAG, "Failed to read API response body", e);
        }
        return body.toString();
    }
}
