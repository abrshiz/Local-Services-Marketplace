package com.example.localservicemarketplace.database;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

import com.example.localservicemarketplace.models.*;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class DatabaseHelper extends SQLiteOpenHelper {

    // Database Info
    private static final String DATABASE_NAME = "LocalServiceMarketplace.db";
    private static final int DATABASE_VERSION = 1;

    // Table Names
    private static final String TABLE_USERS = "users";
    private static final String TABLE_CATEGORIES = "categories";
    private static final String TABLE_SERVICES = "services";
    private static final String TABLE_BOOKINGS = "bookings";
    private static final String TABLE_REVIEWS = "reviews";
    private static final String TABLE_PAYMENTS = "payments";
    private static final String TABLE_TIME_SLOTS = "time_slots";
    private static final String TABLE_ADDRESSES = "addresses";

    // Common Column Names
    private static final String KEY_CREATED_AT = "created_at";
    private static final String KEY_UPDATED_AT = "updated_at";
    private static final String KEY_DESCRIPTION = "description";
    private static final String KEY_IS_ACTIVE = "is_active";

    // User Table Columns
    private static final String KEY_USER_ID = "user_id";
    private static final String KEY_NAME = "name";
    private static final String KEY_EMAIL = "email";
    private static final String KEY_PASSWORD_HASH = "password_hash";
    private static final String KEY_PHONE = "phone";
    private static final String KEY_ROLE = "role";

    // Category Table Columns
    private static final String KEY_CATEGORY_ID = "category_id";
    private static final String KEY_CATEGORY_NAME = "category_name";
    private static final String KEY_ICON_URL = "icon_url";

    // Service Table Columns
    private static final String KEY_SERVICE_ID = "service_id";
    private static final String KEY_PROVIDER_ID = "provider_id";
    private static final String KEY_TITLE = "title";
    private static final String KEY_PRICE_TYPE = "price_type";
    private static final String KEY_BASE_PRICE = "base_price";

    // Booking Table Columns
    private static final String KEY_BOOKING_ID = "booking_id";
    private static final String KEY_CUSTOMER_ID = "customer_id";
    private static final String KEY_SCHEDULED_TIME = "scheduled_time";
    private static final String KEY_END_TIME = "end_time";
    private static final String KEY_STATUS = "status";
    private static final String KEY_TOTAL_PRICE = "total_price";
    private static final String KEY_ADDRESS_ID = "address_id";
    private static final String KEY_NOTES = "notes";

    // Review Table Columns
    private static final String KEY_REVIEW_ID = "review_id";
    private static final String KEY_REVIEWER_ID = "reviewer_id";
    private static final String KEY_RATING = "rating";
    private static final String KEY_COMMENT = "comment";

    public DatabaseHelper(Context context) {
        super(context, DATABASE_NAME, null, DATABASE_VERSION);
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
        // Simple implementation: Create tables here (table creation SQL strings omitted for brevity)
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        db.execSQL("DROP TABLE IF EXISTS " + TABLE_USERS);
        db.execSQL("DROP TABLE IF EXISTS " + TABLE_CATEGORIES);
        db.execSQL("DROP TABLE IF EXISTS " + TABLE_SERVICES);
        db.execSQL("DROP TABLE IF EXISTS " + TABLE_BOOKINGS);
        db.execSQL("DROP TABLE IF EXISTS " + TABLE_REVIEWS);
        db.execSQL("DROP TABLE IF EXISTS " + TABLE_PAYMENTS);
        db.execSQL("DROP TABLE IF EXISTS " + TABLE_TIME_SLOTS);
        db.execSQL("DROP TABLE IF EXISTS " + TABLE_ADDRESSES);
        onCreate(db);
    }

    // --- User Operations ---

    public long addUser(User user) {
        SQLiteDatabase db = this.getWritableDatabase();
        ContentValues values = new ContentValues();
        values.put(KEY_USER_ID, user.getUserId());
        values.put(KEY_NAME, user.getName());
        values.put(KEY_EMAIL, user.getEmail());
        values.put(KEY_PASSWORD_HASH, user.getPasswordHash());
        values.put(KEY_PHONE, user.getPhone());
        values.put(KEY_ROLE, user.getRole().toString());
        values.put(KEY_IS_ACTIVE, 1);
        values.put(KEY_CREATED_AT, user.getCreatedAt().getTime());
        values.put(KEY_UPDATED_AT, user.getUpdatedAt().getTime());
        return db.insert(TABLE_USERS, null, values);
    }

    private User cursorToUser(Cursor cursor) {
        User user = new User();
        user.setUserId(cursor.getString(cursor.getColumnIndexOrThrow(KEY_USER_ID)));
        user.setName(cursor.getString(cursor.getColumnIndexOrThrow(KEY_NAME)));
        user.setEmail(cursor.getString(cursor.getColumnIndexOrThrow(KEY_EMAIL)));
        user.setPasswordHash(cursor.getString(cursor.getColumnIndexOrThrow(KEY_PASSWORD_HASH)));
        user.setPhone(cursor.getString(cursor.getColumnIndexOrThrow(KEY_PHONE)));
        user.setRole(User.UserRole.valueOf(cursor.getString(cursor.getColumnIndexOrThrow(KEY_ROLE))));
        user.setCreatedAt(new Date(cursor.getLong(cursor.getColumnIndexOrThrow(KEY_CREATED_AT))));
        user.setUpdatedAt(new Date(cursor.getLong(cursor.getColumnIndexOrThrow(KEY_UPDATED_AT))));
        return user;
    }

    // --- Service Operations ---

    public List<Service> getAllActiveServices() {
        List<Service> services = new ArrayList<>();
        SQLiteDatabase db = this.getReadableDatabase();
        Cursor cursor = db.query(TABLE_SERVICES, null, KEY_IS_ACTIVE + "=1", null, null, null, null);
        if (cursor != null && cursor.moveToFirst()) {
            do {
                services.add(cursorToService(cursor));
            } while (cursor.moveToNext());
            cursor.close();
        }
        return services;
    }

    private Service cursorToService(Cursor cursor) {
        Service service = new Service();
        service.setServiceId(cursor.getString(cursor.getColumnIndexOrThrow(KEY_SERVICE_ID)));
        service.setProviderId(cursor.getString(cursor.getColumnIndexOrThrow(KEY_PROVIDER_ID)));
        service.setCategoryId(cursor.getString(cursor.getColumnIndexOrThrow(KEY_CATEGORY_ID)));
        service.setTitle(cursor.getString(cursor.getColumnIndexOrThrow(KEY_TITLE)));
        service.setDescription(cursor.getString(cursor.getColumnIndexOrThrow(KEY_DESCRIPTION)));
        service.setPriceType(Service.PriceType.valueOf(cursor.getString(cursor.getColumnIndexOrThrow(KEY_PRICE_TYPE))));
        service.setBasePrice(new BigDecimal(cursor.getString(cursor.getColumnIndexOrThrow(KEY_BASE_PRICE))));
        service.setActive(cursor.getInt(cursor.getColumnIndexOrThrow(KEY_IS_ACTIVE)) == 1);
        service.setCreatedAt(new Date(cursor.getLong(cursor.getColumnIndexOrThrow(KEY_CREATED_AT))));
        service.setUpdatedAt(new Date(cursor.getLong(cursor.getColumnIndexOrThrow(KEY_UPDATED_AT))));
        return service;
    }

    // --- Category Operations ---

    public List<ServiceCategory> getAllCategories() {
        List<ServiceCategory> categories = new ArrayList<>();
        SQLiteDatabase db = this.getReadableDatabase();
        Cursor cursor = db.query(TABLE_CATEGORIES, null, null, null, null, null, null);
        if (cursor != null && cursor.moveToFirst()) {
            do {
                ServiceCategory category = new ServiceCategory();
                category.setCategoryId(cursor.getString(cursor.getColumnIndexOrThrow(KEY_CATEGORY_ID)));
                category.setName(cursor.getString(cursor.getColumnIndexOrThrow(KEY_CATEGORY_NAME)));
                category.setDescription(cursor.getString(cursor.getColumnIndexOrThrow(KEY_DESCRIPTION)));
                category.setIconUrl(cursor.getString(cursor.getColumnIndexOrThrow(KEY_ICON_URL)));
                category.setCreatedAt(new Date(cursor.getLong(cursor.getColumnIndexOrThrow(KEY_CREATED_AT))));
                categories.add(category);
            } while (cursor.moveToNext());
            cursor.close();
        }
        return categories;
    }

    // --- Booking Operations ---

    private Booking cursorToBooking(Cursor cursor) {
        Booking booking = new Booking();
        booking.setBookingId(cursor.getString(cursor.getColumnIndexOrThrow(KEY_BOOKING_ID)));
        booking.setCustomerId(cursor.getString(cursor.getColumnIndexOrThrow(KEY_CUSTOMER_ID)));
        booking.setProviderId(cursor.getString(cursor.getColumnIndexOrThrow(KEY_PROVIDER_ID)));
        booking.setServiceId(cursor.getString(cursor.getColumnIndexOrThrow(KEY_SERVICE_ID)));
        booking.setScheduledTime(new Date(cursor.getLong(cursor.getColumnIndexOrThrow(KEY_SCHEDULED_TIME))));
        booking.setEndTime(new Date(cursor.getLong(cursor.getColumnIndexOrThrow(KEY_END_TIME))));
        booking.setStatus(Booking.BookingStatus.valueOf(cursor.getString(cursor.getColumnIndexOrThrow(KEY_STATUS))));
        booking.setTotalPrice(new BigDecimal(cursor.getString(cursor.getColumnIndexOrThrow(KEY_TOTAL_PRICE))));
        booking.setAddressId(cursor.getString(cursor.getColumnIndexOrThrow(KEY_ADDRESS_ID)));
        booking.setNotes(cursor.getString(cursor.getColumnIndexOrThrow(KEY_NOTES)));
        booking.setCreatedAt(new Date(cursor.getLong(cursor.getColumnIndexOrThrow(KEY_CREATED_AT))));
        booking.setUpdatedAt(new Date(cursor.getLong(cursor.getColumnIndexOrThrow(KEY_UPDATED_AT))));
        return booking;
    }
}