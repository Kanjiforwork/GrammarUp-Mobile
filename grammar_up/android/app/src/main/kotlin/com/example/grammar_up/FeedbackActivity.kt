package com.example.grammar_up

import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import android.widget.RadioGroup
import android.widget.RatingBar
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity

class FeedbackActivity : AppCompatActivity() {

    private lateinit var ratingBar: RatingBar
    private lateinit var radioGroup: RadioGroup
    private lateinit var editTextSuggestion: EditText
    private lateinit var btnCancel: Button
    private lateinit var btnSubmit: Button

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_feedback)

        // Initialize views
        ratingBar = findViewById(R.id.ratingBar)
        radioGroup = findViewById(R.id.radioGroup)
        editTextSuggestion = findViewById(R.id.editTextSuggestion)
        btnCancel = findViewById(R.id.btnCancel)
        btnSubmit = findViewById(R.id.btnSubmit)

        // Setup back button in action bar
        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        supportActionBar?.title = ""

        // Set up button listeners
        btnCancel.setOnClickListener {
            finish()
        }

        btnSubmit.setOnClickListener {
            submitFeedback()
        }
    }

    override fun onSupportNavigateUp(): Boolean {
        finish()
        return true
    }

    private fun submitFeedback() {
        val rating = ratingBar.rating
        val selectedOptionId = radioGroup.checkedRadioButtonId
        val suggestion = editTextSuggestion.text.toString().trim()

        // Check if at least one field is filled
        if (rating == 0f && selectedOptionId == -1 && suggestion.isEmpty()) {
            Toast.makeText(this, "Vui lòng điền ít nhất một thông tin", Toast.LENGTH_SHORT).show()
            return
        }

        // Get selected option text
        val selectedOption = when (selectedOptionId) {
            R.id.radioOption1 -> "Tính năng \"vừa học vừa chơi\""
            R.id.radioOption2 -> "Giao diện đơn giản, dễ tìm bài học"
            R.id.radioOption3 -> "Nội dung bài tập đa dạng, phong phú"
            else -> null
        }

        // Here you can send the feedback to your backend
        // For now, just show success message
        
        Toast.makeText(this, "Cảm ơn bạn đã gửi đánh giá!", Toast.LENGTH_LONG).show()
        
        // Close activity
        finish()
    }
}
