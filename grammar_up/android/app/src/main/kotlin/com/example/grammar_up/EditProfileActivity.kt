package com.example.grammar_up

import android.Manifest
import android.app.Activity
import android.content.pm.PackageManager
import android.content.res.Configuration
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.view.View
import android.widget.*
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONArray
import org.json.JSONObject
import java.io.ByteArrayOutputStream
import java.util.Locale
import java.util.concurrent.TimeUnit

class EditProfileActivity : AppCompatActivity() {

    private val client = OkHttpClient.Builder()
        .connectTimeout(30, TimeUnit.SECONDS)
        .readTimeout(30, TimeUnit.SECONDS)
        .writeTimeout(30, TimeUnit.SECONDS)
        .build()

    // Views
    private lateinit var rootLayout: ScrollView
    private lateinit var headerLayout: LinearLayout
    private lateinit var ivAvatar: ImageView
    private lateinit var btnChangePhoto: ImageView
    private lateinit var etFullName: EditText
    private lateinit var etEmail: EditText
    private lateinit var tvStreak: TextView
    private lateinit var tvPoints: TextView
    private lateinit var tvLevel: TextView
    private lateinit var tvLanguage: TextView
    private lateinit var btnSave: Button
    private lateinit var btnCancel: Button
    private lateinit var progressBar: ProgressBar
    private lateinit var contentLayout: LinearLayout
    private lateinit var statsCard: LinearLayout

    // Labels
    private lateinit var tvFullNameLabel: TextView
    private lateinit var tvEmailLabel: TextView
    private lateinit var tvStatsLabel: TextView
    private lateinit var tvStreakLabel: TextView
    private lateinit var tvPointsLabel: TextView
    private lateinit var tvLevelLabel: TextView
    private lateinit var tvLanguageLabel: TextView

    // Data
    private var userId: String = ""
    private var accessToken: String = ""
    private var isDarkMode = false
    private var languageCode = "en"
    private var currentAvatarUrl: String? = null
    private var selectedImageUri: Uri? = null
    private var selectedImageBitmap: Bitmap? = null

    // Supabase configuration
    private val supabaseUrl = "https://rrusvgwfkkiwlwuvrbmd.supabase.co"
    private val supabaseKey = "sb_publishable_zB9I5wsydI5NvpxyaAHrnQ_-ljP4lZ-"

    // Image picker launchers
    private val galleryLauncher = registerForActivityResult(ActivityResultContracts.GetContent()) { uri ->
        uri?.let {
            selectedImageUri = it
            loadSelectedImage(it)
        }
    }

    private val cameraLauncher = registerForActivityResult(ActivityResultContracts.TakePicturePreview()) { bitmap ->
        bitmap?.let {
            selectedImageBitmap = it
            selectedImageUri = null
            ivAvatar.setImageBitmap(it)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Get user info from intent BEFORE setContentView
        userId = intent.getStringExtra("userId") ?: ""
        accessToken = intent.getStringExtra("accessToken") ?: ""
        isDarkMode = intent.getBooleanExtra("isDarkMode", false)
        languageCode = intent.getStringExtra("languageCode") ?: "en"

        // Apply locale BEFORE setContentView so layout uses correct strings
        applyLocale()

        setContentView(R.layout.activity_edit_profile)

        initViews()
        applyTheme()
        setupListeners()

        if (userId.isNotEmpty() && accessToken.isNotEmpty()) {
            loadProfile()
        } else {
            showError(getString(R.string.user_not_authenticated))
            finish()
        }
    }

    private fun applyLocale() {
        val locale = Locale(languageCode)
        Locale.setDefault(locale)
        val config = Configuration(resources.configuration)
        config.setLocale(locale)
        resources.updateConfiguration(config, resources.displayMetrics)
    }

    private fun initViews() {
        rootLayout = findViewById(R.id.rootLayout)
        headerLayout = findViewById(R.id.headerLayout)
        ivAvatar = findViewById(R.id.ivAvatar)
        btnChangePhoto = findViewById(R.id.btnChangePhoto)
        etFullName = findViewById(R.id.etFullName)
        etEmail = findViewById(R.id.etEmail)
        tvStreak = findViewById(R.id.tvStreak)
        tvPoints = findViewById(R.id.tvPoints)
        tvLevel = findViewById(R.id.tvLevel)
        tvLanguage = findViewById(R.id.tvLanguage)
        btnSave = findViewById(R.id.btnSave)
        btnCancel = findViewById(R.id.btnCancel)
        progressBar = findViewById(R.id.progressBar)
        contentLayout = findViewById(R.id.contentLayout)
        statsCard = findViewById(R.id.statsCard)

        tvFullNameLabel = findViewById(R.id.tvFullNameLabel)
        tvEmailLabel = findViewById(R.id.tvEmailLabel)
        tvStatsLabel = findViewById(R.id.tvStatsLabel)
        tvStreakLabel = findViewById(R.id.tvStreakLabel)
        tvPointsLabel = findViewById(R.id.tvPointsLabel)
        tvLevelLabel = findViewById(R.id.tvLevelLabel)
        tvLanguageLabel = findViewById(R.id.tvLanguageLabel)

        findViewById<ImageView>(R.id.btnBack).setOnClickListener {
            finish()
        }
    }

    private fun applyTheme() {
        if (isDarkMode) {
            // Dark mode colors
            val darkBg = ContextCompat.getColor(this, R.color.darkBackground)
            val darkSurface = ContextCompat.getColor(this, R.color.darkSurface)
            val darkTextPrimary = ContextCompat.getColor(this, R.color.darkTextPrimary)
            val darkTextSecondary = ContextCompat.getColor(this, R.color.darkTextSecondary)
            val darkTextTertiary = ContextCompat.getColor(this, R.color.darkTextTertiary)

            window.statusBarColor = darkBg
            rootLayout.setBackgroundColor(darkBg)
            headerLayout.setBackgroundColor(darkSurface)
            contentLayout.setBackgroundColor(darkBg)

            // Labels
            tvFullNameLabel.setTextColor(darkTextSecondary)
            tvEmailLabel.setTextColor(darkTextSecondary)
            tvStatsLabel.setTextColor(darkTextTertiary)
            tvStreakLabel.setTextColor(darkTextTertiary)
            tvPointsLabel.setTextColor(darkTextTertiary)
            tvLevelLabel.setTextColor(darkTextTertiary)
            tvLanguageLabel.setTextColor(darkTextTertiary)

            // Values
            tvStreak.setTextColor(darkTextPrimary)
            tvPoints.setTextColor(darkTextPrimary)
            tvLevel.setTextColor(darkTextPrimary)
            tvLanguage.setTextColor(darkTextPrimary)

            // EditTexts
            etFullName.setTextColor(darkTextPrimary)
            etFullName.setHintTextColor(darkTextTertiary)
            etFullName.setBackgroundResource(R.drawable.edittext_background_dark)

            etEmail.setTextColor(darkTextPrimary)
            etEmail.setHintTextColor(darkTextTertiary)
            etEmail.setBackgroundResource(R.drawable.edittext_background_dark)

            // Stats card
            statsCard.setBackgroundResource(R.drawable.card_background_dark)

            // Cancel button
            btnCancel.setTextColor(ContextCompat.getColor(this, R.color.darkTeal))
        } else {
            // Light mode colors
            val lightBg = ContextCompat.getColor(this, R.color.gray50)
            val lightSurface = ContextCompat.getColor(this, R.color.white)
            val lightTextPrimary = ContextCompat.getColor(this, R.color.gray900)
            val lightTextSecondary = ContextCompat.getColor(this, R.color.gray600)
            val lightTextTertiary = ContextCompat.getColor(this, R.color.gray500)

            window.statusBarColor = lightBg
            rootLayout.setBackgroundColor(lightBg)
            headerLayout.setBackgroundColor(lightSurface)
            contentLayout.setBackgroundColor(lightBg)

            // Labels
            tvFullNameLabel.setTextColor(lightTextSecondary)
            tvEmailLabel.setTextColor(lightTextSecondary)
            tvStatsLabel.setTextColor(lightTextTertiary)
            tvStreakLabel.setTextColor(lightTextTertiary)
            tvPointsLabel.setTextColor(lightTextTertiary)
            tvLevelLabel.setTextColor(lightTextTertiary)
            tvLanguageLabel.setTextColor(lightTextTertiary)

            // Values
            tvStreak.setTextColor(lightTextPrimary)
            tvPoints.setTextColor(lightTextPrimary)
            tvLevel.setTextColor(lightTextPrimary)
            tvLanguage.setTextColor(lightTextPrimary)

            // EditTexts
            etFullName.setTextColor(lightTextPrimary)
            etFullName.setHintTextColor(ContextCompat.getColor(this, R.color.gray400))
            etFullName.setBackgroundResource(R.drawable.edittext_background)

            etEmail.setTextColor(lightTextPrimary)
            etEmail.setHintTextColor(ContextCompat.getColor(this, R.color.gray400))
            etEmail.setBackgroundResource(R.drawable.edittext_background)

            // Stats card
            statsCard.setBackgroundResource(R.drawable.card_background)

            // Cancel button
            btnCancel.setTextColor(ContextCompat.getColor(this, R.color.primary))
        }
    }

    private fun setupListeners() {
        btnChangePhoto.setOnClickListener {
            showImageSourceDialog()
        }

        ivAvatar.setOnClickListener {
            showImageSourceDialog()
        }

        btnSave.setOnClickListener {
            saveProfile()
        }

        btnCancel.setOnClickListener {
            finish()
        }
    }

    private fun loadProfile() {
        showLoading(true)

        CoroutineScope(Dispatchers.IO).launch {
            try {
                val request = Request.Builder()
                    .url("$supabaseUrl/rest/v1/users?id=eq.$userId&select=*")
                    .addHeader("apikey", supabaseKey)
                    .addHeader("Authorization", "Bearer $accessToken")
                    .build()

                val response = client.newCall(request).execute()
                val responseBody = response.body?.string() ?: "[]"
                val users = JSONArray(responseBody)

                if (users.length() > 0) {
                    val user = users.getJSONObject(0)

                    withContext(Dispatchers.Main) {
                        showLoading(false)
                        populateProfile(user)
                    }
                } else {
                    withContext(Dispatchers.Main) {
                        showLoading(false)
                        showError(getString(R.string.user_not_found))
                    }
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    showLoading(false)
                    showError("${getString(R.string.failed_to_load_profile)}: ${e.message}")
                }
            }
        }
    }

    private fun populateProfile(user: JSONObject) {
        etFullName.setText(user.optString("full_name", ""))
        etEmail.setText(user.optString("email", ""))

        val streak = user.optInt("learning_streak", 0)
        tvStreak.text = getString(R.string.days_format, streak)
        tvPoints.text = user.optInt("total_points", 0).toString()
        tvLevel.text = user.optString("level", "beginner").replaceFirstChar { it.uppercase() }
        tvLanguage.text = user.optString("native_language", "vi").uppercase()

        currentAvatarUrl = user.optString("avatar_url", null)
        if (!currentAvatarUrl.isNullOrEmpty()) {
            loadAvatarImage(currentAvatarUrl!!)
        }
    }

    private fun loadAvatarImage(url: String) {
        CoroutineScope(Dispatchers.IO).launch {
            try {
                val request = Request.Builder().url(url).build()
                val response = client.newCall(request).execute()
                val inputStream = response.body?.byteStream()
                val bitmap = BitmapFactory.decodeStream(inputStream)

                withContext(Dispatchers.Main) {
                    ivAvatar.setImageBitmap(bitmap)
                }
            } catch (e: Exception) {
                // Keep default avatar
            }
        }
    }

    private fun loadSelectedImage(uri: Uri) {
        try {
            val inputStream = contentResolver.openInputStream(uri)
            val bitmap = BitmapFactory.decodeStream(inputStream)
            selectedImageBitmap = bitmap
            ivAvatar.setImageBitmap(bitmap)
        } catch (e: Exception) {
            showError("Failed to load image")
        }
    }

    private fun showImageSourceDialog() {
        val options = arrayOf(getString(R.string.choose_from_gallery), getString(R.string.take_photo))
        val dialogStyle = if (isDarkMode) R.style.AlertDialogThemeDark else R.style.AlertDialogTheme

        AlertDialog.Builder(this, dialogStyle)
            .setTitle(getString(R.string.change_profile_photo))
            .setItems(options) { _, which ->
                when (which) {
                    0 -> openGallery()
                    1 -> openCamera()
                }
            }
            .show()
    }

    private fun openGallery() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_MEDIA_IMAGES)
                != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(this,
                    arrayOf(Manifest.permission.READ_MEDIA_IMAGES), PERMISSION_GALLERY)
                return
            }
        } else {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE)
                != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(this,
                    arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE), PERMISSION_GALLERY)
                return
            }
        }
        galleryLauncher.launch("image/*")
    }

    private fun openCamera() {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA)
            != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this,
                arrayOf(Manifest.permission.CAMERA), PERMISSION_CAMERA)
            return
        }
        cameraLauncher.launch(null)
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            when (requestCode) {
                PERMISSION_GALLERY -> galleryLauncher.launch("image/*")
                PERMISSION_CAMERA -> cameraLauncher.launch(null)
            }
        }
    }

    private fun saveProfile() {
        val fullName = etFullName.text.toString().trim()
        val email = etEmail.text.toString().trim()

        // Validation
        if (fullName.isEmpty()) {
            etFullName.error = getString(R.string.please_enter_full_name)
            return
        }
        if (email.isEmpty() || !android.util.Patterns.EMAIL_ADDRESS.matcher(email).matches()) {
            etEmail.error = getString(R.string.please_enter_valid_email)
            return
        }

        showLoading(true)
        btnSave.isEnabled = false

        CoroutineScope(Dispatchers.IO).launch {
            try {
                var newAvatarUrl = currentAvatarUrl

                // Upload new avatar if selected
                if (selectedImageBitmap != null) {
                    newAvatarUrl = uploadAvatar(selectedImageBitmap!!)
                }

                // Update profile
                val updateJson = JSONObject().apply {
                    put("full_name", fullName)
                    put("email", email)
                    if (newAvatarUrl != null) {
                        put("avatar_url", newAvatarUrl)
                    }
                    put("updated_at", java.time.Instant.now().toString())
                }

                val request = Request.Builder()
                    .url("$supabaseUrl/rest/v1/users?id=eq.$userId")
                    .addHeader("apikey", supabaseKey)
                    .addHeader("Authorization", "Bearer $accessToken")
                    .addHeader("Content-Type", "application/json")
                    .addHeader("Prefer", "return=minimal")
                    .patch(updateJson.toString().toRequestBody("application/json".toMediaType()))
                    .build()

                val response = client.newCall(request).execute()

                withContext(Dispatchers.Main) {
                    showLoading(false)
                    btnSave.isEnabled = true

                    if (response.isSuccessful) {
                        Toast.makeText(this@EditProfileActivity, getString(R.string.profile_updated), Toast.LENGTH_SHORT).show()
                        setResult(Activity.RESULT_OK)
                        finish()
                    } else {
                        showError(getString(R.string.failed_to_update_profile))
                    }
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    showLoading(false)
                    btnSave.isEnabled = true
                    showError("${getString(R.string.failed_to_update_profile)}: ${e.message}")
                }
            }
        }
    }

    private suspend fun uploadAvatar(bitmap: Bitmap): String? {
        return try {
            // Compress bitmap
            val outputStream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.JPEG, 85, outputStream)
            val imageBytes = outputStream.toByteArray()

            val fileName = "${userId}_${System.currentTimeMillis()}.jpg"
            val filePath = "avatars/$fileName"

            // Upload to Supabase Storage
            val request = Request.Builder()
                .url("$supabaseUrl/storage/v1/object/user-avatars/$filePath")
                .addHeader("apikey", supabaseKey)
                .addHeader("Authorization", "Bearer $accessToken")
                .addHeader("Content-Type", "image/jpeg")
                .post(imageBytes.toRequestBody("image/jpeg".toMediaType()))
                .build()

            val response = client.newCall(request).execute()

            if (response.isSuccessful) {
                "$supabaseUrl/storage/v1/object/public/user-avatars/$filePath"
            } else {
                null
            }
        } catch (e: Exception) {
            null
        }
    }

    private fun showLoading(show: Boolean) {
        progressBar.visibility = if (show) View.VISIBLE else View.GONE
        contentLayout.visibility = if (show) View.GONE else View.VISIBLE
    }

    private fun showError(message: String) {
        Toast.makeText(this, message, Toast.LENGTH_LONG).show()
    }

    companion object {
        private const val PERMISSION_GALLERY = 100
        private const val PERMISSION_CAMERA = 101
    }
}
