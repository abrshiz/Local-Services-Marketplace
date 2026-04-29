package com.example.localservicemarketplace.models;

import java.math.BigDecimal;
import java.util.Date;
import java.util.UUID;

public class Service {
    private String serviceId;
    private String providerId;
    private String categoryId;
    private String title;
    private String description;
    private PriceType priceType;
    private BigDecimal basePrice;
    private boolean isActive;
    private Date createdAt;
    private Date updatedAt;

    public enum PriceType {
        FIXED,
        HOURLY,
        PER_VISIT
    }

    public Service() {
        this.serviceId = UUID.randomUUID().toString();
        this.createdAt = new Date();
        this.updatedAt = new Date();
        this.isActive = true;
    }

    // Getters and Setters
    public String getServiceId() { return serviceId; }
    public void setServiceId(String serviceId) { this.serviceId = serviceId; }
    public String getProviderId() { return providerId; }
    public void setProviderId(String providerId) { this.providerId = providerId; }
    public String getCategoryId() { return categoryId; }
    public void setCategoryId(String categoryId) { this.categoryId = categoryId; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public PriceType getPriceType() { return priceType; }
    public void setPriceType(PriceType priceType) { this.priceType = priceType; }
    public BigDecimal getBasePrice() { return basePrice; }
    public void setBasePrice(BigDecimal basePrice) { this.basePrice = basePrice; }
    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }
    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
    public Date getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Date updatedAt) { this.updatedAt = updatedAt; }
}