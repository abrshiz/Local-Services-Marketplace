package com.example.localservicemarketplace.models;

import java.util.Date;
import java.util.UUID;

public class Review {
    private String reviewId;
    private String bookingId;
    private String reviewerId;
    private int rating;
    private String comment;
    private Date createdAt;
    private Date updatedAt;

    public Review() {
        this.reviewId = UUID.randomUUID().toString();
        this.createdAt = new Date();
        this.updatedAt = new Date();
    }

    public Review(String bookingId, String reviewerId, int rating, String comment) {
        this();
        this.bookingId = bookingId;
        this.reviewerId = reviewerId;
        this.rating = rating;
        this.comment = comment;
    }

    // Getters and Setters
    public String getReviewId() { return reviewId; }
    public void setReviewId(String reviewId) { this.reviewId = reviewId; }
    public String getBookingId() { return bookingId; }
    public void setBookingId(String bookingId) { this.bookingId = bookingId; }
    public String getReviewerId() { return reviewerId; }
    public void setReviewerId(String reviewerId) { this.reviewerId = reviewerId; }
    public int getRating() { return rating; }
    public void setRating(int rating) { this.rating = rating; }
    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }
    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
    public Date getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Date updatedAt) { this.updatedAt = updatedAt; }
}