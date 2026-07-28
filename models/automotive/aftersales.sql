-- Schema for Domain: aftersales | Business: Automotive | Version: v1_mvm
-- Generated on: 2026-05-07 02:20:07

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `automotive_ecm`.`aftersales` COMMENT 'Post-sale customer support including warranty management, service campaigns, recall execution, and parts distribution. Manages service appointments, repair orders, TSB (Technical Service Bulletin) distribution, DTC (Diagnostic Trouble Code) analysis, and labor time standards. Tracks warranty claims, parts consumption, service revenue, and customer retention. Includes field service operations and authorized service center network management. Integrates with CDK Global DMS and OBD (On-Board Diagnostics) systems.';

-- ========= TABLES =========
CREATE OR REPLACE TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` (
    `aftersales_repair_order_id` BIGINT COMMENT 'Unique identifier for the repair_order data product (auto-inserted pre-linking).',
    `aftersales_service_appointment_id` BIGINT COMMENT 'Foreign key linking to aftersales.aftersales_service_appointment. Business justification: A repair order is typically created from a service appointment when the customer arrives. aftersales_repair_order currently stores appointment_scheduled_timestamp, appointment_arrival_timestamp, and a',
    `build_spec_id` BIGINT COMMENT 'Foreign key linking to vehicle.build_spec. Business justification: Service technicians reference build_spec for software_version, ota_updatable_flag, and initial diagnostic trouble codes during repair. Build spec determines repair eligibility and procedure. No existi',
    `change_id` BIGINT COMMENT 'Foreign key linking to engineering.engineering_change. Business justification: Repair orders must reference the engineering change that introduced the fix, enabling field impact tracking and change effectiveness reporting.',
    `cost_center_id` BIGINT COMMENT 'Foreign key linking to finance.cost_center. Business justification: Service revenue posting requires linking each repair order to a cost center for cost allocation in the Service Revenue Report.',
    `gl_account_id` BIGINT COMMENT 'Foreign key linking to finance.gl_account. Business justification: General Ledger posting of repair order revenue requires a GL account reference for the Service Revenue GL Posting process.',
    `inspection_lot_id` BIGINT COMMENT 'Foreign key linking to quality.inspection_lot. Business justification: Repair orders are created when a quality inspection lot fails; linking provides the Inspection‑to‑Repair Traceability Report.',
    `storage_location_id` BIGINT COMMENT 'Foreign key linking to inventory.storage_location. Business justification: Repair orders need to track which service center warehouse location parts are pulled from for accurate job costing, inventory depletion, and parts availability management. Enables service advisors to ',
    `party_id` BIGINT COMMENT 'Identifier of the customer who owns the vehicle.',
    `dealership_id` BIGINT COMMENT 'Identifier of the dealer/service center handling the repair.',
    `production_order_id` BIGINT COMMENT 'Foreign key linking to manufacturing.production_order. Business justification: Traceability report linking each repair order to the original production order enables warranty and recall investigations per VIN.',
    `profit_center_id` BIGINT COMMENT 'Foreign key linking to finance.profit_center. Business justification: Profitability analysis per repair order uses profit center to track service margin in the Service Profitability Dashboard.',
    `service_campaign_id` BIGINT COMMENT 'Identifier of a service campaign (e.g., TSB) associated with this repair.',
    `service_center_id` BIGINT COMMENT 'Identifier of the physical service location.',
    `technician_id` BIGINT COMMENT 'Identifier of the primary technician assigned to perform the work.',
    `vehicle_build_id` BIGINT COMMENT 'Foreign key linking to manufacturing.vehicle_build. Business justification: Repair order diagnosis requires build-time data: quality gate results, rework history, paint/assembly timestamps. Technicians and warranty analysts trace field failures to the exact vehicle_build reco',
    `vehicle_order_id` BIGINT COMMENT 'Foreign key linking to sales.vehicle_order. Business justification: Required for warranty eligibility and service cost attribution; repair orders must reference the original vehicle order to verify coverage and allocate service revenue.',
    `vehicle_ownership_id` BIGINT COMMENT 'Foreign key linking to customer.vehicle_ownership. Business justification: Service order processing uses the ownership record to confirm warranty coverage and apply owner‑specific service rules.',
    `vehicle_program_id` BIGINT COMMENT 'Foreign key linking to engineering.vehicle_program. Business justification: Repair orders must be attributed to vehicle programs for program-level warranty cost reporting, service frequency analysis by program, and engineering quality KPI dashboards. OEM service operations an',
    `vehicle_warranty_id` BIGINT COMMENT 'Foreign key linking to aftersales.vehicle_warranty. Business justification: A repair order covered under warranty should reference the specific VIN-level vehicle_warranty entitlement record. aftersales_repair_order currently stores warranty_flag and warranty_type as denormali',
    `vin_registry_id` BIGINT COMMENT 'Foreign key linking to vehicle.vin_registry. Business justification: Required for warranty verification and recall tracking in the Repair Order processing workflow, linking each order to the vehicles VIN registry record.',
    `actual_completion_time` TIMESTAMP COMMENT 'Actual date and time when the repair was completed.',
    `aftersales_repair_order_status` STRING COMMENT 'Current lifecycle status of the repair order.. Valid values are `open|in_progress|quality_check|closed|invoiced|cancelled`',
    `close_timestamp` TIMESTAMP COMMENT 'Date and time when the repair order was closed.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the repair order record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO currency code for monetary values.. Valid values are `USD|CAD|EUR|GBP|JPY`',
    `customer_feedback_score` STRING COMMENT 'Numeric rating (1-5) provided by the customer after service.',
    `customer_signature_flag` BOOLEAN COMMENT 'Indicates whether the customer signed off on the repair order.',
    `diagnostic_code` STRING COMMENT 'Standard OBD diagnostic code recorded during service.. Valid values are `^[0-9]{4}$`',
    `discount_amount` DECIMAL(18,2) COMMENT 'Total discount applied to the repair order.',
    `is_estimate` BOOLEAN COMMENT 'Indicates whether the record is an estimate prior to work being performed.',
    `labor_rate_per_hour` DECIMAL(18,2) COMMENT 'Standard labor rate applied per hour.',
    `labor_total_cost` DECIMAL(18,2) COMMENT 'Total cost of labor before taxes and discounts.',
    `labor_total_hours` DECIMAL(18,2) COMMENT 'Total labor hours recorded for the repair order.',
    `mileage_at_service` STRING COMMENT 'Vehicle odometer reading at the time of service.',
    `net_amount` DECIMAL(18,2) COMMENT 'Final amount after tax and discount.',
    `open_timestamp` TIMESTAMP COMMENT 'Date and time when the repair order was opened.',
    `parts_total_cost` DECIMAL(18,2) COMMENT 'Total cost of parts consumed before taxes and discounts.',
    `payment_method` STRING COMMENT 'Method used by the customer to settle the repair order.. Valid values are `cash|credit_card|debit_card|bank_transfer|mobile_payment|check`',
    `payment_status` STRING COMMENT 'Current status of the payment for the repair order.. Valid values are `pending|paid|failed|refunded`',
    `promised_completion_time` TIMESTAMP COMMENT 'Scheduled date and time promised to the customer for repair completion.',
    `ro_number` STRING COMMENT 'External repair order number assigned by the service center.',
    `service_center_region` STRING COMMENT 'Geographic region where the service center is located.. Valid values are `North|South|East|West|Central`',
    `service_notes` STRING COMMENT 'Free-text notes entered by service advisor describing work performed.',
    `service_priority` STRING COMMENT 'Priority level assigned to the repair order.. Valid values are `high|medium|low|critical`',
    `service_type` STRING COMMENT 'Category of service performed.. Valid values are `maintenance|repair|recall|campaign|diagnostic`',
    `tax_amount` DECIMAL(18,2) COMMENT 'Total tax applied to the repair order.',
    `technician_notes` STRING COMMENT 'Free-text notes entered by the technician during repair.',
    `total_amount` DECIMAL(18,2) COMMENT 'Gross amount of the repair order before tax and discount.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the repair order record.',
    `warranty_claim_number` STRING COMMENT 'Reference number for the warranty claim associated with this repair.',
    `warranty_flag` BOOLEAN COMMENT 'Indicates whether the repair is covered under warranty.',
    CONSTRAINT pk_aftersales_repair_order PRIMARY KEY(`aftersales_repair_order_id`)
) COMMENT 'Core transactional record capturing a vehicle service or repair event at an authorized service center or dealership. Tracks RO number, vehicle VIN, customer, service advisor, open/close dates, labor operations performed, parts consumed, total labor cost, total parts cost, total RO value, payment method, warranty vs. customer pay vs. internal pay type, DMS source (CDK Global), mileage at write-up, promised completion time, actual completion time, technician assignments, and RO status lifecycle (open, in-progress, quality-check, closed, invoiced).';

CREATE OR REPLACE TABLE `automotive_ecm`.`aftersales`.`repair_order_line` (
    `repair_order_line_id` BIGINT COMMENT 'System-generated unique identifier for the repair order line.',
    `aftersales_repair_order_id` BIGINT COMMENT 'Identifier of the parent repair order header to which this line belongs.',
    `aftersales_service_appointment_id` BIGINT COMMENT 'Identifier of the service appointment linked to this line.',
    `aftersales_warranty_claim_id` BIGINT COMMENT 'Identifier of the warranty claim associated with this line, if applicable.',
    `change_id` BIGINT COMMENT 'Foreign key linking to engineering.engineering_change. Business justification: Specific line items may be affected by an engineering change; linking supports detailed root‑cause analysis and cost allocation.',
    `gl_account_id` BIGINT COMMENT 'Foreign key linking to finance.gl_account. Business justification: Each lines labor/parts expense is posted to a specific GL account for detailed expense reporting.',
    `inbound_part_id` BIGINT COMMENT 'Foreign key linking to supply.inbound_part. Business justification: REQUIRED: Parts Traceability Report for warranty investigations needs to link each repair line to the inbound part record it originated from.',
    `inbound_shipment_id` BIGINT COMMENT 'Foreign key linking to supply.inbound_shipment. Business justification: REQUIRED: Repair Order Shipment Tracking report ties repaired parts to the specific inbound shipment they arrived on for logistics audit.',
    `labor_time_standard_id` BIGINT COMMENT 'Foreign key linking to aftersales.labor_time_standard. Business justification: Repair order line should reference the standard labor time definition for the operation code.',
    `service_center_id` BIGINT COMMENT 'Identifier of the authorized service center where work was performed.',
    `service_part_id` BIGINT COMMENT 'Foreign key linking to aftersales.service_part. Business justification: A repair order line that involves parts consumption should reference the aftersales service_part master record. repair_order_line already has sku_master_id (cross-domain inventory) and inbound_part_id',
    `sku_master_id` BIGINT COMMENT 'Foreign key linking to inventory.sku_master. Business justification: REQUIRED: Parts used in a repair order line must be tracked against the inventory SKU master for cost, stock deduction, and compliance reporting.',
    `storage_location_id` BIGINT COMMENT 'Foreign key linking to inventory.storage_location. Business justification: REQUIRED: Service parts are issued from a specific warehouse bin; linking to storage_location enables inventory location traceability for service.',
    `technician_id` BIGINT COMMENT 'Identifier of the technician who performed the labor.',
    `tsb_id` BIGINT COMMENT 'Foreign key linking to aftersales.tsb. Business justification: A repair order line may be performed following a specific Technical Service Bulletin (TSB). Linking repair_order_line to tsb enables tracking of TSB compliance, labor time adherence, and repair proced',
    `actual_technician_hours` DECIMAL(18,2) COMMENT 'Actual labor hours logged by the technician for this line.',
    `cause_complaint` STRING COMMENT 'Narrative describing the customer complaint or issue that initiated the service.',
    `correction` STRING COMMENT 'Narrative describing the corrective action taken to resolve the complaint.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the repair order line record was created in the system.',
    `currency_code` STRING COMMENT 'Three‑letter ISO 4217 currency code for monetary values on the line.. Valid values are `USD|CAD|EUR|GBP|JPY|CNY`',
    `discount_amount` DECIMAL(18,2) COMMENT 'Monetary discount applied to this line, if any.',
    `labor_category` STRING COMMENT 'Broad classification of the labor type performed.. Valid values are `mechanical|electrical|diagnostic|body|software`',
    `labor_rate` DECIMAL(18,2) COMMENT 'Hourly labor rate applied to the technician for this operation.',
    `labor_skill_level` STRING COMMENT 'Skill level required for the technician to perform the operation.. Valid values are `apprentice|journeyman|master|specialist`',
    `labor_time_standard` DECIMAL(18,2) COMMENT 'Flat‑rate standard labor time in hours for the operation code.',
    `line_sequence` STRING COMMENT 'Sequential number of the line within the repair order for ordering.',
    `line_status` STRING COMMENT 'Current processing status of the repair order line.. Valid values are `open|in_progress|completed|closed|canceled`',
    `line_total` DECIMAL(18,2) COMMENT 'Total monetary amount for the line (labor_rate * actual_technician_hours) before discounts and taxes.',
    `notes` STRING COMMENT 'Additional free‑form notes entered by the technician or service advisor.',
    `operation_code` STRING COMMENT 'Standard code representing the specific labor operation performed (e.g., oil change, brake inspection).',
    `overtime_flag` BOOLEAN COMMENT 'True if overtime rates were applied to this labor line.',
    `overtime_multiplier` DECIMAL(18,2) COMMENT 'Multiplier applied to the labor_rate when overtime_flag is true (e.g., 1.5).',
    `part_price` DECIMAL(18,2) COMMENT 'Standard price per unit of the part at the time of service.',
    `part_quantity` DECIMAL(18,2) COMMENT 'Quantity of the part used for this line.',
    `parts_used_flag` BOOLEAN COMMENT 'Indicates whether any parts were consumed on this line.',
    `service_date` DATE COMMENT 'Date on which the service work was performed.',
    `sublet_cost` DECIMAL(18,2) COMMENT 'Total cost charged by the sublet vendor for this line.',
    `sublet_flag` BOOLEAN COMMENT 'True if the work was performed by an external subcontractor.',
    `tax_amount` DECIMAL(18,2) COMMENT 'Tax applied to the line total.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the repair order line record.',
    `vehicle_vin` STRING COMMENT 'Unique 17‑character identifier of the vehicle serviced.. Valid values are `^[A-HJ-NPR-Z0-9]{17}$`',
    `warranty_flag` BOOLEAN COMMENT 'Indicates whether the labor line is covered under warranty (true) or not (false).',
    CONSTRAINT pk_repair_order_line PRIMARY KEY(`repair_order_line_id`)
) COMMENT 'Individual labor operation or job line within a repair order. Captures operation code, labor time standard (flat-rate hours), actual technician hours, labor rate, line total, technician ID, cause/complaint/correction (3C) narrative, warranty flag, sublet flag, and line status. Supports granular cost analysis and technician productivity tracking per CDK Global DMS job line structure.';

CREATE OR REPLACE TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` (
    `aftersales_warranty_claim_id` BIGINT COMMENT 'Unique identifier for the warranty_claim data product (auto-inserted pre-linking).',
    `aftersales_repair_order_id` BIGINT COMMENT 'Foreign key linking to aftersales.aftersales_repair_order. Business justification: A warranty claim is submitted based on work performed in a repair order. aftersales_warranty_claim currently stores repair_order_number as a denormalized STRING — this should be a proper FK to aftersa',
    `defect_record_id` BIGINT COMMENT 'Foreign key linking to quality.defect_record. Business justification: Warranty claim investigation requires linking each claim to the originating quality defect record (Warranty Claim Investigation Report).',
    `part_master_id` BIGINT COMMENT 'Foreign key linking to engineering.part_master. Business justification: Warranty claims must reference the specific failed engineering part for warranty cost allocation by part number, supplier chargeback recovery, and FMEA field-failure feedback loops. OEM warranty syste',
    `party_id` BIGINT COMMENT 'Identifier of the vehicle owner who is the warranty claimant.',
    `dealership_id` BIGINT COMMENT 'Identifier of the dealer or service center submitting the claim.',
    `production_variant_id` BIGINT COMMENT 'Foreign key linking to manufacturing.production_variant. Business justification: OEM warranty analytics teams run variant-level warranty cost and failure-rate reports to identify systemic production variant defects. Linking claims directly to production_variant enables warranty-to',
    `recall_campaign_id` BIGINT COMMENT 'Foreign key linking to compliance.compliance_recall_campaign. Business justification: Regulatory warranty claim reporting mandates associating claims arising from a recall campaign with that campaign for audit and reimbursement.',
    `service_campaign_id` BIGINT COMMENT 'Identifier of the recall or service campaign linked to the claim.',
    `service_center_id` BIGINT COMMENT 'Identifier of the authorized service center performing the repair.',
    `supplier_id` BIGINT COMMENT 'Foreign key linking to supply.supply_supplier. Business justification: Warranty claims track supplier of defective parts for root cause analysis, supplier recovery/chargeback, and quality cost allocation. OEMs routinely charge back warranty costs to suppliers when parts ',
    `vehicle_build_id` BIGINT COMMENT 'Foreign key linking to manufacturing.vehicle_build. Business justification: Warranty adjudication requires build-time evidence: build stage, quality gate status, rework count, and build timestamps to determine manufacturing-origin liability. OEM warranty teams routinely pull ',
    `vehicle_ownership_id` BIGINT COMMENT 'Foreign key linking to customer.vehicle_ownership. Business justification: Claims processing must reference the specific ownership period to determine coverage limits and calculate accurate claim payouts.',
    `vehicle_program_id` BIGINT COMMENT 'Foreign key linking to engineering.vehicle_program. Business justification: Aggregating warranty claims by vehicle program is required for reliability analysis and program improvement decisions.',
    `vehicle_warranty_id` BIGINT COMMENT 'Foreign key linking to aftersales.vehicle_warranty. Business justification: A warranty claim is made against a specific VIN-level vehicle warranty entitlement (vehicle_warranty). While aftersales_warranty_claim already has warranty_policy_id (the policy definition), it lacks ',
    `vin_registry_id` BIGINT COMMENT 'Foreign key linking to vehicle.vin_registry. Business justification: Needed for claim eligibility validation against the vehicles VIN registry during Warranty Claim adjudication.',
    `warranty_policy_id` BIGINT COMMENT 'Foreign key linking to aftersales.warranty_policy. Business justification: A warranty claim is filed under a specific warranty policy; linking directly to warranty_policy provides direct access to policy terms without needing to traverse vehicle_warranty.',
    `adjudication_outcome` STRING COMMENT 'Result of the OEMs review of the claim.. Valid values are `approved|rejected|partial|pending`',
    `adjusted_amount` DECIMAL(18,2) COMMENT 'Monetary amount of the adjustment applied to the claim.',
    `approved_labor_cost` DECIMAL(18,2) COMMENT 'Monetary amount approved for labor services.',
    `approved_labor_hours` DECIMAL(18,2) COMMENT 'Number of labor hours approved for reimbursement.',
    `approved_parts_cost` DECIMAL(18,2) COMMENT 'Monetary amount approved for parts used in the repair.',
    `claim_adjusted_flag` BOOLEAN COMMENT 'Indicates whether the claim amount was later adjusted.',
    `claim_category` STRING COMMENT 'High‑level classification of the claim type.. Valid values are `repair|recall|service_campaign|maintenance`',
    `claim_created_by` STRING COMMENT 'User identifier of the employee who entered the claim.',
    `claim_number` STRING COMMENT 'External claim identifier assigned by the OEM or dealer for tracking.',
    `claim_status` STRING COMMENT 'Current lifecycle status of the warranty claim.. Valid values are `submitted|approved|rejected|adjusted|paid`',
    `claim_submission_timestamp` TIMESTAMP COMMENT 'Exact timestamp when the warranty claim was submitted to the OEM.',
    `currency_code` STRING COMMENT 'Three‑letter ISO currency code for the claim amounts.. Valid values are `USD|EUR|JPY|CAD|GBP|CNY`',
    `failure_date` DATE COMMENT 'Date the vehicle failure that triggered the warranty claim occurred.',
    `goodwill_flag` BOOLEAN COMMENT 'Indicates whether the claim is processed as goodwill (no reimbursement).',
    `labor_rate_per_hour` DECIMAL(18,2) COMMENT 'Standard labor rate used for calculating labor cost.',
    `notes` STRING COMMENT 'Free‑form text notes entered by the service advisor or adjudicator.',
    `parts_tax_amount` DECIMAL(18,2) COMMENT 'Tax amount applied to the approved parts cost.',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when the claim record was first created in the system.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the claim record.',
    `rejection_reason_code` STRING COMMENT 'Code indicating why a claim was rejected, if applicable.',
    `repair_date` DATE COMMENT 'Date the repair work was performed on the vehicle.',
    `total_claim_amount` DECIMAL(18,2) COMMENT 'Total monetary value of the claim (labor + parts).',
    `warranty_end_date` DATE COMMENT 'Date when the vehicles warranty coverage expires.',
    `warranty_start_date` DATE COMMENT 'Date when the vehicles warranty coverage began.',
    `warranty_type` STRING COMMENT 'Category of warranty coverage applicable to the claim.. Valid values are `bumper_to_bumper|powertrain|corrosion|roadside_assistance`',
    CONSTRAINT pk_aftersales_warranty_claim PRIMARY KEY(`aftersales_warranty_claim_id`)
) COMMENT 'Warranty claim submitted by a dealer or authorized service center to the OEM for reimbursement of warranty-covered repairs. Tracks claim number, VIN, repair order reference, failure date, repair date, claim submission date, claim status (submitted, approved, rejected, adjusted, paid), approved labor hours, approved parts cost, total claim amount, rejection reason code, goodwill flag, campaign/recall linkage, and OEM adjudication outcome. Integrates with SAP SD warranty module and CDK Global DMS.';

CREATE OR REPLACE TABLE `automotive_ecm`.`aftersales`.`warranty_policy` (
    `warranty_policy_id` BIGINT COMMENT 'System-generated unique identifier for the warranty policy record.',
    `company_code_id` BIGINT COMMENT 'Foreign key linking to finance.company_code. Business justification: Warranty policies are legal contracts issued by specific legal entities (company codes). Required for warranty reserve accounting by legal entity, intercompany warranty claim settlement, regulatory co',
    `model_id` BIGINT COMMENT 'Foreign key linking to vehicle.model. Business justification: Warranty policies are scoped to specific vehicle models (e.g., 2024 F-150 base warranty). Warranty administrators and customer-facing warranty lookup tools require model-level policy resolution. No ex',
    `powertrain_spec_id` BIGINT COMMENT 'Foreign key linking to engineering.powertrain_spec. Business justification: Powertrain-specific warranty policies (EV battery, hybrid, ICE) are tied to specific powertrain specifications for coverage term determination and regulatory compliance (e.g., CARB EV battery warranty',
    `powertrain_variant_id` BIGINT COMMENT 'Foreign key linking to vehicle.powertrain_variant. Business justification: Warranty policies are powertrain-specific (EV battery warranties are regulated separately from ICE under federal law). The plain text powertrain_type column on warranty_policy is a denormalization of ',
    `production_variant_id` BIGINT COMMENT 'Foreign key linking to manufacturing.production_variant. Business justification: Warranty policies differ by production variant — EV powertrain variants carry different coverage terms than ICE variants; ADAS-equipped variants may have distinct component warranties. OEM warranty po',
    `regulatory_requirement_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_requirement. Business justification: Warranty policies must comply with consumer protection regulations (Magnuson-Moss Warranty Act in US, EU Consumer Rights Directive, regional warranty disclosure laws). Tracking the regulatory basis en',
    `standard_id` BIGINT COMMENT 'Foreign key linking to quality.standard. Business justification: Warranty policies must comply with regulatory quality standards (Magnuson-Moss, EU directives, regional consumer protection laws). Links warranty terms to governing quality/regulatory standards - requ',
    `vehicle_program_id` BIGINT COMMENT 'Foreign key linking to engineering.vehicle_program. Business justification: Warranty policies are defined per vehicle program; the link supports cost forecasting and compliance tracking per program.',
    `authorized_dealer_required_flag` BOOLEAN COMMENT 'Indicates whether warranty service must be performed at an authorized dealer (true) or can be performed at any qualified service center (false).',
    `claim_limit_per_year` STRING COMMENT 'Maximum number of warranty claims allowed per vehicle per calendar year.',
    `claim_limit_total` STRING COMMENT 'Overall maximum number of warranty claims permitted during the policy term.',
    `country_code` STRING COMMENT 'ISO 3166‑1 alpha‑3 country code indicating the primary country of warranty applicability.',
    `coverage_description` STRING COMMENT 'Free‑text description of what components or systems are covered under the policy.',
    `coverage_type` STRING COMMENT 'Category of coverage provided by the warranty (e.g., basic, powertrain, corrosion, emissions, EV battery, ADAS).. Valid values are `basic|powertrain|corrosion|emissions|ev_battery|adas`',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when the warranty policy record was first created in the system.',
    `deductible_amount` DECIMAL(18,2) COMMENT 'Fixed monetary amount the customer must pay for each covered repair under the warranty.',
    `duration_months` STRING COMMENT 'Length of the warranty coverage expressed in calendar months.',
    `effective_end_date` TIMESTAMP COMMENT 'Date and time when the warranty coverage expires (typically EOP or calculated from duration).',
    `effective_start_date` TIMESTAMP COMMENT 'Date and time when the warranty coverage becomes effective (typically SOP).',
    `eop_date` DATE COMMENT 'The production end date of the vehicle model to which the warranty applies.',
    `exclusions` STRING COMMENT 'List of components, conditions, or events excluded from coverage.',
    `extension_allowed_flag` BOOLEAN COMMENT 'True if the warranty may be extended beyond the original term under defined conditions.',
    `extension_terms` STRING COMMENT 'Free‑text description of the conditions, cost, and duration for extending the warranty.',
    `inclusions` STRING COMMENT 'List of components, systems, or services explicitly covered.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Date and time of the most recent modification to the warranty policy record.',
    `market_region` STRING COMMENT 'Geographic market or region where the warranty is offered (e.g., North America, EU).',
    `mileage_limit` STRING COMMENT 'Maximum distance the vehicle may travel while the warranty remains valid, expressed in miles.',
    `model_year` STRING COMMENT 'Model year of the vehicle for which the warranty is defined.',
    `notes` STRING COMMENT 'Additional free‑form notes or remarks about the warranty policy.',
    `policy_number` STRING COMMENT 'External business identifier assigned to the warranty policy, used in contracts and customer communications.',
    `policy_status` STRING COMMENT 'Current lifecycle status of the warranty policy.. Valid values are `active|expired|suspended|terminated`',
    `regulatory_body` STRING COMMENT 'Governing authority that mandates or oversees the warranty (e.g., NHTSA, EPA).',
    `regulatory_reference_number` STRING COMMENT 'Identifier of the regulatory filing or certification linked to the warranty.',
    `renewal_allowed_flag` BOOLEAN COMMENT 'Indicates whether the warranty can be renewed after expiration.',
    `renewal_terms` STRING COMMENT 'Details of renewal options, pricing, and eligibility.',
    `service_center_network` STRING COMMENT 'Identifier of the service‑center network eligible for warranty work (e.g., OEM network, third‑party network).',
    `sop_date` DATE COMMENT 'The production start date of the vehicle model to which the warranty applies.',
    `transferable_flag` BOOLEAN COMMENT 'Indicates whether the warranty can be transferred to a subsequent owner (true) or is non‑transferable (false).',
    CONSTRAINT pk_warranty_policy PRIMARY KEY(`warranty_policy_id`)
) COMMENT 'Master definition of warranty coverage terms applicable to a vehicle nameplate, model year, powertrain type, or market. Captures warranty type (basic/bumper-to-bumper, powertrain, corrosion, emissions, EV battery, ADAS), coverage duration in months, coverage distance in miles/km, deductible amount, transferability flag, market/region applicability, SOP and EOP dates, and governing regulatory body (NHTSA, EPA). Serves as the authoritative reference for warranty eligibility determination.';

CREATE OR REPLACE TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` (
    `vehicle_warranty_id` BIGINT COMMENT 'Unique surrogate key for the vehicle warranty record.',
    `warranty_policy_id` BIGINT COMMENT 'Foreign key linking to aftersales.warranty_policy. Business justification: Vehicle warranty must reference the applicable warranty policy; adds inbound to warranty_policy and outbound from vehicle_warranty.',
    `party_id` BIGINT COMMENT 'Foreign key linking to customer.party. Business justification: Warranty administration requires linking each warranty to the owning party for eligibility verification and regulatory compliance reporting.',
    `dealership_id` BIGINT COMMENT 'Identifier of the dealer that sold the vehicle or issued the warranty.',
    `recall_campaign_id` BIGINT COMMENT 'Reference to a recall record that may affect the warranty.',
    `service_center_id` BIGINT COMMENT 'Identifier of the authorized service center handling warranty work.',
    `service_contract_id` BIGINT COMMENT 'Identifier of the service contract linked to the warranty.',
    `vehicle_program_id` BIGINT COMMENT 'Foreign key linking to engineering.vehicle_program. Business justification: Vehicle warranties must be directly associated with the vehicle program for program-level warranty cost tracking, reserve accrual reporting, and engineering quality dashboards. The indirect path via w',
    `vin_registry_id` BIGINT COMMENT 'Foreign key linking to vehicle.vin_registry. Business justification: Connects warranty contracts to the VIN registry to validate coverage periods and claim eligibility.',
    `claims_last_amount` DECIMAL(18,2) COMMENT 'Monetary amount of the most recent warranty claim.',
    `claims_last_date` DATE COMMENT 'Date of the most recent warranty claim.',
    `coverage_area` STRING COMMENT 'Geographic scope of the warranty coverage.. Valid values are `domestic|international`',
    `coverage_description` STRING COMMENT 'Free‑text description of what components and services are covered.',
    `coverage_end_mileage` STRING COMMENT 'Maximum mileage at which warranty coverage ends.',
    `coverage_start_mileage` STRING COMMENT 'Mileage reading at which warranty coverage begins.',
    `cpo_warranty_flag` BOOLEAN COMMENT 'True if the warranty applies to a Certified Pre‑Owned vehicle.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the warranty record was first created in the system.',
    `duration_months` STRING COMMENT 'Total length of the warranty in months.',
    `eligible_for_recall` BOOLEAN COMMENT 'Indicates whether the vehicle is eligible for a safety recall under this warranty.',
    `end_date` DATE COMMENT 'Date the warranty coverage ends.',
    `exclusions` STRING COMMENT 'Text describing items or conditions excluded from coverage.',
    `extended_warranty_flag` BOOLEAN COMMENT 'Indicates whether the warranty has been extended beyond the original terms.',
    `last_transfer_date` DATE COMMENT 'Date of the most recent warranty transfer.',
    `mileage_limit` STRING COMMENT 'Maximum mileage allowed under the warranty.',
    `original_purchase_date` DATE COMMENT 'Date the vehicle was originally purchased by the first owner.',
    `policy_code` STRING COMMENT 'Internal code representing the warranty policy.',
    `program_category` STRING COMMENT 'Broad category of the warranty program.. Valid values are `new_vehicle|used_vehicle|cpo|extended`',
    `program_name` STRING COMMENT 'Name of the warranty program (e.g., New Vehicle, CPO, Extended).',
    `remaining_mileage` STRING COMMENT 'Mileage remaining before the warranty limit is reached.',
    `remaining_months` STRING COMMENT 'Number of months remaining before warranty expiration.',
    `renewal_date` DATE COMMENT 'Date on which the warranty was renewed or is scheduled to renew.',
    `renewal_flag` BOOLEAN COMMENT 'Indicates whether the warranty is eligible for renewal.',
    `service_plan` STRING COMMENT 'Name of the service plan associated with the warranty.',
    `start_date` DATE COMMENT 'Date the warranty coverage became effective (in‑service date).',
    `status_reason` STRING COMMENT 'Reason why the warranty is in its current status.. Valid values are `normal|customer_cancel|manufacturer_recall|non_payment`',
    `transfer_allowed` BOOLEAN COMMENT 'True if the warranty may be transferred to a subsequent owner.',
    `transfer_count` STRING COMMENT 'Number of times the warranty has been transferred to a new owner.',
    `transfer_fee` DECIMAL(18,2) COMMENT 'Fee charged for transferring the warranty to a new owner.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the warranty record.',
    `vehicle_warranty_status` STRING COMMENT 'Current lifecycle status of the warranty.. Valid values are `active|expired|voided|suspended|transferred`',
    `warranty_claims_amount` DECIMAL(18,2) COMMENT 'Cumulative monetary value of all warranty claims.',
    `warranty_claims_count` STRING COMMENT 'Total number of warranty claims filed to date.',
    `warranty_document_url` STRING COMMENT 'Link to the electronic copy of the warranty contract.',
    `warranty_number` STRING COMMENT 'External warranty contract number assigned by the manufacturer or dealer.',
    `warranty_terms_version` STRING COMMENT 'Version identifier of the warranty terms document.',
    `warranty_type` STRING COMMENT 'Category of coverage provided by the warranty.. Valid values are `bumper_to_bumper|powertrain|corrosion|roadside_assistance|extended`',
    CONSTRAINT pk_vehicle_warranty PRIMARY KEY(`vehicle_warranty_id`)
) COMMENT 'VIN-level warranty entitlement record linking a specific vehicle to its applicable warranty policies. Tracks warranty start date (in-service date), expiration date, remaining months, remaining mileage, warranty status (active, expired, voided), extended warranty flag, CPO (Certified Pre-Owned) warranty flag, and any warranty transfer history. This is the SSOT for whether a specific vehicle is under warranty at any point in time.';

CREATE OR REPLACE TABLE `automotive_ecm`.`aftersales`.`service_campaign` (
    `service_campaign_id` BIGINT COMMENT 'Unique surrogate key for the service campaign record.',
    `change_id` BIGINT COMMENT 'Foreign key linking to engineering.change. Business justification: Service campaigns are initiated when an engineering change order identifies a field-safety or quality issue requiring customer notification. The ECO-to-campaign traceability is required for regulatory',
    `fmea_record_id` BIGINT COMMENT 'Foreign key linking to engineering.fmea_record. Business justification: Safety recalls and service campaigns must be traceable to the FMEA failure mode that identified or predicted the defect. NHTSA/UNECE regulatory submissions require documented root cause; linking servi',
    `model_id` BIGINT COMMENT 'Foreign key linking to vehicle.model. Business justification: NHTSA and UNECE regulatory reporting requires campaign-to-model traceability (e.g., how many campaigns affect Model X). The existing vehicle_program FK is program-level; model-level campaign scoping i',
    `plant_id` BIGINT COMMENT 'Foreign key linking to manufacturing.plant. Business justification: Service campaigns triggered by plant-specific manufacturing defects must reference the originating plant for regulatory reporting (NHTSA/UNECE) and corrective action tracking. OEM recall teams scope a',
    `part_master_id` BIGINT COMMENT 'Foreign key linking to engineering.part_master. Business justification: Service campaigns (recalls and non-safety campaigns) are triggered by specific part failures. Linking to the primary engineering part enables supplier recovery chargebacks, FMEA corrective action trac',
    `production_line_id` BIGINT COMMENT 'Foreign key linking to manufacturing.production_line. Business justification: When a production line process defect causes a field issue, the service campaign is scoped to vehicles produced on that specific line. Manufacturing quality and aftersales teams use this link to drive',
    `production_variant_id` BIGINT COMMENT 'Foreign key linking to manufacturing.production_variant. Business justification: Service campaigns and recalls target specific production variants. Campaign managers must identify the affected VIN population by production variant to scope notifications, parts provisioning, and rem',
    `regulatory_requirement_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_requirement. Business justification: Service campaigns often implement regulatory compliance fixes (emissions software updates, safety modifications per EPA/CARB/UNECE requirements). Tracking the regulatory basis is essential for audit t',
    `vehicle_program_id` BIGINT COMMENT 'Foreign key linking to engineering.vehicle_program. Business justification: Service campaigns are planned per vehicle program; linking enables program‑level impact analysis and regulatory reporting.',
    `affected_model_year_end` STRING COMMENT 'Last model year in the range of vehicles covered.',
    `affected_model_year_start` STRING COMMENT 'First model year in the range of vehicles covered.',
    `affected_vin_population` BIGINT COMMENT 'Estimated count of VINs that fall within the campaign scope.',
    `campaign_cost_estimate` DECIMAL(18,2) COMMENT 'Projected total cost to execute the campaign (currency assumed USD).',
    `campaign_notes` STRING COMMENT 'Free‑form notes or comments from campaign managers.',
    `campaign_priority` STRING COMMENT 'Priority level for resource allocation and scheduling.. Valid values are `high|medium|low`',
    `campaign_region` STRING COMMENT 'Primary geographic region(s) affected; uses ISO‑3 country codes.. Valid values are `USA|CAN|MEX|EU|JP|KR`',
    `campaign_status` STRING COMMENT 'Current lifecycle status of the campaign.. Valid values are `open|closed|suspended|completed|cancelled`',
    `campaign_type` STRING COMMENT 'Classification of the campaign: safety recall, emissions recall, customer satisfaction program, or technical service bulletin action.. Valid values are `safety_recall|emissions_recall|customer_satisfaction|technical_service_bulletin`',
    `compliance_status` STRING COMMENT 'Overall compliance status of the campaign with applicable regulations.. Valid values are `compliant|non_compliant|pending`',
    `customer_satisfaction_flag` BOOLEAN COMMENT 'True if the campaign is a voluntary customer‑satisfaction program.',
    `effective_end_date` DATE COMMENT 'Date when the campaign is closed or no longer applicable (nullable).',
    `effective_start_date` DATE COMMENT 'Date when the campaign becomes effective for affected vehicles.',
    `emissions_recall_flag` BOOLEAN COMMENT 'True if the campaign addresses emissions compliance.',
    `estimated_repair_time_minutes` STRING COMMENT 'Average time, in minutes, required to complete the repair per vehicle.',
    `nhtsa_compliance_flag` BOOLEAN COMMENT 'Indicates whether the campaign meets NHTSA requirements.',
    `parts_cost_estimate` DECIMAL(18,2) COMMENT 'Estimated cost of parts required for the campaign.',
    `parts_required` STRING COMMENT 'Comma‑separated list of part numbers needed to perform the remedy.',
    `record_audit_created` TIMESTAMP COMMENT 'Timestamp when the campaign record was first created in the data lake.',
    `record_audit_updated` TIMESTAMP COMMENT 'Timestamp of the most recent update to the campaign record.',
    `regulatory_reporting_date` DATE COMMENT 'Date on which the campaign was reported to the regulator.',
    `regulatory_reporting_status` STRING COMMENT 'Current status of the campaigns regulatory filing with NHTSA/UNECE.. Valid values are `pending|submitted|approved|rejected`',
    `remedy_description` STRING COMMENT 'Detailed description of the repair or corrective action required.',
    `safety_recall_flag` BOOLEAN COMMENT 'True if the campaign is a safety‑related recall.',
    `technical_service_bulletin_flag` BOOLEAN COMMENT 'True if the campaign originates from a TSB.',
    `unece_compliance_flag` BOOLEAN COMMENT 'Indicates whether the campaign meets UNECE regulations.',
    `warranty_impact_flag` BOOLEAN COMMENT 'Indicates whether the campaign affects warranty coverage.',
    CONSTRAINT pk_service_campaign PRIMARY KEY(`service_campaign_id`)
) COMMENT 'Master record for a service campaign (recall or non-safety field action) issued by the OEM. Captures NHTSA recall number, campaign code, campaign type (safety recall, emissions recall, customer satisfaction program, technical service bulletin action), affected nameplate/model year range, affected VIN population count, remedy description, estimated repair time, parts required, campaign open date, campaign close date, regulatory reporting status, and NHTSA/UNECE compliance flags. Integrates with NHTSA recall database and SAP QM.';

CREATE OR REPLACE TABLE `automotive_ecm`.`aftersales`.`campaign_vin` (
    `campaign_vin_id` BIGINT COMMENT 'Surrogate primary key for the campaign VIN association record.',
    `aftersales_repair_order_id` BIGINT COMMENT 'Foreign key linking to aftersales.aftersales_repair_order. Business justification: A campaign VIN record tracks the completion of a recall/campaign remedy via a repair order. campaign_vin currently stores service_order_number as a denormalized STRING — this should be a proper FK to ',
    `aftersales_service_appointment_id` BIGINT COMMENT 'Foreign key linking to aftersales.aftersales_service_appointment. Business justification: A campaign VIN record tracks the scheduled service appointment for the recall/campaign remedy. campaign_vin has scheduled_service_date (DATE) as a denormalized value — the authoritative appointment re',
    `service_campaign_id` BIGINT COMMENT 'Foreign key linking to aftersales.service_campaign. Business justification: Campaign VIN records need to be linked to the parent service campaign for proper campaign tracking.',
    `vin_registry_id` BIGINT COMMENT 'Foreign key linking to vehicle.vin_registry. Business justification: Associates vehicles with recall or service campaigns, enabling campaign effectiveness reporting and regulatory compliance.',
    `compliance_deadline` DATE COMMENT 'Regulatory compliance deadline for completing the remedy.',
    `compliance_status` STRING COMMENT 'Regulatory compliance status for the vehicle.. Valid values are `compliant|non_compliant|exempt`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the campaign VIN record was created.',
    `dealer_code` STRING COMMENT 'Identifier of the dealer where remedy was performed.',
    `is_critical` BOOLEAN COMMENT 'Flag indicating if the campaign is classified as critical safety.',
    `labor_rate_usd_per_hour` DECIMAL(18,2) COMMENT 'Labor rate applied for the remedy in USD per hour.',
    `labor_time_hours` DECIMAL(18,2) COMMENT 'Labor time recorded for the remedy in hours.',
    `last_service_date` DATE COMMENT 'Date of the most recent service performed on the vehicle.',
    `notes` STRING COMMENT 'Free‑text notes entered by the service technician.',
    `notification_date` DATE COMMENT 'Date when the vehicle was notified about the campaign.',
    `notification_status` STRING COMMENT 'Current notification status of the vehicle for the campaign.. Valid values are `not_notified|notified|scheduled|completed|parts_on_order|owner_refused`',
    `odometer_reading_km` STRING COMMENT 'Vehicle odometer reading at time of remedy in kilometers.',
    `owner_response` STRING COMMENT 'Owners response to the campaign notification.. Valid values are `accepted|refused|pending`',
    `parts_consumed` STRING COMMENT 'Comma‑separated list of part numbers consumed for the remedy.',
    `recall_number` STRING COMMENT 'Official recall number assigned by regulatory authority.',
    `recall_type` STRING COMMENT 'Category of the recall or campaign.. Valid values are `safety|emissions|performance|software`',
    `remedy_completion_date` DATE COMMENT 'Date when the remedy was completed.',
    `remedy_status` STRING COMMENT 'Current status of the remedy execution.. Valid values are `pending|in_progress|completed|cancelled`',
    `service_center_location` STRING COMMENT 'Location identifier of the service center where remedy was performed.',
    `total_labor_cost_usd` DECIMAL(18,2) COMMENT 'Total labor cost for the remedy in USD.',
    `total_parts_cost_usd` DECIMAL(18,2) COMMENT 'Total cost of parts consumed for the remedy in USD.',
    `total_remedy_cost_usd` DECIMAL(18,2) COMMENT 'Aggregate cost (parts + labor) for the remedy in USD.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the record.',
    `warranty_covered` BOOLEAN COMMENT 'Indicates if the remedy is covered under warranty.',
    CONSTRAINT pk_campaign_vin PRIMARY KEY(`campaign_vin_id`)
) COMMENT 'Association record linking a specific VIN to an open service campaign or recall. Tracks VIN, campaign code, notification status (not notified, notified, scheduled, completed, parts-on-order, owner-refused), remedy completion date, dealer code where remedy was performed, parts consumed for remedy, and compliance deadline. Enables OEM and NHTSA to track recall completion rates at the individual vehicle level.';

CREATE OR REPLACE TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` (
    `aftersales_service_appointment_id` BIGINT COMMENT 'Unique identifier for the service_appointment data product (auto-inserted pre-linking).',
    `cost_center_id` BIGINT COMMENT 'Foreign key linking to finance.cost_center. Business justification: Service appointment labor and parts costs are allocated to a cost center for service cost analysis.',
    `party_id` BIGINT COMMENT 'Identifier of the vehicle owner or service requester.',
    `dealership_id` BIGINT COMMENT 'Identifier of the dealership or authorized service center hosting the appointment.',
    `service_campaign_id` BIGINT COMMENT 'Foreign key linking to aftersales.service_campaign. Business justification: Service appointments may be scheduled specifically for a recall or service campaign remedy. aftersales_service_appointment has recall_flag (BOOLEAN) indicating campaign-related appointments, but no FK',
    `service_center_id` BIGINT COMMENT 'Foreign key linking to aftersales.service_center. Business justification: A service appointment is always conducted at a specific service center. This FK normalizes the relationship between appointments and the authorized service center network. No reverse FK exists from se',
    `technician_id` BIGINT COMMENT 'Foreign key linking to aftersales.technician. Business justification: Service appointments are pre-assigned to a specific technician at booking time. This FK links the appointment to the assigned technician. Nullable — technician assignment may occur after booking. No r',
    `vehicle_ownership_id` BIGINT COMMENT 'Foreign key linking to customer.vehicle_ownership. Business justification: Appointment scheduling needs the ownership record to apply loyalty benefits and verify owner eligibility for scheduled services.',
    `vin_registry_id` BIGINT COMMENT 'Foreign key linking to vehicle.vin_registry. Business justification: Ensures service appointment scheduling aligns with the correct vehicle record for service history and recall compliance.',
    `actual_end_timestamp` TIMESTAMP COMMENT 'Timestamp when the service work was completed.',
    `actual_start_timestamp` TIMESTAMP COMMENT 'Timestamp when the vehicle actually entered service.',
    `aftersales_service_appointment_status` STRING COMMENT 'Current lifecycle status of the appointment.. Valid values are `scheduled|confirmed|completed|cancelled|no_show`',
    `appointment_number` STRING COMMENT 'Business identifier assigned to the service appointment, used in dealer and customer communications.',
    `appointment_source` STRING COMMENT 'Origin channel through which the appointment was booked.. Valid values are `online|phone|dms|mobile_app`',
    `bay_number` STRING COMMENT 'Identifier of the service bay where the vehicle will be serviced.',
    `check_in_timestamp` TIMESTAMP COMMENT 'Timestamp when the customer checked in at the service center.',
    `confirmation_status` STRING COMMENT 'Current confirmation state of the appointment.. Valid values are `pending|confirmed|declined`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the appointment record was first created in the system.',
    `currency_code` STRING COMMENT 'Three‑letter ISO currency code for monetary values.. Valid values are `^[A-Z]{3}$`',
    `customer_feedback_score` STRING COMMENT 'Numeric rating (0‑10) provided by the customer after service.',
    `estimated_duration_minutes` STRING COMMENT 'Planned length of the service appointment in minutes.',
    `estimated_gross_amount` DECIMAL(18,2) COMMENT 'Projected total charge before taxes and discounts.',
    `estimated_net_amount` DECIMAL(18,2) COMMENT 'Projected total charge after taxes and discounts.',
    `estimated_tax_amount` DECIMAL(18,2) COMMENT 'Projected tax component of the service charge.',
    `invoice_number` STRING COMMENT 'Identifier of the invoice generated for the service appointment.',
    `is_first_time_customer` BOOLEAN COMMENT 'True if this is the customers first service appointment with the dealer.',
    `is_repeat_service` BOOLEAN COMMENT 'True if the vehicle has previously received the same service type.',
    `labor_time_actual_minutes` STRING COMMENT 'Actual labor minutes recorded for the service.',
    `no_show_flag` BOOLEAN COMMENT 'Indicates whether the customer failed to appear for the scheduled appointment.',
    `parts_actual_amount` DECIMAL(18,2) COMMENT 'Total cost of parts actually used during service.',
    `recall_flag` BOOLEAN COMMENT 'True if the appointment is part of a manufacturer recall campaign.',
    `required_parts_flag` BOOLEAN COMMENT 'Indicates whether specific parts must be ordered before the appointment.',
    `scheduled_timestamp` TIMESTAMP COMMENT 'Planned date and time when the service is to start.',
    `service_category` STRING COMMENT 'Higher‑level grouping of the service (e.g., oil change, brake service, battery replacement).',
    `service_notes` STRING COMMENT 'Free‑form notes entered by the service advisor or technician.',
    `service_priority` STRING COMMENT 'Priority level assigned to the appointment for scheduling.. Valid values are `low|medium|high`',
    `service_type` STRING COMMENT 'Classification of the service (e.g., routine maintenance, warranty repair, recall, pre‑delivery inspection, customer‑pay).. Valid values are `maintenance|warranty_repair|recall|pdi|customer_pay`',
    `total_actual_amount` DECIMAL(18,2) COMMENT 'Final charge for the appointment after labor, parts, taxes, and discounts.',
    `transportation_option` STRING COMMENT 'Customer transportation provision during service.. Valid values are `loaner|shuttle|wait|none`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the appointment record.',
    `vehicle_mileage` BIGINT COMMENT 'Odometer reading at the time of service appointment.',
    `warranty_flag` BOOLEAN COMMENT 'True if the appointment is covered under a warranty agreement.',
    CONSTRAINT pk_aftersales_service_appointment PRIMARY KEY(`aftersales_service_appointment_id`)
) COMMENT 'Scheduled service appointment record for a vehicle at a dealership or authorized service center. Captures appointment date/time, customer contact, VIN, service type (maintenance, warranty repair, recall, PDI, customer pay), service advisor assigned, estimated duration, transportation option (loaner, shuttle, wait), appointment source (online, phone, DMS, mobile app), confirmation status, check-in time, and no-show flag. Sourced from CDK Global DMS scheduling module.';

CREATE OR REPLACE TABLE `automotive_ecm`.`aftersales`.`tsb` (
    `tsb_id` BIGINT COMMENT 'System-generated unique identifier for the Technical Service Bulletin record.',
    `change_id` BIGINT COMMENT 'Foreign key linking to engineering.change. Business justification: TSBs are frequently triggered by or co-issued with engineering change orders (ECOs). OEMs require ECO-to-TSB traceability for regulatory submissions and warranty cost recovery. This link enables the e',
    `defect_record_id` BIGINT COMMENT 'Foreign key linking to quality.defect_record. Business justification: TSBs are issued in response to field defect patterns. Quality teams analyze defect records to identify systemic issues requiring technical service bulletins - core process linking quality defect track',
    `design_specification_id` BIGINT COMMENT 'Foreign key linking to engineering.design_specification. Business justification: Technical Service Bulletins are issued based on design specifications; the link provides traceability for compliance audits.',
    `ecu_catalog_id` BIGINT COMMENT 'Foreign key linking to vehicle.ecu_catalog. Business justification: OTA-capable TSBs (is_ota_capable flag on tsb) reference specific ECU catalog entries to identify affected software baselines. Service technicians and OTA update systems need this link to determine whi',
    `fmea_id` BIGINT COMMENT 'Foreign key linking to quality.fmea. Business justification: TSBs are created based on FMEA failure mode predictions validated by field data. Quality engineering uses FMEA analysis to inform TSB root cause and remedy procedures - standard automotive quality-to-',
    `fmea_record_id` BIGINT COMMENT 'Foreign key linking to engineering.fmea_record. Business justification: TSBs are directly traceable to FMEA failure modes per APQP/PPAP requirements. When a field failure matches a predicted failure mode, the FMEA record is referenced in the TSB for corrective action trac',
    `labor_time_standard_id` BIGINT COMMENT 'Foreign key linking to aftersales.labor_time_standard. Business justification: A Technical Service Bulletin specifies the repair procedure and estimated labor hours. Linking tsb to labor_time_standard normalizes the labor time reference — the TSB should reference the official fl',
    `model_id` BIGINT COMMENT 'Foreign key linking to vehicle.model. Business justification: TSBs are issued for specific vehicle models; service technicians look up applicable TSBs by model during diagnosis. The plain text affected_vehicle_model column is a denormalization of vehicle.model. ',
    `part_master_id` BIGINT COMMENT 'Foreign key linking to engineering.part_master. Business justification: TSBs reference the engineering part (not just service part) for design traceability, supplier recovery, and FMEA feedback. tsb.part_number is a denormalized plain-text field; replacing with part_maste',
    `production_variant_id` BIGINT COMMENT 'Foreign key linking to manufacturing.production_variant. Business justification: TSBs are issued for specific production variants (e.g., a specific engine or powertrain variant with a known field issue). Service engineers and parts planners need to identify which production varian',
    `regulatory_requirement_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_requirement. Business justification: TSBs frequently address regulatory compliance issues (emissions calibration updates, safety system modifications). Linking TSB to regulatory_requirement enables tracking which technical bulletins sati',
    `service_campaign_id` BIGINT COMMENT 'Foreign key linking to aftersales.service_campaign. Business justification: Technical Service Bulletin (TSB) is issued as part of a service campaign; linking provides campaign context.',
    `validation_test_id` BIGINT COMMENT 'Foreign key linking to engineering.validation_test. Business justification: TSB root-cause analysis requires traceability to the validation test that failed to detect the field issue. OEM DVP gap reporting and APQP corrective action processes depend on this link to identify w',
    `affected_model_year_end` STRING COMMENT 'Last model year in the range affected by the bulletin.',
    `affected_model_year_start` STRING COMMENT 'First model year in the range affected by the bulletin.',
    `affected_vin_end` STRING COMMENT 'Ending VIN in the range covered by the bulletin.',
    `affected_vin_start` STRING COMMENT 'Starting VIN (Vehicle Identification Number) in the range covered by the bulletin.',
    `attachment_url` STRING COMMENT 'Link to the full PDF or digital document of the bulletin.',
    `author_department` STRING COMMENT 'Organizational department responsible for the bulletin (e.g., Powertrain, Body, Electronics).',
    `author_engineer` STRING COMMENT 'Name of the OEM engineer who authored the bulletin.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the bulletin record was first created in the data lake.',
    `distribution_status` STRING COMMENT 'Current status of bulletin distribution to the dealer network.. Valid values are `pending|distributed|completed`',
    `effective_from` DATE COMMENT 'Date from which the bulletin recommendations become applicable.',
    `effective_until` DATE COMMENT 'Date after which the bulletin is no longer applicable (nullable for open‑ended bulletins).',
    `estimated_labor_hours` DECIMAL(18,2) COMMENT 'Estimated technician labor time required to complete the repair.',
    `is_ota_capable` BOOLEAN COMMENT 'Indicates whether the fix can be delivered via Over‑The‑Air update.',
    `issue_date` DATE COMMENT 'Date the bulletin was officially issued by the OEM.',
    `labor_rate_per_hour` DECIMAL(18,2) COMMENT 'Standard labor rate applied for cost estimation (currency assumed USD).',
    `last_review_date` DATE COMMENT 'Date when the bulletin was last reviewed for relevance or accuracy.',
    `notes` STRING COMMENT 'Free‑form field for any supplemental information or comments.',
    `part_revision` STRING COMMENT 'Revision identifier of the required part.',
    `regulatory_compliance_flag` BOOLEAN COMMENT 'True if the bulletin satisfies a regulatory requirement (e.g., NHTSA, EPA).',
    `repair_procedure` STRING COMMENT 'Step‑by‑step instructions for service technicians to resolve the issue.',
    `review_status` STRING COMMENT 'Outcome of the most recent technical review.. Valid values are `pending|approved|rejected`',
    `root_cause` STRING COMMENT 'Technical explanation of why the symptom occurs.',
    `severity_level` STRING COMMENT 'Impact severity of the issue addressed by the bulletin.. Valid values are `low|medium|high|critical`',
    `superseded_by_tsb_number` STRING COMMENT 'TSB number that supersedes this bulletin, if any.',
    `symptom_description` STRING COMMENT 'Narrative of the customer‑reported or observed symptom that triggers the bulletin.',
    `title` STRING COMMENT 'Short descriptive title of the bulletin.',
    `total_estimated_cost` DECIMAL(18,2) COMMENT 'Combined estimated cost of parts and labor for the bulletin repair.',
    `tsb_number` STRING COMMENT 'OEM-assigned alphanumeric identifier for the bulletin (e.g., TSB-2023-001).',
    `tsb_status` STRING COMMENT 'Current lifecycle status of the bulletin.. Valid values are `draft|active|retired|superseded`',
    `tsb_type` STRING COMMENT 'Category of the bulletin indicating its purpose.. Valid values are `safety|recall|service|maintenance|software`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the bulletin record.',
    `vehicle_system_affected` STRING COMMENT 'Specific vehicle subsystem (e.g., ECU, transmission) impacted by the issue.',
    `version_number` STRING COMMENT 'Incremental version of the bulletin content.',
    `warranty_impact_flag` BOOLEAN COMMENT 'Indicates whether the repair is covered under vehicle warranty.',
    CONSTRAINT pk_tsb PRIMARY KEY(`tsb_id`)
) COMMENT 'Technical Service Bulletin master record issued by OEM engineering to communicate repair procedures, diagnostic guidance, or part supersessions to the dealer service network. Captures TSB number, title, affected nameplate/model year/VIN range, symptom description, root cause, recommended repair procedure, required parts list, estimated labor time, issue date, supersession reference, and distribution status to dealer network. Integrates with PTC Windchill and CDK Global DMS.';

CREATE OR REPLACE TABLE `automotive_ecm`.`aftersales`.`labor_time_standard` (
    `labor_time_standard_id` BIGINT COMMENT 'Unique surrogate key for each labor time standard record.',
    `model_id` BIGINT COMMENT 'Foreign key linking to vehicle.model. Business justification: Labor time standards are defined per vehicle model for repair order costing and technician scheduling. Service advisors look up standard hours by model daily. The vehicle_segment, body_style, and mode',
    `routing_id` BIGINT COMMENT 'Foreign key linking to manufacturing.routing. Business justification: Aftersales flat-rate labor time standards are derived from and validated against manufacturing routing operation times. Service engineering teams reference manufacturing routings when establishing or ',
    `vehicle_program_id` BIGINT COMMENT 'Foreign key linking to engineering.vehicle_program. Business justification: Flat rate labor time standards are published per vehicle program and model year. OEM service engineering teams maintain program-specific labor time manuals; linking labor_time_standard to vehicle_prog',
    `body_style` STRING COMMENT 'Body style classification of the vehicle (e.g., hatchback, pickup). [ENUM-REF-CANDIDATE: coupe|sedan|hatchback|wagon|pickup|van|SUV — 7 candidates stripped; promote to reference product]',
    `compliance_nhtsa_code` STRING COMMENT 'Regulatory code from NHTSA that the labor operation must satisfy.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the record was first created in the system.',
    `effective_from` DATE COMMENT 'Date from which the labor time standard becomes effective.',
    `effective_until` DATE COMMENT 'Date after which the labor time standard is no longer valid (null if open‑ended).',
    `is_mandatory` BOOLEAN COMMENT 'True if the operation is mandatory for the vehicle model/year, false otherwise.',
    `labor_category` STRING COMMENT 'Broad category of labor (e.g., maintenance, repair).. Valid values are `maintenance|repair|diagnostic|installation`',
    `labor_time_standard_status` STRING COMMENT 'Current lifecycle status of the labor time standard.. Valid values are `active|inactive|deprecated`',
    `labor_type` STRING COMMENT 'Indicates whether the labor is covered under warranty, billed to the customer, or part of a recall.. Valid values are `warranty|customer_pay|recall`',
    `last_revision_date` DATE COMMENT 'Date when the labor time standard was last revised.',
    `notes` STRING COMMENT 'Free‑form comments or special instructions for the labor operation.',
    `oem_part_number` STRING COMMENT 'Part number of the OEM component associated with the operation, if any.',
    `operation_code` STRING COMMENT 'Standardized code identifying the labor operation (e.g., "A123").',
    `operation_description` STRING COMMENT 'Human‑readable description of the labor operation performed.',
    `region` STRING COMMENT 'Geographic region where the standard applies.. Valid values are `NA|EU|APAC|LATAM|MEA`',
    `revision_number` STRING COMMENT 'Sequential number indicating the revision of the standard.',
    `skill_level` STRING COMMENT 'Technician skill level required to perform the operation.. Valid values are `L1|L2|L3|L4|L5|L6`',
    `source` STRING COMMENT 'Origin of the labor time data (OEM guide, MOTOR, Alldata, etc.).. Valid values are `OEM|MOTOR|Alldata|Other`',
    `special_tool_required` BOOLEAN COMMENT 'Indicates whether a special tool is needed (true) or not (false).',
    `standard_hours` DECIMAL(18,2) COMMENT 'Flat‑rate labor time in hours for the operation.',
    `tool_code` STRING COMMENT 'Identifier of the special tool required for the operation.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the record.',
    `vehicle_model_year_end` STRING COMMENT 'Last model year for which this labor time standard applies.',
    `vehicle_model_year_start` STRING COMMENT 'First model year for which this labor time standard applies.',
    `vehicle_segment` STRING COMMENT 'Segment of vehicle (e.g., sedan, SUV) to which the standard is applicable.. Valid values are `sedan|SUV|truck|van|crossover|commercial`',
    CONSTRAINT pk_labor_time_standard PRIMARY KEY(`labor_time_standard_id`)
) COMMENT 'Reference master for flat-rate labor time standards (operation times) used to price warranty claims and customer-pay repair operations. Captures operation code, operation description, applicable nameplate/model year range, standard flat-rate hours, skill level required, special tool requirement flag, last revision date, and source (OEM labor time guide or MOTOR/Alldata industry standard). Used by CDK Global DMS to auto-populate labor time on repair order lines.';

CREATE OR REPLACE TABLE `automotive_ecm`.`aftersales`.`service_part` (
    `service_part_id` BIGINT COMMENT 'Unique surrogate key for the service part record.',
    `inbound_part_id` BIGINT COMMENT 'Foreign key linking to supply.inbound_part. Business justification: REQUIRED: Service Part Origin Traceability needed for regulatory compliance (NHTSA/UNECE) links service parts to their inbound part records.',
    `part_master_id` BIGINT COMMENT 'Foreign key linking to engineering.part_master. Business justification: Required for parts traceability report linking service inventory to engineering part master specs, essential for compliance and quality analysis.',
    `compliance_certification` STRING COMMENT 'Regulatory certification(s) applicable to the part (e.g., EPA, DOT).',
    `core_charge` DECIMAL(18,2) COMMENT 'Refundable deposit required for parts that are returned for reuse.',
    `country_of_origin` STRING COMMENT 'Three‑letter ISO country code indicating where the part was manufactured.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Date‑time when the service part record was first created in the system.',
    `dealer_net_price` DECIMAL(18,2) COMMENT 'Price offered to authorized dealers after standard discounts.',
    `effective_end_date` DATE COMMENT 'Date when the part is retired from the service catalog (null if open‑ended).',
    `effective_start_date` DATE COMMENT 'Date when the part becomes valid for use in service operations.',
    `epa_hazardous_material_code` STRING COMMENT 'EPA classification code for hazardous parts, if applicable.',
    `hazardous_classification` STRING COMMENT 'Regulatory classification code for hazardous parts (e.g., UN number).',
    `hazmat_flag` BOOLEAN COMMENT 'Indicates whether the part is classified as hazardous material.',
    `height_mm` DECIMAL(18,2) COMMENT 'Physical height of the part in millimetres.',
    `inventory_status` STRING COMMENT 'Current inventory availability status of the part.. Valid values are `in_stock|out_of_stock|backordered|discontinued`',
    `last_used_timestamp` TIMESTAMP COMMENT 'Date‑time when the part was last consumed in a service transaction.',
    `length_mm` DECIMAL(18,2) COMMENT 'Physical length of the part in millimetres.',
    `lifecycle_status` STRING COMMENT 'Current lifecycle state of the part within the after‑sales catalog.. Valid values are `active|superseded|discontinued|obsolete`',
    `list_price` DECIMAL(18,2) COMMENT 'Manufacturer suggested retail price before any discounts.',
    `manufacturer_name` STRING COMMENT 'Name of the original equipment manufacturer that produces the part.',
    `part_category` STRING COMMENT 'High‑level classification of the part type.. Valid values are `mechanical|electrical|body|consumable|accessory`',
    `part_name` STRING COMMENT 'Human‑readable name or description of the part.',
    `part_number` STRING COMMENT 'Manufacturer-assigned part number used to uniquely identify the part across the enterprise.',
    `part_revision` STRING COMMENT 'Revision identifier for engineering changes to the part.',
    `service_part_description` STRING COMMENT 'Full textual description of the part, including fitment notes.',
    `superseded_by_part_number` STRING COMMENT 'Part number that replaces this part when it is superseded.',
    `unit_of_measure` STRING COMMENT 'Standard unit used for inventory and transaction quantities (e.g., EA, SET).',
    `updated_timestamp` TIMESTAMP COMMENT 'Date‑time of the most recent update to the service part record.',
    `warranty_eligible_flag` BOOLEAN COMMENT 'Indicates whether the part is covered under the standard warranty program.',
    `warranty_period_months` STRING COMMENT 'Number of months the part is covered by warranty from the date of installation.',
    `weight_kg` DECIMAL(18,2) COMMENT 'Net weight of the part in kilograms.',
    `width_mm` DECIMAL(18,2) COMMENT 'Physical width of the part in millimetres.',
    CONSTRAINT pk_service_part PRIMARY KEY(`service_part_id`)
) COMMENT 'Aftersales service parts master record for parts stocked and consumed in dealer service and repair operations. Captures OEM part number, supersession chain (current and all prior part numbers), part description, part category (mechanical, electrical, body, consumable, fluid, accessory), unit of measure, standard list price, dealer net price, core charge amount, weight, hazmat flag, country of origin, minimum order quantity, and lifecycle status (active, superseded, discontinued, obsolete). Serves as the aftersales-specific view of the parts catalog optimized for service ordering and warranty claims — distinct from the manufacturing BOM parts master in the engineering domain.';

CREATE OR REPLACE TABLE `automotive_ecm`.`aftersales`.`parts_order` (
    `parts_order_id` BIGINT COMMENT 'Unique identifier for the parts_order data product (auto-inserted pre-linking).',
    `aftersales_repair_order_id` BIGINT COMMENT 'Foreign key linking to aftersales.aftersales_repair_order. Business justification: A parts order may be placed specifically to fulfill parts needed for an active repair order (emergency or special order). This FK links the parts procurement directly to the repair event. Nullable — m',
    `cost_center_id` BIGINT COMMENT 'Foreign key linking to finance.cost_center. Business justification: Parts procurement cost is charged to a cost center for expense reporting in the Parts Spend Report.',
    `storage_location_id` BIGINT COMMENT 'Foreign key linking to inventory.storage_location. Business justification: Parts orders must specify the warehouse location for picking and shipping operations. Fulfillment location code is denormalized; proper FK enables inventory allocation, pick list generation, and shipp',
    `gl_account_id` BIGINT COMMENT 'Foreign key linking to finance.gl_account. Business justification: GL account reference is required for posting parts purchase amounts in the Procurement GL Posting process.',
    `dealership_id` BIGINT COMMENT 'Unique identifier of the dealer or service center that placed the parts order.',
    `profit_center_id` BIGINT COMMENT 'Foreign key linking to finance.profit_center. Business justification: Profit center allocation allows analysis of parts cost contribution to overall profitability.',
    `purchase_order_id` BIGINT COMMENT 'Foreign key linking to supply.supply_purchase_order. Business justification: REQUIRED: Dealer‑to‑Supplier PO Reconciliation report matches dealership parts orders to supplier purchase orders for cost allocation and audit.',
    `service_center_id` BIGINT COMMENT 'Foreign key linking to aftersales.service_center. Business justification: A parts order is placed by or on behalf of a specific service center. aftersales_parts_order has dealership_id FKs but lacks a direct FK to the service_center that needs the parts. This FK enables ser',
    `shipment_id` BIGINT COMMENT 'Foreign key linking to logistics.shipment. Business justification: Service parts distribution from central warehouses to dealership service centers requires inbound logistics tracking. Service centers need shipment visibility for inventory planning, appointment sched',
    `actual_delivery_date` DATE COMMENT 'Date the parts were actually received at the dealer.',
    `backorder_flag` BOOLEAN COMMENT 'Indicates whether any line items are on backorder.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the parts order record was first created in the data lake.',
    `currency_code` STRING COMMENT 'Three‑letter ISO 4217 code of the currency used for the order.. Valid values are `^[A-Z]{3}$`',
    `discount_amount` DECIMAL(18,2) COMMENT 'Total discount granted on the order.',
    `freight_cost` DECIMAL(18,2) COMMENT 'Cost of shipping the parts from the fulfillment location to the dealer.',
    `freight_terms` STRING COMMENT 'Terms governing freight cost responsibility.. Valid values are `prepaid|collect|third_party`',
    `net_total` DECIMAL(18,2) COMMENT 'Final amount payable after applying discounts, taxes, and freight.',
    `order_number` STRING COMMENT 'External business identifier assigned to the parts order by the dealer or OEM system.',
    `order_status` STRING COMMENT 'Current lifecycle state of the parts order (e.g., submitted, confirmed, picked, shipped, received, invoiced, cancelled). [ENUM-REF-CANDIDATE: submitted|confirmed|picked|shipped|received|invoiced|cancelled — promote to reference product]',
    `order_timestamp` TIMESTAMP COMMENT 'Date and time when the parts order was placed by the dealer.',
    `order_type` STRING COMMENT 'Classification of the order based on business need.. Valid values are `stock|emergency|campaign|special`',
    `payment_terms` STRING COMMENT 'Agreed payment condition for the order.. Valid values are `net30|net45|net60|cod`',
    `priority_flag` BOOLEAN COMMENT 'Indicates if the order is marked as high priority.',
    `requested_delivery_date` DATE COMMENT 'Date requested by the dealer for parts to be delivered.',
    `shipping_method` STRING COMMENT 'Mode of transportation used to deliver the parts.. Valid values are `ground|air|sea|rail`',
    `special_instructions` STRING COMMENT 'Free‑text field for any additional handling or delivery instructions.',
    `tax_amount` DECIMAL(18,2) COMMENT 'Total tax applied to the order.',
    `total_order_value` DECIMAL(18,2) COMMENT 'Gross monetary value of the order before discounts, taxes, and freight.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the parts order record.',
    CONSTRAINT pk_parts_order PRIMARY KEY(`parts_order_id`)
) COMMENT 'Parts order placed by a dealer or service center to the OEM parts distribution center (PDC) or regional warehouse. Captures order number, ordering dealer code, PDC fulfillment location, order date, requested delivery date, order type (stock, emergency, campaign/recall, special), order status (submitted, confirmed, picked, shipped, received, invoiced), total order value, freight terms, and backorder flags. Integrates with SAP MM and dealer DMS parts ordering module.';

CREATE OR REPLACE TABLE `automotive_ecm`.`aftersales`.`parts_order_line` (
    `parts_order_line_id` BIGINT COMMENT 'Unique surrogate key for each line item within a dealer parts order.',
    `parts_order_id` BIGINT COMMENT 'Identifier of the parts order (header) to which this line belongs.',
    `service_part_id` BIGINT COMMENT 'Surrogate key of the part master record referenced by this line.',
    `stock_balance_id` BIGINT COMMENT 'Foreign key linking to inventory.stock_balance. Business justification: Parts order lines should reference the specific stock balance record allocated for fulfillment to enable lot/batch traceability, FIFO/FEFO picking, expiration date management, and quality status verif',
    `backorder_quantity` DECIMAL(18,2) COMMENT 'Units still pending fulfillment after initial shipment.',
    `confirmed_quantity` DECIMAL(18,2) COMMENT 'Number of units the supplier confirmed it can supply.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when the line record was first created in the system.',
    `currency_code` STRING COMMENT 'Currency in which the monetary amounts are expressed.. Valid values are `USD|EUR|JPY|CAD|GBP|AUD`',
    `discount_amount` DECIMAL(18,2) COMMENT 'Monetary discount granted for this line item.',
    `estimated_availability_date` DATE COMMENT 'Projected calendar date when the part can be shipped.',
    `line_sequence` STRING COMMENT 'Ordinal position of the line item in the parts order.',
    `line_status` STRING COMMENT 'Lifecycle status of the line item.. Valid values are `open|confirmed|shipped|backordered|canceled`',
    `line_total` DECIMAL(18,2) COMMENT 'Gross amount for the line before discounts, taxes, and adjustments.',
    `notes` STRING COMMENT 'Additional remarks entered by the dealer or supplier regarding the line item.',
    `ordered_quantity` DECIMAL(18,2) COMMENT 'Number of units the dealer ordered.',
    `shipped_quantity` DECIMAL(18,2) COMMENT 'Number of units dispatched from the warehouse.',
    `substitution_part_number` STRING COMMENT 'Part number of a substitute component offered in place of the original.',
    `tax_amount` DECIMAL(18,2) COMMENT 'Tax calculated for the line based on applicable rates.',
    `unit_price` DECIMAL(18,2) COMMENT 'Price per single unit of the part before discounts and taxes.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time of the most recent modification to the line record.',
    `warranty_flag` BOOLEAN COMMENT 'True if the part is supplied under warranty terms.',
    CONSTRAINT pk_parts_order_line PRIMARY KEY(`parts_order_line_id`)
) COMMENT 'Individual line item within a dealer parts order. Captures part number, ordered quantity, confirmed quantity, shipped quantity, unit price, line total, backorder quantity, estimated availability date, and substitution part number if original is unavailable. Enables granular parts fulfillment tracking and backorder management at the line level.';

CREATE OR REPLACE TABLE `automotive_ecm`.`aftersales`.`service_contract` (
    `service_contract_id` BIGINT COMMENT 'System-generated unique identifier for the service contract record.',
    `cost_center_id` BIGINT COMMENT 'Foreign key linking to finance.cost_center. Business justification: Contract revenue allocation uses a cost center to capture service contract income in the Contract Revenue Report.',
    `gl_account_id` BIGINT COMMENT 'Foreign key linking to finance.gl_account. Business justification: GL account reference is required for posting contract revenue and expense in the Contract Accounting process.',
    `party_id` BIGINT COMMENT 'Identifier of the customer who purchased the service contract.',
    `dealership_id` BIGINT COMMENT 'Identifier of the dealer that sold the service contract to the customer.',
    `profit_center_id` BIGINT COMMENT 'Foreign key linking to finance.profit_center. Business justification: Profit center links enable profitability analysis of service contracts across business units.',
    `regulatory_requirement_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_requirement. Business justification: Service contracts (extended warranties, maintenance plans) must comply with insurance regulations, consumer protection laws, and warranty disclosure requirements that vary by jurisdiction. Tracking re',
    `service_center_id` BIGINT COMMENT 'Identifier of the primary service center authorized to fulfill the contract.',
    `tertiary_service_transfer_to_dealer_dealership_id` BIGINT COMMENT 'Identifier of the dealer that received the transferred contract.',
    `vehicle_program_id` BIGINT COMMENT 'Foreign key linking to engineering.vehicle_program. Business justification: Service contracts are sold per vehicle program; linking enables revenue forecasting and program‑level service planning.',
    `vin_registry_id` BIGINT COMMENT 'Foreign key linking to vehicle.vin_registry. Business justification: Binds service contracts to the VIN registry to enforce service plan applicability and mileage tracking.',
    `warranty_policy_id` BIGINT COMMENT 'Foreign key linking to aftersales.warranty_policy. Business justification: A service contract defines coverage based on a warranty policy; linking to warranty_policy enables consistent policy lookup and eliminates redundant policy attributes in service_contract.',
    `administrator_code` BIGINT COMMENT 'Identifier of the entity (OEM or third‑party) that administers the contract.',
    `cancellation_date` DATE COMMENT 'Date on which the contract was formally cancelled, if applicable.',
    `cancellation_reason` STRING COMMENT 'Free‑text reason provided for contract cancellation.',
    `claim_count` STRING COMMENT 'Total number of service claims submitted under this contract.',
    `contract_description` STRING COMMENT 'Free‑text description of the contract terms and conditions.',
    `contract_type` STRING COMMENT 'Category of coverage provided by the service contract.. Valid values are `powertrain|comprehensive|maintenance|tire_and_wheel|roadside_assistance|extended_warranty`',
    `coverage_mileage_limit` BIGINT COMMENT 'Maximum mileage (kilometres) covered under the contract.',
    `created_timestamp` TIMESTAMP COMMENT 'Date‑time when the contract record was first created in the system.',
    `currency_code` STRING COMMENT 'Three‑letter ISO 4217 code of the currency used for the contract value.. Valid values are `^[A-Z]{3}$`',
    `deductible_amount` DECIMAL(18,2) COMMENT 'Fixed amount the customer must pay per claim before the contract pays.',
    `discount_amount` DECIMAL(18,2) COMMENT 'Discount granted on the contract price before tax.',
    `effective_from` DATE COMMENT 'Date when the contract coverage becomes effective.',
    `effective_until` DATE COMMENT 'Date when the contract coverage expires or terminates (nullable for open‑ended contracts).',
    `is_refundable` BOOLEAN COMMENT 'Indicates whether the contract value is refundable upon early termination.',
    `is_transferable` BOOLEAN COMMENT 'Indicates whether the contract may be transferred to another dealer or owner.',
    `last_claim_date` DATE COMMENT 'Date of the most recent claim filed against the contract.',
    `mileage_used` BIGINT COMMENT 'Total mileage recorded on the vehicle while the contract was active.',
    `net_contract_value` DECIMAL(18,2) COMMENT 'Final contract value after applying discounts and taxes.',
    `payment_method` STRING COMMENT 'Method used by the customer to pay for the contract.. Valid values are `credit_card|debit_card|bank_transfer|cash|check`',
    `payment_term_code` STRING COMMENT 'Standard payment term applied to the contract invoice.. Valid values are `net30|net45|net60|cash|credit`',
    `regulatory_compliance_flag` BOOLEAN COMMENT 'True if the contract complies with all applicable automotive regulatory requirements.',
    `renewal_date` DATE COMMENT 'Scheduled date for contract renewal if renewal_option is not none.',
    `renewal_option` STRING COMMENT 'Policy for contract renewal: automatic, manual, or none.. Valid values are `auto|manual|none`',
    `service_contract_status` STRING COMMENT 'Current lifecycle state of the service contract.. Valid values are `active|expired|cancelled|transferred|pending|suspended`',
    `tax_amount` DECIMAL(18,2) COMMENT 'Tax component applied to the contract price.',
    `total_contract_value` DECIMAL(18,2) COMMENT 'Gross monetary value of the contract at the time of sale.',
    `transfer_date` DATE COMMENT 'Date when the contract ownership was transferred to another dealer or party.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date‑time of the most recent modification to the contract record.',
    `warranty_flag` BOOLEAN COMMENT 'Indicates whether the vehicle is still under the original OEM warranty (true) or not (false).',
    CONSTRAINT pk_service_contract PRIMARY KEY(`service_contract_id`)
) COMMENT 'Extended service contract or vehicle service agreement (VSA) sold to a customer beyond the standard OEM warranty. Captures contract number, VIN, customer reference, contract type (powertrain, comprehensive, maintenance plan, tire and wheel), coverage start date, coverage end date, coverage mileage limit, deductible amount, selling dealer, administrator (OEM or third-party), contract status (active, expired, cancelled, transferred), and total contract value. Distinct from the OEM warranty_policy which is factory-issued.';

CREATE OR REPLACE TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` (
    `service_contract_claim_id` BIGINT COMMENT 'System-generated unique identifier for the service contract claim record.',
    `aftersales_repair_order_id` BIGINT COMMENT 'Identifier of the repair order associated with the claim.',
    `cost_center_id` BIGINT COMMENT 'Foreign key linking to finance.cost_center. Business justification: Each claim expense is allocated to a cost center for accurate service contract cost tracking.',
    `gl_account_id` BIGINT COMMENT 'Foreign key linking to finance.gl_account. Business justification: GL account is needed to post claim expense entries in the Service Contract Claim GL Posting routine.',
    `party_id` BIGINT COMMENT 'Identifier of the customer who owns the vehicle and holds the service contract.',
    `dealership_id` BIGINT COMMENT 'Identifier of the dealer associated with the claim.',
    `profit_center_id` BIGINT COMMENT 'Foreign key linking to finance.profit_center. Business justification: Profit center linkage enables claim profitability analysis per business unit.',
    `service_center_id` BIGINT COMMENT 'Identifier of the service center that performed the repair.',
    `service_contract_id` BIGINT COMMENT 'Identifier of the extended service contract under which the claim is filed.',
    `vehicle_program_id` BIGINT COMMENT 'Foreign key linking to engineering.vehicle_program. Business justification: Claims are aggregated by vehicle program for reliability metrics and warranty cost analysis.',
    `vin_registry_id` BIGINT COMMENT 'Foreign key linking to vehicle.vin_registry. Business justification: Service contract claims are filed against specific vehicles. The plain text vin column on service_contract_claim is a denormalization of vehicle.vin_registry. A structured FK enables vehicle-level cla',
    `adjusted_amount` DECIMAL(18,2) COMMENT 'Amount of monetary adjustment applied to the approved claim.',
    `approved_amount` DECIMAL(18,2) COMMENT 'Final amount approved for payment after adjustments and deductible.',
    `claim_adjusted_flag` BOOLEAN COMMENT 'Indicates whether the claim amount has been adjusted after initial approval.',
    `claim_adjustment_reason` STRING COMMENT 'Reason provided for any monetary adjustment to the claim.',
    `claim_category` STRING COMMENT 'High‑level classification of the claim type.. Valid values are `repair|maintenance|upgrade|other`',
    `claim_closure_date` DATE COMMENT 'Date when the claim was closed or paid.',
    `claim_created_timestamp` TIMESTAMP COMMENT 'Timestamp when the claim record was first created in the system.',
    `claim_effective_date` DATE COMMENT 'Date on which the claim becomes effective for processing.',
    `claim_line_item_count` STRING COMMENT 'Number of individual line items (parts, labor, etc.) associated with the claim.',
    `claim_number` STRING COMMENT 'External reference number assigned to the claim by the service contract system.',
    `claim_original_amount` DECIMAL(18,2) COMMENT 'Original total amount requested before any deductions or adjustments.',
    `claim_payment_method` STRING COMMENT 'Method used to remit payment for the claim.. Valid values are `check|credit|direct_deposit`',
    `claim_payment_status` STRING COMMENT 'Current status of the claim payment.. Valid values are `pending|completed|failed`',
    `claim_payment_timestamp` TIMESTAMP COMMENT 'Timestamp when the approved claim amount was paid to the service provider.',
    `claim_priority` STRING COMMENT 'Priority level assigned to the claim for processing.. Valid values are `high|medium|low`',
    `claim_review_timestamp` TIMESTAMP COMMENT 'Timestamp when the claim was reviewed.',
    `claim_reviewed_by` STRING COMMENT 'User identifier of the employee who reviewed the claim.',
    `claim_status` STRING COMMENT 'Current processing status of the claim.. Valid values are `pending|approved|denied|paid`',
    `claim_submission_timestamp` TIMESTAMP COMMENT 'Date and time when the claim was submitted to the service contract system.',
    `claim_submitted_by` STRING COMMENT 'User identifier of the employee who submitted the claim.',
    `claim_type` STRING COMMENT 'Indicates whether the claim is under an extended service contract or a voluntary service agreement.. Valid values are `extended_service_contract|voluntary_service_agreement`',
    `claim_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the claim record.',
    `claimed_labor_amount` DECIMAL(18,2) COMMENT 'Labor cost claimed for the repair, before any adjustments.',
    `claimed_parts_amount` DECIMAL(18,2) COMMENT 'Parts cost claimed for the repair, before any adjustments.',
    `covered_repair_description` STRING COMMENT 'Narrative description of the repair work covered by the claim.',
    `currency_code` STRING COMMENT 'Three‑letter ISO currency code for monetary values in the claim.. Valid values are `^[A-Z]{3}$`',
    `deductible_amount` DECIMAL(18,2) COMMENT 'Deductible applied to the claim as per the service contract terms.',
    `denial_reason_code` STRING COMMENT 'Code indicating why a claim was denied, if applicable.',
    `labor_rate_per_hour` DECIMAL(18,2) COMMENT 'Standard labor rate applied to calculate labor charges.',
    `notes` STRING COMMENT 'Free‑form text notes entered by claim processors.',
    `parts_tax_amount` DECIMAL(18,2) COMMENT 'Tax amount applied to the parts portion of the claim.',
    CONSTRAINT pk_service_contract_claim PRIMARY KEY(`service_contract_claim_id`)
) COMMENT 'Claim submitted against an extended service contract or VSA for a covered repair. Tracks claim number, service contract reference, repair order reference, VIN, claim submission date, covered repair description, claimed labor amount, claimed parts amount, deductible applied, approved amount, claim status (pending, approved, denied, paid), and denial reason code. Distinct from OEM warranty_claim which is submitted to the manufacturer.';

CREATE OR REPLACE TABLE `automotive_ecm`.`aftersales`.`goodwill_adjustment` (
    `goodwill_adjustment_id` BIGINT COMMENT 'System-generated unique identifier for the goodwill adjustment record.',
    `aftersales_repair_order_id` BIGINT COMMENT 'Identifier of the repair order linked to this goodwill transaction.',
    `aftersales_warranty_claim_id` BIGINT COMMENT 'Foreign key linking to aftersales.aftersales_warranty_claim. Business justification: A goodwill adjustment may be issued in conjunction with or as a supplement to a warranty claim (e.g., when warranty coverage is denied but OEM provides goodwill relief). goodwill_adjustment has warran',
    `fiscal_period_id` BIGINT COMMENT 'Foreign key linking to finance.fiscal_period. Business justification: Goodwill adjustments must be assigned to specific fiscal periods for period-close accuracy, monthly/quarterly financial statements, warranty reserve calculations, and variance analysis. Approval_times',
    `gl_account_id` BIGINT COMMENT 'Foreign key linking to finance.gl_account. Business justification: Goodwill adjustments are financial transactions requiring GL account assignment for expense classification, financial statement preparation, and audit trail. Standard automotive finance practice track',
    `party_id` BIGINT COMMENT 'Identifier of the customer receiving the goodwill assistance.',
    `dealership_id` BIGINT COMMENT 'Identifier of the dealer or service center that processed the goodwill adjustment.',
    `profit_center_id` BIGINT COMMENT 'Foreign key linking to finance.profit_center. Business justification: Goodwill costs must be allocated to profit centers for P&L responsibility, regional performance analysis, and dealer/service center profitability tracking. Essential for automotive aftersales financia',
    `service_campaign_id` BIGINT COMMENT 'Identifier of a service or recall campaign linked to the goodwill adjustment.',
    `vehicle_program_id` BIGINT COMMENT 'Foreign key linking to engineering.vehicle_program. Business justification: Goodwill adjustments are tracked by vehicle program for program-level quality cost reporting and design defect cost allocation. OEM program management reviews goodwill spend by vehicle program to asse',
    `vin_registry_id` BIGINT COMMENT 'Foreign key linking to vehicle.vin_registry. Business justification: Goodwill adjustments are issued for specific vehicles identified by VIN. The plain text vin column on goodwill_adjustment is a denormalization of vehicle.vin_registry. A structured FK enables vehicle-',
    `adjustment_number` STRING COMMENT 'External reference number assigned to the goodwill adjustment for tracking and audit.',
    `adjustment_timestamp` TIMESTAMP COMMENT 'Date and time when the goodwill adjustment was applied to the customers account.',
    `approval_authority_level` STRING COMMENT 'Organizational level of the person who approved the goodwill adjustment.. Valid values are `supervisor|manager|director|vice_president|executive`',
    `approval_timestamp` TIMESTAMP COMMENT 'Date and time when the goodwill adjustment received final approval.',
    `approved_amount` DECIMAL(18,2) COMMENT 'Total monetary value approved for the goodwill adjustment before tax.',
    `approved_by` STRING COMMENT 'Name of the individual who approved the goodwill adjustment.',
    `business_justification` STRING COMMENT 'Narrative explanation why the goodwill adjustment was granted.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when the goodwill adjustment record was first created in the system.',
    `currency_code` STRING COMMENT 'Three‑letter ISO currency code for the approved amount.',
    `goodwill_adjustment_status` STRING COMMENT 'Current lifecycle state of the goodwill adjustment.. Valid values are `pending|approved|rejected|closed|cancelled`',
    `goodwill_type` STRING COMMENT 'Category of goodwill assistance provided to the customer.. Valid values are `full_coverage|partial_coverage|parts_only|labor_only|cash_reimbursement`',
    `labor_cost` DECIMAL(18,2) COMMENT 'Monetary value of labor covered by the goodwill adjustment.',
    `notes` STRING COMMENT 'Free‑form comments or observations related to the goodwill adjustment.',
    `nps_impact_flag` BOOLEAN COMMENT 'Indicates whether the goodwill adjustment is linked to a Net Promoter Score (NPS) impact initiative.',
    `nps_score_change` STRING COMMENT 'Projected change in the customers NPS score attributable to this goodwill adjustment.',
    `part_cost` DECIMAL(18,2) COMMENT 'Monetary value of parts covered by the goodwill adjustment.',
    `source_system` STRING COMMENT 'Originating operational system that created the goodwill adjustment record.. Valid values are `SAP_S4HANA|CDK_DMS|Other`',
    `tax_amount` DECIMAL(18,2) COMMENT 'Tax applied to the goodwill adjustment amount.',
    `total_amount` DECIMAL(18,2) COMMENT 'Sum of approved amount, parts cost, labor cost, and tax.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time of the most recent modification to the goodwill adjustment record.',
    `warranty_flag` BOOLEAN COMMENT 'Indicates whether the goodwill adjustment is associated with a warranty claim.',
    CONSTRAINT pk_goodwill_adjustment PRIMARY KEY(`goodwill_adjustment_id`)
) COMMENT 'Goodwill or customer assistance transaction where the OEM or dealer provides financial relief to a customer for a repair outside standard warranty coverage. Captures adjustment number, VIN, customer reference, repair order reference, goodwill type (full coverage, partial coverage, parts-only, labor-only, cash reimbursement), requested amount, approved amount, approval authority level (service manager, zone manager, regional, national), business justification narrative, policy exception code, and customer retention outcome. Tracks OEM goodwill spend against budget allocations and enables cost management reporting by region, model, and failure type.';

CREATE OR REPLACE TABLE `automotive_ecm`.`aftersales`.`service_center` (
    `service_center_id` BIGINT COMMENT 'Unique surrogate key for the service center record.',
    `company_code_id` BIGINT COMMENT 'Foreign key linking to finance.company_code. Business justification: Service centers operate under specific legal entities for tax compliance, employment law, liability management, and financial reporting. Essential for multi-entity automotive groups with regional serv',
    `dealership_id` BIGINT COMMENT 'Identifier of the dealer group to which the service center belongs.',
    `jurisdiction_id` BIGINT COMMENT 'Foreign key linking to compliance.jurisdiction. Business justification: Service centers must comply with local regulations (environmental disposal, labor laws, safety standards, emissions testing authorization). Linking to jurisdiction enables tracking authorization statu',
    `plant_id` BIGINT COMMENT 'Foreign key linking to manufacturing.plant. Business justification: Service Center performance dashboard aggregates service metrics by originating plant for warranty and recall analysis.',
    `adas_calibration_authorized` BOOLEAN COMMENT 'Indicates whether the center can calibrate Advanced Driver Assistance Systems.',
    `address_line1` STRING COMMENT 'Primary street address of the service center.',
    `address_line2` STRING COMMENT 'Secondary address information (suite, floor, etc.).',
    `authorization_level` STRING COMMENT 'Combined classification of services the center is authorized to perform.. Valid values are `warranty|recall|collision|ev_certified|adas_calibration|none`',
    `average_service_time_minutes` DECIMAL(18,2) COMMENT 'Mean duration from service order start to completion, expressed in minutes.',
    `city` STRING COMMENT 'City where the service center is located.',
    `collision_authorized` BOOLEAN COMMENT 'Indicates whether the center is certified to perform collision repairs.',
    `country` STRING COMMENT 'Three‑letter ISO country code.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the service center record was first created.',
    `dsk_instance_code` BIGINT COMMENT 'Identifier of the CDK Global DMS instance that manages this service center.',
    `effective_end_date` DATE COMMENT 'Date when the service center ceased operations (null if still active).',
    `effective_start_date` DATE COMMENT 'Date when the service center became active in the network.',
    `ev_certified` BOOLEAN COMMENT 'Indicates whether the center is qualified to service electric vehicles.',
    `iatf_certified` BOOLEAN COMMENT 'Indicates compliance with IATF 16949 quality management standards.',
    `is_primary_center` BOOLEAN COMMENT 'Indicates if this center is the primary hub for its dealer group.',
    `iso9001_certified` BOOLEAN COMMENT 'Indicates compliance with ISO 9001 quality management standards.',
    `last_audit_date` DATE COMMENT 'Date when the most recent compliance audit was performed.',
    `latitude` DOUBLE COMMENT 'Latitude coordinate of the service center location.',
    `loaner_fleet_size` STRING COMMENT 'Number of loaner vehicles maintained for customer use.',
    `longitude` DOUBLE COMMENT 'Longitude coordinate of the service center location.',
    `market` STRING COMMENT 'Market segment served (e.g., premium, mass‑market, commercial).',
    `network_status` STRING COMMENT 'Current participation status of the center in the OEM service network.. Valid values are `active|suspended|terminated`',
    `notes` STRING COMMENT 'Free‑form field for any supplemental information about the service center.',
    `operating_hours` STRING COMMENT 'Standard weekly operating hours (e.g., Mon‑Fri 08:00‑18:00).',
    `postal_code` STRING COMMENT 'Postal or ZIP code.. Valid values are `^[A-Z0-9]{3,10}$`',
    `recall_authorized` BOOLEAN COMMENT 'Indicates whether the center can execute manufacturer recall campaigns.',
    `region` STRING COMMENT 'Regional grouping (e.g., North America, EMEA) used for reporting.',
    `regulatory_status` STRING COMMENT 'Current status of the centers compliance with automotive regulations.. Valid values are `compliant|non_compliant|under_review`',
    `service_bay_count` STRING COMMENT 'Total count of service bays available for vehicle work.',
    `service_center_code` STRING COMMENT 'External business code used to reference the service center in dealer and OEM systems.',
    `service_center_name` STRING COMMENT 'Human‑readable name of the authorized service center.',
    `service_center_type` STRING COMMENT 'Category of the service center based on ownership and relationship to OEM.. Valid values are `dealership|independent|authorized|factory`',
    `service_orders_processed` BIGINT COMMENT 'Cumulative count of service orders completed at the center.',
    `state` STRING COMMENT 'State or province abbreviation.. Valid values are `^[A-Z]{2}$`',
    `technician_headcount` STRING COMMENT 'Number of technicians employed at the service center.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the service center record.',
    `warranty_authorized` BOOLEAN COMMENT 'Indicates whether the center can perform warranty repairs.',
    `warranty_claims_processed` BIGINT COMMENT 'Cumulative count of warranty claims handled by the center.',
    CONSTRAINT pk_service_center PRIMARY KEY(`service_center_id`)
) COMMENT 'Master record for authorized service centers and dealership service departments in the OEM aftersales network. Captures service center code, name, address, dealer group affiliation, authorization level (warranty, recall, certified collision, EV-certified, ADAS-calibration), service bay count, technician headcount, CDK Global DMS instance ID, operating hours, loaner fleet size, and network status (active, suspended, terminated). Distinct from the dealer domains dealer profile — this is the service-operations-specific view.';

CREATE OR REPLACE TABLE `automotive_ecm`.`aftersales`.`technician` (
    `technician_id` BIGINT COMMENT 'System-generated unique identifier for the service technician.',
    `service_center_id` BIGINT COMMENT 'Identifier of the service center to which the technician is assigned.',
    `availability_status` STRING COMMENT 'Current availability of the technician for new assignments.. Valid values are `available|unavailable|on_leave|scheduled`',
    `certification_expiry_date` DATE COMMENT 'Date on which the technicians current certification expires.',
    `certification_level` STRING COMMENT 'Level of certification achieved by the technician.. Valid values are `level1|level2|master|expert`',
    `certification_type` STRING COMMENT 'Type of certification held by the technician (e.g., ASE, OEM, EV, ADAS).. Valid values are `ASE|OEM|EV|ADAS|HV|GENERAL`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the technician record was first created.',
    `current_active_ro_count` STRING COMMENT 'Number of repair orders currently assigned to the technician.',
    `email_address` STRING COMMENT 'Primary email address used for communication with the technician.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `flat_rate_efficiency_rating` DECIMAL(18,2) COMMENT 'Efficiency rating expressed as a percentage of flat‑rate labor productivity.',
    `full_name` STRING COMMENT 'Legal full name of the technician.',
    `hire_date` DATE COMMENT 'Date the technician was hired by the organization.',
    `last_training_date` DATE COMMENT 'Date of the most recent training session attended by the technician.',
    `max_concurrent_ro` STRING COMMENT 'Maximum number of repair orders the technician can handle simultaneously.',
    `notes` STRING COMMENT 'Free‑form notes about the technician (e.g., performance comments, special accommodations).',
    `overtime_eligible` BOOLEAN COMMENT 'Indicates whether the technician is eligible for overtime pay.',
    `overtime_rate_multiplier` DECIMAL(18,2) COMMENT 'Multiplier applied to the base labor rate for overtime work.',
    `phone_number` STRING COMMENT 'Primary telephone number for the technician.',
    `shift_type` STRING COMMENT 'Work shift classification for the technician.. Valid values are `day|night|flex|rotating`',
    `skill_level` STRING COMMENT 'Skill tier of the technician based on experience and performance.. Valid values are `junior|mid|senior|lead`',
    `specialization` STRING COMMENT 'Technical area of expertise for the technician.. Valid values are `powertrain|electrical|body|diagnostics|software|hvac`',
    `technician_status` STRING COMMENT 'Current employment status of the technician.. Valid values are `active|inactive|suspended|retired`',
    `training_hours_completed` STRING COMMENT 'Cumulative hours of formal training completed by the technician.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the technician record.',
    `years_of_experience` STRING COMMENT 'Total number of years the technician has worked in automotive service.',
    CONSTRAINT pk_technician PRIMARY KEY(`technician_id`)
) COMMENT 'Master record for service technicians employed at authorized service centers. Captures technician ID, name, service center assignment, certification level (ASE, OEM-certified, EV-certified, ADAS-certified), specialization (powertrain, electrical, body, diagnostics), flat-rate efficiency rating, current active RO count, hire date, and certification expiry dates. This is the aftersales-specific technician profile focused on service capacity and certification — distinct from the workforce domains employee record.';

CREATE OR REPLACE TABLE `automotive_ecm`.`aftersales`.`parts_return` (
    `parts_return_id` BIGINT COMMENT 'Unique surrogate key for the parts return transaction.',
    `aftersales_warranty_claim_id` BIGINT COMMENT 'Foreign key linking to aftersales.aftersales_warranty_claim. Business justification: Warranty parts returns are required by OEMs as part of the warranty claim process — defective parts must be returned for inspection. parts_return has warranty_flag indicating warranty-related returns ',
    `cost_center_id` BIGINT COMMENT 'Foreign key linking to finance.cost_center. Business justification: Returned parts credit is allocated to a cost center for accurate reverse logistics cost accounting.',
    `part_master_id` BIGINT COMMENT 'Foreign key linking to engineering.part_master. Business justification: Returned parts are analyzed against the engineering part master to identify systemic defects and drive quality improvements.',
    `parts_order_id` BIGINT COMMENT 'Foreign key linking to aftersales.aftersales_parts_order. Business justification: A parts return is typically associated with the original parts order from which the part was received. parts_return currently stores original_order_number as a denormalized STRING — this should be a p',
    `dealership_id` BIGINT COMMENT 'Identifier of the dealer originating the return.',
    `storage_location_id` BIGINT COMMENT 'Foreign key linking to inventory.storage_location. Business justification: Returned parts must be received into a specific warehouse location for inspection, disposition, and restocking. Return location string is denormalized; FK enables proper goods receipt posting, quality',
    `repair_order_line_id` BIGINT COMMENT 'Foreign key linking to aftersales.repair_order_line. Business justification: A parts return may be traced back to the specific repair order line where the part was consumed (warranty core returns, defective parts used in repair). parts_return currently stores original_order_li',
    `service_campaign_id` BIGINT COMMENT 'Identifier of the service or recall campaign linked to the return.',
    `service_part_id` BIGINT COMMENT 'Foreign key linking to aftersales.service_part. Business justification: A parts return is for a specific service part. parts_return has part_master_id (cross-domain engineering FK) but lacks a FK to the aftersales-domain service_part master. This FK enables direct lookup ',
    `supplier_quality_event_id` BIGINT COMMENT 'Foreign key linking to quality.supplier_quality_event. Business justification: Parts returns from dealer inventory due to supplier quality issues must be tracked back to originating supplier quality events for cost recovery and supplier scorecarding - standard supplier quality m',
    `batch_number` STRING COMMENT 'Manufacturing batch identifier of the returned part, if applicable.',
    `core_return_flag` BOOLEAN COMMENT 'True when the part is a core that must be returned for reuse.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the return record was created in the system.',
    `credit_amount` DECIMAL(18,2) COMMENT 'Gross credit amount owed to the dealer before taxes or adjustments.',
    `credit_memo_date` DATE COMMENT 'Date the credit memo was generated.',
    `credit_memo_reference` STRING COMMENT 'Identifier of the credit memo generated for the return.',
    `currency_code` STRING COMMENT 'Three‑letter ISO currency code for the credit amount.',
    `inspected_by` STRING COMMENT 'Identifier of the employee who performed the inspection.',
    `inspection_date` DATE COMMENT 'Date the returned parts were inspected.',
    `inspection_notes` STRING COMMENT 'Free‑form notes from the inspection process.',
    `inspection_outcome` STRING COMMENT 'Result of OEM inspection of the returned part.. Valid values are `accepted|rejected|partial`',
    `is_credit_issued` BOOLEAN COMMENT 'Indicates whether a credit memo has been issued.',
    `lot_number` STRING COMMENT 'Lot identifier for traceability of the returned part.',
    `net_credit_amount` DECIMAL(18,2) COMMENT 'Net amount after tax and any adjustments.',
    `notes` STRING COMMENT 'Any supplemental information related to the return.',
    `overstock_flag` BOOLEAN COMMENT 'True when the return is due to dealer overstock.',
    `part_condition` STRING COMMENT 'Condition of the part at the time of return.. Valid values are `new|used|defective|repaired`',
    `quantity_returned` STRING COMMENT 'Number of units returned.',
    `received_date` DATE COMMENT 'Date the OEM received the returned parts.',
    `return_authorization_number` STRING COMMENT 'External reference number issued to authorize the parts return.',
    `return_date` DATE COMMENT 'Date the dealer initiated the return.',
    `return_method` STRING COMMENT 'Means by which the parts were returned to the OEM.. Valid values are `mail|carrier|dropoff|pickup`',
    `return_reason_category` STRING COMMENT 'High‑level category of the return reason.. Valid values are `quality|logistics|regulatory|other`',
    `return_reason_code` STRING COMMENT 'Standardized code describing why the part is being returned.',
    `return_reason_description` STRING COMMENT 'Human‑readable description of the return reason.',
    `return_source_system` STRING COMMENT 'Originating ERP or MES system that created the return record.',
    `return_status` STRING COMMENT 'Current processing status of the return.. Valid values are `pending|approved|rejected|processed|cancelled`',
    `return_type` STRING COMMENT 'Category of the return based on business rules.. Valid values are `warranty|core|overstock|campaign`',
    `shipment_tracking_number` STRING COMMENT 'Carrier tracking identifier for the return shipment.',
    `tax_amount` DECIMAL(18,2) COMMENT 'Tax component applied to the credit.',
    `unit_of_measure` STRING COMMENT 'Measurement unit for the quantity returned.. Valid values are `each|box|kg|liter`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the return record.',
    `warranty_flag` BOOLEAN COMMENT 'Indicates if the return is covered under warranty.',
    CONSTRAINT pk_parts_return PRIMARY KEY(`parts_return_id`)
) COMMENT 'Parts return transaction record for defective, warranty-core, or over-ordered parts returned from a dealer to the OEM PDC. Captures return authorization number, originating dealer, return reason code (warranty defect, core return, overstock, campaign supersession), part number, quantity returned, credit amount, return shipment tracking, OEM inspection outcome (accepted, rejected, partial credit), and credit memo reference. Integrates with SAP MM returns management.';

CREATE OR REPLACE TABLE `automotive_ecm`.`aftersales`.`tsb_part_requirement` (
    `tsb_part_requirement_id` BIGINT COMMENT 'System-generated unique identifier for this TSB-to-part requirement record.',
    `service_part_id` BIGINT COMMENT 'Foreign key linking to the service part required for this TSB repair procedure.',
    `tsb_id` BIGINT COMMENT 'Foreign key linking to the Technical Service Bulletin that specifies this part requirement.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this TSB-part requirement record was first created in the system.',
    `installation_sequence` STRING COMMENT 'Order in which this part should be installed during the repair procedure (1 = first, 2 = second, etc.). Relevant for complex multi-part TSB repairs.',
    `is_primary_part` BOOLEAN COMMENT 'Indicates whether this part is the primary component being replaced (true) or a supplemental part (gasket, fastener, fluid). Identified in detection reasoning as relationship-specific data.',
    `part_revision` STRING COMMENT 'Specific revision identifier of the part required for this TSB repair. Moved from tsb.part_revision because the revision requirement is specific to each TSB-part combination.',
    `part_role_in_procedure` STRING COMMENT 'Categorizes the parts function within the TSB repair procedure (e.g., primary replacement component, supplemental gasket, consumable fluid, diagnostic tool, optional upgrade). Identified in detection reasoning as relationship-specific data.',
    `quantity_required` DECIMAL(18,2) COMMENT 'Number of units of this part required to complete the TSB repair procedure. Identified in detection reasoning as relationship-specific data.',
    `required_parts` STRING COMMENT 'Comma‑separated list of part numbers and revisions needed for the repair. [Moved from tsb: The tsb.required_parts STRING attribute is a denormalized representation of the M:N relationship. This comma-separated list should be normalized into individual tsb_part_requirement records. This is the classic indicator of a collapsed M:N relationship.]',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this TSB-part requirement record.',
    CONSTRAINT pk_tsb_part_requirement PRIMARY KEY(`tsb_part_requirement_id`)
) COMMENT 'This association product represents the parts bill-of-materials specified in a Technical Service Bulletin. Each record links one TSB to one service part with attributes that define the parts role, quantity, and revision requirements for executing the repair procedure described in the bulletin. This is actively managed by OEM parts engineering and used by dealer parts departments for inventory pre-positioning.. Existence Justification: In automotive aftersales operations, Technical Service Bulletins specify a bill-of-materials (parts list) required to execute the repair procedure, and service parts are referenced across multiple TSBs as they apply to different symptoms, model years, or VIN ranges. OEM parts engineering actively manages this relationship as TSB Part Requirements or Repair Kit Definitions to enable dealer parts departments to pre-position inventory. The current models denormalized STRING fields (tsb.required_parts, tsb.part_revision) are clear evidence that this M:N relationship has been collapsed into a single record and should be normalized.';

-- ========= FOREIGN KEYS =========
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ADD CONSTRAINT `fk_aftersales_aftersales_repair_order_aftersales_service_appointment_id` FOREIGN KEY (`aftersales_service_appointment_id`) REFERENCES `automotive_ecm`.`aftersales`.`aftersales_service_appointment`(`aftersales_service_appointment_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ADD CONSTRAINT `fk_aftersales_aftersales_repair_order_service_campaign_id` FOREIGN KEY (`service_campaign_id`) REFERENCES `automotive_ecm`.`aftersales`.`service_campaign`(`service_campaign_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ADD CONSTRAINT `fk_aftersales_aftersales_repair_order_service_center_id` FOREIGN KEY (`service_center_id`) REFERENCES `automotive_ecm`.`aftersales`.`service_center`(`service_center_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ADD CONSTRAINT `fk_aftersales_aftersales_repair_order_technician_id` FOREIGN KEY (`technician_id`) REFERENCES `automotive_ecm`.`aftersales`.`technician`(`technician_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ADD CONSTRAINT `fk_aftersales_aftersales_repair_order_vehicle_warranty_id` FOREIGN KEY (`vehicle_warranty_id`) REFERENCES `automotive_ecm`.`aftersales`.`vehicle_warranty`(`vehicle_warranty_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ADD CONSTRAINT `fk_aftersales_repair_order_line_aftersales_repair_order_id` FOREIGN KEY (`aftersales_repair_order_id`) REFERENCES `automotive_ecm`.`aftersales`.`aftersales_repair_order`(`aftersales_repair_order_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ADD CONSTRAINT `fk_aftersales_repair_order_line_aftersales_service_appointment_id` FOREIGN KEY (`aftersales_service_appointment_id`) REFERENCES `automotive_ecm`.`aftersales`.`aftersales_service_appointment`(`aftersales_service_appointment_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ADD CONSTRAINT `fk_aftersales_repair_order_line_aftersales_warranty_claim_id` FOREIGN KEY (`aftersales_warranty_claim_id`) REFERENCES `automotive_ecm`.`aftersales`.`aftersales_warranty_claim`(`aftersales_warranty_claim_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ADD CONSTRAINT `fk_aftersales_repair_order_line_labor_time_standard_id` FOREIGN KEY (`labor_time_standard_id`) REFERENCES `automotive_ecm`.`aftersales`.`labor_time_standard`(`labor_time_standard_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ADD CONSTRAINT `fk_aftersales_repair_order_line_service_center_id` FOREIGN KEY (`service_center_id`) REFERENCES `automotive_ecm`.`aftersales`.`service_center`(`service_center_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ADD CONSTRAINT `fk_aftersales_repair_order_line_service_part_id` FOREIGN KEY (`service_part_id`) REFERENCES `automotive_ecm`.`aftersales`.`service_part`(`service_part_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ADD CONSTRAINT `fk_aftersales_repair_order_line_technician_id` FOREIGN KEY (`technician_id`) REFERENCES `automotive_ecm`.`aftersales`.`technician`(`technician_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ADD CONSTRAINT `fk_aftersales_repair_order_line_tsb_id` FOREIGN KEY (`tsb_id`) REFERENCES `automotive_ecm`.`aftersales`.`tsb`(`tsb_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ADD CONSTRAINT `fk_aftersales_aftersales_warranty_claim_aftersales_repair_order_id` FOREIGN KEY (`aftersales_repair_order_id`) REFERENCES `automotive_ecm`.`aftersales`.`aftersales_repair_order`(`aftersales_repair_order_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ADD CONSTRAINT `fk_aftersales_aftersales_warranty_claim_service_campaign_id` FOREIGN KEY (`service_campaign_id`) REFERENCES `automotive_ecm`.`aftersales`.`service_campaign`(`service_campaign_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ADD CONSTRAINT `fk_aftersales_aftersales_warranty_claim_service_center_id` FOREIGN KEY (`service_center_id`) REFERENCES `automotive_ecm`.`aftersales`.`service_center`(`service_center_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ADD CONSTRAINT `fk_aftersales_aftersales_warranty_claim_vehicle_warranty_id` FOREIGN KEY (`vehicle_warranty_id`) REFERENCES `automotive_ecm`.`aftersales`.`vehicle_warranty`(`vehicle_warranty_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ADD CONSTRAINT `fk_aftersales_aftersales_warranty_claim_warranty_policy_id` FOREIGN KEY (`warranty_policy_id`) REFERENCES `automotive_ecm`.`aftersales`.`warranty_policy`(`warranty_policy_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ADD CONSTRAINT `fk_aftersales_vehicle_warranty_warranty_policy_id` FOREIGN KEY (`warranty_policy_id`) REFERENCES `automotive_ecm`.`aftersales`.`warranty_policy`(`warranty_policy_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ADD CONSTRAINT `fk_aftersales_vehicle_warranty_service_center_id` FOREIGN KEY (`service_center_id`) REFERENCES `automotive_ecm`.`aftersales`.`service_center`(`service_center_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ADD CONSTRAINT `fk_aftersales_vehicle_warranty_service_contract_id` FOREIGN KEY (`service_contract_id`) REFERENCES `automotive_ecm`.`aftersales`.`service_contract`(`service_contract_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`campaign_vin` ADD CONSTRAINT `fk_aftersales_campaign_vin_aftersales_repair_order_id` FOREIGN KEY (`aftersales_repair_order_id`) REFERENCES `automotive_ecm`.`aftersales`.`aftersales_repair_order`(`aftersales_repair_order_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`campaign_vin` ADD CONSTRAINT `fk_aftersales_campaign_vin_aftersales_service_appointment_id` FOREIGN KEY (`aftersales_service_appointment_id`) REFERENCES `automotive_ecm`.`aftersales`.`aftersales_service_appointment`(`aftersales_service_appointment_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`campaign_vin` ADD CONSTRAINT `fk_aftersales_campaign_vin_service_campaign_id` FOREIGN KEY (`service_campaign_id`) REFERENCES `automotive_ecm`.`aftersales`.`service_campaign`(`service_campaign_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ADD CONSTRAINT `fk_aftersales_aftersales_service_appointment_service_campaign_id` FOREIGN KEY (`service_campaign_id`) REFERENCES `automotive_ecm`.`aftersales`.`service_campaign`(`service_campaign_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ADD CONSTRAINT `fk_aftersales_aftersales_service_appointment_service_center_id` FOREIGN KEY (`service_center_id`) REFERENCES `automotive_ecm`.`aftersales`.`service_center`(`service_center_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ADD CONSTRAINT `fk_aftersales_aftersales_service_appointment_technician_id` FOREIGN KEY (`technician_id`) REFERENCES `automotive_ecm`.`aftersales`.`technician`(`technician_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ADD CONSTRAINT `fk_aftersales_tsb_labor_time_standard_id` FOREIGN KEY (`labor_time_standard_id`) REFERENCES `automotive_ecm`.`aftersales`.`labor_time_standard`(`labor_time_standard_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ADD CONSTRAINT `fk_aftersales_tsb_service_campaign_id` FOREIGN KEY (`service_campaign_id`) REFERENCES `automotive_ecm`.`aftersales`.`service_campaign`(`service_campaign_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order` ADD CONSTRAINT `fk_aftersales_parts_order_aftersales_repair_order_id` FOREIGN KEY (`aftersales_repair_order_id`) REFERENCES `automotive_ecm`.`aftersales`.`aftersales_repair_order`(`aftersales_repair_order_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order` ADD CONSTRAINT `fk_aftersales_parts_order_service_center_id` FOREIGN KEY (`service_center_id`) REFERENCES `automotive_ecm`.`aftersales`.`service_center`(`service_center_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order_line` ADD CONSTRAINT `fk_aftersales_parts_order_line_parts_order_id` FOREIGN KEY (`parts_order_id`) REFERENCES `automotive_ecm`.`aftersales`.`parts_order`(`parts_order_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order_line` ADD CONSTRAINT `fk_aftersales_parts_order_line_service_part_id` FOREIGN KEY (`service_part_id`) REFERENCES `automotive_ecm`.`aftersales`.`service_part`(`service_part_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ADD CONSTRAINT `fk_aftersales_service_contract_service_center_id` FOREIGN KEY (`service_center_id`) REFERENCES `automotive_ecm`.`aftersales`.`service_center`(`service_center_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ADD CONSTRAINT `fk_aftersales_service_contract_warranty_policy_id` FOREIGN KEY (`warranty_policy_id`) REFERENCES `automotive_ecm`.`aftersales`.`warranty_policy`(`warranty_policy_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ADD CONSTRAINT `fk_aftersales_service_contract_claim_aftersales_repair_order_id` FOREIGN KEY (`aftersales_repair_order_id`) REFERENCES `automotive_ecm`.`aftersales`.`aftersales_repair_order`(`aftersales_repair_order_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ADD CONSTRAINT `fk_aftersales_service_contract_claim_service_center_id` FOREIGN KEY (`service_center_id`) REFERENCES `automotive_ecm`.`aftersales`.`service_center`(`service_center_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ADD CONSTRAINT `fk_aftersales_service_contract_claim_service_contract_id` FOREIGN KEY (`service_contract_id`) REFERENCES `automotive_ecm`.`aftersales`.`service_contract`(`service_contract_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`goodwill_adjustment` ADD CONSTRAINT `fk_aftersales_goodwill_adjustment_aftersales_repair_order_id` FOREIGN KEY (`aftersales_repair_order_id`) REFERENCES `automotive_ecm`.`aftersales`.`aftersales_repair_order`(`aftersales_repair_order_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`goodwill_adjustment` ADD CONSTRAINT `fk_aftersales_goodwill_adjustment_aftersales_warranty_claim_id` FOREIGN KEY (`aftersales_warranty_claim_id`) REFERENCES `automotive_ecm`.`aftersales`.`aftersales_warranty_claim`(`aftersales_warranty_claim_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`goodwill_adjustment` ADD CONSTRAINT `fk_aftersales_goodwill_adjustment_service_campaign_id` FOREIGN KEY (`service_campaign_id`) REFERENCES `automotive_ecm`.`aftersales`.`service_campaign`(`service_campaign_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`technician` ADD CONSTRAINT `fk_aftersales_technician_service_center_id` FOREIGN KEY (`service_center_id`) REFERENCES `automotive_ecm`.`aftersales`.`service_center`(`service_center_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ADD CONSTRAINT `fk_aftersales_parts_return_aftersales_warranty_claim_id` FOREIGN KEY (`aftersales_warranty_claim_id`) REFERENCES `automotive_ecm`.`aftersales`.`aftersales_warranty_claim`(`aftersales_warranty_claim_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ADD CONSTRAINT `fk_aftersales_parts_return_parts_order_id` FOREIGN KEY (`parts_order_id`) REFERENCES `automotive_ecm`.`aftersales`.`parts_order`(`parts_order_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ADD CONSTRAINT `fk_aftersales_parts_return_repair_order_line_id` FOREIGN KEY (`repair_order_line_id`) REFERENCES `automotive_ecm`.`aftersales`.`repair_order_line`(`repair_order_line_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ADD CONSTRAINT `fk_aftersales_parts_return_service_campaign_id` FOREIGN KEY (`service_campaign_id`) REFERENCES `automotive_ecm`.`aftersales`.`service_campaign`(`service_campaign_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ADD CONSTRAINT `fk_aftersales_parts_return_service_part_id` FOREIGN KEY (`service_part_id`) REFERENCES `automotive_ecm`.`aftersales`.`service_part`(`service_part_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb_part_requirement` ADD CONSTRAINT `fk_aftersales_tsb_part_requirement_service_part_id` FOREIGN KEY (`service_part_id`) REFERENCES `automotive_ecm`.`aftersales`.`service_part`(`service_part_id`);
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb_part_requirement` ADD CONSTRAINT `fk_aftersales_tsb_part_requirement_tsb_id` FOREIGN KEY (`tsb_id`) REFERENCES `automotive_ecm`.`aftersales`.`tsb`(`tsb_id`);

-- ========= TAGS =========
ALTER SCHEMA `automotive_ecm`.`aftersales` SET TAGS ('dbx_division' = 'business');
ALTER SCHEMA `automotive_ecm`.`aftersales` SET TAGS ('dbx_domain' = 'aftersales');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` SET TAGS ('dbx_subdomain' = 'service_operations');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `aftersales_repair_order_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Key for repair_order');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `aftersales_service_appointment_id` SET TAGS ('dbx_business_glossary_term' = 'Aftersales Service Appointment Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `build_spec_id` SET TAGS ('dbx_business_glossary_term' = 'Build Spec Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `change_id` SET TAGS ('dbx_business_glossary_term' = 'Engineering Change Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `cost_center_id` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `gl_account_id` SET TAGS ('dbx_business_glossary_term' = 'Gl Account Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `inspection_lot_id` SET TAGS ('dbx_business_glossary_term' = 'Inspection Lot Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `storage_location_id` SET TAGS ('dbx_business_glossary_term' = 'Parts Source Storage Location Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Customer ID');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `dealership_id` SET TAGS ('dbx_business_glossary_term' = 'Dealer ID');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `production_order_id` SET TAGS ('dbx_business_glossary_term' = 'Production Order Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `profit_center_id` SET TAGS ('dbx_business_glossary_term' = 'Profit Center Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `service_campaign_id` SET TAGS ('dbx_business_glossary_term' = 'Service Campaign ID');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `service_center_id` SET TAGS ('dbx_business_glossary_term' = 'Service Center ID');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `technician_id` SET TAGS ('dbx_business_glossary_term' = 'Technician ID');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `vehicle_build_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Build Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `vehicle_order_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Order Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `vehicle_ownership_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Ownership Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `vehicle_program_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Program Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `vehicle_warranty_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Warranty Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `vin_registry_id` SET TAGS ('dbx_business_glossary_term' = 'Vin Registry Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `actual_completion_time` SET TAGS ('dbx_business_glossary_term' = 'Actual Completion Timestamp');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `aftersales_repair_order_status` SET TAGS ('dbx_business_glossary_term' = 'Repair Order Status');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `aftersales_repair_order_status` SET TAGS ('dbx_value_regex' = 'open|in_progress|quality_check|closed|invoiced|cancelled');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `close_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Repair Order Close Timestamp');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (ISO 4217)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = 'USD|CAD|EUR|GBP|JPY');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `customer_feedback_score` SET TAGS ('dbx_business_glossary_term' = 'Customer Feedback Score');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `customer_signature_flag` SET TAGS ('dbx_business_glossary_term' = 'Customer Signature Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `diagnostic_code` SET TAGS ('dbx_business_glossary_term' = 'Diagnostic Trouble Code (DTC)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `diagnostic_code` SET TAGS ('dbx_value_regex' = '^[0-9]{4}$');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `discount_amount` SET TAGS ('dbx_business_glossary_term' = 'Discount Amount (USD)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `is_estimate` SET TAGS ('dbx_business_glossary_term' = 'Estimate Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `labor_rate_per_hour` SET TAGS ('dbx_business_glossary_term' = 'Labor Rate per Hour (USD)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `labor_total_cost` SET TAGS ('dbx_business_glossary_term' = 'Labor Total Cost (USD)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `labor_total_hours` SET TAGS ('dbx_business_glossary_term' = 'Labor Total Hours');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `mileage_at_service` SET TAGS ('dbx_business_glossary_term' = 'Mileage at Service (MILEAGE)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `net_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Amount (USD)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `open_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Repair Order Open Timestamp');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `parts_total_cost` SET TAGS ('dbx_business_glossary_term' = 'Parts Total Cost (USD)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'cash|credit_card|debit_card|bank_transfer|mobile_payment|check');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `payment_status` SET TAGS ('dbx_business_glossary_term' = 'Payment Status');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `payment_status` SET TAGS ('dbx_value_regex' = 'pending|paid|failed|refunded');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `promised_completion_time` SET TAGS ('dbx_business_glossary_term' = 'Promised Completion Timestamp');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `ro_number` SET TAGS ('dbx_business_glossary_term' = 'Repair Order Number (RO)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `service_center_region` SET TAGS ('dbx_business_glossary_term' = 'Service Center Region');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `service_center_region` SET TAGS ('dbx_value_regex' = 'North|South|East|West|Central');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `service_notes` SET TAGS ('dbx_business_glossary_term' = 'Service Notes');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `service_priority` SET TAGS ('dbx_business_glossary_term' = 'Service Priority');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `service_priority` SET TAGS ('dbx_value_regex' = 'high|medium|low|critical');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `service_type` SET TAGS ('dbx_business_glossary_term' = 'Service Type');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `service_type` SET TAGS ('dbx_value_regex' = 'maintenance|repair|recall|campaign|diagnostic');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Tax Amount (USD)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `technician_notes` SET TAGS ('dbx_business_glossary_term' = 'Technician Notes');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `total_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Amount (USD)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `warranty_claim_number` SET TAGS ('dbx_business_glossary_term' = 'Warranty Claim Number');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_repair_order` ALTER COLUMN `warranty_flag` SET TAGS ('dbx_business_glossary_term' = 'Warranty Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` SET TAGS ('dbx_subdomain' = 'service_operations');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `repair_order_line_id` SET TAGS ('dbx_business_glossary_term' = 'Repair Order Line ID');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `aftersales_repair_order_id` SET TAGS ('dbx_business_glossary_term' = 'Repair Order ID');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `aftersales_service_appointment_id` SET TAGS ('dbx_business_glossary_term' = 'Appointment ID');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `aftersales_warranty_claim_id` SET TAGS ('dbx_business_glossary_term' = 'Warranty Claim ID');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `change_id` SET TAGS ('dbx_business_glossary_term' = 'Engineering Change Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `gl_account_id` SET TAGS ('dbx_business_glossary_term' = 'Gl Account Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `inbound_part_id` SET TAGS ('dbx_business_glossary_term' = 'Inbound Part Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `inbound_shipment_id` SET TAGS ('dbx_business_glossary_term' = 'Inbound Shipment Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `labor_time_standard_id` SET TAGS ('dbx_business_glossary_term' = 'Labor Time Standard Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `service_center_id` SET TAGS ('dbx_business_glossary_term' = 'Service Center ID');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `service_part_id` SET TAGS ('dbx_business_glossary_term' = 'Service Part Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `sku_master_id` SET TAGS ('dbx_business_glossary_term' = 'Sku Master Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `storage_location_id` SET TAGS ('dbx_business_glossary_term' = 'Storage Location Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `technician_id` SET TAGS ('dbx_business_glossary_term' = 'Technician ID');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `tsb_id` SET TAGS ('dbx_business_glossary_term' = 'Tsb Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `actual_technician_hours` SET TAGS ('dbx_business_glossary_term' = 'Actual Technician Hours');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `cause_complaint` SET TAGS ('dbx_business_glossary_term' = 'Cause / Complaint Description');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `correction` SET TAGS ('dbx_business_glossary_term' = 'Correction Description');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = 'USD|CAD|EUR|GBP|JPY|CNY');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `discount_amount` SET TAGS ('dbx_business_glossary_term' = 'Discount Amount');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `labor_category` SET TAGS ('dbx_business_glossary_term' = 'Labor Category');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `labor_category` SET TAGS ('dbx_value_regex' = 'mechanical|electrical|diagnostic|body|software');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `labor_rate` SET TAGS ('dbx_business_glossary_term' = 'Labor Rate (Currency per Hour)');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `labor_skill_level` SET TAGS ('dbx_business_glossary_term' = 'Labor Skill Level');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `labor_skill_level` SET TAGS ('dbx_value_regex' = 'apprentice|journeyman|master|specialist');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `labor_time_standard` SET TAGS ('dbx_business_glossary_term' = 'Labor Time Standard (Hours)');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `line_sequence` SET TAGS ('dbx_business_glossary_term' = 'Line Sequence Number');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `line_status` SET TAGS ('dbx_business_glossary_term' = 'Line Status');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `line_status` SET TAGS ('dbx_value_regex' = 'open|in_progress|completed|closed|canceled');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `line_total` SET TAGS ('dbx_business_glossary_term' = 'Line Total Amount');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Line Notes');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `operation_code` SET TAGS ('dbx_business_glossary_term' = 'Labor Operation Code');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `overtime_flag` SET TAGS ('dbx_business_glossary_term' = 'Overtime Applied Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `overtime_multiplier` SET TAGS ('dbx_business_glossary_term' = 'Overtime Multiplier');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `part_price` SET TAGS ('dbx_business_glossary_term' = 'Part Unit Price');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `part_quantity` SET TAGS ('dbx_business_glossary_term' = 'Part Quantity');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `parts_used_flag` SET TAGS ('dbx_business_glossary_term' = 'Parts Used Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `service_date` SET TAGS ('dbx_business_glossary_term' = 'Service Date');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `sublet_cost` SET TAGS ('dbx_business_glossary_term' = 'Sublet Cost Amount');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `sublet_flag` SET TAGS ('dbx_business_glossary_term' = 'Sublet Service Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Tax Amount');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `vehicle_vin` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Identification Number (VIN)');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `vehicle_vin` SET TAGS ('dbx_value_regex' = '^[A-HJ-NPR-Z0-9]{17}$');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `vehicle_vin` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `vehicle_vin` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `automotive_ecm`.`aftersales`.`repair_order_line` ALTER COLUMN `warranty_flag` SET TAGS ('dbx_business_glossary_term' = 'Warranty Covered Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` SET TAGS ('dbx_subdomain' = 'warranty_management');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `aftersales_warranty_claim_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Key for warranty_claim');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `aftersales_repair_order_id` SET TAGS ('dbx_business_glossary_term' = 'Aftersales Repair Order Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `defect_record_id` SET TAGS ('dbx_business_glossary_term' = 'Defect Record Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `part_master_id` SET TAGS ('dbx_business_glossary_term' = 'Part Master Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Customer ID');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `dealership_id` SET TAGS ('dbx_business_glossary_term' = 'Dealer ID');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `production_variant_id` SET TAGS ('dbx_business_glossary_term' = 'Production Variant Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `recall_campaign_id` SET TAGS ('dbx_business_glossary_term' = 'Compliance Recall Campaign Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `service_campaign_id` SET TAGS ('dbx_business_glossary_term' = 'Campaign ID');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `service_center_id` SET TAGS ('dbx_business_glossary_term' = 'Service Center ID');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `supplier_id` SET TAGS ('dbx_business_glossary_term' = 'Supply Supplier Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `vehicle_build_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Build Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `vehicle_ownership_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Ownership Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `vehicle_program_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Program Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `vehicle_warranty_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Warranty Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `vin_registry_id` SET TAGS ('dbx_business_glossary_term' = 'Vin Registry Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `warranty_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Warranty Policy Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `adjudication_outcome` SET TAGS ('dbx_business_glossary_term' = 'Adjudication Outcome');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `adjudication_outcome` SET TAGS ('dbx_value_regex' = 'approved|rejected|partial|pending');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `adjusted_amount` SET TAGS ('dbx_business_glossary_term' = 'Adjusted Amount');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `approved_labor_cost` SET TAGS ('dbx_business_glossary_term' = 'Approved Labor Cost');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `approved_labor_hours` SET TAGS ('dbx_business_glossary_term' = 'Approved Labor Hours');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `approved_parts_cost` SET TAGS ('dbx_business_glossary_term' = 'Approved Parts Cost');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `claim_adjusted_flag` SET TAGS ('dbx_business_glossary_term' = 'Claim Adjusted Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `claim_category` SET TAGS ('dbx_business_glossary_term' = 'Claim Category');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `claim_category` SET TAGS ('dbx_value_regex' = 'repair|recall|service_campaign|maintenance');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `claim_created_by` SET TAGS ('dbx_business_glossary_term' = 'Claim Created By');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `claim_number` SET TAGS ('dbx_business_glossary_term' = 'Claim Number');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `claim_status` SET TAGS ('dbx_business_glossary_term' = 'Claim Status');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `claim_status` SET TAGS ('dbx_value_regex' = 'submitted|approved|rejected|adjusted|paid');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `claim_submission_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Claim Submission Timestamp');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = 'USD|EUR|JPY|CAD|GBP|CNY');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `failure_date` SET TAGS ('dbx_business_glossary_term' = 'Failure Date');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `goodwill_flag` SET TAGS ('dbx_business_glossary_term' = 'Goodwill Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `labor_rate_per_hour` SET TAGS ('dbx_business_glossary_term' = 'Labor Rate Per Hour');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Claim Notes');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `parts_tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Parts Tax Amount');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `record_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `rejection_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Rejection Reason Code');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `repair_date` SET TAGS ('dbx_business_glossary_term' = 'Repair Date');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `total_claim_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Claim Amount');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `warranty_end_date` SET TAGS ('dbx_business_glossary_term' = 'Warranty End Date');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `warranty_start_date` SET TAGS ('dbx_business_glossary_term' = 'Warranty Start Date');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `warranty_type` SET TAGS ('dbx_business_glossary_term' = 'Warranty Type');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_warranty_claim` ALTER COLUMN `warranty_type` SET TAGS ('dbx_value_regex' = 'bumper_to_bumper|powertrain|corrosion|roadside_assistance');
ALTER TABLE `automotive_ecm`.`aftersales`.`warranty_policy` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `automotive_ecm`.`aftersales`.`warranty_policy` SET TAGS ('dbx_subdomain' = 'warranty_management');
ALTER TABLE `automotive_ecm`.`aftersales`.`warranty_policy` ALTER COLUMN `warranty_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Warranty Policy ID');
ALTER TABLE `automotive_ecm`.`aftersales`.`warranty_policy` ALTER COLUMN `company_code_id` SET TAGS ('dbx_business_glossary_term' = 'Company Code Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`warranty_policy` ALTER COLUMN `model_id` SET TAGS ('dbx_business_glossary_term' = 'Model Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`warranty_policy` ALTER COLUMN `powertrain_spec_id` SET TAGS ('dbx_business_glossary_term' = 'Powertrain Spec Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`warranty_policy` ALTER COLUMN `powertrain_variant_id` SET TAGS ('dbx_business_glossary_term' = 'Powertrain Variant Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`warranty_policy` ALTER COLUMN `production_variant_id` SET TAGS ('dbx_business_glossary_term' = 'Production Variant Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`warranty_policy` ALTER COLUMN `regulatory_requirement_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Requirement Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`warranty_policy` ALTER COLUMN `standard_id` SET TAGS ('dbx_business_glossary_term' = 'Standard Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`warranty_policy` ALTER COLUMN `vehicle_program_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Program Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`warranty_policy` ALTER COLUMN `authorized_dealer_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Authorized Dealer Required Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`warranty_policy` ALTER COLUMN `claim_limit_per_year` SET TAGS ('dbx_business_glossary_term' = 'Annual Warranty Claim Limit');
ALTER TABLE `automotive_ecm`.`aftersales`.`warranty_policy` ALTER COLUMN `claim_limit_total` SET TAGS ('dbx_business_glossary_term' = 'Total Warranty Claim Limit');
ALTER TABLE `automotive_ecm`.`aftersales`.`warranty_policy` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Country Code');
ALTER TABLE `automotive_ecm`.`aftersales`.`warranty_policy` ALTER COLUMN `coverage_description` SET TAGS ('dbx_business_glossary_term' = 'Warranty Coverage Description');
ALTER TABLE `automotive_ecm`.`aftersales`.`warranty_policy` ALTER COLUMN `coverage_type` SET TAGS ('dbx_business_glossary_term' = 'Warranty Coverage Type');
ALTER TABLE `automotive_ecm`.`aftersales`.`warranty_policy` ALTER COLUMN `coverage_type` SET TAGS ('dbx_value_regex' = 'basic|powertrain|corrosion|emissions|ev_battery|adas');
ALTER TABLE `automotive_ecm`.`aftersales`.`warranty_policy` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `automotive_ecm`.`aftersales`.`warranty_policy` ALTER COLUMN `deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Warranty Deductible Amount');
ALTER TABLE `automotive_ecm`.`aftersales`.`warranty_policy` ALTER COLUMN `duration_months` SET TAGS ('dbx_business_glossary_term' = 'Warranty Duration (Months)');
ALTER TABLE `automotive_ecm`.`aftersales`.`warranty_policy` ALTER COLUMN `effective_end_date` SET TAGS ('dbx_business_glossary_term' = 'Warranty Effective End Date');
ALTER TABLE `automotive_ecm`.`aftersales`.`warranty_policy` ALTER COLUMN `effective_start_date` SET TAGS ('dbx_business_glossary_term' = 'Warranty Effective Start Date');
ALTER TABLE `automotive_ecm`.`aftersales`.`warranty_policy` ALTER COLUMN `eop_date` SET TAGS ('dbx_business_glossary_term' = 'End of Production Date');
ALTER TABLE `automotive_ecm`.`aftersales`.`warranty_policy` ALTER COLUMN `exclusions` SET TAGS ('dbx_business_glossary_term' = 'Warranty Exclusions');
ALTER TABLE `automotive_ecm`.`aftersales`.`warranty_policy` ALTER COLUMN `extension_allowed_flag` SET TAGS ('dbx_business_glossary_term' = 'Warranty Extension Allowed Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`warranty_policy` ALTER COLUMN `extension_terms` SET TAGS ('dbx_business_glossary_term' = 'Warranty Extension Terms');
ALTER TABLE `automotive_ecm`.`aftersales`.`warranty_policy` ALTER COLUMN `inclusions` SET TAGS ('dbx_business_glossary_term' = 'Warranty Inclusions');
ALTER TABLE `automotive_ecm`.`aftersales`.`warranty_policy` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `automotive_ecm`.`aftersales`.`warranty_policy` ALTER COLUMN `market_region` SET TAGS ('dbx_business_glossary_term' = 'Market Region');
ALTER TABLE `automotive_ecm`.`aftersales`.`warranty_policy` ALTER COLUMN `mileage_limit` SET TAGS ('dbx_business_glossary_term' = 'Warranty Mileage Limit');
ALTER TABLE `automotive_ecm`.`aftersales`.`warranty_policy` ALTER COLUMN `model_year` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Model Year');
ALTER TABLE `automotive_ecm`.`aftersales`.`warranty_policy` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Warranty Policy Notes');
ALTER TABLE `automotive_ecm`.`aftersales`.`warranty_policy` ALTER COLUMN `policy_number` SET TAGS ('dbx_business_glossary_term' = 'Warranty Policy Number');
ALTER TABLE `automotive_ecm`.`aftersales`.`warranty_policy` ALTER COLUMN `policy_status` SET TAGS ('dbx_business_glossary_term' = 'Warranty Policy Status');
ALTER TABLE `automotive_ecm`.`aftersales`.`warranty_policy` ALTER COLUMN `policy_status` SET TAGS ('dbx_value_regex' = 'active|expired|suspended|terminated');
ALTER TABLE `automotive_ecm`.`aftersales`.`warranty_policy` ALTER COLUMN `regulatory_body` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Body');
ALTER TABLE `automotive_ecm`.`aftersales`.`warranty_policy` ALTER COLUMN `regulatory_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reference Number');
ALTER TABLE `automotive_ecm`.`aftersales`.`warranty_policy` ALTER COLUMN `renewal_allowed_flag` SET TAGS ('dbx_business_glossary_term' = 'Warranty Renewal Allowed Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`warranty_policy` ALTER COLUMN `renewal_terms` SET TAGS ('dbx_business_glossary_term' = 'Warranty Renewal Terms');
ALTER TABLE `automotive_ecm`.`aftersales`.`warranty_policy` ALTER COLUMN `service_center_network` SET TAGS ('dbx_business_glossary_term' = 'Service Center Network');
ALTER TABLE `automotive_ecm`.`aftersales`.`warranty_policy` ALTER COLUMN `sop_date` SET TAGS ('dbx_business_glossary_term' = 'Start of Production Date');
ALTER TABLE `automotive_ecm`.`aftersales`.`warranty_policy` ALTER COLUMN `transferable_flag` SET TAGS ('dbx_business_glossary_term' = 'Warranty Transferability Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` SET TAGS ('dbx_subdomain' = 'warranty_management');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `vehicle_warranty_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Warranty ID');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `warranty_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Aftersales Warranty Policy Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Party Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `dealership_id` SET TAGS ('dbx_business_glossary_term' = 'Dealer Identifier');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `recall_campaign_id` SET TAGS ('dbx_business_glossary_term' = 'Recall Identifier');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `service_center_id` SET TAGS ('dbx_business_glossary_term' = 'Service Center Identifier');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `service_contract_id` SET TAGS ('dbx_business_glossary_term' = 'Service Contract Identifier');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `vehicle_program_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Program Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `vin_registry_id` SET TAGS ('dbx_business_glossary_term' = 'Vin Registry Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `claims_last_amount` SET TAGS ('dbx_business_glossary_term' = 'Last Warranty Claim Amount');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `claims_last_date` SET TAGS ('dbx_business_glossary_term' = 'Last Warranty Claim Date');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `coverage_area` SET TAGS ('dbx_business_glossary_term' = 'Warranty Coverage Area');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `coverage_area` SET TAGS ('dbx_value_regex' = 'domestic|international');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `coverage_description` SET TAGS ('dbx_business_glossary_term' = 'Coverage Description');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `coverage_end_mileage` SET TAGS ('dbx_business_glossary_term' = 'Warranty Coverage End Mileage');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `coverage_start_mileage` SET TAGS ('dbx_business_glossary_term' = 'Warranty Coverage Start Mileage');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `cpo_warranty_flag` SET TAGS ('dbx_business_glossary_term' = 'Certified Pre‑Owned Warranty Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `duration_months` SET TAGS ('dbx_business_glossary_term' = 'Warranty Duration (Months)');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `eligible_for_recall` SET TAGS ('dbx_business_glossary_term' = 'Eligibility for Recall');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `end_date` SET TAGS ('dbx_business_glossary_term' = 'Warranty Expiration Date');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `exclusions` SET TAGS ('dbx_business_glossary_term' = 'Warranty Exclusions');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `extended_warranty_flag` SET TAGS ('dbx_business_glossary_term' = 'Extended Warranty Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `last_transfer_date` SET TAGS ('dbx_business_glossary_term' = 'Last Warranty Transfer Date');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `mileage_limit` SET TAGS ('dbx_business_glossary_term' = 'Warranty Mileage Limit');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `original_purchase_date` SET TAGS ('dbx_business_glossary_term' = 'Original Purchase Date');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `policy_code` SET TAGS ('dbx_business_glossary_term' = 'Warranty Policy Code');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `program_category` SET TAGS ('dbx_business_glossary_term' = 'Warranty Program Category');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `program_category` SET TAGS ('dbx_value_regex' = 'new_vehicle|used_vehicle|cpo|extended');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `program_name` SET TAGS ('dbx_business_glossary_term' = 'Warranty Program Name');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `remaining_mileage` SET TAGS ('dbx_business_glossary_term' = 'Remaining Warranty Mileage');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `remaining_months` SET TAGS ('dbx_business_glossary_term' = 'Remaining Warranty Months');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `renewal_date` SET TAGS ('dbx_business_glossary_term' = 'Warranty Renewal Date');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `renewal_flag` SET TAGS ('dbx_business_glossary_term' = 'Warranty Renewal Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `service_plan` SET TAGS ('dbx_business_glossary_term' = 'Warranty Service Plan');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `start_date` SET TAGS ('dbx_business_glossary_term' = 'Warranty Effective Start Date');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `status_reason` SET TAGS ('dbx_business_glossary_term' = 'Warranty Status Reason');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `status_reason` SET TAGS ('dbx_value_regex' = 'normal|customer_cancel|manufacturer_recall|non_payment');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `transfer_allowed` SET TAGS ('dbx_business_glossary_term' = 'Warranty Transfer Allowed');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `transfer_count` SET TAGS ('dbx_business_glossary_term' = 'Warranty Transfer Count');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `transfer_fee` SET TAGS ('dbx_business_glossary_term' = 'Warranty Transfer Fee');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `vehicle_warranty_status` SET TAGS ('dbx_business_glossary_term' = 'Warranty Status');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `vehicle_warranty_status` SET TAGS ('dbx_value_regex' = 'active|expired|voided|suspended|transferred');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `warranty_claims_amount` SET TAGS ('dbx_business_glossary_term' = 'Warranty Claims Amount');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `warranty_claims_count` SET TAGS ('dbx_business_glossary_term' = 'Warranty Claims Count');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `warranty_document_url` SET TAGS ('dbx_business_glossary_term' = 'Warranty Document URL');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `warranty_number` SET TAGS ('dbx_business_glossary_term' = 'Warranty Policy Number');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `warranty_terms_version` SET TAGS ('dbx_business_glossary_term' = 'Warranty Terms Version');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `warranty_type` SET TAGS ('dbx_business_glossary_term' = 'Warranty Type');
ALTER TABLE `automotive_ecm`.`aftersales`.`vehicle_warranty` ALTER COLUMN `warranty_type` SET TAGS ('dbx_value_regex' = 'bumper_to_bumper|powertrain|corrosion|roadside_assistance|extended');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_campaign` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_campaign` SET TAGS ('dbx_subdomain' = 'technical_support');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_campaign` ALTER COLUMN `service_campaign_id` SET TAGS ('dbx_business_glossary_term' = 'Service Campaign ID');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_campaign` ALTER COLUMN `change_id` SET TAGS ('dbx_business_glossary_term' = 'Change Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_campaign` ALTER COLUMN `fmea_record_id` SET TAGS ('dbx_business_glossary_term' = 'Fmea Record Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_campaign` ALTER COLUMN `model_id` SET TAGS ('dbx_business_glossary_term' = 'Model Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_campaign` ALTER COLUMN `plant_id` SET TAGS ('dbx_business_glossary_term' = 'Plant Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_campaign` ALTER COLUMN `part_master_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Part Master Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_campaign` ALTER COLUMN `production_line_id` SET TAGS ('dbx_business_glossary_term' = 'Production Line Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_campaign` ALTER COLUMN `production_variant_id` SET TAGS ('dbx_business_glossary_term' = 'Production Variant Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_campaign` ALTER COLUMN `regulatory_requirement_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Requirement Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_campaign` ALTER COLUMN `vehicle_program_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Program Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_campaign` ALTER COLUMN `affected_model_year_end` SET TAGS ('dbx_business_glossary_term' = 'Affected Model Year End');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_campaign` ALTER COLUMN `affected_model_year_start` SET TAGS ('dbx_business_glossary_term' = 'Affected Model Year Start');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_campaign` ALTER COLUMN `affected_vin_population` SET TAGS ('dbx_business_glossary_term' = 'Affected VIN Population');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_campaign` ALTER COLUMN `campaign_cost_estimate` SET TAGS ('dbx_business_glossary_term' = 'Campaign Cost Estimate');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_campaign` ALTER COLUMN `campaign_notes` SET TAGS ('dbx_business_glossary_term' = 'Campaign Notes');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_campaign` ALTER COLUMN `campaign_priority` SET TAGS ('dbx_business_glossary_term' = 'Campaign Priority');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_campaign` ALTER COLUMN `campaign_priority` SET TAGS ('dbx_value_regex' = 'high|medium|low');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_campaign` ALTER COLUMN `campaign_region` SET TAGS ('dbx_business_glossary_term' = 'Campaign Region');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_campaign` ALTER COLUMN `campaign_region` SET TAGS ('dbx_value_regex' = 'USA|CAN|MEX|EU|JP|KR');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_campaign` ALTER COLUMN `campaign_status` SET TAGS ('dbx_business_glossary_term' = 'Campaign Status');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_campaign` ALTER COLUMN `campaign_status` SET TAGS ('dbx_value_regex' = 'open|closed|suspended|completed|cancelled');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_campaign` ALTER COLUMN `campaign_type` SET TAGS ('dbx_business_glossary_term' = 'Campaign Type');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_campaign` ALTER COLUMN `campaign_type` SET TAGS ('dbx_value_regex' = 'safety_recall|emissions_recall|customer_satisfaction|technical_service_bulletin');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_campaign` ALTER COLUMN `compliance_status` SET TAGS ('dbx_business_glossary_term' = 'Compliance Status');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_campaign` ALTER COLUMN `compliance_status` SET TAGS ('dbx_value_regex' = 'compliant|non_compliant|pending');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_campaign` ALTER COLUMN `customer_satisfaction_flag` SET TAGS ('dbx_business_glossary_term' = 'Customer Satisfaction Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_campaign` ALTER COLUMN `effective_end_date` SET TAGS ('dbx_business_glossary_term' = 'Effective End Date');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_campaign` ALTER COLUMN `effective_start_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Start Date');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_campaign` ALTER COLUMN `emissions_recall_flag` SET TAGS ('dbx_business_glossary_term' = 'Emissions Recall Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_campaign` ALTER COLUMN `estimated_repair_time_minutes` SET TAGS ('dbx_business_glossary_term' = 'Estimated Repair Time (Minutes)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_campaign` ALTER COLUMN `nhtsa_compliance_flag` SET TAGS ('dbx_business_glossary_term' = 'NHTSA Compliance Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_campaign` ALTER COLUMN `parts_cost_estimate` SET TAGS ('dbx_business_glossary_term' = 'Parts Cost Estimate');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_campaign` ALTER COLUMN `parts_required` SET TAGS ('dbx_business_glossary_term' = 'Parts Required');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_campaign` ALTER COLUMN `record_audit_created` SET TAGS ('dbx_business_glossary_term' = 'Record Audit Created');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_campaign` ALTER COLUMN `record_audit_updated` SET TAGS ('dbx_business_glossary_term' = 'Record Audit Updated');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_campaign` ALTER COLUMN `regulatory_reporting_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Date');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_campaign` ALTER COLUMN `regulatory_reporting_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Status');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_campaign` ALTER COLUMN `regulatory_reporting_status` SET TAGS ('dbx_value_regex' = 'pending|submitted|approved|rejected');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_campaign` ALTER COLUMN `remedy_description` SET TAGS ('dbx_business_glossary_term' = 'Remedy Description');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_campaign` ALTER COLUMN `safety_recall_flag` SET TAGS ('dbx_business_glossary_term' = 'Safety Recall Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_campaign` ALTER COLUMN `technical_service_bulletin_flag` SET TAGS ('dbx_business_glossary_term' = 'Technical Service Bulletin Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_campaign` ALTER COLUMN `unece_compliance_flag` SET TAGS ('dbx_business_glossary_term' = 'UNECE Compliance Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_campaign` ALTER COLUMN `warranty_impact_flag` SET TAGS ('dbx_business_glossary_term' = 'Warranty Impact Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`campaign_vin` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `automotive_ecm`.`aftersales`.`campaign_vin` SET TAGS ('dbx_subdomain' = 'technical_support');
ALTER TABLE `automotive_ecm`.`aftersales`.`campaign_vin` ALTER COLUMN `campaign_vin_id` SET TAGS ('dbx_business_glossary_term' = 'Campaign VIN Record ID');
ALTER TABLE `automotive_ecm`.`aftersales`.`campaign_vin` ALTER COLUMN `aftersales_repair_order_id` SET TAGS ('dbx_business_glossary_term' = 'Aftersales Repair Order Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`campaign_vin` ALTER COLUMN `aftersales_service_appointment_id` SET TAGS ('dbx_business_glossary_term' = 'Aftersales Service Appointment Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`campaign_vin` ALTER COLUMN `service_campaign_id` SET TAGS ('dbx_business_glossary_term' = 'Service Campaign Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`campaign_vin` ALTER COLUMN `vin_registry_id` SET TAGS ('dbx_business_glossary_term' = 'Vin Registry Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`campaign_vin` ALTER COLUMN `compliance_deadline` SET TAGS ('dbx_business_glossary_term' = 'Compliance Deadline');
ALTER TABLE `automotive_ecm`.`aftersales`.`campaign_vin` ALTER COLUMN `compliance_status` SET TAGS ('dbx_business_glossary_term' = 'Compliance Status');
ALTER TABLE `automotive_ecm`.`aftersales`.`campaign_vin` ALTER COLUMN `compliance_status` SET TAGS ('dbx_value_regex' = 'compliant|non_compliant|exempt');
ALTER TABLE `automotive_ecm`.`aftersales`.`campaign_vin` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `automotive_ecm`.`aftersales`.`campaign_vin` ALTER COLUMN `dealer_code` SET TAGS ('dbx_business_glossary_term' = 'Dealer Code');
ALTER TABLE `automotive_ecm`.`aftersales`.`campaign_vin` ALTER COLUMN `is_critical` SET TAGS ('dbx_business_glossary_term' = 'Critical Safety Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`campaign_vin` ALTER COLUMN `labor_rate_usd_per_hour` SET TAGS ('dbx_business_glossary_term' = 'Labor Rate (USD per Hour)');
ALTER TABLE `automotive_ecm`.`aftersales`.`campaign_vin` ALTER COLUMN `labor_time_hours` SET TAGS ('dbx_business_glossary_term' = 'Labor Time (Hours)');
ALTER TABLE `automotive_ecm`.`aftersales`.`campaign_vin` ALTER COLUMN `last_service_date` SET TAGS ('dbx_business_glossary_term' = 'Last Service Date');
ALTER TABLE `automotive_ecm`.`aftersales`.`campaign_vin` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Technician Notes');
ALTER TABLE `automotive_ecm`.`aftersales`.`campaign_vin` ALTER COLUMN `notification_date` SET TAGS ('dbx_business_glossary_term' = 'Notification Date');
ALTER TABLE `automotive_ecm`.`aftersales`.`campaign_vin` ALTER COLUMN `notification_status` SET TAGS ('dbx_business_glossary_term' = 'Campaign Notification Status');
ALTER TABLE `automotive_ecm`.`aftersales`.`campaign_vin` ALTER COLUMN `notification_status` SET TAGS ('dbx_value_regex' = 'not_notified|notified|scheduled|completed|parts_on_order|owner_refused');
ALTER TABLE `automotive_ecm`.`aftersales`.`campaign_vin` ALTER COLUMN `odometer_reading_km` SET TAGS ('dbx_business_glossary_term' = 'Odometer Reading (km)');
ALTER TABLE `automotive_ecm`.`aftersales`.`campaign_vin` ALTER COLUMN `owner_response` SET TAGS ('dbx_business_glossary_term' = 'Owner Response');
ALTER TABLE `automotive_ecm`.`aftersales`.`campaign_vin` ALTER COLUMN `owner_response` SET TAGS ('dbx_value_regex' = 'accepted|refused|pending');
ALTER TABLE `automotive_ecm`.`aftersales`.`campaign_vin` ALTER COLUMN `parts_consumed` SET TAGS ('dbx_business_glossary_term' = 'Parts Consumed');
ALTER TABLE `automotive_ecm`.`aftersales`.`campaign_vin` ALTER COLUMN `recall_number` SET TAGS ('dbx_business_glossary_term' = 'Recall Number');
ALTER TABLE `automotive_ecm`.`aftersales`.`campaign_vin` ALTER COLUMN `recall_type` SET TAGS ('dbx_business_glossary_term' = 'Recall Type');
ALTER TABLE `automotive_ecm`.`aftersales`.`campaign_vin` ALTER COLUMN `recall_type` SET TAGS ('dbx_value_regex' = 'safety|emissions|performance|software');
ALTER TABLE `automotive_ecm`.`aftersales`.`campaign_vin` ALTER COLUMN `remedy_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Remedy Completion Date');
ALTER TABLE `automotive_ecm`.`aftersales`.`campaign_vin` ALTER COLUMN `remedy_status` SET TAGS ('dbx_business_glossary_term' = 'Remedy Status');
ALTER TABLE `automotive_ecm`.`aftersales`.`campaign_vin` ALTER COLUMN `remedy_status` SET TAGS ('dbx_value_regex' = 'pending|in_progress|completed|cancelled');
ALTER TABLE `automotive_ecm`.`aftersales`.`campaign_vin` ALTER COLUMN `service_center_location` SET TAGS ('dbx_business_glossary_term' = 'Service Center Location');
ALTER TABLE `automotive_ecm`.`aftersales`.`campaign_vin` ALTER COLUMN `total_labor_cost_usd` SET TAGS ('dbx_business_glossary_term' = 'Total Labor Cost (USD)');
ALTER TABLE `automotive_ecm`.`aftersales`.`campaign_vin` ALTER COLUMN `total_parts_cost_usd` SET TAGS ('dbx_business_glossary_term' = 'Total Parts Cost (USD)');
ALTER TABLE `automotive_ecm`.`aftersales`.`campaign_vin` ALTER COLUMN `total_remedy_cost_usd` SET TAGS ('dbx_business_glossary_term' = 'Total Remedy Cost (USD)');
ALTER TABLE `automotive_ecm`.`aftersales`.`campaign_vin` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `automotive_ecm`.`aftersales`.`campaign_vin` ALTER COLUMN `warranty_covered` SET TAGS ('dbx_business_glossary_term' = 'Warranty Covered Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` SET TAGS ('dbx_subdomain' = 'service_operations');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `aftersales_service_appointment_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Key for service_appointment');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `cost_center_id` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Customer ID');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `dealership_id` SET TAGS ('dbx_business_glossary_term' = 'Dealer ID');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `service_campaign_id` SET TAGS ('dbx_business_glossary_term' = 'Service Campaign Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `service_center_id` SET TAGS ('dbx_business_glossary_term' = 'Service Center Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `technician_id` SET TAGS ('dbx_business_glossary_term' = 'Technician Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `vehicle_ownership_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Ownership Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `vin_registry_id` SET TAGS ('dbx_business_glossary_term' = 'Vin Registry Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `actual_end_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Actual Service End Timestamp');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `actual_start_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Actual Service Start Timestamp');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `aftersales_service_appointment_status` SET TAGS ('dbx_business_glossary_term' = 'Appointment Status');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `aftersales_service_appointment_status` SET TAGS ('dbx_value_regex' = 'scheduled|confirmed|completed|cancelled|no_show');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `appointment_number` SET TAGS ('dbx_business_glossary_term' = 'Appointment Number (APPT_NO)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `appointment_source` SET TAGS ('dbx_business_glossary_term' = 'Appointment Source');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `appointment_source` SET TAGS ('dbx_value_regex' = 'online|phone|dms|mobile_app');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `bay_number` SET TAGS ('dbx_business_glossary_term' = 'Service Bay Number');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `check_in_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Check‑In Timestamp');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `confirmation_status` SET TAGS ('dbx_business_glossary_term' = 'Confirmation Status');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `confirmation_status` SET TAGS ('dbx_value_regex' = 'pending|confirmed|declined');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (ISO 4217)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `customer_feedback_score` SET TAGS ('dbx_business_glossary_term' = 'Customer Feedback Score');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `estimated_duration_minutes` SET TAGS ('dbx_business_glossary_term' = 'Estimated Duration (Minutes)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `estimated_gross_amount` SET TAGS ('dbx_business_glossary_term' = 'Estimated Gross Amount');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `estimated_net_amount` SET TAGS ('dbx_business_glossary_term' = 'Estimated Net Amount');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `estimated_tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Estimated Tax Amount');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `invoice_number` SET TAGS ('dbx_business_glossary_term' = 'Invoice Number');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `is_first_time_customer` SET TAGS ('dbx_business_glossary_term' = 'First‑Time Customer Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `is_repeat_service` SET TAGS ('dbx_business_glossary_term' = 'Repeat Service Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `labor_time_actual_minutes` SET TAGS ('dbx_business_glossary_term' = 'Actual Labor Time (Minutes)');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `no_show_flag` SET TAGS ('dbx_business_glossary_term' = 'No‑Show Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `parts_actual_amount` SET TAGS ('dbx_business_glossary_term' = 'Actual Parts Amount');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `recall_flag` SET TAGS ('dbx_business_glossary_term' = 'Recall Service Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `required_parts_flag` SET TAGS ('dbx_business_glossary_term' = 'Required Parts Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `scheduled_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Appointment Timestamp');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `service_category` SET TAGS ('dbx_business_glossary_term' = 'Service Category');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `service_notes` SET TAGS ('dbx_business_glossary_term' = 'Service Notes');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `service_priority` SET TAGS ('dbx_business_glossary_term' = 'Service Priority');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `service_priority` SET TAGS ('dbx_value_regex' = 'low|medium|high');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `service_type` SET TAGS ('dbx_business_glossary_term' = 'Service Type');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `service_type` SET TAGS ('dbx_value_regex' = 'maintenance|warranty_repair|recall|pdi|customer_pay');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `total_actual_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Actual Amount');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `transportation_option` SET TAGS ('dbx_business_glossary_term' = 'Transportation Option');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `transportation_option` SET TAGS ('dbx_value_regex' = 'loaner|shuttle|wait|none');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `vehicle_mileage` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Mileage');
ALTER TABLE `automotive_ecm`.`aftersales`.`aftersales_service_appointment` ALTER COLUMN `warranty_flag` SET TAGS ('dbx_business_glossary_term' = 'Warranty Service Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` SET TAGS ('dbx_subdomain' = 'technical_support');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `tsb_id` SET TAGS ('dbx_business_glossary_term' = 'Technical Service Bulletin ID');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `change_id` SET TAGS ('dbx_business_glossary_term' = 'Change Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `defect_record_id` SET TAGS ('dbx_business_glossary_term' = 'Defect Record Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `design_specification_id` SET TAGS ('dbx_business_glossary_term' = 'Design Specification Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `ecu_catalog_id` SET TAGS ('dbx_business_glossary_term' = 'Ecu Catalog Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `fmea_id` SET TAGS ('dbx_business_glossary_term' = 'Fmea Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `fmea_record_id` SET TAGS ('dbx_business_glossary_term' = 'Fmea Record Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `labor_time_standard_id` SET TAGS ('dbx_business_glossary_term' = 'Labor Time Standard Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `model_id` SET TAGS ('dbx_business_glossary_term' = 'Model Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `part_master_id` SET TAGS ('dbx_business_glossary_term' = 'Part Master Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `production_variant_id` SET TAGS ('dbx_business_glossary_term' = 'Production Variant Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `regulatory_requirement_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Requirement Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `service_campaign_id` SET TAGS ('dbx_business_glossary_term' = 'Service Campaign Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `validation_test_id` SET TAGS ('dbx_business_glossary_term' = 'Validation Test Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `affected_model_year_end` SET TAGS ('dbx_business_glossary_term' = 'Affected Model Year End');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `affected_model_year_start` SET TAGS ('dbx_business_glossary_term' = 'Affected Model Year Start');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `affected_vin_end` SET TAGS ('dbx_business_glossary_term' = 'Affected VIN End');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `affected_vin_start` SET TAGS ('dbx_business_glossary_term' = 'Affected VIN Start');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `attachment_url` SET TAGS ('dbx_business_glossary_term' = 'Attachment URL');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `author_department` SET TAGS ('dbx_business_glossary_term' = 'Author Department');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `author_engineer` SET TAGS ('dbx_business_glossary_term' = 'Author Engineer Name');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `author_engineer` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `author_engineer` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `distribution_status` SET TAGS ('dbx_business_glossary_term' = 'Distribution Status');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `distribution_status` SET TAGS ('dbx_value_regex' = 'pending|distributed|completed');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `effective_from` SET TAGS ('dbx_business_glossary_term' = 'Technical Service Bulletin Effective From Date');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `effective_until` SET TAGS ('dbx_business_glossary_term' = 'Technical Service Bulletin Effective Until Date');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `estimated_labor_hours` SET TAGS ('dbx_business_glossary_term' = 'Estimated Labor Hours');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `is_ota_capable` SET TAGS ('dbx_business_glossary_term' = 'OTA Capable Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `issue_date` SET TAGS ('dbx_business_glossary_term' = 'Technical Service Bulletin Issue Date');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `labor_rate_per_hour` SET TAGS ('dbx_business_glossary_term' = 'Labor Rate Per Hour');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Additional Notes');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `part_revision` SET TAGS ('dbx_business_glossary_term' = 'Part Revision');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `regulatory_compliance_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Compliance Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `repair_procedure` SET TAGS ('dbx_business_glossary_term' = 'Repair Procedure');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `review_status` SET TAGS ('dbx_business_glossary_term' = 'Review Status');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `review_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `root_cause` SET TAGS ('dbx_business_glossary_term' = 'Root Cause');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `severity_level` SET TAGS ('dbx_business_glossary_term' = 'Severity Level');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `severity_level` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `superseded_by_tsb_number` SET TAGS ('dbx_business_glossary_term' = 'Superseding TSB Number');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `symptom_description` SET TAGS ('dbx_business_glossary_term' = 'Symptom Description');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'Technical Service Bulletin Title');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `total_estimated_cost` SET TAGS ('dbx_business_glossary_term' = 'Total Estimated Cost');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `tsb_number` SET TAGS ('dbx_business_glossary_term' = 'Technical Service Bulletin Number');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `tsb_status` SET TAGS ('dbx_business_glossary_term' = 'Technical Service Bulletin Status');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `tsb_status` SET TAGS ('dbx_value_regex' = 'draft|active|retired|superseded');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `tsb_type` SET TAGS ('dbx_business_glossary_term' = 'Technical Service Bulletin Type');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `tsb_type` SET TAGS ('dbx_value_regex' = 'safety|recall|service|maintenance|software');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `vehicle_system_affected` SET TAGS ('dbx_business_glossary_term' = 'Vehicle System Affected');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Bulletin Version Number');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb` ALTER COLUMN `warranty_impact_flag` SET TAGS ('dbx_business_glossary_term' = 'Warranty Impact Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`labor_time_standard` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `automotive_ecm`.`aftersales`.`labor_time_standard` SET TAGS ('dbx_subdomain' = 'service_operations');
ALTER TABLE `automotive_ecm`.`aftersales`.`labor_time_standard` ALTER COLUMN `labor_time_standard_id` SET TAGS ('dbx_business_glossary_term' = 'Labor Time Standard ID');
ALTER TABLE `automotive_ecm`.`aftersales`.`labor_time_standard` ALTER COLUMN `model_id` SET TAGS ('dbx_business_glossary_term' = 'Model Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`labor_time_standard` ALTER COLUMN `routing_id` SET TAGS ('dbx_business_glossary_term' = 'Routing Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`labor_time_standard` ALTER COLUMN `vehicle_program_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Program Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`labor_time_standard` ALTER COLUMN `body_style` SET TAGS ('dbx_business_glossary_term' = 'Body Style');
ALTER TABLE `automotive_ecm`.`aftersales`.`labor_time_standard` ALTER COLUMN `compliance_nhtsa_code` SET TAGS ('dbx_business_glossary_term' = 'NHTSA Compliance Code');
ALTER TABLE `automotive_ecm`.`aftersales`.`labor_time_standard` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `automotive_ecm`.`aftersales`.`labor_time_standard` ALTER COLUMN `effective_from` SET TAGS ('dbx_business_glossary_term' = 'Effective From Date');
ALTER TABLE `automotive_ecm`.`aftersales`.`labor_time_standard` ALTER COLUMN `effective_until` SET TAGS ('dbx_business_glossary_term' = 'Effective Until Date');
ALTER TABLE `automotive_ecm`.`aftersales`.`labor_time_standard` ALTER COLUMN `is_mandatory` SET TAGS ('dbx_business_glossary_term' = 'Mandatory Operation Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`labor_time_standard` ALTER COLUMN `labor_category` SET TAGS ('dbx_business_glossary_term' = 'Labor Category');
ALTER TABLE `automotive_ecm`.`aftersales`.`labor_time_standard` ALTER COLUMN `labor_category` SET TAGS ('dbx_value_regex' = 'maintenance|repair|diagnostic|installation');
ALTER TABLE `automotive_ecm`.`aftersales`.`labor_time_standard` ALTER COLUMN `labor_time_standard_status` SET TAGS ('dbx_business_glossary_term' = 'Labor Standard Status');
ALTER TABLE `automotive_ecm`.`aftersales`.`labor_time_standard` ALTER COLUMN `labor_time_standard_status` SET TAGS ('dbx_value_regex' = 'active|inactive|deprecated');
ALTER TABLE `automotive_ecm`.`aftersales`.`labor_time_standard` ALTER COLUMN `labor_type` SET TAGS ('dbx_business_glossary_term' = 'Labor Type');
ALTER TABLE `automotive_ecm`.`aftersales`.`labor_time_standard` ALTER COLUMN `labor_type` SET TAGS ('dbx_value_regex' = 'warranty|customer_pay|recall');
ALTER TABLE `automotive_ecm`.`aftersales`.`labor_time_standard` ALTER COLUMN `last_revision_date` SET TAGS ('dbx_business_glossary_term' = 'Last Revision Date');
ALTER TABLE `automotive_ecm`.`aftersales`.`labor_time_standard` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `automotive_ecm`.`aftersales`.`labor_time_standard` ALTER COLUMN `oem_part_number` SET TAGS ('dbx_business_glossary_term' = 'OEM Part Number');
ALTER TABLE `automotive_ecm`.`aftersales`.`labor_time_standard` ALTER COLUMN `operation_code` SET TAGS ('dbx_business_glossary_term' = 'Operation Code');
ALTER TABLE `automotive_ecm`.`aftersales`.`labor_time_standard` ALTER COLUMN `operation_description` SET TAGS ('dbx_business_glossary_term' = 'Operation Description');
ALTER TABLE `automotive_ecm`.`aftersales`.`labor_time_standard` ALTER COLUMN `region` SET TAGS ('dbx_business_glossary_term' = 'Geographic Region');
ALTER TABLE `automotive_ecm`.`aftersales`.`labor_time_standard` ALTER COLUMN `region` SET TAGS ('dbx_value_regex' = 'NA|EU|APAC|LATAM|MEA');
ALTER TABLE `automotive_ecm`.`aftersales`.`labor_time_standard` ALTER COLUMN `revision_number` SET TAGS ('dbx_business_glossary_term' = 'Revision Number');
ALTER TABLE `automotive_ecm`.`aftersales`.`labor_time_standard` ALTER COLUMN `skill_level` SET TAGS ('dbx_business_glossary_term' = 'Skill Level Required');
ALTER TABLE `automotive_ecm`.`aftersales`.`labor_time_standard` ALTER COLUMN `skill_level` SET TAGS ('dbx_value_regex' = 'L1|L2|L3|L4|L5|L6');
ALTER TABLE `automotive_ecm`.`aftersales`.`labor_time_standard` ALTER COLUMN `source` SET TAGS ('dbx_business_glossary_term' = 'Source of Labor Standard');
ALTER TABLE `automotive_ecm`.`aftersales`.`labor_time_standard` ALTER COLUMN `source` SET TAGS ('dbx_value_regex' = 'OEM|MOTOR|Alldata|Other');
ALTER TABLE `automotive_ecm`.`aftersales`.`labor_time_standard` ALTER COLUMN `special_tool_required` SET TAGS ('dbx_business_glossary_term' = 'Special Tool Required Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`labor_time_standard` ALTER COLUMN `standard_hours` SET TAGS ('dbx_business_glossary_term' = 'Standard Labor Hours');
ALTER TABLE `automotive_ecm`.`aftersales`.`labor_time_standard` ALTER COLUMN `tool_code` SET TAGS ('dbx_business_glossary_term' = 'Tool Code');
ALTER TABLE `automotive_ecm`.`aftersales`.`labor_time_standard` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `automotive_ecm`.`aftersales`.`labor_time_standard` ALTER COLUMN `vehicle_model_year_end` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Model Year End');
ALTER TABLE `automotive_ecm`.`aftersales`.`labor_time_standard` ALTER COLUMN `vehicle_model_year_start` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Model Year Start');
ALTER TABLE `automotive_ecm`.`aftersales`.`labor_time_standard` ALTER COLUMN `vehicle_segment` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Segment');
ALTER TABLE `automotive_ecm`.`aftersales`.`labor_time_standard` ALTER COLUMN `vehicle_segment` SET TAGS ('dbx_value_regex' = 'sedan|SUV|truck|van|crossover|commercial');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_part` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_part` SET TAGS ('dbx_subdomain' = 'parts_distribution');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_part` ALTER COLUMN `service_part_id` SET TAGS ('dbx_business_glossary_term' = 'Service Part ID');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_part` ALTER COLUMN `inbound_part_id` SET TAGS ('dbx_business_glossary_term' = 'Inbound Part Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_part` ALTER COLUMN `part_master_id` SET TAGS ('dbx_business_glossary_term' = 'Part Master Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_part` ALTER COLUMN `compliance_certification` SET TAGS ('dbx_business_glossary_term' = 'Compliance Certification (CCERT)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_part` ALTER COLUMN `core_charge` SET TAGS ('dbx_business_glossary_term' = 'Core Charge (CC)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_part` ALTER COLUMN `country_of_origin` SET TAGS ('dbx_business_glossary_term' = 'Country of Origin (COO)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_part` ALTER COLUMN `country_of_origin` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_part` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp (CT)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_part` ALTER COLUMN `dealer_net_price` SET TAGS ('dbx_business_glossary_term' = 'Dealer Net Price (DNP)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_part` ALTER COLUMN `effective_end_date` SET TAGS ('dbx_business_glossary_term' = 'Effective End Date (EED)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_part` ALTER COLUMN `effective_start_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Start Date (ESD)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_part` ALTER COLUMN `epa_hazardous_material_code` SET TAGS ('dbx_business_glossary_term' = 'EPA Hazardous Material Code (EPA_HAZ)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_part` ALTER COLUMN `hazardous_classification` SET TAGS ('dbx_business_glossary_term' = 'Hazardous Classification (HC)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_part` ALTER COLUMN `hazmat_flag` SET TAGS ('dbx_business_glossary_term' = 'Hazardous Material Flag (HM)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_part` ALTER COLUMN `height_mm` SET TAGS ('dbx_business_glossary_term' = 'Height (MM)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_part` ALTER COLUMN `inventory_status` SET TAGS ('dbx_business_glossary_term' = 'Inventory Status (INV_ST)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_part` ALTER COLUMN `inventory_status` SET TAGS ('dbx_value_regex' = 'in_stock|out_of_stock|backordered|discontinued');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_part` ALTER COLUMN `last_used_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Used Timestamp (LUT)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_part` ALTER COLUMN `length_mm` SET TAGS ('dbx_business_glossary_term' = 'Length (MM)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_part` ALTER COLUMN `lifecycle_status` SET TAGS ('dbx_business_glossary_term' = 'Lifecycle Status (LS)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_part` ALTER COLUMN `lifecycle_status` SET TAGS ('dbx_value_regex' = 'active|superseded|discontinued|obsolete');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_part` ALTER COLUMN `list_price` SET TAGS ('dbx_business_glossary_term' = 'Standard List Price (SLP)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_part` ALTER COLUMN `manufacturer_name` SET TAGS ('dbx_business_glossary_term' = 'Manufacturer Name (MFR)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_part` ALTER COLUMN `part_category` SET TAGS ('dbx_business_glossary_term' = 'Part Category (CAT)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_part` ALTER COLUMN `part_category` SET TAGS ('dbx_value_regex' = 'mechanical|electrical|body|consumable|accessory');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_part` ALTER COLUMN `part_name` SET TAGS ('dbx_business_glossary_term' = 'Part Name (DES)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_part` ALTER COLUMN `part_number` SET TAGS ('dbx_business_glossary_term' = 'Part Number (OEM)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_part` ALTER COLUMN `part_revision` SET TAGS ('dbx_business_glossary_term' = 'Part Revision (REV)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_part` ALTER COLUMN `service_part_description` SET TAGS ('dbx_business_glossary_term' = 'Part Description (DESC)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_part` ALTER COLUMN `superseded_by_part_number` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Part Number (SUP)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_part` ALTER COLUMN `unit_of_measure` SET TAGS ('dbx_business_glossary_term' = 'Unit of Measure (UOM)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_part` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp (UT)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_part` ALTER COLUMN `warranty_eligible_flag` SET TAGS ('dbx_business_glossary_term' = 'Warranty Eligible Flag (WEF)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_part` ALTER COLUMN `warranty_period_months` SET TAGS ('dbx_business_glossary_term' = 'Warranty Period (Months)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_part` ALTER COLUMN `weight_kg` SET TAGS ('dbx_business_glossary_term' = 'Weight (KG)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_part` ALTER COLUMN `width_mm` SET TAGS ('dbx_business_glossary_term' = 'Width (MM)');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order` SET TAGS ('dbx_subdomain' = 'parts_distribution');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order` ALTER COLUMN `parts_order_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Key for parts_order');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order` ALTER COLUMN `aftersales_repair_order_id` SET TAGS ('dbx_business_glossary_term' = 'Aftersales Repair Order Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order` ALTER COLUMN `cost_center_id` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order` ALTER COLUMN `storage_location_id` SET TAGS ('dbx_business_glossary_term' = 'Fulfillment Storage Location Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order` ALTER COLUMN `gl_account_id` SET TAGS ('dbx_business_glossary_term' = 'Gl Account Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order` ALTER COLUMN `dealership_id` SET TAGS ('dbx_business_glossary_term' = 'Dealer Identifier (DEALER_ID)');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order` ALTER COLUMN `profit_center_id` SET TAGS ('dbx_business_glossary_term' = 'Profit Center Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order` ALTER COLUMN `purchase_order_id` SET TAGS ('dbx_business_glossary_term' = 'Supply Purchase Order Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order` ALTER COLUMN `service_center_id` SET TAGS ('dbx_business_glossary_term' = 'Service Center Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order` ALTER COLUMN `shipment_id` SET TAGS ('dbx_business_glossary_term' = 'Shipment Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order` ALTER COLUMN `actual_delivery_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Delivery Date (ACT_DELIV_DT)');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order` ALTER COLUMN `backorder_flag` SET TAGS ('dbx_business_glossary_term' = 'Backorder Flag (BACKORDER_FLG)');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp (REC_CRE_TS)');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (CURR_CD)');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order` ALTER COLUMN `discount_amount` SET TAGS ('dbx_business_glossary_term' = 'Discount Amount (DISC_AMT)');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order` ALTER COLUMN `freight_cost` SET TAGS ('dbx_business_glossary_term' = 'Freight Cost (FRGT_COST)');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order` ALTER COLUMN `freight_terms` SET TAGS ('dbx_business_glossary_term' = 'Freight Terms (FRGT_TRMS)');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order` ALTER COLUMN `freight_terms` SET TAGS ('dbx_value_regex' = 'prepaid|collect|third_party');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order` ALTER COLUMN `net_total` SET TAGS ('dbx_business_glossary_term' = 'Net Order Total (NET_ORD_TOT)');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order` ALTER COLUMN `order_number` SET TAGS ('dbx_business_glossary_term' = 'Order Number (ORD_NUM)');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order` ALTER COLUMN `order_status` SET TAGS ('dbx_business_glossary_term' = 'Order Status (ORD_STS)');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order` ALTER COLUMN `order_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Order Timestamp (ORD_TS)');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order` ALTER COLUMN `order_type` SET TAGS ('dbx_business_glossary_term' = 'Order Type (ORD_TYPE)');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order` ALTER COLUMN `order_type` SET TAGS ('dbx_value_regex' = 'stock|emergency|campaign|special');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order` ALTER COLUMN `payment_terms` SET TAGS ('dbx_business_glossary_term' = 'Payment Terms (PAY_TERM)');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order` ALTER COLUMN `payment_terms` SET TAGS ('dbx_value_regex' = 'net30|net45|net60|cod');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order` ALTER COLUMN `priority_flag` SET TAGS ('dbx_business_glossary_term' = 'Priority Flag (PRIORITY_FLG)');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order` ALTER COLUMN `requested_delivery_date` SET TAGS ('dbx_business_glossary_term' = 'Requested Delivery Date (REQ_DELIV_DT)');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order` ALTER COLUMN `shipping_method` SET TAGS ('dbx_business_glossary_term' = 'Shipping Method (SHIP_MTHD)');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order` ALTER COLUMN `shipping_method` SET TAGS ('dbx_value_regex' = 'ground|air|sea|rail');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order` ALTER COLUMN `special_instructions` SET TAGS ('dbx_business_glossary_term' = 'Special Instructions (SPEC_INSTR)');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order` ALTER COLUMN `tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Tax Amount (TAX_AMT)');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order` ALTER COLUMN `total_order_value` SET TAGS ('dbx_business_glossary_term' = 'Total Order Value (TOT_ORD_VAL)');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp (REC_UPD_TS)');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order_line` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order_line` SET TAGS ('dbx_subdomain' = 'parts_distribution');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order_line` ALTER COLUMN `parts_order_line_id` SET TAGS ('dbx_business_glossary_term' = 'Parts Order Line Identifier');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order_line` ALTER COLUMN `parts_order_id` SET TAGS ('dbx_business_glossary_term' = 'Parts Order Identifier');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order_line` ALTER COLUMN `service_part_id` SET TAGS ('dbx_business_glossary_term' = 'Part Identifier');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order_line` ALTER COLUMN `stock_balance_id` SET TAGS ('dbx_business_glossary_term' = 'Stock Balance Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order_line` ALTER COLUMN `backorder_quantity` SET TAGS ('dbx_business_glossary_term' = 'Backorder Quantity');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order_line` ALTER COLUMN `confirmed_quantity` SET TAGS ('dbx_business_glossary_term' = 'Confirmed Quantity');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order_line` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order_line` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (ISO 4217)');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order_line` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = 'USD|EUR|JPY|CAD|GBP|AUD');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order_line` ALTER COLUMN `discount_amount` SET TAGS ('dbx_business_glossary_term' = 'Discount Amount');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order_line` ALTER COLUMN `estimated_availability_date` SET TAGS ('dbx_business_glossary_term' = 'Estimated Availability Date');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order_line` ALTER COLUMN `line_sequence` SET TAGS ('dbx_business_glossary_term' = 'Line Sequence Number');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order_line` ALTER COLUMN `line_status` SET TAGS ('dbx_business_glossary_term' = 'Line Status');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order_line` ALTER COLUMN `line_status` SET TAGS ('dbx_value_regex' = 'open|confirmed|shipped|backordered|canceled');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order_line` ALTER COLUMN `line_total` SET TAGS ('dbx_business_glossary_term' = 'Line Total Amount');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order_line` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Line Notes');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order_line` ALTER COLUMN `ordered_quantity` SET TAGS ('dbx_business_glossary_term' = 'Ordered Quantity');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order_line` ALTER COLUMN `shipped_quantity` SET TAGS ('dbx_business_glossary_term' = 'Shipped Quantity');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order_line` ALTER COLUMN `substitution_part_number` SET TAGS ('dbx_business_glossary_term' = 'Substitution Part Number');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order_line` ALTER COLUMN `tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Tax Amount');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order_line` ALTER COLUMN `unit_price` SET TAGS ('dbx_business_glossary_term' = 'Unit Price (USD)');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order_line` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_order_line` ALTER COLUMN `warranty_flag` SET TAGS ('dbx_business_glossary_term' = 'Warranty Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` SET TAGS ('dbx_subdomain' = 'warranty_management');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `service_contract_id` SET TAGS ('dbx_business_glossary_term' = 'Service Contract ID');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `cost_center_id` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `gl_account_id` SET TAGS ('dbx_business_glossary_term' = 'Gl Account Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Customer ID');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `dealership_id` SET TAGS ('dbx_business_glossary_term' = 'Selling Dealer ID');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `profit_center_id` SET TAGS ('dbx_business_glossary_term' = 'Profit Center Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `regulatory_requirement_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Requirement Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `service_center_id` SET TAGS ('dbx_business_glossary_term' = 'Service Center ID');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `tertiary_service_transfer_to_dealer_dealership_id` SET TAGS ('dbx_business_glossary_term' = 'Transfer To Dealer ID');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `vehicle_program_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Program Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `vin_registry_id` SET TAGS ('dbx_business_glossary_term' = 'Vin Registry Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `warranty_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Warranty Policy Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `administrator_code` SET TAGS ('dbx_business_glossary_term' = 'Administrator ID');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `cancellation_date` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Date');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `cancellation_reason` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Reason');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `claim_count` SET TAGS ('dbx_business_glossary_term' = 'Claim Count');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `contract_description` SET TAGS ('dbx_business_glossary_term' = 'Contract Description');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `contract_type` SET TAGS ('dbx_business_glossary_term' = 'Contract Type');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `contract_type` SET TAGS ('dbx_value_regex' = 'powertrain|comprehensive|maintenance|tire_and_wheel|roadside_assistance|extended_warranty');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `coverage_mileage_limit` SET TAGS ('dbx_business_glossary_term' = 'Coverage Mileage Limit');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Deductible Amount');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `discount_amount` SET TAGS ('dbx_business_glossary_term' = 'Discount Amount');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `effective_from` SET TAGS ('dbx_business_glossary_term' = 'Coverage Start Date');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `effective_until` SET TAGS ('dbx_business_glossary_term' = 'Coverage End Date');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `is_refundable` SET TAGS ('dbx_business_glossary_term' = 'Refundable Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `is_transferable` SET TAGS ('dbx_business_glossary_term' = 'Transferable Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `last_claim_date` SET TAGS ('dbx_business_glossary_term' = 'Last Claim Date');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `mileage_used` SET TAGS ('dbx_business_glossary_term' = 'Mileage Used');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `net_contract_value` SET TAGS ('dbx_business_glossary_term' = 'Net Contract Value');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'credit_card|debit_card|bank_transfer|cash|check');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `payment_term_code` SET TAGS ('dbx_business_glossary_term' = 'Payment Term Code');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `payment_term_code` SET TAGS ('dbx_value_regex' = 'net30|net45|net60|cash|credit');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `regulatory_compliance_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Compliance Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `renewal_date` SET TAGS ('dbx_business_glossary_term' = 'Renewal Date');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `renewal_option` SET TAGS ('dbx_business_glossary_term' = 'Renewal Option');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `renewal_option` SET TAGS ('dbx_value_regex' = 'auto|manual|none');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `service_contract_status` SET TAGS ('dbx_business_glossary_term' = 'Contract Status');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `service_contract_status` SET TAGS ('dbx_value_regex' = 'active|expired|cancelled|transferred|pending|suspended');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Tax Amount');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `total_contract_value` SET TAGS ('dbx_business_glossary_term' = 'Total Contract Value');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `transfer_date` SET TAGS ('dbx_business_glossary_term' = 'Transfer Date');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract` ALTER COLUMN `warranty_flag` SET TAGS ('dbx_business_glossary_term' = 'Warranty Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` SET TAGS ('dbx_subdomain' = 'warranty_management');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `service_contract_claim_id` SET TAGS ('dbx_business_glossary_term' = 'Service Contract Claim ID');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `aftersales_repair_order_id` SET TAGS ('dbx_business_glossary_term' = 'Repair Order ID');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `cost_center_id` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `gl_account_id` SET TAGS ('dbx_business_glossary_term' = 'Gl Account Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Customer ID');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `dealership_id` SET TAGS ('dbx_business_glossary_term' = 'Dealer ID');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `profit_center_id` SET TAGS ('dbx_business_glossary_term' = 'Profit Center Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `service_center_id` SET TAGS ('dbx_business_glossary_term' = 'Service Center ID');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `service_contract_id` SET TAGS ('dbx_business_glossary_term' = 'Service Contract ID');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `vehicle_program_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Program Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `vin_registry_id` SET TAGS ('dbx_business_glossary_term' = 'Vin Registry Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `adjusted_amount` SET TAGS ('dbx_business_glossary_term' = 'Adjusted Amount');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `approved_amount` SET TAGS ('dbx_business_glossary_term' = 'Approved Claim Amount');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `claim_adjusted_flag` SET TAGS ('dbx_business_glossary_term' = 'Claim Adjusted Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `claim_adjustment_reason` SET TAGS ('dbx_business_glossary_term' = 'Claim Adjustment Reason');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `claim_category` SET TAGS ('dbx_business_glossary_term' = 'Claim Category');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `claim_category` SET TAGS ('dbx_value_regex' = 'repair|maintenance|upgrade|other');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `claim_closure_date` SET TAGS ('dbx_business_glossary_term' = 'Claim Closure Date');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `claim_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Claim Record Created Timestamp');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `claim_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Claim Effective Date');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `claim_line_item_count` SET TAGS ('dbx_business_glossary_term' = 'Claim Line Item Count');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `claim_number` SET TAGS ('dbx_business_glossary_term' = 'Claim Number');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `claim_original_amount` SET TAGS ('dbx_business_glossary_term' = 'Original Claim Amount');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `claim_payment_method` SET TAGS ('dbx_business_glossary_term' = 'Claim Payment Method');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `claim_payment_method` SET TAGS ('dbx_value_regex' = 'check|credit|direct_deposit');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `claim_payment_status` SET TAGS ('dbx_business_glossary_term' = 'Claim Payment Status');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `claim_payment_status` SET TAGS ('dbx_value_regex' = 'pending|completed|failed');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `claim_payment_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Claim Payment Timestamp');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `claim_priority` SET TAGS ('dbx_business_glossary_term' = 'Claim Priority');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `claim_priority` SET TAGS ('dbx_value_regex' = 'high|medium|low');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `claim_review_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Claim Review Timestamp');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `claim_reviewed_by` SET TAGS ('dbx_business_glossary_term' = 'Claim Reviewed By');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `claim_reviewed_by` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `claim_reviewed_by` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `claim_status` SET TAGS ('dbx_business_glossary_term' = 'Claim Status');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `claim_status` SET TAGS ('dbx_value_regex' = 'pending|approved|denied|paid');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `claim_submission_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Claim Submission Timestamp');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `claim_submitted_by` SET TAGS ('dbx_business_glossary_term' = 'Claim Submitted By');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `claim_submitted_by` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `claim_submitted_by` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `claim_type` SET TAGS ('dbx_business_glossary_term' = 'Claim Type');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `claim_type` SET TAGS ('dbx_value_regex' = 'extended_service_contract|voluntary_service_agreement');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `claim_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Claim Record Updated Timestamp');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `claimed_labor_amount` SET TAGS ('dbx_business_glossary_term' = 'Claimed Labor Amount');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `claimed_parts_amount` SET TAGS ('dbx_business_glossary_term' = 'Claimed Parts Amount');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `covered_repair_description` SET TAGS ('dbx_business_glossary_term' = 'Covered Repair Description');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (ISO 4217)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Deductible Amount');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `denial_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Denial Reason Code');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `labor_rate_per_hour` SET TAGS ('dbx_business_glossary_term' = 'Labor Rate Per Hour');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Claim Notes');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_contract_claim` ALTER COLUMN `parts_tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Parts Tax Amount');
ALTER TABLE `automotive_ecm`.`aftersales`.`goodwill_adjustment` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `automotive_ecm`.`aftersales`.`goodwill_adjustment` SET TAGS ('dbx_subdomain' = 'warranty_management');
ALTER TABLE `automotive_ecm`.`aftersales`.`goodwill_adjustment` ALTER COLUMN `goodwill_adjustment_id` SET TAGS ('dbx_business_glossary_term' = 'Goodwill Adjustment ID');
ALTER TABLE `automotive_ecm`.`aftersales`.`goodwill_adjustment` ALTER COLUMN `aftersales_repair_order_id` SET TAGS ('dbx_business_glossary_term' = 'Repair Order ID');
ALTER TABLE `automotive_ecm`.`aftersales`.`goodwill_adjustment` ALTER COLUMN `aftersales_warranty_claim_id` SET TAGS ('dbx_business_glossary_term' = 'Aftersales Warranty Claim Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`goodwill_adjustment` ALTER COLUMN `fiscal_period_id` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Period Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`goodwill_adjustment` ALTER COLUMN `gl_account_id` SET TAGS ('dbx_business_glossary_term' = 'Gl Account Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`goodwill_adjustment` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Customer ID');
ALTER TABLE `automotive_ecm`.`aftersales`.`goodwill_adjustment` ALTER COLUMN `dealership_id` SET TAGS ('dbx_business_glossary_term' = 'Dealer ID');
ALTER TABLE `automotive_ecm`.`aftersales`.`goodwill_adjustment` ALTER COLUMN `profit_center_id` SET TAGS ('dbx_business_glossary_term' = 'Profit Center Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`goodwill_adjustment` ALTER COLUMN `service_campaign_id` SET TAGS ('dbx_business_glossary_term' = 'Campaign ID');
ALTER TABLE `automotive_ecm`.`aftersales`.`goodwill_adjustment` ALTER COLUMN `vehicle_program_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Program Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`goodwill_adjustment` ALTER COLUMN `vin_registry_id` SET TAGS ('dbx_business_glossary_term' = 'Vin Registry Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`goodwill_adjustment` ALTER COLUMN `adjustment_number` SET TAGS ('dbx_business_glossary_term' = 'Goodwill Adjustment Number');
ALTER TABLE `automotive_ecm`.`aftersales`.`goodwill_adjustment` ALTER COLUMN `adjustment_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Timestamp');
ALTER TABLE `automotive_ecm`.`aftersales`.`goodwill_adjustment` ALTER COLUMN `approval_authority_level` SET TAGS ('dbx_business_glossary_term' = 'Approval Authority Level');
ALTER TABLE `automotive_ecm`.`aftersales`.`goodwill_adjustment` ALTER COLUMN `approval_authority_level` SET TAGS ('dbx_value_regex' = 'supervisor|manager|director|vice_president|executive');
ALTER TABLE `automotive_ecm`.`aftersales`.`goodwill_adjustment` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');
ALTER TABLE `automotive_ecm`.`aftersales`.`goodwill_adjustment` ALTER COLUMN `approved_amount` SET TAGS ('dbx_business_glossary_term' = 'Approved Goodwill Amount');
ALTER TABLE `automotive_ecm`.`aftersales`.`goodwill_adjustment` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `automotive_ecm`.`aftersales`.`goodwill_adjustment` ALTER COLUMN `business_justification` SET TAGS ('dbx_business_glossary_term' = 'Business Justification');
ALTER TABLE `automotive_ecm`.`aftersales`.`goodwill_adjustment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `automotive_ecm`.`aftersales`.`goodwill_adjustment` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (ISO 4217)');
ALTER TABLE `automotive_ecm`.`aftersales`.`goodwill_adjustment` ALTER COLUMN `goodwill_adjustment_status` SET TAGS ('dbx_business_glossary_term' = 'Goodwill Adjustment Status');
ALTER TABLE `automotive_ecm`.`aftersales`.`goodwill_adjustment` ALTER COLUMN `goodwill_adjustment_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected|closed|cancelled');
ALTER TABLE `automotive_ecm`.`aftersales`.`goodwill_adjustment` ALTER COLUMN `goodwill_type` SET TAGS ('dbx_business_glossary_term' = 'Goodwill Type');
ALTER TABLE `automotive_ecm`.`aftersales`.`goodwill_adjustment` ALTER COLUMN `goodwill_type` SET TAGS ('dbx_value_regex' = 'full_coverage|partial_coverage|parts_only|labor_only|cash_reimbursement');
ALTER TABLE `automotive_ecm`.`aftersales`.`goodwill_adjustment` ALTER COLUMN `labor_cost` SET TAGS ('dbx_business_glossary_term' = 'Labor Cost');
ALTER TABLE `automotive_ecm`.`aftersales`.`goodwill_adjustment` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `automotive_ecm`.`aftersales`.`goodwill_adjustment` ALTER COLUMN `nps_impact_flag` SET TAGS ('dbx_business_glossary_term' = 'NPS Impact Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`goodwill_adjustment` ALTER COLUMN `nps_score_change` SET TAGS ('dbx_business_glossary_term' = 'NPS Score Change');
ALTER TABLE `automotive_ecm`.`aftersales`.`goodwill_adjustment` ALTER COLUMN `part_cost` SET TAGS ('dbx_business_glossary_term' = 'Part Cost');
ALTER TABLE `automotive_ecm`.`aftersales`.`goodwill_adjustment` ALTER COLUMN `source_system` SET TAGS ('dbx_business_glossary_term' = 'Source System');
ALTER TABLE `automotive_ecm`.`aftersales`.`goodwill_adjustment` ALTER COLUMN `source_system` SET TAGS ('dbx_value_regex' = 'SAP_S4HANA|CDK_DMS|Other');
ALTER TABLE `automotive_ecm`.`aftersales`.`goodwill_adjustment` ALTER COLUMN `tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Tax Amount');
ALTER TABLE `automotive_ecm`.`aftersales`.`goodwill_adjustment` ALTER COLUMN `total_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Goodwill Amount');
ALTER TABLE `automotive_ecm`.`aftersales`.`goodwill_adjustment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `automotive_ecm`.`aftersales`.`goodwill_adjustment` ALTER COLUMN `warranty_flag` SET TAGS ('dbx_business_glossary_term' = 'Warranty Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` SET TAGS ('dbx_subdomain' = 'service_operations');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `service_center_id` SET TAGS ('dbx_business_glossary_term' = 'Service Center Identifier');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `company_code_id` SET TAGS ('dbx_business_glossary_term' = 'Company Code Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `dealership_id` SET TAGS ('dbx_business_glossary_term' = 'Dealer Group Identifier');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `jurisdiction_id` SET TAGS ('dbx_business_glossary_term' = 'Jurisdiction Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `plant_id` SET TAGS ('dbx_business_glossary_term' = 'Plant Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `adas_calibration_authorized` SET TAGS ('dbx_business_glossary_term' = 'ADAS Calibration Service Authorization Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `address_line1` SET TAGS ('dbx_business_glossary_term' = 'Address Line 1');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `address_line1` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `address_line1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `address_line2` SET TAGS ('dbx_business_glossary_term' = 'Address Line 2');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `address_line2` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `address_line2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `authorization_level` SET TAGS ('dbx_business_glossary_term' = 'Service Authorization Level');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `authorization_level` SET TAGS ('dbx_value_regex' = 'warranty|recall|collision|ev_certified|adas_calibration|none');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `average_service_time_minutes` SET TAGS ('dbx_business_glossary_term' = 'Average Service Time per Order (Minutes)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `city` SET TAGS ('dbx_business_glossary_term' = 'City');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `city` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `collision_authorized` SET TAGS ('dbx_business_glossary_term' = 'Certified Collision Service Authorization Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `country` SET TAGS ('dbx_business_glossary_term' = 'Country Code (ISO 3166‑1 alpha‑3)');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `country` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `country` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `dsk_instance_code` SET TAGS ('dbx_business_glossary_term' = 'CDK Global DMS Instance Identifier');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `effective_end_date` SET TAGS ('dbx_business_glossary_term' = 'Effective End Date');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `effective_start_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Start Date');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `ev_certified` SET TAGS ('dbx_business_glossary_term' = 'Electric Vehicle Service Certification Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `iatf_certified` SET TAGS ('dbx_business_glossary_term' = 'IATF 16949 Certification Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `is_primary_center` SET TAGS ('dbx_business_glossary_term' = 'Primary Service Center Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `iso9001_certified` SET TAGS ('dbx_business_glossary_term' = 'ISO 9001 Certification Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `last_audit_date` SET TAGS ('dbx_business_glossary_term' = 'Date of Last Regulatory Audit');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `latitude` SET TAGS ('dbx_business_glossary_term' = 'Geographic Latitude');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `latitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `latitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `loaner_fleet_size` SET TAGS ('dbx_business_glossary_term' = 'Loaner Vehicle Fleet Size');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `longitude` SET TAGS ('dbx_business_glossary_term' = 'Geographic Longitude');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `longitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `longitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `market` SET TAGS ('dbx_business_glossary_term' = 'Service Center Market Segment');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `network_status` SET TAGS ('dbx_business_glossary_term' = 'Service Center Network Status');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `network_status` SET TAGS ('dbx_value_regex' = 'active|suspended|terminated');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Additional Notes');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `operating_hours` SET TAGS ('dbx_business_glossary_term' = 'Operating Hours Schedule');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `postal_code` SET TAGS ('dbx_business_glossary_term' = 'Postal Code');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `postal_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{3,10}$');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `postal_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `recall_authorized` SET TAGS ('dbx_business_glossary_term' = 'Recall Service Authorization Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `region` SET TAGS ('dbx_business_glossary_term' = 'Service Center Geographic Region');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `regulatory_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Compliance Status');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `regulatory_status` SET TAGS ('dbx_value_regex' = 'compliant|non_compliant|under_review');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `service_bay_count` SET TAGS ('dbx_business_glossary_term' = 'Number of Service Bays');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `service_center_code` SET TAGS ('dbx_business_glossary_term' = 'Service Center Code');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `service_center_name` SET TAGS ('dbx_business_glossary_term' = 'Service Center Name');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `service_center_type` SET TAGS ('dbx_business_glossary_term' = 'Service Center Type');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `service_center_type` SET TAGS ('dbx_value_regex' = 'dealership|independent|authorized|factory');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `service_orders_processed` SET TAGS ('dbx_business_glossary_term' = 'Total Service Orders Processed');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `state` SET TAGS ('dbx_business_glossary_term' = 'State/Province');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `state` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `state` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `state` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `technician_headcount` SET TAGS ('dbx_business_glossary_term' = 'Technician Headcount');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `warranty_authorized` SET TAGS ('dbx_business_glossary_term' = 'Warranty Service Authorization Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`service_center` ALTER COLUMN `warranty_claims_processed` SET TAGS ('dbx_business_glossary_term' = 'Total Warranty Claims Processed');
ALTER TABLE `automotive_ecm`.`aftersales`.`technician` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `automotive_ecm`.`aftersales`.`technician` SET TAGS ('dbx_subdomain' = 'service_operations');
ALTER TABLE `automotive_ecm`.`aftersales`.`technician` ALTER COLUMN `technician_id` SET TAGS ('dbx_business_glossary_term' = 'Technician ID');
ALTER TABLE `automotive_ecm`.`aftersales`.`technician` ALTER COLUMN `service_center_id` SET TAGS ('dbx_business_glossary_term' = 'Service Center ID (SC_ID)');
ALTER TABLE `automotive_ecm`.`aftersales`.`technician` ALTER COLUMN `availability_status` SET TAGS ('dbx_business_glossary_term' = 'Availability Status (AVAIL_STATUS)');
ALTER TABLE `automotive_ecm`.`aftersales`.`technician` ALTER COLUMN `availability_status` SET TAGS ('dbx_value_regex' = 'available|unavailable|on_leave|scheduled');
ALTER TABLE `automotive_ecm`.`aftersales`.`technician` ALTER COLUMN `certification_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Certification Expiry Date (CERT_EXPIRY)');
ALTER TABLE `automotive_ecm`.`aftersales`.`technician` ALTER COLUMN `certification_level` SET TAGS ('dbx_business_glossary_term' = 'Certification Level (CERT_LEVEL)');
ALTER TABLE `automotive_ecm`.`aftersales`.`technician` ALTER COLUMN `certification_level` SET TAGS ('dbx_value_regex' = 'level1|level2|master|expert');
ALTER TABLE `automotive_ecm`.`aftersales`.`technician` ALTER COLUMN `certification_type` SET TAGS ('dbx_business_glossary_term' = 'Certification Type (CERT_TYPE)');
ALTER TABLE `automotive_ecm`.`aftersales`.`technician` ALTER COLUMN `certification_type` SET TAGS ('dbx_value_regex' = 'ASE|OEM|EV|ADAS|HV|GENERAL');
ALTER TABLE `automotive_ecm`.`aftersales`.`technician` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp (CREATED_TS)');
ALTER TABLE `automotive_ecm`.`aftersales`.`technician` ALTER COLUMN `current_active_ro_count` SET TAGS ('dbx_business_glossary_term' = 'Current Active Repair Order Count (ACTIVE_RO_COUNT)');
ALTER TABLE `automotive_ecm`.`aftersales`.`technician` ALTER COLUMN `email_address` SET TAGS ('dbx_business_glossary_term' = 'Technician Email Address (TECH_EMAIL)');
ALTER TABLE `automotive_ecm`.`aftersales`.`technician` ALTER COLUMN `email_address` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `automotive_ecm`.`aftersales`.`technician` ALTER COLUMN `email_address` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`aftersales`.`technician` ALTER COLUMN `email_address` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `automotive_ecm`.`aftersales`.`technician` ALTER COLUMN `flat_rate_efficiency_rating` SET TAGS ('dbx_business_glossary_term' = 'Flat‑Rate Efficiency Rating (EFF_RATING)');
ALTER TABLE `automotive_ecm`.`aftersales`.`technician` ALTER COLUMN `full_name` SET TAGS ('dbx_business_glossary_term' = 'Technician Full Name (TECH_NAME)');
ALTER TABLE `automotive_ecm`.`aftersales`.`technician` ALTER COLUMN `full_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`aftersales`.`technician` ALTER COLUMN `full_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `automotive_ecm`.`aftersales`.`technician` ALTER COLUMN `hire_date` SET TAGS ('dbx_business_glossary_term' = 'Hire Date (HIRE_DATE)');
ALTER TABLE `automotive_ecm`.`aftersales`.`technician` ALTER COLUMN `last_training_date` SET TAGS ('dbx_business_glossary_term' = 'Last Training Date (LAST_TRAIN_DATE)');
ALTER TABLE `automotive_ecm`.`aftersales`.`technician` ALTER COLUMN `max_concurrent_ro` SET TAGS ('dbx_business_glossary_term' = 'Maximum Concurrent Repair Orders (MAX_CONCURRENT_RO)');
ALTER TABLE `automotive_ecm`.`aftersales`.`technician` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Technician Notes (NOTES)');
ALTER TABLE `automotive_ecm`.`aftersales`.`technician` ALTER COLUMN `overtime_eligible` SET TAGS ('dbx_business_glossary_term' = 'Overtime Eligible (OT_ELIGIBLE)');
ALTER TABLE `automotive_ecm`.`aftersales`.`technician` ALTER COLUMN `overtime_rate_multiplier` SET TAGS ('dbx_business_glossary_term' = 'Overtime Rate Multiplier (OT_MULTIPLIER)');
ALTER TABLE `automotive_ecm`.`aftersales`.`technician` ALTER COLUMN `phone_number` SET TAGS ('dbx_business_glossary_term' = 'Technician Phone Number (TECH_PHONE)');
ALTER TABLE `automotive_ecm`.`aftersales`.`technician` ALTER COLUMN `phone_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`aftersales`.`technician` ALTER COLUMN `phone_number` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `automotive_ecm`.`aftersales`.`technician` ALTER COLUMN `shift_type` SET TAGS ('dbx_business_glossary_term' = 'Shift Type (SHIFT_TYPE)');
ALTER TABLE `automotive_ecm`.`aftersales`.`technician` ALTER COLUMN `shift_type` SET TAGS ('dbx_value_regex' = 'day|night|flex|rotating');
ALTER TABLE `automotive_ecm`.`aftersales`.`technician` ALTER COLUMN `skill_level` SET TAGS ('dbx_business_glossary_term' = 'Skill Level (SKILL_LEVEL)');
ALTER TABLE `automotive_ecm`.`aftersales`.`technician` ALTER COLUMN `skill_level` SET TAGS ('dbx_value_regex' = 'junior|mid|senior|lead');
ALTER TABLE `automotive_ecm`.`aftersales`.`technician` ALTER COLUMN `specialization` SET TAGS ('dbx_business_glossary_term' = 'Technician Specialization (SPECIALIZATION)');
ALTER TABLE `automotive_ecm`.`aftersales`.`technician` ALTER COLUMN `specialization` SET TAGS ('dbx_value_regex' = 'powertrain|electrical|body|diagnostics|software|hvac');
ALTER TABLE `automotive_ecm`.`aftersales`.`technician` ALTER COLUMN `technician_status` SET TAGS ('dbx_business_glossary_term' = 'Technician Status (STATUS)');
ALTER TABLE `automotive_ecm`.`aftersales`.`technician` ALTER COLUMN `technician_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|retired');
ALTER TABLE `automotive_ecm`.`aftersales`.`technician` ALTER COLUMN `training_hours_completed` SET TAGS ('dbx_business_glossary_term' = 'Training Hours Completed (TRAIN_HRS)');
ALTER TABLE `automotive_ecm`.`aftersales`.`technician` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp (UPDATED_TS)');
ALTER TABLE `automotive_ecm`.`aftersales`.`technician` ALTER COLUMN `years_of_experience` SET TAGS ('dbx_business_glossary_term' = 'Years of Experience (YEARS_EXP)');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` SET TAGS ('dbx_subdomain' = 'parts_distribution');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `parts_return_id` SET TAGS ('dbx_business_glossary_term' = 'Parts Return Identifier');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `aftersales_warranty_claim_id` SET TAGS ('dbx_business_glossary_term' = 'Aftersales Warranty Claim Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `cost_center_id` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `part_master_id` SET TAGS ('dbx_business_glossary_term' = 'Part Master Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `parts_order_id` SET TAGS ('dbx_business_glossary_term' = 'Aftersales Parts Order Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `dealership_id` SET TAGS ('dbx_business_glossary_term' = 'Dealer Identifier');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `storage_location_id` SET TAGS ('dbx_business_glossary_term' = 'Receiving Storage Location Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `repair_order_line_id` SET TAGS ('dbx_business_glossary_term' = 'Repair Order Line Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `service_campaign_id` SET TAGS ('dbx_business_glossary_term' = 'Campaign Identifier');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `service_part_id` SET TAGS ('dbx_business_glossary_term' = 'Service Part Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `supplier_quality_event_id` SET TAGS ('dbx_business_glossary_term' = 'Supplier Quality Event Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `batch_number` SET TAGS ('dbx_business_glossary_term' = 'Batch Number');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `core_return_flag` SET TAGS ('dbx_business_glossary_term' = 'Core Return Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `credit_amount` SET TAGS ('dbx_business_glossary_term' = 'Credit Amount');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `credit_memo_date` SET TAGS ('dbx_business_glossary_term' = 'Credit Memo Issue Date');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `credit_memo_reference` SET TAGS ('dbx_business_glossary_term' = 'Credit Memo Reference');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (ISO 4217)');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `inspected_by` SET TAGS ('dbx_business_glossary_term' = 'Inspected By (Employee Identifier)');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `inspection_date` SET TAGS ('dbx_business_glossary_term' = 'Inspection Date');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `inspection_notes` SET TAGS ('dbx_business_glossary_term' = 'Inspection Notes');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `inspection_outcome` SET TAGS ('dbx_business_glossary_term' = 'Inspection Outcome');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `inspection_outcome` SET TAGS ('dbx_value_regex' = 'accepted|rejected|partial');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `is_credit_issued` SET TAGS ('dbx_business_glossary_term' = 'Credit Issued Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `lot_number` SET TAGS ('dbx_business_glossary_term' = 'Lot Number');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `net_credit_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Credit Amount');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Additional Notes');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `overstock_flag` SET TAGS ('dbx_business_glossary_term' = 'Overstock Return Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `part_condition` SET TAGS ('dbx_business_glossary_term' = 'Part Condition');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `part_condition` SET TAGS ('dbx_value_regex' = 'new|used|defective|repaired');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `quantity_returned` SET TAGS ('dbx_business_glossary_term' = 'Quantity Returned');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `received_date` SET TAGS ('dbx_business_glossary_term' = 'Received Date');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `return_authorization_number` SET TAGS ('dbx_business_glossary_term' = 'Return Authorization Number (RA#)');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `return_date` SET TAGS ('dbx_business_glossary_term' = 'Return Date');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `return_method` SET TAGS ('dbx_business_glossary_term' = 'Return Method');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `return_method` SET TAGS ('dbx_value_regex' = 'mail|carrier|dropoff|pickup');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `return_reason_category` SET TAGS ('dbx_business_glossary_term' = 'Return Reason Category');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `return_reason_category` SET TAGS ('dbx_value_regex' = 'quality|logistics|regulatory|other');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `return_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Return Reason Code');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `return_reason_description` SET TAGS ('dbx_business_glossary_term' = 'Return Reason Description');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `return_source_system` SET TAGS ('dbx_business_glossary_term' = 'Source System of Return Record');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `return_status` SET TAGS ('dbx_business_glossary_term' = 'Return Status');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `return_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected|processed|cancelled');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `return_type` SET TAGS ('dbx_business_glossary_term' = 'Return Type');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `return_type` SET TAGS ('dbx_value_regex' = 'warranty|core|overstock|campaign');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `shipment_tracking_number` SET TAGS ('dbx_business_glossary_term' = 'Shipment Tracking Number');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Tax Amount');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `unit_of_measure` SET TAGS ('dbx_business_glossary_term' = 'Unit of Measure');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `unit_of_measure` SET TAGS ('dbx_value_regex' = 'each|box|kg|liter');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `automotive_ecm`.`aftersales`.`parts_return` ALTER COLUMN `warranty_flag` SET TAGS ('dbx_business_glossary_term' = 'Warranty Return Flag');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb_part_requirement` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb_part_requirement` SET TAGS ('dbx_subdomain' = 'technical_support');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb_part_requirement` SET TAGS ('dbx_association_edges' = 'aftersales.tsb,aftersales.service_part');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb_part_requirement` ALTER COLUMN `tsb_part_requirement_id` SET TAGS ('dbx_business_glossary_term' = 'TSB Part Requirement ID');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb_part_requirement` ALTER COLUMN `service_part_id` SET TAGS ('dbx_business_glossary_term' = 'Tsb Part Requirement - Service Part Id');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb_part_requirement` ALTER COLUMN `tsb_id` SET TAGS ('dbx_business_glossary_term' = 'Tsb Part Requirement - Tsb Id');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb_part_requirement` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb_part_requirement` ALTER COLUMN `installation_sequence` SET TAGS ('dbx_business_glossary_term' = 'Installation Sequence');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb_part_requirement` ALTER COLUMN `is_primary_part` SET TAGS ('dbx_business_glossary_term' = 'Is Primary Part');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb_part_requirement` ALTER COLUMN `part_revision` SET TAGS ('dbx_business_glossary_term' = 'Part Revision');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb_part_requirement` ALTER COLUMN `part_role_in_procedure` SET TAGS ('dbx_business_glossary_term' = 'Part Role in Procedure');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb_part_requirement` ALTER COLUMN `quantity_required` SET TAGS ('dbx_business_glossary_term' = 'Quantity Required');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb_part_requirement` ALTER COLUMN `required_parts` SET TAGS ('dbx_business_glossary_term' = 'Required Parts List');
ALTER TABLE `automotive_ecm`.`aftersales`.`tsb_part_requirement` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
