package com.example.grammar_up

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
import java.util.concurrent.TimeUnit

class AchievementActivity : AppCompatActivity() {

    private val client = OkHttpClient.Builder()
        .connectTimeout(30, TimeUnit.SECONDS)
        .readTimeout(30, TimeUnit.SECONDS)
        .writeTimeout(30, TimeUnit.SECONDS)
        .build()

    private lateinit var achievementsContainer: LinearLayout
    private lateinit var progressBar: ProgressBar
    private lateinit var tvEarnedCount: TextView
    private lateinit var tvTotalCount: TextView
    private lateinit var rootLayout: LinearLayout
    private lateinit var headerLayout: LinearLayout
    private lateinit var scrollView: ScrollView

    private var isDarkMode = false

    // Supabase configuration
    private val supabaseUrl = "https://rrusvgwfkkiwlwuvrbmd.supabase.co"
    private val supabaseKey = "sb_publishable_zB9I5wsydI5NvpxyaAHrnQ_-ljP4lZ-"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_achievement)

        // Get user info from intent
        val userId = intent.getStringExtra("userId") ?: ""
        val accessToken = intent.getStringExtra("accessToken") ?: ""
        isDarkMode = intent.getBooleanExtra("isDarkMode", false)

        // Initialize views
        rootLayout = findViewById(R.id.rootLayout)
        headerLayout = findViewById(R.id.headerLayout)
        scrollView = findViewById(R.id.scrollView)
        achievementsContainer = findViewById(R.id.achievementsContainer)
        progressBar = findViewById(R.id.progressBar)
        tvEarnedCount = findViewById(R.id.tvEarnedCount)
        tvTotalCount = findViewById(R.id.tvTotalCount)

        // Apply dark mode
        applyTheme()

        // Setup back button
        findViewById<ImageView>(R.id.btnBack).setOnClickListener {
            finish()
        }

        // Load achievements
        if (userId.isNotEmpty() && accessToken.isNotEmpty()) {
            loadAchievements(userId, accessToken)
        } else {
            showError("Vui lòng đăng nhập để xem achievements")
        }
    }

    private fun applyTheme() {
        if (isDarkMode) {
            rootLayout.setBackgroundColor(ContextCompat.getColor(this, R.color.darkBackground))
            scrollView.setBackgroundColor(ContextCompat.getColor(this, R.color.darkBackground))
            window.statusBarColor = ContextCompat.getColor(this, R.color.darkBackground)
        }
    }

    private fun loadAchievements(userId: String, accessToken: String) {
        progressBar.visibility = View.VISIBLE
        achievementsContainer.removeAllViews()

        CoroutineScope(Dispatchers.IO).launch {
            try {
                // Fetch all achievements
                val achievementsRequest = Request.Builder()
                    .url("$supabaseUrl/rest/v1/achievements?select=*&order=created_at.asc")
                    .addHeader("apikey", supabaseKey)
                    .addHeader("Authorization", "Bearer $accessToken")
                    .build()

                val achievementsResponse = client.newCall(achievementsRequest).execute()
                val achievementsJson = achievementsResponse.body?.string() ?: "[]"
                val achievements = JSONArray(achievementsJson)

                // Fetch user's earned achievements
                val earnedRequest = Request.Builder()
                    .url("$supabaseUrl/rest/v1/user_achievements?select=achievement_id,earned_at&user_id=eq.$userId")
                    .addHeader("apikey", supabaseKey)
                    .addHeader("Authorization", "Bearer $accessToken")
                    .build()

                val earnedResponse = client.newCall(earnedRequest).execute()
                val earnedJson = earnedResponse.body?.string() ?: "[]"
                val earnedArray = JSONArray(earnedJson)

                // Create a set of earned achievement IDs
                val earnedIds = mutableSetOf<String>()
                val earnedDates = mutableMapOf<String, String>()
                for (i in 0 until earnedArray.length()) {
                    val item = earnedArray.getJSONObject(i)
                    val achievementId = item.getString("achievement_id")
                    earnedIds.add(achievementId)
                    earnedDates[achievementId] = item.optString("earned_at", "")
                }

                withContext(Dispatchers.Main) {
                    progressBar.visibility = View.GONE

                    // Update counts
                    tvEarnedCount.text = earnedIds.size.toString()
                    tvTotalCount.text = "/${achievements.length()}"

                    // Group achievements by category
                    val categories = mapOf(
                        "learning" to "Học tập",
                        "exercise" to "Bài tập",
                        "streak" to "Chuỗi ngày",
                        "vocabulary" to "Từ vựng",
                        "milestone" to "Cột mốc"
                    )

                    val groupedAchievements = mutableMapOf<String, MutableList<JSONObject>>()
                    for (i in 0 until achievements.length()) {
                        val achievement = achievements.getJSONObject(i)
                        val category = achievement.optString("category", "other")
                        if (!groupedAchievements.containsKey(category)) {
                            groupedAchievements[category] = mutableListOf()
                        }
                        groupedAchievements[category]?.add(achievement)
                    }

                    // Display achievements by category
                    for ((category, achievementList) in groupedAchievements) {
                        // Add category header
                        val categoryName = categories[category] ?: category
                        addCategoryHeader(categoryName)

                        // Add achievements in this category
                        for (achievement in achievementList) {
                            val id = achievement.getString("id")
                            val isEarned = earnedIds.contains(id)
                            val earnedDate = earnedDates[id]
                            addAchievementItem(achievement, isEarned, earnedDate)
                        }
                    }
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    progressBar.visibility = View.GONE
                    showError("Không thể tải achievements: ${e.message}")
                }
            }
        }
    }

    private fun addCategoryHeader(categoryName: String) {
        val headerView = LayoutInflater.from(this)
            .inflate(R.layout.item_achievement_category, achievementsContainer, false)

        val tvCategoryName = headerView.findViewById<TextView>(R.id.tvCategoryName)
        tvCategoryName.text = categoryName

        if (isDarkMode) {
            tvCategoryName.setTextColor(ContextCompat.getColor(this, R.color.darkTextPrimary))
        }

        achievementsContainer.addView(headerView)
    }

    private fun addAchievementItem(achievement: JSONObject, isEarned: Boolean, earnedDate: String?) {
        val itemView = LayoutInflater.from(this)
            .inflate(R.layout.item_achievement, achievementsContainer, false)

        val tvIcon = itemView.findViewById<TextView>(R.id.tvIcon)
        val tvName = itemView.findViewById<TextView>(R.id.tvName)
        val tvDescription = itemView.findViewById<TextView>(R.id.tvDescription)
        val tvPoints = itemView.findViewById<TextView>(R.id.tvPoints)
        val tvStatus = itemView.findViewById<TextView>(R.id.tvStatus)
        val cardContainer = itemView.findViewById<View>(R.id.cardContainer)

        // Set data - with proper fallback for null/empty icon
        val iconUrl = achievement.optString("icon_url", "")
        tvIcon.text = if (iconUrl.isNullOrEmpty() || iconUrl == "null") "🏆" else iconUrl
        tvName.text = achievement.getString("name")
        tvDescription.text = achievement.getString("description")
        tvPoints.text = "+${achievement.optInt("points_reward", 0)} pts"

        // Apply dark mode to card
        if (isDarkMode) {
            cardContainer.setBackgroundResource(R.drawable.card_background_dark)
            tvName.setTextColor(ContextCompat.getColor(this, R.color.darkTextPrimary))
            tvDescription.setTextColor(ContextCompat.getColor(this, R.color.darkTextSecondary))
        }

        if (isEarned) {
            // Earned state
            tvStatus.text = "Đã đạt được"
            tvStatus.setTextColor(getColor(R.color.success))
            tvStatus.setBackgroundResource(R.drawable.badge_earned_background)
            cardContainer.alpha = 1.0f
        } else {
            // Not earned state
            tvStatus.text = "Chưa đạt"
            tvStatus.setTextColor(getColor(R.color.gray500))
            tvStatus.setBackgroundResource(if (isDarkMode) R.drawable.badge_locked_background_dark else R.drawable.badge_locked_background)
            cardContainer.alpha = 0.6f
        }

        achievementsContainer.addView(itemView)
    }

    private fun showError(message: String) {
        val errorView = TextView(this).apply {
            text = message
            setTextColor(getColor(R.color.error))
            textSize = 16f
            setPadding(32, 32, 32, 32)
        }
        achievementsContainer.addView(errorView)
    }
}
