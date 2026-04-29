package com.example.localservicemarketplace.fragments;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.example.localservicemarketplace.R;
import com.example.localservicemarketplace.adapters.ServiceAdapter;
import com.example.localservicemarketplace.database.DatabaseHelper;
import com.example.localservicemarketplace.models.Service;
import com.example.localservicemarketplace.utils.SessionManager;

import java.util.List;

public class ProviderDashboardFragment extends Fragment {
    private TextView tvStatsTotalServices, tvStatsTotalBookings, tvStatsAverageRating;
    private RecyclerView rvMyServices;
    private DatabaseHelper dbHelper;
    private SessionManager sessionManager;
    private String providerId;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_provider_dashboard, container, false);

        dbHelper = new DatabaseHelper(getContext());
        sessionManager = new SessionManager(getContext());
        providerId = sessionManager.getUserId();

        initViews(view);
        loadDashboardData();

        return view;
    }

    private void initViews(View view) {
        tvStatsTotalServices = view.findViewById(R.id.tv_stats_total_services);
        tvStatsTotalBookings = view.findViewById(R.id.tv_stats_total_bookings);
        tvStatsAverageRating = view.findViewById(R.id.tv_stats_average_rating);
        rvMyServices = view.findViewById(R.id.rv_my_services);

        rvMyServices.setLayoutManager(new LinearLayoutManager(getContext()));
    }

    private void loadDashboardData() {
        // Load provider's services
        List<Service> services = dbHelper.getServicesByProvider(providerId);
        tvStatsTotalServices.setText(String.valueOf(services.size()));

        // Load bookings count
        int bookingsCount = dbHelper.getBookingsByProvider(providerId).size();
        tvStatsTotalBookings.setText(String.valueOf(bookingsCount));

        // Load average rating
        double rating = dbHelper.getAverageRatingForProvider(providerId);
        tvStatsAverageRating.setText(String.format("%.1f ★", rating));

        // Load services in recycler view
        ServiceAdapter adapter = new ServiceAdapter(services, service -> {
            // Handle service click
        });
        rvMyServices.setAdapter(adapter);
    }
}