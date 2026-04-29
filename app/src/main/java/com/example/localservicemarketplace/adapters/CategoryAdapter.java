package com.example.localservicemarketplace.adapters;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.example.localservicemarketplace.R;
import com.example.localservicemarketplace.models.ServiceCategory;

import java.util.List;

public class CategoryAdapter extends RecyclerView.Adapter<CategoryAdapter.ViewHolder> {
    private List<ServiceCategory> categories;
    private OnCategoryClickListener listener;

    public interface OnCategoryClickListener {
        void onCategoryClick(ServiceCategory category);
    }

    public CategoryAdapter(List<ServiceCategory> categories, OnCategoryClickListener listener) {
        this.categories = categories;
        this.listener = listener;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_category, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        ServiceCategory category = categories.get(position);
        holder.tvCategoryName.setText(category.getName());
        holder.tvCategoryDesc.setText(category.getDescription());

        // Set icon based on iconUrl (simplified for demo)
        // In production, you'd load actual images
        holder.itemView.setOnClickListener(v -> listener.onCategoryClick(category));
    }

    @Override
    public int getItemCount() {
        return categories.size();
    }

    static class ViewHolder extends RecyclerView.ViewHolder {
        TextView tvCategoryName, tvCategoryDesc;
        ImageView ivCategoryIcon;

        ViewHolder(View itemView) {
            super(itemView);
            tvCategoryName = itemView.findViewById(R.id.tv_category_name);
            tvCategoryDesc = itemView.findViewById(R.id.tv_category_desc);
            ivCategoryIcon = itemView.findViewById(R.id.iv_category_icon);
        }
    }
}