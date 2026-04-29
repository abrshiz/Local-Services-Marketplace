package com.example.localservicemarketplace.models;

import java.math.BigDecimal;
import java.util.Date;
import java.util.UUID;

public class Payment {
    private String paymentId;
    private String bookingId;
    private BigDecimal amount;
    private PaymentStatus status;
    private PaymentMethod method;
    private String transactionRef;
    private Date paidAt;
    private Date createdAt;

    public enum PaymentStatus {
        PENDING,
        CONFIRMED,
        COMPLETED,
        CANCELED,
        REFUNDED
    }

    public enum PaymentMethod {
        CARD,
        WALLET,
        CASH_ON_SERVICE,
        OTHER
    }

    public Payment() {
        this.paymentId = UUID.randomUUID().toString();
        this.createdAt = new Date();
        this.status = PaymentStatus.PENDING;
    }

    // Getters and Setters
    public String getPaymentId() { return paymentId; }
    public void setPaymentId(String paymentId) { this.paymentId = paymentId; }
    public String getBookingId() { return bookingId; }
    public void setBookingId(String bookingId) { this.bookingId = bookingId; }
    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }
    public PaymentStatus getStatus() { return status; }
    public void setStatus(PaymentStatus status) { this.status = status; }
    public PaymentMethod getMethod() { return method; }
    public void setMethod(PaymentMethod method) { this.method = method; }
    public String getTransactionRef() { return transactionRef; }
    public void setTransactionRef(String transactionRef) { this.transactionRef = transactionRef; }
    public Date getPaidAt() { return paidAt; }
    public void setPaidAt(Date paidAt) { this.paidAt = paidAt; }
    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
}