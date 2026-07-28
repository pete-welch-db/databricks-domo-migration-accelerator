-- Schema for Domain: sales | Business: Automotive | Version: v1_mvm
-- Generated on: 2026-05-07 02:20:10

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `automotive_ecm`.`sales` COMMENT 'Sales operations including lead management, opportunity tracking, quote generation, order capture, and sales performance analytics. Manages MSRP (Manufacturer Suggested Retail Price), incentive programs, fleet sales, and commercial vehicle contracts. Tracks sales pipeline, conversion rates, and regional sales performance. Integrates with dealer networks and Salesforce Automotive Cloud for unified sales execution across direct and indirect channels. Interfaces with SAP SD.';

-- ========= TABLES =========
CREATE OR REPLACE TABLE `automotive_ecm`.`sales`.`opportunity` (
    `opportunity_id` BIGINT COMMENT 'Unique identifier for the sales opportunity record. Primary key.',
    `campaign_id` BIGINT COMMENT 'Reference to the marketing campaign that generated this opportunity, if applicable.',
    `company_code_id` BIGINT COMMENT 'Foreign key linking to finance.company_code. Business justification: Opportunities must track which legal entity will book revenue for multi-entity OEMs. Critical for revenue planning, territory-to-entity mapping, and cross-border sales compliance in global automotive ',
    `dealership_id` BIGINT COMMENT 'Reference to the dealership managing this opportunity.',
    `party_id` BIGINT COMMENT 'Reference to the prospect or customer associated with this opportunity.',
    `model_id` BIGINT COMMENT 'Foreign key linking to vehicle.model. Business justification: Opportunity tracking by model enables sales forecasting, market analysis, and model performance dashboards.',
    `opportunity_party_id` BIGINT COMMENT 'Reference to the prospect or customer associated with this opportunity.',
    `rep_id` BIGINT COMMENT 'Reference to the sales representative or account owner assigned to this opportunity.',
    `opportunity_sales_representative_rep_id` BIGINT COMMENT 'Reference to the sales representative or account owner assigned to this opportunity.',
    `opportunity_vehicle_model_id` BIGINT COMMENT 'Reference to the specific vehicle configuration or model of interest for this opportunity.',
    `regulatory_requirement_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_requirement. Business justification: Opportunity evaluation checks applicable regulatory requirements (e.g., emissions, safety) for the target market.',
    `sales_territory_id` BIGINT COMMENT 'Foreign key linking to sales.sales_territory. Business justification: Opportunities are associated with sales territories (opportunity has territory STRING). Normalizing this to a FK to sales_territory enables proper territory-opportunity association, territory-level pi',
    `vehicle_program_id` BIGINT COMMENT 'Foreign key linking to engineering.vehicle_program. Business justification: Required for Opportunity Management report to align sales opportunities with engineering program schedules, ensuring capacity planning.',
    `vin_registry_id` BIGINT COMMENT 'Reference to the specific vehicle configuration or model of interest for this opportunity.',
    `actual_close_date` DATE COMMENT 'Actual date when the opportunity was closed (won or lost).',
    `competitor_brand` STRING COMMENT 'Competitor brand or OEM that the customer is also considering, if known.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the opportunity record was first created in the system.',
    `delivery_location` STRING COMMENT 'Preferred delivery location or dealership for vehicle handover.',
    `discount_amount` DECIMAL(18,2) COMMENT 'Total discount amount applied to the opportunity, including dealer discounts and manufacturer incentives.',
    `estimated_value` DECIMAL(18,2) COMMENT 'Estimated total deal value including vehicle price, options, accessories, and services.',
    `expected_close_date` DATE COMMENT 'Anticipated date when the opportunity is expected to close (either won or lost).',
    `exterior_color` STRING COMMENT 'Preferred exterior color for the vehicle.',
    `financing_type` STRING COMMENT 'Type of financing or payment method the customer intends to use.. Valid values are `cash|finance|lease|balloon|fleet_contract`',
    `fiscal_year` STRING COMMENT 'Fiscal year in which the opportunity is expected to close, used for sales forecasting and quota tracking.. Valid values are `^FY[0-9]{4}$`',
    `fleet_size` STRING COMMENT 'Number of vehicles in the fleet opportunity, applicable for fleet and commercial sales.',
    `incentive_amount` DECIMAL(18,2) COMMENT 'Total manufacturer incentive amount applicable to this opportunity.',
    `interior_color` STRING COMMENT 'Preferred interior color or trim for the vehicle.',
    `is_active` BOOLEAN COMMENT 'Indicates whether the opportunity is currently active (open) or closed.',
    `is_won` BOOLEAN COMMENT 'Indicates whether the opportunity was closed as won (successful sale).',
    `last_activity_date` DATE COMMENT 'Date of the most recent sales activity or interaction related to this opportunity.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the opportunity record was last modified.',
    `lead_source` STRING COMMENT 'Original channel or source through which the opportunity was generated. [ENUM-REF-CANDIDATE: web|phone|email|walk_in|referral|event|advertising|social_media|partner — 9 candidates stripped; promote to reference product]',
    `loss_reason` STRING COMMENT 'Primary reason why the opportunity was lost, if applicable. [ENUM-REF-CANDIDATE: price|product_fit|competitor|timing|financing|no_response|other — 7 candidates stripped; promote to reference product]',
    `model_year` STRING COMMENT 'Model year of the vehicle of interest in this opportunity.. Valid values are `^MY[0-9]{4}$`',
    `msrp` DECIMAL(18,2) COMMENT 'Manufacturer Suggested Retail Price for the vehicle configuration of interest.',
    `next_follow_up_date` DATE COMMENT 'Scheduled date for the next follow-up activity with the prospect.',
    `notes` STRING COMMENT 'Free-text notes and comments about the opportunity, customer preferences, and sales interactions.',
    `opportunity_name` STRING COMMENT 'Descriptive name of the opportunity, typically including prospect name and vehicle of interest.',
    `opportunity_number` STRING COMMENT 'Business-facing unique identifier for the opportunity, typically auto-generated and used in communications with dealers and sales teams.. Valid values are `^OPP-[0-9]{8}$`',
    `opportunity_type` STRING COMMENT 'Classification of the opportunity based on customer segment and purchase type.. Valid values are `retail|fleet|commercial|government|employee_purchase|demo`',
    `powertrain_type` STRING COMMENT 'Type of powertrain for the vehicle of interest: ICE (Internal Combustion Engine), HEV (Hybrid Electric Vehicle), PHEV (Plug-in Hybrid Electric Vehicle), BEV (Battery Electric Vehicle), FCEV (Fuel Cell Electric Vehicle).. Valid values are `ICE|HEV|PHEV|BEV|FCEV`',
    `priority` STRING COMMENT 'Priority level assigned to this opportunity based on strategic importance, deal size, or customer value.. Valid values are `low|medium|high|critical`',
    `probability` DECIMAL(18,2) COMMENT 'Estimated probability of closing this opportunity successfully, expressed as a percentage (0-100).',
    `quote_date` DATE COMMENT 'Date when the quote was generated, if applicable.',
    `quote_generated` BOOLEAN COMMENT 'Indicates whether a formal quote has been generated for this opportunity.',
    `region` STRING COMMENT 'Geographic sales region where this opportunity is being managed.',
    `sales_stage` STRING COMMENT 'Current stage of the opportunity in the sales pipeline, reflecting progression from initial contact through close. [ENUM-REF-CANDIDATE: lead|qualification|needs_analysis|test_drive|quote|negotiation|closed_won|closed_lost — 8 candidates stripped; promote to reference product]',
    `test_drive_completed` BOOLEAN COMMENT 'Indicates whether the prospect has completed a test drive for the vehicle of interest.',
    `test_drive_date` DATE COMMENT 'Date when the test drive was completed, if applicable.',
    `trade_in_value` DECIMAL(18,2) COMMENT 'Appraised value of the customers trade-in vehicle, if applicable.',
    `vehicle_configuration` STRING COMMENT 'Detailed configuration of the vehicle including trim level, options, and packages.',
    `win_reason` STRING COMMENT 'Primary reason why the opportunity was won, if applicable. [ENUM-REF-CANDIDATE: price|product_features|brand_loyalty|service|financing|relationship|other — 7 candidates stripped; promote to reference product]',
    CONSTRAINT pk_opportunity PRIMARY KEY(`opportunity_id`)
) COMMENT 'Core sales opportunity record tracking a potential vehicle sale from initial identification through close. Captures prospect vehicle interest, estimated deal value, probability of close, sales stage, assigned sales representative, source channel, and expected close date. Aligns with Salesforce Automotive Cloud Opportunity object and SAP SD pre-sales pipeline. Covers retail, fleet, and commercial vehicle opportunities.';

CREATE OR REPLACE TABLE `automotive_ecm`.`sales`.`lead` (
    `lead_id` BIGINT COMMENT 'Unique identifier for the sales lead record. Primary key.',
    `campaign_id` BIGINT COMMENT 'Identifier of the marketing campaign that generated this lead, if applicable.',
    `opportunity_id` BIGINT COMMENT 'Identifier of the opportunity record created upon lead conversion. Null if not yet converted.',
    `dealership_id` BIGINT COMMENT 'Identifier of the dealership assigned to this lead for follow-up and conversion.',
    `rep_id` BIGINT COMMENT 'Identifier of the sales representative or dealer contact assigned to follow up on this lead.',
    `lead_dealership_id` BIGINT COMMENT 'Identifier of the dealership assigned to this lead for follow-up and conversion.',
    `lead_rep_id` BIGINT COMMENT 'Identifier of the sales representative or dealer contact assigned to follow up on this lead.',
    `model_id` BIGINT COMMENT 'Foreign key linking to vehicle.model. Business justification: Leads in automotive track which model the prospect is interested in. Marketing and sales teams require this FK for model-level lead funnel reporting, campaign ROI by model, and conquest/retention anal',
    `party_id` BIGINT COMMENT 'Foreign key linking to customer.party. Business justification: Associates leads with existing parties for referral tracking and lead conversion analysis in the Lead Management process.',
    `sales_territory_id` BIGINT COMMENT 'Foreign key linking to sales.sales_territory. Business justification: Leads are routed and assigned based on sales territories. Adding sales_territory_id to lead enables territory-level lead volume reporting, territory assignment tracking, and proper integration with th',
    `city` STRING COMMENT 'City where the lead is located.',
    `company_name` STRING COMMENT 'Name of the organization or company associated with the lead, applicable for fleet sales or commercial vehicle inquiries.',
    `converted_date` DATE COMMENT 'The date when the lead was converted into an opportunity. Null if not yet converted. Format: yyyy-MM-dd.',
    `country_code` STRING COMMENT 'Three-letter ISO 3166-1 alpha-3 country code representing the leads country of residence or business location.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when the lead record was first created in the system. Format: yyyy-MM-ddTHH:mm:ss.SSSXXX.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the estimated budget amount.. Valid values are `^[A-Z]{3}$`',
    `email_address` STRING COMMENT 'Primary email address of the lead for digital communication and follow-up.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `estimated_budget_amount` DECIMAL(18,2) COMMENT 'Estimated budget or price range the lead has indicated for the vehicle purchase.',
    `financing_interest` BOOLEAN COMMENT 'Boolean flag indicating whether the lead is interested in financing or leasing options.',
    `first_name` STRING COMMENT 'The first name (given name) of the individual lead contact.',
    `last_contact_date` DATE COMMENT 'The date when the lead was last contacted by a sales representative. Format: yyyy-MM-dd.',
    `last_name` STRING COMMENT 'The last name (family name) of the individual lead contact.',
    `lead_number` STRING COMMENT 'Human-readable business identifier for the lead, typically auto-generated by the CRM system. Format: LEAD-NNNNNNNN.. Valid values are `^LEAD-[0-9]{8}$`',
    `lead_source` STRING COMMENT 'The origin channel through which the lead was captured (web inquiry, dealer walk-in, automotive event, customer referral, digital marketing campaign, phone inquiry).. Valid values are `web|dealer_walk_in|event|referral|digital_campaign|phone_inquiry`',
    `lead_status` STRING COMMENT 'Current lifecycle status of the lead in the sales pipeline (new, contacted, qualified, unqualified, converted to opportunity, lost).. Valid values are `new|contacted|qualified|unqualified|converted|lost`',
    `lead_type` STRING COMMENT 'Classification of the lead based on buyer category: individual consumer, fleet buyer, commercial enterprise, or government entity.. Valid values are `individual|fleet|commercial|government`',
    `lost_reason` STRING COMMENT 'Reason why the lead was marked as lost (e.g., purchased from competitor, no longer interested, unresponsive).',
    `mobile_number` STRING COMMENT 'Mobile phone number of the lead for SMS campaigns and mobile outreach.',
    `model_year_interest` STRING COMMENT 'The model year (MY) of the vehicle the lead is interested in purchasing.. Valid values are `^(20[2-9][0-9]|MY[2-9][0-9])$`',
    `modified_timestamp` TIMESTAMP COMMENT 'The date and time when the lead record was last modified. Format: yyyy-MM-ddTHH:mm:ss.SSSXXX.',
    `next_follow_up_date` DATE COMMENT 'Scheduled date for the next follow-up activity with the lead. Format: yyyy-MM-dd.',
    `notes` STRING COMMENT 'Free-text notes and comments captured by sales representatives regarding the leads preferences, objections, and conversation history.',
    `opt_in_email` BOOLEAN COMMENT 'Boolean flag indicating whether the lead has opted in to receive email marketing communications.',
    `opt_in_phone` BOOLEAN COMMENT 'Boolean flag indicating whether the lead has opted in to receive phone call communications.',
    `opt_in_sms` BOOLEAN COMMENT 'Boolean flag indicating whether the lead has opted in to receive SMS marketing communications.',
    `phone_number` STRING COMMENT 'Primary contact phone number for the lead. Used for outbound sales calls and follow-up.',
    `postal_code` STRING COMMENT 'Postal or ZIP code of the leads address, used for geographic segmentation and dealer assignment.',
    `purchase_timeframe` STRING COMMENT 'Expected timeframe within which the lead intends to make a purchase decision (immediate, within 30 days, within 90 days, within 6 months, or future/undecided).. Valid values are `immediate|within_30_days|within_90_days|within_6_months|future`',
    `qualification_score` STRING COMMENT 'Numeric score (0-100) representing the leads likelihood to convert, based on engagement, budget, authority, need, and timeline (BANT criteria).',
    `rating` STRING COMMENT 'Qualitative rating of the lead based on engagement and conversion potential: hot (high priority), warm (moderate interest), cold (low engagement).. Valid values are `hot|warm|cold`',
    `referral_source` STRING COMMENT 'Name or identifier of the person or entity that referred this lead, if applicable.',
    `region` STRING COMMENT 'Geographic region or sales territory where the lead is located (e.g., North America, Europe, Asia-Pacific).',
    `state_province` STRING COMMENT 'State or province where the lead is located.',
    `street_address` STRING COMMENT 'Street address of the lead, used for delivery and service planning.',
    `test_drive_requested` BOOLEAN COMMENT 'Boolean flag indicating whether the lead has requested a test drive.',
    `trade_in_interest` BOOLEAN COMMENT 'Boolean flag indicating whether the lead has expressed interest in trading in an existing vehicle as part of the purchase.',
    `unqualified_reason` STRING COMMENT 'Reason why the lead was marked as unqualified (e.g., no budget, no authority, no need, incorrect contact information).',
    `vehicle_interest_category` STRING COMMENT 'The powertrain category of vehicle the lead is interested in: ICE (Internal Combustion Engine), EV (Electric Vehicle), HEV (Hybrid Electric Vehicle), or PHEV (Plug-in Hybrid Electric Vehicle).. Valid values are `ICE|EV|HEV|PHEV`',
    `web_form_code` STRING COMMENT 'Identifier of the web form or landing page through which the lead was captured, used for digital campaign attribution.',
    CONSTRAINT pk_lead PRIMARY KEY(`lead_id`)
) COMMENT 'Inbound or outbound sales lead representing an individual or organization expressing interest in purchasing a vehicle. Tracks lead source (web, dealer walk-in, event, referral, digital campaign), lead status, assigned owner, vehicle interest category (ICE, EV, HEV, PHEV), and qualification score. Feeds into opportunity pipeline upon qualification. Sourced from Salesforce Automotive Cloud Lead object.';

CREATE OR REPLACE TABLE `automotive_ecm`.`sales`.`quote` (
    `quote_id` BIGINT COMMENT 'Primary key for quote',
    `company_code_id` BIGINT COMMENT 'Foreign key linking to finance.company_code. Business justification: Quotes require company code for pricing rules, tax jurisdiction determination, and legal entity identification before order conversion. Essential for multi-entity OEM quote-to-order process and regula',
    `configuration_id` BIGINT COMMENT 'Foreign key linking to vehicle.vehicle_configuration. Business justification: Quote must be tied to a specific vehicle configuration to calculate options, OTA updates, and compliance; supports configuration‑based pricing.',
    `finished_vehicle_stock_id` BIGINT COMMENT 'Foreign key linking to inventory.finished_vehicle_stock. Business justification: Quotes reference specific in-stock vehicles for immediate delivery scenarios. Dealers quote against available inventory to offer shorter delivery times and close sales faster. Essential for stock-base',
    `homologation_record_id` BIGINT COMMENT 'Foreign key linking to compliance.homologation_record. Business justification: Quotes for export or regulated markets require homologation certification reference to validate vehicle eligibility, pricing (including regulatory fees), and delivery timelines. Sales teams must verif',
    `model_id` BIGINT COMMENT 'Foreign key linking to vehicle.model. Business justification: Required for Quote generation to reference the exact vehicle model, ensuring pricing consistency and enabling model‑level reporting.',
    `opportunity_id` BIGINT COMMENT 'Reference to the sales opportunity or lead that generated this quote. Tracks quote back to pipeline stage in Salesforce Automotive Cloud.',
    `party_id` BIGINT COMMENT 'Reference to the customer or prospect receiving this quote. Links to customer master data in SAP or Salesforce Automotive Cloud.',
    `dealership_id` BIGINT COMMENT 'Reference to the dealership or direct sales channel issuing the quote. Links to dealer master data in CDK Global DMS or SAP.',
    `quote_dealership_id` BIGINT COMMENT 'Reference to the dealership or direct sales channel issuing the quote. Links to dealer master data in CDK Global DMS or SAP.',
    `quote_party_id` BIGINT COMMENT 'Reference to the customer or prospect receiving this quote. Links to customer master data in SAP or Salesforce Automotive Cloud.',
    `vin_registry_id` BIGINT COMMENT 'Reference to the specific vehicle configuration being quoted. Links to vehicle master data including model, trim, powertrain, and options.',
    `quote_vin_registry_id` BIGINT COMMENT 'Reference to the specific vehicle configuration being quoted. Links to vehicle master data including model, trim, powertrain, and options.',
    `rep_id` BIGINT COMMENT 'Reference to the sales representative or account manager who prepared the quote. Used for commission tracking and performance analytics.',
    `sales_territory_id` BIGINT COMMENT 'Foreign key linking to sales.sales_territory. Business justification: Quotes are issued within specific sales territories (quote has sales_region STRING). Normalizing sales_region to a FK to sales_territory enables proper territory-level quote analytics, territory perfo',
    `sku_master_id` BIGINT COMMENT 'Foreign key linking to inventory.sku_master. Business justification: Quotes include accessory and parts pricing. Sales teams configure quotes with optional parts/accessories from inventory master data. Essential for accurate quote generation and parts availability vali',
    `vehicle_order_id` BIGINT COMMENT 'Reference to the sales order created from this quote if converted_to_order is true. Links quote to order for fulfillment tracking.',
    `vehicle_warranty_id` BIGINT COMMENT 'Foreign key linking to aftersales.vehicle_warranty. Business justification: Quote generation systems check existing warranty coverage to calculate net customer pricing, determine whats warranty-covered vs. customer-paid, and present accurate out-of-pocket costs. Standard aut',
    `accessories_total` DECIMAL(18,2) COMMENT 'Total value of dealer-installed accessories (e.g., floor mats, cargo organizers, protection packages). Separate from factory options.',
    `apr_rate` DECIMAL(18,2) COMMENT 'Annual percentage rate for financing if offered. Expressed as decimal (e.g., 0.0399 for 3.99% APR). Subject to credit approval.',
    `conversion_date` DATE COMMENT 'Date when quote was converted to order. Used for sales cycle time analytics and conversion rate reporting.',
    `converted_to_order` BOOLEAN COMMENT 'Indicates whether this quote was successfully converted to a customer order. True when customer accepts quote and order is created in SAP SD.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this quote record was first created in the system. Audit trail for record creation.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for all monetary amounts in this quote (e.g., USD, CAD, EUR, MXN).. Valid values are `^[A-Z]{3}$`',
    `delivery_method` STRING COMMENT 'Method by which customer will take delivery of vehicle. Dealer pickup is standard; home delivery, port pickup (for imports), and factory pickup (for premium brands) are alternatives.. Valid values are `dealer_pickup|home_delivery|port_pickup|factory_pickup`',
    `destination_charge` DECIMAL(18,2) COMMENT 'Freight and delivery charge from manufacturing plant to dealer. Typically a fixed amount per vehicle set by OEM.',
    `doc_fee` DECIMAL(18,2) COMMENT 'Dealer documentation and administrative fee for processing the sale. Regulated by state law in many jurisdictions.',
    `down_payment` DECIMAL(18,2) COMMENT 'Customer down payment amount if financing is offered. Reduces amount financed and monthly payment.',
    `drivetrain` STRING COMMENT 'Drivetrain configuration: FWD (Front-Wheel Drive), RWD (Rear-Wheel Drive), AWD (All-Wheel Drive), 4WD (Four-Wheel Drive).. Valid values are `fwd|rwd|awd|4wd`',
    `engine_code` STRING COMMENT 'Internal code identifying the specific engine or electric motor configuration. Used for parts ordering and service documentation.. Valid values are `^[A-Z0-9]{4,10}$`',
    `estimated_delivery_date` DATE COMMENT 'Estimated date when vehicle will be available for customer delivery. For in-stock vehicles, typically within days; for build-to-order, may be weeks or months.',
    `expiry_date` DATE COMMENT 'Date when the quote expires and pricing/terms are no longer valid. Typically 30-90 days from quote_date depending on market and vehicle type.',
    `exterior_color_code` STRING COMMENT 'Code representing the exterior paint color selected by customer. Links to color master data and may affect pricing for premium colors.. Valid values are `^[A-Z0-9]{3,6}$`',
    `financing_offered` BOOLEAN COMMENT 'Indicates whether financing terms are included in this quote. True if quote includes loan or lease options, false for cash-only quotes.',
    `financing_term_months` STRING COMMENT 'Length of financing term in months if financing_offered is true. Common terms: 36, 48, 60, 72, 84 months.',
    `incentive_total` DECIMAL(18,2) COMMENT 'Total value of manufacturer incentives, rebates, and discounts applied to this quote (e.g., loyalty bonus, conquest incentive, EV tax credit eligibility). Reduces net selling price.',
    `interior_color_code` STRING COMMENT 'Code representing the interior upholstery and trim color selected by customer.. Valid values are `^[A-Z0-9]{3,6}$`',
    `lease_annual_mileage` STRING COMMENT 'Annual mileage allowance for lease if offered. Common values: 10000, 12000, 15000 miles per year. Excess mileage incurs per-mile charges.',
    `lease_monthly_payment` DECIMAL(18,2) COMMENT 'Estimated monthly lease payment if lease is offered. Based on capitalized cost, residual value, money factor, and term.',
    `lease_offered` BOOLEAN COMMENT 'Indicates whether lease terms are included in this quote as an alternative to purchase financing.',
    `lease_term_months` STRING COMMENT 'Length of lease term in months if lease_offered is true. Common terms: 24, 36, 39, 48 months.',
    `model_year` STRING COMMENT 'Model year of the vehicle being quoted. Critical for pricing, incentive eligibility, and inventory management.',
    `modified_by` STRING COMMENT 'User ID or name of the person who last modified this quote record. Audit trail for change tracking.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this quote record was last modified. Audit trail for record updates and revisions.',
    `monthly_payment` DECIMAL(18,2) COMMENT 'Estimated monthly payment amount if financing is offered. Calculated from amount financed, APR, and term. Subject to credit approval.',
    `msrp_base` DECIMAL(18,2) COMMENT 'Base MSRP for the vehicle model and trim before options, accessories, and destination charges. Published pricing from OEM.',
    `net_selling_price` DECIMAL(18,2) COMMENT 'Final vehicle price after all incentives and trade-in allowance. Calculated as subtotal_amount - incentive_total - trade_in_allowance + trade_in_payoff. Base for tax calculation.',
    `notes` STRING COMMENT 'Free-text notes and comments about the quote. May include special customer requests, configuration details, or sales rep observations.',
    `options_total` DECIMAL(18,2) COMMENT 'Total value of factory-installed options and packages selected by customer (e.g., ADAS, premium audio, sunroof). Sum of individual option prices.',
    `powertrain_type` STRING COMMENT 'Type of powertrain: ICE (Internal Combustion Engine), HEV (Hybrid Electric Vehicle), PHEV (Plug-in Hybrid Electric Vehicle), BEV (Battery Electric Vehicle), FCEV (Fuel Cell Electric Vehicle). Critical for incentive eligibility and regulatory compliance.. Valid values are `ice|hev|phev|bev|fcev`',
    `quote_date` DATE COMMENT 'Date when the quote was issued to the customer or prospect. Represents the principal business event timestamp for this transaction.',
    `quote_number` STRING COMMENT 'Externally visible business identifier for the quote, typically generated by SAP SD (VA21) or Salesforce Automotive Cloud. Used for customer communication and dealer reference.. Valid values are `^[A-Z0-9]{8,20}$`',
    `quote_status` STRING COMMENT 'Current lifecycle status of the quote. Tracks progression from draft through approval to conversion or expiry. [ENUM-REF-CANDIDATE: draft|submitted|approved|rejected|expired|converted|cancelled — 7 candidates stripped; promote to reference product]',
    `quote_type` STRING COMMENT 'Classification of quote by sales channel and vehicle delivery format. Retail for individual consumers, fleet for corporate bulk orders, CKD (Completely Knocked Down) and SKD (Semi Knocked Down) for export assembly, commercial for business vehicles, demo for demonstration units. [ENUM-REF-CANDIDATE: retail|fleet|ckd|skd|commercial|demo|export — 7 candidates stripped; promote to reference product]',
    `registration_fee` DECIMAL(18,2) COMMENT 'Government registration and title fees for the vehicle. Varies by state/province and vehicle type.',
    `rejection_reason` STRING COMMENT 'Free-text reason why quote was rejected or not converted. Captured for loss analysis and sales process improvement.',
    `sales_channel` STRING COMMENT 'Channel through which quote was generated. Dealer for franchise network, direct for OEM-owned stores, online for digital sales, fleet for corporate accounts, broker for third-party intermediaries.. Valid values are `dealer|direct|online|fleet|broker`',
    `subtotal_amount` DECIMAL(18,2) COMMENT 'Subtotal before incentives, trade-in, taxes, and fees. Calculated as msrp_base + options_total + accessories_total + destination_charge.',
    `tax_amount` DECIMAL(18,2) COMMENT 'Total sales tax calculated on net_selling_price based on customer delivery location jurisdiction. May include state, county, and local taxes.',
    `total_amount_due` DECIMAL(18,2) COMMENT 'Final total amount customer must pay. Calculated as net_selling_price + tax_amount + registration_fee + doc_fee. Used for financing calculation or cash payment.',
    `trade_in_allowance` DECIMAL(18,2) COMMENT 'Value credited to customer for trade-in vehicle. Based on used vehicle appraisal. Reduces amount due from customer.',
    `trade_in_payoff` DECIMAL(18,2) COMMENT 'Outstanding loan balance on trade-in vehicle that must be paid off. If greater than trade_in_allowance, creates negative equity rolled into new financing.',
    `trade_in_vin` STRING COMMENT 'VIN of the customers trade-in vehicle if applicable. Used for appraisal lookup and title transfer processing.. Valid values are `^[A-HJ-NPR-Z0-9]{17}$`',
    `transmission_type` STRING COMMENT 'Type of transmission: manual, automatic, CVT (Continuously Variable Transmission), DCT (Dual Clutch Transmission), or single-speed (for EVs).. Valid values are `manual|automatic|cvt|dct|single_speed`',
    `trim_level` STRING COMMENT 'Trim or grade level of the vehicle (e.g., Base, Sport, Luxury, Premium). Determines standard equipment and base pricing.',
    `version` STRING COMMENT 'Version number of the quote. Increments when quote is revised with updated pricing, configuration, or terms. Supports quote revision history and audit trail.',
    `vin` STRING COMMENT '17-character Vehicle Identification Number if quote is for a specific in-stock or allocated vehicle. Null for build-to-order quotes where VIN is not yet assigned.. Valid values are `^[A-HJ-NPR-Z0-9]{17}$`',
    `created_by` STRING COMMENT 'User ID or name of the person who created this quote record. Audit trail for accountability.',
    CONSTRAINT pk_quote PRIMARY KEY(`quote_id`)
) COMMENT 'Formal vehicle sales quotation issued to a prospect or customer, detailing configured vehicle, MSRP, applied incentives, trade-in allowance, financing terms, accessories, and net selling price. Tracks quote version, expiry date, quote status, and issuing dealer or direct sales channel. Supports retail, fleet, and CKD/SKD export quotes. Linked to SAP SD quotation (VA21) and Salesforce Automotive Cloud Quote.';

CREATE OR REPLACE TABLE `automotive_ecm`.`sales`.`quote_line` (
    `quote_line_id` BIGINT COMMENT 'Unique identifier for the quote line item. Primary key.',
    `msrp_schedule_id` BIGINT COMMENT 'Foreign key linking to sales.msrp_schedule. Business justification: Quote line items need to reference the official MSRP schedule for the selected configuration; adding msrp_schedule_id eliminates redundant MSRP columns and enables consistent pricing lookup.',
    `part_master_id` BIGINT COMMENT 'Foreign key linking to engineering.part_master. Business justification: Needed for Pricing Engine to pull cost, lead time, and compliance from Part Master when generating quotes.',
    `vin_registry_id` BIGINT COMMENT 'Reference to the specific vehicle configuration being quoted. Applicable when line_type is vehicle. Links to the vehicle master for model, trim, and base specifications.',
    `quote_id` BIGINT COMMENT 'Foreign key reference to the parent quote header. Establishes the header-detail relationship for this line item.',
    `trim_option_availability_id` BIGINT COMMENT 'Foreign key linking to vehicle.vehicle_option_package. Business justification: Quote line for an option package should reference the canonical package entity for accurate pricing, warranty, and regulatory compliance.',
    `availability_status` STRING COMMENT 'Current availability status of the line item. Indicates whether the product is in dealer inventory, allocated from manufacturer, requires build-to-order, is backordered, or has been discontinued.. Valid values are `in_stock|allocated|build_to_order|backordered|discontinued`',
    `commission_eligible` BOOLEAN COMMENT 'Indicates whether this line item is eligible for sales representative commission. Certain line types (fees, trade-ins) may be excluded from commission calculations.',
    `commission_rate` DECIMAL(18,2) COMMENT 'Commission rate applied to this line item for sales representative compensation. Expressed as a decimal percentage. May vary by product type and sales program.',
    `cost_amount` DECIMAL(18,2) COMMENT 'Dealer cost or transfer price for this line item. Used for margin analysis and profitability reporting. Confidential business data not disclosed to customers.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this quote line was first created. Recorded in ISO 8601 format with timezone. Used for audit trail and lifecycle tracking.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for all monetary amounts on this line. Typically inherits from quote header but may differ for international fleet quotes.. Valid values are `^[A-Z]{3}$`',
    `delivery_date` DATE COMMENT 'Estimated or committed delivery date for this line item. Critical for customer expectations, logistics planning, and order fulfillment tracking.',
    `discount_amount` DECIMAL(18,2) COMMENT 'Total discount applied to this line item. Includes dealer discounts, promotional discounts, and volume discounts. Expressed as a positive value that reduces the line total.',
    `discount_percentage` DECIMAL(18,2) COMMENT 'Discount expressed as a percentage of the unit price. Used for percentage-based discount calculations and reporting. Stored alongside discount_amount for transparency.',
    `extended_price` DECIMAL(18,2) COMMENT 'Line item subtotal before tax. Calculated as (unit_price * quantity) - discount_amount - incentive_amount. Represents the pre-tax line total.',
    `exterior_color_code` STRING COMMENT 'Manufacturer color code for the vehicle exterior paint. Used for vehicle configuration, pricing (premium colors), and inventory matching.',
    `incentive_amount` DECIMAL(18,2) COMMENT 'Total manufacturer or dealer incentive applied to this line item. Includes cash rebates, loyalty bonuses, conquest incentives, and special financing subsidies. Reduces the customer-facing price.',
    `incentive_description` STRING COMMENT 'Human-readable description of the incentive applied. Provides customer-facing explanation of the incentive program, eligibility criteria, and value proposition.',
    `interior_color_code` STRING COMMENT 'Manufacturer color code for the vehicle interior trim and upholstery. Used for vehicle configuration, pricing, and customer preference tracking.',
    `line_number` STRING COMMENT 'Sequential line item number within the quote. Determines the ordering and display sequence of line items.',
    `line_status` STRING COMMENT 'Current lifecycle status of the quote line. Tracks the line through draft, approval, conversion to order, or cancellation workflows.. Valid values are `draft|active|approved|rejected|cancelled|converted`',
    `line_total` DECIMAL(18,2) COMMENT 'Total amount for this line item including tax. Calculated as extended_price + tax_amount. Represents the final customer-facing line total.',
    `line_type` STRING COMMENT 'Classification of the quote line item. Distinguishes between vehicle configurations, accessories, service packages, warranties, insurance products, fees, discounts, and trade-in credits. [ENUM-REF-CANDIDATE: vehicle|accessory|service_package|warranty|insurance|fee|discount|trade_in — 8 candidates stripped; promote to reference product]',
    `list_price` DECIMAL(18,2) COMMENT 'Manufacturer Suggested Retail Price (MSRP) or standard list price for the line item before any discounts or incentives. Expressed in the quote currency.',
    `margin_amount` DECIMAL(18,2) COMMENT 'Gross margin for this line item. Calculated as extended_price - cost_amount. Used for profitability analysis and sales performance evaluation.',
    `model_code` STRING COMMENT 'Manufacturer model code representing the configured vehicle variant. Includes base model, trim level, and factory option packages. Used for pricing and inventory lookup.',
    `model_year` STRING COMMENT 'Model year of the vehicle being quoted. Critical for pricing, incentive eligibility, and inventory allocation. Aligns with manufacturer production cycles.',
    `modified_by` STRING COMMENT 'User identifier of the person who last modified this quote line. Supports change tracking and audit requirements.',
    `modified_timestamp` TIMESTAMP COMMENT 'Date and time of the most recent modification to this quote line. Recorded in ISO 8601 format with timezone. Used for change tracking and audit trail.',
    `notes` STRING COMMENT 'Free-text notes and comments specific to this line item. Used for special instructions, configuration details, customer requests, or internal coordination.',
    `product_code` STRING COMMENT 'Stock Keeping Unit (SKU) or product code for accessories, service packages, warranties, or other non-vehicle line items. Links to product master for pricing and availability.',
    `product_description` STRING COMMENT 'Detailed description of the line item product or service. Includes accessory names, service package details, warranty coverage terms, or fee descriptions for customer clarity.',
    `quantity` STRING COMMENT 'Number of units for this line item. Typically 1 for vehicles, but may be greater than 1 for accessories, fleet orders, or service packages.',
    `rejection_reason` STRING COMMENT 'Explanation for why this line item was rejected or removed from the quote. Captures business reasons such as unavailability, pricing issues, or customer preference changes.',
    `tax_amount` DECIMAL(18,2) COMMENT 'Total sales tax calculated for this line item. Calculated as extended_price * tax_rate. Contributes to the overall quote tax total.',
    `tax_code` STRING COMMENT 'Tax jurisdiction code determining the applicable sales tax rate for this line item. Links to tax master for rate lookup and tax calculation rules.',
    `tax_rate` DECIMAL(18,2) COMMENT 'Sales tax rate applied to this line item, expressed as a decimal (e.g., 0.0825 for 8.25%). Used for tax calculation and compliance reporting.',
    `unit_of_measure` STRING COMMENT 'Unit of measure for the line item quantity. Common values include each (vehicles, accessories), set, pair, kit, hour (labor), month/year (subscriptions, warranties). [ENUM-REF-CANDIDATE: each|set|pair|kit|hour|month|year — 7 candidates stripped; promote to reference product]',
    `unit_price` DECIMAL(18,2) COMMENT 'Actual selling price per unit after dealer adjustments but before line-level discounts and incentives. May differ from list price due to market conditions or dealer pricing strategy.',
    `vin` STRING COMMENT '17-character Vehicle Identification Number uniquely identifying a specific vehicle unit. Populated when quoting a specific in-stock or allocated vehicle. Null for build-to-order quotes.. Valid values are `^[A-HJ-NPR-Z0-9]{17}$`',
    `created_by` STRING COMMENT 'User identifier of the sales representative or system user who created this quote line. Used for audit trail and accountability.',
    CONSTRAINT pk_quote_line PRIMARY KEY(`quote_line_id`)
) COMMENT 'Individual line item within a vehicle sales quote, representing a specific vehicle configuration, accessory, service package, or fee. Captures line type, configured model code, option packages, unit price, discount amount, incentive applied, and line-level tax. Enables multi-vehicle fleet quotes and accessory bundling. Child entity of quote.';

CREATE OR REPLACE TABLE `automotive_ecm`.`sales`.`vehicle_order` (
    `vehicle_order_id` BIGINT COMMENT 'Primary key for vehicle_order',
    `company_code_id` BIGINT COMMENT 'Foreign key linking to finance.company_code. Business justification: Order Accounting: each vehicle order must be tied to a legal entity (company code) for statutory reporting and consolidation.',
    `configuration_id` BIGINT COMMENT 'Foreign key linking to vehicle.configuration. Business justification: A vehicle order is placed against a specific vehicle configuration (color, trim, powertrain, options). Order management and manufacturing teams require this FK to validate build feasibility, trigger p',
    `contact_point_id` BIGINT COMMENT 'Reference to the specific address where the vehicle will be delivered. Links to customer or dealer address master data.',
    `cost_center_id` BIGINT COMMENT 'Foreign key linking to finance.cost_center. Business justification: Cost Allocation: orders are charged to a cost center for expense tracking and internal budgeting.',
    `dealership_id` BIGINT COMMENT 'Reference to the dealership through which the order was placed. Links to the dealer network master data.',
    `fiscal_period_id` BIGINT COMMENT 'Foreign key linking to finance.fiscal_period. Business justification: Orders must be assigned to fiscal periods for revenue recognition timing, period-end cutoffs, and financial reporting compliance. Critical for automotive OEM monthly/quarterly revenue close processes.',
    `fleet_contract_id` BIGINT COMMENT 'Foreign key linking to sales.fleet_contract. Business justification: Vehicle orders placed under fleet contracts need a header-level association to the fleet contract, not just at the order_line level. Adding fleet_contract_id to vehicle_order enables fleet contract fu',
    `homologation_record_id` BIGINT COMMENT 'Foreign key linking to compliance.homologation_record. Business justification: Regulatory reporting requires each vehicle order to reference the homologation approval authorizing the model for the market.',
    `model_id` BIGINT COMMENT 'Foreign key linking to vehicle.model. Business justification: Vehicle orders in automotive are placed against a specific model before VIN assignment (build-to-order). Order management and production scheduling teams require this FK for model-level order bank rep',
    `opportunity_id` BIGINT COMMENT 'Foreign key linking to sales.opportunity. Business justification: A confirmed vehicle order originates from a sales opportunity. Adding opportunity_id to vehicle_order provides direct traceability from the confirmed purchase back to the originating opportunity, enab',
    `party_id` BIGINT COMMENT 'Reference to the customer who placed the vehicle order. Links to the customer master data.',
    `rep_id` BIGINT COMMENT 'Reference to the sales representative or sales agent who handled the order. Used for commission calculation and performance tracking.',
    `vin_registry_id` BIGINT COMMENT 'Reference to the specific vehicle unit ordered. For stock orders, links to existing inventory. For build-to-order, links to the vehicle configuration that will be manufactured.',
    `profit_center_id` BIGINT COMMENT 'Foreign key linking to finance.profit_center. Business justification: Profit Center Reporting: each order contributes to a profit center for profitability analysis per business unit.',
    `sales_territory_id` BIGINT COMMENT 'Foreign key linking to sales.sales_territory. Business justification: Vehicle orders are placed within specific sales territories (vehicle_order has region_code STRING). Normalizing region_code to a FK to sales_territory enables proper territory-level order analytics, r',
    `vehicle_program_id` BIGINT COMMENT 'Foreign key linking to engineering.vehicle_program. Business justification: Order fulfillment tracks against Vehicle Program to manage production volume and delivery timelines.',
    `actual_delivery_date` DATE COMMENT 'Actual date when the vehicle was delivered to the customer or dealer. Used for On-Time Delivery (OTD) performance measurement.',
    `build_week` STRING COMMENT 'Scheduled production week for the vehicle in ISO week format (YYYYWWW). Represents the planned Start of Production (SOP) week.. Valid values are `^(19|20)d{2}W(0[1-9]|[1-4][0-9]|5[0-3])$`',
    `cancellation_reason` STRING COMMENT 'Free-text explanation for order cancellation. Populated only when order_status is cancelled. Used for loss analysis and process improvement.',
    `committed_delivery_date` DATE COMMENT 'OEM-committed delivery date communicated to the customer. Represents the contractual delivery obligation.',
    `confirmed_date` DATE COMMENT 'Date when the order was confirmed by the OEM and accepted into the production schedule. Represents the commitment to fulfill the order.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this order record was first created in the data platform. Used for audit trail and data lineage.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for all monetary amounts in this order.. Valid values are `^[A-Z]{3}$`',
    `delivery_location` STRING COMMENT 'Type of location where the vehicle will be delivered. Dealer for dealership pickup, customer_address for home delivery, port for export shipments, distribution_center for fleet staging.. Valid values are `dealer|customer_address|port|distribution_center`',
    `discount_amount` DECIMAL(18,2) COMMENT 'Total discount amount applied to the MSRP. Includes dealer discounts, promotional offers, and negotiated price reductions.',
    `exterior_color_code` STRING COMMENT 'Code representing the selected exterior paint color for the ordered vehicle.. Valid values are `^[A-Z0-9]{3,10}$`',
    `financing_reference_number` STRING COMMENT 'External reference number for the financing or lease agreement associated with this vehicle order. Links to the financial institution contract.. Valid values are `^[A-Z0-9]{8,20}$`',
    `financing_type` STRING COMMENT 'Source of financing for the vehicle purchase. Captive for OEM-owned finance arm, third_party for external lenders, none for cash purchases.. Valid values are `captive|third_party|bank|credit_union|none`',
    `fiscal_year` STRING COMMENT 'Fiscal year in which the order was placed. Used for financial reporting and sales performance tracking.. Valid values are `^FY(19|20)d{2}$`',
    `incentive_amount` DECIMAL(18,2) COMMENT 'Total manufacturer incentive amount applied to the order. Includes cash rebates, loyalty bonuses, conquest incentives, and special financing subsidies.',
    `interior_color_code` STRING COMMENT 'Code representing the selected interior trim and upholstery color for the ordered vehicle.. Valid values are `^[A-Z0-9]{3,10}$`',
    `model_year` STRING COMMENT 'Model year designation of the ordered vehicle. Represents the production year classification used for regulatory compliance and marketing.. Valid values are `^(19|20)d{2}$`',
    `msrp` DECIMAL(18,2) COMMENT 'Manufacturer Suggested Retail Price for the configured vehicle before any discounts, incentives, or dealer adjustments.',
    `order_date` DATE COMMENT 'Date when the customer placed the vehicle order. Represents the business event timestamp for order capture.',
    `order_number` STRING COMMENT 'Externally-visible unique order number assigned to the vehicle purchase order. Used for customer communication and dealer reference.. Valid values are `^[A-Z0-9]{10,20}$`',
    `order_status` STRING COMMENT 'Current lifecycle status of the vehicle order. Tracks progression from initial placement through manufacturing, shipment, and final delivery to customer. [ENUM-REF-CANDIDATE: draft|placed|confirmed|scheduled|in_production|built|shipped|delivered|cancelled — 9 candidates stripped; promote to reference product]',
    `order_timestamp` TIMESTAMP COMMENT 'Precise timestamp when the vehicle order was captured in the system. Used for order sequencing and audit trail.',
    `order_type` STRING COMMENT 'Classification of the vehicle order by customer segment and sales channel. Retail for individual consumers, fleet for commercial bulk purchases, government for public sector contracts, export for international sales, demo for dealer demonstration vehicles, internal for company use.. Valid values are `retail|fleet|government|export|demo|internal`',
    `payment_method` STRING COMMENT 'Method of payment for the vehicle order. Cash for full upfront payment, finance for loan-based purchase, lease for lease agreement, fleet_contract for commercial fleet arrangements.. Valid values are `cash|finance|lease|fleet_contract`',
    `powertrain_type` STRING COMMENT 'Type of powertrain system for the ordered vehicle. ICE for Internal Combustion Engine, HEV for Hybrid Electric Vehicle, PHEV for Plug-in Hybrid Electric Vehicle, BEV for Battery Electric Vehicle, FCEV for Fuel Cell Electric Vehicle.. Valid values are `ICE|HEV|PHEV|BEV|FCEV`',
    `priority_code` STRING COMMENT 'Priority classification for production scheduling. VIP for high-value customers, expedited for rush orders, fleet_priority for large commercial contracts, standard for normal processing.. Valid values are `standard|expedited|vip|fleet_priority`',
    `production_plant_code` STRING COMMENT 'Code identifying the manufacturing plant assigned to build this vehicle. Used for production scheduling and capacity planning.. Valid values are `^[A-Z0-9]{3,6}$`',
    `requested_delivery_date` DATE COMMENT 'Customer-requested date for vehicle delivery. Used for production planning and logistics scheduling.',
    `sales_channel` STRING COMMENT 'Channel through which the order was captured. Dealer for traditional dealership sales, direct for OEM-direct sales, online for e-commerce platform, fleet_sales for commercial fleet division, broker for third-party intermediaries.. Valid values are `dealer|direct|online|fleet_sales|broker`',
    `selling_price` DECIMAL(18,2) COMMENT 'Final agreed selling price for the vehicle after all discounts, incentives, rebates, and negotiations. Represents the actual transaction price.',
    `source_system` STRING COMMENT 'System of record where the order was originally captured. Used for data lineage and integration troubleshooting.. Valid values are `SAP_SD|Salesforce|DMS|Web_Portal|Mobile_App`',
    `special_instructions` STRING COMMENT 'Free-text field for special handling instructions, customer requests, or delivery notes that require attention during order fulfillment.',
    `tax_amount` DECIMAL(18,2) COMMENT 'Total sales tax, value-added tax, or other applicable taxes calculated for the vehicle order based on delivery jurisdiction.',
    `total_amount` DECIMAL(18,2) COMMENT 'Total amount payable by the customer including selling price, taxes, fees, and any additional charges minus trade-in value.',
    `trade_in_value` DECIMAL(18,2) COMMENT 'Appraised value of the customer trade-in vehicle applied toward the purchase. Null if no trade-in is involved.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this order record was last modified in the data platform. Used for change tracking and audit trail.',
    `vin` STRING COMMENT '17-character Vehicle Identification Number assigned to the ordered vehicle. May be null at order placement for build-to-order vehicles and populated when the vehicle enters production.. Valid values are `^[A-HJ-NPR-Z0-9]{17}$`',
    CONSTRAINT pk_vehicle_order PRIMARY KEY(`vehicle_order_id`)
) COMMENT 'Confirmed customer vehicle purchase order capturing the commercial commitment to buy a specific configured vehicle. Records order type (retail, fleet, government, export), ordered VIN or build-to-order configuration, agreed selling price, payment method, financing reference, delivery commitment date, and order status lifecycle (placed, confirmed, in-production, shipped, delivered). Interfaces with SAP SD sales order (VA01) and triggers manufacturing scheduling.';

CREATE OR REPLACE TABLE `automotive_ecm`.`sales`.`order_line` (
    `order_line_id` BIGINT COMMENT 'Unique identifier for the order line item. Primary key for the order_line product.',
    `configuration_id` BIGINT COMMENT 'Reference to the detailed vehicle configuration record capturing all selected options, packages, and specifications for this order line.',
    `dealership_id` BIGINT COMMENT 'Reference to the dealership responsible for this order line. Links to dealer network and channel management.',
    `fleet_contract_id` BIGINT COMMENT 'Reference to the fleet sales contract or commercial vehicle agreement governing this line item. Null for retail orders.',
    `fleet_contract_line_id` BIGINT COMMENT 'Foreign key linking to sales.fleet_contract_line. Business justification: Order lines fulfill specific fleet contract line allocations. While order_line already has fleet_contract_id for header-level association, adding fleet_contract_line_id enables granular fulfillment tr',
    `gl_account_id` BIGINT COMMENT 'Foreign key linking to finance.gl_account. Business justification: Revenue Posting: every order line maps to a GL account to generate journal entries for recognized revenue.',
    `part_master_id` BIGINT COMMENT 'Foreign key linking to engineering.part_master. Business justification: Production scheduling uses Order Line to retrieve Part Master details for manufacturing execution.',
    `rep_id` BIGINT COMMENT 'Reference to the sales representative or sales agent who captured this order line. Used for commission calculation and performance tracking.',
    `vin_registry_id` BIGINT COMMENT 'Reference to the trade-in vehicle appraisal record if this order line includes a trade-in transaction. Null if no trade-in.',
    `sku_master_id` BIGINT COMMENT 'Foreign key linking to inventory.sku_master. Business justification: Order lines for accessories, parts, and options reference inventory SKUs. Critical for parts order fulfillment, inventory allocation, and accessory installation scheduling. Supports mixed vehicle+part',
    `tertiary_order_vin_registry_id` BIGINT COMMENT 'Reference to the specific vehicle master record when line_type is vehicle. Links to vehicle configuration and specifications.',
    `trim_option_availability_id` BIGINT COMMENT 'Foreign key linking to vehicle.vehicle_option_package. Business justification: Order line must reference option package entity to drive production planning, parts allocation, and warranty tracking.',
    `vehicle_order_id` BIGINT COMMENT 'Foreign key reference to the parent sales order header. Links this line item to its containing order transaction.',
    `actual_delivery_date` DATE COMMENT 'Actual date when the line item was delivered and accepted by the dealer or customer. Triggers revenue recognition.',
    `actual_production_date` DATE COMMENT 'Actual date when vehicle production was completed. Populated from MES upon job completion.',
    `allocation_date` DATE COMMENT 'Date when a specific vehicle unit or inventory item was allocated to fulfill this order line. Null until allocation occurs.',
    `cancellation_reason` STRING COMMENT 'Reason code or description explaining why this order line was cancelled. Null for non-cancelled lines.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this order line record was first created in the system. Represents the moment of order line capture.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for all monetary amounts on this line item.. Valid values are `^[A-Z]{3}$`',
    `discount_amount` DECIMAL(18,2) COMMENT 'Total discount applied to this line item including dealer discounts, promotional discounts, and volume discounts.',
    `estimated_delivery_date` DATE COMMENT 'Estimated date when the line item will be delivered to the dealer or end customer. Updated based on production and logistics schedules.',
    `exterior_color_code` STRING COMMENT 'Manufacturer color code for the vehicle exterior paint finish. Links to paint specification and supply chain planning.',
    `financing_type` STRING COMMENT 'Method of financing selected for this line item. Indicates whether the customer is paying cash, securing a loan, entering a lease, or using fleet financing.. Valid values are `cash|loan|lease|fleet_lease|captive_finance`',
    `fleet_indicator` BOOLEAN COMMENT 'Boolean flag indicating whether this line item is part of a fleet or commercial vehicle order. True for fleet sales, False for retail sales.',
    `incentive_amount` DECIMAL(18,2) COMMENT 'Manufacturer or dealer incentive amount applied to this line item. Includes rebates, loyalty bonuses, and promotional incentives.',
    `interior_color_code` STRING COMMENT 'Manufacturer color code for the vehicle interior trim and upholstery. Links to interior material specifications.',
    `line_number` STRING COMMENT 'Sequential line item number within the parent order. Determines display and processing sequence.',
    `line_status` STRING COMMENT 'Current fulfillment status of this order line. Tracks progression from order capture through delivery or cancellation. [ENUM-REF-CANDIDATE: open|allocated|in_production|shipped|delivered|cancelled|on_hold — 7 candidates stripped; promote to reference product]',
    `line_total` DECIMAL(18,2) COMMENT 'Total amount for this line item including net price, taxes, and fees. Calculated as (net_price * quantity) plus tax_amount.',
    `line_type` STRING COMMENT 'Classification of the order line item indicating whether it represents a vehicle unit, accessory, warranty product, service contract, parts, freight charge, or documentation fee. [ENUM-REF-CANDIDATE: vehicle|accessory|extended_warranty|service_contract|parts|freight|documentation_fee — 7 candidates stripped; promote to reference product]',
    `list_price` DECIMAL(18,2) COMMENT 'Manufacturer Suggested Retail Price (MSRP) or catalog list price per unit before any discounts or incentives.',
    `model_code` STRING COMMENT 'Manufacturer model code identifying the vehicle platform, body style, and base configuration. Used for production planning and parts allocation.',
    `model_year` STRING COMMENT 'Model year designation for the vehicle. Represents the production year classification, not the calendar year of manufacture.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this order line record was last modified. Updated whenever any attribute changes.',
    `net_price` DECIMAL(18,2) COMMENT 'Net unit price after applying all discounts and incentives but before taxes and fees. Calculated as list_price minus discount_amount minus incentive_amount.',
    `plant_code` STRING COMMENT 'Code identifying the manufacturing plant or assembly facility assigned to produce this vehicle unit.',
    `powertrain_type` STRING COMMENT 'Type of powertrain system. ICE=Internal Combustion Engine, HEV=Hybrid Electric Vehicle, PHEV=Plug-in Hybrid Electric Vehicle, BEV=Battery Electric Vehicle, FCEV=Fuel Cell Electric Vehicle.. Valid values are `ICE|HEV|PHEV|BEV|FCEV`',
    `product_description` STRING COMMENT 'Human-readable description of the line item product or service. Provides business context for reporting and customer documentation.',
    `quantity` DECIMAL(18,2) COMMENT 'Ordered quantity for this line item. Typically 1 for vehicle units, may be greater than 1 for accessories, parts, or fleet orders.',
    `scheduled_production_date` DATE COMMENT 'Planned Start of Production (SOP) date for this vehicle unit. Applicable only for build-to-order vehicles.',
    `ship_date` DATE COMMENT 'Date when the line item was shipped from the manufacturing plant or distribution center to the dealer or customer.',
    `special_instructions` STRING COMMENT 'Free-text field capturing any special handling instructions, customer requests, or delivery notes specific to this order line.',
    `tax_amount` DECIMAL(18,2) COMMENT 'Total tax amount for this line item including sales tax, value-added tax, and any applicable excise taxes.',
    `unit_of_measure` STRING COMMENT 'Unit of measure for the quantity field. EA=Each, SET=Set, KIT=Kit, HR=Hour (for service contracts), UNIT=Unit.. Valid values are `EA|SET|KIT|HR|UNIT`',
    `vin` STRING COMMENT '17-character Vehicle Identification Number assigned to this line item when available. May be null at order capture and populated during production allocation. Uniquely identifies the physical vehicle unit.. Valid values are `^[A-HJ-NPR-Z0-9]{17}$`',
    CONSTRAINT pk_order_line PRIMARY KEY(`order_line_id`)
) COMMENT 'Individual line item within a vehicle order representing a specific vehicle unit, accessory, extended warranty, or service contract. Captures VIN assignment (when available), model code, trim level, exterior/interior color, option packages, unit net price, quantity, and line fulfillment status. Supports multi-unit fleet orders with individual VIN-level tracking per line.';

CREATE OR REPLACE TABLE `automotive_ecm`.`sales`.`incentive_program` (
    `incentive_program_id` BIGINT COMMENT 'Unique identifier for the sales_incentive_program data product (auto-inserted pre-linking).',
    `campaign_id` BIGINT COMMENT 'Foreign key linking to sales.campaign. Business justification: OEM incentive programs (customer cash rebates, dealer cash, low-APR financing) are typically launched as part of structured sales campaigns. Linking sales_incentive_program to campaign connects the in',
    `model_id` BIGINT COMMENT 'Foreign key linking to vehicle.model. Business justification: Sales incentive programs in automotive are model-specific (e.g., $2000 cash back on Accord). Finance and marketing teams require this FK to track incentive spend by model, measure program effectiven',
    `model_year_program_id` BIGINT COMMENT 'Foreign key linking to vehicle.vehicle_model_year_program. Business justification: Incentive programs in automotive are model-year specific (e.g., MY2024 EV launch incentive). Finance and product teams require this FK to align incentive program eligibility with model year program ',
    `regulatory_requirement_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_requirement. Business justification: Incentive programs frequently target regulatory compliance goals (ZEV credit generation, fleet emissions reduction, CAFE improvement). Program design, eligibility rules, and payout structures referenc',
    `sales_territory_id` BIGINT COMMENT 'Foreign key linking to sales.sales_territory. Business justification: Incentive programs are often scoped to specific geographic or channel-based sales territories (e.g., regional conquest cash, zone-specific dealer incentives). Linking sales_incentive_program to sales_',
    `vehicle_program_id` BIGINT COMMENT 'Foreign key linking to engineering.vehicle_program. Business justification: Sales incentive programs (cash back, low APR, lease support) are designed for specific vehicle programs to drive sales of particular nameplates. Incentive program eligibility, claim validation, and RO',
    CONSTRAINT pk_incentive_program PRIMARY KEY(`incentive_program_id`)
) COMMENT 'Master record for OEM-sponsored sales incentive programs including customer cash rebates, dealer cash allowances, low-APR financing offers, lease support, conquest bonuses, loyalty rewards, and fleet incentives. Captures program code, program type, eligible model year and nameplate, start and end dates, maximum incentive amount, funding source (OEM vs regional), stackability rules, and eligibility criteria. Managed centrally and distributed to dealer network.';

CREATE OR REPLACE TABLE `automotive_ecm`.`sales`.`sales_incentive_claim` (
    `sales_incentive_claim_id` BIGINT COMMENT 'Unique identifier for the sales_incentive_claim data product (auto-inserted pre-linking).',
    `cost_center_id` BIGINT COMMENT 'Foreign key linking to finance.cost_center. Business justification: Incentive claims are expenses charged to specific cost centers for budget tracking, variance analysis, and departmental P&L. Standard practice for sales incentive program accounting in automotive.',
    `finished_vehicle_stock_id` BIGINT COMMENT 'Foreign key linking to inventory.finished_vehicle_stock. Business justification: Incentive claims reference specific delivered vehicles for validation. OEM incentive programs require VIN-level proof of delivery and stock status verification. Critical for dealer incentive audits, m',
    `fleet_contract_id` BIGINT COMMENT 'Foreign key linking to sales.fleet_contract. Business justification: Fleet contracts often carry OEM-sponsored incentive programs (volume discounts, fleet cash). Linking sales_incentive_claim to fleet_contract allows tracking of incentives applied at the fleet contract',
    `gl_account_id` BIGINT COMMENT 'Foreign key linking to finance.gl_account. Business justification: Claims require GL account assignment for proper expense classification (marketing vs sales expense accounts). Essential for financial reporting and incentive program cost analysis in automotive operat',
    `incentive_program_id` BIGINT COMMENT 'Foreign key linking to sales.sales_incentive_program. Business justification: Link claim to internal incentive program for accurate incentive tracking.',
    `payment_id` BIGINT COMMENT 'Foreign key linking to billing.payment. Business justification: Incentive claims (dealer/rep bonuses, volume rebates) result in outbound payments. Tracks which payment settled each claim for audit, reconciliation, and commission reporting. Standard automotive ince',
    `rep_id` BIGINT COMMENT 'Foreign key linking to sales.rep. Business justification: Incentive claims are submitted and managed by sales representatives. Linking sales_incentive_claim to rep enables commission calculations tied to incentive claims, rep-level incentive performance repo',
    `vehicle_order_id` BIGINT COMMENT 'Foreign key linking to sales.vehicle_order. Business justification: An incentive claim is a transactional record applied to a specific vehicle sale. Linking sales_incentive_claim to vehicle_order anchors the claim to the confirmed purchase transaction, enabling incent',
    CONSTRAINT pk_sales_incentive_claim PRIMARY KEY(`sales_incentive_claim_id`)
) COMMENT 'Transactional record of an incentive applied to a specific vehicle sale or lease transaction. Captures the incentive program applied, claimed amount, claim date, approving authority, claim status (submitted, approved, paid, rejected), dealer or direct channel submitting the claim, and supporting documentation references. Enables incentive spend tracking and reconciliation against program budgets.';

CREATE OR REPLACE TABLE `automotive_ecm`.`sales`.`fleet_contract` (
    `fleet_contract_id` BIGINT COMMENT 'Unique identifier for the fleet contract. Primary key for the fleet contract entity.',
    `campaign_id` BIGINT COMMENT 'Foreign key linking to sales.campaign. Business justification: Fleet contracts are often executed under specific OEM fleet sales campaigns (e.g., government fleet programs, national account campaigns). Linking fleet_contract to campaign enables campaign-level fle',
    `company_code_id` BIGINT COMMENT 'Foreign key linking to finance.company_code. Business justification: Fleet contracts are legal agreements requiring explicit contracting legal entity for revenue recognition, liability tracking, and multi-year contract accounting. Standard practice for enterprise fleet',
    `opportunity_id` BIGINT COMMENT 'Foreign key linking to sales.opportunity. Business justification: Fleet contracts originate from fleet sales opportunities. Linking fleet_contract to opportunity provides traceability from the commercial agreement back to the originating opportunity, enabling fleet ',
    `organization_account_id` BIGINT COMMENT 'Reference to the fleet customer account that holds this contract. Links to the master fleet account entity.',
    `party_id` BIGINT COMMENT 'Reference to the primary customer entity associated with this fleet contract. May represent corporate buyer, government agency, or rental company.',
    `rep_id` BIGINT COMMENT 'Reference to the sales representative or account manager responsible for this fleet contract. Typically a dedicated fleet sales specialist.',
    `regulatory_requirement_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_requirement. Business justification: Government and regulated fleet contracts must reference applicable regulatory requirements (ZEV mandates, emissions standards, CAFE targets) that define eligible vehicle specifications, volume commitm',
    `vehicle_program_id` BIGINT COMMENT 'Foreign key linking to engineering.vehicle_program. Business justification: Fleet contracts specify eligible vehicle programs by nameplate and model year. Fleet contract management, volume commitment tracking, and production scheduling require linking contracts to the enginee',
    `annual_mileage_allowance` STRING COMMENT 'Maximum annual mileage allowed per vehicle under lease terms without excess mileage charges. Typical values range from 10,000 to 25,000 miles per year. Null for purchase contracts.',
    `approval_date` DATE COMMENT 'Date when the fleet contract received final internal approval from sales management or finance. Precedes contract signing.',
    `approved_by_user_code` BIGINT COMMENT 'Reference to the user who granted final approval for this fleet contract. Typically a sales director or VP of fleet sales.',
    `auto_renewal_flag` BOOLEAN COMMENT 'Indicates whether the contract automatically renews for an additional term unless either party provides notice of non-renewal.',
    `base_discount_percentage` DECIMAL(18,2) COMMENT 'Base percentage discount off Manufacturer Suggested Retail Price (MSRP) granted to the fleet customer. Additional volume-based discounts may apply.',
    `committed_volume` STRING COMMENT 'Total number of vehicles the fleet customer has committed to purchase or lease under this contract. Used for volume-based pricing tier qualification.',
    `contract_name` STRING COMMENT 'Descriptive name or title of the fleet contract, typically including customer name and program identifier for easy reference.',
    `contract_number` STRING COMMENT 'Externally-known unique business identifier for the fleet contract, used in communications with fleet customers and internal systems. Format: FC-YYYYNNNN.. Valid values are `^FC-[0-9]{8}$`',
    `contract_signed_date` DATE COMMENT 'Date when the fleet contract was formally signed by both parties. Marks the legal binding of the agreement.',
    `contract_status` STRING COMMENT 'Current lifecycle status of the fleet contract. Governs whether new orders can be placed and whether pricing and incentives are active. [ENUM-REF-CANDIDATE: draft|pending_approval|active|suspended|expired|terminated|completed — 7 candidates stripped; promote to reference product]',
    `contract_term_months` STRING COMMENT 'Duration of the fleet contract expressed in months. Typical terms range from 12 to 60 months for corporate fleets.',
    `contract_type` STRING COMMENT 'Classification of the fleet contract based on customer segment and business model. Determines pricing rules, incentive eligibility, and delivery processes.. Valid values are `corporate|government|rental|utility|leasing|dealer_demo`',
    `contract_value_amount` DECIMAL(18,2) COMMENT 'Total estimated monetary value of the fleet contract based on committed volume and agreed pricing. Expressed in contract currency.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this fleet contract record was first created in the system. Used for audit trail and data lineage.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for all monetary amounts in this contract (e.g., USD, EUR, CAD).. Valid values are `^[A-Z]{3}$`',
    `delivered_volume` STRING COMMENT 'Cumulative count of vehicles delivered to the fleet customer under this contract to date. Updated upon each delivery completion.',
    `delivery_schedule_type` STRING COMMENT 'Classification of how vehicles will be delivered over the contract term. Staggered and quarterly schedules are common for large fleet orders.. Valid values are `single_delivery|staggered|quarterly|annual|on_demand`',
    `effective_end_date` DATE COMMENT 'Date when the fleet contract expires or terminates. After this date, no new orders can be placed under the contract terms. Nullable for open-ended agreements.',
    `effective_start_date` DATE COMMENT 'Date when the fleet contract becomes active and eligible for vehicle orders. Aligns with fiscal year or model year start in many cases.',
    `eligible_model_years` STRING COMMENT 'Comma-separated list of model years eligible for purchase under this contract. Typically current and next model year.',
    `eligible_powertrain_types` STRING COMMENT 'Comma-separated list of powertrain types eligible under this contract. May include ICE (Internal Combustion Engine), HEV (Hybrid Electric Vehicle), PHEV (Plug-in Hybrid Electric Vehicle), EV (Electric Vehicle), or combinations.',
    `financing_type` STRING COMMENT 'Primary financing method for vehicles under this contract. Captive finance refers to manufacturer-owned financing arm.. Valid values are `cash_purchase|lease|captive_finance|third_party_finance|mixed`',
    `government_contract_flag` BOOLEAN COMMENT 'Indicates whether this is a government procurement contract subject to special regulations, reporting requirements, and compliance standards.',
    `gsa_schedule_number` STRING COMMENT 'GSA schedule contract number for U.S. federal government fleet purchases. Null for non-government contracts.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this fleet contract record was last updated. Tracks the most recent change to any field in the record.',
    `lease_term_months` STRING COMMENT 'Duration of lease agreement in months if financing_type is lease. Typical fleet lease terms are 24, 36, or 48 months. Null for cash purchases.',
    `maintenance_included_flag` BOOLEAN COMMENT 'Indicates whether scheduled maintenance services are included in the fleet contract pricing. Common for lease agreements and full-service fleet contracts.',
    `minimum_order_quantity` STRING COMMENT 'Minimum number of vehicles that must be ordered in a single transaction to qualify for fleet contract pricing.',
    `multi_location_delivery_flag` BOOLEAN COMMENT 'Indicates whether vehicles under this contract will be delivered to multiple locations. True for national fleet accounts with regional distribution.',
    `national_fleet_account_flag` BOOLEAN COMMENT 'Indicates whether this is a national fleet account with centralized purchasing and multi-region delivery. National accounts receive special pricing and dedicated account management.',
    `payment_terms` STRING COMMENT 'Standard payment terms governing when payment is due after vehicle delivery. Net 30/60/90 are common for corporate fleets; government contracts may have custom terms.. Valid values are `net_30|net_60|net_90|prepayment|milestone|custom`',
    `primary_delivery_location` STRING COMMENT 'Primary geographic location or facility where fleet vehicles will be delivered. May be a corporate headquarters, fleet depot, or distribution center.',
    `remaining_volume` STRING COMMENT 'Number of vehicles remaining to be delivered under the committed volume. Calculated as committed_volume minus delivered_volume.',
    `renewal_eligible_flag` BOOLEAN COMMENT 'Indicates whether this fleet contract is eligible for renewal upon expiration. Based on customer performance, payment history, and strategic account status.',
    `sales_region` STRING COMMENT 'Geographic sales region where this fleet contract is managed. Used for regional sales performance tracking and territory management.',
    `special_terms_notes` STRING COMMENT 'Free-text field capturing any special terms, conditions, or negotiated provisions unique to this fleet contract that are not captured in standard fields.',
    `termination_date` DATE COMMENT 'Date when the fleet contract was terminated prior to its natural expiration. Null for contracts that completed normally or are still active.',
    `termination_reason` STRING COMMENT 'Business reason for early termination of the fleet contract. Examples include customer request, breach of terms, business closure, or strategic change.',
    `volume_tier_discount_percentage` DECIMAL(18,2) COMMENT 'Additional discount percentage applied when cumulative volume reaches specified tier thresholds. Stacks on top of base discount.',
    `warranty_extension_months` STRING COMMENT 'Number of months beyond standard manufacturer warranty that are included in the fleet contract. Zero indicates standard warranty only.',
    CONSTRAINT pk_fleet_contract PRIMARY KEY(`fleet_contract_id`)
) COMMENT 'Commercial agreement governing the sale or lease of multiple vehicles to a fleet customer (corporate, government, rental, utility). Captures fleet account reference, contracted volume commitments, agreed pricing tiers, eligible nameplates and model years, contract term, delivery schedule, fleet incentive program linkage, and contract status. Supports national fleet accounts and government procurement contracts. Distinct from retail sales orders due to volume pricing, multi-delivery scheduling, and contract lifecycle management.';

CREATE OR REPLACE TABLE `automotive_ecm`.`sales`.`fleet_contract_line` (
    `fleet_contract_line_id` BIGINT COMMENT 'Unique identifier for the fleet contract line item. Primary key for this entity.',
    `dealership_id` BIGINT COMMENT 'Reference to the dealership or distribution partner involved in fulfilling this contract line, if applicable.',
    `fleet_contract_id` BIGINT COMMENT 'Reference to the parent fleet contract under which this line item is allocated. Links this line to the master fleet agreement.',
    `homologation_record_id` BIGINT COMMENT 'Foreign key linking to compliance.homologation_record. Business justification: Each fleet contract line specifies vehicles for target markets; homologation record determines market eligibility and certification status. Fleet operations must validate homologation before committin',
    `model_id` BIGINT COMMENT 'Foreign key linking to vehicle.model. Business justification: Each fleet contract line specifies a vehicle model/nameplate for fulfillment. Fleet account managers and production schedulers require this FK for model-level fleet order fulfillment tracking, allocat',
    `model_year_program_id` BIGINT COMMENT 'Foreign key linking to vehicle.vehicle_model_year_program. Business justification: Fleet contract lines are tied to specific model year programs for production scheduling and delivery window planning. Fleet and production teams require this FK to align fleet fulfillment with model y',
    `msrp_schedule_id` BIGINT COMMENT 'Foreign key linking to sales.msrp_schedule. Business justification: Fleet contract lines capture MSRP as a denormalized decimal column. The authoritative MSRP is defined in the msrp_schedule table by nameplate, model year, trim level, and powertrain. Adding msrp_sched',
    `rep_id` BIGINT COMMENT 'Reference to the sales representative or account manager responsible for this contract line.',
    `vin_registry_id` BIGINT COMMENT 'Reference to the specific vehicle master record representing the nameplate and configuration allocated in this line.',
    `service_contract_id` BIGINT COMMENT 'Foreign key linking to aftersales.service_contract. Business justification: Individual fleet vehicles within a contract may have specific service coverage terms. Real business process: per-vehicle service contract assignment within fleet deals, tracking which vehicles have wh',
    `sku_master_id` BIGINT COMMENT 'Foreign key linking to inventory.sku_master. Business justification: Fleet contract lines specify standard parts, accessories, and upfit components included in fleet vehicles. Essential for fleet configuration management, upfitter coordination, and contract fulfillment',
    `storage_location_id` BIGINT COMMENT 'Reference to the specific delivery location, distribution center, or customer facility where vehicles will be delivered.',
    `trim_level_id` BIGINT COMMENT 'Foreign key linking to vehicle.vehicle_trim_level. Business justification: Fleet contract lines specify a trim level for each ordered vehicle. Fleet operations teams require this FK to validate trim availability, enforce contract specifications, and normalize the denormalize',
    `vehicle_program_id` BIGINT COMMENT 'Foreign key linking to engineering.vehicle_program. Business justification: Each fleet contract line specifies a nameplate/model_year/powertrain combination that maps to a vehicle program. Production scheduling, fulfillment tracking, and delivery window management for fleet l',
    `allocation_priority` STRING COMMENT 'The priority level for production allocation and delivery scheduling: standard, high, urgent, or critical. Influences manufacturing sequence and resource allocation.. Valid values are `standard|high|urgent|critical`',
    `amendment_notes` STRING COMMENT 'Free-text notes documenting any amendments or changes made to this contract line after initial creation.',
    `body_style` STRING COMMENT 'The body style or vehicle type (e.g., Sedan, SUV, Truck, Van, Coupe). Defines the physical configuration and use case category.',
    `cancellation_reason` STRING COMMENT 'The reason for cancellation if this contract line was cancelled. Captures business justification for contract line termination.',
    `created_by_user_code` STRING COMMENT 'The user ID of the person who created this contract line record. Audit trail for accountability.',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this contract line record was first created in the system. Audit trail for record creation.',
    `currency_code` STRING COMMENT 'The three-letter ISO 4217 currency code for all monetary values in this contract line (e.g., USD, EUR, CAD).. Valid values are `^[A-Z]{3}$`',
    `delivery_window_end_date` DATE COMMENT 'The latest date in the delivery window for vehicles under this contract line. Defines the end of the acceptable delivery period.',
    `delivery_window_start_date` DATE COMMENT 'The earliest date in the delivery window for vehicles under this contract line. Defines the beginning of the acceptable delivery period.',
    `destination_country_code` STRING COMMENT 'The three-letter ISO 3166-1 alpha-3 country code for the destination market of vehicles in this line (e.g., USA, CAN, MEX).. Valid values are `^[A-Z]{3}$`',
    `destination_region` STRING COMMENT 'The geographic region or sales territory where vehicles in this line will be delivered (e.g., Northeast, Southwest, Pacific).',
    `discount_percentage` DECIMAL(18,2) COMMENT 'The percentage discount applied to the MSRP to arrive at the unit contracted price. Represents fleet pricing concession.',
    `exterior_color_code` STRING COMMENT 'The OEM color code for the exterior paint finish specified for vehicles in this line.',
    `fleet_use_type` STRING COMMENT 'The intended use category for the fleet vehicles: commercial (business operations), rental (rental fleet), government (public sector), corporate (executive/employee), utility (service/maintenance), or emergency (police/fire/EMS).. Valid values are `commercial|rental|government|corporate|utility|emergency`',
    `fulfillment_status` STRING COMMENT 'The current fulfillment status of this contract line: pending (not yet started), in_production (vehicles being built), ready_for_delivery (built and awaiting shipment), partially_fulfilled (some units delivered), fully_fulfilled (all units delivered), or cancelled.. Valid values are `pending|in_production|ready_for_delivery|partially_fulfilled|fully_fulfilled|cancelled`',
    `interior_color_code` STRING COMMENT 'The OEM color code for the interior trim and upholstery specified for vehicles in this line.',
    `last_modified_by_user_code` STRING COMMENT 'The user ID of the person who last modified this contract line record. Audit trail for accountability.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'The date and time when this contract line record was last updated. Audit trail for record changes.',
    `line_number` STRING COMMENT 'Sequential line item number within the parent fleet contract. Used for ordering and referencing specific allocations within the contract.',
    `line_status` STRING COMMENT 'The current administrative status of this contract line: active (in force), on_hold (temporarily suspended), cancelled (terminated), completed (fully delivered and closed), or amended (modified after creation).. Valid values are `active|on_hold|cancelled|completed|amended`',
    `planned_production_month` STRING COMMENT 'The planned production month for vehicles in this line, in YYYY-MM format. Aligns with manufacturing scheduling and capacity planning.. Valid values are `^d{4}-(0[1-9]|1[0-2])$`',
    `powertrain_type` STRING COMMENT 'The powertrain technology type for the vehicle: ICE (Internal Combustion Engine), EV (Electric Vehicle), HEV (Hybrid Electric Vehicle), PHEV (Plug-in Hybrid Electric Vehicle), or FCEV (Fuel Cell Electric Vehicle).. Valid values are `ICE|EV|HEV|PHEV|FCEV`',
    `quantity_committed` STRING COMMENT 'The total number of vehicle units committed under this contract line. Represents the contractual obligation for delivery.',
    `quantity_fulfilled` STRING COMMENT 'The number of vehicle units that have been delivered and fulfilled against this contract line to date.',
    `quantity_remaining` STRING COMMENT 'The number of vehicle units still pending delivery under this contract line. Calculated as quantity_committed minus quantity_fulfilled.',
    `regulatory_compliance_notes` STRING COMMENT 'Free-text notes documenting any special regulatory compliance requirements for vehicles in this line (e.g., CARB emissions, CAFE standards, safety certifications).',
    `requested_delivery_date` DATE COMMENT 'The customer-requested target delivery date for vehicles in this contract line. May differ from actual delivery schedule.',
    `special_equipment_codes` STRING COMMENT 'Comma-separated list of special equipment or option codes included in the vehicle configuration for this line (e.g., towing package, advanced safety features).',
    `total_line_value` DECIMAL(18,2) COMMENT 'The total monetary value of this contract line, calculated as quantity_committed multiplied by unit_contracted_price.',
    `unit_contracted_price` DECIMAL(18,2) COMMENT 'The negotiated price per vehicle unit for this contract line. Represents the agreed-upon unit price before taxes and fees.',
    CONSTRAINT pk_fleet_contract_line PRIMARY KEY(`fleet_contract_line_id`)
) COMMENT 'Individual vehicle allocation line within a fleet contract specifying a particular nameplate, model year, trim, powertrain type (ICE/EV/HEV/PHEV), quantity committed, unit contracted price, and delivery window. Tracks fulfillment status per line against the parent fleet contract. Enables granular fleet order management and delivery scheduling.';

CREATE OR REPLACE TABLE `automotive_ecm`.`sales`.`msrp_schedule` (
    `msrp_schedule_id` BIGINT COMMENT 'Unique identifier for the MSRP schedule record. Primary key.',
    `company_code_id` BIGINT COMMENT 'Foreign key linking to finance.company_code. Business justification: MSRP schedules vary by legal entity due to different market regulations, tax structures, and pricing authority. Required for multi-entity OEMs with regional pricing and regulatory compliance.',
    `model_id` BIGINT COMMENT 'Reference to the vehicle nameplate and configuration this MSRP applies to.',
    `model_year_program_id` BIGINT COMMENT 'Foreign key linking to vehicle.vehicle_model_year_program. Business justification: MSRP schedules are issued per model year program in automotive manufacturing. Product pricing and launch teams require this FK to align pricing schedules with model year program milestones (SOP/EOP) a',
    `powertrain_spec_id` BIGINT COMMENT 'Foreign key linking to engineering.powertrain_spec. Business justification: MSRP schedules are published per powertrain configuration. EPA fuel economy values (epa_fuel_economy_city/highway/combined), powertrain warranty terms, and CAFE credit values on the MSRP sheet are sou',
    `powertrain_variant_id` BIGINT COMMENT 'Foreign key linking to vehicle.powertrain_variant. Business justification: MSRP schedules in automotive are published per powertrain variant (e.g., 2.0L ICE vs. hybrid vs. EV). Pricing analysts and product managers require this FK to generate accurate price books by powertra',
    `regulatory_requirement_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_requirement. Business justification: MSRP schedules incorporate jurisdiction-specific regulatory costs (gas guzzler tax, CAFE penalties, ZEV credit values, safety equipment mandates). Pricing teams reference regulatory requirements to ca',
    `sales_territory_id` BIGINT COMMENT 'Foreign key linking to sales.sales_territory. Business justification: MSRP schedules are market-region specific (msrp_schedule has market_region STRING). Normalizing market_region to a FK to sales_territory enables proper regional MSRP management, territory-level pricin',
    `sku_master_id` BIGINT COMMENT 'Foreign key linking to inventory.sku_master. Business justification: MSRP schedules price accessories, options, and parts. Pricing master data links vehicle options to inventory SKUs for consistent pricing across sales channels. Required for option package pricing, acc',
    `trim_level_id` BIGINT COMMENT 'Foreign key linking to vehicle.vehicle_trim_level. Business justification: MSRP schedules are published per trim level (LX, EX, Touring). Automotive pricing teams require this FK to join pricing schedules to authoritative trim definitions for price book generation and dealer',
    `vehicle_program_id` BIGINT COMMENT 'Foreign key linking to engineering.vehicle_program. Business justification: MSRP schedules are published per vehicle program for each model year. Pricing governance, CAFE compliance reporting, and dealer pricing bulletins require linking each MSRP schedule to the engineering ',
    `adas_level` STRING COMMENT 'SAE automation level for ADAS features included in this configuration: Level 0 (no automation) through Level 5 (full automation). Impacts pricing and regulatory compliance.. Valid values are `level_0|level_1|level_2|level_3|level_4|level_5`',
    `advertising_fee` DECIMAL(18,2) COMMENT 'Regional or national advertising fee included in the MSRP to fund cooperative advertising programs. Disclosed separately on buyers order.',
    `approved_by` STRING COMMENT 'Name or user ID of the pricing manager or executive who approved this MSRP schedule for publication.',
    `approved_timestamp` TIMESTAMP COMMENT 'Date and time when this MSRP schedule was approved for publication. Part of audit trail for pricing governance.',
    `base_msrp` DECIMAL(18,2) COMMENT 'The base MSRP for the vehicle configuration before destination charge, options, taxes, or fees. Expressed in the schedule currency.',
    `body_style` STRING COMMENT 'The body style of the vehicle configuration (sedan, coupe, SUV, truck, van, wagon, convertible, hatchback). [ENUM-REF-CANDIDATE: sedan|coupe|suv|truck|van|wagon|convertible|hatchback — 8 candidates stripped; promote to reference product]',
    `cafe_credit_value` DECIMAL(18,2) COMMENT 'CAFE credit or debit value for this vehicle configuration, used to calculate fleet-wide CAFE compliance. Positive for over-compliance, negative for under-compliance. Confidential regulatory data.',
    `country_code` STRING COMMENT 'Three-letter ISO 3166-1 alpha-3 country code where this MSRP applies (e.g., USA, CAN, MEX, DEU).. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this MSRP schedule record was first created in the system. Part of audit trail.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the MSRP amounts (e.g., USD, CAD, EUR, MXN).. Valid values are `^[A-Z]{3}$`',
    `destination_charge` DECIMAL(18,2) COMMENT 'Standard destination and delivery charge applied to transport the vehicle from manufacturing plant to dealer. Mandated by federal regulation to be uniform within a market region.',
    `effective_date` DATE COMMENT 'The date from which this MSRP schedule becomes effective. Typically aligned with model year launch or mid-cycle pricing adjustments.',
    `epa_fuel_economy_city` STRING COMMENT 'EPA-certified city fuel economy rating in miles per gallon (MPG) for ICE/HEV/PHEV, or MPGe (miles per gallon equivalent) for BEV/FCEV. Used for CAFE compliance and consumer disclosure.',
    `epa_fuel_economy_combined` STRING COMMENT 'EPA-certified combined fuel economy rating (55% city, 45% highway) in MPG or MPGe. Primary metric for CAFE and consumer comparison.',
    `epa_fuel_economy_highway` STRING COMMENT 'EPA-certified highway fuel economy rating in miles per gallon (MPG) or MPGe. Used for CAFE compliance and consumer disclosure.',
    `expiration_date` DATE COMMENT 'The date on which this MSRP schedule expires and is superseded by a new schedule. Null if currently active with no planned end date.',
    `gas_guzzler_tax` DECIMAL(18,2) COMMENT 'Federal gas guzzler tax applied to vehicles with EPA fuel economy below statutory thresholds. Zero if not applicable.',
    `holdback_amount` DECIMAL(18,2) COMMENT 'Manufacturer holdback amount paid to dealer after vehicle sale, typically 2-3% of MSRP. Used to support dealer cash flow and inventory financing. Confidential business data.',
    `invoice_price` DECIMAL(18,2) COMMENT 'The dealer invoice price (wholesale cost to dealer) for this vehicle configuration. Used for dealer margin calculations and incentive programs. Confidential business data.',
    `modified_timestamp` TIMESTAMP COMMENT 'Date and time when this MSRP schedule record was last modified. Updated on any change to pricing, dates, or status.',
    `nameplate` STRING COMMENT 'The vehicle nameplate or model name (e.g., Camry, F-150, Model 3). Denormalized for reporting convenience.',
    `ncap_safety_rating` STRING COMMENT 'Overall NCAP safety rating (1-5 stars) for this vehicle configuration. Used for marketing and consumer safety disclosure. Null if not yet rated.',
    `notes` STRING COMMENT 'Free-text notes or comments about this MSRP schedule, such as rationale for mid-cycle adjustments, competitive positioning, or special market conditions.',
    `option_package_code` STRING COMMENT 'Code representing the factory-installed option package or bundle (e.g., Premium Package, Technology Package, Winter Package). May be null for base configuration.',
    `powertrain_warranty_miles` STRING COMMENT 'Extended powertrain warranty duration in miles (e.g., 60,000 miles). Covers engine, transmission, drivetrain components.',
    `powertrain_warranty_months` STRING COMMENT 'Extended powertrain warranty duration in months (e.g., 60 months / 5 years). Typically longer than bumper-to-bumper warranty.',
    `published_timestamp` TIMESTAMP COMMENT 'Date and time when this MSRP schedule was published to dealer systems and public-facing channels (website, configurator, dealer portals).',
    `schedule_number` STRING COMMENT 'Business identifier for the MSRP schedule, typically assigned at model year launch or mid-cycle refresh. Format: MSRP-NNNNNN.. Valid values are `^MSRP-[0-9]{6,10}$`',
    `schedule_status` STRING COMMENT 'Current lifecycle status of the MSRP schedule: draft (pending approval), active (currently in effect), superseded (replaced by newer schedule), archived (historical record).. Valid values are `draft|active|superseded|archived`',
    `schedule_type` STRING COMMENT 'Type of MSRP schedule: launch (initial model year pricing), mid_cycle (mid-year adjustment), promotional (temporary special pricing), fleet (commercial/fleet pricing).. Valid values are `launch|mid_cycle|promotional|fleet`',
    `total_msrp` DECIMAL(18,2) COMMENT 'Total MSRP including base price, destination charge, gas guzzler tax, and any mandatory fees. Excludes dealer-installed accessories and local taxes.',
    `warranty_miles` STRING COMMENT 'Standard manufacturer warranty duration in miles (e.g., 36,000 miles). Warranty expires at the earlier of months or miles threshold.',
    `warranty_months` STRING COMMENT 'Standard manufacturer warranty duration in months (e.g., 36 months / 3 years). Used for warranty cost accrual and customer communication.',
    CONSTRAINT pk_msrp_schedule PRIMARY KEY(`msrp_schedule_id`)
) COMMENT 'Official Manufacturer Suggested Retail Price schedule for each vehicle nameplate, model year, trim level, and option package combination. Captures base MSRP, destination and delivery charge, gas guzzler tax (if applicable), effective date, market region, and currency. Serves as the pricing reference baseline for all quotes, orders, and incentive calculations. Updated at model year launch and mid-cycle adjustments.';

CREATE OR REPLACE TABLE `automotive_ecm`.`sales`.`sales_territory` (
    `sales_territory_id` BIGINT COMMENT 'Unique identifier for the sales territory. Primary key.',
    `rep_id` BIGINT COMMENT 'Identifier of the sales manager responsible for this territory. Links to employee or sales representative master data.',
    `annual_quota_revenue` DECIMAL(18,2) COMMENT 'Annual revenue quota target for this territory in the base currency. Represents expected sales value including MSRP and incentives.',
    `annual_quota_units` STRING COMMENT 'Annual sales quota for this territory measured in vehicle units. Used for performance tracking and incentive calculation.',
    `competitive_intensity` STRING COMMENT 'Assessment of competitive pressure in the territory based on number of competing brands, dealer density, and market share dynamics.. Valid values are `low|medium|high|very_high`',
    `country_code` STRING COMMENT 'Three-letter ISO 3166-1 alpha-3 country code where the territory operates (e.g., USA, CAN, MEX, DEU, CHN).. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this territory record was first created in the system. Used for audit trail and data lineage tracking.',
    `dealer_count` STRING COMMENT 'Number of authorized dealerships operating within this territory. Used for dealer network density analysis and coverage planning.',
    `distribution_channel` STRING COMMENT 'Primary distribution channel used in this territory. Direct represents OEM-owned sales, dealer represents franchised network, fleet serves corporate buyers, online covers digital sales, and export handles international shipments.. Valid values are `direct|dealer|fleet|online|export`',
    `district_code` STRING COMMENT 'Code identifying the district within the region. Represents a mid-level geographic or organizational subdivision.. Valid values are `^[A-Z0-9]{2,8}$`',
    `district_name` STRING COMMENT 'Name of the district (e.g., Northeast District, Southern California District).',
    `effective_end_date` DATE COMMENT 'Date when this territory configuration expires or is superseded. Null for currently active territories. Supports territory history and audit trails.',
    `effective_start_date` DATE COMMENT 'Date when this territory configuration becomes active. Used for territory realignment and historical tracking.',
    `fiscal_year` STRING COMMENT 'Fiscal year for which the territory configuration and quotas are defined (e.g., FY2024, FY2025). Aligns with corporate financial planning cycles.. Valid values are `^FY[0-9]{4}$`',
    `household_count` STRING COMMENT 'Number of households in the territory. Key metric for retail automotive market potential analysis.',
    `incentive_program_code` STRING COMMENT 'Code of the primary sales incentive program applicable to this territory. Links to dealer incentive and rebate programs.. Valid values are `^[A-Z0-9]{4,12}$`',
    `language_code` STRING COMMENT 'Primary language code for customer communication and marketing materials in this territory (e.g., en, es, fr, de, zh). Follows ISO 639-1 two-letter codes.. Valid values are `^[a-z]{2}$`',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this territory record. Supports change tracking and data quality monitoring.',
    `market_segment` STRING COMMENT 'Primary market segment focus for this territory. Determines product mix, pricing strategy, and customer targeting approach.. Valid values are `luxury|premium|mass_market|commercial|electric|performance`',
    `median_household_income` DECIMAL(18,2) COMMENT 'Median household income in the territory. Used for market segmentation and product mix planning (luxury vs. mass market).',
    `model_year_focus` STRING COMMENT 'Primary model year of vehicles being sold in this territory (e.g., MY2024, MY2025). Reflects inventory and product launch timing.. Valid values are `^MY[0-9]{4}$`',
    `modified_by_user` STRING COMMENT 'User ID or name of the person who last modified this territory record. Supports accountability and audit requirements.',
    `notes` STRING COMMENT 'Free-text notes capturing special considerations, territory-specific strategies, market conditions, or operational instructions for sales teams.',
    `population_count` STRING COMMENT 'Total population within the territory boundaries. Used for market sizing and potential customer base estimation.',
    `postal_code_range` STRING COMMENT 'Postal code or ZIP code ranges covered by this territory (e.g., 90001-90099, 91001-91199). Used for geographic assignment of leads and customers.',
    `priority` STRING COMMENT 'Strategic priority level assigned to this territory for resource allocation, investment, and management attention. Strategic territories receive highest focus and support.. Valid values are `strategic|high|medium|low`',
    `quota_currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for quota and revenue targets (e.g., USD, EUR, CNY, JPY).. Valid values are `^[A-Z]{3}$`',
    `region_code` STRING COMMENT 'Code identifying the parent region in the geographic hierarchy (e.g., national, regional, district level). Used for roll-up reporting and regional performance tracking.. Valid values are `^[A-Z0-9]{2,8}$`',
    `region_name` STRING COMMENT 'Name of the parent region (e.g., North America, Western Europe, Asia Pacific).',
    `regulatory_region` STRING COMMENT 'Regulatory jurisdiction or compliance region (e.g., EPA, CARB, Euro NCAP, UNECE). Determines applicable emissions standards, safety requirements, and homologation rules.',
    `sales_manager_name` STRING COMMENT 'Full name of the sales manager assigned to this territory for quick reference and reporting.',
    `sales_office_code` STRING COMMENT 'Code of the primary sales office serving this territory. Links to SAP SD sales organization structure.. Valid values are `^[A-Z0-9]{3,8}$`',
    `sales_organization_code` STRING COMMENT 'SAP sales organization code responsible for this territory. Represents the legal entity or business unit managing sales operations.. Valid values are `^[A-Z0-9]{4}$`',
    `state_province_code` STRING COMMENT 'State or province code within the country (e.g., CA for California, ON for Ontario, TX for Texas). May contain multiple values if territory spans multiple states.. Valid values are `^[A-Z0-9]{2,6}$`',
    `territory_code` STRING COMMENT 'Business identifier code for the sales territory used across systems and reporting. Typically alphanumeric format following regional coding standards.. Valid values are `^[A-Z0-9]{3,12}$`',
    `territory_name` STRING COMMENT 'Full descriptive name of the sales territory (e.g., Northeast Region - Metro, California Fleet Sales Zone).',
    `territory_status` STRING COMMENT 'Current operational status of the territory. Active territories are operational, inactive are closed, suspended are temporarily paused, planned are future territories, consolidating are merging with others, and splitting are being divided.. Valid values are `active|inactive|suspended|planned|consolidating|splitting`',
    `territory_type` STRING COMMENT 'Classification of the territory by sales channel or customer segment. Retail serves individual consumers, fleet serves corporate fleet buyers, export covers international markets, commercial targets business customers, government serves public sector, and dealer_network represents indirect sales through franchised dealers.. Valid values are `retail|fleet|export|commercial|government|dealer_network`',
    `time_zone` STRING COMMENT 'Primary time zone for the territory (e.g., America/New_York, Europe/Berlin, Asia/Shanghai). Used for scheduling and operational coordination.',
    `vehicle_category_focus` STRING COMMENT 'Primary vehicle categories sold in this territory (e.g., SUV, Truck, Sedan, EV, Commercial Vehicles). Reflects regional demand patterns and product strategy.',
    `vehicle_registration_count` STRING COMMENT 'Total number of registered vehicles in the territory. Indicates market saturation and replacement demand potential.',
    `zone_code` STRING COMMENT 'Code identifying the zone within the district. Represents the most granular level of the territory hierarchy.. Valid values are `^[A-Z0-9]{2,8}$`',
    `zone_name` STRING COMMENT 'Name of the zone (e.g., Manhattan Zone, Orange County Zone).',
    CONSTRAINT pk_sales_territory PRIMARY KEY(`sales_territory_id`)
) COMMENT 'Geographic or channel-based sales territory definition used to assign sales representatives, dealers, and regional managers to specific market areas. Captures territory code, territory name, region hierarchy (national/regional/district/zone), assigned sales manager, territory type (retail/fleet/export), and effective dates. Supports regional sales performance tracking and quota allocation.';

CREATE OR REPLACE TABLE `automotive_ecm`.`sales`.`rep` (
    `rep_id` BIGINT COMMENT 'Unique identifier for the OEM direct sales representative. Primary key.',
    `cost_center_id` BIGINT COMMENT 'Foreign key linking to finance.cost_center. Business justification: Sales reps are employees whose compensation and expenses must be allocated to cost centers for departmental P&L and headcount cost tracking. Standard HR-finance integration for automotive sales organi',
    `active_status` BOOLEAN COMMENT 'Indicates whether the sales representative is currently active and eligible for lead assignment and quota tracking. False indicates inactive (terminated, on leave, or transferred out of sales).',
    `certification_expiry_date` DATE COMMENT 'Date when the current sales certification expires and recertification is required. Null if certification does not expire or is not required for the role.',
    `certification_status` STRING COMMENT 'Status of the representatives sales certification or training completion. Certified indicates all required product, compliance, and sales methodology training is current. Used for dealer-facing role authorization and advanced product sales eligibility.. Valid values are `certified|in_progress|expired|not_required`',
    `commission_plan_code` STRING COMMENT 'Identifier for the incentive compensation plan assigned to the representative. Links to commission structure, bonus tiers, and payout rules in the compensation management system.. Valid values are `^[A-Z0-9]{4,10}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this sales representative record was first created in the system. Used for audit trail and data lineage tracking.',
    `crm_user_code` STRING COMMENT 'User identifier in Salesforce Automotive Cloud. Used to link sales activities, opportunities, and customer interactions to this representative.',
    `dealer_count` STRING COMMENT 'Number of dealerships assigned to this representative for relationship management and sales support. Applicable primarily to retail field reps and dealer development roles.',
    `email_address` STRING COMMENT 'Primary corporate email address for the sales representative. Used for customer communication and system notifications.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `first_name` STRING COMMENT 'Legal first name of the sales representative.',
    `fiscal_year` STRING COMMENT 'Fiscal year for which the current quota is assigned. Used for year-over-year performance comparison and quota planning.',
    `fleet_account_count` STRING COMMENT 'Number of fleet or commercial accounts assigned to this representative. Applicable primarily to fleet account managers and national account executives.',
    `hire_date` DATE COMMENT 'Date the sales representative was hired by the OEM. Used for tenure calculation and eligibility for tenure-based incentives.',
    `language_proficiency` STRING COMMENT 'Comma-separated list of languages the representative is proficient in (e.g., English, Spanish, Mandarin). Used for customer matching and international account assignment.',
    `last_name` STRING COMMENT 'Legal last name of the sales representative.',
    `mobile_number` STRING COMMENT 'Mobile phone number for field sales representative. Used for on-the-go communication and CRM mobile app access.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this sales representative record was last modified. Used for change tracking and data synchronization across systems.',
    `notes` STRING COMMENT 'Free-text field for additional information about the sales representative, such as special skills, awards, territory transition notes, or temporary assignment details.',
    `office_location` STRING COMMENT 'Primary office or branch location where the representative is based (e.g., Detroit HQ, Los Angeles Regional Office, Remote). Used for travel planning and regional coordination.',
    `performance_tier` STRING COMMENT 'Current performance classification based on quota attainment, customer satisfaction (NPS), and other KPIs. Used for recognition programs, incentive multipliers, and career development planning.. Valid values are `platinum|gold|silver|bronze|developing`',
    `phone_number` STRING COMMENT 'Primary business phone number for the sales representative. Used for dealer and customer contact.',
    `product_specialization` STRING COMMENT 'Primary product line or vehicle segment specialization (e.g., Electric Vehicles, Commercial Trucks, Luxury Sedans, SUVs, Performance Vehicles). Used for lead routing and expert assignment in Salesforce Automotive Cloud.',
    `quota_amount` DECIMAL(18,2) COMMENT 'Annual or period-based sales quota target assigned to the representative, expressed in the base currency. Used for performance measurement and incentive compensation calculation.',
    `quota_currency` STRING COMMENT 'Three-letter ISO 4217 currency code for the quota amount (e.g., USD, EUR, JPY). Supports multi-currency sales operations.. Valid values are `^[A-Z]{3}$`',
    `quota_period` STRING COMMENT 'Time period over which the quota is measured (annual, quarterly, or monthly). Aligns with fiscal year and performance review cycles.. Valid values are `annual|quarterly|monthly`',
    `region` STRING COMMENT 'Higher-level geographic region grouping multiple territories (e.g., North America, Europe, Asia Pacific, Latin America). Used for regional performance rollup and management hierarchy.',
    `sales_role` STRING COMMENT 'Functional sales role classification defining the representatives primary responsibility area. Retail field reps manage dealer relationships, fleet account managers handle commercial fleet sales, national account executives manage large enterprise accounts, export sales covers international markets, regional sales managers oversee territories, and dealer development focuses on dealer network expansion.. Valid values are `retail_field_rep|fleet_account_manager|national_account_executive|export_sales|regional_sales_manager|dealer_development`',
    `sales_start_date` DATE COMMENT 'Date the representative began their current sales role or territory assignment. May differ from hire_date if the employee transferred from another department or role.',
    `termination_date` DATE COMMENT 'Date the sales representatives employment or sales role ended. Null for active representatives. Used for historical performance analysis and territory reassignment.',
    `work_arrangement` STRING COMMENT 'Primary work location arrangement. Field-based representatives spend majority of time visiting dealers or customers; office-based work from regional offices; hybrid split time; remote work from home.. Valid values are `field_based|office_based|hybrid|remote`',
    CONSTRAINT pk_rep PRIMARY KEY(`rep_id`)
) COMMENT 'Master record for OEM direct sales representatives and field sales personnel responsible for managing dealer relationships, fleet accounts, and direct sales channels. Captures employee reference, assigned territory, sales role (retail field rep, fleet account manager, national account executive, export sales), quota assignment, certification status, and active status. Distinct from dealer-side sales staff managed in the dealer domain.';

CREATE OR REPLACE TABLE `automotive_ecm`.`sales`.`quota` (
    `quota_id` BIGINT COMMENT 'Unique identifier for the sales quota record. Primary key.',
    `rep_id` BIGINT COMMENT 'Foreign key reference to the entity assigned this quota. Interpretation depends on assignee_type: references sales_representative, dealership, territory, region, or team table.',
    `dealership_id` BIGINT COMMENT 'Foreign key reference to the dealership this quota is assigned to. Null if quota is not dealership-specific.',
    `fiscal_period_id` BIGINT COMMENT 'Foreign key linking to finance.fiscal_period. Business justification: Quotas are period-specific targets that must align with fiscal periods for performance measurement, commission calculation, and sales forecasting. Critical for automotive sales compensation and planni',
    `model_id` BIGINT COMMENT 'Foreign key linking to vehicle.model. Business justification: Sales quotas in automotive are set per model/nameplate (e.g., sell 500 Camrys in Q1). Sales operations and finance teams require this FK for quota-vs-actual reporting by model, dealer allocation pla',
    `model_year_program_id` BIGINT COMMENT 'Foreign key linking to vehicle.vehicle_model_year_program. Business justification: Automotive sales quotas are set per model year program (e.g., MY2024 launch quotas). Sales planning teams require this FK to align quota periods with model year program timelines and to normalize the ',
    `quota_rep_id` BIGINT COMMENT 'Foreign key reference to the individual sales representative this quota is assigned to. Null if quota is not individual-specific.',
    `quota_sales_representative_rep_id` BIGINT COMMENT 'Foreign key reference to the individual sales representative this quota is assigned to. Null if quota is not individual-specific.',
    `sales_territory_id` BIGINT COMMENT 'Foreign key reference to the sales territory this quota is assigned to. Null if quota is not territory-specific.',
    `vehicle_program_id` BIGINT COMMENT 'Foreign key linking to engineering.vehicle_program. Business justification: Annual sales quotas in automotive manufacturing are set per vehicle program and model year. Quota attainment reporting, sales planning, and incentive eligibility are all managed at the program level. ',
    `approval_status` STRING COMMENT 'Approval workflow status for the quota: pending (awaiting approval), approved (management approved), rejected (not approved), revision_required (sent back for changes).. Valid values are `pending|approved|rejected|revision_required`',
    `approved_by` STRING COMMENT 'Name or identifier of the manager or executive who approved this quota. Null if not yet approved.',
    `approved_date` DATE COMMENT 'Date on which the quota was approved by management. Null if not yet approved.',
    `assignee_name` STRING COMMENT 'Human-readable name of the quota assignee (representative name, dealer name, territory name, etc.) for reporting and display purposes.',
    `assignee_type` STRING COMMENT 'Type of entity to which the quota is assigned: sales_representative (individual salesperson), dealer (dealership entity), territory (geographic sales territory), region (multi-territory region), district (sales district), zone (sales zone), team (sales team). [ENUM-REF-CANDIDATE: sales_representative|dealer|territory|region|district|zone|team — 7 candidates stripped; promote to reference product]',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the quota record was first created in the system, in format yyyy-MM-ddTHH:mm:ss.SSSXXX.',
    `fiscal_month` STRING COMMENT 'Fiscal month within the fiscal year (M01 through M12). Null if quota is quarterly or annual.. Valid values are `^M(0[1-9]|1[0-2])$`',
    `fiscal_quarter` STRING COMMENT 'Fiscal quarter within the fiscal year (Q1, Q2, Q3, Q4). Null if quota is annual or monthly.. Valid values are `Q1|Q2|Q3|Q4`',
    `fiscal_year` STRING COMMENT 'Fiscal year for which the quota is assigned, in format FYYYYYYY (e.g., FY2024). Aligns with corporate fiscal calendar.. Valid values are `^FY[0-9]{4}$`',
    `incentive_eligible` BOOLEAN COMMENT 'Boolean flag indicating whether achievement of this quota makes the assignee eligible for incentive compensation (True) or is a non-incentivized target (False).',
    `modified_by` STRING COMMENT 'User identifier or name of the person who last modified the quota record.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the quota record was last modified, in format yyyy-MM-ddTHH:mm:ss.SSSXXX.',
    `notes` STRING COMMENT 'Free-text notes or comments regarding the quota assignment, special conditions, or context for sales management and reporting.',
    `period_end_date` DATE COMMENT 'End date of the quota performance period. Defines when quota measurement concludes.',
    `period_start_date` DATE COMMENT 'Start date of the quota performance period. Defines when quota measurement begins.',
    `powertrain_type` STRING COMMENT 'Powertrain type this quota applies to: ICE (Internal Combustion Engine), HEV (Hybrid Electric Vehicle), PHEV (Plug-in Hybrid Electric Vehicle), BEV (Battery Electric Vehicle), FCEV (Fuel Cell Electric Vehicle), all (applies to all powertrains). Null if not powertrain-specific.. Valid values are `ICE|HEV|PHEV|BEV|FCEV|all`',
    `product_line` STRING COMMENT 'Specific product line or brand this quota applies to (e.g., premium brand, economy brand, commercial line). Null if quota applies to all product lines.',
    `quota_name` STRING COMMENT 'Descriptive name for the quota assignment, e.g., Q1 FY2024 Northeast Region EV Target or Annual MY2024 Fleet Sales Goal.',
    `quota_number` STRING COMMENT 'Human-readable business identifier for the quota assignment, typically following format QTA-YYYYNNNN.. Valid values are `^QTA-[0-9]{8}$`',
    `quota_status` STRING COMMENT 'Current lifecycle status of the quota: draft (under review), approved (management approved), active (in effect), suspended (temporarily paused), closed (period ended), cancelled (voided before completion).. Valid values are `draft|approved|active|suspended|closed|cancelled`',
    `quota_type` STRING COMMENT 'Classification of the quota by measurement type: unit_volume (vehicle units sold), revenue (dollar/currency target), ev_mix (Electric Vehicle penetration percentage), fleet_penetration (commercial fleet sales), market_share (regional market share target), model_mix (specific model line targets).. Valid values are `unit_volume|revenue|ev_mix|fleet_penetration|market_share|model_mix`',
    `region_code` STRING COMMENT 'Three-letter geographic region code where quota applies (e.g., USA, CAN, MEX, DEU, GBR, CHN, JPN). Follows ISO 3166-1 alpha-3 country codes or internal regional codes.. Valid values are `^[A-Z]{3}$`',
    `revision_number` STRING COMMENT 'Version number of the quota record, incremented each time the quota is revised or adjusted. Initial version is 1.',
    `revision_reason` STRING COMMENT 'Business reason for the most recent revision to the quota (e.g., Market conditions adjustment, Territory realignment, Product launch delay). Null if no revisions have been made.',
    `sales_channel` STRING COMMENT 'Sales channel this quota applies to: retail (individual consumer sales), fleet (corporate fleet sales), commercial (business sales), government (government contracts), direct (OEM direct sales), dealer_network (indirect dealer sales). Null if applies to all channels.. Valid values are `retail|fleet|commercial|government|direct|dealer_network`',
    `target_unit` STRING COMMENT 'Unit of measure for the target_value: units (vehicle count), currency codes (USD, EUR, GBP, JPY, CNY), percentage (for mix/share targets), market_points (for market share basis points). [ENUM-REF-CANDIDATE: units|usd|eur|gbp|jpy|cny|percentage|market_points — 8 candidates stripped; promote to reference product]',
    `target_value` DECIMAL(18,2) COMMENT 'Numeric target value for the quota. Interpretation depends on quota_type: unit count for unit_volume, currency amount for revenue, percentage for ev_mix or market_share.',
    `threshold_minimum` DECIMAL(18,2) COMMENT 'Minimum performance threshold (as percentage of target_value or absolute value) required for any incentive payout or recognition. Null if no minimum threshold applies.',
    `threshold_stretch` DECIMAL(18,2) COMMENT 'Stretch performance threshold (as percentage of target_value or absolute value) that triggers maximum incentive payout or recognition. Null if no stretch threshold applies.',
    `vehicle_segment` STRING COMMENT 'Vehicle segment or category this quota applies to (e.g., sedan, SUV, truck, commercial, luxury). Null if quota applies to all segments. [ENUM-REF-CANDIDATE: sedan|suv|truck|crossover|van|commercial|luxury|compact|midsize — promote to reference product]',
    `created_by` STRING COMMENT 'User identifier or name of the person who created the quota record.',
    CONSTRAINT pk_quota PRIMARY KEY(`quota_id`)
) COMMENT 'Sales volume and revenue quota assigned to a sales representative, dealer, sales territory, or regional team for a defined period (monthly, quarterly, annual). Captures quota type (unit volume, revenue, EV mix, fleet penetration), target value, model year or fiscal period, assigned entity type and reference, and quota approval status. Enables sales performance tracking against targets.';

CREATE OR REPLACE TABLE `automotive_ecm`.`sales`.`activity` (
    `activity_id` BIGINT COMMENT 'Unique identifier for the sales activity record. Primary key.',
    `party_id` BIGINT COMMENT 'Reference to the customer account associated with this sales activity.',
    `activity_party_id` BIGINT COMMENT 'Reference to the customer account associated with this sales activity.',
    `rep_id` BIGINT COMMENT 'Reference to the sales representative who performed or is responsible for this sales activity.',
    `activity_sales_representative_rep_id` BIGINT COMMENT 'Reference to the sales representative who performed or is responsible for this sales activity.',
    `vin_registry_id` BIGINT COMMENT 'Reference to the specific vehicle that was the subject of this sales activity, if applicable (e.g., test drive, demo).',
    `activity_vin_registry_id` BIGINT COMMENT 'Reference to the specific vehicle that was the subject of this sales activity, if applicable (e.g., test drive, demo).',
    `campaign_id` BIGINT COMMENT 'Reference to the marketing campaign that generated or is associated with this sales activity.',
    `case_id` BIGINT COMMENT 'Foreign key linking to customer.case. Business justification: Sales follow-up activities often reference open customer service cases (warranty concerns, delivery issues). CRM workflows require linking sales activities to case records for coordinated customer exp',
    `contact_id` BIGINT COMMENT 'Reference to the specific contact person involved in this sales activity.',
    `contact_point_id` BIGINT COMMENT 'Reference to the specific contact person involved in this sales activity.',
    `dealership_id` BIGINT COMMENT 'Reference to the dealership location where the sales activity took place or is associated with.',
    `fleet_contract_id` BIGINT COMMENT 'Foreign key linking to sales.fleet_contract. Business justification: Fleet sales activities (contract negotiations, fleet account reviews, renewal discussions) are logged against fleet contracts. The activity table has is_fleet_sale boolean flag confirming fleet-relate',
    `lead_id` BIGINT COMMENT 'Reference to the lead record associated with this sales activity, if the activity is related to a lead.',
    `opportunity_id` BIGINT COMMENT 'Reference to the opportunity record associated with this sales activity, if the activity is related to an opportunity.',
    `quote_id` BIGINT COMMENT 'Foreign key linking to sales.quote. Business justification: Sales activities are frequently logged against specific quotes (e.g., quote presented, quote revised, customer reviewed quote). The activity table already has quote_presented boolean flag, confirming ',
    `sales_territory_id` BIGINT COMMENT 'Foreign key linking to sales.sales_territory. Business justification: Sales activity occurs within a sales territory; linking to sales_territory enables consistent reporting and removes the free‑text territory column.',
    `vehicle_order_id` BIGINT COMMENT 'Foreign key linking to sales.vehicle_order. Business justification: Post-order activities such as delivery coordination, order status follow-ups, and customer satisfaction calls are logged against vehicle orders. Adding vehicle_order_id to activity enables tracking of',
    `activity_date` DATE COMMENT 'The date on which the sales activity occurred or is scheduled to occur.',
    `activity_description` STRING COMMENT 'Detailed description or notes about the sales activity, capturing key discussion points, customer feedback, and action items.',
    `activity_number` STRING COMMENT 'Business-facing unique identifier for the sales activity, typically system-generated in format ACT-########.. Valid values are `^ACT-[0-9]{8}$`',
    `activity_status` STRING COMMENT 'Current lifecycle status of the sales activity indicating whether it is scheduled, in progress, completed, cancelled, no-show, or rescheduled.. Valid values are `scheduled|in_progress|completed|cancelled|no_show|rescheduled`',
    `activity_type` STRING COMMENT 'Classification of the sales activity indicating the nature of the interaction (call, email, test drive, demo, site visit, proposal presentation, follow-up, negotiation, or other). [ENUM-REF-CANDIDATE: call|email|meeting|test_drive|demo|site_visit|proposal_presentation|follow_up|negotiation|other — 10 candidates stripped; promote to reference product]',
    `competitor_mentioned` STRING COMMENT 'Name of any competitor brand or product mentioned by the customer during the sales activity.',
    `created_by_user_code` BIGINT COMMENT 'Reference to the user who created this sales activity record in the system.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this sales activity record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the estimated deal value (e.g., USD, EUR, GBP).. Valid values are `^[A-Z]{3}$`',
    `customer_sentiment` STRING COMMENT 'Qualitative assessment of the customers sentiment or attitude during the sales activity (very positive, positive, neutral, negative, very negative).. Valid values are `very_positive|positive|neutral|negative|very_negative`',
    `demo_completed` BOOLEAN COMMENT 'Boolean flag indicating whether a product demonstration was completed as part of this sales activity.',
    `duration_minutes` STRING COMMENT 'The duration of the sales activity in minutes, calculated or manually entered.',
    `end_timestamp` TIMESTAMP COMMENT 'The precise date and time when the sales activity ended or is scheduled to end.',
    `estimated_deal_value` DECIMAL(18,2) COMMENT 'Estimated monetary value of the potential deal discussed or progressed during this sales activity, in the base currency.',
    `fiscal_quarter` STRING COMMENT 'Fiscal quarter in which the sales activity occurred (Q1, Q2, Q3, Q4).. Valid values are `Q1|Q2|Q3|Q4`',
    `fiscal_year` STRING COMMENT 'Fiscal year in which the sales activity occurred, in format FY#### (e.g., FY2024).. Valid values are `^FY[0-9]{4}$`',
    `is_commercial_vehicle` BOOLEAN COMMENT 'Boolean flag indicating whether this sales activity involves a commercial vehicle.',
    `is_fleet_sale` BOOLEAN COMMENT 'Boolean flag indicating whether this sales activity is related to a fleet sale opportunity.',
    `location` STRING COMMENT 'Physical or virtual location where the sales activity took place (e.g., dealership showroom, customer site, online).',
    `model_year` STRING COMMENT 'Model year of the vehicle discussed in the sales activity, in format MY#### (e.g., MY2024).. Valid values are `^MY[0-9]{4}$`',
    `modified_by_user_code` BIGINT COMMENT 'Reference to the user who last modified this sales activity record in the system.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this sales activity record was last modified in the system.',
    `next_action` STRING COMMENT 'Description of the next planned action or follow-up step resulting from this sales activity.',
    `next_action_date` DATE COMMENT 'The scheduled date for the next follow-up action or activity.',
    `objection_raised` STRING COMMENT 'Description of any objections or concerns raised by the customer during the sales activity.',
    `objection_resolved` BOOLEAN COMMENT 'Boolean flag indicating whether the customers objection was successfully resolved during the activity.',
    `outcome` STRING COMMENT 'The result or outcome of the sales activity indicating whether it was successful, unsuccessful, pending, no contact made, customer interested, not interested, or callback requested. [ENUM-REF-CANDIDATE: successful|unsuccessful|pending|no_contact|interested|not_interested|callback_requested — 7 candidates stripped; promote to reference product]',
    `priority` STRING COMMENT 'Priority level assigned to the sales activity indicating its urgency and importance (low, medium, high, urgent).. Valid values are `low|medium|high|urgent`',
    `quote_presented` BOOLEAN COMMENT 'Boolean flag indicating whether a price quote or proposal was presented during this sales activity.',
    `region` STRING COMMENT 'Geographic sales region where the activity took place or is associated with.',
    `start_timestamp` TIMESTAMP COMMENT 'The precise date and time when the sales activity started or is scheduled to start.',
    `subject` STRING COMMENT 'Brief subject or title of the sales activity describing the purpose or topic of the interaction.',
    `test_drive_completed` BOOLEAN COMMENT 'Boolean flag indicating whether a test drive was completed as part of this sales activity.',
    CONSTRAINT pk_activity PRIMARY KEY(`activity_id`)
) COMMENT 'Record of a sales-related interaction or activity logged against a lead, opportunity, or customer account. Captures activity type (call, email, test drive, demo, site visit, proposal presentation), activity date and time, outcome, next action, associated opportunity or lead reference, and sales rep performing the activity. Sourced from Salesforce Automotive Cloud Activity/Task/Event objects. Supports pipeline velocity and conversion analysis.';

CREATE OR REPLACE TABLE `automotive_ecm`.`sales`.`campaign` (
    `campaign_id` BIGINT COMMENT 'Unique surrogate key for the sales campaign record.',
    `msrp_schedule_id` BIGINT COMMENT 'Foreign key linking to sales.msrp_schedule. Business justification: Campaigns target specific vehicle nameplates and model years (campaign has target_nameplate STRING and target_model_year INT). The msrp_schedule table is the authoritative source for nameplate/model y',
    `sales_territory_id` BIGINT COMMENT 'Foreign key linking to sales.sales_territory. Business justification: Campaigns are scoped to specific sales territories (campaign has territory_code STRING). Normalizing this to a FK to sales_territory enables proper territory-campaign association, territory-level camp',
    `vehicle_program_id` BIGINT COMMENT 'Foreign key linking to engineering.vehicle_program. Business justification: Marketing campaigns in automotive are planned around vehicle program launches and refreshes. Campaign budget allocation, KPI tracking (kpi_sales_volume_target), and launch readiness reporting are all ',
    `actual_spent_amount` DECIMAL(18,2) COMMENT 'Total amount actually spent on the campaign to date.',
    `actual_spent_currency` STRING COMMENT 'ISO 4217 currency code for the actual spent amount.. Valid values are `^[A-Z]{3}$`',
    `budget_amount` DECIMAL(18,2) COMMENT 'Planned monetary budget allocated to the campaign.',
    `budget_currency` STRING COMMENT 'ISO 4217 currency code for the budget amount.. Valid values are `^[A-Z]{3}$`',
    `campaign_description` STRING COMMENT 'Free‑form text describing the campaign goals, scope, and key messages.',
    `campaign_name` STRING COMMENT 'Human‑readable name of the campaign used in reporting and UI.',
    `campaign_status` STRING COMMENT 'Current lifecycle state of the campaign.. Valid values are `planned|active|completed|cancelled|on_hold`',
    `campaign_type` STRING COMMENT 'Category of the campaign indicating its strategic purpose.. Valid values are `model_launch|clearance|seasonal|conquest|loyalty`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the campaign record was first created.',
    `dealer_participation_flag` BOOLEAN COMMENT 'Indicates whether dealers are required to participate in the campaign.',
    `end_date` DATE COMMENT 'Date when the campaign is scheduled to end.',
    `kpi_market_share_actual` DECIMAL(18,2) COMMENT 'Observed market‑share percentage change achieved by the campaign.',
    `kpi_market_share_target` DECIMAL(18,2) COMMENT 'Target market‑share percentage increase for the nameplate during the campaign period.',
    `kpi_sales_volume_actual` STRING COMMENT 'Actual number of vehicles sold attributable to the campaign.',
    `kpi_sales_volume_target` STRING COMMENT 'Planned number of vehicles to be sold as a result of the campaign.',
    `marketing_channels` STRING COMMENT 'Primary channels used to deliver the campaign messaging.. Valid values are `dealer|online|direct|partner|mixed`',
    `notes` STRING COMMENT 'Free‑form field for any supplemental information or remarks.',
    `objective` STRING COMMENT 'High‑level business objective the campaign aims to achieve (e.g., increase sales volume, improve market share).',
    `priority` STRING COMMENT 'Business priority assigned to the campaign.. Valid values are `low|medium|high`',
    `region_code` STRING COMMENT 'Three‑letter ISO code representing the primary geographic region of the campaign.. Valid values are `^[A-Z]{3}$`',
    `start_date` DATE COMMENT 'Date when the campaign becomes active.',
    `target_customer_segment` STRING COMMENT 'Customer segment the campaign is designed for.. Valid values are `fleet|consumer|luxury|commercial`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the campaign record.',
    CONSTRAINT pk_campaign PRIMARY KEY(`campaign_id`)
) COMMENT 'Master record for a structured sales and marketing campaign targeting specific customer segments, nameplates, or market regions to drive vehicle sales. Captures campaign name, campaign type (model launch, clearance, seasonal, conquest, loyalty), target nameplate and model year, target customer segment, campaign period, budget allocation, participating dealers or regions, and campaign objectives. Distinct from incentive programs — campaigns coordinate multi-channel outreach while incentive programs define financial offers.';

-- ========= FOREIGN KEYS =========
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ADD CONSTRAINT `fk_sales_opportunity_campaign_id` FOREIGN KEY (`campaign_id`) REFERENCES `automotive_ecm`.`sales`.`campaign`(`campaign_id`);
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ADD CONSTRAINT `fk_sales_opportunity_rep_id` FOREIGN KEY (`rep_id`) REFERENCES `automotive_ecm`.`sales`.`rep`(`rep_id`);
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ADD CONSTRAINT `fk_sales_opportunity_opportunity_sales_representative_rep_id` FOREIGN KEY (`opportunity_sales_representative_rep_id`) REFERENCES `automotive_ecm`.`sales`.`rep`(`rep_id`);
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ADD CONSTRAINT `fk_sales_opportunity_sales_territory_id` FOREIGN KEY (`sales_territory_id`) REFERENCES `automotive_ecm`.`sales`.`sales_territory`(`sales_territory_id`);
ALTER TABLE `automotive_ecm`.`sales`.`lead` ADD CONSTRAINT `fk_sales_lead_campaign_id` FOREIGN KEY (`campaign_id`) REFERENCES `automotive_ecm`.`sales`.`campaign`(`campaign_id`);
ALTER TABLE `automotive_ecm`.`sales`.`lead` ADD CONSTRAINT `fk_sales_lead_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `automotive_ecm`.`sales`.`opportunity`(`opportunity_id`);
ALTER TABLE `automotive_ecm`.`sales`.`lead` ADD CONSTRAINT `fk_sales_lead_rep_id` FOREIGN KEY (`rep_id`) REFERENCES `automotive_ecm`.`sales`.`rep`(`rep_id`);
ALTER TABLE `automotive_ecm`.`sales`.`lead` ADD CONSTRAINT `fk_sales_lead_lead_rep_id` FOREIGN KEY (`lead_rep_id`) REFERENCES `automotive_ecm`.`sales`.`rep`(`rep_id`);
ALTER TABLE `automotive_ecm`.`sales`.`lead` ADD CONSTRAINT `fk_sales_lead_sales_territory_id` FOREIGN KEY (`sales_territory_id`) REFERENCES `automotive_ecm`.`sales`.`sales_territory`(`sales_territory_id`);
ALTER TABLE `automotive_ecm`.`sales`.`quote` ADD CONSTRAINT `fk_sales_quote_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `automotive_ecm`.`sales`.`opportunity`(`opportunity_id`);
ALTER TABLE `automotive_ecm`.`sales`.`quote` ADD CONSTRAINT `fk_sales_quote_rep_id` FOREIGN KEY (`rep_id`) REFERENCES `automotive_ecm`.`sales`.`rep`(`rep_id`);
ALTER TABLE `automotive_ecm`.`sales`.`quote` ADD CONSTRAINT `fk_sales_quote_sales_territory_id` FOREIGN KEY (`sales_territory_id`) REFERENCES `automotive_ecm`.`sales`.`sales_territory`(`sales_territory_id`);
ALTER TABLE `automotive_ecm`.`sales`.`quote` ADD CONSTRAINT `fk_sales_quote_vehicle_order_id` FOREIGN KEY (`vehicle_order_id`) REFERENCES `automotive_ecm`.`sales`.`vehicle_order`(`vehicle_order_id`);
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ADD CONSTRAINT `fk_sales_quote_line_msrp_schedule_id` FOREIGN KEY (`msrp_schedule_id`) REFERENCES `automotive_ecm`.`sales`.`msrp_schedule`(`msrp_schedule_id`);
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ADD CONSTRAINT `fk_sales_quote_line_quote_id` FOREIGN KEY (`quote_id`) REFERENCES `automotive_ecm`.`sales`.`quote`(`quote_id`);
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ADD CONSTRAINT `fk_sales_vehicle_order_fleet_contract_id` FOREIGN KEY (`fleet_contract_id`) REFERENCES `automotive_ecm`.`sales`.`fleet_contract`(`fleet_contract_id`);
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ADD CONSTRAINT `fk_sales_vehicle_order_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `automotive_ecm`.`sales`.`opportunity`(`opportunity_id`);
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ADD CONSTRAINT `fk_sales_vehicle_order_rep_id` FOREIGN KEY (`rep_id`) REFERENCES `automotive_ecm`.`sales`.`rep`(`rep_id`);
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ADD CONSTRAINT `fk_sales_vehicle_order_sales_territory_id` FOREIGN KEY (`sales_territory_id`) REFERENCES `automotive_ecm`.`sales`.`sales_territory`(`sales_territory_id`);
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ADD CONSTRAINT `fk_sales_order_line_fleet_contract_id` FOREIGN KEY (`fleet_contract_id`) REFERENCES `automotive_ecm`.`sales`.`fleet_contract`(`fleet_contract_id`);
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ADD CONSTRAINT `fk_sales_order_line_fleet_contract_line_id` FOREIGN KEY (`fleet_contract_line_id`) REFERENCES `automotive_ecm`.`sales`.`fleet_contract_line`(`fleet_contract_line_id`);
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ADD CONSTRAINT `fk_sales_order_line_rep_id` FOREIGN KEY (`rep_id`) REFERENCES `automotive_ecm`.`sales`.`rep`(`rep_id`);
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ADD CONSTRAINT `fk_sales_order_line_vehicle_order_id` FOREIGN KEY (`vehicle_order_id`) REFERENCES `automotive_ecm`.`sales`.`vehicle_order`(`vehicle_order_id`);
ALTER TABLE `automotive_ecm`.`sales`.`incentive_program` ADD CONSTRAINT `fk_sales_incentive_program_campaign_id` FOREIGN KEY (`campaign_id`) REFERENCES `automotive_ecm`.`sales`.`campaign`(`campaign_id`);
ALTER TABLE `automotive_ecm`.`sales`.`incentive_program` ADD CONSTRAINT `fk_sales_incentive_program_sales_territory_id` FOREIGN KEY (`sales_territory_id`) REFERENCES `automotive_ecm`.`sales`.`sales_territory`(`sales_territory_id`);
ALTER TABLE `automotive_ecm`.`sales`.`sales_incentive_claim` ADD CONSTRAINT `fk_sales_sales_incentive_claim_fleet_contract_id` FOREIGN KEY (`fleet_contract_id`) REFERENCES `automotive_ecm`.`sales`.`fleet_contract`(`fleet_contract_id`);
ALTER TABLE `automotive_ecm`.`sales`.`sales_incentive_claim` ADD CONSTRAINT `fk_sales_sales_incentive_claim_incentive_program_id` FOREIGN KEY (`incentive_program_id`) REFERENCES `automotive_ecm`.`sales`.`incentive_program`(`incentive_program_id`);
ALTER TABLE `automotive_ecm`.`sales`.`sales_incentive_claim` ADD CONSTRAINT `fk_sales_sales_incentive_claim_rep_id` FOREIGN KEY (`rep_id`) REFERENCES `automotive_ecm`.`sales`.`rep`(`rep_id`);
ALTER TABLE `automotive_ecm`.`sales`.`sales_incentive_claim` ADD CONSTRAINT `fk_sales_sales_incentive_claim_vehicle_order_id` FOREIGN KEY (`vehicle_order_id`) REFERENCES `automotive_ecm`.`sales`.`vehicle_order`(`vehicle_order_id`);
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ADD CONSTRAINT `fk_sales_fleet_contract_campaign_id` FOREIGN KEY (`campaign_id`) REFERENCES `automotive_ecm`.`sales`.`campaign`(`campaign_id`);
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ADD CONSTRAINT `fk_sales_fleet_contract_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `automotive_ecm`.`sales`.`opportunity`(`opportunity_id`);
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ADD CONSTRAINT `fk_sales_fleet_contract_rep_id` FOREIGN KEY (`rep_id`) REFERENCES `automotive_ecm`.`sales`.`rep`(`rep_id`);
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ADD CONSTRAINT `fk_sales_fleet_contract_line_fleet_contract_id` FOREIGN KEY (`fleet_contract_id`) REFERENCES `automotive_ecm`.`sales`.`fleet_contract`(`fleet_contract_id`);
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ADD CONSTRAINT `fk_sales_fleet_contract_line_msrp_schedule_id` FOREIGN KEY (`msrp_schedule_id`) REFERENCES `automotive_ecm`.`sales`.`msrp_schedule`(`msrp_schedule_id`);
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ADD CONSTRAINT `fk_sales_fleet_contract_line_rep_id` FOREIGN KEY (`rep_id`) REFERENCES `automotive_ecm`.`sales`.`rep`(`rep_id`);
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ADD CONSTRAINT `fk_sales_msrp_schedule_sales_territory_id` FOREIGN KEY (`sales_territory_id`) REFERENCES `automotive_ecm`.`sales`.`sales_territory`(`sales_territory_id`);
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ADD CONSTRAINT `fk_sales_sales_territory_rep_id` FOREIGN KEY (`rep_id`) REFERENCES `automotive_ecm`.`sales`.`rep`(`rep_id`);
ALTER TABLE `automotive_ecm`.`sales`.`quota` ADD CONSTRAINT `fk_sales_quota_rep_id` FOREIGN KEY (`rep_id`) REFERENCES `automotive_ecm`.`sales`.`rep`(`rep_id`);
ALTER TABLE `automotive_ecm`.`sales`.`quota` ADD CONSTRAINT `fk_sales_quota_quota_rep_id` FOREIGN KEY (`quota_rep_id`) REFERENCES `automotive_ecm`.`sales`.`rep`(`rep_id`);
ALTER TABLE `automotive_ecm`.`sales`.`quota` ADD CONSTRAINT `fk_sales_quota_quota_sales_representative_rep_id` FOREIGN KEY (`quota_sales_representative_rep_id`) REFERENCES `automotive_ecm`.`sales`.`rep`(`rep_id`);
ALTER TABLE `automotive_ecm`.`sales`.`quota` ADD CONSTRAINT `fk_sales_quota_sales_territory_id` FOREIGN KEY (`sales_territory_id`) REFERENCES `automotive_ecm`.`sales`.`sales_territory`(`sales_territory_id`);
ALTER TABLE `automotive_ecm`.`sales`.`activity` ADD CONSTRAINT `fk_sales_activity_rep_id` FOREIGN KEY (`rep_id`) REFERENCES `automotive_ecm`.`sales`.`rep`(`rep_id`);
ALTER TABLE `automotive_ecm`.`sales`.`activity` ADD CONSTRAINT `fk_sales_activity_activity_sales_representative_rep_id` FOREIGN KEY (`activity_sales_representative_rep_id`) REFERENCES `automotive_ecm`.`sales`.`rep`(`rep_id`);
ALTER TABLE `automotive_ecm`.`sales`.`activity` ADD CONSTRAINT `fk_sales_activity_campaign_id` FOREIGN KEY (`campaign_id`) REFERENCES `automotive_ecm`.`sales`.`campaign`(`campaign_id`);
ALTER TABLE `automotive_ecm`.`sales`.`activity` ADD CONSTRAINT `fk_sales_activity_fleet_contract_id` FOREIGN KEY (`fleet_contract_id`) REFERENCES `automotive_ecm`.`sales`.`fleet_contract`(`fleet_contract_id`);
ALTER TABLE `automotive_ecm`.`sales`.`activity` ADD CONSTRAINT `fk_sales_activity_lead_id` FOREIGN KEY (`lead_id`) REFERENCES `automotive_ecm`.`sales`.`lead`(`lead_id`);
ALTER TABLE `automotive_ecm`.`sales`.`activity` ADD CONSTRAINT `fk_sales_activity_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `automotive_ecm`.`sales`.`opportunity`(`opportunity_id`);
ALTER TABLE `automotive_ecm`.`sales`.`activity` ADD CONSTRAINT `fk_sales_activity_quote_id` FOREIGN KEY (`quote_id`) REFERENCES `automotive_ecm`.`sales`.`quote`(`quote_id`);
ALTER TABLE `automotive_ecm`.`sales`.`activity` ADD CONSTRAINT `fk_sales_activity_sales_territory_id` FOREIGN KEY (`sales_territory_id`) REFERENCES `automotive_ecm`.`sales`.`sales_territory`(`sales_territory_id`);
ALTER TABLE `automotive_ecm`.`sales`.`activity` ADD CONSTRAINT `fk_sales_activity_vehicle_order_id` FOREIGN KEY (`vehicle_order_id`) REFERENCES `automotive_ecm`.`sales`.`vehicle_order`(`vehicle_order_id`);
ALTER TABLE `automotive_ecm`.`sales`.`campaign` ADD CONSTRAINT `fk_sales_campaign_msrp_schedule_id` FOREIGN KEY (`msrp_schedule_id`) REFERENCES `automotive_ecm`.`sales`.`msrp_schedule`(`msrp_schedule_id`);
ALTER TABLE `automotive_ecm`.`sales`.`campaign` ADD CONSTRAINT `fk_sales_campaign_sales_territory_id` FOREIGN KEY (`sales_territory_id`) REFERENCES `automotive_ecm`.`sales`.`sales_territory`(`sales_territory_id`);

-- ========= TAGS =========
ALTER SCHEMA `automotive_ecm`.`sales` SET TAGS ('dbx_division' = 'business');
ALTER SCHEMA `automotive_ecm`.`sales` SET TAGS ('dbx_domain' = 'sales');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` SET TAGS ('dbx_subdomain' = 'pipeline_management');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Opportunity ID');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `campaign_id` SET TAGS ('dbx_business_glossary_term' = 'Campaign ID');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `company_code_id` SET TAGS ('dbx_business_glossary_term' = 'Company Code Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `dealership_id` SET TAGS ('dbx_business_glossary_term' = 'Dealership ID');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Customer ID');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `model_id` SET TAGS ('dbx_business_glossary_term' = 'Model Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `opportunity_party_id` SET TAGS ('dbx_business_glossary_term' = 'Customer ID');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `rep_id` SET TAGS ('dbx_business_glossary_term' = 'Sales Representative ID');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `opportunity_sales_representative_rep_id` SET TAGS ('dbx_business_glossary_term' = 'Sales Representative ID');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `opportunity_vehicle_model_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle ID');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `regulatory_requirement_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Requirement Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `sales_territory_id` SET TAGS ('dbx_business_glossary_term' = 'Sales Territory Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `vehicle_program_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Program Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `vin_registry_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle ID');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `actual_close_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Close Date');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `competitor_brand` SET TAGS ('dbx_business_glossary_term' = 'Competitor Brand');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `delivery_location` SET TAGS ('dbx_business_glossary_term' = 'Delivery Location');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `discount_amount` SET TAGS ('dbx_business_glossary_term' = 'Discount Amount');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `estimated_value` SET TAGS ('dbx_business_glossary_term' = 'Estimated Value');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `expected_close_date` SET TAGS ('dbx_business_glossary_term' = 'Expected Close Date');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `exterior_color` SET TAGS ('dbx_business_glossary_term' = 'Exterior Color');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `financing_type` SET TAGS ('dbx_business_glossary_term' = 'Financing Type');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `financing_type` SET TAGS ('dbx_value_regex' = 'cash|finance|lease|balloon|fleet_contract');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `fiscal_year` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Year (FY)');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `fiscal_year` SET TAGS ('dbx_value_regex' = '^FY[0-9]{4}$');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `fleet_size` SET TAGS ('dbx_business_glossary_term' = 'Fleet Size');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `incentive_amount` SET TAGS ('dbx_business_glossary_term' = 'Incentive Amount');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `interior_color` SET TAGS ('dbx_business_glossary_term' = 'Interior Color');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `is_active` SET TAGS ('dbx_business_glossary_term' = 'Is Active');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `is_won` SET TAGS ('dbx_business_glossary_term' = 'Is Won');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `last_activity_date` SET TAGS ('dbx_business_glossary_term' = 'Last Activity Date');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `lead_source` SET TAGS ('dbx_business_glossary_term' = 'Lead Source');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `loss_reason` SET TAGS ('dbx_business_glossary_term' = 'Loss Reason');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `model_year` SET TAGS ('dbx_business_glossary_term' = 'Model Year (MY)');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `model_year` SET TAGS ('dbx_value_regex' = '^MY[0-9]{4}$');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `msrp` SET TAGS ('dbx_business_glossary_term' = 'Manufacturer Suggested Retail Price (MSRP)');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `next_follow_up_date` SET TAGS ('dbx_business_glossary_term' = 'Next Follow-Up Date');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Opportunity Notes');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `opportunity_name` SET TAGS ('dbx_business_glossary_term' = 'Opportunity Name');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `opportunity_number` SET TAGS ('dbx_business_glossary_term' = 'Opportunity Number');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `opportunity_number` SET TAGS ('dbx_value_regex' = '^OPP-[0-9]{8}$');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `opportunity_type` SET TAGS ('dbx_business_glossary_term' = 'Opportunity Type');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `opportunity_type` SET TAGS ('dbx_value_regex' = 'retail|fleet|commercial|government|employee_purchase|demo');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `powertrain_type` SET TAGS ('dbx_business_glossary_term' = 'Powertrain Type');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `powertrain_type` SET TAGS ('dbx_value_regex' = 'ICE|HEV|PHEV|BEV|FCEV');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `priority` SET TAGS ('dbx_business_glossary_term' = 'Opportunity Priority');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `priority` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `probability` SET TAGS ('dbx_business_glossary_term' = 'Probability of Close');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `quote_date` SET TAGS ('dbx_business_glossary_term' = 'Quote Date');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `quote_generated` SET TAGS ('dbx_business_glossary_term' = 'Quote Generated');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `region` SET TAGS ('dbx_business_glossary_term' = 'Sales Region');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `sales_stage` SET TAGS ('dbx_business_glossary_term' = 'Sales Stage');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `test_drive_completed` SET TAGS ('dbx_business_glossary_term' = 'Test Drive Completed');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `test_drive_date` SET TAGS ('dbx_business_glossary_term' = 'Test Drive Date');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `trade_in_value` SET TAGS ('dbx_business_glossary_term' = 'Trade-In Value');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `vehicle_configuration` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Configuration');
ALTER TABLE `automotive_ecm`.`sales`.`opportunity` ALTER COLUMN `win_reason` SET TAGS ('dbx_business_glossary_term' = 'Win Reason');
ALTER TABLE `automotive_ecm`.`sales`.`lead` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `automotive_ecm`.`sales`.`lead` SET TAGS ('dbx_subdomain' = 'pipeline_management');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `lead_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Identifier');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `campaign_id` SET TAGS ('dbx_business_glossary_term' = 'Campaign Identifier');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Converted Opportunity Identifier');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `dealership_id` SET TAGS ('dbx_business_glossary_term' = 'Assigned Dealer Identifier');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `rep_id` SET TAGS ('dbx_business_glossary_term' = 'Assigned Owner Identifier');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `lead_dealership_id` SET TAGS ('dbx_business_glossary_term' = 'Assigned Dealer Identifier');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `lead_rep_id` SET TAGS ('dbx_business_glossary_term' = 'Assigned Owner Identifier');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `model_id` SET TAGS ('dbx_business_glossary_term' = 'Model Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Party Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `sales_territory_id` SET TAGS ('dbx_business_glossary_term' = 'Sales Territory Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `city` SET TAGS ('dbx_business_glossary_term' = 'City');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `city` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `company_name` SET TAGS ('dbx_business_glossary_term' = 'Company Name');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `converted_date` SET TAGS ('dbx_business_glossary_term' = 'Lead Converted Date');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Country Code');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Lead Created Timestamp');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `email_address` SET TAGS ('dbx_business_glossary_term' = 'Lead Email Address');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `email_address` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `email_address` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `email_address` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `estimated_budget_amount` SET TAGS ('dbx_business_glossary_term' = 'Estimated Budget Amount');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `financing_interest` SET TAGS ('dbx_business_glossary_term' = 'Financing Interest Flag');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `first_name` SET TAGS ('dbx_business_glossary_term' = 'Lead First Name');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `first_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `first_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `last_contact_date` SET TAGS ('dbx_business_glossary_term' = 'Last Contact Date');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `last_name` SET TAGS ('dbx_business_glossary_term' = 'Lead Last Name');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `last_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `last_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `lead_number` SET TAGS ('dbx_business_glossary_term' = 'Lead Number');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `lead_number` SET TAGS ('dbx_value_regex' = '^LEAD-[0-9]{8}$');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `lead_source` SET TAGS ('dbx_business_glossary_term' = 'Lead Source');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `lead_source` SET TAGS ('dbx_value_regex' = 'web|dealer_walk_in|event|referral|digital_campaign|phone_inquiry');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `lead_status` SET TAGS ('dbx_business_glossary_term' = 'Lead Status');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `lead_status` SET TAGS ('dbx_value_regex' = 'new|contacted|qualified|unqualified|converted|lost');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `lead_type` SET TAGS ('dbx_business_glossary_term' = 'Lead Type');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `lead_type` SET TAGS ('dbx_value_regex' = 'individual|fleet|commercial|government');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `lost_reason` SET TAGS ('dbx_business_glossary_term' = 'Lost Reason');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `mobile_number` SET TAGS ('dbx_business_glossary_term' = 'Lead Mobile Number');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `mobile_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `mobile_number` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `model_year_interest` SET TAGS ('dbx_business_glossary_term' = 'Model Year (MY) Interest');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `model_year_interest` SET TAGS ('dbx_value_regex' = '^(20[2-9][0-9]|MY[2-9][0-9])$');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Lead Modified Timestamp');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `next_follow_up_date` SET TAGS ('dbx_business_glossary_term' = 'Next Follow-Up Date');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Lead Notes');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `opt_in_email` SET TAGS ('dbx_business_glossary_term' = 'Email Opt-In Flag');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `opt_in_email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `opt_in_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `opt_in_phone` SET TAGS ('dbx_business_glossary_term' = 'Phone Opt-In Flag');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `opt_in_phone` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `opt_in_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `opt_in_sms` SET TAGS ('dbx_business_glossary_term' = 'SMS (Short Message Service) Opt-In Flag');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `phone_number` SET TAGS ('dbx_business_glossary_term' = 'Lead Phone Number');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `phone_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `phone_number` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `postal_code` SET TAGS ('dbx_business_glossary_term' = 'Postal Code');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `postal_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `purchase_timeframe` SET TAGS ('dbx_business_glossary_term' = 'Purchase Timeframe');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `purchase_timeframe` SET TAGS ('dbx_value_regex' = 'immediate|within_30_days|within_90_days|within_6_months|future');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `qualification_score` SET TAGS ('dbx_business_glossary_term' = 'Lead Qualification Score');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `rating` SET TAGS ('dbx_business_glossary_term' = 'Lead Rating');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `rating` SET TAGS ('dbx_value_regex' = 'hot|warm|cold');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `referral_source` SET TAGS ('dbx_business_glossary_term' = 'Referral Source');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `region` SET TAGS ('dbx_business_glossary_term' = 'Lead Region');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `state_province` SET TAGS ('dbx_business_glossary_term' = 'State or Province');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `state_province` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `state_province` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `street_address` SET TAGS ('dbx_business_glossary_term' = 'Street Address');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `street_address` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `street_address` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `test_drive_requested` SET TAGS ('dbx_business_glossary_term' = 'Test Drive Requested Flag');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `trade_in_interest` SET TAGS ('dbx_business_glossary_term' = 'Trade-In Interest Flag');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `unqualified_reason` SET TAGS ('dbx_business_glossary_term' = 'Unqualified Reason');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `vehicle_interest_category` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Interest Category');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `vehicle_interest_category` SET TAGS ('dbx_value_regex' = 'ICE|EV|HEV|PHEV');
ALTER TABLE `automotive_ecm`.`sales`.`lead` ALTER COLUMN `web_form_code` SET TAGS ('dbx_business_glossary_term' = 'Web Form Identifier');
ALTER TABLE `automotive_ecm`.`sales`.`quote` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `automotive_ecm`.`sales`.`quote` SET TAGS ('dbx_subdomain' = 'pipeline_management');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `quote_id` SET TAGS ('dbx_business_glossary_term' = 'Quote Identifier');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `company_code_id` SET TAGS ('dbx_business_glossary_term' = 'Company Code Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `configuration_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Configuration Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `finished_vehicle_stock_id` SET TAGS ('dbx_business_glossary_term' = 'Finished Vehicle Stock Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `homologation_record_id` SET TAGS ('dbx_business_glossary_term' = 'Homologation Record Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `model_id` SET TAGS ('dbx_business_glossary_term' = 'Model Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Sales Opportunity Identifier');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Customer Identifier');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `dealership_id` SET TAGS ('dbx_business_glossary_term' = 'Dealer Identifier');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `quote_dealership_id` SET TAGS ('dbx_business_glossary_term' = 'Dealer Identifier');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `quote_party_id` SET TAGS ('dbx_business_glossary_term' = 'Customer Identifier');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `vin_registry_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Identifier');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `quote_vin_registry_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Identifier');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `rep_id` SET TAGS ('dbx_business_glossary_term' = 'Sales Representative Identifier');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `sales_territory_id` SET TAGS ('dbx_business_glossary_term' = 'Sales Territory Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `sku_master_id` SET TAGS ('dbx_business_glossary_term' = 'Sku Master Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `vehicle_order_id` SET TAGS ('dbx_business_glossary_term' = 'Sales Order Identifier');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `vehicle_warranty_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Warranty Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `accessories_total` SET TAGS ('dbx_business_glossary_term' = 'Accessories Total Amount');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `apr_rate` SET TAGS ('dbx_business_glossary_term' = 'Annual Percentage Rate (APR)');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `conversion_date` SET TAGS ('dbx_business_glossary_term' = 'Quote Conversion Date');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `converted_to_order` SET TAGS ('dbx_business_glossary_term' = 'Converted to Order Flag');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `delivery_method` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Delivery Method');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `delivery_method` SET TAGS ('dbx_value_regex' = 'dealer_pickup|home_delivery|port_pickup|factory_pickup');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `destination_charge` SET TAGS ('dbx_business_glossary_term' = 'Destination and Delivery Charge');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `doc_fee` SET TAGS ('dbx_business_glossary_term' = 'Documentation Fee');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `down_payment` SET TAGS ('dbx_business_glossary_term' = 'Down Payment Amount');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `drivetrain` SET TAGS ('dbx_business_glossary_term' = 'Drivetrain Configuration');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `drivetrain` SET TAGS ('dbx_value_regex' = 'fwd|rwd|awd|4wd');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `engine_code` SET TAGS ('dbx_business_glossary_term' = 'Engine Code');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `engine_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{4,10}$');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `estimated_delivery_date` SET TAGS ('dbx_business_glossary_term' = 'Estimated Delivery Date');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Quote Expiry Date');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `exterior_color_code` SET TAGS ('dbx_business_glossary_term' = 'Exterior Color Code');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `exterior_color_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{3,6}$');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `financing_offered` SET TAGS ('dbx_business_glossary_term' = 'Financing Offered Flag');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `financing_term_months` SET TAGS ('dbx_business_glossary_term' = 'Financing Term in Months');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `incentive_total` SET TAGS ('dbx_business_glossary_term' = 'Total Incentive Amount');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `interior_color_code` SET TAGS ('dbx_business_glossary_term' = 'Interior Color Code');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `interior_color_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{3,6}$');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `lease_annual_mileage` SET TAGS ('dbx_business_glossary_term' = 'Lease Annual Mileage Allowance');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `lease_monthly_payment` SET TAGS ('dbx_business_glossary_term' = 'Lease Monthly Payment');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `lease_offered` SET TAGS ('dbx_business_glossary_term' = 'Lease Offered Flag');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `lease_term_months` SET TAGS ('dbx_business_glossary_term' = 'Lease Term in Months');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `model_year` SET TAGS ('dbx_business_glossary_term' = 'Model Year (MY)');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `modified_by` SET TAGS ('dbx_business_glossary_term' = 'Record Modified By User');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Modified Timestamp');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `monthly_payment` SET TAGS ('dbx_business_glossary_term' = 'Estimated Monthly Payment');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `msrp_base` SET TAGS ('dbx_business_glossary_term' = 'Manufacturer Suggested Retail Price (MSRP) Base');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `net_selling_price` SET TAGS ('dbx_business_glossary_term' = 'Net Selling Price');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Quote Notes');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `options_total` SET TAGS ('dbx_business_glossary_term' = 'Options Total Amount');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `powertrain_type` SET TAGS ('dbx_business_glossary_term' = 'Powertrain Type');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `powertrain_type` SET TAGS ('dbx_value_regex' = 'ice|hev|phev|bev|fcev');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `quote_date` SET TAGS ('dbx_business_glossary_term' = 'Quote Issue Date');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `quote_number` SET TAGS ('dbx_business_glossary_term' = 'Quote Number');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `quote_number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{8,20}$');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `quote_status` SET TAGS ('dbx_business_glossary_term' = 'Quote Status');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `quote_type` SET TAGS ('dbx_business_glossary_term' = 'Quote Type');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `registration_fee` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Registration Fee');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `rejection_reason` SET TAGS ('dbx_business_glossary_term' = 'Quote Rejection Reason');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `sales_channel` SET TAGS ('dbx_business_glossary_term' = 'Sales Channel');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `sales_channel` SET TAGS ('dbx_value_regex' = 'dealer|direct|online|fleet|broker');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `subtotal_amount` SET TAGS ('dbx_business_glossary_term' = 'Subtotal Amount');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Sales Tax Amount');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `total_amount_due` SET TAGS ('dbx_business_glossary_term' = 'Total Amount Due');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `trade_in_allowance` SET TAGS ('dbx_business_glossary_term' = 'Trade-In Allowance Amount');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `trade_in_payoff` SET TAGS ('dbx_business_glossary_term' = 'Trade-In Loan Payoff Amount');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `trade_in_payoff` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `trade_in_payoff` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `trade_in_vin` SET TAGS ('dbx_business_glossary_term' = 'Trade-In Vehicle Identification Number (VIN)');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `trade_in_vin` SET TAGS ('dbx_value_regex' = '^[A-HJ-NPR-Z0-9]{17}$');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `trade_in_vin` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `trade_in_vin` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `transmission_type` SET TAGS ('dbx_business_glossary_term' = 'Transmission Type');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `transmission_type` SET TAGS ('dbx_value_regex' = 'manual|automatic|cvt|dct|single_speed');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `trim_level` SET TAGS ('dbx_business_glossary_term' = 'Trim Level');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `version` SET TAGS ('dbx_business_glossary_term' = 'Quote Version Number');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `vin` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Identification Number (VIN)');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `vin` SET TAGS ('dbx_value_regex' = '^[A-HJ-NPR-Z0-9]{17}$');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `vin` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `vin` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`quote` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Record Created By User');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` SET TAGS ('dbx_subdomain' = 'pipeline_management');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `quote_line_id` SET TAGS ('dbx_business_glossary_term' = 'Quote Line Identifier (ID)');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `msrp_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Msrp Schedule Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `part_master_id` SET TAGS ('dbx_business_glossary_term' = 'Part Master Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `vin_registry_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Identifier (ID)');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `quote_id` SET TAGS ('dbx_business_glossary_term' = 'Quote Identifier (ID)');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `trim_option_availability_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Option Package Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `availability_status` SET TAGS ('dbx_business_glossary_term' = 'Availability Status');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `availability_status` SET TAGS ('dbx_value_regex' = 'in_stock|allocated|build_to_order|backordered|discontinued');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `commission_eligible` SET TAGS ('dbx_business_glossary_term' = 'Commission Eligible Flag');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `commission_rate` SET TAGS ('dbx_business_glossary_term' = 'Commission Rate');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `commission_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `cost_amount` SET TAGS ('dbx_business_glossary_term' = 'Cost Amount');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `cost_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `delivery_date` SET TAGS ('dbx_business_glossary_term' = 'Delivery Date');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `discount_amount` SET TAGS ('dbx_business_glossary_term' = 'Discount Amount');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `discount_percentage` SET TAGS ('dbx_business_glossary_term' = 'Discount Percentage');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `extended_price` SET TAGS ('dbx_business_glossary_term' = 'Extended Price');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `exterior_color_code` SET TAGS ('dbx_business_glossary_term' = 'Exterior Color Code');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `incentive_amount` SET TAGS ('dbx_business_glossary_term' = 'Incentive Amount');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `incentive_description` SET TAGS ('dbx_business_glossary_term' = 'Incentive Description');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `interior_color_code` SET TAGS ('dbx_business_glossary_term' = 'Interior Color Code');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `line_number` SET TAGS ('dbx_business_glossary_term' = 'Line Number');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `line_status` SET TAGS ('dbx_business_glossary_term' = 'Line Status');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `line_status` SET TAGS ('dbx_value_regex' = 'draft|active|approved|rejected|cancelled|converted');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `line_total` SET TAGS ('dbx_business_glossary_term' = 'Line Total');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `line_type` SET TAGS ('dbx_business_glossary_term' = 'Line Type');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `list_price` SET TAGS ('dbx_business_glossary_term' = 'List Price');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `margin_amount` SET TAGS ('dbx_business_glossary_term' = 'Margin Amount');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `margin_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `model_code` SET TAGS ('dbx_business_glossary_term' = 'Model Code');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `model_year` SET TAGS ('dbx_business_glossary_term' = 'Model Year (MY)');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `modified_by` SET TAGS ('dbx_business_glossary_term' = 'Modified By User');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Line Notes');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `product_code` SET TAGS ('dbx_business_glossary_term' = 'Product Code');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `product_description` SET TAGS ('dbx_business_glossary_term' = 'Product Description');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `quantity` SET TAGS ('dbx_business_glossary_term' = 'Quantity');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `rejection_reason` SET TAGS ('dbx_business_glossary_term' = 'Rejection Reason');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Tax Amount');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `tax_code` SET TAGS ('dbx_business_glossary_term' = 'Tax Code');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `tax_rate` SET TAGS ('dbx_business_glossary_term' = 'Tax Rate');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `unit_of_measure` SET TAGS ('dbx_business_glossary_term' = 'Unit of Measure (UOM)');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `unit_price` SET TAGS ('dbx_business_glossary_term' = 'Unit Price');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `vin` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Identification Number (VIN)');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `vin` SET TAGS ('dbx_value_regex' = '^[A-HJ-NPR-Z0-9]{17}$');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `vin` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`quote_line` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By User');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` SET TAGS ('dbx_subdomain' = 'order_fulfillment');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `vehicle_order_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Order Identifier');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `company_code_id` SET TAGS ('dbx_business_glossary_term' = 'Company Code Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `configuration_id` SET TAGS ('dbx_business_glossary_term' = 'Configuration Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `contact_point_id` SET TAGS ('dbx_business_glossary_term' = 'Delivery Address Identifier');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `contact_point_id` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `contact_point_id` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `cost_center_id` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `dealership_id` SET TAGS ('dbx_business_glossary_term' = 'Dealership Identifier');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `fiscal_period_id` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Period Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `fleet_contract_id` SET TAGS ('dbx_business_glossary_term' = 'Fleet Contract Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `homologation_record_id` SET TAGS ('dbx_business_glossary_term' = 'Homologation Record Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `model_id` SET TAGS ('dbx_business_glossary_term' = 'Model Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Opportunity Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Customer Identifier');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `rep_id` SET TAGS ('dbx_business_glossary_term' = 'Sales Representative Identifier');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `vin_registry_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Identifier');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `profit_center_id` SET TAGS ('dbx_business_glossary_term' = 'Profit Center Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `sales_territory_id` SET TAGS ('dbx_business_glossary_term' = 'Sales Territory Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `vehicle_program_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Program Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `actual_delivery_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Delivery Date');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `build_week` SET TAGS ('dbx_business_glossary_term' = 'Build Week');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `build_week` SET TAGS ('dbx_value_regex' = '^(19|20)d{2}W(0[1-9]|[1-4][0-9]|5[0-3])$');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `cancellation_reason` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Reason');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `committed_delivery_date` SET TAGS ('dbx_business_glossary_term' = 'Committed Delivery Date');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `confirmed_date` SET TAGS ('dbx_business_glossary_term' = 'Order Confirmation Date');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `delivery_location` SET TAGS ('dbx_business_glossary_term' = 'Delivery Location Type');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `delivery_location` SET TAGS ('dbx_value_regex' = 'dealer|customer_address|port|distribution_center');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `discount_amount` SET TAGS ('dbx_business_glossary_term' = 'Discount Amount');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `exterior_color_code` SET TAGS ('dbx_business_glossary_term' = 'Exterior Color Code');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `exterior_color_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{3,10}$');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `financing_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Financing Reference Number');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `financing_reference_number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{8,20}$');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `financing_reference_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `financing_reference_number` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `financing_type` SET TAGS ('dbx_business_glossary_term' = 'Financing Type');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `financing_type` SET TAGS ('dbx_value_regex' = 'captive|third_party|bank|credit_union|none');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `fiscal_year` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Year (FY)');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `fiscal_year` SET TAGS ('dbx_value_regex' = '^FY(19|20)d{2}$');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `incentive_amount` SET TAGS ('dbx_business_glossary_term' = 'Incentive Amount');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `interior_color_code` SET TAGS ('dbx_business_glossary_term' = 'Interior Color Code');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `interior_color_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{3,10}$');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `model_year` SET TAGS ('dbx_business_glossary_term' = 'Model Year (MY)');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `model_year` SET TAGS ('dbx_value_regex' = '^(19|20)d{2}$');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `msrp` SET TAGS ('dbx_business_glossary_term' = 'Manufacturer Suggested Retail Price (MSRP)');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `order_date` SET TAGS ('dbx_business_glossary_term' = 'Order Date');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `order_number` SET TAGS ('dbx_business_glossary_term' = 'Order Number');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `order_number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{10,20}$');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `order_status` SET TAGS ('dbx_business_glossary_term' = 'Order Status');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `order_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Order Timestamp');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `order_type` SET TAGS ('dbx_business_glossary_term' = 'Order Type');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `order_type` SET TAGS ('dbx_value_regex' = 'retail|fleet|government|export|demo|internal');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'cash|finance|lease|fleet_contract');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `powertrain_type` SET TAGS ('dbx_business_glossary_term' = 'Powertrain Type');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `powertrain_type` SET TAGS ('dbx_value_regex' = 'ICE|HEV|PHEV|BEV|FCEV');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `priority_code` SET TAGS ('dbx_business_glossary_term' = 'Order Priority Code');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `priority_code` SET TAGS ('dbx_value_regex' = 'standard|expedited|vip|fleet_priority');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `production_plant_code` SET TAGS ('dbx_business_glossary_term' = 'Production Plant Code');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `production_plant_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{3,6}$');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `requested_delivery_date` SET TAGS ('dbx_business_glossary_term' = 'Requested Delivery Date');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `sales_channel` SET TAGS ('dbx_business_glossary_term' = 'Sales Channel');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `sales_channel` SET TAGS ('dbx_value_regex' = 'dealer|direct|online|fleet_sales|broker');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `selling_price` SET TAGS ('dbx_business_glossary_term' = 'Selling Price');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `source_system` SET TAGS ('dbx_business_glossary_term' = 'Source System');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `source_system` SET TAGS ('dbx_value_regex' = 'SAP_SD|Salesforce|DMS|Web_Portal|Mobile_App');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `special_instructions` SET TAGS ('dbx_business_glossary_term' = 'Special Instructions');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Tax Amount');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `total_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Order Amount');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `trade_in_value` SET TAGS ('dbx_business_glossary_term' = 'Trade-In Value');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `vin` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Identification Number (VIN)');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `vin` SET TAGS ('dbx_value_regex' = '^[A-HJ-NPR-Z0-9]{17}$');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `vin` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`vehicle_order` ALTER COLUMN `vin` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` SET TAGS ('dbx_subdomain' = 'order_fulfillment');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `order_line_id` SET TAGS ('dbx_business_glossary_term' = 'Order Line Identifier (ID)');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `configuration_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Configuration Identifier (ID)');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `dealership_id` SET TAGS ('dbx_business_glossary_term' = 'Dealership Identifier (ID)');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `fleet_contract_id` SET TAGS ('dbx_business_glossary_term' = 'Fleet Contract Identifier (ID)');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `fleet_contract_line_id` SET TAGS ('dbx_business_glossary_term' = 'Fleet Contract Line Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `gl_account_id` SET TAGS ('dbx_business_glossary_term' = 'Gl Account Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `part_master_id` SET TAGS ('dbx_business_glossary_term' = 'Part Master Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `rep_id` SET TAGS ('dbx_business_glossary_term' = 'Sales Representative Identifier (ID)');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `vin_registry_id` SET TAGS ('dbx_business_glossary_term' = 'Trade-In Vehicle Identifier (ID)');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `sku_master_id` SET TAGS ('dbx_business_glossary_term' = 'Sku Master Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `tertiary_order_vin_registry_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Identifier (ID)');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `trim_option_availability_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Option Package Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `vehicle_order_id` SET TAGS ('dbx_business_glossary_term' = 'Order Identifier (ID)');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `actual_delivery_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Delivery Date');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `actual_production_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Production Date');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `allocation_date` SET TAGS ('dbx_business_glossary_term' = 'Allocation Date');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `cancellation_reason` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Reason');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `discount_amount` SET TAGS ('dbx_business_glossary_term' = 'Discount Amount');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `estimated_delivery_date` SET TAGS ('dbx_business_glossary_term' = 'Estimated Delivery Date');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `exterior_color_code` SET TAGS ('dbx_business_glossary_term' = 'Exterior Color Code');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `financing_type` SET TAGS ('dbx_business_glossary_term' = 'Financing Type');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `financing_type` SET TAGS ('dbx_value_regex' = 'cash|loan|lease|fleet_lease|captive_finance');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `fleet_indicator` SET TAGS ('dbx_business_glossary_term' = 'Fleet Order Indicator');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `incentive_amount` SET TAGS ('dbx_business_glossary_term' = 'Incentive Amount');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `interior_color_code` SET TAGS ('dbx_business_glossary_term' = 'Interior Color Code');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `line_number` SET TAGS ('dbx_business_glossary_term' = 'Line Item Number');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `line_status` SET TAGS ('dbx_business_glossary_term' = 'Line Item Status');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `line_total` SET TAGS ('dbx_business_glossary_term' = 'Line Total Amount');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `line_type` SET TAGS ('dbx_business_glossary_term' = 'Line Item Type');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `list_price` SET TAGS ('dbx_business_glossary_term' = 'List Price');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `model_code` SET TAGS ('dbx_business_glossary_term' = 'Model Code');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `model_year` SET TAGS ('dbx_business_glossary_term' = 'Model Year (MY)');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `net_price` SET TAGS ('dbx_business_glossary_term' = 'Net Price');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `plant_code` SET TAGS ('dbx_business_glossary_term' = 'Manufacturing Plant Code');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `powertrain_type` SET TAGS ('dbx_business_glossary_term' = 'Powertrain Type');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `powertrain_type` SET TAGS ('dbx_value_regex' = 'ICE|HEV|PHEV|BEV|FCEV');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `product_description` SET TAGS ('dbx_business_glossary_term' = 'Product Description');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `quantity` SET TAGS ('dbx_business_glossary_term' = 'Quantity');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `scheduled_production_date` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Production Date');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `ship_date` SET TAGS ('dbx_business_glossary_term' = 'Ship Date');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `special_instructions` SET TAGS ('dbx_business_glossary_term' = 'Special Instructions');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Tax Amount');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `unit_of_measure` SET TAGS ('dbx_business_glossary_term' = 'Unit of Measure (UOM)');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `unit_of_measure` SET TAGS ('dbx_value_regex' = 'EA|SET|KIT|HR|UNIT');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `vin` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Identification Number (VIN)');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `vin` SET TAGS ('dbx_value_regex' = '^[A-HJ-NPR-Z0-9]{17}$');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `vin` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`order_line` ALTER COLUMN `vin` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`incentive_program` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `automotive_ecm`.`sales`.`incentive_program` SET TAGS ('dbx_subdomain' = 'incentive_programs');
ALTER TABLE `automotive_ecm`.`sales`.`incentive_program` ALTER COLUMN `incentive_program_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Key for sales_incentive_program');
ALTER TABLE `automotive_ecm`.`sales`.`incentive_program` ALTER COLUMN `campaign_id` SET TAGS ('dbx_business_glossary_term' = 'Campaign Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`incentive_program` ALTER COLUMN `model_id` SET TAGS ('dbx_business_glossary_term' = 'Model Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`incentive_program` ALTER COLUMN `model_year_program_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Model Year Program Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`incentive_program` ALTER COLUMN `regulatory_requirement_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Requirement Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`incentive_program` ALTER COLUMN `sales_territory_id` SET TAGS ('dbx_business_glossary_term' = 'Sales Territory Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`incentive_program` ALTER COLUMN `vehicle_program_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Program Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`sales_incentive_claim` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `automotive_ecm`.`sales`.`sales_incentive_claim` SET TAGS ('dbx_subdomain' = 'incentive_programs');
ALTER TABLE `automotive_ecm`.`sales`.`sales_incentive_claim` ALTER COLUMN `sales_incentive_claim_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Key for sales_incentive_claim');
ALTER TABLE `automotive_ecm`.`sales`.`sales_incentive_claim` ALTER COLUMN `cost_center_id` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`sales_incentive_claim` ALTER COLUMN `finished_vehicle_stock_id` SET TAGS ('dbx_business_glossary_term' = 'Finished Vehicle Stock Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`sales_incentive_claim` ALTER COLUMN `fleet_contract_id` SET TAGS ('dbx_business_glossary_term' = 'Fleet Contract Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`sales_incentive_claim` ALTER COLUMN `gl_account_id` SET TAGS ('dbx_business_glossary_term' = 'Gl Account Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`sales_incentive_claim` ALTER COLUMN `incentive_program_id` SET TAGS ('dbx_business_glossary_term' = 'Sales Incentive Program Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`sales_incentive_claim` ALTER COLUMN `payment_id` SET TAGS ('dbx_business_glossary_term' = 'Payment Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`sales_incentive_claim` ALTER COLUMN `rep_id` SET TAGS ('dbx_business_glossary_term' = 'Rep Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`sales_incentive_claim` ALTER COLUMN `vehicle_order_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Order Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` SET TAGS ('dbx_subdomain' = 'fleet_business');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `fleet_contract_id` SET TAGS ('dbx_business_glossary_term' = 'Fleet Contract Identifier (ID)');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `campaign_id` SET TAGS ('dbx_business_glossary_term' = 'Campaign Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `company_code_id` SET TAGS ('dbx_business_glossary_term' = 'Company Code Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Opportunity Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `organization_account_id` SET TAGS ('dbx_business_glossary_term' = 'Fleet Account Identifier (ID)');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Customer Identifier (ID)');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `rep_id` SET TAGS ('dbx_business_glossary_term' = 'Fleet Sales Representative Identifier (ID)');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `regulatory_requirement_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Requirement Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `vehicle_program_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Program Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `annual_mileage_allowance` SET TAGS ('dbx_business_glossary_term' = 'Annual Mileage Allowance');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Contract Approval Date');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `approved_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Approved By User Identifier (ID)');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `approved_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `approved_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `auto_renewal_flag` SET TAGS ('dbx_business_glossary_term' = 'Auto-Renewal Flag');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `base_discount_percentage` SET TAGS ('dbx_business_glossary_term' = 'Base Fleet Discount Percentage');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `base_discount_percentage` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `committed_volume` SET TAGS ('dbx_business_glossary_term' = 'Committed Vehicle Volume');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `contract_name` SET TAGS ('dbx_business_glossary_term' = 'Fleet Contract Name');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `contract_number` SET TAGS ('dbx_business_glossary_term' = 'Fleet Contract Number');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `contract_number` SET TAGS ('dbx_value_regex' = '^FC-[0-9]{8}$');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `contract_signed_date` SET TAGS ('dbx_business_glossary_term' = 'Contract Signed Date');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `contract_status` SET TAGS ('dbx_business_glossary_term' = 'Fleet Contract Status');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `contract_term_months` SET TAGS ('dbx_business_glossary_term' = 'Contract Term in Months');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `contract_type` SET TAGS ('dbx_business_glossary_term' = 'Fleet Contract Type');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `contract_type` SET TAGS ('dbx_value_regex' = 'corporate|government|rental|utility|leasing|dealer_demo');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `contract_value_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Contract Value Amount');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (ISO 4217)');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `delivered_volume` SET TAGS ('dbx_business_glossary_term' = 'Delivered Vehicle Volume');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `delivery_schedule_type` SET TAGS ('dbx_business_glossary_term' = 'Delivery Schedule Type');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `delivery_schedule_type` SET TAGS ('dbx_value_regex' = 'single_delivery|staggered|quarterly|annual|on_demand');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `effective_end_date` SET TAGS ('dbx_business_glossary_term' = 'Contract Effective End Date');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `effective_start_date` SET TAGS ('dbx_business_glossary_term' = 'Contract Effective Start Date');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `eligible_model_years` SET TAGS ('dbx_business_glossary_term' = 'Eligible Model Years (MY)');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `eligible_powertrain_types` SET TAGS ('dbx_business_glossary_term' = 'Eligible Powertrain Types');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `financing_type` SET TAGS ('dbx_business_glossary_term' = 'Fleet Financing Type');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `financing_type` SET TAGS ('dbx_value_regex' = 'cash_purchase|lease|captive_finance|third_party_finance|mixed');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `government_contract_flag` SET TAGS ('dbx_business_glossary_term' = 'Government Contract Flag');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `gsa_schedule_number` SET TAGS ('dbx_business_glossary_term' = 'General Services Administration (GSA) Schedule Number');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `lease_term_months` SET TAGS ('dbx_business_glossary_term' = 'Lease Term in Months');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `maintenance_included_flag` SET TAGS ('dbx_business_glossary_term' = 'Maintenance Included Flag');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `minimum_order_quantity` SET TAGS ('dbx_business_glossary_term' = 'Minimum Order Quantity (MOQ)');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `multi_location_delivery_flag` SET TAGS ('dbx_business_glossary_term' = 'Multi-Location Delivery Flag');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `national_fleet_account_flag` SET TAGS ('dbx_business_glossary_term' = 'National Fleet Account Flag');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `payment_terms` SET TAGS ('dbx_business_glossary_term' = 'Payment Terms');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `payment_terms` SET TAGS ('dbx_value_regex' = 'net_30|net_60|net_90|prepayment|milestone|custom');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `primary_delivery_location` SET TAGS ('dbx_business_glossary_term' = 'Primary Delivery Location');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `remaining_volume` SET TAGS ('dbx_business_glossary_term' = 'Remaining Vehicle Volume');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `renewal_eligible_flag` SET TAGS ('dbx_business_glossary_term' = 'Renewal Eligible Flag');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `sales_region` SET TAGS ('dbx_business_glossary_term' = 'Sales Region');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `special_terms_notes` SET TAGS ('dbx_business_glossary_term' = 'Special Terms and Conditions Notes');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Contract Termination Date');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `termination_reason` SET TAGS ('dbx_business_glossary_term' = 'Contract Termination Reason');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `volume_tier_discount_percentage` SET TAGS ('dbx_business_glossary_term' = 'Volume Tier Discount Percentage');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `volume_tier_discount_percentage` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract` ALTER COLUMN `warranty_extension_months` SET TAGS ('dbx_business_glossary_term' = 'Warranty Extension Period in Months');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` SET TAGS ('dbx_subdomain' = 'fleet_business');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `fleet_contract_line_id` SET TAGS ('dbx_business_glossary_term' = 'Fleet Contract Line Identifier (ID)');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `dealership_id` SET TAGS ('dbx_business_glossary_term' = 'Dealership Identifier (ID)');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `fleet_contract_id` SET TAGS ('dbx_business_glossary_term' = 'Fleet Contract Identifier (ID)');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `homologation_record_id` SET TAGS ('dbx_business_glossary_term' = 'Homologation Record Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `model_id` SET TAGS ('dbx_business_glossary_term' = 'Model Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `model_year_program_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Model Year Program Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `msrp_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Msrp Schedule Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `rep_id` SET TAGS ('dbx_business_glossary_term' = 'Sales Representative Identifier (ID)');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `vin_registry_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Identifier (ID)');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `service_contract_id` SET TAGS ('dbx_business_glossary_term' = 'Service Contract Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `sku_master_id` SET TAGS ('dbx_business_glossary_term' = 'Sku Master Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `storage_location_id` SET TAGS ('dbx_business_glossary_term' = 'Delivery Location Identifier (ID)');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `trim_level_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Trim Level Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `vehicle_program_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Program Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `allocation_priority` SET TAGS ('dbx_business_glossary_term' = 'Allocation Priority');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `allocation_priority` SET TAGS ('dbx_value_regex' = 'standard|high|urgent|critical');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `amendment_notes` SET TAGS ('dbx_business_glossary_term' = 'Amendment Notes');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `body_style` SET TAGS ('dbx_business_glossary_term' = 'Body Style');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `cancellation_reason` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Reason');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `created_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Created By User Identifier (ID)');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `created_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `created_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `delivery_window_end_date` SET TAGS ('dbx_business_glossary_term' = 'Delivery Window End Date');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `delivery_window_start_date` SET TAGS ('dbx_business_glossary_term' = 'Delivery Window Start Date');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `destination_country_code` SET TAGS ('dbx_business_glossary_term' = 'Destination Country Code');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `destination_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `destination_region` SET TAGS ('dbx_business_glossary_term' = 'Destination Region');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `discount_percentage` SET TAGS ('dbx_business_glossary_term' = 'Discount Percentage');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `exterior_color_code` SET TAGS ('dbx_business_glossary_term' = 'Exterior Color Code');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `fleet_use_type` SET TAGS ('dbx_business_glossary_term' = 'Fleet Use Type');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `fleet_use_type` SET TAGS ('dbx_value_regex' = 'commercial|rental|government|corporate|utility|emergency');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `fulfillment_status` SET TAGS ('dbx_business_glossary_term' = 'Fulfillment Status');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `fulfillment_status` SET TAGS ('dbx_value_regex' = 'pending|in_production|ready_for_delivery|partially_fulfilled|fully_fulfilled|cancelled');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `interior_color_code` SET TAGS ('dbx_business_glossary_term' = 'Interior Color Code');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `last_modified_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Last Modified By User Identifier (ID)');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `last_modified_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `last_modified_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `line_number` SET TAGS ('dbx_business_glossary_term' = 'Line Number');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `line_status` SET TAGS ('dbx_business_glossary_term' = 'Line Status');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `line_status` SET TAGS ('dbx_value_regex' = 'active|on_hold|cancelled|completed|amended');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `planned_production_month` SET TAGS ('dbx_business_glossary_term' = 'Planned Production Month');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `planned_production_month` SET TAGS ('dbx_value_regex' = '^d{4}-(0[1-9]|1[0-2])$');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `powertrain_type` SET TAGS ('dbx_business_glossary_term' = 'Powertrain Type');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `powertrain_type` SET TAGS ('dbx_value_regex' = 'ICE|EV|HEV|PHEV|FCEV');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `quantity_committed` SET TAGS ('dbx_business_glossary_term' = 'Quantity Committed');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `quantity_fulfilled` SET TAGS ('dbx_business_glossary_term' = 'Quantity Fulfilled');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `quantity_remaining` SET TAGS ('dbx_business_glossary_term' = 'Quantity Remaining');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `regulatory_compliance_notes` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Compliance Notes');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `requested_delivery_date` SET TAGS ('dbx_business_glossary_term' = 'Requested Delivery Date');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `special_equipment_codes` SET TAGS ('dbx_business_glossary_term' = 'Special Equipment Codes');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `total_line_value` SET TAGS ('dbx_business_glossary_term' = 'Total Line Value');
ALTER TABLE `automotive_ecm`.`sales`.`fleet_contract_line` ALTER COLUMN `unit_contracted_price` SET TAGS ('dbx_business_glossary_term' = 'Unit Contracted Price');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` SET TAGS ('dbx_subdomain' = 'incentive_programs');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `msrp_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Manufacturer Suggested Retail Price (MSRP) Schedule ID');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `company_code_id` SET TAGS ('dbx_business_glossary_term' = 'Company Code Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `model_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle ID');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `model_year_program_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Model Year Program Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `powertrain_spec_id` SET TAGS ('dbx_business_glossary_term' = 'Powertrain Spec Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `powertrain_variant_id` SET TAGS ('dbx_business_glossary_term' = 'Powertrain Variant Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `regulatory_requirement_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Requirement Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `sales_territory_id` SET TAGS ('dbx_business_glossary_term' = 'Sales Territory Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `sku_master_id` SET TAGS ('dbx_business_glossary_term' = 'Sku Master Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `trim_level_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Trim Level Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `vehicle_program_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Program Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `adas_level` SET TAGS ('dbx_business_glossary_term' = 'Advanced Driver Assistance Systems (ADAS) Level');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `adas_level` SET TAGS ('dbx_value_regex' = 'level_0|level_1|level_2|level_3|level_4|level_5');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `advertising_fee` SET TAGS ('dbx_business_glossary_term' = 'Advertising Fee');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `approved_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approved Timestamp');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `base_msrp` SET TAGS ('dbx_business_glossary_term' = 'Base Manufacturer Suggested Retail Price (MSRP)');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `body_style` SET TAGS ('dbx_business_glossary_term' = 'Body Style');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `cafe_credit_value` SET TAGS ('dbx_business_glossary_term' = 'Corporate Average Fuel Economy (CAFE) Credit Value');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `cafe_credit_value` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Country Code');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `destination_charge` SET TAGS ('dbx_business_glossary_term' = 'Destination and Delivery Charge');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `epa_fuel_economy_city` SET TAGS ('dbx_business_glossary_term' = 'Environmental Protection Agency (EPA) Fuel Economy City');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `epa_fuel_economy_combined` SET TAGS ('dbx_business_glossary_term' = 'Environmental Protection Agency (EPA) Fuel Economy Combined');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `epa_fuel_economy_highway` SET TAGS ('dbx_business_glossary_term' = 'Environmental Protection Agency (EPA) Fuel Economy Highway');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `gas_guzzler_tax` SET TAGS ('dbx_business_glossary_term' = 'Gas Guzzler Tax');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `holdback_amount` SET TAGS ('dbx_business_glossary_term' = 'Dealer Holdback Amount');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `holdback_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `invoice_price` SET TAGS ('dbx_business_glossary_term' = 'Dealer Invoice Price');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `invoice_price` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `nameplate` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Nameplate');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `ncap_safety_rating` SET TAGS ('dbx_business_glossary_term' = 'New Car Assessment Programme (NCAP) Safety Rating');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Schedule Notes');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `option_package_code` SET TAGS ('dbx_business_glossary_term' = 'Option Package Code');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `powertrain_warranty_miles` SET TAGS ('dbx_business_glossary_term' = 'Powertrain Warranty Duration (Miles)');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `powertrain_warranty_months` SET TAGS ('dbx_business_glossary_term' = 'Powertrain Warranty Duration (Months)');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `published_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Published Timestamp');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `schedule_number` SET TAGS ('dbx_business_glossary_term' = 'MSRP Schedule Number');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `schedule_number` SET TAGS ('dbx_value_regex' = '^MSRP-[0-9]{6,10}$');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `schedule_status` SET TAGS ('dbx_business_glossary_term' = 'Schedule Status');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `schedule_status` SET TAGS ('dbx_value_regex' = 'draft|active|superseded|archived');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `schedule_type` SET TAGS ('dbx_business_glossary_term' = 'Schedule Type');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `schedule_type` SET TAGS ('dbx_value_regex' = 'launch|mid_cycle|promotional|fleet');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `total_msrp` SET TAGS ('dbx_business_glossary_term' = 'Total Manufacturer Suggested Retail Price (MSRP)');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `warranty_miles` SET TAGS ('dbx_business_glossary_term' = 'Warranty Duration (Miles)');
ALTER TABLE `automotive_ecm`.`sales`.`msrp_schedule` ALTER COLUMN `warranty_months` SET TAGS ('dbx_business_glossary_term' = 'Warranty Duration (Months)');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` SET TAGS ('dbx_subdomain' = 'pipeline_management');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `sales_territory_id` SET TAGS ('dbx_business_glossary_term' = 'Sales Territory ID');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `rep_id` SET TAGS ('dbx_business_glossary_term' = 'Sales Manager ID');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `annual_quota_revenue` SET TAGS ('dbx_business_glossary_term' = 'Annual Quota Revenue');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `annual_quota_units` SET TAGS ('dbx_business_glossary_term' = 'Annual Quota Units');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `competitive_intensity` SET TAGS ('dbx_business_glossary_term' = 'Competitive Intensity');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `competitive_intensity` SET TAGS ('dbx_value_regex' = 'low|medium|high|very_high');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Country Code');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `dealer_count` SET TAGS ('dbx_business_glossary_term' = 'Dealer Count');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `distribution_channel` SET TAGS ('dbx_business_glossary_term' = 'Distribution Channel');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `distribution_channel` SET TAGS ('dbx_value_regex' = 'direct|dealer|fleet|online|export');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `district_code` SET TAGS ('dbx_business_glossary_term' = 'District Code');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `district_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,8}$');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `district_name` SET TAGS ('dbx_business_glossary_term' = 'District Name');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `effective_end_date` SET TAGS ('dbx_business_glossary_term' = 'Effective End Date');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `effective_start_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Start Date');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `fiscal_year` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Year (FY)');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `fiscal_year` SET TAGS ('dbx_value_regex' = '^FY[0-9]{4}$');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `household_count` SET TAGS ('dbx_business_glossary_term' = 'Household Count');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `incentive_program_code` SET TAGS ('dbx_business_glossary_term' = 'Incentive Program Code');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `incentive_program_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{4,12}$');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `language_code` SET TAGS ('dbx_business_glossary_term' = 'Language Code');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `language_code` SET TAGS ('dbx_value_regex' = '^[a-z]{2}$');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `market_segment` SET TAGS ('dbx_business_glossary_term' = 'Market Segment');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `market_segment` SET TAGS ('dbx_value_regex' = 'luxury|premium|mass_market|commercial|electric|performance');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `median_household_income` SET TAGS ('dbx_business_glossary_term' = 'Median Household Income');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `model_year_focus` SET TAGS ('dbx_business_glossary_term' = 'Model Year (MY) Focus');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `model_year_focus` SET TAGS ('dbx_value_regex' = '^MY[0-9]{4}$');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `modified_by_user` SET TAGS ('dbx_business_glossary_term' = 'Modified By User');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Territory Notes');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `population_count` SET TAGS ('dbx_business_glossary_term' = 'Population Count');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `postal_code_range` SET TAGS ('dbx_business_glossary_term' = 'Postal Code Range');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `postal_code_range` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `postal_code_range` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `priority` SET TAGS ('dbx_business_glossary_term' = 'Territory Priority');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `priority` SET TAGS ('dbx_value_regex' = 'strategic|high|medium|low');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `quota_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Quota Currency Code');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `quota_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `region_code` SET TAGS ('dbx_business_glossary_term' = 'Region Code');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `region_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,8}$');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `region_name` SET TAGS ('dbx_business_glossary_term' = 'Region Name');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `regulatory_region` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Region');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `sales_manager_name` SET TAGS ('dbx_business_glossary_term' = 'Sales Manager Name');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `sales_office_code` SET TAGS ('dbx_business_glossary_term' = 'Sales Office Code');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `sales_office_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{3,8}$');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `sales_organization_code` SET TAGS ('dbx_business_glossary_term' = 'Sales Organization Code');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `sales_organization_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{4}$');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `state_province_code` SET TAGS ('dbx_business_glossary_term' = 'State or Province Code');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `state_province_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,6}$');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `territory_code` SET TAGS ('dbx_business_glossary_term' = 'Territory Code');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `territory_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{3,12}$');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `territory_name` SET TAGS ('dbx_business_glossary_term' = 'Territory Name');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `territory_status` SET TAGS ('dbx_business_glossary_term' = 'Territory Status');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `territory_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|planned|consolidating|splitting');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `territory_type` SET TAGS ('dbx_business_glossary_term' = 'Territory Type');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `territory_type` SET TAGS ('dbx_value_regex' = 'retail|fleet|export|commercial|government|dealer_network');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `time_zone` SET TAGS ('dbx_business_glossary_term' = 'Time Zone');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `vehicle_category_focus` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Category Focus');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `vehicle_registration_count` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Registration Count');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `zone_code` SET TAGS ('dbx_business_glossary_term' = 'Zone Code');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `zone_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,8}$');
ALTER TABLE `automotive_ecm`.`sales`.`sales_territory` ALTER COLUMN `zone_name` SET TAGS ('dbx_business_glossary_term' = 'Zone Name');
ALTER TABLE `automotive_ecm`.`sales`.`rep` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `automotive_ecm`.`sales`.`rep` SET TAGS ('dbx_subdomain' = 'pipeline_management');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `rep_id` SET TAGS ('dbx_business_glossary_term' = 'Sales Representative ID');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `cost_center_id` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `active_status` SET TAGS ('dbx_business_glossary_term' = 'Active Status');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `certification_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Certification Expiry Date');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `certification_status` SET TAGS ('dbx_business_glossary_term' = 'Sales Certification Status');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `certification_status` SET TAGS ('dbx_value_regex' = 'certified|in_progress|expired|not_required');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `commission_plan_code` SET TAGS ('dbx_business_glossary_term' = 'Commission Plan Code');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `commission_plan_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{4,10}$');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `commission_plan_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `crm_user_code` SET TAGS ('dbx_business_glossary_term' = 'Customer Relationship Management (CRM) User ID');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `crm_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `crm_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `dealer_count` SET TAGS ('dbx_business_glossary_term' = 'Assigned Dealer Count');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `email_address` SET TAGS ('dbx_business_glossary_term' = 'Email Address');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `email_address` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `email_address` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `email_address` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `first_name` SET TAGS ('dbx_business_glossary_term' = 'First Name');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `first_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `first_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `fiscal_year` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Year (FY)');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `fleet_account_count` SET TAGS ('dbx_business_glossary_term' = 'Assigned Fleet Account Count');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `hire_date` SET TAGS ('dbx_business_glossary_term' = 'Hire Date');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `language_proficiency` SET TAGS ('dbx_business_glossary_term' = 'Language Proficiency');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `last_name` SET TAGS ('dbx_business_glossary_term' = 'Last Name');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `last_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `last_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `mobile_number` SET TAGS ('dbx_business_glossary_term' = 'Mobile Phone Number');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `mobile_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `mobile_number` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Modified Timestamp');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `office_location` SET TAGS ('dbx_business_glossary_term' = 'Office Location');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `performance_tier` SET TAGS ('dbx_business_glossary_term' = 'Performance Tier');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `performance_tier` SET TAGS ('dbx_value_regex' = 'platinum|gold|silver|bronze|developing');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `performance_tier` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `phone_number` SET TAGS ('dbx_business_glossary_term' = 'Phone Number');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `phone_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `phone_number` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `product_specialization` SET TAGS ('dbx_business_glossary_term' = 'Product Specialization');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `quota_amount` SET TAGS ('dbx_business_glossary_term' = 'Sales Quota Amount');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `quota_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `quota_currency` SET TAGS ('dbx_business_glossary_term' = 'Quota Currency Code');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `quota_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `quota_period` SET TAGS ('dbx_business_glossary_term' = 'Quota Period');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `quota_period` SET TAGS ('dbx_value_regex' = 'annual|quarterly|monthly');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `region` SET TAGS ('dbx_business_glossary_term' = 'Sales Region');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `sales_role` SET TAGS ('dbx_business_glossary_term' = 'Sales Role');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `sales_role` SET TAGS ('dbx_value_regex' = 'retail_field_rep|fleet_account_manager|national_account_executive|export_sales|regional_sales_manager|dealer_development');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `sales_start_date` SET TAGS ('dbx_business_glossary_term' = 'Sales Start Date');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Termination Date');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `work_arrangement` SET TAGS ('dbx_business_glossary_term' = 'Work Arrangement');
ALTER TABLE `automotive_ecm`.`sales`.`rep` ALTER COLUMN `work_arrangement` SET TAGS ('dbx_value_regex' = 'field_based|office_based|hybrid|remote');
ALTER TABLE `automotive_ecm`.`sales`.`quota` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `automotive_ecm`.`sales`.`quota` SET TAGS ('dbx_subdomain' = 'pipeline_management');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `quota_id` SET TAGS ('dbx_business_glossary_term' = 'Quota Identifier (ID)');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `rep_id` SET TAGS ('dbx_business_glossary_term' = 'Assignee Identifier (ID)');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `dealership_id` SET TAGS ('dbx_business_glossary_term' = 'Dealership Identifier (ID)');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `fiscal_period_id` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Period Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `model_id` SET TAGS ('dbx_business_glossary_term' = 'Model Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `model_year_program_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Model Year Program Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `quota_rep_id` SET TAGS ('dbx_business_glossary_term' = 'Sales Representative Identifier (ID)');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `quota_sales_representative_rep_id` SET TAGS ('dbx_business_glossary_term' = 'Sales Representative Identifier (ID)');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `sales_territory_id` SET TAGS ('dbx_business_glossary_term' = 'Territory Identifier (ID)');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `vehicle_program_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Program Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Approval Status');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected|revision_required');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `approved_date` SET TAGS ('dbx_business_glossary_term' = 'Approved Date');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `assignee_name` SET TAGS ('dbx_business_glossary_term' = 'Assignee Name');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `assignee_type` SET TAGS ('dbx_business_glossary_term' = 'Assignee Type');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `fiscal_month` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Month');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `fiscal_month` SET TAGS ('dbx_value_regex' = '^M(0[1-9]|1[0-2])$');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `fiscal_quarter` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Quarter');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `fiscal_quarter` SET TAGS ('dbx_value_regex' = 'Q1|Q2|Q3|Q4');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `fiscal_year` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Year (FY)');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `fiscal_year` SET TAGS ('dbx_value_regex' = '^FY[0-9]{4}$');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `incentive_eligible` SET TAGS ('dbx_business_glossary_term' = 'Incentive Eligible Flag');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `modified_by` SET TAGS ('dbx_business_glossary_term' = 'Modified By');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Period End Date');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Period Start Date');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `powertrain_type` SET TAGS ('dbx_business_glossary_term' = 'Powertrain Type');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `powertrain_type` SET TAGS ('dbx_value_regex' = 'ICE|HEV|PHEV|BEV|FCEV|all');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `product_line` SET TAGS ('dbx_business_glossary_term' = 'Product Line');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `quota_name` SET TAGS ('dbx_business_glossary_term' = 'Quota Name');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `quota_number` SET TAGS ('dbx_business_glossary_term' = 'Quota Number');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `quota_number` SET TAGS ('dbx_value_regex' = '^QTA-[0-9]{8}$');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `quota_status` SET TAGS ('dbx_business_glossary_term' = 'Quota Status');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `quota_status` SET TAGS ('dbx_value_regex' = 'draft|approved|active|suspended|closed|cancelled');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `quota_type` SET TAGS ('dbx_business_glossary_term' = 'Quota Type');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `quota_type` SET TAGS ('dbx_value_regex' = 'unit_volume|revenue|ev_mix|fleet_penetration|market_share|model_mix');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `region_code` SET TAGS ('dbx_business_glossary_term' = 'Region Code');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `region_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `revision_number` SET TAGS ('dbx_business_glossary_term' = 'Revision Number');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `revision_reason` SET TAGS ('dbx_business_glossary_term' = 'Revision Reason');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `sales_channel` SET TAGS ('dbx_business_glossary_term' = 'Sales Channel');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `sales_channel` SET TAGS ('dbx_value_regex' = 'retail|fleet|commercial|government|direct|dealer_network');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `target_unit` SET TAGS ('dbx_business_glossary_term' = 'Target Unit of Measure');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `target_value` SET TAGS ('dbx_business_glossary_term' = 'Target Value');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `threshold_minimum` SET TAGS ('dbx_business_glossary_term' = 'Threshold Minimum');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `threshold_stretch` SET TAGS ('dbx_business_glossary_term' = 'Threshold Stretch');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `vehicle_segment` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Segment');
ALTER TABLE `automotive_ecm`.`sales`.`quota` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By');
ALTER TABLE `automotive_ecm`.`sales`.`activity` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `automotive_ecm`.`sales`.`activity` SET TAGS ('dbx_subdomain' = 'pipeline_management');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `activity_id` SET TAGS ('dbx_business_glossary_term' = 'Sales Activity ID');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Customer ID');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `activity_party_id` SET TAGS ('dbx_business_glossary_term' = 'Customer ID');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `rep_id` SET TAGS ('dbx_business_glossary_term' = 'Sales Representative ID');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `activity_sales_representative_rep_id` SET TAGS ('dbx_business_glossary_term' = 'Sales Representative ID');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `vin_registry_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle ID');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `activity_vin_registry_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle ID');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `campaign_id` SET TAGS ('dbx_business_glossary_term' = 'Campaign ID');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `case_id` SET TAGS ('dbx_business_glossary_term' = 'Case Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `contact_id` SET TAGS ('dbx_business_glossary_term' = 'Contact ID');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `contact_point_id` SET TAGS ('dbx_business_glossary_term' = 'Contact ID');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `dealership_id` SET TAGS ('dbx_business_glossary_term' = 'Dealership ID');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `fleet_contract_id` SET TAGS ('dbx_business_glossary_term' = 'Fleet Contract Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `lead_id` SET TAGS ('dbx_business_glossary_term' = 'Lead ID');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Opportunity ID');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `quote_id` SET TAGS ('dbx_business_glossary_term' = 'Quote Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `sales_territory_id` SET TAGS ('dbx_business_glossary_term' = 'Sales Territory Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `vehicle_order_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Order Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `activity_date` SET TAGS ('dbx_business_glossary_term' = 'Activity Date');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `activity_description` SET TAGS ('dbx_business_glossary_term' = 'Activity Description');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `activity_number` SET TAGS ('dbx_business_glossary_term' = 'Activity Number');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `activity_number` SET TAGS ('dbx_value_regex' = '^ACT-[0-9]{8}$');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `activity_status` SET TAGS ('dbx_business_glossary_term' = 'Activity Status');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `activity_status` SET TAGS ('dbx_value_regex' = 'scheduled|in_progress|completed|cancelled|no_show|rescheduled');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `activity_type` SET TAGS ('dbx_business_glossary_term' = 'Activity Type');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `competitor_mentioned` SET TAGS ('dbx_business_glossary_term' = 'Competitor Mentioned');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `created_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Created By User ID');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `created_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `created_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `customer_sentiment` SET TAGS ('dbx_business_glossary_term' = 'Customer Sentiment');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `customer_sentiment` SET TAGS ('dbx_value_regex' = 'very_positive|positive|neutral|negative|very_negative');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `demo_completed` SET TAGS ('dbx_business_glossary_term' = 'Demo Completed Flag');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `duration_minutes` SET TAGS ('dbx_business_glossary_term' = 'Duration in Minutes');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `end_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Activity End Timestamp');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `estimated_deal_value` SET TAGS ('dbx_business_glossary_term' = 'Estimated Deal Value');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `fiscal_quarter` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Quarter');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `fiscal_quarter` SET TAGS ('dbx_value_regex' = 'Q1|Q2|Q3|Q4');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `fiscal_year` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Year (FY)');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `fiscal_year` SET TAGS ('dbx_value_regex' = '^FY[0-9]{4}$');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `is_commercial_vehicle` SET TAGS ('dbx_business_glossary_term' = 'Commercial Vehicle Flag');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `is_fleet_sale` SET TAGS ('dbx_business_glossary_term' = 'Fleet Sale Flag');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `location` SET TAGS ('dbx_business_glossary_term' = 'Activity Location');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `model_year` SET TAGS ('dbx_business_glossary_term' = 'Model Year (MY)');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `model_year` SET TAGS ('dbx_value_regex' = '^MY[0-9]{4}$');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `modified_by_user_code` SET TAGS ('dbx_business_glossary_term' = 'Modified By User ID');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `modified_by_user_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `modified_by_user_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Modified Timestamp');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `next_action` SET TAGS ('dbx_business_glossary_term' = 'Next Action');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `next_action_date` SET TAGS ('dbx_business_glossary_term' = 'Next Action Date');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `objection_raised` SET TAGS ('dbx_business_glossary_term' = 'Objection Raised');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `objection_resolved` SET TAGS ('dbx_business_glossary_term' = 'Objection Resolved Flag');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `outcome` SET TAGS ('dbx_business_glossary_term' = 'Activity Outcome');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `priority` SET TAGS ('dbx_business_glossary_term' = 'Activity Priority');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `priority` SET TAGS ('dbx_value_regex' = 'low|medium|high|urgent');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `quote_presented` SET TAGS ('dbx_business_glossary_term' = 'Quote Presented Flag');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `region` SET TAGS ('dbx_business_glossary_term' = 'Sales Region');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `start_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Activity Start Timestamp');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `subject` SET TAGS ('dbx_business_glossary_term' = 'Activity Subject');
ALTER TABLE `automotive_ecm`.`sales`.`activity` ALTER COLUMN `test_drive_completed` SET TAGS ('dbx_business_glossary_term' = 'Test Drive Completed Flag');
ALTER TABLE `automotive_ecm`.`sales`.`campaign` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `automotive_ecm`.`sales`.`campaign` SET TAGS ('dbx_subdomain' = 'pipeline_management');
ALTER TABLE `automotive_ecm`.`sales`.`campaign` ALTER COLUMN `campaign_id` SET TAGS ('dbx_business_glossary_term' = 'Sales Campaign Identifier (SCID)');
ALTER TABLE `automotive_ecm`.`sales`.`campaign` ALTER COLUMN `msrp_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Msrp Schedule Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`campaign` ALTER COLUMN `sales_territory_id` SET TAGS ('dbx_business_glossary_term' = 'Sales Territory Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`campaign` ALTER COLUMN `vehicle_program_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Program Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`sales`.`campaign` ALTER COLUMN `actual_spent_amount` SET TAGS ('dbx_business_glossary_term' = 'Actual Spent Amount (ASA)');
ALTER TABLE `automotive_ecm`.`sales`.`campaign` ALTER COLUMN `actual_spent_currency` SET TAGS ('dbx_business_glossary_term' = 'Actual Spent Currency Code (ASCC)');
ALTER TABLE `automotive_ecm`.`sales`.`campaign` ALTER COLUMN `actual_spent_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `automotive_ecm`.`sales`.`campaign` ALTER COLUMN `budget_amount` SET TAGS ('dbx_business_glossary_term' = 'Budget Amount (BA)');
ALTER TABLE `automotive_ecm`.`sales`.`campaign` ALTER COLUMN `budget_currency` SET TAGS ('dbx_business_glossary_term' = 'Budget Currency Code (BCC)');
ALTER TABLE `automotive_ecm`.`sales`.`campaign` ALTER COLUMN `budget_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `automotive_ecm`.`sales`.`campaign` ALTER COLUMN `campaign_description` SET TAGS ('dbx_business_glossary_term' = 'Campaign Description (CD)');
ALTER TABLE `automotive_ecm`.`sales`.`campaign` ALTER COLUMN `campaign_name` SET TAGS ('dbx_business_glossary_term' = 'Campaign Name (CN)');
ALTER TABLE `automotive_ecm`.`sales`.`campaign` ALTER COLUMN `campaign_status` SET TAGS ('dbx_business_glossary_term' = 'Campaign Status (CS)');
ALTER TABLE `automotive_ecm`.`sales`.`campaign` ALTER COLUMN `campaign_status` SET TAGS ('dbx_value_regex' = 'planned|active|completed|cancelled|on_hold');
ALTER TABLE `automotive_ecm`.`sales`.`campaign` ALTER COLUMN `campaign_type` SET TAGS ('dbx_business_glossary_term' = 'Campaign Type (CT)');
ALTER TABLE `automotive_ecm`.`sales`.`campaign` ALTER COLUMN `campaign_type` SET TAGS ('dbx_value_regex' = 'model_launch|clearance|seasonal|conquest|loyalty');
ALTER TABLE `automotive_ecm`.`sales`.`campaign` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp (RCT)');
ALTER TABLE `automotive_ecm`.`sales`.`campaign` ALTER COLUMN `dealer_participation_flag` SET TAGS ('dbx_business_glossary_term' = 'Dealer Participation Flag (DPF)');
ALTER TABLE `automotive_ecm`.`sales`.`campaign` ALTER COLUMN `end_date` SET TAGS ('dbx_business_glossary_term' = 'Campaign End Date (CED)');
ALTER TABLE `automotive_ecm`.`sales`.`campaign` ALTER COLUMN `kpi_market_share_actual` SET TAGS ('dbx_business_glossary_term' = 'Market Share Actual KPI (MSA)');
ALTER TABLE `automotive_ecm`.`sales`.`campaign` ALTER COLUMN `kpi_market_share_target` SET TAGS ('dbx_business_glossary_term' = 'Market Share Target KPI (MSTK)');
ALTER TABLE `automotive_ecm`.`sales`.`campaign` ALTER COLUMN `kpi_sales_volume_actual` SET TAGS ('dbx_business_glossary_term' = 'Sales Volume Actual KPI (SVA)');
ALTER TABLE `automotive_ecm`.`sales`.`campaign` ALTER COLUMN `kpi_sales_volume_target` SET TAGS ('dbx_business_glossary_term' = 'Sales Volume Target KPI (SVTK)');
ALTER TABLE `automotive_ecm`.`sales`.`campaign` ALTER COLUMN `marketing_channels` SET TAGS ('dbx_business_glossary_term' = 'Marketing Channels (MC)');
ALTER TABLE `automotive_ecm`.`sales`.`campaign` ALTER COLUMN `marketing_channels` SET TAGS ('dbx_value_regex' = 'dealer|online|direct|partner|mixed');
ALTER TABLE `automotive_ecm`.`sales`.`campaign` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Additional Notes (AN)');
ALTER TABLE `automotive_ecm`.`sales`.`campaign` ALTER COLUMN `objective` SET TAGS ('dbx_business_glossary_term' = 'Campaign Objective (CO)');
ALTER TABLE `automotive_ecm`.`sales`.`campaign` ALTER COLUMN `priority` SET TAGS ('dbx_business_glossary_term' = 'Campaign Priority (CP)');
ALTER TABLE `automotive_ecm`.`sales`.`campaign` ALTER COLUMN `priority` SET TAGS ('dbx_value_regex' = 'low|medium|high');
ALTER TABLE `automotive_ecm`.`sales`.`campaign` ALTER COLUMN `region_code` SET TAGS ('dbx_business_glossary_term' = 'Region ISO 3166-1 Alpha-3 Code (RIC)');
ALTER TABLE `automotive_ecm`.`sales`.`campaign` ALTER COLUMN `region_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `automotive_ecm`.`sales`.`campaign` ALTER COLUMN `start_date` SET TAGS ('dbx_business_glossary_term' = 'Campaign Start Date (CSD)');
ALTER TABLE `automotive_ecm`.`sales`.`campaign` ALTER COLUMN `target_customer_segment` SET TAGS ('dbx_business_glossary_term' = 'Target Customer Segment (TCS)');
ALTER TABLE `automotive_ecm`.`sales`.`campaign` ALTER COLUMN `target_customer_segment` SET TAGS ('dbx_value_regex' = 'fleet|consumer|luxury|commercial');
ALTER TABLE `automotive_ecm`.`sales`.`campaign` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp (RUT)');
