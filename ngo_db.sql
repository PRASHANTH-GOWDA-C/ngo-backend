CREATE DATABASE IF NOT EXISTS ngo_db;
USE ngo_db;

CREATE TABLE Donor (
  donor_id    INT AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(100) NOT NULL,
  email       VARCHAR(100) UNIQUE NOT NULL,
  phone       VARCHAR(15),
  type        ENUM('individual', 'corporate') DEFAULT 'individual',
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE NGO (
  ngo_id          INT AUTO_INCREMENT PRIMARY KEY,
  name            VARCHAR(150) NOT NULL,
  registration_no VARCHAR(50) UNIQUE NOT NULL,
  verified_status ENUM('pending', 'verified', 'rejected') DEFAULT 'pending',
  trust_score     DECIMAL(3,1) DEFAULT 5.0 CHECK (trust_score BETWEEN 0 AND 10),
  created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Category (
  category_id INT AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(80) UNIQUE NOT NULL
);

CREATE TABLE Campaign (
  campaign_id   INT AUTO_INCREMENT PRIMARY KEY,
  ngo_id        INT NOT NULL,
  title         VARCHAR(200) NOT NULL,
  description   TEXT,
  goal_amount   DECIMAL(12,2) NOT NULL CHECK (goal_amount > 0),
  raised_amount DECIMAL(12,2) DEFAULT 0.00,
  deadline      DATE NOT NULL,
  status        ENUM('active', 'completed', 'cancelled') DEFAULT 'active',
  FOREIGN KEY (ngo_id) REFERENCES NGO(ngo_id)
);

CREATE TABLE Campaign_Category (
  campaign_id INT,
  category_id INT,
  PRIMARY KEY (campaign_id, category_id),
  FOREIGN KEY (campaign_id) REFERENCES Campaign(campaign_id),
  FOREIGN KEY (category_id) REFERENCES Category(category_id)
);

CREATE TABLE Donation_Pool (
  pool_id      INT AUTO_INCREMENT PRIMARY KEY,
  name         VARCHAR(150) NOT NULL,
  total_amount DECIMAL(12,2) DEFAULT 0.00
);

CREATE TABLE Distribution_Rule (
  rule_id    INT AUTO_INCREMENT PRIMARY KEY,
  pool_id    INT NOT NULL,
  ngo_id     INT NOT NULL,
  percentage DECIMAL(5,2) NOT NULL CHECK (percentage > 0 AND percentage <= 100),
  FOREIGN KEY (pool_id) REFERENCES Donation_Pool(pool_id),
  FOREIGN KEY (ngo_id) REFERENCES NGO(ngo_id)
);

CREATE TABLE Donation (
  donation_id INT AUTO_INCREMENT PRIMARY KEY,
  donor_id    INT NOT NULL,
  campaign_id INT,
  pool_id     INT,
  amount      DECIMAL(10,2) NOT NULL CHECK (amount > 0),
  donated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (donor_id) REFERENCES Donor(donor_id),
  FOREIGN KEY (campaign_id) REFERENCES Campaign(campaign_id),
  FOREIGN KEY (pool_id) REFERENCES Donation_Pool(pool_id),
  CONSTRAINT chk_target CHECK (
    (campaign_id IS NOT NULL AND pool_id IS NULL) OR
    (campaign_id IS NULL AND pool_id IS NOT NULL)
  )
);


CREATE TABLE Expense (
  expense_id  INT AUTO_INCREMENT PRIMARY KEY,
  campaign_id INT NOT NULL,
  amount      DECIMAL(10,2) NOT NULL CHECK (amount > 0),
  description VARCHAR(255),
  proof_url   VARCHAR(500),
  recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (campaign_id) REFERENCES Campaign(campaign_id)
);

CREATE TABLE Donation_History (
  donor_id      INT,
  category_id   INT,
  total_donated DECIMAL(12,2) DEFAULT 0.00,
  PRIMARY KEY (donor_id, category_id),
  FOREIGN KEY (donor_id) REFERENCES Donor(donor_id),
  FOREIGN KEY (category_id) REFERENCES Category(category_id)
);

CREATE TABLE Volunteer (
  volunteer_id INT AUTO_INCREMENT PRIMARY KEY,
  name         VARCHAR(100) NOT NULL,
  email        VARCHAR(100) UNIQUE NOT NULL,
  skill        VARCHAR(100)
);

CREATE TABLE Event (
  event_id    INT AUTO_INCREMENT PRIMARY KEY,
  ngo_id      INT NOT NULL,
  title       VARCHAR(200) NOT NULL,
  event_date  DATE NOT NULL,
  location    VARCHAR(200),
  FOREIGN KEY (ngo_id) REFERENCES NGO(ngo_id)
);

CREATE TABLE Participation (
  volunteer_id INT,
  event_id     INT,
  joined_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (volunteer_id, event_id),
  FOREIGN KEY (volunteer_id) REFERENCES Volunteer(volunteer_id),
  FOREIGN KEY (event_id) REFERENCES Event(event_id)
);

DELIMITER $$

-- Auto-update campaign raised_amount on donation
CREATE TRIGGER trg_update_campaign_raised
AFTER INSERT ON Donation
FOR EACH ROW
BEGIN
  IF NEW.campaign_id IS NOT NULL THEN
    UPDATE Campaign
    SET raised_amount = raised_amount + NEW.amount
    WHERE campaign_id = NEW.campaign_id;
  END IF;
  IF NEW.pool_id IS NOT NULL THEN
    UPDATE Donation_Pool
    SET total_amount = total_amount + NEW.amount
    WHERE pool_id = NEW.pool_id;
  END IF;
END$$

DELIMITER ;

CREATE VIEW donor_transparency_report AS
SELECT
  d.name         AS donor_name,
  c.title        AS campaign,
  dn.amount,
  dn.donated_at,
  e.description  AS expense_description,
  e.amount       AS expense_amount
FROM Donation dn
JOIN Donor d    ON dn.donor_id    = d.donor_id
JOIN Campaign c ON dn.campaign_id = c.campaign_id
LEFT JOIN Expense e ON e.campaign_id = c.campaign_id;

CREATE VIEW active_campaigns AS
SELECT
  c.campaign_id,
  c.title,
  n.name         AS ngo_name,
  c.goal_amount,
  c.raised_amount,
  ROUND((c.raised_amount / c.goal_amount) * 100, 1) AS percent_funded,
  c.deadline
FROM Campaign c
JOIN NGO n ON c.ngo_id = n.ngo_id
WHERE c.status = 'active' AND c.deadline >= CURDATE();

INSERT INTO Category (name) VALUES
  ('Education'), ('Health'), ('Environment'), ('Disaster Relief'), ('Animal Welfare');

INSERT INTO NGO (name, registration_no, verified_status, trust_score) VALUES
  ('Smile Foundation', 'NGO-001', 'verified', 8.5),
  ('GreenEarth Trust', 'NGO-002', 'verified', 7.2);

INSERT INTO Donor (name, email, type) VALUES
  ('Rahul Sharma', 'rahul@example.com', 'individual'),
  ('TechCorp India', 'csr@techcorp.in', 'corporate');

INSERT INTO Campaign (ngo_id, title, goal_amount, deadline) VALUES
  (1, 'Books for Rural Schools', 100000, '2025-12-31'),
  (2, 'Tree Plantation Drive',  50000,  '2025-10-31');

INSERT INTO Campaign_Category VALUES (1,1), (2,3);

INSERT INTO Donation_Pool (name) VALUES ('General Fund');

INSERT INTO Distribution_Rule (pool_id, ngo_id, percentage) VALUES
  (1, 1, 60), (1, 2, 40);
