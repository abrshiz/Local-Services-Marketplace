package com.example.localservicemarketplace.fragments;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Toast;

import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.example.localservicemarketplace.R;
import com.example.localservicemarketplace.adapters.CategoryAdapter;
import com.example.localservicemarketplace.adapters.ServiceAdapter;
import com.example.localservicemarketplace.database.DatabaseHelper;
import com.example.localservicemarketplace.models.Service;
import com.example.localservicemarketplace.models.ServiceCategory;

import java.util.List;

public class HomeFragment extends Fragment {
    private RecyclerView rvCategories, rvServices;
    private DatabaseHelper dbHelper;
    private CategoryAdapter categoryAdapter;
    private ServiceAdapter serviceAdapter;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_home, container, false);

        dbHelper = new DatabaseHelper(getContext());

        initViews(view);
        loadCategories();
        loadServices();

        return view;
    }

    private void initViews(View view) {
        rvCategories = view.findViewById(R.id.rv_categories);
        rvServices = view.findViewById(R.id.rv_services);

        rvCategories.setLayoutManager(new GridLayoutManager(getContext(), 2));
        rvServices.setLayoutManager(new GridLayoutManager(getContext(), 2));
    }

    private void loadCategories() {
        List<ServiceCategory> categories = dbHelper.getAllCategories();
        categoryAdapter = new CategoryAdapter(categories, category -> {
            // Filter services by category
            Toast.makeText(getContext(), "Selected: " + category.getName(), Toast.LENGTH_SHORT).show();
            loadServicesByCategory(category.getCategoryId());
        });
        rvCategories.setAdapter(categoryAdapter);
    }

    private void loadServices() {
        List<Service> services = dbHelper.getAllActiveServices();
        serviceAdapter = new ServiceAdapter(services, service -> {
            // Navigate to booking
            Toast.makeText(getContext(), "Selected: " + service.getTitle(), Toast.LENGTH_SHORT).show();
            // TODO: Open BookingActivity
        });
        rvServices.setAdapter(serviceAdapter);
    }

    private void loadServicesByCategory(String categoryId) {
        List<Service> services = dbHelper.getServicesByCategory(categoryId);
        serviceAdapter.updateServices(services);
    }
}