-- Schema for Domain: customer | Business: Automotive | Version: v1_mvm
-- Generated on: 2026-05-07 02:20:08

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `automotive_ecm`.`customer` COMMENT 'SSOT for all customer identities including retail buyers, fleet operators, corporate accounts, and government entities. Manages customer profiles, contact information, preferences, vehicle ownership history, loyalty program membership, household linkages, and customer segmentation. Tracks NPS (Net Promoter Score), CLTV (Customer Lifetime Value), and customer journey touchpoints. Supports both B2C and B2B customer types with unified identity management. Integrates with Salesforce Automotive Cloud.';

-- ========= TABLES =========
CREATE OR REPLACE TABLE `automotive_ecm`.`customer`.`party` (
    `party_id` BIGINT COMMENT 'Unique system-generated identifier for the party record.',
    `address_line1` STRING COMMENT 'First line of the partys primary mailing address.',
    `address_line2` STRING COMMENT 'Second line of the partys primary mailing address (optional).',
    `address_type` STRING COMMENT 'Classification of the primary address (e.g., billing, shipping).. Valid values are `billing|shipping|mailing|primary`',
    `city` STRING COMMENT 'City component of the primary mailing address.',
    `communication_preference` STRING COMMENT 'Preferred channel for outbound communications.. Valid values are `email|sms|phone|mail`',
    `country_code` STRING COMMENT 'Three‑letter ISO country code for the primary mailing address.. Valid values are `^[A-Z]{3}$`',
    `credit_rating` STRING COMMENT 'External credit rating assigned to the party for risk assessment.. Valid values are `AAA|AA|A|BBB|BB|B`',
    `customer_lifetime_value` DECIMAL(18,2) COMMENT 'Estimated total net revenue expected from the party over the relationship.',
    `customer_segment` STRING COMMENT 'Business segment classification for analytics and targeting.. Valid values are `mass_market|premium|fleet|government|enterprise`',
    `data_residency_region` STRING COMMENT 'Geographic region where the partys personal data is stored to satisfy data‑sovereignty requirements.',
    `date_of_birth` DATE COMMENT 'Birth date of an individual party, used for age verification and KYC.',
    `email_address` STRING COMMENT 'Primary email address for electronic communication.. Valid values are `^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+.[A-Za-z]{2,}$`',
    `external_reference_code` STRING COMMENT 'Additional external reference used for cross‑system reconciliation.',
    `gdpr_consent_email` BOOLEAN COMMENT 'Indicates whether the party has consented to receive email communications under GDPR.',
    `gdpr_consent_sms` BOOLEAN COMMENT 'Indicates whether the party has consented to receive SMS communications under GDPR.',
    `incorporation_date` DATE COMMENT 'Date the organization was legally formed.',
    `industry_classification` STRING COMMENT 'Standard industry code (NAICS or SIC) describing the partys primary business.',
    `is_tax_exempt` BOOLEAN COMMENT 'Indicates whether the party is exempt from sales tax.',
    `kyc_status` STRING COMMENT 'Current status of KYC verification for the party.. Valid values are `pending|verified|rejected`',
    `last_verified_date` DATE COMMENT 'Date when the partys information was last validated against source data.',
    `legal_name` STRING COMMENT 'Full legal name of the individual or organization as recorded for contracts and compliance.',
    `lifecycle_status` STRING COMMENT 'Current lifecycle stage of the party within the business relationship.. Valid values are `prospect|active|inactive|churned|suspended`',
    `loyalty_tier` STRING COMMENT 'Current tier level within the loyalty program.. Valid values are `bronze|silver|gold|platinum`',
    `marketing_opt_in` BOOLEAN COMMENT 'Indicates whether the party has consented to receive marketing communications.',
    `net_promoter_score` STRING COMMENT 'Latest NPS rating captured for the party.',
    `notes` STRING COMMENT 'Free‑form notes entered by business users about the party.',
    `onboarding_channel` STRING COMMENT 'Channel through which the party was onboarded.. Valid values are `online|branch|dealer|partner`',
    `onboarding_date` DATE COMMENT 'Date the party was first created in the system.',
    `party_type` STRING COMMENT 'Indicates whether the party is an individual customer or an organization (e.g., fleet operator, dealer).. Valid values are `individual|organization`',
    `phone_number` STRING COMMENT 'Primary telephone number for voice or SMS contact.',
    `postal_code` STRING COMMENT 'Postal or ZIP code of the primary mailing address.',
    `preferred_currency` STRING COMMENT 'ISO 4217 currency code the party prefers for billing and pricing.',
    `preferred_language` STRING COMMENT 'ISO 639‑1 language code for the partys preferred communication language.',
    `primary_contact_method` STRING COMMENT 'Method most frequently used to reach the party.. Valid values are `email|phone|mail`',
    `record_audit_created` TIMESTAMP COMMENT 'Timestamp when the party record was first created in the lakehouse.',
    `record_audit_updated` TIMESTAMP COMMENT 'Timestamp of the most recent update to the party record.',
    `registration_number` STRING COMMENT 'Official registration number for an organization (e.g., corporate registration, dealer license).',
    `source_system` STRING COMMENT 'Originating system that supplied the party record (e.g., Salesforce, CDK).',
    `source_system_code` STRING COMMENT 'Unique identifier of the party in the source system.',
    `state_province` STRING COMMENT 'State or province component of the primary mailing address.',
    `tax_exempt_reason` STRING COMMENT 'Reason or code for tax exemption, if applicable.',
    `tax_identification_number` STRING COMMENT 'Government‑issued tax identifier (e.g., EIN, VAT) for the party.',
    `trade_name` STRING COMMENT 'Doing‑business‑as name or brand name used by the organization.',
    CONSTRAINT pk_party PRIMARY KEY(`party_id`)
) COMMENT 'SSOT master entity for all customer identities served by Automotive — retail buyers (B2C), fleet operators, corporate accounts, government entities, and dealer principals. Stores the unified identity record including party type (individual/organization), legal name, tax identification, registration number, preferred language, preferred currency, date of birth (for individuals), incorporation date (for organizations), industry classification (NAICS/SIC), credit rating, KYC status, GDPR consent flags, data residency region, source system (Salesforce Automotive Cloud party ID), onboarding channel, onboarding date, lifecycle status (prospect/active/inactive/churned), and last verified date. This is the anchor entity for all customer-domain relationships.';

CREATE OR REPLACE TABLE `automotive_ecm`.`customer`.`individual` (
    `individual_id` BIGINT COMMENT 'Unique system-generated identifier for the individual.',
    `dealership_id` BIGINT COMMENT 'Identifier of the dealer the individual prefers for service or purchase.',
    `individual_preferred_dealer_dealership_id` BIGINT COMMENT 'Identifier of the dealer the individual prefers for service or purchase.',
    `party_id` BIGINT COMMENT 'Foreign key linking to customer.party. Business justification: individual is the B2C subtype of the party master entity. The party table is the SSOT for all customer identities. individual must have a party_id FK to establish the subtype/extension relationship — ',
    `payment_plan_id` BIGINT COMMENT 'Foreign key linking to billing.payment_plan. Business justification: Retail customers enroll in payment plans for vehicle financing, extended warranties, and service contracts. Individual customer records must track active payment plan enrollment for credit decisioning',
    `contact_id` BIGINT COMMENT 'Unique identifier of the individual in Salesforce Automotive Cloud.',
    `annual_income_band` STRING COMMENT 'Income range band used for segmentation and marketing.. Valid values are `0-25k|25k-50k|50k-75k|75k-100k|100k-150k|150k+`',
    `cltv_estimate` DECIMAL(18,2) COMMENT 'Estimated total future revenue attributable to the individual.',
    `consent_timestamp` TIMESTAMP COMMENT 'Timestamp when the individual gave marketing consent.',
    `country_of_residence` STRING COMMENT 'Country where the individual currently resides.',
    `customer_type` STRING COMMENT 'Classification of the individual as B2C, B2B, government, or fleet.. Valid values are `b2c|b2b|government|fleet`',
    `driver_license_expiry` DATE COMMENT 'Expiration date of the driver license.',
    `driver_license_number` STRING COMMENT 'Government‑issued driver license identifier.',
    `driver_license_state` STRING COMMENT 'State or province that issued the driver license.',
    `education_level` STRING COMMENT 'Highest completed education level of the individual.. Valid values are `high_school|associate|bachelor|master|doctorate|other`',
    `employment_status` STRING COMMENT 'Current employment situation of the individual.. Valid values are `employed|unemployed|student|retired|self_employed|other`',
    `first_name` STRING COMMENT 'Given name of the individual.',
    `gender` STRING COMMENT 'Self‑identified gender of the individual.. Valid values are `male|female|other|prefer_not_to_say`',
    `individual_status` STRING COMMENT 'Current lifecycle status of the individual record.. Valid values are `active|inactive|suspended|prospect|deceased`',
    `last_name` STRING COMMENT 'Family name or surname of the individual.',
    `last_purchase_date` DATE COMMENT 'Date of the most recent vehicle or service purchase.',
    `loyalty_tier` STRING COMMENT 'Current loyalty program tier of the individual.. Valid values are `bronze|silver|gold|platinum|elite`',
    `marital_status` STRING COMMENT 'Current marital status of the individual.. Valid values are `single|married|divorced|widowed|partnered|prefer_not_to_say`',
    `marketing_opt_in_email` BOOLEAN COMMENT 'True if the individual has consented to receive marketing emails.',
    `marketing_opt_in_phone` BOOLEAN COMMENT 'True if the individual has consented to receive marketing phone calls.',
    `marketing_opt_in_sms` BOOLEAN COMMENT 'True if the individual has consented to receive marketing SMS messages.',
    `middle_name` STRING COMMENT 'Middle name or initial of the individual, if any.',
    `nationality` STRING COMMENT 'Country of citizenship of the individual.',
    `nps_score` STRING COMMENT 'Latest NPS rating provided by the individual (‑100 to 100).',
    `occupation` STRING COMMENT 'Primary occupation or job title of the individual.',
    `preferred_contact_method` STRING COMMENT 'Individuals preferred channel for communications.. Valid values are `email|phone|sms|mail|app_notification`',
    `primary_spoken_language` STRING COMMENT 'ISO 639‑1 code of the individuals primary language.',
    `record_audit_created` TIMESTAMP COMMENT 'Timestamp when the individual record was first created.',
    `record_audit_updated` TIMESTAMP COMMENT 'Timestamp of the most recent update to the individual record.',
    `segment` STRING COMMENT 'Business segment used for marketing and analytics (e.g., luxury, economy).',
    `source_system` STRING COMMENT 'Name of the source system that supplied the record (e.g., Salesforce, SAP).',
    `suffix` STRING COMMENT 'Suffix such as Jr., Sr., III, if applicable.',
    `vehicle_ownership_count` STRING COMMENT 'Number of vehicles currently owned by the individual.',
    CONSTRAINT pk_individual PRIMARY KEY(`individual_id`)
) COMMENT 'B2C retail customer profile extending the party master for natural persons. Captures personal identity attributes: first name, middle name, last name, suffix, gender, marital status, employment status, occupation, annual income band, education level, driver license number, driver license state/country, driver license expiry, primary spoken language, nationality, country of residence, household_id (FK to household), loyalty tier, NPS score (latest), CLTV estimate, preferred contact method, marketing opt-in flags, and Salesforce Contact ID. Supports personalized marketing, loyalty management, and customer journey analytics for retail vehicle buyers.';

CREATE OR REPLACE TABLE `automotive_ecm`.`customer`.`organization_account` (
    `organization_account_id` BIGINT COMMENT 'Unique surrogate key for the organization account record.',
    `payment_plan_id` BIGINT COMMENT 'Foreign key linking to billing.payment_plan. Business justification: Fleet and commercial accounts negotiate custom payment plans for bulk vehicle orders and multi-year service agreements. Organization account records must reference negotiated payment terms for contrac',
    `parent_organization_account_id` BIGINT COMMENT 'Identifier of the parent organization in corporate hierarchy, if applicable.',
    `party_id` BIGINT COMMENT 'Foreign key linking to customer.party. Business justification: organization_account is the B2B subtype of the party master entity, covering corporate accounts, fleet operators, government entities, and leasing companies. It must have a party_id FK to establish th',
    `vehicle_program_id` BIGINT COMMENT 'Foreign key linking to engineering.vehicle_program. Business justification: Fleet and corporate accounts negotiate program-level procurement contracts (e.g., a logistics company committing to a specific EV program). Linking organization_account to vehicle_program enables flee',
    `account_tier` STRING COMMENT 'Tier classification of the account based on strategic importance.. Valid values are `strategic|key|standard`',
    `accounts_payable_contact_email` STRING COMMENT 'Email address of the accounts payable contact.',
    `accounts_payable_contact_name` STRING COMMENT 'Name of the accounts payable contact.',
    `accounts_payable_contact_phone` STRING COMMENT 'Phone number of the accounts payable contact.',
    `annual_revenue` DECIMAL(18,2) COMMENT 'Annual revenue of the organization in US dollars.',
    `classification` STRING COMMENT 'Broad classification of the organization account.. Valid values are `corporate|fleet|government|leasing`',
    `contract_vehicle_type` STRING COMMENT 'Contract vehicle type used for government procurement.. Valid values are `GSA|state|none`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the organization account record was created.',
    `credit_limit` DECIMAL(18,2) COMMENT 'Maximum credit amount extended to the organization.',
    `dba_name` STRING COMMENT 'Trade name under which the organization operates.',
    `duns_number` STRING COMMENT 'Unique DUNS identifier for the organization.',
    `effective_from` DATE COMMENT 'Date when the account became effective.',
    `effective_until` DATE COMMENT 'Date when the account expires or is terminated, if applicable.',
    `fleet_size` STRING COMMENT 'Number of vehicles owned or managed by the organization.',
    `government_entity_type` STRING COMMENT 'Type of government entity, if applicable.. Valid values are `federal|state|municipal|private`',
    `industry_codes` STRING COMMENT 'Additional industry-specific codes (e.g., CAGE, NCAGE).',
    `naics_code` STRING COMMENT 'North American Industry Classification System code for the organization.',
    `number_of_employees` STRING COMMENT 'Total number of employees in the organization.',
    `organization_account_status` STRING COMMENT 'Current lifecycle status of the organization account.. Valid values are `active|inactive|suspended|pending|closed`',
    `payment_terms` STRING COMMENT 'Standard payment terms agreed with the organization.. Valid values are `net_30|net_45|net_60|due_on_receipt|custom`',
    `preferred_oem_programs` STRING COMMENT 'Comma-separated list of preferred OEM programs for the organization.',
    `procurement_contact_email` STRING COMMENT 'Email address of the procurement contact.',
    `procurement_contact_name` STRING COMMENT 'Name of the primary procurement contact for the organization.',
    `procurement_contact_phone` STRING COMMENT 'Phone number of the procurement contact.',
    `sap_customer_number` STRING COMMENT 'Customer number in SAP S/4HANA Finance module.',
    `sic_code` STRING COMMENT 'Standard Industrial Classification code for the organization.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the organization account record.',
    CONSTRAINT pk_organization_account PRIMARY KEY(`organization_account_id`)
) COMMENT 'B2B customer profile for corporate accounts, fleet operators, government entities, and leasing companies. Extends the party master with organization-specific attributes: legal entity name, DBA name, parent company party_id (for corporate hierarchy), DUNS number, SIC/NAICS code, annual revenue, number of employees, fleet size, procurement contact name, accounts payable contact, credit limit, payment terms, preferred OEM programs, government entity type (federal/state/municipal), contract vehicle type (GSA/state contract), Salesforce Account ID, SAP customer number, and account tier (strategic/key/standard). Enables B2B fleet sales, government procurement, and corporate account management.';

CREATE OR REPLACE TABLE `automotive_ecm`.`customer`.`contact_point` (
    `contact_point_id` BIGINT COMMENT 'System-generated unique identifier for each contact point record.',
    `party_id` BIGINT COMMENT 'Foreign key linking to customer.party. Business justification: Contact points belong to a party (customer or organization). Adding contact_point.party_id creates the required inbound link and eliminates isolation.',
    `address_line1` STRING COMMENT 'First line of the mailing address.',
    `address_line2` STRING COMMENT 'Second line of the mailing address (optional).',
    `channel` STRING COMMENT 'Preferred channel associated with the contact point for outbound messaging.. Valid values are `voice|sms|email|mail|push|social`',
    `city` STRING COMMENT 'City component of the mailing address.',
    `classification` STRING COMMENT 'Business classification indicating the nature of the party owning the contact point.. Valid values are `personal|business|dealer|fleet|government`',
    `communication_preference` STRING COMMENT 'Type of communications the party consents to receive via this contact point.. Valid values are `marketing|transactional|service|none`',
    `contact_point_status` STRING COMMENT 'Current lifecycle status of the contact point.. Valid values are `active|inactive|pending|suspended|deleted`',
    `contact_point_type` STRING COMMENT 'Category of the contact point indicating the medium (e.g., email, phone, mailing address, social media handle).. Valid values are `email|phone|address|social|other`',
    `contact_point_value` DECIMAL(18,2) COMMENT 'The raw value of the contact point (e.g., email address, phone number, full mailing address, social handle).',
    `country_code` STRING COMMENT 'Three‑letter ISO country code for the mailing address.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the contact point record was first created in the lakehouse.',
    `effective_date` DATE COMMENT 'Date from which the contact point becomes valid for use.',
    `email_address` STRING COMMENT 'Email address used for electronic communication.. Valid values are `^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+.[A-Za-z]{2,}$`',
    `expiry_date` DATE COMMENT 'Date after which the contact point is no longer valid.',
    `is_primary` BOOLEAN COMMENT 'Indicates whether this contact point is the primary method for reaching the party.',
    `is_verified` BOOLEAN COMMENT 'True when the contact point has been successfully verified.',
    `language_preference` STRING COMMENT 'Preferred language for communications sent to this contact point.',
    `last_used_timestamp` TIMESTAMP COMMENT 'Most recent timestamp when this contact point was used for communication.',
    `opt_in_status` BOOLEAN COMMENT 'True when the party has consented to receive communications via this contact point.',
    `opt_out_date` TIMESTAMP COMMENT 'Date and time when the party withdrew consent for this contact point.',
    `phone_number` STRING COMMENT 'Telephone number including country code, used for voice or SMS contact.. Valid values are `^+?[0-9]{7,15}$`',
    `postal_code` STRING COMMENT 'Postal or ZIP code of the mailing address.',
    `preferred_contact_hours` STRING COMMENT 'Typical daily time window (e.g., 09:00-17:00) when the party prefers to be contacted.',
    `preferred_time_zone` STRING COMMENT 'IANA time‑zone identifier representing the partys preferred time zone for contact.',
    `social_handle` STRING COMMENT 'Identifier for the party on a social media platform (e.g., @user).',
    `social_platform` STRING COMMENT 'Social media platform associated with the social handle.. Valid values are `twitter|linkedin|facebook|instagram|other`',
    `source_system` STRING COMMENT 'Originating system that supplied the contact point record (e.g., Salesforce, CDK).',
    `state_province` STRING COMMENT 'State or province component of the mailing address.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the contact point record.',
    `verification_date` TIMESTAMP COMMENT 'Date and time when the contact point was verified.',
    `verification_method` STRING COMMENT 'Method used to verify the contact point (e.g., email link, SMS code).. Valid values are `email|sms|call|postal|in_person|other`',
    CONSTRAINT pk_contact_point PRIMARY KEY(`contact_point_id`)
) COMMENT 'Stores all contact information for a party (individual or organization) including email addresses, phone numbers, mailing addresses, and social media handles. Each record captures: contact point type (email/phone/address/social), contact point value, is_primary flag, is_verified flag, verification date, verification method, opt-in status, opt-out date, channel (voice/SMS/email/mail/push), preferred time zone, preferred contact hours, source system, and effective/expiry dates. Supports omnichannel communication, regulatory compliance (TCPA, CAN-SPAM, GDPR), and Salesforce Automotive Cloud contact synchronization.';

CREATE OR REPLACE TABLE `automotive_ecm`.`customer`.`vehicle_ownership` (
    `vehicle_ownership_id` BIGINT COMMENT 'Surrogate primary key uniquely identifying each vehicle ownership record.',
    `ar_invoice_id` BIGINT COMMENT 'Foreign key linking to finance.ar_invoice. Business justification: Vehicle sales and deliveries generate AR invoices for retail/fleet customers. Linking ownership to invoice enables revenue recognition validation, warranty reserve calculation, and sales commission re',
    `configuration_id` BIGINT COMMENT 'Foreign key linking to vehicle.configuration. Business justification: When a customer purchases a vehicle, the exact commercial configuration (trim, color, powertrain, options) must be recorded on the ownership record for warranty claim processing, recall targeting by c',
    `dealership_id` BIGINT COMMENT 'Foreign key linking to dealer.dealership. Business justification: Required for warranty/service eligibility reports linking each ownership record to the dealer that sold the vehicle; dealer_code is denormalized and replaced.',
    `fixed_asset_id` BIGINT COMMENT 'Foreign key linking to finance.fixed_asset. Business justification: Fleet and commercial customers capitalize owned vehicles as fixed assets. Linking ownership to fixed_asset record supports depreciation tracking, asset disposal accounting, and lease-vs-buy analysis—e',
    `homologation_record_id` BIGINT COMMENT 'Foreign key linking to compliance.homologation_record. Business justification: Vehicle ownership records must reference the homologation approval for the specific vehicle configuration owned. Required for warranty validation, recall eligibility determination, and emissions compl',
    `party_id` BIGINT COMMENT 'Unique identifier of the customer (party) that owns or leases the vehicle.',
    `production_variant_id` BIGINT COMMENT 'Foreign key linking to manufacturing.production_variant. Business justification: Recall management, OTA software update targeting, and service campaign execution require knowing the exact production variant a customer owns. Regulatory recall notices (NHTSA/UNECE) must identify aff',
    `vehicle_order_id` BIGINT COMMENT 'Foreign key linking to sales.vehicle_order. Business justification: Links ownership record to the original sales order, enabling warranty, service, and revenue attribution reports.',
    `vehicle_program_id` BIGINT COMMENT 'Foreign key linking to engineering.vehicle_program. Business justification: Required for warranty, recall and production tracking reports that map each owned vehicle to its engineering program.',
    `vin_registry_id` BIGINT COMMENT 'Foreign key linking to vehicle.vin_registry. Business justification: Required for ownership verification and warranty claim processing; links each ownership record to the VIN registry entry to retrieve vehicle specs.',
    `acquisition_channel` STRING COMMENT 'Source through which the vehicle was obtained.. Valid values are `dealer|direct|auction|fleet`',
    `acquisition_date` DATE COMMENT 'Date the customer acquired the vehicle (purchase, lease start, etc.).',
    `acquisition_dealer_code` STRING COMMENT 'Identifier of the dealer that facilitated the acquisition.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the ownership record was first created.',
    `current_odometer` BIGINT COMMENT 'Most recent mileage reported for the vehicle.',
    `disposition_date` DATE COMMENT 'Date the vehicle was disposed of (sold, traded, etc.).',
    `disposition_odometer` BIGINT COMMENT 'Mileage recorded at the time of disposition.',
    `disposition_type` STRING COMMENT 'How the ownership relationship ended.. Valid values are `sold|traded|totaled|repossessed|retired`',
    `insurance_carrier` STRING COMMENT 'Company providing the vehicles insurance coverage.',
    `insurance_expiry` DATE COMMENT 'Date the insurance coverage ends.',
    `insurance_policy_number` STRING COMMENT 'Identifier of the insurance policy covering the vehicle.',
    `is_primary_vehicle` BOOLEAN COMMENT 'True if this vehicle is the primary vehicle for the customer household.',
    `lien_holder_name` STRING COMMENT 'Name of the financial institution or entity holding a lien on the vehicle.',
    `odometer_at_acquisition` BIGINT COMMENT 'Vehicle mileage recorded at the time of acquisition.',
    `ownership_number` STRING COMMENT 'Business identifier for the ownership agreement between the customer and the manufacturer/dealer.',
    `ownership_type` STRING COMMENT 'Classification of how the vehicle is held by the customer.. Valid values are `retail|lease|fleet|government`',
    `purchase_price` DECIMAL(18,2) COMMENT 'Amount paid by the customer for the vehicle at acquisition.',
    `registration_country` STRING COMMENT 'Three‑letter country code of the registration jurisdiction.',
    `registration_expiry` DATE COMMENT 'Date the vehicle registration expires.',
    `registration_number` STRING COMMENT 'Official license plate number assigned to the vehicle.',
    `registration_state` STRING COMMENT 'State or province where the vehicle is registered.',
    `title_number` STRING COMMENT 'Legal document number proving ownership.',
    `title_state` STRING COMMENT 'State that issued the title.',
    `trade_in_vin` STRING COMMENT 'VIN of a vehicle traded in as part of the acquisition, if applicable.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the ownership record.',
    `vehicle_ownership_status` STRING COMMENT 'Current lifecycle state of the ownership record.. Valid values are `active|inactive|closed|pending`',
    CONSTRAINT pk_vehicle_ownership PRIMARY KEY(`vehicle_ownership_id`)
) COMMENT 'Tracks the ownership history of vehicles by customers — the authoritative record linking a customer (party) to a VIN. Captures: VIN, party_id (owner), ownership type (retail purchase/lease/fleet/government), acquisition date, acquisition channel (dealer/direct/auction/fleet), acquisition dealer code, purchase price, trade-in VIN, registration state/country, registration number, registration expiry, title number, title state, lien holder name, insurance carrier, insurance policy number, insurance expiry, odometer at acquisition, current odometer (last reported), is_primary_vehicle flag, disposition type (sold/traded/totaled/repossessed), disposition date, and disposition odometer. SSOT for customer-vehicle relationship; cross-references vehicle domain VIN master.';

CREATE OR REPLACE TABLE `automotive_ecm`.`customer`.`loyalty_membership` (
    `loyalty_membership_id` BIGINT COMMENT 'System-generated unique identifier for the loyalty membership record.',
    `account_id` BIGINT COMMENT 'Foreign key linking to billing.account. Business justification: Loyalty programs require billing account linkage for consolidated statements, points-based payment offsets, and redemption processing. OEMs integrate loyalty benefits into customer billing cycles for ',
    `party_id` BIGINT COMMENT 'Unique identifier of the customer (party) that holds the membership.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the loyalty membership record was first created.',
    `current_tier` STRING COMMENT 'Current loyalty tier of the member based on points qualification.. Valid values are `bronze|silver|gold|platinum`',
    `enrollment_channel` STRING COMMENT 'Channel through which the customer enrolled (e.g., online, in‑store).. Valid values are `online|in_store|dealer|call_center|mobile_app`',
    `enrollment_date` DATE COMMENT 'Date the customer enrolled in the loyalty program.',
    `is_primary_member` BOOLEAN COMMENT 'Indicates if this member is the primary account holder in a household linkage.',
    `last_activity_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent activity (e.g., point accrual, redemption) by the member.',
    `last_redemption_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent points redemption.',
    `lifetime_points_earned` DECIMAL(18,2) COMMENT 'Total points the member has earned over the lifetime of the membership.',
    `membership_expiry_date` DATE COMMENT 'Date when the membership itself expires if not renewed.',
    `membership_number` STRING COMMENT 'Business identifier assigned to the member within the loyalty program.',
    `notes` STRING COMMENT 'Free‑form comments or notes about the membership.',
    `points_balance` DECIMAL(18,2) COMMENT 'Current balance of loyalty points available for redemption.',
    `points_balance_last_year` DECIMAL(18,2) COMMENT 'Points balance at the end of the previous fiscal year.',
    `points_earned_this_year` DECIMAL(18,2) COMMENT 'Points accrued by the member during the current calendar year.',
    `points_expiry_date` DATE COMMENT 'Date on which the current points balance will expire if not used.',
    `points_redeemed_this_year` DECIMAL(18,2) COMMENT 'Points redeemed by the member during the current calendar year.',
    `preferred_redemption_category` STRING COMMENT 'Members preferred category for redeeming points.. Valid values are `service|accessories|cash|gift_card|charity`',
    `program_status` STRING COMMENT 'Current status of the membership within the loyalty program.. Valid values are `active|suspended|expired|cancelled`',
    `record_status` STRING COMMENT 'Lifecycle status of the record for data‑governance purposes.. Valid values are `active|inactive|deleted`',
    `redemption_eligibility_flag` BOOLEAN COMMENT 'Indicates whether the member is currently eligible to redeem points.',
    `referral_code` STRING COMMENT 'Alphanumeric code used by the member to refer new customers.',
    `salesforce_loyalty_member_reference` STRING COMMENT 'Identifier of the member record in Salesforce Automotive Cloud Loyalty Management.',
    `tier_benefits_description` STRING COMMENT 'Textual description of benefits associated with the current tier.',
    `tier_expiry_date` DATE COMMENT 'Date the current tier expires if not renewed.',
    `tier_points_required` DECIMAL(18,2) COMMENT 'Number of points required to reach the next tier level.',
    `tier_qualification_date` DATE COMMENT 'Date the member qualified for the current tier.',
    `total_points_redeemed` DECIMAL(18,2) COMMENT 'Aggregate number of points the member has redeemed.',
    `total_redemptions` STRING COMMENT 'Cumulative count of redemption transactions performed by the member.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the loyalty membership record.',
    CONSTRAINT pk_loyalty_membership PRIMARY KEY(`loyalty_membership_id`)
) COMMENT 'Manages customer enrollment and status in Automotive loyalty programs (e.g., owner rewards, EV early adopter program, fleet loyalty). Captures: program_id, party_id, membership number, enrollment date, enrollment channel, current tier (bronze/silver/gold/platinum), tier qualification date, tier expiry date, points balance, lifetime points earned, points expiry date, redemption eligibility flag, referral code, referred_by party_id, preferred redemption category, program status (active/suspended/expired/cancelled), and Salesforce Loyalty Management program member ID. Enables tier-based benefits, points accrual/redemption, and retention marketing.';

CREATE OR REPLACE TABLE `automotive_ecm`.`customer`.`preference` (
    `preference_id` BIGINT COMMENT 'Unique system-generated identifier for each preference entry.',
    `party_id` BIGINT COMMENT 'Identifier of the customer (person or organization) to whom the preference applies.',
    `channel` STRING COMMENT 'Preferred channel for delivering communications when the preference_category is communication.. Valid values are `email|sms|push|mail|phone`',
    `confidence_score` DECIMAL(18,2) COMMENT 'Confidence level (0.0000‑1.0000) that the stored preference accurately reflects the customers intent.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the preference record was first created in the system.',
    `data_origin_system` STRING COMMENT 'Identifies the source system that supplied the preference record.. Valid values are `salesforce|cdk|custom|other`',
    `effective_date` DATE COMMENT 'Date on which the preference becomes active.',
    `expiry_date` DATE COMMENT 'Date after which the preference is no longer valid; null if indefinite.',
    `is_opt_out` BOOLEAN COMMENT 'True if the customer has explicitly opted out of the indicated preference; otherwise false.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the preference record.',
    `notes` STRING COMMENT 'Optional free‑form comments or remarks about the preference.',
    `preference_category` STRING COMMENT 'High‑level grouping of the preference (e.g., communication, vehicle feature, service scheduling, digital experience, privacy).. Valid values are `communication|vehicle|service|digital|privacy`',
    `preference_status` STRING COMMENT 'Current lifecycle state of the preference (e.g., active, inactive, expired, pending review).. Valid values are `active|inactive|expired|pending`',
    `preference_value` DECIMAL(18,2) COMMENT 'The value assigned to the preference key; stored as text and interpreted according to value_data_type.',
    `source` STRING COMMENT 'Origin of the preference record: self‑declared by the customer, inferred by analytics, or imported from an external system.. Valid values are `self_declared|inferred|imported`',
    `value_data_type` STRING COMMENT 'Indicates the native data type of preference_value (e.g., string, boolean, integer, list).. Valid values are `string|boolean|integer|list`',
    CONSTRAINT pk_preference PRIMARY KEY(`preference_id`)
) COMMENT 'Stores customer-declared and inferred preferences for communications, vehicle features, service scheduling, and digital experiences. Each record captures: party_id, preference category (communication/vehicle/service/digital/privacy), preference key (e.g., preferred_fuel_type, preferred_body_style, preferred_service_day, email_frequency), preference value, value data type (string/boolean/integer/list), source (self-declared/inferred/imported), confidence score, effective date, expiry date, and last updated timestamp. Supports personalized marketing, product recommendation engines, and connected vehicle feature configuration.';

CREATE OR REPLACE TABLE `automotive_ecm`.`customer`.`nps_response` (
    `nps_response_id` BIGINT COMMENT 'System-generated unique identifier for each NPS survey response record.',
    `aftersales_repair_order_id` BIGINT COMMENT 'Foreign key linking to aftersales.aftersales_repair_order. Business justification: NPS surveys in automotive aftersales are triggered by specific service visits. Linking NPS responses to repair orders enables satisfaction tracking by service event, technician performance analysis, a',
    `case_id` BIGINT COMMENT 'Identifier of the service case created if the response was escalated.',
    `party_id` BIGINT COMMENT 'Unique identifier of the customer (person or organization) who provided the NPS response.',
    `vehicle_ownership_id` BIGINT COMMENT 'Foreign key linking to customer.vehicle_ownership. Business justification: NPS surveys in automotive are frequently triggered by vehicle purchase events, service visits, or ownership milestones — all of which are tied to a specific vehicle ownership record. nps_response curr',
    `vehicle_program_id` BIGINT COMMENT 'Foreign key linking to engineering.vehicle_program. Business justification: Automotive NPS surveys are tied to vehicle programs (model launches, model years) so program teams can track customer satisfaction by program and prioritize engineering improvements. Program managers ',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the NPS response record was first inserted into the data lake.',
    `dealer_code` STRING COMMENT 'Code of the dealer or service location linked to the survey touchpoint.',
    `follow_up_required_flag` BOOLEAN COMMENT 'Indicates whether the response requires follow‑up action (true) or not (false).',
    `follow_up_status` STRING COMMENT 'Current status of any follow‑up activity triggered by the response.. Valid values are `required|in_progress|completed|none`',
    `nps_response_status` STRING COMMENT 'Current processing state of the NPS response record.. Valid values are `pending|completed|escalated|closed`',
    `nps_score` STRING COMMENT 'Numeric rating provided by the respondent on a 0‑10 scale.',
    `promoter_category` STRING COMMENT 'Categorization of the NPS score: promoter (9‑10), passive (7‑8), or detractor (0‑6).. Valid values are `promoter|passive|detractor`',
    `response_date` DATE COMMENT 'Date on which the respondent submitted the completed survey.',
    `salesforce_survey_response_reference` STRING COMMENT 'Unique identifier of the response record in Salesforce Survey system.',
    `survey_channel` STRING COMMENT 'Medium through which the survey was delivered to the respondent.. Valid values are `email|sms|app|ivr`',
    `survey_date` DATE COMMENT 'Date on which the survey was presented to the respondent.',
    `survey_type` STRING COMMENT 'Indicates whether the NPS survey is transactional (post‑purchase) or relational (brand experience).. Valid values are `transactional|relational`',
    `touchpoint` STRING COMMENT 'Business interaction point at which the NPS survey was triggered.. Valid values are `vehicle_purchase|service_visit|delivery|recall|roadside|connected_app`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the NPS response record.',
    `verbatim_comment` STRING COMMENT 'Free‑text comment supplied by the respondent providing qualitative feedback.',
    CONSTRAINT pk_nps_response PRIMARY KEY(`nps_response_id`)
) COMMENT 'Captures Net Promoter Score survey responses from customers across all touchpoints in the automotive ownership journey. Records: party_id, VIN (if vehicle-specific), survey_id, survey type (transactional/relational), touchpoint (vehicle_purchase/service_visit/delivery/recall/roadside/connected_app), dealer code, nps_score (0-10), promoter category (promoter/passive/detractor), verbatim comment, survey channel (email/SMS/app/IVR), survey date, response date, follow-up required flag, follow-up status, case_id (if escalated), and Salesforce Survey Response ID. Feeds NPS KPI reporting and closed-loop customer recovery workflows.';

CREATE OR REPLACE TABLE `automotive_ecm`.`customer`.`case` (
    `case_id` BIGINT COMMENT 'Unique system-generated identifier for the customer service case.',
    `aftersales_repair_order_id` BIGINT COMMENT 'Foreign key linking to aftersales.aftersales_repair_order. Business justification: Customer complaints and escalations frequently reference specific repair orders. This link supports case management workflows, enables root cause analysis of service failures, tracks repeat repairs, a',
    `aftersales_warranty_claim_id` BIGINT COMMENT 'Foreign key linking to aftersales.aftersales_warranty_claim. Business justification: Warranty claim disputes are a major source of customer cases in automotive. Linking cases to warranty claims enables escalation tracking, adjudication appeals, goodwill decision support, and regulator',
    `ar_invoice_id` BIGINT COMMENT 'Foreign key linking to finance.ar_invoice. Business justification: Service cases (repairs, warranty claims) often generate customer-pay invoices for non-covered work or deductibles. Linking case to invoice enables dispute resolution, goodwill adjustment tracking, and',
    `contact_id` BIGINT COMMENT 'Foreign key linking to dealer.contact. Business justification: Cases are routinely assigned to specific dealer personnel (service advisors, sales managers, customer relations specialists) for resolution and follow-up. Case ownership tracking, workload management,',
    `dealership_id` BIGINT COMMENT 'Foreign key linking to dealer.dealership. Business justification: Customer service cases in automotive frequently involve dealer-specific issues (service quality complaints, sales disputes, warranty administration). Case routing, dealer performance tracking, escalat',
    `invoice_id` BIGINT COMMENT 'Foreign key linking to billing.invoice. Business justification: Customer service cases frequently involve disputed invoices (incorrect charges, warranty claim billing errors). Case management systems must reference specific invoices to track dispute resolution and',
    `part_master_id` BIGINT COMMENT 'Foreign key linking to engineering.part_master. Business justification: Warranty and recall case management requires identifying the specific defective part. Quality engineers use case-to-part linkage for root-cause analysis, recall scope determination, and warranty cost ',
    `party_id` BIGINT COMMENT 'Identifier of the customer (individual, fleet, corporate) who raised the case.',
    `recall_campaign_id` BIGINT COMMENT 'Foreign key linking to compliance.recall_campaign. Business justification: Customer cases frequently originate from recall campaigns—owners report symptoms, request recall service, or escalate incomplete repairs. Links case management to recall tracking for regulatory report',
    `vehicle_build_id` BIGINT COMMENT 'Foreign key linking to manufacturing.vehicle_build. Business justification: Warranty root-cause analysis and IATF 16949 traceability require linking customer quality/warranty cases directly to the specific vehicle build record (shift, line, BOM version, quality gate results, ',
    `vehicle_ownership_id` BIGINT COMMENT 'Foreign key linking to customer.vehicle_ownership. Business justification: A customer service case — particularly warranty claims, recall notifications, and service complaints — is directly associated with a specific vehicle ownership record. case already has party_id (who f',
    `vin_registry_id` BIGINT COMMENT 'Foreign key linking to vehicle.vin_registry. Business justification: Needed for service case management to pull vehicle specifications, warranty status, and recall info from VIN registry.',
    `case_category` STRING COMMENT 'Primary business category for the case (e.g., Service, Sales, Technical).',
    `case_description` STRING COMMENT 'Full free‑text description of the issue, request or complaint.',
    `case_number` STRING COMMENT 'Business-visible case number assigned at creation.',
    `case_status` STRING COMMENT 'Current lifecycle state of the case.. Valid values are `new|in_progress|pending_customer|resolved|closed|escalated`',
    `case_type` STRING COMMENT 'High-level classification of the case purpose.. Valid values are `complaint|inquiry|warranty_claim|recall|roadside|goodwill`',
    `closed_timestamp` TIMESTAMP COMMENT 'Date and time when the case was finally closed.',
    `customer_satisfaction_score` STRING COMMENT 'Post‑resolution satisfaction rating provided by the customer (e.g., 1‑10).',
    `dynamics_case_reference` STRING COMMENT 'Native Microsoft Dynamics 365 identifier for the case.',
    `escalation_level` STRING COMMENT 'Level of escalation applied to the case, if any.. Valid values are `level1|level2|level3`',
    `escalation_reason` STRING COMMENT 'Reason why the case was escalated.',
    `opened_timestamp` TIMESTAMP COMMENT 'Date and time when the case was initially created.',
    `priority` STRING COMMENT 'Business priority level indicating urgency (P1 highest).. Valid values are `P1|P2|P3|P4`',
    `record_audit_created` TIMESTAMP COMMENT 'System timestamp when the case record was first persisted.',
    `record_audit_updated` TIMESTAMP COMMENT 'System timestamp of the most recent update to the case record.',
    `resolution_code` STRING COMMENT 'Standard code representing how the case was resolved.',
    `resolution_description` STRING COMMENT 'Free‑text description of the resolution actions taken.',
    `resolved_timestamp` TIMESTAMP COMMENT 'Date and time when the case was marked as resolved.',
    `salesforce_case_reference` STRING COMMENT 'Native Salesforce identifier for the case record.',
    `sla_due_timestamp` TIMESTAMP COMMENT 'Target date/time by which the case should be resolved per Service Level Agreement.',
    `source_channel` STRING COMMENT 'Channel through which the case was originally submitted.. Valid values are `phone|email|web|in_person|mobile_app`',
    `sub_category` STRING COMMENT 'More detailed sub‑category within the main category.',
    `subject` STRING COMMENT 'Brief title or subject line summarising the case.',
    `total_handle_time_minutes` STRING COMMENT 'Cumulative time spent handling the case, measured in minutes.',
    CONSTRAINT pk_case PRIMARY KEY(`case_id`)
) COMMENT 'Customer service case record tracking complaints, inquiries, warranty claims, recall notifications, and roadside assistance requests raised by customers through any channel. Captures: party_id, VIN (if vehicle-related), case number, case type (complaint/inquiry/warranty_claim/recall/roadside/goodwill/lemon_law/regulatory), case category, case sub-category, subject, description, priority (P1-P4), status (new/in_progress/pending_customer/resolved/closed/escalated), opened date, SLA due date, resolved date, closed date, resolution code, resolution description, dealer code (if dealer-handled), assigned agent ID, escalation level, escalation reason, total handle time (minutes), customer satisfaction score (post-resolution), Salesforce Case ID, and Microsoft Dynamics 365 Case ID. SSOT for customer service operations.';

-- ========= FOREIGN KEYS =========
ALTER TABLE `automotive_ecm`.`customer`.`individual` ADD CONSTRAINT `fk_customer_individual_party_id` FOREIGN KEY (`party_id`) REFERENCES `automotive_ecm`.`customer`.`party`(`party_id`);
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ADD CONSTRAINT `fk_customer_organization_account_parent_organization_account_id` FOREIGN KEY (`parent_organization_account_id`) REFERENCES `automotive_ecm`.`customer`.`organization_account`(`organization_account_id`);
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ADD CONSTRAINT `fk_customer_organization_account_party_id` FOREIGN KEY (`party_id`) REFERENCES `automotive_ecm`.`customer`.`party`(`party_id`);
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ADD CONSTRAINT `fk_customer_contact_point_party_id` FOREIGN KEY (`party_id`) REFERENCES `automotive_ecm`.`customer`.`party`(`party_id`);
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ADD CONSTRAINT `fk_customer_vehicle_ownership_party_id` FOREIGN KEY (`party_id`) REFERENCES `automotive_ecm`.`customer`.`party`(`party_id`);
ALTER TABLE `automotive_ecm`.`customer`.`loyalty_membership` ADD CONSTRAINT `fk_customer_loyalty_membership_party_id` FOREIGN KEY (`party_id`) REFERENCES `automotive_ecm`.`customer`.`party`(`party_id`);
ALTER TABLE `automotive_ecm`.`customer`.`preference` ADD CONSTRAINT `fk_customer_preference_party_id` FOREIGN KEY (`party_id`) REFERENCES `automotive_ecm`.`customer`.`party`(`party_id`);
ALTER TABLE `automotive_ecm`.`customer`.`nps_response` ADD CONSTRAINT `fk_customer_nps_response_case_id` FOREIGN KEY (`case_id`) REFERENCES `automotive_ecm`.`customer`.`case`(`case_id`);
ALTER TABLE `automotive_ecm`.`customer`.`nps_response` ADD CONSTRAINT `fk_customer_nps_response_party_id` FOREIGN KEY (`party_id`) REFERENCES `automotive_ecm`.`customer`.`party`(`party_id`);
ALTER TABLE `automotive_ecm`.`customer`.`nps_response` ADD CONSTRAINT `fk_customer_nps_response_vehicle_ownership_id` FOREIGN KEY (`vehicle_ownership_id`) REFERENCES `automotive_ecm`.`customer`.`vehicle_ownership`(`vehicle_ownership_id`);
ALTER TABLE `automotive_ecm`.`customer`.`case` ADD CONSTRAINT `fk_customer_case_party_id` FOREIGN KEY (`party_id`) REFERENCES `automotive_ecm`.`customer`.`party`(`party_id`);
ALTER TABLE `automotive_ecm`.`customer`.`case` ADD CONSTRAINT `fk_customer_case_vehicle_ownership_id` FOREIGN KEY (`vehicle_ownership_id`) REFERENCES `automotive_ecm`.`customer`.`vehicle_ownership`(`vehicle_ownership_id`);

-- ========= TAGS =========
ALTER SCHEMA `automotive_ecm`.`customer` SET TAGS ('dbx_division' = 'business');
ALTER SCHEMA `automotive_ecm`.`customer` SET TAGS ('dbx_domain' = 'customer');
ALTER TABLE `automotive_ecm`.`customer`.`party` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `automotive_ecm`.`customer`.`party` SET TAGS ('dbx_subdomain' = 'identity_management');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Party Identifier');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `address_line1` SET TAGS ('dbx_business_glossary_term' = 'Address Line 1 (ADDR_LINE1)');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `address_line1` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `address_line1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `address_line2` SET TAGS ('dbx_business_glossary_term' = 'Address Line 2 (ADDR_LINE2)');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `address_line2` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `address_line2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `address_type` SET TAGS ('dbx_business_glossary_term' = 'Address Type (ADDR_TYPE)');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `address_type` SET TAGS ('dbx_value_regex' = 'billing|shipping|mailing|primary');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `city` SET TAGS ('dbx_business_glossary_term' = 'City (CITY)');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `city` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `communication_preference` SET TAGS ('dbx_business_glossary_term' = 'Communication Preference (COMM_PREF)');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `communication_preference` SET TAGS ('dbx_value_regex' = 'email|sms|phone|mail');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Country Code (ISO 3166‑1 Alpha‑3)');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `country_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `country_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `credit_rating` SET TAGS ('dbx_business_glossary_term' = 'Credit Rating (CR)');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `credit_rating` SET TAGS ('dbx_value_regex' = 'AAA|AA|A|BBB|BB|B');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `credit_rating` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `credit_rating` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `customer_lifetime_value` SET TAGS ('dbx_business_glossary_term' = 'Customer Lifetime Value (CLTV)');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `customer_lifetime_value` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `customer_lifetime_value` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `customer_segment` SET TAGS ('dbx_business_glossary_term' = 'Customer Segment (SEGMENT)');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `customer_segment` SET TAGS ('dbx_value_regex' = 'mass_market|premium|fleet|government|enterprise');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `data_residency_region` SET TAGS ('dbx_business_glossary_term' = 'Data Residency Region (DATA_RES_REGION)');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_business_glossary_term' = 'Date of Birth (DOB)');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_pii_dob' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `email_address` SET TAGS ('dbx_business_glossary_term' = 'Email Address (EMAIL)');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `email_address` SET TAGS ('dbx_value_regex' = '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+.[A-Za-z]{2,}$');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `email_address` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `email_address` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `external_reference_code` SET TAGS ('dbx_business_glossary_term' = 'External Reference Code (EXT_REF_CODE)');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `gdpr_consent_email` SET TAGS ('dbx_business_glossary_term' = 'GDPR Email Consent (GDPR_EMAIL)');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `gdpr_consent_email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `gdpr_consent_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `gdpr_consent_sms` SET TAGS ('dbx_business_glossary_term' = 'GDPR SMS Consent (GDPR_SMS)');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `incorporation_date` SET TAGS ('dbx_business_glossary_term' = 'Incorporation Date (INCORP_DATE)');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `industry_classification` SET TAGS ('dbx_business_glossary_term' = 'Industry Classification (NAICS/SIC)');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `is_tax_exempt` SET TAGS ('dbx_business_glossary_term' = 'Tax Exempt Flag (TAX_EXEMPT)');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `kyc_status` SET TAGS ('dbx_business_glossary_term' = 'Know‑Your‑Customer Status (KYC_STATUS)');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `kyc_status` SET TAGS ('dbx_value_regex' = 'pending|verified|rejected');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `last_verified_date` SET TAGS ('dbx_business_glossary_term' = 'Last Verified Date (LAST_VERIFIED)');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `legal_name` SET TAGS ('dbx_business_glossary_term' = 'Legal Name (FULL)');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `legal_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `legal_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `lifecycle_status` SET TAGS ('dbx_business_glossary_term' = 'Lifecycle Status (LIFECYCLE_STATUS)');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `lifecycle_status` SET TAGS ('dbx_value_regex' = 'prospect|active|inactive|churned|suspended');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `loyalty_tier` SET TAGS ('dbx_business_glossary_term' = 'Loyalty Tier (LOYALTY_TIER)');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `loyalty_tier` SET TAGS ('dbx_value_regex' = 'bronze|silver|gold|platinum');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `marketing_opt_in` SET TAGS ('dbx_business_glossary_term' = 'Marketing Opt‑In Flag (MKT_OPT_IN)');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `net_promoter_score` SET TAGS ('dbx_business_glossary_term' = 'Net Promoter Score (NPS)');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes (FREE_TEXT)');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `onboarding_channel` SET TAGS ('dbx_business_glossary_term' = 'Onboarding Channel (ONB_CHANNEL)');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `onboarding_channel` SET TAGS ('dbx_value_regex' = 'online|branch|dealer|partner');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `onboarding_date` SET TAGS ('dbx_business_glossary_term' = 'Onboarding Date (ONB_DATE)');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `party_type` SET TAGS ('dbx_business_glossary_term' = 'Party Type (INDIVIDUAL|ORGANIZATION)');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `party_type` SET TAGS ('dbx_value_regex' = 'individual|organization');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `phone_number` SET TAGS ('dbx_business_glossary_term' = 'Phone Number (PHONE)');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `phone_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `phone_number` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `postal_code` SET TAGS ('dbx_business_glossary_term' = 'Postal Code (POSTAL_CODE)');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `postal_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `preferred_currency` SET TAGS ('dbx_business_glossary_term' = 'Preferred Currency (CURR_PREF)');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `preferred_language` SET TAGS ('dbx_business_glossary_term' = 'Preferred Language (LANG_PREF)');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `primary_contact_method` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Method (PRIMARY_CONTACT)');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `primary_contact_method` SET TAGS ('dbx_value_regex' = 'email|phone|mail');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `record_audit_created` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp (CREATED_TS)');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `record_audit_updated` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp (UPDATED_TS)');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `registration_number` SET TAGS ('dbx_business_glossary_term' = 'Registration Number (REG_NO)');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `registration_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `registration_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `source_system` SET TAGS ('dbx_business_glossary_term' = 'Source System (SRC_SYS)');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Identifier (SRC_SYS_ID)');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `state_province` SET TAGS ('dbx_business_glossary_term' = 'State or Province (STATE_PROV)');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `state_province` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `state_province` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `tax_exempt_reason` SET TAGS ('dbx_business_glossary_term' = 'Tax Exempt Reason (TAX_EXEMPT_REASON)');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_business_glossary_term' = 'Tax Identification Number (TIN)');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`party` ALTER COLUMN `trade_name` SET TAGS ('dbx_business_glossary_term' = 'Trade Name (DBA)');
ALTER TABLE `automotive_ecm`.`customer`.`individual` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `automotive_ecm`.`customer`.`individual` SET TAGS ('dbx_subdomain' = 'identity_management');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `individual_id` SET TAGS ('dbx_business_glossary_term' = 'Individual ID');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `dealership_id` SET TAGS ('dbx_business_glossary_term' = 'Preferred Dealer ID');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `individual_preferred_dealer_dealership_id` SET TAGS ('dbx_business_glossary_term' = 'Preferred Dealer ID');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Party Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `payment_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Payment Plan Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `contact_id` SET TAGS ('dbx_business_glossary_term' = 'Salesforce Contact ID');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `annual_income_band` SET TAGS ('dbx_business_glossary_term' = 'Annual Income Band');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `annual_income_band` SET TAGS ('dbx_value_regex' = '0-25k|25k-50k|50k-75k|75k-100k|100k-150k|150k+');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `cltv_estimate` SET TAGS ('dbx_business_glossary_term' = 'Customer Lifetime Value Estimate (CLTV)');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `cltv_estimate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `cltv_estimate` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `consent_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Marketing Consent Timestamp');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `country_of_residence` SET TAGS ('dbx_business_glossary_term' = 'Country of Residence (ISO 3166‑1 Alpha‑3)');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `customer_type` SET TAGS ('dbx_business_glossary_term' = 'Customer Type');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `customer_type` SET TAGS ('dbx_value_regex' = 'b2c|b2b|government|fleet');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `driver_license_expiry` SET TAGS ('dbx_business_glossary_term' = 'Driver License Expiry Date');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `driver_license_expiry` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `driver_license_expiry` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `driver_license_number` SET TAGS ('dbx_business_glossary_term' = 'Driver License Number');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `driver_license_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `driver_license_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `driver_license_state` SET TAGS ('dbx_business_glossary_term' = 'Driver License State/Province');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `driver_license_state` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `driver_license_state` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `education_level` SET TAGS ('dbx_business_glossary_term' = 'Education Level');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `education_level` SET TAGS ('dbx_value_regex' = 'high_school|associate|bachelor|master|doctorate|other');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `employment_status` SET TAGS ('dbx_business_glossary_term' = 'Employment Status');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `employment_status` SET TAGS ('dbx_value_regex' = 'employed|unemployed|student|retired|self_employed|other');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `first_name` SET TAGS ('dbx_business_glossary_term' = 'First Name (FN)');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `first_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `first_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `gender` SET TAGS ('dbx_business_glossary_term' = 'Gender');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `gender` SET TAGS ('dbx_value_regex' = 'male|female|other|prefer_not_to_say');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `gender` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `gender` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `individual_status` SET TAGS ('dbx_business_glossary_term' = 'Individual Status');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `individual_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|prospect|deceased');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `last_name` SET TAGS ('dbx_business_glossary_term' = 'Last Name (LN)');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `last_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `last_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `last_purchase_date` SET TAGS ('dbx_business_glossary_term' = 'Last Purchase Date');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `loyalty_tier` SET TAGS ('dbx_business_glossary_term' = 'Loyalty Tier');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `loyalty_tier` SET TAGS ('dbx_value_regex' = 'bronze|silver|gold|platinum|elite');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `marital_status` SET TAGS ('dbx_business_glossary_term' = 'Marital Status');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `marital_status` SET TAGS ('dbx_value_regex' = 'single|married|divorced|widowed|partnered|prefer_not_to_say');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `marital_status` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `marital_status` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `marketing_opt_in_email` SET TAGS ('dbx_business_glossary_term' = 'Marketing Opt‑In Email');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `marketing_opt_in_email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `marketing_opt_in_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `marketing_opt_in_phone` SET TAGS ('dbx_business_glossary_term' = 'Marketing Opt‑In Phone');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `marketing_opt_in_phone` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `marketing_opt_in_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `marketing_opt_in_sms` SET TAGS ('dbx_business_glossary_term' = 'Marketing Opt‑In SMS');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `middle_name` SET TAGS ('dbx_business_glossary_term' = 'Middle Name (MN)');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `middle_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `middle_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `nationality` SET TAGS ('dbx_business_glossary_term' = 'Nationality (ISO 3166‑1 Alpha‑3)');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `nationality` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `nationality` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `nps_score` SET TAGS ('dbx_business_glossary_term' = 'Net Promoter Score (NPS)');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `occupation` SET TAGS ('dbx_business_glossary_term' = 'Occupation');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `preferred_contact_method` SET TAGS ('dbx_business_glossary_term' = 'Preferred Contact Method');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `preferred_contact_method` SET TAGS ('dbx_value_regex' = 'email|phone|sms|mail|app_notification');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `primary_spoken_language` SET TAGS ('dbx_business_glossary_term' = 'Primary Spoken Language');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `record_audit_created` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `record_audit_updated` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `segment` SET TAGS ('dbx_business_glossary_term' = 'Customer Segment');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `source_system` SET TAGS ('dbx_business_glossary_term' = 'Source System');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `suffix` SET TAGS ('dbx_business_glossary_term' = 'Name Suffix');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `suffix` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `suffix` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`individual` ALTER COLUMN `vehicle_ownership_count` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Ownership Count');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` SET TAGS ('dbx_subdomain' = 'identity_management');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `organization_account_id` SET TAGS ('dbx_business_glossary_term' = 'Organization Account ID');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `payment_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Fleet Payment Plan Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `parent_organization_account_id` SET TAGS ('dbx_business_glossary_term' = 'Parent Organization Account ID');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Party Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `vehicle_program_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Program Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `account_tier` SET TAGS ('dbx_business_glossary_term' = 'Account Tier');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `account_tier` SET TAGS ('dbx_value_regex' = 'strategic|key|standard');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `accounts_payable_contact_email` SET TAGS ('dbx_business_glossary_term' = 'Accounts Payable Contact Email');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `accounts_payable_contact_email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `accounts_payable_contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `accounts_payable_contact_name` SET TAGS ('dbx_business_glossary_term' = 'Accounts Payable Contact Name');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `accounts_payable_contact_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `accounts_payable_contact_name` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `accounts_payable_contact_phone` SET TAGS ('dbx_business_glossary_term' = 'Accounts Payable Contact Phone');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `accounts_payable_contact_phone` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `accounts_payable_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `annual_revenue` SET TAGS ('dbx_business_glossary_term' = 'Annual Revenue (USD)');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `annual_revenue` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `annual_revenue` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `classification` SET TAGS ('dbx_business_glossary_term' = 'Organization Classification');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `classification` SET TAGS ('dbx_value_regex' = 'corporate|fleet|government|leasing');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `contract_vehicle_type` SET TAGS ('dbx_business_glossary_term' = 'Contract Vehicle Type');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `contract_vehicle_type` SET TAGS ('dbx_value_regex' = 'GSA|state|none');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `credit_limit` SET TAGS ('dbx_business_glossary_term' = 'Credit Limit (USD)');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `credit_limit` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `credit_limit` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `dba_name` SET TAGS ('dbx_business_glossary_term' = 'Doing Business As (DBA) Name');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `duns_number` SET TAGS ('dbx_business_glossary_term' = 'DUNS Number (Data Universal Numbering System)');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `duns_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `duns_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `effective_from` SET TAGS ('dbx_business_glossary_term' = 'Effective From Date');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `effective_until` SET TAGS ('dbx_business_glossary_term' = 'Effective Until Date');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `fleet_size` SET TAGS ('dbx_business_glossary_term' = 'Fleet Size');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `government_entity_type` SET TAGS ('dbx_business_glossary_term' = 'Government Entity Type');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `government_entity_type` SET TAGS ('dbx_value_regex' = 'federal|state|municipal|private');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `industry_codes` SET TAGS ('dbx_business_glossary_term' = 'Additional Industry Codes');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `naics_code` SET TAGS ('dbx_business_glossary_term' = 'North American Industry Classification System (NAICS) Code');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `number_of_employees` SET TAGS ('dbx_business_glossary_term' = 'Number of Employees');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `number_of_employees` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `organization_account_status` SET TAGS ('dbx_business_glossary_term' = 'Account Status');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `organization_account_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|pending|closed');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `payment_terms` SET TAGS ('dbx_business_glossary_term' = 'Payment Terms');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `payment_terms` SET TAGS ('dbx_value_regex' = 'net_30|net_45|net_60|due_on_receipt|custom');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `preferred_oem_programs` SET TAGS ('dbx_business_glossary_term' = 'Preferred OEM Programs');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `procurement_contact_email` SET TAGS ('dbx_business_glossary_term' = 'Procurement Contact Email');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `procurement_contact_email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `procurement_contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `procurement_contact_name` SET TAGS ('dbx_business_glossary_term' = 'Procurement Contact Name');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `procurement_contact_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `procurement_contact_name` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `procurement_contact_phone` SET TAGS ('dbx_business_glossary_term' = 'Procurement Contact Phone');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `procurement_contact_phone` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `procurement_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `sap_customer_number` SET TAGS ('dbx_business_glossary_term' = 'SAP Customer Number');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `sic_code` SET TAGS ('dbx_business_glossary_term' = 'Standard Industrial Classification (SIC) Code');
ALTER TABLE `automotive_ecm`.`customer`.`organization_account` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` SET TAGS ('dbx_subdomain' = 'identity_management');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `contact_point_id` SET TAGS ('dbx_business_glossary_term' = 'Contact Point ID');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Party Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `address_line1` SET TAGS ('dbx_business_glossary_term' = 'Address Line 1');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `address_line1` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `address_line1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `address_line2` SET TAGS ('dbx_business_glossary_term' = 'Address Line 2');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `address_line2` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `address_line2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `channel` SET TAGS ('dbx_business_glossary_term' = 'Communication Channel');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `channel` SET TAGS ('dbx_value_regex' = 'voice|sms|email|mail|push|social');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `city` SET TAGS ('dbx_business_glossary_term' = 'City');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `city` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `classification` SET TAGS ('dbx_business_glossary_term' = 'Contact Point Classification');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `classification` SET TAGS ('dbx_value_regex' = 'personal|business|dealer|fleet|government');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `communication_preference` SET TAGS ('dbx_business_glossary_term' = 'Communication Preference');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `communication_preference` SET TAGS ('dbx_value_regex' = 'marketing|transactional|service|none');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `contact_point_status` SET TAGS ('dbx_business_glossary_term' = 'Contact Point Status');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `contact_point_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|suspended|deleted');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `contact_point_type` SET TAGS ('dbx_business_glossary_term' = 'Contact Point Type');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `contact_point_type` SET TAGS ('dbx_value_regex' = 'email|phone|address|social|other');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `contact_point_value` SET TAGS ('dbx_business_glossary_term' = 'Contact Point Value');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Country Code (ISO 3166‑1 Alpha‑3)');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `country_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `country_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `email_address` SET TAGS ('dbx_business_glossary_term' = 'Email Address');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `email_address` SET TAGS ('dbx_value_regex' = '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+.[A-Za-z]{2,}$');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `email_address` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `email_address` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `is_primary` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Flag');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `is_verified` SET TAGS ('dbx_business_glossary_term' = 'Verification Status');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `language_preference` SET TAGS ('dbx_business_glossary_term' = 'Language Preference');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `last_used_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Used Timestamp');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `opt_in_status` SET TAGS ('dbx_business_glossary_term' = 'Opt‑In Status');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `opt_out_date` SET TAGS ('dbx_business_glossary_term' = 'Opt‑Out Timestamp');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `phone_number` SET TAGS ('dbx_business_glossary_term' = 'Phone Number');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `phone_number` SET TAGS ('dbx_value_regex' = '^+?[0-9]{7,15}$');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `phone_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `phone_number` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `postal_code` SET TAGS ('dbx_business_glossary_term' = 'Postal Code');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `postal_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `preferred_contact_hours` SET TAGS ('dbx_business_glossary_term' = 'Preferred Contact Hours');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `preferred_time_zone` SET TAGS ('dbx_business_glossary_term' = 'Preferred Time Zone');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `social_handle` SET TAGS ('dbx_business_glossary_term' = 'Social Media Handle');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `social_handle` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `social_handle` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `social_platform` SET TAGS ('dbx_business_glossary_term' = 'Social Media Platform');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `social_platform` SET TAGS ('dbx_value_regex' = 'twitter|linkedin|facebook|instagram|other');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `source_system` SET TAGS ('dbx_business_glossary_term' = 'Source System');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `state_province` SET TAGS ('dbx_business_glossary_term' = 'State/Province');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `state_province` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `state_province` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `verification_date` SET TAGS ('dbx_business_glossary_term' = 'Verification Timestamp');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `verification_method` SET TAGS ('dbx_business_glossary_term' = 'Verification Method');
ALTER TABLE `automotive_ecm`.`customer`.`contact_point` ALTER COLUMN `verification_method` SET TAGS ('dbx_value_regex' = 'email|sms|call|postal|in_person|other');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` SET TAGS ('dbx_subdomain' = 'ownership_tracking');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `vehicle_ownership_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Ownership Record ID');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `ar_invoice_id` SET TAGS ('dbx_business_glossary_term' = 'Ar Invoice Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `configuration_id` SET TAGS ('dbx_business_glossary_term' = 'Configuration Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `dealership_id` SET TAGS ('dbx_business_glossary_term' = 'Dealership Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `fixed_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Fixed Asset Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `homologation_record_id` SET TAGS ('dbx_business_glossary_term' = 'Homologation Record Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Customer ID');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `production_variant_id` SET TAGS ('dbx_business_glossary_term' = 'Production Variant Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `vehicle_order_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Order Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `vehicle_program_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Program Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `vin_registry_id` SET TAGS ('dbx_business_glossary_term' = 'Vin Registry Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `acquisition_channel` SET TAGS ('dbx_business_glossary_term' = 'Acquisition Channel');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `acquisition_channel` SET TAGS ('dbx_value_regex' = 'dealer|direct|auction|fleet');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `acquisition_date` SET TAGS ('dbx_business_glossary_term' = 'Acquisition Date');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `acquisition_dealer_code` SET TAGS ('dbx_business_glossary_term' = 'Acquisition Dealer Code');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `current_odometer` SET TAGS ('dbx_business_glossary_term' = 'Current Odometer Reading');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `disposition_date` SET TAGS ('dbx_business_glossary_term' = 'Disposition Date');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `disposition_odometer` SET TAGS ('dbx_business_glossary_term' = 'Disposition Odometer Reading');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `disposition_type` SET TAGS ('dbx_business_glossary_term' = 'Disposition Type');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `disposition_type` SET TAGS ('dbx_value_regex' = 'sold|traded|totaled|repossessed|retired');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `insurance_carrier` SET TAGS ('dbx_business_glossary_term' = 'Insurance Carrier');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `insurance_expiry` SET TAGS ('dbx_business_glossary_term' = 'Insurance Expiry Date');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `insurance_policy_number` SET TAGS ('dbx_business_glossary_term' = 'Insurance Policy Number');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `insurance_policy_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `insurance_policy_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `is_primary_vehicle` SET TAGS ('dbx_business_glossary_term' = 'Primary Vehicle Indicator');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `lien_holder_name` SET TAGS ('dbx_business_glossary_term' = 'Lien Holder Name');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `lien_holder_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `odometer_at_acquisition` SET TAGS ('dbx_business_glossary_term' = 'Acquisition Odometer Reading');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `ownership_number` SET TAGS ('dbx_business_glossary_term' = 'Ownership Contract Number');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `ownership_type` SET TAGS ('dbx_business_glossary_term' = 'Ownership Type');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `ownership_type` SET TAGS ('dbx_value_regex' = 'retail|lease|fleet|government');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `purchase_price` SET TAGS ('dbx_business_glossary_term' = 'Purchase Price');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `purchase_price` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `purchase_price` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `registration_country` SET TAGS ('dbx_business_glossary_term' = 'Registration Country');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `registration_expiry` SET TAGS ('dbx_business_glossary_term' = 'Registration Expiry Date');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `registration_number` SET TAGS ('dbx_business_glossary_term' = 'Registration Number');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `registration_state` SET TAGS ('dbx_business_glossary_term' = 'Registration State');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `title_number` SET TAGS ('dbx_business_glossary_term' = 'Title Number');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `title_state` SET TAGS ('dbx_business_glossary_term' = 'Title State');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `trade_in_vin` SET TAGS ('dbx_business_glossary_term' = 'Trade‑In Vehicle VIN');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `vehicle_ownership_status` SET TAGS ('dbx_business_glossary_term' = 'Ownership Record Status');
ALTER TABLE `automotive_ecm`.`customer`.`vehicle_ownership` ALTER COLUMN `vehicle_ownership_status` SET TAGS ('dbx_value_regex' = 'active|inactive|closed|pending');
ALTER TABLE `automotive_ecm`.`customer`.`loyalty_membership` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `automotive_ecm`.`customer`.`loyalty_membership` SET TAGS ('dbx_subdomain' = 'ownership_tracking');
ALTER TABLE `automotive_ecm`.`customer`.`loyalty_membership` ALTER COLUMN `loyalty_membership_id` SET TAGS ('dbx_business_glossary_term' = 'Loyalty Membership ID');
ALTER TABLE `automotive_ecm`.`customer`.`loyalty_membership` ALTER COLUMN `account_id` SET TAGS ('dbx_business_glossary_term' = 'Billing Account Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`customer`.`loyalty_membership` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Customer ID');
ALTER TABLE `automotive_ecm`.`customer`.`loyalty_membership` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `automotive_ecm`.`customer`.`loyalty_membership` ALTER COLUMN `current_tier` SET TAGS ('dbx_business_glossary_term' = 'Current Tier (BRONZE/SILVER/GOLD/PLATINUM)');
ALTER TABLE `automotive_ecm`.`customer`.`loyalty_membership` ALTER COLUMN `current_tier` SET TAGS ('dbx_value_regex' = 'bronze|silver|gold|platinum');
ALTER TABLE `automotive_ecm`.`customer`.`loyalty_membership` ALTER COLUMN `enrollment_channel` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Channel');
ALTER TABLE `automotive_ecm`.`customer`.`loyalty_membership` ALTER COLUMN `enrollment_channel` SET TAGS ('dbx_value_regex' = 'online|in_store|dealer|call_center|mobile_app');
ALTER TABLE `automotive_ecm`.`customer`.`loyalty_membership` ALTER COLUMN `enrollment_date` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Date');
ALTER TABLE `automotive_ecm`.`customer`.`loyalty_membership` ALTER COLUMN `is_primary_member` SET TAGS ('dbx_business_glossary_term' = 'Is Primary Member Flag');
ALTER TABLE `automotive_ecm`.`customer`.`loyalty_membership` ALTER COLUMN `last_activity_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Activity Timestamp');
ALTER TABLE `automotive_ecm`.`customer`.`loyalty_membership` ALTER COLUMN `last_redemption_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Redemption Timestamp');
ALTER TABLE `automotive_ecm`.`customer`.`loyalty_membership` ALTER COLUMN `lifetime_points_earned` SET TAGS ('dbx_business_glossary_term' = 'Lifetime Points Earned');
ALTER TABLE `automotive_ecm`.`customer`.`loyalty_membership` ALTER COLUMN `membership_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Membership Expiry Date');
ALTER TABLE `automotive_ecm`.`customer`.`loyalty_membership` ALTER COLUMN `membership_number` SET TAGS ('dbx_business_glossary_term' = 'Membership Number (MEMBER_NO)');
ALTER TABLE `automotive_ecm`.`customer`.`loyalty_membership` ALTER COLUMN `membership_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`loyalty_membership` ALTER COLUMN `membership_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`loyalty_membership` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `automotive_ecm`.`customer`.`loyalty_membership` ALTER COLUMN `points_balance` SET TAGS ('dbx_business_glossary_term' = 'Points Balance');
ALTER TABLE `automotive_ecm`.`customer`.`loyalty_membership` ALTER COLUMN `points_balance_last_year` SET TAGS ('dbx_business_glossary_term' = 'Points Balance Last Year');
ALTER TABLE `automotive_ecm`.`customer`.`loyalty_membership` ALTER COLUMN `points_earned_this_year` SET TAGS ('dbx_business_glossary_term' = 'Points Earned This Year');
ALTER TABLE `automotive_ecm`.`customer`.`loyalty_membership` ALTER COLUMN `points_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Points Expiry Date');
ALTER TABLE `automotive_ecm`.`customer`.`loyalty_membership` ALTER COLUMN `points_redeemed_this_year` SET TAGS ('dbx_business_glossary_term' = 'Points Redeemed This Year');
ALTER TABLE `automotive_ecm`.`customer`.`loyalty_membership` ALTER COLUMN `preferred_redemption_category` SET TAGS ('dbx_business_glossary_term' = 'Preferred Redemption Category');
ALTER TABLE `automotive_ecm`.`customer`.`loyalty_membership` ALTER COLUMN `preferred_redemption_category` SET TAGS ('dbx_value_regex' = 'service|accessories|cash|gift_card|charity');
ALTER TABLE `automotive_ecm`.`customer`.`loyalty_membership` ALTER COLUMN `program_status` SET TAGS ('dbx_business_glossary_term' = 'Program Status');
ALTER TABLE `automotive_ecm`.`customer`.`loyalty_membership` ALTER COLUMN `program_status` SET TAGS ('dbx_value_regex' = 'active|suspended|expired|cancelled');
ALTER TABLE `automotive_ecm`.`customer`.`loyalty_membership` ALTER COLUMN `record_status` SET TAGS ('dbx_business_glossary_term' = 'Record Status');
ALTER TABLE `automotive_ecm`.`customer`.`loyalty_membership` ALTER COLUMN `record_status` SET TAGS ('dbx_value_regex' = 'active|inactive|deleted');
ALTER TABLE `automotive_ecm`.`customer`.`loyalty_membership` ALTER COLUMN `redemption_eligibility_flag` SET TAGS ('dbx_business_glossary_term' = 'Redemption Eligibility Flag');
ALTER TABLE `automotive_ecm`.`customer`.`loyalty_membership` ALTER COLUMN `referral_code` SET TAGS ('dbx_business_glossary_term' = 'Referral Code');
ALTER TABLE `automotive_ecm`.`customer`.`loyalty_membership` ALTER COLUMN `salesforce_loyalty_member_reference` SET TAGS ('dbx_business_glossary_term' = 'Salesforce Loyalty Member ID');
ALTER TABLE `automotive_ecm`.`customer`.`loyalty_membership` ALTER COLUMN `salesforce_loyalty_member_reference` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`loyalty_membership` ALTER COLUMN `salesforce_loyalty_member_reference` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `automotive_ecm`.`customer`.`loyalty_membership` ALTER COLUMN `tier_benefits_description` SET TAGS ('dbx_business_glossary_term' = 'Tier Benefits Description');
ALTER TABLE `automotive_ecm`.`customer`.`loyalty_membership` ALTER COLUMN `tier_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Tier Expiry Date');
ALTER TABLE `automotive_ecm`.`customer`.`loyalty_membership` ALTER COLUMN `tier_points_required` SET TAGS ('dbx_business_glossary_term' = 'Tier Points Required');
ALTER TABLE `automotive_ecm`.`customer`.`loyalty_membership` ALTER COLUMN `tier_qualification_date` SET TAGS ('dbx_business_glossary_term' = 'Tier Qualification Date');
ALTER TABLE `automotive_ecm`.`customer`.`loyalty_membership` ALTER COLUMN `total_points_redeemed` SET TAGS ('dbx_business_glossary_term' = 'Total Points Redeemed');
ALTER TABLE `automotive_ecm`.`customer`.`loyalty_membership` ALTER COLUMN `total_redemptions` SET TAGS ('dbx_business_glossary_term' = 'Total Redemptions');
ALTER TABLE `automotive_ecm`.`customer`.`loyalty_membership` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `automotive_ecm`.`customer`.`preference` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `automotive_ecm`.`customer`.`preference` SET TAGS ('dbx_subdomain' = 'ownership_tracking');
ALTER TABLE `automotive_ecm`.`customer`.`preference` ALTER COLUMN `preference_id` SET TAGS ('dbx_business_glossary_term' = 'Preference ID');
ALTER TABLE `automotive_ecm`.`customer`.`preference` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Customer ID');
ALTER TABLE `automotive_ecm`.`customer`.`preference` ALTER COLUMN `channel` SET TAGS ('dbx_business_glossary_term' = 'Preference Communication Channel');
ALTER TABLE `automotive_ecm`.`customer`.`preference` ALTER COLUMN `channel` SET TAGS ('dbx_value_regex' = 'email|sms|push|mail|phone');
ALTER TABLE `automotive_ecm`.`customer`.`preference` ALTER COLUMN `confidence_score` SET TAGS ('dbx_business_glossary_term' = 'Preference Confidence Score');
ALTER TABLE `automotive_ecm`.`customer`.`preference` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Preference Record Creation Timestamp');
ALTER TABLE `automotive_ecm`.`customer`.`preference` ALTER COLUMN `data_origin_system` SET TAGS ('dbx_business_glossary_term' = 'Preference Data Origin System');
ALTER TABLE `automotive_ecm`.`customer`.`preference` ALTER COLUMN `data_origin_system` SET TAGS ('dbx_value_regex' = 'salesforce|cdk|custom|other');
ALTER TABLE `automotive_ecm`.`customer`.`preference` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Preference Effective Date');
ALTER TABLE `automotive_ecm`.`customer`.`preference` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Preference Expiry Date');
ALTER TABLE `automotive_ecm`.`customer`.`preference` ALTER COLUMN `is_opt_out` SET TAGS ('dbx_business_glossary_term' = 'Preference Opt‑Out Indicator');
ALTER TABLE `automotive_ecm`.`customer`.`preference` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Preference Record Last Updated Timestamp');
ALTER TABLE `automotive_ecm`.`customer`.`preference` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Preference Notes');
ALTER TABLE `automotive_ecm`.`customer`.`preference` ALTER COLUMN `preference_category` SET TAGS ('dbx_business_glossary_term' = 'Preference Category');
ALTER TABLE `automotive_ecm`.`customer`.`preference` ALTER COLUMN `preference_category` SET TAGS ('dbx_value_regex' = 'communication|vehicle|service|digital|privacy');
ALTER TABLE `automotive_ecm`.`customer`.`preference` ALTER COLUMN `preference_status` SET TAGS ('dbx_business_glossary_term' = 'Preference Status');
ALTER TABLE `automotive_ecm`.`customer`.`preference` ALTER COLUMN `preference_status` SET TAGS ('dbx_value_regex' = 'active|inactive|expired|pending');
ALTER TABLE `automotive_ecm`.`customer`.`preference` ALTER COLUMN `preference_value` SET TAGS ('dbx_business_glossary_term' = 'Preference Value');
ALTER TABLE `automotive_ecm`.`customer`.`preference` ALTER COLUMN `source` SET TAGS ('dbx_business_glossary_term' = 'Preference Source');
ALTER TABLE `automotive_ecm`.`customer`.`preference` ALTER COLUMN `source` SET TAGS ('dbx_value_regex' = 'self_declared|inferred|imported');
ALTER TABLE `automotive_ecm`.`customer`.`preference` ALTER COLUMN `value_data_type` SET TAGS ('dbx_business_glossary_term' = 'Preference Value Data Type');
ALTER TABLE `automotive_ecm`.`customer`.`preference` ALTER COLUMN `value_data_type` SET TAGS ('dbx_value_regex' = 'string|boolean|integer|list');
ALTER TABLE `automotive_ecm`.`customer`.`nps_response` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `automotive_ecm`.`customer`.`nps_response` SET TAGS ('dbx_subdomain' = 'service_experience');
ALTER TABLE `automotive_ecm`.`customer`.`nps_response` ALTER COLUMN `nps_response_id` SET TAGS ('dbx_business_glossary_term' = 'Net Promoter Score Response ID');
ALTER TABLE `automotive_ecm`.`customer`.`nps_response` ALTER COLUMN `aftersales_repair_order_id` SET TAGS ('dbx_business_glossary_term' = 'Aftersales Repair Order Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`customer`.`nps_response` ALTER COLUMN `case_id` SET TAGS ('dbx_business_glossary_term' = 'Case ID');
ALTER TABLE `automotive_ecm`.`customer`.`nps_response` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Customer Party ID');
ALTER TABLE `automotive_ecm`.`customer`.`nps_response` ALTER COLUMN `vehicle_ownership_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Ownership Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`customer`.`nps_response` ALTER COLUMN `vehicle_program_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Program Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`customer`.`nps_response` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `automotive_ecm`.`customer`.`nps_response` ALTER COLUMN `dealer_code` SET TAGS ('dbx_business_glossary_term' = 'Dealer Code');
ALTER TABLE `automotive_ecm`.`customer`.`nps_response` ALTER COLUMN `follow_up_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Follow‑Up Required Flag');
ALTER TABLE `automotive_ecm`.`customer`.`nps_response` ALTER COLUMN `follow_up_status` SET TAGS ('dbx_business_glossary_term' = 'Follow‑Up Status');
ALTER TABLE `automotive_ecm`.`customer`.`nps_response` ALTER COLUMN `follow_up_status` SET TAGS ('dbx_value_regex' = 'required|in_progress|completed|none');
ALTER TABLE `automotive_ecm`.`customer`.`nps_response` ALTER COLUMN `nps_response_status` SET TAGS ('dbx_business_glossary_term' = 'Response Lifecycle Status');
ALTER TABLE `automotive_ecm`.`customer`.`nps_response` ALTER COLUMN `nps_response_status` SET TAGS ('dbx_value_regex' = 'pending|completed|escalated|closed');
ALTER TABLE `automotive_ecm`.`customer`.`nps_response` ALTER COLUMN `nps_score` SET TAGS ('dbx_business_glossary_term' = 'Net Promoter Score (NPS) Rating');
ALTER TABLE `automotive_ecm`.`customer`.`nps_response` ALTER COLUMN `promoter_category` SET TAGS ('dbx_business_glossary_term' = 'Promoter Category');
ALTER TABLE `automotive_ecm`.`customer`.`nps_response` ALTER COLUMN `promoter_category` SET TAGS ('dbx_value_regex' = 'promoter|passive|detractor');
ALTER TABLE `automotive_ecm`.`customer`.`nps_response` ALTER COLUMN `response_date` SET TAGS ('dbx_business_glossary_term' = 'Response Date');
ALTER TABLE `automotive_ecm`.`customer`.`nps_response` ALTER COLUMN `salesforce_survey_response_reference` SET TAGS ('dbx_business_glossary_term' = 'Salesforce Survey Response ID');
ALTER TABLE `automotive_ecm`.`customer`.`nps_response` ALTER COLUMN `survey_channel` SET TAGS ('dbx_business_glossary_term' = 'Survey Delivery Channel');
ALTER TABLE `automotive_ecm`.`customer`.`nps_response` ALTER COLUMN `survey_channel` SET TAGS ('dbx_value_regex' = 'email|sms|app|ivr');
ALTER TABLE `automotive_ecm`.`customer`.`nps_response` ALTER COLUMN `survey_date` SET TAGS ('dbx_business_glossary_term' = 'Survey Date');
ALTER TABLE `automotive_ecm`.`customer`.`nps_response` ALTER COLUMN `survey_type` SET TAGS ('dbx_business_glossary_term' = 'Survey Type');
ALTER TABLE `automotive_ecm`.`customer`.`nps_response` ALTER COLUMN `survey_type` SET TAGS ('dbx_value_regex' = 'transactional|relational');
ALTER TABLE `automotive_ecm`.`customer`.`nps_response` ALTER COLUMN `touchpoint` SET TAGS ('dbx_business_glossary_term' = 'Customer Touchpoint');
ALTER TABLE `automotive_ecm`.`customer`.`nps_response` ALTER COLUMN `touchpoint` SET TAGS ('dbx_value_regex' = 'vehicle_purchase|service_visit|delivery|recall|roadside|connected_app');
ALTER TABLE `automotive_ecm`.`customer`.`nps_response` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `automotive_ecm`.`customer`.`nps_response` ALTER COLUMN `verbatim_comment` SET TAGS ('dbx_business_glossary_term' = 'Verbatim Comment');
ALTER TABLE `automotive_ecm`.`customer`.`case` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `automotive_ecm`.`customer`.`case` SET TAGS ('dbx_subdomain' = 'service_experience');
ALTER TABLE `automotive_ecm`.`customer`.`case` ALTER COLUMN `case_id` SET TAGS ('dbx_business_glossary_term' = 'Case ID');
ALTER TABLE `automotive_ecm`.`customer`.`case` ALTER COLUMN `aftersales_repair_order_id` SET TAGS ('dbx_business_glossary_term' = 'Aftersales Repair Order Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`customer`.`case` ALTER COLUMN `aftersales_warranty_claim_id` SET TAGS ('dbx_business_glossary_term' = 'Aftersales Warranty Claim Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`customer`.`case` ALTER COLUMN `ar_invoice_id` SET TAGS ('dbx_business_glossary_term' = 'Ar Invoice Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`customer`.`case` ALTER COLUMN `contact_id` SET TAGS ('dbx_business_glossary_term' = 'Assigned Contact Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`customer`.`case` ALTER COLUMN `dealership_id` SET TAGS ('dbx_business_glossary_term' = 'Dealership Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`customer`.`case` ALTER COLUMN `invoice_id` SET TAGS ('dbx_business_glossary_term' = 'Disputed Invoice Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`customer`.`case` ALTER COLUMN `part_master_id` SET TAGS ('dbx_business_glossary_term' = 'Part Master Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`customer`.`case` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Customer Party ID');
ALTER TABLE `automotive_ecm`.`customer`.`case` ALTER COLUMN `recall_campaign_id` SET TAGS ('dbx_business_glossary_term' = 'Recall Campaign Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`customer`.`case` ALTER COLUMN `vehicle_build_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Build Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`customer`.`case` ALTER COLUMN `vehicle_ownership_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Ownership Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`customer`.`case` ALTER COLUMN `vin_registry_id` SET TAGS ('dbx_business_glossary_term' = 'Vin Registry Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`customer`.`case` ALTER COLUMN `case_category` SET TAGS ('dbx_business_glossary_term' = 'Case Category');
ALTER TABLE `automotive_ecm`.`customer`.`case` ALTER COLUMN `case_description` SET TAGS ('dbx_business_glossary_term' = 'Case Description');
ALTER TABLE `automotive_ecm`.`customer`.`case` ALTER COLUMN `case_number` SET TAGS ('dbx_business_glossary_term' = 'Case Number');
ALTER TABLE `automotive_ecm`.`customer`.`case` ALTER COLUMN `case_status` SET TAGS ('dbx_business_glossary_term' = 'Case Status');
ALTER TABLE `automotive_ecm`.`customer`.`case` ALTER COLUMN `case_status` SET TAGS ('dbx_value_regex' = 'new|in_progress|pending_customer|resolved|closed|escalated');
ALTER TABLE `automotive_ecm`.`customer`.`case` ALTER COLUMN `case_type` SET TAGS ('dbx_business_glossary_term' = 'Case Type');
ALTER TABLE `automotive_ecm`.`customer`.`case` ALTER COLUMN `case_type` SET TAGS ('dbx_value_regex' = 'complaint|inquiry|warranty_claim|recall|roadside|goodwill');
ALTER TABLE `automotive_ecm`.`customer`.`case` ALTER COLUMN `closed_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Case Closed Timestamp');
ALTER TABLE `automotive_ecm`.`customer`.`case` ALTER COLUMN `customer_satisfaction_score` SET TAGS ('dbx_business_glossary_term' = 'Customer Satisfaction Score');
ALTER TABLE `automotive_ecm`.`customer`.`case` ALTER COLUMN `dynamics_case_reference` SET TAGS ('dbx_business_glossary_term' = 'Dynamics 365 Case ID');
ALTER TABLE `automotive_ecm`.`customer`.`case` ALTER COLUMN `escalation_level` SET TAGS ('dbx_business_glossary_term' = 'Escalation Level');
ALTER TABLE `automotive_ecm`.`customer`.`case` ALTER COLUMN `escalation_level` SET TAGS ('dbx_value_regex' = 'level1|level2|level3');
ALTER TABLE `automotive_ecm`.`customer`.`case` ALTER COLUMN `escalation_reason` SET TAGS ('dbx_business_glossary_term' = 'Escalation Reason');
ALTER TABLE `automotive_ecm`.`customer`.`case` ALTER COLUMN `opened_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Case Opened Timestamp');
ALTER TABLE `automotive_ecm`.`customer`.`case` ALTER COLUMN `priority` SET TAGS ('dbx_business_glossary_term' = 'Case Priority');
ALTER TABLE `automotive_ecm`.`customer`.`case` ALTER COLUMN `priority` SET TAGS ('dbx_value_regex' = 'P1|P2|P3|P4');
ALTER TABLE `automotive_ecm`.`customer`.`case` ALTER COLUMN `record_audit_created` SET TAGS ('dbx_business_glossary_term' = 'Record Audit Created');
ALTER TABLE `automotive_ecm`.`customer`.`case` ALTER COLUMN `record_audit_updated` SET TAGS ('dbx_business_glossary_term' = 'Record Audit Updated');
ALTER TABLE `automotive_ecm`.`customer`.`case` ALTER COLUMN `resolution_code` SET TAGS ('dbx_business_glossary_term' = 'Resolution Code');
ALTER TABLE `automotive_ecm`.`customer`.`case` ALTER COLUMN `resolution_description` SET TAGS ('dbx_business_glossary_term' = 'Resolution Description');
ALTER TABLE `automotive_ecm`.`customer`.`case` ALTER COLUMN `resolved_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Case Resolved Timestamp');
ALTER TABLE `automotive_ecm`.`customer`.`case` ALTER COLUMN `salesforce_case_reference` SET TAGS ('dbx_business_glossary_term' = 'Salesforce Case ID');
ALTER TABLE `automotive_ecm`.`customer`.`case` ALTER COLUMN `sla_due_timestamp` SET TAGS ('dbx_business_glossary_term' = 'SLA Due Timestamp');
ALTER TABLE `automotive_ecm`.`customer`.`case` ALTER COLUMN `source_channel` SET TAGS ('dbx_business_glossary_term' = 'Case Source Channel');
ALTER TABLE `automotive_ecm`.`customer`.`case` ALTER COLUMN `source_channel` SET TAGS ('dbx_value_regex' = 'phone|email|web|in_person|mobile_app');
ALTER TABLE `automotive_ecm`.`customer`.`case` ALTER COLUMN `sub_category` SET TAGS ('dbx_business_glossary_term' = 'Case Sub-Category');
ALTER TABLE `automotive_ecm`.`customer`.`case` ALTER COLUMN `subject` SET TAGS ('dbx_business_glossary_term' = 'Case Subject');
ALTER TABLE `automotive_ecm`.`customer`.`case` ALTER COLUMN `total_handle_time_minutes` SET TAGS ('dbx_business_glossary_term' = 'Total Handle Time (Minutes)');
