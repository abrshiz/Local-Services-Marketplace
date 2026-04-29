package com.example.localservicemarketplace.models;

import java.math.BigDecimal;
import java.util.Date;
import java.util.UUID;

public class Booking {
    private String bookingId;
    private String customerId;
    private String providerId;
    private String serviceId;
    private Date scheduledTime;
    private Date endTime;
    private BookingStatus status;
    private BigDecimal totalPrice;
    private String addressId;
    private String notes;
    private Date createdAt;
    private Date updatedAt;

    public enum BookingStatus {
        PENDING,
        ACCEPTED,
        CONFIRMED,
        COMPLETED,
        CANCELLED_BY_CUSTOMER,
        CANCELLED_BY_PROVIDER,
        REJECTED,
        TIMEOUT
    }

    public Booking() {
        this.bookingId = UUID.randomUUID().toString();
        this.createdAt = new Date();
        this.updatedAt = new Date();
        this.status = BookingStatus.PENDING;
    }

    // Getters and Setters
    public String getBookingId() { return bookingId; }
    public void setBookingId(String bookingId) { this.bookingId = bookingId; }
    public String getCustomerId() { return customerId; }
    public void setCustomerId(String customerId) { this.customerId = customerId; }
    public String getProviderId() { return providerId; }
    public void setProviderId(String providerId) { this.providerId = providerId; }
    public String getServiceId() { return serviceId; }
    public void setServiceId(String serviceId) { this.serviceId = serviceId; }
    public Date getScheduledTime() { return scheduledTime; }
    public void setScheduledTime(Date scheduledTime) { this.scheduledTime = scheduledTime; }
    public Date getEndTime() { return endTime; }
    public void setEndTime(Date endTime) { this.endTime = endTime; }
    public BookingStatus getStatus() { return status; }
    public void setStatus(BookingStatus status) { this.status = status; }
    public BigDecimal getTotalPrice() { return totalPrice; }
    public void setTotalPrice(BigDecimal totalPrice) { this.totalPrice = totalPrice; }
    public String getAddressId() { return addressId; }
    public void setAddressId(String addressId) { this.addressId = addressId; }
    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
    public Date getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Date updatedAt) { this.updatedAt = updatedAt; }
}