package com.example.localservicemarketplace.adapters;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.example.localservicemarketplace.R;
import com.example.localservicemarketplace.models.Service;
import com.example.localservicemarketplace.database.DatabaseHelper;

import java.util.List;

public class ServiceAdapter extends RecyclerView.Adapter<ServiceAdapter.ViewHolder> {
    private List<Service> services;
    private OnServiceClickListener listener;
    private DatabaseHelper dbHelper;

    public interface OnServiceClickListener {
        void onServiceClick(Service service);
    }

    public ServiceAdapter(List<Service> services, OnServiceClickListener listener) {
        this.services = services;
        this.listener = listener;
    }

    public void updateServices(List<Service> newServices) {
        this.services = newServices;
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_service, parent, false);
        dbHelper = new DatabaseHelper(parent.getContext());
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        Service service = services.get(position);
        holder.tvServiceTitle.setText(service.getTitle());
        holder.tvServiceDesc.setText(service.getDescription());
        holder.tvServicePrice.setText(String.format("₱%s", service.getBasePrice().toString()));
        holder.tvPriceType.setText(service.getPriceType().toString());

        // Get provider name
        String providerName = getProviderName(service.getProviderId());
        holder.tvProviderName.setText(providerName);

        holder.itemView.setOnClickListener(v -> listener.onServiceClick(service));
    }

    private String getProviderName(String providerId) {
        com.example.localservicemarketplace.models.User user = dbHelper.getUserById(providerId);
        return user != null ? user.getName() : "Unknown Provider";
    }

    @Override
    public int getItemCount() {
        return services.size();
    }

    static class ViewHolder extends RecyclerView.ViewHolder {
        TextView tvServiceTitle, tvServiceDesc, tvServicePrice, tvPriceType, tvProviderName;

        ViewHolder(View itemView) {
            super(itemView);
            tvServiceTitle = itemView.findViewById(R.id.tv_service_title);
            tvServiceDesc = itemView.findViewById(R.id.tv_service_desc);
            tvServicePrice = itemView.findViewById(R.id.tv_service_price);
            tvPriceType = itemView.findViewById(R.id.tv_price_type);
            tvProviderName = itemView.findViewById(R.id.tv_provider_name);
        }
    }
}