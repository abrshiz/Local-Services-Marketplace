package com.example.localservicemarketplace.models;

import java.util.Date;
import java.util.UUID;

public class TimeSlot {
    private String slotId;
    private String providerId;
    private Date startTime;
    private Date endTime;
    private boolean isAvailable;
    private Date createdAt;

    public TimeSlot() {
        this.slotId = UUID.randomUUID().toString();
        this.createdAt = new Date();
        this.isAvailable = true;
    }

    // Getters and Setters
    public String getSlotId() { return slotId; }
    public void setSlotId(String slotId) { this.slotId = slotId; }
    public String getProviderId() { return providerId; }
    public void setProviderId(String providerId) { this.providerId = providerId; }
    public Date getStartTime() { return startTime; }
    public void setStartTime(Date startTime) { this.startTime = startTime; }
    public Date getEndTime() { return endTime; }
    public void setEndTime(Date endTime) { this.endTime = endTime; }
    public boolean isAvailable() { return isAvailable; }
    public void setAvailable(boolean available) { isAvailable = available; }
    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
}