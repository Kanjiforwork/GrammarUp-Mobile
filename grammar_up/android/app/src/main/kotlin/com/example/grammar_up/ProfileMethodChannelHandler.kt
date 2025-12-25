package com.example.grammar_up

import android.content.Context
import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import okhttp3.*
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.RequestBody.Companion.asRequestBody
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject
import java.io.File
import java.io.IOException

class ProfileMethodChannelHandler(private val context: Context) : MethodChannel.MethodCallHandler {
    companion object {
        private const val TAG = "ProfileMethodChannel"
        private const val CHANNEL_NAME = "com.example.grammar_up/profile"
    }

    private var supabaseUrl: String? = null
    private var supabaseAnonKey: String? = null
    private var accessToken: String? = null
    private val client = OkHttpClient()
    private val coroutineScope = CoroutineScope(Dispatchers.Main)

    fun registerChannel(binaryMessenger: io.flutter.plugin.common.BinaryMessenger) {
        val channel = MethodChannel(binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initializeSupabase" -> initializeSupabase(call, result)
            "getProfile" -> getProfile(call, result)
            "updateProfile" -> updateProfile(call, result)
            "uploadProfilePicture" -> uploadProfilePicture(call, result)
            else -> result.notImplemented()
        }
    }

    private fun initializeSupabase(call: MethodCall, result: MethodChannel.Result) {
        try {
            supabaseUrl = call.argument<String>("supabaseUrl")
            supabaseAnonKey = call.argument<String>("supabaseAnonKey")
            accessToken = call.argument<String>("accessToken")

            if (supabaseUrl.isNullOrEmpty() || supabaseAnonKey.isNullOrEmpty()) {
                result.error("INVALID_ARGS", "Supabase URL and Anon Key are required", null)
                return
            }

            Log.d(TAG, "Supabase initialized successfully")
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Error initializing Supabase: ${e.message}", e)
            result.error("INIT_ERROR", "Failed to initialize: ${e.message}", null)
        }
    }

    private fun getProfile(call: MethodCall, result: MethodChannel.Result) {
        coroutineScope.launch {
            try {
                val userId = call.argument<String>("userId")
                if (userId.isNullOrEmpty()) {
                    result.error("INVALID_ARGS", "User ID is required", null)
                    return@launch
                }

                if (supabaseUrl.isNullOrEmpty() || supabaseAnonKey.isNullOrEmpty()) {
                    result.error("NOT_INITIALIZED", "Supabase not initialized", null)
                    return@launch
                }

                // Make REST API call to get profile
                val response = withContext(Dispatchers.IO) {
                    val request = Request.Builder()
                        .url("$supabaseUrl/rest/v1/users?id=eq.$userId&select=*")
                        .addHeader("apikey", supabaseAnonKey!!)
                        .addHeader("Authorization", "Bearer ${accessToken ?: supabaseAnonKey}")
                        .get()
                        .build()

                    client.newCall(request).execute()
                }

                if (response.isSuccessful) {
                    val body = response.body?.string()
                    val jsonArray = org.json.JSONArray(body)
                    
                    if (jsonArray.length() > 0) {
                        val profileJson = jsonArray.getJSONObject(0)
                        val profileMap = hashMapOf<String, Any?>()
                        
                        profileMap["id"] = profileJson.getString("id")
                        profileMap["email"] = profileJson.getString("email")
                        profileMap["full_name"] = if (profileJson.isNull("full_name")) null else profileJson.getString("full_name")
                        profileMap["avatar_url"] = if (profileJson.isNull("avatar_url")) null else profileJson.getString("avatar_url")
                        profileMap["native_language"] = if (profileJson.isNull("native_language")) null else profileJson.getString("native_language")
                        profileMap["level"] = if (profileJson.isNull("level")) null else profileJson.getString("level")
                        profileMap["learning_streak"] = if (profileJson.isNull("learning_streak")) null else profileJson.getInt("learning_streak")
                        profileMap["total_points"] = if (profileJson.isNull("total_points")) null else profileJson.getInt("total_points")
                        profileMap["created_at"] = if (profileJson.isNull("created_at")) null else profileJson.getString("created_at")
                        profileMap["updated_at"] = if (profileJson.isNull("updated_at")) null else profileJson.getString("updated_at")
                        
                        Log.d(TAG, "Profile fetched successfully")
                        result.success(profileMap)
                    } else {
                        result.error("NOT_FOUND", "Profile not found", null)
                    }
                } else {
                    result.error("FETCH_ERROR", "Failed to fetch profile: ${response.code}", null)
                }
                response.close()
            } catch (e: Exception) {
                Log.e(TAG, "Error fetching profile: ${e.message}", e)
                result.error("FETCH_ERROR", "Failed to fetch profile: ${e.message}", null)
            }
        }
    }

    private fun updateProfile(call: MethodCall, result: MethodChannel.Result) {
        coroutineScope.launch {
            try {
                val userId = call.argument<String>("userId")
                val fullName = call.argument<String>("full_name")
                val email = call.argument<String>("email")
                val avatarUrl = call.argument<String>("avatar_url")

                if (userId.isNullOrEmpty()) {
                    result.error("INVALID_ARGS", "User ID is required", null)
                    return@launch
                }

                if (supabaseUrl.isNullOrEmpty() || supabaseAnonKey.isNullOrEmpty()) {
                    result.error("NOT_INITIALIZED", "Supabase not initialized", null)
                    return@launch
                }

                // Build JSON body
                val updateJson = JSONObject()
                fullName?.let { updateJson.put("full_name", it) }
                email?.let { updateJson.put("email", it) }
                avatarUrl?.let { updateJson.put("avatar_url", it) }
                updateJson.put("updated_at", java.time.Instant.now().toString())

                val jsonBody = updateJson.toString()
                    .toRequestBody("application/json".toMediaType())

                // Make REST API call to update profile
                val response = withContext(Dispatchers.IO) {
                    val request = Request.Builder()
                        .url("$supabaseUrl/rest/v1/users?id=eq.$userId")
                        .addHeader("apikey", supabaseAnonKey!!)
                        .addHeader("Authorization", "Bearer ${accessToken ?: supabaseAnonKey}")
                        .addHeader("Content-Type", "application/json")
                        .addHeader("Prefer", "return=minimal")
                        .patch(jsonBody)
                        .build()

                    client.newCall(request).execute()
                }

                if (response.isSuccessful) {
                    Log.d(TAG, "Profile updated successfully")
                    result.success(true)
                } else {
                    result.error("UPDATE_ERROR", "Failed to update profile: ${response.code}", null)
                }
                response.close()
            } catch (e: Exception) {
                Log.e(TAG, "Error updating profile: ${e.message}", e)
                result.error("UPDATE_ERROR", "Failed to update profile: ${e.message}", null)
            }
        }
    }

    private fun uploadProfilePicture(call: MethodCall, result: MethodChannel.Result) {
        coroutineScope.launch {
            try {
                val userId = call.argument<String>("userId")
                val filePath = call.argument<String>("filePath")

                if (userId.isNullOrEmpty() || filePath.isNullOrEmpty()) {
                    result.error("INVALID_ARGS", "User ID and file path are required", null)
                    return@launch
                }

                if (supabaseUrl.isNullOrEmpty() || supabaseAnonKey.isNullOrEmpty()) {
                    result.error("NOT_INITIALIZED", "Supabase not initialized", null)
                    return@launch
                }

                val file = File(filePath)
                if (!file.exists()) {
                    result.error("FILE_NOT_FOUND", "File not found at path: $filePath", null)
                    return@launch
                }

                // Generate unique filename
                val fileExtension = file.extension
                val uniqueFileName = "${userId}_${System.currentTimeMillis()}.$fileExtension"
                val storagePath = "avatars/$uniqueFileName"

                // Determine content type
                val contentType = when (fileExtension.lowercase()) {
                    "jpg", "jpeg" -> "image/jpeg"
                    "png" -> "image/png"
                    "gif" -> "image/gif"
                    else -> "application/octet-stream"
                }

                // Upload to Supabase Storage
                val uploadResponse = withContext(Dispatchers.IO) {
                    val requestBody = file.asRequestBody(contentType.toMediaType())
                    
                    val request = Request.Builder()
                        .url("$supabaseUrl/storage/v1/object/user-avatars/$storagePath")
                        .addHeader("apikey", supabaseAnonKey!!)
                        .addHeader("Authorization", "Bearer ${accessToken ?: supabaseAnonKey}")
                        .addHeader("Content-Type", contentType)
                        .post(requestBody)
                        .build()

                    client.newCall(request).execute()
                }

                if (uploadResponse.isSuccessful) {
                    // Generate public URL
                    val publicUrl = "$supabaseUrl/storage/v1/object/public/user-avatars/$storagePath"
                    
                    // Update user profile with new avatar URL
                    val updateJson = JSONObject()
                    updateJson.put("avatar_url", publicUrl)
                    updateJson.put("updated_at", java.time.Instant.now().toString())

                    val jsonBody = updateJson.toString()
                        .toRequestBody("application/json".toMediaType())

                    val updateResponse = withContext(Dispatchers.IO) {
                        val request = Request.Builder()
                            .url("$supabaseUrl/rest/v1/users?id=eq.$userId")
                            .addHeader("apikey", supabaseAnonKey!!)
                            .addHeader("Authorization", "Bearer ${accessToken ?: supabaseAnonKey}")
                            .addHeader("Content-Type", "application/json")
                            .addHeader("Prefer", "return=minimal")
                            .patch(jsonBody)
                            .build()

                        client.newCall(request).execute()
                    }

                    if (updateResponse.isSuccessful) {
                        Log.d(TAG, "Profile picture uploaded successfully: $publicUrl")
                        result.success(publicUrl)
                    } else {
                        result.error("UPDATE_ERROR", "Upload succeeded but profile update failed", null)
                    }
                    updateResponse.close()
                } else {
                    val errorBody = uploadResponse.body?.string()
                    Log.e(TAG, "Upload failed: ${uploadResponse.code} - $errorBody")
                    result.error("UPLOAD_ERROR", "Failed to upload: ${uploadResponse.code}", null)
                }
                uploadResponse.close()
            } catch (e: Exception) {
                Log.e(TAG, "Error uploading profile picture: ${e.message}", e)
                result.error("UPLOAD_ERROR", "Failed to upload: ${e.message}", null)
            }
        }
    }
}
