package com.example.localservicemarketplace.fragments;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AlertDialog;
import androidx.fragment.app.Fragment;

import com.example.localservicemarketplace.R;
import com.example.localservicemarketplace.activities.MainActivity;
import com.example.localservicemarketplace.database.DatabaseHelper;
import com.example.localservicemarketplace.models.User;
import com.example.localservicemarketplace.utils.SessionManager;

public class ProfileFragment extends Fragment {
    private TextView tvName, tvEmail, tvPhone, tvRole, tvRating;
    private Button btnLogout, btnEditProfile, btnAddService;
    private DatabaseHelper dbHelper;
    private SessionManager sessionManager;
    private String userId;
    private String userRole;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_profile, container, false);

        dbHelper = new DatabaseHelper(getContext());
        sessionManager = new SessionManager(getContext());
        userId = sessionManager.getUserId();
        userRole = sessionManager.getUserRole();

        initViews(view);
        loadUserData();
        setupListeners();

        return view;
    }

    private void initViews(View view) {
        tvName = view.findViewById(R.id.tv_name);
        tvEmail = view.findViewById(R.id.tv_email);
        tvPhone = view.findViewById(R.id.tv_phone);
        tvRole = view.findViewById(R.id.tv_role);
        tvRating = view.findViewById(R.id.tv_rating);
        btnLogout = view.findViewById(R.id.btn_logout);
        btnEditProfile = view.findViewById(R.id.btn_edit_profile);
        btnAddService = view.findViewById(R.id.btn_add_service);

        // Show add service button only for providers
        if (!userRole.equals("SERVICE_PROVIDER")) {
            btnAddService.setVisibility(View.GONE);
        }
    }

    private void loadUserData() {
        User user = dbHelper.getUserById(userId);
        if (user != null) {
            tvName.setText(user.getName());
            tvEmail.setText(user.getEmail());
            tvPhone.setText(user.getPhone());
            tvRole.setText(user.getRole().toString());

            // Load rating for providers
            if (userRole.equals("SERVICE_PROVIDER")) {
                double rating = dbHelper.getAverageRatingForProvider(userId);
                tvRating.setText(String.format("Rating: %.1f ★", rating));
                tvRating.setVisibility(View.VISIBLE);
            } else {
                tvRating.setVisibility(View.GONE);
            }
        }
    }

    private void setupListeners() {
        btnLogout.setOnClickListener(v -> {
            new AlertDialog.Builder(getContext())
                    .setTitle("Logout")
                    .setMessage("Are you sure you want to logout?")
                    .setPositiveButton("Yes", (dialog, which) -> {
                        if (getActivity() instanceof MainActivity) {
                            ((MainActivity) getActivity()).logout();
                        }
                    })
                    .setNegativeButton("No", null)
                    .show();
        });

        btnEditProfile.setOnClickListener(v -> {
            Toast.makeText(getContext(), "Edit profile feature coming soon", Toast.LENGTH_SHORT).show();
        });

        btnAddService.setOnClickListener(v -> {
            Toast.makeText(getContext(), "Add service feature coming soon", Toast.LENGTH_SHORT).show();
        });
    }
}