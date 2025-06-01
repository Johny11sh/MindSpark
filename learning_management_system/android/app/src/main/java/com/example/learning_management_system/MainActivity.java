package com.example.learning_management_system;

import io.flutter.embedding.android.FlutterActivity;
import android.os.Bundle;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getIntent().putExtra("enable-software-rendering", true);
    }
}
