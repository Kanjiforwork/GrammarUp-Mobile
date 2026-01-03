package com.example.grammar_up

import android.content.res.Configuration
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.ProgressBar
import android.widget.ScrollView
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import okhttp3.OkHttpClient
import okhttp3.Request
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Locale
import java.util.concurrent.TimeUnit

class LearningHistoryActivity : AppCompatActivity() {

    private val client = OkHttpClient.Builder()
        .connectTimeout(30, TimeUnit.SECONDS)
        .readTimeout(30, TimeUnit.SECONDS)
        .writeTimeout(30, TimeUnit.SECONDS)
        .build()

    private lateinit var historyContainer: LinearLayout
    private lateinit var progressBar: ProgressBar
    private lateinit var tvExerciseCount: TextView
    private lateinit var tvLessonCount: TextView
    private lateinit var tabExercises: TextView
    private lateinit var tabLessons: TextView
    private lateinit var emptyState: LinearLayout
    private lateinit var tvEmptyTitle: TextView
    private lateinit var tvEmptySubtitle: TextView
    private lateinit var rootLayout: LinearLayout
    private lateinit var tabLayout: LinearLayout
    private lateinit var scrollView: ScrollView

    private var isDarkMode = false
    private var languageCode = "en"
    private var currentTab = "exercises" // "exercises" or "lessons"

    private var exerciseAttempts: JSONArray = JSONArray()
    private var lessonProgress: JSONArray = JSONArray()
    private var exercisesMap: MutableMap<String, JSONObject> = mutableMapOf()
    private var lessonsMap: MutableMap<String, JSONObject> = mutableMapOf()

    // Supabase configuration
    private val supabaseUrl = "https://rrusvgwfkkiwlwuvrbmd.supabase.co"
    private val supabaseKey = "sb_publishable_zB9I5wsydI5NvpxyaAHrnQ_-ljP4lZ-"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Get user info from intent BEFORE setContentView
        val userId = intent.getStringExtra("userId") ?: ""
        val accessToken = intent.getStringExtra("accessToken") ?: ""
        isDarkMode = intent.getBooleanExtra("isDarkMode", false)
        languageCode = intent.getStringExtra("languageCode") ?: "en"

        // Apply locale BEFORE setContentView so layout uses correct strings
        applyLocale()

        setContentView(R.layout.activity_learning_history)

        // Initialize views
        rootLayout = findViewById(R.id.rootLayout)
        tabLayout = findViewById(R.id.tabLayout)
        scrollView = findViewById(R.id.scrollView)
        historyContainer = findViewById(R.id.historyContainer)
        progressBar = findViewById(R.id.progressBar)
        tvExerciseCount = findViewById(R.id.tvExerciseCount)
        tvLessonCount = findViewById(R.id.tvLessonCount)
        tabExercises = findViewById(R.id.tabExercises)
        tabLessons = findViewById(R.id.tabLessons)
        emptyState = findViewById(R.id.emptyState)
        tvEmptyTitle = findViewById(R.id.tvEmptyTitle)
        tvEmptySubtitle = findViewById(R.id.tvEmptySubtitle)

        // Apply dark mode
        applyTheme()

        // Setup back button
        findViewById<ImageView>(R.id.btnBack).setOnClickListener {
            finish()
        }

        // Setup tab buttons
        tabExercises.setOnClickListener {
            if (currentTab != "exercises") {
                currentTab = "exercises"
                updateTabUI()
                displayExerciseHistory()
            }
        }

        tabLessons.setOnClickListener {
            if (currentTab != "lessons") {
                currentTab = "lessons"
                updateTabUI()
                displayLessonHistory()
            }
        }

        // Load history
        if (userId.isNotEmpty() && accessToken.isNotEmpty()) {
            loadHistory(userId, accessToken)
        } else {
            showError(getString(R.string.please_login_history))
        }
    }

    private fun applyLocale() {
        val locale = Locale(languageCode)
        Locale.setDefault(locale)
        val config = Configuration(resources.configuration)
        config.setLocale(locale)
        resources.updateConfiguration(config, resources.displayMetrics)
    }

    private fun applyTheme() {
        if (isDarkMode) {
            rootLayout.setBackgroundColor(ContextCompat.getColor(this, R.color.darkBackground))
            scrollView.setBackgroundColor(ContextCompat.getColor(this, R.color.darkBackground))
            tabLayout.setBackgroundColor(ContextCompat.getColor(this, R.color.darkSurface))
            emptyState.setBackgroundColor(ContextCompat.getColor(this, R.color.darkBackground))
            tvEmptyTitle.setTextColor(ContextCompat.getColor(this, R.color.darkTextPrimary))
            tvEmptySubtitle.setTextColor(ContextCompat.getColor(this, R.color.darkTextSecondary))
            window.statusBarColor = ContextCompat.getColor(this, R.color.darkBackground)
        }
    }

    private fun updateTabUI() {
        if (currentTab == "exercises") {
            tabExercises.setBackgroundResource(R.drawable.button_submit_background)
            tabExercises.setTextColor(ContextCompat.getColor(this, R.color.white))
            tabLessons.setBackgroundResource(if (isDarkMode) R.drawable.edittext_background_dark else R.drawable.edittext_background)
            tabLessons.setTextColor(ContextCompat.getColor(this, if (isDarkMode) R.color.darkTextSecondary else R.color.gray600))
        } else {
            tabLessons.setBackgroundResource(R.drawable.button_submit_background)
            tabLessons.setTextColor(ContextCompat.getColor(this, R.color.white))
            tabExercises.setBackgroundResource(if (isDarkMode) R.drawable.edittext_background_dark else R.drawable.edittext_background)
            tabExercises.setTextColor(ContextCompat.getColor(this, if (isDarkMode) R.color.darkTextSecondary else R.color.gray600))
        }
    }

    private fun loadHistory(userId: String, accessToken: String) {
        progressBar.visibility = View.VISIBLE
        historyContainer.removeAllViews()
        emptyState.visibility = View.GONE

        CoroutineScope(Dispatchers.IO).launch {
            try {
                // Fetch exercise attempts
                val attemptsRequest = Request.Builder()
                    .url("$supabaseUrl/rest/v1/exercise_attempts?select=*&user_id=eq.$userId&status=eq.completed&order=completed_at.desc")
                    .addHeader("apikey", supabaseKey)
                    .addHeader("Authorization", "Bearer $accessToken")
                    .build()

                val attemptsResponse = client.newCall(attemptsRequest).execute()
                val attemptsJson = attemptsResponse.body?.string() ?: "[]"
                exerciseAttempts = JSONArray(attemptsJson)

                // Fetch lesson progress
                val progressRequest = Request.Builder()
                    .url("$supabaseUrl/rest/v1/lesson_progress?select=*&user_id=eq.$userId&order=last_accessed_at.desc")
                    .addHeader("apikey", supabaseKey)
                    .addHeader("Authorization", "Bearer $accessToken")
                    .build()

                val progressResponse = client.newCall(progressRequest).execute()
                val progressJson = progressResponse.body?.string() ?: "[]"
                lessonProgress = JSONArray(progressJson)

                // Collect unique exercise IDs and lesson IDs
                val exerciseIds = mutableSetOf<String>()
                val lessonIds = mutableSetOf<String>()

                for (i in 0 until exerciseAttempts.length()) {
                    exerciseIds.add(exerciseAttempts.getJSONObject(i).getString("exercise_id"))
                }
                for (i in 0 until lessonProgress.length()) {
                    lessonIds.add(lessonProgress.getJSONObject(i).getString("lesson_id"))
                }

                // Fetch exercises info
                if (exerciseIds.isNotEmpty()) {
                    val idsParam = exerciseIds.joinToString(",") { "\"$it\"" }
                    val exercisesRequest = Request.Builder()
                        .url("$supabaseUrl/rest/v1/exercises?select=id,title,category,concept,level&id=in.($idsParam)")
                        .addHeader("apikey", supabaseKey)
                        .addHeader("Authorization", "Bearer $accessToken")
                        .build()

                    val exercisesResponse = client.newCall(exercisesRequest).execute()
                    val exercisesJson = exercisesResponse.body?.string() ?: "[]"
                    val exercisesArray = JSONArray(exercisesJson)

                    for (i in 0 until exercisesArray.length()) {
                        val exercise = exercisesArray.getJSONObject(i)
                        exercisesMap[exercise.getString("id")] = exercise
                    }
                }

                // Fetch lessons info
                if (lessonIds.isNotEmpty()) {
                    val idsParam = lessonIds.joinToString(",") { "\"$it\"" }
                    val lessonsRequest = Request.Builder()
                        .url("$supabaseUrl/rest/v1/lessons?select=id,title,category,concept,level&id=in.($idsParam)")
                        .addHeader("apikey", supabaseKey)
                        .addHeader("Authorization", "Bearer $accessToken")
                        .build()

                    val lessonsResponse = client.newCall(lessonsRequest).execute()
                    val lessonsJson = lessonsResponse.body?.string() ?: "[]"
                    val lessonsArray = JSONArray(lessonsJson)

                    for (i in 0 until lessonsArray.length()) {
                        val lesson = lessonsArray.getJSONObject(i)
                        lessonsMap[lesson.getString("id")] = lesson
                    }
                }

                withContext(Dispatchers.Main) {
                    progressBar.visibility = View.GONE

                    // Update counts
                    tvExerciseCount.text = exerciseAttempts.length().toString()
                    tvLessonCount.text = lessonProgress.length().toString()

                    // Display based on current tab
                    if (currentTab == "exercises") {
                        displayExerciseHistory()
                    } else {
                        displayLessonHistory()
                    }
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    progressBar.visibility = View.GONE
                    showError("${getString(R.string.cannot_load_history)}: ${e.message}")
                }
            }
        }
    }

    private fun displayExerciseHistory() {
        historyContainer.removeAllViews()

        if (exerciseAttempts.length() == 0) {
            emptyState.visibility = View.VISIBLE
            tvEmptyTitle.text = getString(R.string.no_exercise_history)
            tvEmptySubtitle.text = getString(R.string.do_exercises_hint)
            return
        }

        emptyState.visibility = View.GONE

        for (i in 0 until exerciseAttempts.length()) {
            val attempt = exerciseAttempts.getJSONObject(i)
            addExerciseItem(attempt)
        }
    }

    private fun displayLessonHistory() {
        historyContainer.removeAllViews()

        if (lessonProgress.length() == 0) {
            emptyState.visibility = View.VISIBLE
            tvEmptyTitle.text = getString(R.string.no_lesson_history)
            tvEmptySubtitle.text = getString(R.string.do_lessons_hint)
            return
        }

        emptyState.visibility = View.GONE

        for (i in 0 until lessonProgress.length()) {
            val progress = lessonProgress.getJSONObject(i)
            addLessonItem(progress)
        }
    }

    private fun addExerciseItem(attempt: JSONObject) {
        val itemView = LayoutInflater.from(this)
            .inflate(R.layout.item_history_exercise, historyContainer, false)

        val cardContainer = itemView.findViewById<View>(R.id.cardContainer)
        val tvExerciseTitle = itemView.findViewById<TextView>(R.id.tvExerciseTitle)
        val tvDate = itemView.findViewById<TextView>(R.id.tvDate)
        val tvStatus = itemView.findViewById<TextView>(R.id.tvStatus)
        val tvScore = itemView.findViewById<TextView>(R.id.tvScore)
        val tvCorrect = itemView.findViewById<TextView>(R.id.tvCorrect)
        val tvTime = itemView.findViewById<TextView>(R.id.tvTime)
        val tvAttempt = itemView.findViewById<TextView>(R.id.tvAttempt)

        // Get exercise info
        val exerciseId = attempt.getString("exercise_id")
        val exercise = exercisesMap[exerciseId]
        val title = exercise?.optString("title", getString(R.string.exercise)) ?: getString(R.string.exercise)

        // Set data
        tvExerciseTitle.text = title

        // Format date
        val completedAt = attempt.optString("completed_at", "")
        tvDate.text = formatDateTime(completedAt)

        // Status
        val isPassed = attempt.optBoolean("is_passed", false)
        if (isPassed) {
            tvStatus.text = getString(R.string.passed)
            tvStatus.setTextColor(ContextCompat.getColor(this, R.color.success))
            tvStatus.setBackgroundResource(R.drawable.badge_earned_background)
        } else {
            tvStatus.text = getString(R.string.not_passed)
            tvStatus.setTextColor(ContextCompat.getColor(this, R.color.error))
            tvStatus.setBackgroundResource(R.drawable.badge_locked_background)
        }

        // Score
        val scorePercentage = attempt.optInt("score_percentage", 0)
        tvScore.text = "$scorePercentage%"
        tvScore.setTextColor(ContextCompat.getColor(this,
            if (scorePercentage >= 70) R.color.success else if (scorePercentage >= 50) R.color.warning else R.color.error))

        // Correct answers
        val correctAnswers = attempt.optInt("correct_answers", 0)
        val totalQuestions = attempt.optInt("total_questions", 0)
        tvCorrect.text = "$correctAnswers/$totalQuestions"

        // Time spent
        val timeSpent = attempt.optInt("time_spent", 0)
        tvTime.text = formatTime(timeSpent)

        // Attempt number
        val attemptNumber = attempt.optInt("attempt_number", 1)
        tvAttempt.text = getString(R.string.attempt_number, attemptNumber)

        // Apply dark mode
        if (isDarkMode) {
            cardContainer.setBackgroundResource(R.drawable.card_background_dark)
            tvExerciseTitle.setTextColor(ContextCompat.getColor(this, R.color.darkTextPrimary))
            tvDate.setTextColor(ContextCompat.getColor(this, R.color.darkTextSecondary))
            tvCorrect.setTextColor(ContextCompat.getColor(this, R.color.darkTextPrimary))
            tvTime.setTextColor(ContextCompat.getColor(this, R.color.darkTextPrimary))
            tvAttempt.setTextColor(ContextCompat.getColor(this, R.color.darkTextSecondary))
        }

        historyContainer.addView(itemView)
    }

    private fun addLessonItem(progress: JSONObject) {
        val itemView = LayoutInflater.from(this)
            .inflate(R.layout.item_history_lesson, historyContainer, false)

        val cardContainer = itemView.findViewById<View>(R.id.cardContainer)
        val tvLessonTitle = itemView.findViewById<TextView>(R.id.tvLessonTitle)
        val tvCategory = itemView.findViewById<TextView>(R.id.tvCategory)
        val tvStatus = itemView.findViewById<TextView>(R.id.tvStatus)
        val tvProgressPercent = itemView.findViewById<TextView>(R.id.tvProgressPercent)
        val progressBarView = itemView.findViewById<ProgressBar>(R.id.progressBar)
        val tvTimeSpent = itemView.findViewById<TextView>(R.id.tvTimeSpent)
        val tvLastAccessed = itemView.findViewById<TextView>(R.id.tvLastAccessed)

        // Get lesson info
        val lessonId = progress.getString("lesson_id")
        val lesson = lessonsMap[lessonId]
        val title = lesson?.optString("title", getString(R.string.lesson)) ?: getString(R.string.lesson)
        val category = lesson?.optString("category", "") ?: ""

        // Set data
        tvLessonTitle.text = title
        tvCategory.text = category

        // Status
        val status = progress.optString("status", "not_started")
        when (status) {
            "completed" -> {
                tvStatus.text = getString(R.string.completed)
                tvStatus.setTextColor(ContextCompat.getColor(this, R.color.success))
                tvStatus.setBackgroundResource(R.drawable.badge_earned_background)
                tvProgressPercent.text = "100%"
                progressBarView.progress = 100
            }
            "in_progress" -> {
                tvStatus.text = getString(R.string.in_progress)
                tvStatus.setTextColor(ContextCompat.getColor(this, R.color.warning))
                tvStatus.setBackgroundResource(R.drawable.badge_locked_background)
                // Estimate progress based on last_question_index
                val lastIndex = progress.optInt("last_question_index", 0)
                val progressPercent = minOf(lastIndex * 20, 90) // Rough estimate
                tvProgressPercent.text = "$progressPercent%"
                progressBarView.progress = progressPercent
            }
            else -> {
                tvStatus.text = getString(R.string.not_started)
                tvStatus.setTextColor(ContextCompat.getColor(this, R.color.gray500))
                tvStatus.setBackgroundResource(R.drawable.badge_locked_background)
                tvProgressPercent.text = "0%"
                progressBarView.progress = 0
            }
        }

        // Time spent
        val timeSpent = progress.optInt("time_spent", 0)
        tvTimeSpent.text = formatTimeMinutes(timeSpent)

        // Last accessed
        val lastAccessed = progress.optString("last_accessed_at", "")
        tvLastAccessed.text = formatDate(lastAccessed)

        // Apply dark mode
        if (isDarkMode) {
            cardContainer.setBackgroundResource(R.drawable.card_background_dark)
            tvLessonTitle.setTextColor(ContextCompat.getColor(this, R.color.darkTextPrimary))
            tvCategory.setTextColor(ContextCompat.getColor(this, R.color.darkTextSecondary))
            tvTimeSpent.setTextColor(ContextCompat.getColor(this, R.color.darkTextSecondary))
            tvLastAccessed.setTextColor(ContextCompat.getColor(this, R.color.darkTextSecondary))
        }

        historyContainer.addView(itemView)
    }

    private fun formatDateTime(isoDate: String): String {
        if (isoDate.isEmpty()) return "N/A"
        return try {
            val inputFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault())
            val outputFormat = SimpleDateFormat("dd/MM/yyyy - HH:mm", Locale.getDefault())
            val date = inputFormat.parse(isoDate.substring(0, 19))
            date?.let { outputFormat.format(it) } ?: "N/A"
        } catch (e: Exception) {
            "N/A"
        }
    }

    private fun formatDate(isoDate: String): String {
        if (isoDate.isEmpty()) return "N/A"
        return try {
            val inputFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault())
            val outputFormat = SimpleDateFormat("dd/MM/yyyy", Locale.getDefault())
            val date = inputFormat.parse(isoDate.substring(0, 19))
            date?.let { outputFormat.format(it) } ?: "N/A"
        } catch (e: Exception) {
            "N/A"
        }
    }

    private fun formatTime(seconds: Int): String {
        val minutes = seconds / 60
        val secs = seconds % 60
        return String.format("%d:%02d", minutes, secs)
    }

    private fun formatTimeMinutes(seconds: Int): String {
        val minutes = seconds / 60
        return if (minutes > 0) getString(R.string.minutes_format, minutes) else getString(R.string.less_than_minute)
    }

    private fun showError(message: String) {
        historyContainer.removeAllViews()
        emptyState.visibility = View.VISIBLE
        tvEmptyTitle.text = getString(R.string.error)
        tvEmptySubtitle.text = message
    }
}
