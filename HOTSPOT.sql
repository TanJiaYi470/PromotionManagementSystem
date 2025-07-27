/*
COURSE CODE: UCCD2303 
PROGRAMME: CS
GROUP NUMBER: G055
GROUP LEADER NAME & EMAIL: Lee Cheng Jun & chengjun5487@1utar.my
MEMBER 2 NAME: Brian Lee Zhen Hui
MEMBER 3 NAME: Ng Che Te
MEMBER 4 NAME: Tan Jia Yi
Submission date and time (DD-MON-YY): 29-April-2025, 5pm

Part 1 group work: Template save as "G055.sql"

Refer to the format of Northwoods.sql as an example for group sql script submission
*/


-- Drop tables
DROP TABLE Feedback CASCADE CONSTRAINTS;
DROP TABLE PromoAnalytics CASCADE CONSTRAINTS;
DROP TABLE Voucher_Item CASCADE CONSTRAINTS;
DROP TABLE Voucher CASCADE CONSTRAINTS;
DROP TABLE Item_Detail CASCADE CONSTRAINTS;
DROP TABLE PromoItem CASCADE CONSTRAINTS;
DROP TABLE MarketingEvent CASCADE CONSTRAINTS;
DROP TABLE AdSchedule CASCADE CONSTRAINTS;
DROP TABLE Promotion_Segment CASCADE CONSTRAINTS;
DROP TABLE Promotion CASCADE CONSTRAINTS;
DROP TABLE CS_Membership CASCADE CONSTRAINTS;
DROP TABLE CustomerSegment CASCADE CONSTRAINTS;
DROP TABLE LoyaltyProgram CASCADE CONSTRAINTS;
DROP TABLE Customer CASCADE CONSTRAINTS;

-- 1. CUSTOMER
CREATE TABLE Customer (
  CustomerID     NUMBER         PRIMARY KEY,
  Name           VARCHAR2(100)  NOT NULL,
  Email          VARCHAR2(100)  UNIQUE  NOT NULL,
  DOB            DATE,
  Phone          VARCHAR2(20),
  LoyaltyPoints  NUMBER         DEFAULT 0
);

-- 2. LOYALTYPROGRAM
CREATE TABLE LoyaltyProgram (
  ProgramID    NUMBER         PRIMARY KEY,
  CustomerID   NUMBER         NOT NULL,
  Points       NUMBER         DEFAULT 0,
  Tier         VARCHAR2(20),
  JoinDate     DATE           DEFAULT SYSDATE,
  CONSTRAINT FK_LP_Customer
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

-- 3. PROMOTION
CREATE TABLE Promotion (
  PromoID   NUMBER         PRIMARY KEY,
  Title     VARCHAR2(150)  NOT NULL,
  StartDate DATE           NOT NULL,
  EndDate   DATE           NOT NULL,
  Type      VARCHAR2(50),
  Status    VARCHAR2(20)   DEFAULT 'PLANNED'
);

-- 4. PROMOITEM 
CREATE TABLE PromoItem (
  ItemID    NUMBER         PRIMARY KEY,
  PromoID   NUMBER         NOT NULL,
  ItemType  VARCHAR2(50),
  Stock     NUMBER         DEFAULT 0,
  Price     NUMBER(10,2)   DEFAULT 0,
  CONSTRAINT FK_PI_Promotion
    FOREIGN KEY (PromoID) REFERENCES Promotion(PromoID)
);

-- 5. ITEM_DETAIL
CREATE TABLE Item_Detail (
  PromoID      NUMBER        NOT NULL,
  ItemID       NUMBER        NOT NULL,
  DiscountRate NUMBER(5,2)   DEFAULT 0,
  StockLimit   NUMBER,
  CONSTRAINT PK_Item_Detail PRIMARY KEY (PromoID, ItemID),
  CONSTRAINT FK_ID_Promotion 
    FOREIGN KEY (PromoID) REFERENCES Promotion(PromoID),
  CONSTRAINT FK_ID_PromoItem
    FOREIGN KEY (ItemID) REFERENCES PromoItem(ItemID)
);

-- 6. VOUCHER
CREATE TABLE Voucher (
  CodeID        NUMBER        PRIMARY KEY,
  PromoID       NUMBER        NOT NULL,
  Code          VARCHAR2(50)  UNIQUE NOT NULL,
  DiscountValue NUMBER(5,2)   DEFAULT 0,
  ValidFrom     DATE,
  ValidTo       DATE,
  Used          CHAR(1)       DEFAULT 'N',
  CONSTRAINT FK_Voucher_Promo 
    FOREIGN KEY (PromoID) REFERENCES Promotion(PromoID)
);

-- 7. VOUCHER_ITEM
CREATE TABLE Voucher_Item (
  ItemID             NUMBER     NOT NULL,
  CodeID             NUMBER     NOT NULL,
  MaxUsagePerItem    NUMBER     DEFAULT 1,
  IsExclusive        CHAR(1)    DEFAULT 'N',
  MinPurchaseAmount  NUMBER(10,2),
  CONSTRAINT PK_Voucher_Item PRIMARY KEY (ItemID, CodeID),
  CONSTRAINT FK_VI_PromoItem
    FOREIGN KEY (ItemID) REFERENCES PromoItem(ItemID),
  CONSTRAINT FK_VI_Voucher
    FOREIGN KEY (CodeID) REFERENCES Voucher(CodeID)
);

-- 8. MARKETINGEVENT
CREATE TABLE MarketingEvent (
  EventID    NUMBER        PRIMARY KEY,
  PromoID    NUMBER        NOT NULL,
  EventName  VARCHAR2(100) NOT NULL,
  Location   VARCHAR2(100),
  EventDate  DATE,
  EventTime  TIMESTAMP,
  CONSTRAINT FK_ME_Promotion
    FOREIGN KEY (PromoID) REFERENCES Promotion(PromoID)
);

-- 9. ADSCHEDULE
CREATE TABLE AdSchedule (
  AdID         NUMBER        PRIMARY KEY,
  PromoID      NUMBER        NOT NULL,
  Platform     VARCHAR2(50),
  StartTime    TIMESTAMP,
  EndTime      TIMESTAMP,
  ContentType  VARCHAR2(50),
  CONSTRAINT FK_AS_Promotion
    FOREIGN KEY (PromoID) REFERENCES Promotion(PromoID)
);

--10. PROMOANALYTICS
CREATE TABLE PromoAnalytics (
  ReportID       NUMBER        PRIMARY KEY,
  PromoID        NUMBER        NOT NULL,
  SalesImpact    VARCHAR2(200),
  RedemptionRate NUMBER(5,2),
  FeedbackSummary VARCHAR2(400),
  CONSTRAINT FK_PA_Promotion
    FOREIGN KEY (PromoID) REFERENCES Promotion(PromoID)
);

--11. FEEDBACK
CREATE TABLE Feedback (
  FeedbackID  NUMBER       PRIMARY KEY,
  CustomerID  NUMBER       NOT NULL,
  PromoID     NUMBER       NOT NULL,
  Comments    VARCHAR2(400),
  Rating      NUMBER(1)    CHECK (Rating BETWEEN 1 AND 5),
  FeedbackDate DATE        DEFAULT SYSDATE,
  CONSTRAINT FK_FB_Customer
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
  CONSTRAINT FK_FB_Promotion
    FOREIGN KEY (PromoID) REFERENCES Promotion(PromoID)
);

--12. CUSTOMERSEGMENT
CREATE TABLE CustomerSegment (
  SegmentID   NUMBER        PRIMARY KEY,
  ProgramID   NUMBER        NOT NULL,
  Criteria    VARCHAR2(200),
  Description VARCHAR2(400),
  CONSTRAINT FK_CS_LoyaltyProgram
    FOREIGN KEY (ProgramID) REFERENCES LoyaltyProgram(ProgramID)
);

--13. PROMOTION_SEGMENT
CREATE TABLE Promotion_Segment (
  PromoID       NUMBER   NOT NULL,
  SegmentID     NUMBER   NOT NULL,
  PriorityLevel NUMBER   DEFAULT 0,
  Channel       VARCHAR2(50),
  CONSTRAINT PK_Promo_Segment PRIMARY KEY (PromoID, SegmentID),
  CONSTRAINT FK_PS_Promotion
    FOREIGN KEY (PromoID) REFERENCES Promotion(PromoID),
  CONSTRAINT FK_PS_Segment
    FOREIGN KEY (SegmentID) REFERENCES CustomerSegment(SegmentID)
);

--14. CS_MEMBERSHIP
CREATE TABLE CS_Membership (
  CustomerID  NUMBER    NOT NULL,
  SegmentID   NUMBER    NOT NULL,
  DateJoined  DATE      DEFAULT SYSDATE,
  Status      VARCHAR2(20),
  CONSTRAINT PK_CS_Membership PRIMARY KEY (CustomerID, SegmentID),
  CONSTRAINT FK_CSM_Customer
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
  CONSTRAINT FK_CSM_Segment
    FOREIGN KEY (SegmentID) REFERENCES CustomerSegment(SegmentID)
);


-- CUSTOMER
INSERT INTO Customer VALUES (1, 'Alice Tan', 'alice.tan@gmail.com', DATE '1990-04-12', '012-3456789', 100);
INSERT INTO Customer VALUES (2, 'Bob Lim', 'bob.lim@yahoo.com', DATE '1985-11-05', '013-9876543', 250);
INSERT INTO Customer VALUES (3, 'Chen Wei', 'chen.wei@hotmail.com', DATE '1992-06-30', '014-1112233', 50);
INSERT INTO Customer VALUES (4, 'Dina Rossi', 'dina.rossi@gmail.com', DATE '1988-12-20', '015-4445566', 0);
INSERT INTO Customer VALUES (5, 'Evan Lee', 'evan.lee@yahoo.com', DATE '1995-02-14', '016-7778899', 300);
INSERT INTO Customer VALUES (6, 'Fiona Ng', 'fiona.ng@gmail.com', DATE '1991-07-22', '017-8887766', 120);
INSERT INTO Customer VALUES (7, 'Gavin Tan', 'gavin.tan@hotmail.com', DATE '1987-03-15', '018-3322110', 80);
INSERT INTO Customer VALUES (8, 'Hana Lim', 'hana.lim@yahoo.com', DATE '1993-09-05', '019-9988776', 200);
INSERT INTO Customer VALUES (9, 'Ivan Choo', 'ivan.choo@gmail.com', DATE '1989-01-10', '011-6677889', 40);
INSERT INTO Customer VALUES (10, 'Jasmine Ho', 'jasmine.ho@hotmail.com', DATE '1996-11-25', '012-5566778', 180);
INSERT INTO Customer VALUES (11, 'Kelvin Teo', 'kelvin.teo@gmail.com', DATE '1984-04-30', '013-4455667', 300);
INSERT INTO Customer VALUES (12, 'Laura Goh', 'laura.goh@yahoo.com', DATE '1992-08-18', '014-2233445', 70);
INSERT INTO Customer VALUES (13, 'Marcus Lee', 'marcus.lee@gmail.com', DATE '1990-05-01', '015-5566778', 90);
INSERT INTO Customer VALUES (14, 'Natalie Tan', 'natalie.tan@hotmail.com', DATE '1995-12-15', '016-3344556', 210);
INSERT INTO Customer VALUES (15, 'Oscar Wong', 'oscar.wong@gmail.com', DATE '1988-02-20', '017-8899001', 60);
INSERT INTO Customer VALUES (16, 'Pauline Cheng', 'pauline.cheng@yahoo.com', DATE '1991-06-08', '018-6677885', 130);
INSERT INTO Customer VALUES (17, 'Quentin Ong', 'quentin.ong@hotmail.com', DATE '1994-10-11', '019-7766554', 20);
INSERT INTO Customer VALUES (18, 'Rachel Yap', 'rachel.yap@gmail.com', DATE '1993-01-17', '011-3344557', 110);
INSERT INTO Customer VALUES (19, 'Samuel Low', 'samuel.low@gmail.com', DATE '1987-08-22', '012-4455667', 240);
INSERT INTO Customer VALUES (20, 'Tina Khoo', 'tina.khoo@hotmail.com', DATE '1995-09-30', '013-7788990', 150);

-- LOYALTYPROGRAM
INSERT INTO LoyaltyProgram VALUES (10, 1, 100, 'Silver', DATE '2024-01-01');
INSERT INTO LoyaltyProgram VALUES (11, 2, 250, 'Gold', DATE '2023-05-15');
INSERT INTO LoyaltyProgram VALUES (12, 3, 50, 'Bronze', DATE '2024-03-10');
INSERT INTO LoyaltyProgram VALUES (13, 4, 0, 'Bronze', DATE '2025-02-01');
INSERT INTO LoyaltyProgram VALUES (14, 5, 300, 'Gold', DATE '2023-10-20');
INSERT INTO LoyaltyProgram VALUES (15, 6, 120, 'Silver', DATE '2024-02-05');
INSERT INTO LoyaltyProgram VALUES (16, 7, 80, 'Bronze', DATE '2024-01-18');
INSERT INTO LoyaltyProgram VALUES (17, 8, 200, 'Silver', DATE '2023-11-11');
INSERT INTO LoyaltyProgram VALUES (18, 9, 40, 'Bronze', DATE '2024-04-12');
INSERT INTO LoyaltyProgram VALUES (19, 10, 180, 'Silver', DATE '2023-06-08');
INSERT INTO LoyaltyProgram VALUES (20, 11, 300, 'Gold', DATE '2022-12-30');
INSERT INTO LoyaltyProgram VALUES (21, 12, 70, 'Bronze', DATE '2024-02-20');
INSERT INTO LoyaltyProgram VALUES (22, 13, 90, 'Bronze', DATE '2023-08-15');
INSERT INTO LoyaltyProgram VALUES (23, 14, 210, 'Gold', DATE '2023-03-01');
INSERT INTO LoyaltyProgram VALUES (24, 15, 60, 'Bronze', DATE '2024-05-19');
INSERT INTO LoyaltyProgram VALUES (25, 16, 130, 'Silver', DATE '2023-09-07');
INSERT INTO LoyaltyProgram VALUES (26, 17, 20, 'Bronze', DATE '2024-06-22');
INSERT INTO LoyaltyProgram VALUES (27, 18, 110, 'Silver', DATE '2023-11-18');
INSERT INTO LoyaltyProgram VALUES (28, 19, 240, 'Gold', DATE '2023-01-29');
INSERT INTO LoyaltyProgram VALUES (29, 20, 150, 'Silver', DATE '2023-07-14');

-- PROMOTION
INSERT INTO Promotion VALUES (100, 'Spring Fling', DATE '2025-03-01', DATE '2025-03-31', 'Voucher', 'ACTIVE');
INSERT INTO Promotion VALUES (101, 'Burger Week', DATE '2025-04-01', DATE '2025-04-07', 'Item', 'PLANNED');
INSERT INTO Promotion VALUES (102, 'Kids Workshop', DATE '2025-05-10', DATE '2025-05-10', 'Event', 'PLANNED');
INSERT INTO Promotion VALUES (103, 'Summer Combo', DATE '2025-06-01', DATE '2025-06-30', 'Voucher', 'PLANNED');
INSERT INTO Promotion VALUES (104, 'Mother''s Day Special', DATE '2025-05-01', DATE '2025-05-31', 'Event', 'PLANNED');
INSERT INTO Promotion VALUES (105, 'Holiday Bonanza', DATE '2025-11-01', DATE '2025-11-30', 'Voucher', 'PLANNED');
INSERT INTO Promotion VALUES (106, 'Family Day', DATE '2025-08-15', DATE '2025-08-15', 'Event', 'PLANNED');
INSERT INTO Promotion VALUES (107, 'Tech Gadget Week', DATE '2025-09-05', DATE '2025-09-12', 'Item', 'PLANNED');
INSERT INTO Promotion VALUES (108, 'Back to School', DATE '2025-07-25', DATE '2025-08-10', 'Voucher', 'ACTIVE');
INSERT INTO Promotion VALUES (109, 'Movie Mania', DATE '2025-10-01', DATE '2025-10-15', 'Item', 'PLANNED');
INSERT INTO Promotion VALUES (110, 'Halloween Bash', DATE '2025-10-25', DATE '2025-10-31', 'Event', 'PLANNED');
INSERT INTO Promotion VALUES (111, 'Black Friday Sale', DATE '2025-11-28', DATE '2025-11-30', 'Voucher', 'PLANNED');
INSERT INTO Promotion VALUES (112, 'Cyber Monday', DATE '2025-12-02', DATE '2025-12-02', 'Voucher', 'PLANNED');
INSERT INTO Promotion VALUES (113, 'New Year Gala', DATE '2025-12-31', DATE '2026-01-01', 'Event', 'PLANNED');
INSERT INTO Promotion VALUES (114, 'Online Flash Sale', DATE '2025-08-05', DATE '2025-08-05', 'Item', 'PLANNED');
INSERT INTO Promotion VALUES (115, 'Early Bird Discount', DATE '2025-05-01', DATE '2025-05-03', 'Voucher', 'PLANNED');
INSERT INTO Promotion VALUES (116, 'Ramadan Special', DATE '2025-03-15', DATE '2025-04-15', 'Voucher', 'PLANNED');
INSERT INTO Promotion VALUES (117, 'Mother''s Day Treat', DATE '2025-05-10', DATE '2025-05-10', 'Event', 'PLANNED');
INSERT INTO Promotion VALUES (118, 'Fathers Appreciation', DATE '2025-06-20', DATE '2025-06-20', 'Event', 'PLANNED');
INSERT INTO Promotion VALUES (119, 'Mega Online Week', DATE '2025-07-20', DATE '2025-07-27', 'Item', 'PLANNED');

-- PROMOITEM
INSERT INTO PromoItem VALUES (200, 101, 'Burger', 500, 5.50);
INSERT INTO PromoItem VALUES (201, 101, 'Fries', 500, 2.00);
INSERT INTO PromoItem VALUES (202, 104, 'Online Burger', 999, 4.50);
INSERT INTO PromoItem VALUES (203, 104, 'Online Drink', 999, 1.50);
INSERT INTO PromoItem VALUES (204, 100, 'Value Set', 999, 8.00);
INSERT INTO PromoItem VALUES (205, 105, 'Holiday Set', 100, 12.00);
INSERT INTO PromoItem VALUES (206, 107, 'Tech Bag', 50, 45.00);
INSERT INTO PromoItem VALUES (207, 107, 'Wireless Earbuds', 80, 70.00);
INSERT INTO PromoItem VALUES (208, 108, 'Backpack', 200, 40.00);
INSERT INTO PromoItem VALUES (209, 109, 'Movie Ticket', 300, 8.00);
INSERT INTO PromoItem VALUES (210, 109, 'Popcorn Combo', 400, 5.00);
INSERT INTO PromoItem VALUES (211, 114, 'Flash Drive', 150, 10.00);
INSERT INTO PromoItem VALUES (212, 114, 'Keyboard', 70, 25.00);
INSERT INTO PromoItem VALUES (213, 119, 'Online Headphones', 999, 55.00);
INSERT INTO PromoItem VALUES (214, 119, 'Bluetooth Speaker', 999, 75.00);
INSERT INTO PromoItem VALUES (215, 100, 'Coupon Deal', 999, 3.00);
INSERT INTO PromoItem VALUES (216, 103, 'Meal Combo', 150, 7.50);
INSERT INTO PromoItem VALUES (217, 105, 'Gift Hamper', 60, 50.00);
INSERT INTO PromoItem VALUES (218, 107, 'Smartwatch', 30, 120.00);
INSERT INTO PromoItem VALUES (219, 119, 'Gaming Mouse', 90, 60.00);

-- ITEM_DETAIL
INSERT INTO Item_Detail VALUES (101, 200, 10, 100);
INSERT INTO Item_Detail VALUES (101, 201, 0, 300);
INSERT INTO Item_Detail VALUES (104, 202, 15, 999);
INSERT INTO Item_Detail VALUES (104, 203, 20, 999);
INSERT INTO Item_Detail VALUES (100, 204, 5, 50);
INSERT INTO Item_Detail VALUES (105, 205, 8, 120);
INSERT INTO Item_Detail VALUES (107, 206, 12, 60);
INSERT INTO Item_Detail VALUES (107, 207, 15, 100);
INSERT INTO Item_Detail VALUES (108, 208, 10, 250);
INSERT INTO Item_Detail VALUES (109, 209, 5, 400);
INSERT INTO Item_Detail VALUES (109, 210, 0, 500);
INSERT INTO Item_Detail VALUES (114, 211, 20, 180);
INSERT INTO Item_Detail VALUES (114, 212, 10, 90);
INSERT INTO Item_Detail VALUES (119, 213, 18, 999);
INSERT INTO Item_Detail VALUES (119, 214, 15, 999);
INSERT INTO Item_Detail VALUES (100, 215, 5, 100);
INSERT INTO Item_Detail VALUES (103, 216, 10, 130);
INSERT INTO Item_Detail VALUES (105, 217, 8, 70);
INSERT INTO Item_Detail VALUES (107, 218, 20, 40);
INSERT INTO Item_Detail VALUES (119, 219, 12, 100);

-- VOUCHER
INSERT INTO Voucher VALUES (300, 100, 'SPRING25', 25, DATE '2025-03-01', DATE '2025-03-31', 'N');
INSERT INTO Voucher VALUES (301, 103, 'SUMMER10', 10, DATE '2025-06-01', DATE '2025-06-30', 'N');
INSERT INTO Voucher VALUES (302, 100, 'SPRING50', 50, DATE '2025-03-01', DATE '2025-03-15', 'N');
INSERT INTO Voucher VALUES (303, 100, 'SPRING5', 5, DATE '2025-03-10', DATE '2025-03-31', 'N');
INSERT INTO Voucher VALUES (304, 103, 'SUMMER20', 20, DATE '2025-06-01', DATE '2025-06-30', 'N');
INSERT INTO Voucher VALUES (305, 105, 'HOLIDAY30', 30, DATE '2025-11-01', DATE '2025-11-30', 'N');
INSERT INTO Voucher VALUES (306, 108, 'BACK2SCHOOL', 15, DATE '2025-07-25', DATE '2025-08-10', 'N');
INSERT INTO Voucher VALUES (307, 111, 'BLACKFRIDAY50', 50, DATE '2025-11-28', DATE '2025-11-30', 'N');
INSERT INTO Voucher VALUES (308, 112, 'CYBERMONDAY20', 20, DATE '2025-12-02', DATE '2025-12-02', 'N');
INSERT INTO Voucher VALUES (309, 115, 'EARLY10', 10, DATE '2025-05-01', DATE '2025-05-03', 'N');
INSERT INTO Voucher VALUES (310, 116, 'RAMADAN15', 15, DATE '2025-03-15', DATE '2025-04-15', 'N');
INSERT INTO Voucher VALUES (311, 119, 'MEGAWEEK30', 30, DATE '2025-07-20', DATE '2025-07-27', 'N');
INSERT INTO Voucher VALUES (312, 105, 'FESTIVE40', 40, DATE '2025-11-01', DATE '2025-11-30', 'N');
INSERT INTO Voucher VALUES (313, 100, 'SPRING15', 15, DATE '2025-03-01', DATE '2025-03-31', 'N');
INSERT INTO Voucher VALUES (314, 103, 'SUMMER5', 5, DATE '2025-06-01', DATE '2025-06-30', 'N');
INSERT INTO Voucher VALUES (315, 116, 'RAMADAN5', 5, DATE '2025-03-15', DATE '2025-04-15', 'N');
INSERT INTO Voucher VALUES (316, 119, 'ONLINE10', 10, DATE '2025-07-20', DATE '2025-07-27', 'N');
INSERT INTO Voucher VALUES (317, 105, 'HOLIDAY10', 10, DATE '2025-11-01', DATE '2025-11-30', 'N');
INSERT INTO Voucher VALUES (318, 115, 'EARLY5', 5, DATE '2025-05-01', DATE '2025-05-03', 'N');
INSERT INTO Voucher VALUES (319, 119, 'FLASH20', 20, DATE '2025-07-20', DATE '2025-07-27', 'N');


-- VOUCHER_ITEM
INSERT INTO Voucher_Item VALUES (204, 300, 1, 'Y', 20);
INSERT INTO Voucher_Item VALUES (204, 302, 1, 'N', 0);
INSERT INTO Voucher_Item VALUES (200, 303, 2, 'N', 10);
INSERT INTO Voucher_Item VALUES (202, 301, 1, 'Y', 15);
INSERT INTO Voucher_Item VALUES (203, 304, 1, 'N', 0);
INSERT INTO Voucher_Item VALUES (205, 305, 1, 'Y', 25);
INSERT INTO Voucher_Item VALUES (208, 306, 1, 'N', 5);
INSERT INTO Voucher_Item VALUES (209, 307, 1, 'Y', 30);
INSERT INTO Voucher_Item VALUES (210, 307, 2, 'N', 20);
INSERT INTO Voucher_Item VALUES (211, 308, 1, 'Y', 10);
INSERT INTO Voucher_Item VALUES (212, 308, 1, 'N', 5);
INSERT INTO Voucher_Item VALUES (213, 311, 1, 'Y', 20);
INSERT INTO Voucher_Item VALUES (214, 311, 1, 'N', 15);
INSERT INTO Voucher_Item VALUES (215, 313, 2, 'N', 5);
INSERT INTO Voucher_Item VALUES (216, 314, 1, 'Y', 5);
INSERT INTO Voucher_Item VALUES (217, 312, 1, 'Y', 40);
INSERT INTO Voucher_Item VALUES (218, 316, 1, 'N', 10);
INSERT INTO Voucher_Item VALUES (219, 319, 1, 'Y', 15);
INSERT INTO Voucher_Item VALUES (206, 317, 1, 'N', 20);
INSERT INTO Voucher_Item VALUES (207, 318, 1, 'Y', 10);

-- MARKETINGEVENT
INSERT INTO MarketingEvent VALUES (400, 100, 'Spring Launch Party', 'Mall A', DATE '2025-03-01', TIMESTAMP '2025-03-01 14:00:00');
INSERT INTO MarketingEvent VALUES (401, 101, 'Burger Festival', 'Mall B', DATE '2025-04-01', TIMESTAMP '2025-04-01 12:00:00');
INSERT INTO MarketingEvent VALUES (402, 102, 'Kids Activity Zone', 'Park C', DATE '2025-05-10', TIMESTAMP '2025-05-10 10:00:00');
INSERT INTO MarketingEvent VALUES (403, 103, 'Summer Combo Party', 'Beach D', DATE '2025-06-05', TIMESTAMP '2025-06-05 15:00:00');
INSERT INTO MarketingEvent VALUES (404, 104, 'Mother''s Day Special', 'Mall E', DATE '2025-05-12', TIMESTAMP '2025-05-12 11:00:00');
INSERT INTO MarketingEvent VALUES (405, 100, 'Spring Contest', 'Outlet A', DATE '2025-03-02', TIMESTAMP '2025-03-02 10:00:00');
INSERT INTO MarketingEvent VALUES (406, 101, 'Burger Eating Contest', 'Outlet B', DATE '2025-04-02', TIMESTAMP '2025-04-02 13:00:00');
INSERT INTO MarketingEvent VALUES (407, 102, 'Kids Coloring', 'Mall C', DATE '2025-05-11', TIMESTAMP '2025-05-11 11:00:00');
INSERT INTO MarketingEvent VALUES (408, 103, 'Summer Dance', 'Beach F', DATE '2025-06-06', TIMESTAMP '2025-06-06 16:00:00');
INSERT INTO MarketingEvent VALUES (409, 104, 'Mom and Me Special', 'Mall G', DATE '2025-05-13', TIMESTAMP '2025-05-13 10:00:00');
INSERT INTO MarketingEvent VALUES (410, 100, 'Spring Pop-up', 'Pop-up Store', DATE '2025-03-03', TIMESTAMP '2025-03-03 12:00:00');
INSERT INTO MarketingEvent VALUES (411, 101, 'Burger Combo Fiesta', 'Mall H', DATE '2025-04-03', TIMESTAMP '2025-04-03 11:00:00');
INSERT INTO MarketingEvent VALUES (412, 102, 'Kids Fun Walk', 'Park I', DATE '2025-05-12', TIMESTAMP '2025-05-12 09:00:00');
INSERT INTO MarketingEvent VALUES (413, 103, 'Beach Carnival', 'Beach J', DATE '2025-06-07', TIMESTAMP '2025-06-07 17:00:00');
INSERT INTO MarketingEvent VALUES (414, 104, 'Mother''s Day Tea', 'Hotel K', DATE '2025-05-14', TIMESTAMP '2025-05-14 14:00:00');
INSERT INTO MarketingEvent VALUES (415, 100, 'Spring Surprise', 'Mall L', DATE '2025-03-04', TIMESTAMP '2025-03-04 13:00:00');
INSERT INTO MarketingEvent VALUES (416, 101, 'Burger Launch', 'Restaurant M', DATE '2025-04-04', TIMESTAMP '2025-04-04 14:00:00');
INSERT INTO MarketingEvent VALUES (417, 102, 'Kids Party', 'Mall N', DATE '2025-05-13', TIMESTAMP '2025-05-13 15:00:00');
INSERT INTO MarketingEvent VALUES (418, 103, 'Summer BBQ', 'Beach O', DATE '2025-06-08', TIMESTAMP '2025-06-08 18:00:00');
INSERT INTO MarketingEvent VALUES (419, 104, 'Mom Gift Fair', 'Mall P', DATE '2025-05-15', TIMESTAMP '2025-05-15 12:00:00');

-- ADSCHEDULE
INSERT INTO AdSchedule VALUES (500, 100, 'Facebook', TIMESTAMP '2025-02-25 00:00:00', TIMESTAMP '2025-03-01 23:59:59', 'Banner');
INSERT INTO AdSchedule VALUES (501, 101, 'Instagram', TIMESTAMP '2025-03-28 00:00:00', TIMESTAMP '2025-04-07 23:59:59', 'Story');
INSERT INTO AdSchedule VALUES (502, 102, 'Billboard', TIMESTAMP '2025-05-01 00:00:00', TIMESTAMP '2025-05-10 23:59:59', 'Video');
INSERT INTO AdSchedule VALUES (503, 103, 'YouTube', TIMESTAMP '2025-05-25 00:00:00', TIMESTAMP '2025-06-10 23:59:59', 'Video');
INSERT INTO AdSchedule VALUES (504, 104, 'Push Notification', TIMESTAMP '2025-05-01 00:00:00', TIMESTAMP '2025-05-10 23:59:59', 'Popup');
INSERT INTO AdSchedule VALUES (505, 100, 'Radio', TIMESTAMP '2025-02-20 00:00:00', TIMESTAMP '2025-03-01 23:59:59', 'Audio');
INSERT INTO AdSchedule VALUES (506, 101, 'In-App Banner', TIMESTAMP '2025-03-29 00:00:00', TIMESTAMP '2025-04-06 23:59:59', 'Popup');
INSERT INTO AdSchedule VALUES (507, 102, 'Kids TV', TIMESTAMP '2025-05-02 00:00:00', TIMESTAMP '2025-05-10 23:59:59', 'Video');
INSERT INTO AdSchedule VALUES (508, 103, 'Summer Billboard', TIMESTAMP '2025-06-01 00:00:00', TIMESTAMP '2025-06-30 23:59:59', 'Banner');
INSERT INTO AdSchedule VALUES (509, 104, 'Mothers App', TIMESTAMP '2025-05-05 00:00:00', TIMESTAMP '2025-05-12 23:59:59', 'Story');
INSERT INTO AdSchedule VALUES (510, 100, 'Instagram Reel', TIMESTAMP '2025-02-26 00:00:00', TIMESTAMP '2025-03-01 23:59:59', 'Video');
INSERT INTO AdSchedule VALUES (511, 101, 'Website Promo', TIMESTAMP '2025-03-30 00:00:00', TIMESTAMP '2025-04-05 23:59:59', 'Banner');
INSERT INTO AdSchedule VALUES (512, 102, 'Kids Online', TIMESTAMP '2025-05-03 00:00:00', TIMESTAMP '2025-05-11 23:59:59', 'Popup');
INSERT INTO AdSchedule VALUES (513, 103, 'YouTube Summer', TIMESTAMP '2025-05-27 00:00:00', TIMESTAMP '2025-06-10 23:59:59', 'Video');
INSERT INTO AdSchedule VALUES (514, 104, 'Gift Push', TIMESTAMP '2025-05-02 00:00:00', TIMESTAMP '2025-05-10 23:59:59', 'Popup');
INSERT INTO AdSchedule VALUES (515, 100, 'Outdoor Banners', TIMESTAMP '2025-02-27 00:00:00', TIMESTAMP '2025-03-01 23:59:59', 'Banner');
INSERT INTO AdSchedule VALUES (516, 101, 'Email Campaign', TIMESTAMP '2025-03-31 00:00:00', TIMESTAMP '2025-04-06 23:59:59', 'Text');
INSERT INTO AdSchedule VALUES (517, 102, 'Online Contest', TIMESTAMP '2025-05-04 00:00:00', TIMESTAMP '2025-05-12 23:59:59', 'Popup');
INSERT INTO AdSchedule VALUES (518, 103, 'Summer Radio', TIMESTAMP '2025-06-02 00:00:00', TIMESTAMP '2025-06-15 23:59:59', 'Audio');
INSERT INTO AdSchedule VALUES (519, 104, 'Special Ads', TIMESTAMP '2025-05-06 00:00:00', TIMESTAMP '2025-05-12 23:59:59', 'Story');

-- PROMOANALYTICS
INSERT INTO PromoAnalytics VALUES (600, 100, '+15% sales', 12.5, 'Mostly positive');
INSERT INTO PromoAnalytics VALUES (601, 101, '+8% sales', 5.0, 'Good uptake');
INSERT INTO PromoAnalytics VALUES (602, 102, 'N/A', 0.0, 'Hands-on feedback only');
INSERT INTO PromoAnalytics VALUES (603, 103, '+10% sales', 8.8, 'Mixed reviews');
INSERT INTO PromoAnalytics VALUES (604, 104, '+20% web orders', 15.0, 'Excellent');
INSERT INTO PromoAnalytics VALUES (605, 100, '+5% social engagement', 4.5, 'Okay response');
INSERT INTO PromoAnalytics VALUES (606, 101, '+6% customer traffic', 5.8, 'Encouraging');
INSERT INTO PromoAnalytics VALUES (607, 102, '+7% family signups', 6.2, 'Positive');
INSERT INTO PromoAnalytics VALUES (608, 103, '+12% combo meals sold', 10.0, 'Great');
INSERT INTO PromoAnalytics VALUES (609, 104, '+9% gifts purchased', 7.5, 'Good');
INSERT INTO PromoAnalytics VALUES (610, 100, '+11% app installs', 9.8, 'Very good');
INSERT INTO PromoAnalytics VALUES (611, 101, '+13% burger orders', 11.5, 'Very happy');
INSERT INTO PromoAnalytics VALUES (612, 102, '+4% event check-ins', 3.5, 'Average');
INSERT INTO PromoAnalytics VALUES (613, 103, '+6% ice cream sales', 5.7, 'Fair');
INSERT INTO PromoAnalytics VALUES (614, 104, '+15% restaurant bookings', 14.5, 'Excellent');
INSERT INTO PromoAnalytics VALUES (615, 100, '+3% voucher use', 2.9, 'Mild');
INSERT INTO PromoAnalytics VALUES (616, 101, '+8% burger combo redemptions', 7.2, 'Good');
INSERT INTO PromoAnalytics VALUES (617, 102, '+5% kids feedback', 4.8, 'Positive');
INSERT INTO PromoAnalytics VALUES (618, 103, '+10% customer returns', 8.9, 'Very good');
INSERT INTO PromoAnalytics VALUES (619, 104, '+12% Mother''s Day sales', 10.5, 'Fantastic');

-- FEEDBACK
INSERT INTO Feedback VALUES (700, 1, 100, 'Great deal!', 5, DATE '2025-03-05');
INSERT INTO Feedback VALUES (701, 2, 100, NULL, 3, DATE '2025-03-10');
INSERT INTO Feedback VALUES (702, 3, 101, 'Loved the burger', 5, DATE '2025-04-03');
INSERT INTO Feedback VALUES (703, 4, 103, 'Not enough items', 2, DATE '2025-06-10');
INSERT INTO Feedback VALUES (704, 5, 104, 'Very convenient', 4, DATE '2025-07-05');
INSERT INTO Feedback VALUES (705, 6, 100, 'Spring event was fun', 5, DATE '2025-03-07');
INSERT INTO Feedback VALUES (706, 7, 101, 'Burger could be bigger', 3, DATE '2025-04-04');
INSERT INTO Feedback VALUES (707, 8, 102, 'Kids loved the games', 5, DATE '2025-05-10');
INSERT INTO Feedback VALUES (708, 9, 102, 'Nice family event', 4, DATE '2025-05-10');
INSERT INTO Feedback VALUES (709, 10, 103, 'Combo was worth it', 5, DATE '2025-06-02');
INSERT INTO Feedback VALUES (710, 11, 103, 'More variety needed', 3, DATE '2025-06-12');
INSERT INTO Feedback VALUES (711, 12, 104, 'Perfect Mother''s Day gift', 5, DATE '2025-05-08');
INSERT INTO Feedback VALUES (712, 13, 100, 'Spring promo average', 3, DATE '2025-03-15');
INSERT INTO Feedback VALUES (713, 14, 101, 'Burger week was tasty', 4, DATE '2025-04-06');
INSERT INTO Feedback VALUES (714, 15, 102, 'Enjoyed kids activities', 5, DATE '2025-05-11');
INSERT INTO Feedback VALUES (715, 16, 104, 'Gift fair awesome', 5, DATE '2025-05-09');
INSERT INTO Feedback VALUES (716, 17, 100, 'Love the vouchers', 5, DATE '2025-03-08');
INSERT INTO Feedback VALUES (717, 18, 103, 'Good deals overall', 4, DATE '2025-06-04');
INSERT INTO Feedback VALUES (718, 19, 101, 'Burger deal fair', 3, DATE '2025-04-05');
INSERT INTO Feedback VALUES (719, 20, 104, 'Mother loved the surprise', 5, DATE '2025-05-10');


-- CUSTOMERSEGMENT
INSERT INTO CustomerSegment VALUES (800, 10, 'Points >=100', 'Silver and above');
INSERT INTO CustomerSegment VALUES (801, 11, 'Points >=200', 'Gold members');
INSERT INTO CustomerSegment VALUES (802, 12, 'Joined last 30 days', 'Newbies');
INSERT INTO CustomerSegment VALUES (803, 14, 'Tier = Gold', 'Top tier');
INSERT INTO CustomerSegment VALUES (804, 13, 'Points = 0', 'Inactive');
INSERT INTO CustomerSegment VALUES (805, 15, 'Points between 50-100', 'Moderate spenders');
INSERT INTO CustomerSegment VALUES (806, 16, 'Points >=80', 'Active members');
INSERT INTO CustomerSegment VALUES (807, 17, 'Points <=20', 'Low activity');
INSERT INTO CustomerSegment VALUES (808, 18, 'Joined after Jan 2024', 'Recent joiners');
INSERT INTO CustomerSegment VALUES (809, 19, 'Points between 200-300', 'High-value customers');
INSERT INTO CustomerSegment VALUES (810, 20, 'Points >=150', 'Potential Gold');
INSERT INTO CustomerSegment VALUES (811, 10, 'Birthday month', 'Special offer group');
INSERT INTO CustomerSegment VALUES (812, 11, 'Top 10% Loyalty', 'VIP members');
INSERT INTO CustomerSegment VALUES (813, 12, 'Below 100 Points', 'At-risk');
INSERT INTO CustomerSegment VALUES (814, 13, 'No purchases', 'Non-active');
INSERT INTO CustomerSegment VALUES (815, 14, 'Frequent feedback', 'Engaged users');
INSERT INTO CustomerSegment VALUES (816, 15, 'Voucher users', 'Coupon Lovers');
INSERT INTO CustomerSegment VALUES (817, 16, 'New parents', 'Family group');
INSERT INTO CustomerSegment VALUES (818, 17, 'Students', 'Young adults');
INSERT INTO CustomerSegment VALUES (819, 18, 'Seniors', 'Senior citizens');

-- PROMOTION_SEGMENT
INSERT INTO Promotion_Segment VALUES (100, 800, 1, 'Email');
INSERT INTO Promotion_Segment VALUES (100, 801, 2, 'SMS');
INSERT INTO Promotion_Segment VALUES (101, 802, 1, 'In-App');
INSERT INTO Promotion_Segment VALUES (102, 803, 1, 'Email');
INSERT INTO Promotion_Segment VALUES (103, 804, 1, 'Website');
INSERT INTO Promotion_Segment VALUES (104, 805, 1, 'Email');
INSERT INTO Promotion_Segment VALUES (100, 806, 2, 'SMS');
INSERT INTO Promotion_Segment VALUES (101, 807, 1, 'In-App');
INSERT INTO Promotion_Segment VALUES (102, 808, 1, 'Email');
INSERT INTO Promotion_Segment VALUES (103, 809, 1, 'Website');
INSERT INTO Promotion_Segment VALUES (104, 810, 1, 'Facebook');
INSERT INTO Promotion_Segment VALUES (100, 811, 1, 'Instagram');
INSERT INTO Promotion_Segment VALUES (101, 812, 1, 'Direct Call');
INSERT INTO Promotion_Segment VALUES (102, 813, 2, 'SMS');
INSERT INTO Promotion_Segment VALUES (103, 814, 1, 'Email');
INSERT INTO Promotion_Segment VALUES (104, 815, 2, 'Website');
INSERT INTO Promotion_Segment VALUES (100, 816, 1, 'In-App');
INSERT INTO Promotion_Segment VALUES (101, 817, 1, 'Email');
INSERT INTO Promotion_Segment VALUES (102, 818, 1, 'Social Media');
INSERT INTO Promotion_Segment VALUES (103, 819, 1, 'Email');

-- CS_MEMBERSHIP
INSERT INTO CS_Membership VALUES (1, 800, DATE '2024-01-01', 'Active');
INSERT INTO CS_Membership VALUES (2, 801, DATE '2023-05-15', 'Active');
INSERT INTO CS_Membership VALUES (3, 802, DATE '2024-03-10', 'Active');
INSERT INTO CS_Membership VALUES (5, 803, DATE '2023-10-20', 'Active');
INSERT INTO CS_Membership VALUES (4, 804, DATE '2025-02-01', 'Pending');
INSERT INTO CS_Membership VALUES (6, 805, DATE '2024-02-15', 'Active');
INSERT INTO CS_Membership VALUES (7, 806, DATE '2024-01-12', 'Active');
INSERT INTO CS_Membership VALUES (8, 807, DATE '2024-04-11', 'Active');
INSERT INTO CS_Membership VALUES (9, 808, DATE '2024-04-25', 'Active');
INSERT INTO CS_Membership VALUES (10, 809, DATE '2023-06-09', 'Active');
INSERT INTO CS_Membership VALUES (11, 810, DATE '2022-11-20', 'Active');
INSERT INTO CS_Membership VALUES (12, 811, DATE '2023-12-30', 'Active');
INSERT INTO CS_Membership VALUES (13, 812, DATE '2024-02-21', 'Active');
INSERT INTO CS_Membership VALUES (14, 813, DATE '2023-07-16', 'Inactive');
INSERT INTO CS_Membership VALUES (15, 814, DATE '2023-08-22', 'Inactive');
INSERT INTO CS_Membership VALUES (16, 815, DATE '2024-04-28', 'Active');
INSERT INTO CS_Membership VALUES (17, 816, DATE '2023-09-15', 'Active');
INSERT INTO CS_Membership VALUES (18, 817, DATE '2024-05-19', 'Active');
INSERT INTO CS_Membership VALUES (19, 818, DATE '2024-05-05', 'Active');
INSERT INTO CS_Membership VALUES (20, 819, DATE '2024-06-11', 'Pending');

COMMIT;