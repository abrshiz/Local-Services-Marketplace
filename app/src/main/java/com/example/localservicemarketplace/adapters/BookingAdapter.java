package com.example.localservicemarketplace.adapters;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.example.localservicemarketplace.R;
import com.example.localservicemarketplace.database.DatabaseHelper;
import com.example.localservicemarketplace.models.Booking;
import com.example.localservicemarketplace.models.Service;
import com.example.localservicemarketplace.models.User;

import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Locale;

public class BookingAdapter extends RecyclerView.Adapter<BookingAdapter.ViewHolder> {
    private List<Booking> bookings;
    private String userRole;
    private BookingActionListener actionListener;
    private DatabaseHelper dbHelper;
    private SimpleDateFormat dateFormat;

    public interface BookingActionListener {
        void onAccept(Booking booking);
        void onReject(Booking booking);
        void onComplete(Booking booking);
        void onCancel(Booking booking);
    }

    public BookingAdapter(List<Booking> bookings, String userRole, BookingActionListener actionListener) {
        this.bookings = bookings;
        this.userRole = userRole;
        this.actionListener = actionListener;
        this.dateFormat = new SimpleDateFormat("MMM dd, yyyy 'at' hh:mm a", Locale.getDefault());
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_booking, parent, false);
        dbHelper = new DatabaseHelper(parent.getContext());
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        Booking booking = bookings.get(position);

        Service service = getServiceById(booking.getServiceId());
        if (service != null) {
            holder.tvServiceName.setText(service.getTitle());
            holder.tvTotalPrice.setText(String.format("₱%s", booking.getTotalPrice().toString()));
        }

        holder.tvDateTime.setText(dateFormat.format(booking.getScheduledTime()));
        holder.tvStatus.setText(booking.getStatus().toString());

        // Show different info based on user role
        if (userRole.equals("SERVICE_PROVIDER")) {
            User customer = dbHelper.getUserById(booking.getCustomerId());
            holder.tvOtherParty.setText(String.format("Customer: %s", customer != null ? customer.getName() : "Unknown"));

            // Show action buttons based on booking status
            if (booking.getStatus() == Booking.BookingStatus.PENDING) {
                holder.btnAccept.setVisibility(View.VISIBLE);
                holder.btnReject.setVisibility(View.VISIBLE);
                holder.btnComplete.setVisibility(View.GONE);
                holder.btnCancel.setVisibility(View.GONE);

                holder.btnAccept.setOnClickListener(v -> actionListener.onAccept(booking));
                holder.btnReject.setOnClickListener(v -> actionListener.onReject(booking));
            } else if (booking.getStatus() == Booking.BookingStatus.ACCEPTED) {
                holder.btnAccept.setVisibility(View.GONE);
                holder.btnReject.setVisibility(View.GONE);
                holder.btnComplete.setVisibility(View.VISIBLE);
                holder.btnCancel.setVisibility(View.GONE);

                holder.btnComplete.setOnClickListener(v -> actionListener.onComplete(booking));
            } else {
                hideActionButtons(holder);
            }
        } else {
            User provider = dbHelper.getUserById(booking.getProviderId());
            holder.tvOtherParty.setText(String.format("Provider: %s", provider != null ? provider.getName() : "Unknown"));

            // Show cancel button for pending bookings
            if (booking.getStatus() == Booking.BookingStatus.PENDING) {
                holder.btnCancel.setVisibility(View.VISIBLE);
                holder.btnCancel.setOnClickListener(v -> actionListener.onCancel(booking));
                hideProviderButtons(holder);
            } else {
                hideActionButtons(holder);
            }
        }

        // Set status color
        setStatusColor(holder.tvStatus, booking.getStatus());
    }

    private void hideActionButtons(ViewHolder holder) {
        holder.btnAccept.setVisibility(View.GONE);
        holder.btnReject.setVisibility(View.GONE);
        holder.btnComplete.setVisibility(View.GONE);
        holder.btnCancel.setVisibility(View.GONE);
    }

    private void hideProviderButtons(ViewHolder holder) {
        holder.btnAccept.setVisibility(View.GONE);
        holder.btnReject.setVisibility(View.GONE);
        holder.btnComplete.setVisibility(View.GONE);
    }

    private void setStatusColor(TextView tvStatus, Booking.BookingStatus status) {
        int color;
        switch (status) {
            case PENDING:
                color = android.R.color.holo_orange_dark;
                break;
            case ACCEPTED:
            case CONFIRMED:
                color = android.R.color.holo_blue_dark;
                break;
            case COMPLETED:
                color = android.R.color.holo_green_dark;
                break;
            case CANCELLED_BY_CUSTOMER:
            case CANCELLED_BY_PROVIDER:
            case REJECTED:
            case TIMEOUT:
                color = android.R.color.holo_red_dark;
                break;
            default:
                color = android.R.color.darker_gray;
        }
        tvStatus.setTextColor(tvStatus.getContext().getResources().getColor(color));
    }

    private Service getServiceById(String serviceId) {
        // Simplified - in production, you'd have a method in DatabaseHelper
        // For now, return null or implement a getServiceById method
        return null;
    }

    @Override
    public int getItemCount() {
        return bookings.size();
    }

    static class ViewHolder extends RecyclerView.ViewHolder {
        TextView tvServiceName, tvDateTime, tvStatus, tvTotalPrice, tvOtherParty;
        Button btnAccept, btnReject, btnComplete, btnCancel;

        ViewHolder(View itemView) {
            super(itemView);
            tvServiceName = itemView.findViewById(R.id.tv_service_name);
            tvDateTime = itemView.findViewById(R.id.tv_datetime);
            tvStatus = itemView.findViewById(R.id.tv_status);
            tvTotalPrice = itemView.findViewById(R.id.tv_total_price);
            tvOtherParty = itemView.findViewById(R.id.tv_other_party);
            btnAccept = itemView.findViewById(R.id.btn_accept);
            btnReject = itemView.findViewById(R.id.btn_reject);
            btnComplete = itemView.findViewById(R.id.btn_complete);
            btnCancel = itemView.findViewById(R.id.btn_cancel);
        }
    }
}