-- Additive MySQL schema for settlement APIs. Apply to the application database
-- when automatic schema updates are disabled. Existing data is not modified.
CREATE TABLE IF NOT EXISTS expenses (
    id BIGINT NOT NULL AUTO_INCREMENT,
    trip_id BIGINT NOT NULL,
    title VARCHAR(100) NOT NULL,
    amount BIGINT NOT NULL,
    payer_id BIGINT NOT NULL,
    place_name VARCHAR(100),
    expense_date DATE NOT NULL,
    PRIMARY KEY (id),
    INDEX idx_expenses_trip (trip_id, expense_date),
    CONSTRAINT fk_expenses_trip FOREIGN KEY (trip_id) REFERENCES trips(id),
    CONSTRAINT fk_expenses_payer FOREIGN KEY (payer_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS expense_participants (
    expense_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    PRIMARY KEY (expense_id, user_id),
    CONSTRAINT fk_expense_participants_expense FOREIGN KEY (expense_id) REFERENCES expenses(id) ON DELETE CASCADE,
    CONSTRAINT fk_expense_participants_user FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS settlement_statuses (
    trip_id BIGINT NOT NULL,
    completed_at DATETIME(6),
    PRIMARY KEY (trip_id),
    CONSTRAINT fk_settlement_status_trip FOREIGN KEY (trip_id) REFERENCES trips(id)
);
