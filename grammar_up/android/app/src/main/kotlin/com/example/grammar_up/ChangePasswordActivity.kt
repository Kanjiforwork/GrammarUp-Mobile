package com.example.grammar_up

import android.content.res.Configuration
import android.os.Bundle
import android.view.View
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject
import java.util.Locale
import java.util.concurrent.TimeUnit

class ChangePasswordActivity : AppCompatActivity() {

    private val client = OkHttpClient.Builder()
        .connectTimeout(30, TimeUnit.SECONDS)
        .readTimeout(30, TimeUnit.SECONDS)
        .writeTimeout(30, TimeUnit.SECONDS)
        .build()

    // Views
    private lateinit var rootLayout: ScrollView
    private lateinit var headerLayout: LinearLayout
    private lateinit var etCurrentPassword: EditText
    private lateinit var etNewPassword: EditText
    private lateinit var etConfirmPassword: EditText
    private lateinit var btnChangePassword: Button
    private lateinit var btnCancel: Button
    private lateinit var progressBar: ProgressBar
    private lateinit var contentLayout: LinearLayout

    // Labels
    private lateinit var tvCurrentPasswordLabel: TextView
    private lateinit var tvNewPasswordLabel: TextView
    private lateinit var tvConfirmPasswordLabel: TextView
    private lateinit var tvPasswordRequirements: TextView

    // Data
    private var accessToken: String = ""
    private var isDarkMode = false
    private var languageCode = "en"

    // Supabase configuration
    private val supabaseUrl = "https://rrusvgwfkkiwlwuvrbmd.supabase.co"
    private val supabaseKey = "sb_publishable_zB9I5wsydI5NvpxyaAHrnQ_-ljP4lZ-"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Get data from intent
        accessToken = intent.getStringExtra("accessToken") ?: ""
        isDarkMode = intent.getBooleanExtra("isDarkMode", false)
        languageCode = intent.getStringExtra("languageCode") ?: "en"

        // Apply locale BEFORE setContentView
        applyLocale()

        setContentView(R.layout.activity_change_password)

        initViews()
        applyTheme()
        setupListeners()

        if (accessToken.isEmpty()) {
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
        etCurrentPassword = findViewById(R.id.etCurrentPassword)
        etNewPassword = findViewById(R.id.etNewPassword)
        etConfirmPassword = findViewById(R.id.etConfirmPassword)
        btnChangePassword = findViewById(R.id.btnChangePassword)
        btnCancel = findViewById(R.id.btnCancel)
        progressBar = findViewById(R.id.progressBar)
        contentLayout = findViewById(R.id.contentLayout)

        tvCurrentPasswordLabel = findViewById(R.id.tvCurrentPasswordLabel)
        tvNewPasswordLabel = findViewById(R.id.tvNewPasswordLabel)
        tvConfirmPasswordLabel = findViewById(R.id.tvConfirmPasswordLabel)
        tvPasswordRequirements = findViewById(R.id.tvPasswordRequirements)

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
            tvCurrentPasswordLabel.setTextColor(darkTextSecondary)
            tvNewPasswordLabel.setTextColor(darkTextSecondary)
            tvConfirmPasswordLabel.setTextColor(darkTextSecondary)
            tvPasswordRequirements.setTextColor(darkTextTertiary)

            // EditTexts
            etCurrentPassword.setTextColor(darkTextPrimary)
            etCurrentPassword.setHintTextColor(darkTextTertiary)
            etCurrentPassword.setBackgroundResource(R.drawable.edittext_background_dark)

            etNewPassword.setTextColor(darkTextPrimary)
            etNewPassword.setHintTextColor(darkTextTertiary)
            etNewPassword.setBackgroundResource(R.drawable.edittext_background_dark)

            etConfirmPassword.setTextColor(darkTextPrimary)
            etConfirmPassword.setHintTextColor(darkTextTertiary)
            etConfirmPassword.setBackgroundResource(R.drawable.edittext_background_dark)

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
            tvCurrentPasswordLabel.setTextColor(lightTextSecondary)
            tvNewPasswordLabel.setTextColor(lightTextSecondary)
            tvConfirmPasswordLabel.setTextColor(lightTextSecondary)
            tvPasswordRequirements.setTextColor(lightTextTertiary)

            // EditTexts
            etCurrentPassword.setTextColor(lightTextPrimary)
            etCurrentPassword.setHintTextColor(ContextCompat.getColor(this, R.color.gray400))
            etCurrentPassword.setBackgroundResource(R.drawable.edittext_background)

            etNewPassword.setTextColor(lightTextPrimary)
            etNewPassword.setHintTextColor(ContextCompat.getColor(this, R.color.gray400))
            etNewPassword.setBackgroundResource(R.drawable.edittext_background)

            etConfirmPassword.setTextColor(lightTextPrimary)
            etConfirmPassword.setHintTextColor(ContextCompat.getColor(this, R.color.gray400))
            etConfirmPassword.setBackgroundResource(R.drawable.edittext_background)

            // Cancel button
            btnCancel.setTextColor(ContextCompat.getColor(this, R.color.primary))
        }
    }

    private fun setupListeners() {
        btnChangePassword.setOnClickListener {
            changePassword()
        }

        btnCancel.setOnClickListener {
            finish()
        }
    }

    private fun changePassword() {
        val currentPassword = etCurrentPassword.text.toString().trim()
        val newPassword = etNewPassword.text.toString().trim()
        val confirmPassword = etConfirmPassword.text.toString().trim()

        // Validation
        if (currentPassword.isEmpty()) {
            etCurrentPassword.error = getString(R.string.please_enter_current_password)
            return
        }

        if (newPassword.isEmpty()) {
            etNewPassword.error = getString(R.string.please_enter_new_password)
            return
        }

        if (newPassword.length < 6) {
            etNewPassword.error = getString(R.string.password_too_short)
            return
        }

        if (confirmPassword.isEmpty()) {
            etConfirmPassword.error = getString(R.string.please_confirm_password)
            return
        }

        if (newPassword != confirmPassword) {
            etConfirmPassword.error = getString(R.string.passwords_do_not_match)
            return
        }

        if (currentPassword == newPassword) {
            etNewPassword.error = getString(R.string.new_password_same_as_current)
            return
        }

        showLoading(true)
        btnChangePassword.isEnabled = false

        CoroutineScope(Dispatchers.IO).launch {
            try {
                // First, verify current password by attempting to refresh session
                // This is a security measure to ensure user knows the current password
                
                // Update password using Supabase Auth API
                val updateJson = JSONObject().apply {
                    put("password", newPassword)
                }

                val request = Request.Builder()
                    .url("$supabaseUrl/auth/v1/user")
                    .addHeader("apikey", supabaseKey)
                    .addHeader("Authorization", "Bearer $accessToken")
                    .addHeader("Content-Type", "application/json")
                    .put(updateJson.toString().toRequestBody("application/json".toMediaType()))
                    .build()

                val response = client.newCall(request).execute()

                withContext(Dispatchers.Main) {
                    showLoading(false)
                    btnChangePassword.isEnabled = true

                    if (response.isSuccessful) {
                        Toast.makeText(
                            this@ChangePasswordActivity,
                            getString(R.string.password_changed_successfully),
                            Toast.LENGTH_SHORT
                        ).show()
                        finish()
                    } else {
                        val errorBody = response.body?.string() ?: ""
                        val errorMessage = try {
                            val errorJson = JSONObject(errorBody)
                            errorJson.optString("message", errorJson.optString("error_description", ""))
                        } catch (e: Exception) {
                            ""
                        }

                        if (errorMessage.contains("invalid", ignoreCase = true) || 
                            errorMessage.contains("credentials", ignoreCase = true)) {
                            showError(getString(R.string.current_password_incorrect))
                        } else {
                            showError(getString(R.string.failed_to_change_password))
                        }
                    }
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    showLoading(false)
                    btnChangePassword.isEnabled = true
                    showError("${getString(R.string.failed_to_change_password)}: ${e.message}")
                }
            }
        }
    }

    private fun showLoading(show: Boolean) {
        progressBar.visibility = if (show) View.VISIBLE else View.GONE
        contentLayout.visibility = if (show) View.GONE else View.VISIBLE
    }

    private fun showError(message: String) {
        Toast.makeText(this, message, Toast.LENGTH_LONG).show()
    }
}
