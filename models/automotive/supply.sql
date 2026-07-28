-- Schema for Domain: supply | Business: Automotive | Version: v1_mvm
-- Generated on: 2026-05-07 02:20:10

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `automotive_ecm`.`supply` COMMENT 'Governs the inbound supply chain from tier-1 and tier-2 suppliers through to plant receiving. Owns supplier master data, RFQ (Request for Quotation) events, PPAP (Production Part Approval Process) records, JIT/JIS delivery schedules, inbound logistics, supplier performance metrics (PPM - Parts Per Million defect rates, OTD - On-Time Delivery), and CKD/SKD kit management for global assembly operations. Integrates with SAP MM and PTC Windchill.';

-- ========= TABLES =========
CREATE OR REPLACE TABLE `automotive_ecm`.`supply`.`supplier_part_approval` (
    `supplier_part_approval_id` BIGINT COMMENT 'System generated unique identifier for the supplier part approval record.',
    `apqp_plan_id` BIGINT COMMENT 'Foreign key linking to quality.apqp_plan. Business justification: Supplier part approvals (PPAP) are governed by APQP plans and must be completed at specific APQP gates (typically Gate 4). This link enables tracking approval status against program milestones and ens',
    `control_plan_id` BIGINT COMMENT 'Foreign key linking to quality.control_plan. Business justification: PPAP submissions require approved control plans as mandatory documentation. Linking supplier part approvals to control plans enables validation that the suppliers quality control methodology meets OE',
    `cost_center_id` BIGINT COMMENT 'Foreign key linking to finance.cost_center. Business justification: PPAP approval activities (testing, validation, travel) incur costs that must be allocated to engineering or quality cost centers for departmental budget tracking and variance analysis.',
    `inbound_part_id` BIGINT COMMENT 'Foreign key linking to supply.inbound_part. Business justification: supplier_part_approval currently stores part_number and part_name as denormalized strings. Adding inbound_part_id FK normalizes this to the supply domains part master. The part_number and part_name c',
    `regulatory_requirement_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_requirement. Business justification: PPAP approvals must reference specific regulatory requirements (FMVSS 302 flammability, ECE R100 battery safety, etc.) that the part must meet. Critical for compliance traceability in automotive manuf',
    `supplier_id` BIGINT COMMENT 'Foreign key linking to supply.supply_supplier. Business justification: PPAP approval records must be tied to the supplier entity in the supply domain for audit and traceability.',
    `supplier_plant_id` BIGINT COMMENT 'Foreign key linking to supply.supply_supplier_plant. Business justification: Part approvals are granted at the plant level — a supplier may have multiple plants and each plants manufacturing process must be independently approved. This FK links the approval to the specific pl',
    `approval_date` DATE COMMENT 'Date the approval decision was recorded.',
    `approval_number` STRING COMMENT 'External business identifier assigned to the approval record, often used in audit and reporting.',
    `approval_outcome` STRING COMMENT 'Result of the PPAP review: approved, interim approval, or rejected.. Valid values are `approved|interim_approval|rejected`',
    `approval_score` DECIMAL(18,2) COMMENT 'Numeric score (0‑100) reflecting overall assessment of the parts compliance.',
    `approver_name` STRING COMMENT 'Name of the engineer or manager who approved the part.',
    `capability_study_status` STRING COMMENT 'Status of the capability study element.. Valid values are `completed|pending|not_applicable`',
    `classification` STRING COMMENT 'Business classification indicating the importance of the part.. Valid values are `critical|major|minor|optional`',
    `comments` STRING COMMENT 'Free‑form notes entered by reviewers or approvers.',
    `control_plan_status` STRING COMMENT 'Status of the control plan element.. Valid values are `completed|pending|not_applicable`',
    `cost_usd` DECIMAL(18,2) COMMENT 'Approved cost of the part in US dollars.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the approval record was first created in the system.',
    `design_records_status` STRING COMMENT 'Status of the design records element within the PPAP package.. Valid values are `completed|pending|not_applicable`',
    `expiry_date` DATE COMMENT 'Date after which the approval is no longer valid.',
    `lead_time_days` STRING COMMENT 'Standard lead time in days for the part from supplier to plant.',
    `lifecycle_status` STRING COMMENT 'Current lifecycle stage of the approval record.. Valid values are `draft|submitted|under_review|approved|rejected|expired`',
    `msa_status` STRING COMMENT 'Status of the MSA element.. Valid values are `completed|pending|not_applicable`',
    `overall_status` STRING COMMENT 'Aggregated status of the approval record.. Valid values are `active|inactive|expired|revoked`',
    `pfmea_status` STRING COMMENT 'Status of the Process FMEA element.. Valid values are `completed|pending|not_applicable`',
    `ppap_submission_level` STRING COMMENT 'Level of PPAP submission (1‑5) indicating the depth of documentation provided.. Valid values are `level_1|level_2|level_3|level_4|level_5`',
    `quality_rating` STRING COMMENT 'Quality rating assigned to the part after approval.. Valid values are `A|B|C|D|E|F`',
    `record_audit_created` TIMESTAMP COMMENT 'Audit timestamp for the creation event of the record.',
    `record_audit_updated` TIMESTAMP COMMENT 'Audit timestamp for the most recent modification of the record.',
    `regulatory_compliance_flag` BOOLEAN COMMENT 'Indicates whether the part meets all applicable regulatory requirements.',
    `risk_level` STRING COMMENT 'Risk level associated with the part based on failure mode analysis.. Valid values are `high|medium|low`',
    `sample_parts_status` STRING COMMENT 'Status of the sample parts element.. Valid values are `completed|pending|not_applicable`',
    `submission_date` DATE COMMENT 'Date the supplier submitted the PPAP package.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the approval record.',
    CONSTRAINT pk_supplier_part_approval PRIMARY KEY(`supplier_part_approval_id`)
) COMMENT 'PPAP (Production Part Approval Process) record capturing the formal approval of a supplier-produced part for use in production. Includes approval ID, part number, supplier reference, PPAP submission level (1–5), submission date, approval date, approver, PPAP elements status (design records, PFMEA, control plan, MSA, capability study, sample parts), approval outcome (approved, interim approval, rejected), and expiry date. Mandated by IATF 16949 and AIAG PPAP standards for all production parts.';

CREATE OR REPLACE TABLE `automotive_ecm`.`supply`.`supplier` (
    `supplier_id` BIGINT COMMENT 'Unique identifier for the supply_supplier data product (auto-inserted pre-linking).',
    `account_id` BIGINT COMMENT 'Foreign key linking to billing.account. Business justification: Automotive OEMs maintain billing accounts for suppliers to process supplier invoices, track payables, and manage payment processing. Essential for accounts payable operations and supplier payment reco',
    `jurisdiction_id` BIGINT COMMENT 'Foreign key linking to compliance.jurisdiction. Business justification: Supplier Jurisdiction Registry links a supplier to the jurisdiction where it operates for tax and regulatory reporting.',
    CONSTRAINT pk_supplier PRIMARY KEY(`supplier_id`)
) COMMENT 'Master record for all tier-1 and tier-2 suppliers in the automotive supply chain. Captures supplier identity, classification (direct/indirect, tier level), IATF 16949 certification status, DUNS number, geographic footprint, commodity codes, preferred currency, payment terms, and supplier lifecycle status (active, probation, disqualified). SSOT for supplier identity within the supply domain; integrates with SAP MM vendor master and PTC Windchill supplier collaboration.';

CREATE OR REPLACE TABLE `automotive_ecm`.`supply`.`supplier_plant` (
    `supplier_plant_id` BIGINT COMMENT 'Unique identifier for the supply_supplier_plant data product (auto-inserted pre-linking).',
    `supplier_id` BIGINT COMMENT 'Foreign key linking to supply.supply_supplier. Business justification: Link child plant to its supplier master for in‑domain hierarchy',
    CONSTRAINT pk_supplier_plant PRIMARY KEY(`supplier_plant_id`)
) COMMENT 'Represents the specific manufacturing or distribution plant/site of a supplier that ships parts to an OEM assembly plant. Captures plant address, plant code, production capabilities, capacity constraints, dock-to-dock lead time, customs zone, and plant-level quality certifications. Enables JIT/JIS scheduling at the plant-to-plant level and supports CKD/SKD kit origin tracking.';

CREATE OR REPLACE TABLE `automotive_ecm`.`supply`.`inbound_part` (
    `inbound_part_id` BIGINT COMMENT 'System-generated unique identifier for the inbound part record.',
    `commodity_group_id` BIGINT COMMENT 'FK to supply.commodity_group',
    `control_plan_id` BIGINT COMMENT 'Foreign key linking to quality.control_plan. Business justification: Each inbound part must have an associated control plan defining inspection requirements, sampling frequency, and reaction plans. This link is essential for receiving inspection operations, enabling in',
    `cost_center_id` BIGINT COMMENT 'Foreign key linking to finance.cost_center. Business justification: Material receipt cost is allocated to a Cost Center for inventory valuation and variance analysis.',
    `party_id` BIGINT COMMENT 'Foreign key linking to customer.party. Business justification: Fleet customers and OEM programs often require custom part sourcing. Enables warranty cost allocation by customer segment, customer-specific part qualification tracking, and program costing. Essential',
    `inspection_plan_id` BIGINT COMMENT 'Foreign key linking to quality.inspection_plan. Business justification: Inbound parts require inspection plans defining acceptance criteria, measurement methods, and gauge requirements. This link enables receiving inspectors to execute the correct inspection protocol and ',
    `jurisdiction_id` BIGINT COMMENT 'Foreign key linking to compliance.jurisdiction. Business justification: Parts sourced for specific markets must comply with jurisdiction-specific regulations (EU RoHS, California Prop 65, China RoHS). Essential for market-specific compliance planning and customs clearance',
    `part_master_id` BIGINT COMMENT 'Foreign key linking to engineering.part_master. Business justification: Inbound receipt process matches each received part to the engineering part master for quality verification and BOM reconciliation.',
    `platform_id` BIGINT COMMENT 'Foreign key linking to vehicle.platform. Business justification: Inbound parts in automotive are frequently platform-specific commodities (e.g., platform-level chassis, suspension, electrical architecture parts). Platform commodity managers track part costs and sou',
    `regulatory_requirement_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_requirement. Business justification: Regulatory Requirement Mapping report links each inbound part to the regulatory requirement it must satisfy for emissions and safety compliance.',
    `sku_master_id` BIGINT COMMENT 'Foreign key linking to inventory.sku_master. Business justification: Receiving process matches inbound parts to SKU master to create accurate stock records; essential for inventory posting.',
    `supplier_id` BIGINT COMMENT 'Foreign key linking to supply.supply_supplier. Business justification: Connect inbound part to internal supplier master for analytics',
    `tax_code_id` BIGINT COMMENT 'Foreign key linking to billing.tax_code. Business justification: Automotive parts have specific tax treatment including customs duties, VAT, and tariff classifications. Required for accurate landed cost calculation, customs compliance, and financial reporting. Tax ',
    `average_cost` DECIMAL(18,2) COMMENT 'Weighted average purchase cost per unit of the part.',
    `country_of_origin` STRING COMMENT 'Three‑letter ISO code of the country where the part was manufactured.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when the inbound part record was first created.',
    `currency_code` STRING COMMENT 'Three‑letter ISO currency code for the parts cost.. Valid values are `^[A-Z]{3}$`',
    `customs_tariff_code` STRING COMMENT 'HS‑8 tariff classification code used for import duties.. Valid values are `^[0-9]{8}$`',
    `effective_from` DATE COMMENT 'Date from which the part information is considered valid.',
    `effective_until` DATE COMMENT 'Date after which the part information is no longer valid (nullable).',
    `engineering_change_level` STRING COMMENT 'Level of engineering change applied to the part (e.g., A‑E).. Valid values are `A|B|C|D|E`',
    `hazardous_material_flag` BOOLEAN COMMENT 'Indicates whether the part is classified as hazardous under regulatory rules.',
    `height_mm` DECIMAL(18,2) COMMENT 'Physical height of the part in millimetres.',
    `last_received_date` DATE COMMENT 'Date when the part was most recently received at the plant.',
    `last_received_quantity` STRING COMMENT 'Quantity of the part received on the most recent receipt.',
    `lead_time_days` STRING COMMENT 'Planned number of days from order placement to receipt.',
    `length_mm` DECIMAL(18,2) COMMENT 'Physical length of the part in millimetres.',
    `lifecycle_status` STRING COMMENT 'Current operational status of the part within the supply chain.. Valid values are `active|inactive|discontinued|pending`',
    `lot_size` STRING COMMENT 'Standard production batch size for the part.',
    `material_type` STRING COMMENT 'Category indicating whether the part is raw material, sub‑assembly, CKD kit, finished good, or service item.. Valid values are `raw|sub-assembly|ckd_kit|finished|service`',
    `minimum_order_quantity` STRING COMMENT 'Smallest quantity that can be ordered from the supplier.',
    `oem_part_number` STRING COMMENT 'Original Equipment Manufacturer part number used internally for cross‑reference.',
    `ppap_status` STRING COMMENT 'Current status of the Production Part Approval Process for the part.. Valid values are `approved|rejected|pending|under_review`',
    `price_uom` STRING COMMENT 'Unit of measure used for the price (e.g., each, kilogram).. Valid values are `EA|KG|L|M|SET`',
    `reorder_point_quantity` STRING COMMENT 'Inventory level that triggers a new purchase order.',
    `safety_stock_quantity` STRING COMMENT 'Buffer inventory quantity maintained to protect against supply variability.',
    `source_system` STRING COMMENT 'Originating system of record for the part data.. Valid values are `SAP|Windchill|Other`',
    `supplier_part_number` STRING COMMENT 'Identifier assigned by the external supplier to the part.',
    `unit_of_measure` STRING COMMENT 'Standard unit used for ordering and inventory management.. Valid values are `EA|KG|L|M|SET`',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time of the most recent modification to the record.',
    `weight_kg` DECIMAL(18,2) COMMENT 'Net weight of the part in kilograms.',
    `width_mm` DECIMAL(18,2) COMMENT 'Physical width of the part in millimetres.',
    CONSTRAINT pk_inbound_part PRIMARY KEY(`inbound_part_id`)
) COMMENT 'Master record for every purchased part number sourced from external suppliers. Captures OEM part number, supplier part number cross-reference, commodity group, material type (raw, sub-assembly, CKD kit), unit of measure, PPAP approval status, engineering change level, hazardous material flag, country of origin, and customs tariff code. Bridges SAP MM material master and PTC Windchill parts classification for supply-domain-owned purchased parts.';

CREATE OR REPLACE TABLE `automotive_ecm`.`supply`.`sourcing_nomination` (
    `sourcing_nomination_id` BIGINT COMMENT 'System-generated unique identifier for each sourcing nomination record.',
    `commodity_group_id` BIGINT COMMENT 'Foreign key linking to supply.commodity_group. Business justification: sourcing_nomination has a commodity field (denormalized string). Nominations are made at the commodity level — linking to commodity_group normalizes this and enables commodity-level sourcing analytics',
    `organization_account_id` BIGINT COMMENT 'Foreign key linking to customer.organization_account. Business justification: Fleet and government contracts often include customer-directed sourcing (e.g., fleet operator specifies tire brand, government contract mandates domestic suppliers). Tracks customer-driven supplier se',
    `fleet_contract_id` BIGINT COMMENT 'Foreign key linking to sales.fleet_contract. Business justification: Fleet contracts drive sourcing nominations for high-volume part requirements. Enables contract-driven supplier selection, volume commitments, and ensures supply chain capacity aligns with multi-year f',
    `inbound_part_id` BIGINT COMMENT 'Foreign key linking to supply.inbound_part. Business justification: sourcing_nomination currently stores part_number as a denormalized string. The nomination is for a specific purchased part in the supply domain. Adding inbound_part_id normalizes this to the part mast',
    `model_id` BIGINT COMMENT 'Foreign key linking to vehicle.model. Business justification: Sourcing nominations in automotive are issued per vehicle model/program. Commodity managers must link nominations to vehicle.model to produce program-level sourcing coverage reports and ensure all par',
    `supplier_id` BIGINT COMMENT 'Foreign key linking to supply.supply_supplier. Business justification: Link sourcing nomination to internal supplier master',
    `comments` STRING COMMENT 'Additional notes or remarks entered by the buyer or sourcing team.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the nomination record was first created in the system.',
    `currency_code` STRING COMMENT 'Three‑letter ISO currency code for the target piece price.. Valid values are `USD|EUR|JPY|GBP|CAD|AUD`',
    `effective_end_date` DATE COMMENT 'Optional date when the nomination expires or is superseded.',
    `effective_start_date` DATE COMMENT 'Date from which the nomination becomes effective for planning purposes.',
    `is_jis` BOOLEAN COMMENT 'Indicates whether the nominated part is required under a JIS delivery strategy.',
    `is_jit` BOOLEAN COMMENT 'Indicates whether the nominated part is required under a JIT delivery strategy.',
    `kit_type` STRING COMMENT 'Specifies whether the part is supplied as a Completely Knocked Down (CKD) or Semi‑Knocked Down (SKD) kit, or not a kit.. Valid values are `CKD|SKD|none`',
    `model_year` STRING COMMENT 'Model year for which the part nomination applies.',
    `nominated_volume` DECIMAL(18,2) COMMENT 'Total quantity of the part the supplier is expected to deliver for the program.',
    `nomination_date` TIMESTAMP COMMENT 'Timestamp when the OEM formally recorded the nomination.',
    `nomination_number` STRING COMMENT 'Human‑readable business code assigned to the nomination for tracking and reference.',
    `nomination_status` STRING COMMENT 'Current lifecycle status of the nomination.. Valid values are `nominated|confirmed|withdrawn|rejected`',
    `priority` STRING COMMENT 'Business priority assigned to the nomination for execution planning.. Valid values are `high|medium|low`',
    `program_code` STRING COMMENT 'Code identifying the vehicle program or platform associated with the nomination (e.g., SUV2025, EVX).',
    `region` STRING COMMENT 'Region code indicating the primary supply geography for the nominated part.. Valid values are `NAM|EME|APAC|LATAM|AFR`',
    `risk_rating` STRING COMMENT 'Qualitative assessment of supply risk for the nominated part.. Valid values are `low|medium|high`',
    `sor_reference` STRING COMMENT 'Reference code linking to the SOR document that defines functional and performance requirements.',
    `target_piece_price` DECIMAL(18,2) COMMENT 'Target unit price (per piece) the OEM aims to achieve with the nominated supplier.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the nomination record.',
    CONSTRAINT pk_sourcing_nomination PRIMARY KEY(`sourcing_nomination_id`)
) COMMENT 'Records the formal OEM decision to nominate a specific supplier for a given part or commodity within a model year program. Captures nomination date, program/platform code, nominated supplier, awarded annual volume, target piece price, SOR (Statement of Requirements) reference, nomination status (nominated, confirmed, withdrawn), and the responsible commodity buyer. Precedes the RFQ and PPAP process. SSOT for sourcing award decisions; distinct from procurement domains strategic sourcing strategy — this is the operational award record.';

CREATE OR REPLACE TABLE `automotive_ecm`.`supply`.`rfq` (
    `rfq_id` BIGINT COMMENT 'System‑generated unique identifier for the RFQ record.',
    `apqp_plan_id` BIGINT COMMENT 'Foreign key linking to quality.apqp_plan. Business justification: RFQs for new program parts are issued within APQP program context and must align with APQP timing milestones. This link ensures sourcing activities are synchronized with quality planning gates, enable',
    `commodity_group_id` BIGINT COMMENT 'Foreign key linking to supply.commodity_group. Business justification: rfq has commodity_code as a denormalized string. RFQs are issued within a commodity group context. Linking to commodity_group normalizes this and enables commodity-level RFQ analytics and routing to t',
    `cost_center_id` BIGINT COMMENT 'Foreign key linking to finance.cost_center. Business justification: RFQ sourcing activities are performed by purchasing or engineering cost centers that need to track sourcing process costs against departmental budgets for overhead allocation.',
    `organization_account_id` BIGINT COMMENT 'Foreign key linking to customer.organization_account. Business justification: RFQs for customer-specific programs (fleet customization, government contracts, customer-funded tooling) require customer linkage. Enables tracking customer-specific part qualification, customer-funde',
    `inbound_part_id` BIGINT COMMENT 'Foreign key linking to supply.inbound_part. Business justification: An RFQ is issued for a specific purchased part in the supply domain. rfq already has part_master_id (cross-domain to engineering), but inbound_part is the supply domains authoritative part record. Ad',
    `model_id` BIGINT COMMENT 'Foreign key linking to vehicle.model. Business justification: RFQs in automotive procurement are issued for parts required by specific vehicle models/programs. Linking rfq.model_id → vehicle.model.model_id enables program-level sourcing cost analysis, supplier s',
    `part_master_id` BIGINT COMMENT 'Foreign key linking to engineering.part_master. Business justification: RFQ generation is driven by engineering part definitions; linking to part_master enables accurate pricing and specification alignment.',
    `sourcing_nomination_id` BIGINT COMMENT 'Foreign key linking to supply.sourcing_nomination. Business justification: In automotive procurement, an RFQ is typically issued as part of a formal sourcing nomination process. Linking rfq to sourcing_nomination establishes the procurement chain: nomination → RFQ → response',
    `supplier_id` BIGINT COMMENT 'Foreign key linking to supply.supply_supplier. Business justification: Associate RFQ with internal supplier master',
    `approval_status` STRING COMMENT 'Current status of internal approval workflow.. Valid values are `PENDING|APPROVED|REJECTED`',
    `attachment_flag` BOOLEAN COMMENT 'Indicates whether supporting documents are attached to the RFQ.',
    `compliance_requirements` STRING COMMENT 'Regulatory or quality standards the supplier must meet (e.g., IATF 16949, ISO 14001).',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the RFQ record was first created in the system.',
    `delivery_schedule_type` STRING COMMENT 'Preferred delivery methodology (Just‑In‑Time, Just‑In‑Sequence, or standard).. Valid values are `JIT|JIS|STANDARD`',
    `discount_amount` DECIMAL(18,2) COMMENT 'Any discount the supplier proposes relative to the target price.',
    `issue_timestamp` TIMESTAMP COMMENT 'Date‑time when the RFQ was issued to suppliers.',
    `last_status_change_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent change to the RFQ status.',
    `net_price_amount` DECIMAL(18,2) COMMENT 'Net price after discounts, taxes, and fees.',
    `notes` STRING COMMENT 'Free‑form notes entered by the buyer.',
    `priority` STRING COMMENT 'Business priority assigned to the RFQ.. Valid values are `HIGH|MEDIUM|LOW`',
    `program_model_year` STRING COMMENT 'Vehicle program or model year for which the part is required.',
    `quantity_estimate` BIGINT COMMENT 'Projected annual volume the buyer expects to purchase.',
    `regulatory_approval_required` BOOLEAN COMMENT 'True if the part requires regulatory sign‑off before purchase.',
    `required_delivery_date` DATE COMMENT 'Date by which the part must be delivered to the plant.',
    `response_due_date` DATE COMMENT 'Last date on which suppliers may submit their quotations.',
    `rfq_number` STRING COMMENT 'Business‑visible RFQ number assigned by the sourcing system.',
    `rfq_status` STRING COMMENT 'Current lifecycle state of the RFQ.. Valid values are `draft|open|closed|awarded|cancelled|pending`',
    `rfq_type` STRING COMMENT 'Classification of the RFQ request.. Valid values are `NEW_PART|EXISTING_PART|SERVICE|MATERIAL`',
    `source_system` STRING COMMENT 'System of record that originated the RFQ (e.g., SAP_MM).',
    `target_price_amount` DECIMAL(18,2) COMMENT 'Maximum price the buyer is willing to pay for the quoted item (gross).',
    `target_price_currency` STRING COMMENT 'Three‑letter ISO 4217 currency code for the target price.',
    `tooling_description` STRING COMMENT 'Details of the tooling requirements, if any.',
    `tooling_required` BOOLEAN COMMENT 'Indicates whether new tooling is needed for the part.',
    `unit_of_measure` STRING COMMENT 'Unit in which the quantity is expressed.. Valid values are `EA|KG|L|M|SET|BOX`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the RFQ record.',
    `created_by` STRING COMMENT 'User identifier of the employee who created the RFQ.',
    CONSTRAINT pk_rfq PRIMARY KEY(`rfq_id`)
) COMMENT 'Transactional record of a Request for Quotation event issued to one or more suppliers for a specific part, assembly, or service. Captures RFQ number, issue date, response due date, commodity, target price, annual volume estimate, program/model year, tooling requirements, and RFQ status (open, closed, awarded, cancelled). Integrates with SAP MM RFQ (ME41) and PTC Windchill supplier collaboration portal.';

CREATE OR REPLACE TABLE `automotive_ecm`.`supply`.`rfq_response` (
    `rfq_response_id` BIGINT COMMENT 'System-generated unique identifier for the RFQ response record.',
    `cost_center_id` BIGINT COMMENT 'Foreign key linking to finance.cost_center. Business justification: Quote evaluation and supplier selection work is performed by cost centers (procurement, engineering) that need to track time and resources spent on sourcing activities.',
    `payment_term_id` BIGINT COMMENT 'Foreign key linking to billing.payment_term. Business justification: Supplier RFQ responses include proposed payment terms as part of commercial offer. Essential for total cost evaluation during automotive sourcing decisions, enabling comparison of payment term impacts',
    `rfq_id` BIGINT COMMENT 'Identifier of the original Request for Quotation to which this response belongs.',
    `supplier_id` BIGINT COMMENT 'Foreign key linking to supply.supply_supplier. Business justification: Associate RFQ response with internal supplier master',
    `supplier_plant_id` BIGINT COMMENT 'Foreign key linking to supply.supply_supplier_plant. Business justification: A suppliers quotation response to an RFQ comes from a specific manufacturing plant that will produce the parts. Linking rfq_response to supply_supplier_plant captures which plant is committing to the',
    `amortization_term_months` STRING COMMENT 'Number of months over which the tooling cost is amortized.',
    `capacity_commitment` DECIMAL(18,2) COMMENT 'Maximum production capacity the supplier commits to deliver per period.',
    `capacity_unit` STRING COMMENT 'Unit for the capacity commitment (e.g., units_per_month).',
    `compliance_certifications` STRING COMMENT 'List of regulatory or industry certifications attached to the quotation.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the RFQ response record was first created in the system.',
    `delivery_address` STRING COMMENT 'Physical address where the supplier will deliver the goods.',
    `discount_percentage` DECIMAL(18,2) COMMENT 'Percentage discount offered on the quoted unit price.',
    `exceptions_to_sor` STRING COMMENT 'Supplier‑provided deviations or exceptions to the original SOR.',
    `freight_included` BOOLEAN COMMENT 'True if freight costs are included in the total price.',
    `is_preferred_supplier` BOOLEAN COMMENT 'Indicates whether the supplier is marked as a preferred source for this part.',
    `lead_time_days` STRING COMMENT 'Number of calendar days the supplier needs to deliver the quoted items after order confirmation.',
    `quoted_currency` STRING COMMENT 'ISO 4217 currency code of the quoted price.',
    `quoted_quantity` DECIMAL(18,2) COMMENT 'Quantity of items the supplier is quoting for.',
    `quoted_unit_price` DECIMAL(18,2) COMMENT 'Price per unit quoted by the supplier.',
    `regulatory_approval_status` STRING COMMENT 'Status of any required regulatory approvals for the quoted part.. Valid values are `pending|approved|rejected`',
    `remarks` STRING COMMENT 'Additional free‑form comments from the supplier.',
    `response_number` STRING COMMENT 'External reference number assigned to the suppliers quotation response.',
    `response_source` STRING COMMENT 'Channel through which the supplier submitted the quotation.. Valid values are `email|portal|api`',
    `rfq_response_status` STRING COMMENT 'Current lifecycle status of the RFQ response.. Valid values are `submitted|under_review|accepted|rejected`',
    `shipping_method` STRING COMMENT 'Mode of transportation for delivering the goods.. Valid values are `air|sea|land`',
    `submission_timestamp` TIMESTAMP COMMENT 'Date and time when the supplier submitted the quotation.',
    `tax_amount` DECIMAL(18,2) COMMENT 'Estimated tax component included in the quotation.',
    `tooling_cost` DECIMAL(18,2) COMMENT 'One‑time cost for tooling or molds required to produce the part.',
    `total_price` DECIMAL(18,2) COMMENT 'Total amount for the quoted quantity (unit price multiplied by quantity).',
    `unit_of_measure` STRING COMMENT 'Measurement unit for the quoted quantity.. Valid values are `EA|KG|L`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the RFQ response record.',
    `validity_end_date` DATE COMMENT 'Last date on which the quoted terms are valid.',
    `validity_start_date` DATE COMMENT 'First date on which the quoted terms are valid.',
    `warranty_period_months` STRING COMMENT 'Length of warranty coverage offered by the supplier.',
    `warranty_type` STRING COMMENT 'Type of warranty provided.. Valid values are `standard|extended`',
    CONSTRAINT pk_rfq_response PRIMARY KEY(`rfq_response_id`)
) COMMENT 'Captures a suppliers formal quotation response to an RFQ. Records quoted unit price, tooling cost, amortization terms, lead time, capacity commitment, exceptions to SOR, validity period, and response status (submitted, under review, accepted, rejected). Supports competitive bid analysis and supplier selection decisions. One RFQ may have multiple responses from competing suppliers.';

CREATE OR REPLACE TABLE `automotive_ecm`.`supply`.`purchase_order` (
    `purchase_order_id` BIGINT COMMENT 'Unique identifier for the supply_purchase_order data product (auto-inserted pre-linking).',
    `company_code_id` BIGINT COMMENT 'Foreign key linking to finance.company_code. Business justification: Every purchase order must be issued by a legal entity (company code) for legal contract validity, tax jurisdiction determination, and statutory financial reporting requirements.',
    `cost_center_id` BIGINT COMMENT 'Foreign key linking to finance.cost_center. Business justification: PO cost allocation required for budgeting and expense posting in Cost Center; finance tracks spend per cost center.',
    `party_id` BIGINT COMMENT 'Foreign key linking to customer.party. Business justification: Build-to-order and fleet procurement requires linking POs to the driving customer for cost allocation, program tracking, and customer-specific supplier terms. Critical for customer-funded tooling, spe',
    `price_agreement_id` BIGINT COMMENT 'Foreign key linking to supply.price_agreement. Business justification: Purchase orders are priced according to a formally agreed price agreement. Linking supply_purchase_order to price_agreement ensures commercial compliance — the PO price can be validated against the ag',
    `profit_center_id` BIGINT COMMENT 'Foreign key linking to finance.profit_center. Business justification: Purchase orders are issued by plants or business units that are profit centers. Essential for segment P&L reporting and procurement spend attribution to business segments.',
    `scheduling_agreement_id` BIGINT COMMENT 'Foreign key linking to supply.scheduling_agreement. Business justification: In SAP MM-based automotive procurement, purchase orders are often issued against a scheduling agreement (Rahmenvertrag). Linking supply_purchase_order to scheduling_agreement establishes the contractu',
    `supplier_id` BIGINT COMMENT 'Foreign key linking to supply.supply_supplier. Business justification: Link purchase order to internal supplier master',
    `supplier_plant_id` BIGINT COMMENT 'Foreign key linking to supply.supply_supplier_plant. Business justification: A purchase order is issued to a specific supplier plant, not just the supplier entity. In JIT/JIS automotive supply chains, the plant-level routing is critical for delivery scheduling and logistics co',
    `vehicle_order_id` BIGINT COMMENT 'Foreign key linking to sales.vehicle_order. Business justification: PRODUCTION PLANNING: Purchase orders are generated from vehicle orders; linking enables order‑to‑delivery traceability report required by manufacturing execution system.',
    CONSTRAINT pk_purchase_order PRIMARY KEY(`purchase_order_id`)
) COMMENT 'Legally binding procurement document issued to a supplier authorizing delivery of parts or materials at agreed price and schedule. Captures PO number, PO type (standard, blanket, scheduling agreement), supplier, plant, delivery terms (Incoterms), payment terms, total value, currency, and PO status (open, partially delivered, closed, cancelled). SSOT for purchase commitments; sourced from SAP MM (ME21N/ME22N).';

CREATE OR REPLACE TABLE `automotive_ecm`.`supply`.`po_line` (
    `po_line_id` BIGINT COMMENT 'Unique identifier for the supply_po_line data product (auto-inserted pre-linking).',
    `gl_account_id` BIGINT COMMENT 'Foreign key linking to finance.gl_account. Business justification: Each PO line expense must be posted to a GL account for financial reporting; GL account determines expense classification.',
    `inbound_part_id` BIGINT COMMENT 'Foreign key linking to supply.inbound_part. Business justification: Each PO line item is for a specific purchased part. supply_po_line already has sku_master_id (cross-domain to inventory), but inbound_part is the supply domains authoritative part record. Adding inbo',
    `order_line_id` BIGINT COMMENT 'Foreign key linking to sales.order_line. Business justification: FULFILLMENT MAPPING: Each PO line must reference the originating sales order line to reconcile parts consumption against sold vehicle configurations.',
    `price_agreement_id` BIGINT COMMENT 'Foreign key linking to supply.price_agreement. Business justification: Each PO line is priced according to a specific price agreement for that part-supplier combination. Linking supply_po_line to price_agreement enables line-level price validation and commercial audit tr',
    `profit_center_id` BIGINT COMMENT 'Foreign key linking to finance.profit_center. Business justification: Individual PO line items need profit center attribution for segment reporting when parts are consumed by different business units or product lines within same plant.',
    `purchase_order_id` BIGINT COMMENT 'Foreign key linking to supply.supply_purchase_order. Business justification: Connect PO line to its purchase order within supply domain',
    `sku_master_id` BIGINT COMMENT 'Foreign key linking to inventory.sku_master. Business justification: Purchase order line items specify the exact SKU to be received; linking enables automatic inventory allocation.',
    `supplier_id` BIGINT COMMENT 'Foreign key linking to supply.supply_supplier. Business justification: Link PO line to internal supplier master',
    CONSTRAINT pk_po_line PRIMARY KEY(`po_line_id`)
) COMMENT 'Individual line item within a purchase order representing a specific part number, quantity, unit price, delivery date, and plant destination. Captures line number, material number, ordered quantity, confirmed quantity, net price, delivery date, goods receipt quantity, and invoice quantity. Enables line-level tracking of delivery performance and invoice matching (3-way match) in SAP MM.';

CREATE OR REPLACE TABLE `automotive_ecm`.`supply`.`scheduling_agreement` (
    `scheduling_agreement_id` BIGINT COMMENT 'System generated unique identifier for the scheduling agreement record.',
    `company_code_id` BIGINT COMMENT 'Foreign key linking to finance.company_code. Business justification: Scheduling agreements are multi-year legal contracts that must be owned by a legal entity (company code) for contract enforceability and financial commitment tracking.',
    `control_plan_id` BIGINT COMMENT 'Foreign key linking to quality.control_plan. Business justification: Long-term scheduling agreements must reference control plans to contractually bind suppliers to ongoing quality requirements. This link enables verification that quality standards are maintained throu',
    `cost_center_id` BIGINT COMMENT 'Foreign key linking to finance.cost_center. Business justification: Long-term supply agreements are managed by procurement or production planning cost centers that need to track agreement management costs and performance against budget.',
    `fleet_contract_id` BIGINT COMMENT 'Foreign key linking to sales.fleet_contract. Business justification: Long-term fleet contracts require dedicated scheduling agreements with suppliers for JIT/JIS delivery of high-volume parts. Enables fleet contract fulfillment planning, synchronizes supplier delivery ',
    `inbound_part_id` BIGINT COMMENT 'Foreign key linking to supply.inbound_part. Business justification: A scheduling agreement is for a specific purchased part. scheduling_agreement already has part_master_id (cross-domain), but inbound_part is the supply domains part master. Adding inbound_part_id cre',
    `model_id` BIGINT COMMENT 'Foreign key linking to vehicle.model. Business justification: Scheduling agreements in automotive are negotiated per vehicle program/model to commit supplier volumes aligned to production plans. Linking to vehicle.model enables program-level supply coverage anal',
    `part_master_id` BIGINT COMMENT 'Foreign key linking to engineering.part_master. Business justification: Scheduling agreements are created per engineering part to lock volume, price, and delivery cadence with the supplier.',
    `price_agreement_id` BIGINT COMMENT 'Foreign key linking to supply.price_agreement. Business justification: A scheduling agreement references the price agreement that governs the piece price for deliveries. Adding price_agreement_id normalizes the price reference — price_per_unit on scheduling_agreement bec',
    `regulatory_requirement_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_requirement. Business justification: Long-term supply agreements must reference applicable regulatory requirements for supplied parts to ensure continuous compliance throughout contract term. Essential for automotive OEM compliance manag',
    `supplier_id` BIGINT COMMENT 'Foreign key linking to supply.supply_supplier. Business justification: Link scheduling agreement to internal supplier master',
    `supplier_plant_id` BIGINT COMMENT 'Foreign key linking to supply.supply_supplier_plant. Business justification: A scheduling agreement governs JIT/JIS deliveries from a specific supplier plant. The plant-level link is essential for delivery scheduling, logistics coordination, and plant-level performance trackin',
    `actual_otd_percent` DECIMAL(18,2) COMMENT 'Measured on‑time delivery performance for the agreement period.',
    `actual_ppm` DECIMAL(18,2) COMMENT 'Measured defect rate for parts delivered under the agreement.',
    `agreement_number` STRING COMMENT 'External business identifier assigned to the scheduling agreement (e.g., contract number).',
    `agreement_type` STRING COMMENT 'Classification of the scheduling agreement (e.g., framework, spot, consignment).. Valid values are `framework|spot|consignment|service|lease`',
    `approval_date` DATE COMMENT 'Date on which the agreement received formal approval.',
    `compliance_approval_status` STRING COMMENT 'Regulatory or quality compliance status of the agreement.. Valid values are `pending|approved|rejected`',
    `compliance_document_ref` STRING COMMENT 'Reference number of the attached compliance documentation.',
    `contract_scope` STRING COMMENT 'High‑level description of the parts, services, or components covered.',
    `contract_version` STRING COMMENT 'Version identifier for the agreement when amendments are made.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the scheduling agreement record was first created in the system.',
    `currency_code` STRING COMMENT 'Three‑letter ISO 4217 code of the currency used for pricing.. Valid values are `USD|EUR|JPY|CNY|GBP`',
    `delivery_rhythm` STRING COMMENT 'Scheduled frequency of deliveries defined in the agreement.. Valid values are `daily|weekly|biweekly|monthly`',
    `early_termination_allowed` BOOLEAN COMMENT 'Flag indicating whether the agreement can be terminated before the end date.',
    `end_date` DATE COMMENT 'Date on which the agreement expires or is terminated (nullable for open‑ended contracts).',
    `kanban_flag` BOOLEAN COMMENT 'Indicates whether the agreement uses a Kanban pull system for JIT deliveries.',
    `payment_terms` STRING COMMENT 'Standard payment condition agreed with the supplier.. Valid values are `net30|net45|net60|cash|prepaid`',
    `penalty_clause` STRING COMMENT 'Text describing penalties for missed deliveries or quality breaches.',
    `release_horizon_weeks` STRING COMMENT 'Number of weeks in advance that delivery forecasts must be submitted.',
    `renewal_notice_period_days` STRING COMMENT 'Notice period required to exercise renewal option.',
    `renewal_option` BOOLEAN COMMENT 'Indicates if the agreement includes an automatic renewal provision.',
    `scheduling_agreement_description` STRING COMMENT 'Free‑text description of the purpose, scope and key terms of the agreement.',
    `scheduling_agreement_status` STRING COMMENT 'Current lifecycle status of the scheduling agreement.. Valid values are `draft|active|suspended|terminated|expired`',
    `start_date` DATE COMMENT 'Date on which the agreement becomes binding.',
    `target_otd_percent` DECIMAL(18,2) COMMENT 'Target percentage for on‑time deliveries defined in the agreement.',
    `target_ppm` DECIMAL(18,2) COMMENT 'Maximum allowable defect rate for supplied parts.',
    `termination_notice_period_days` STRING COMMENT 'Number of days notice required to terminate the agreement early.',
    `total_annual_volume` DECIMAL(18,2) COMMENT 'Planned total quantity of parts to be supplied over the contract year.',
    `unit_of_measure` STRING COMMENT 'Measurement unit for the volume (e.g., pieces, kilograms).. Valid values are `pcs|kg|liter|meter|unit`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the scheduling agreement record.',
    CONSTRAINT pk_scheduling_agreement PRIMARY KEY(`scheduling_agreement_id`)
) COMMENT 'Long-term supply agreement with a supplier defining the framework for JIT/JIS delivery of parts over a model year or contract period. Captures agreement number, validity start/end dates, target annual volume, release horizon (firm/forecast weeks), delivery rhythm (daily, weekly), Kanban flag, and agreement status. The scheduling agreement is the backbone of JIT supply in SAP MM (ME31L/ME32L).';

CREATE OR REPLACE TABLE `automotive_ecm`.`supply`.`supply_delivery_schedule` (
    `supply_delivery_schedule_id` BIGINT COMMENT 'Unique identifier for the supply_delivery_schedule data product (auto-inserted pre-linking).',
    `build_spec_id` BIGINT COMMENT 'Foreign key linking to vehicle.build_spec. Business justification: In JIT/JIS automotive manufacturing, delivery schedules are sequenced to specific vehicle build specs. Linking supply_delivery_schedule.build_spec_id → vehicle.build_spec.build_spec_id enables sequenc',
    `inbound_part_id` BIGINT COMMENT 'Foreign key linking to supply.inbound_part. Business justification: Each delivery schedule line specifies a specific part to be delivered. Linking supply_delivery_schedule to inbound_part enables part-level delivery tracking, quantity reconciliation, and JIT/JIS sched',
    `inbound_shipment_id` BIGINT COMMENT 'Foreign key linking to supply.inbound_shipment. Business justification: A JIT/JIS delivery schedule line is fulfilled by a specific inbound shipment (ASN). Linking supply_delivery_schedule to inbound_shipment enables schedule-vs-actual delivery tracking, OTD calculation, ',
    `scheduling_agreement_id` BIGINT COMMENT 'Foreign key linking to supply.scheduling_agreement. Business justification: Delivery schedule is issued under a scheduling agreement; linking via scheduling_agreement_id enables traceability to the agreement.',
    `supplier_id` BIGINT COMMENT 'Foreign key linking to supply.supply_supplier. Business justification: Delivery schedule belongs to a supplier; adding supplier_id FK creates the required parent relationship and consolidates supplier reference.',
    `supplier_plant_id` BIGINT COMMENT 'Foreign key linking to supply.supply_supplier_plant. Business justification: A delivery schedule specifies which supplier plant is responsible for the delivery. This plant-level link is critical for JIT/JIS scheduling, dock assignment, and logistics coordination at the OEM rec',
    CONSTRAINT pk_supply_delivery_schedule PRIMARY KEY(`supply_delivery_schedule_id`)
) COMMENT 'JIT/JIS delivery schedule line issued against a scheduling agreement, specifying exact quantities and delivery dates/times for a part to a plant dock. Captures schedule line date, time, required quantity, cumulative quantity, schedule type (firm, forecast, JIS sequence), dock door, and transmission status (sent, acknowledged, revised). Drives supplier production and logistics planning. Sourced from SAP MM schedule lines (EKET).';

CREATE OR REPLACE TABLE `automotive_ecm`.`supply`.`supply_ppap_submission` (
    `supply_ppap_submission_id` BIGINT COMMENT 'Unique identifier for the supply_ppap_submission data product (auto-inserted pre-linking).',
    `fmea_id` BIGINT COMMENT 'Foreign key linking to quality.fmea. Business justification: PPAP submissions require DFMEA and PFMEA documentation as mandatory elements per AIAG PPAP requirements. This link enables validation that required failure mode analysis is complete, supports risk ass',
    `inbound_part_id` BIGINT COMMENT 'Foreign key linking to supply.inbound_part. Business justification: A PPAP submission is always for a specific purchased part number. Linking supply_ppap_submission to inbound_part establishes the part context for the approval process and enables traceability from par',
    `model_id` BIGINT COMMENT 'Foreign key linking to vehicle.model. Business justification: PPAP submissions under IATF 16949 are tied to specific vehicle programs/models. Regulators and quality auditors require traceability from PPAP submission to vehicle model. This link enables program-le',
    `supplier_id` BIGINT COMMENT 'Foreign key linking to supply.supply_supplier. Business justification: supply_ppap_submission is completely isolated with only its PK defined. A PPAP submission is always made by a specific supplier — this FK is essential to connect the submission to the supplier master ',
    `supplier_part_approval_id` BIGINT COMMENT 'Foreign key linking to supply.supplier_part_approval. Business justification: A PPAP submission is the formal process record that results in a supplier_part_approval outcome. The submission (child) references the approval record (parent) to link the process to its formal approv',
    `supplier_plant_id` BIGINT COMMENT 'Foreign key linking to supply.supply_supplier_plant. Business justification: PPAP submissions are made by a specific manufacturing plant of the supplier, not just the supplier entity. Linking to supply_supplier_plant captures which plants process is being approved, which is c',
    CONSTRAINT pk_supply_ppap_submission PRIMARY KEY(`supply_ppap_submission_id`)
) COMMENT 'Production Part Approval Process submission record tracking the formal approval of a suppliers manufacturing process for a specific part. Captures PPAP level (1–5), submission date, part number, supplier, engineering change level, submission reason (new part, engineering change, tooling move), PPAP elements checklist status, PSW (Part Submission Warrant) status, and approval/rejection date. Integrates with PTC Windchill and SAP QM. SSOT for PPAP compliance.';

CREATE OR REPLACE TABLE `automotive_ecm`.`supply`.`inbound_shipment` (
    `inbound_shipment_id` BIGINT COMMENT 'System-generated unique identifier for the inbound shipment record.',
    `carrier_id` BIGINT COMMENT 'Foreign key linking to logistics.carrier. Business justification: REQUIRED: Carrier performance & cost reporting uses inbound shipment data; linking enables carrier KPI aggregation.',
    `company_code_id` BIGINT COMMENT 'Foreign key linking to finance.company_code. Business justification: Shipments are received by legal entities (company codes) for customs clearance, import duty calculation, and VAT/tax determination based on receiving legal entity jurisdiction.',
    `cost_center_id` BIGINT COMMENT 'Foreign key linking to finance.cost_center. Business justification: Freight costs and receiving/inspection labor are allocated to logistics or receiving cost centers for transportation cost analysis and warehouse budget management.',
    `vehicle_compound_id` BIGINT COMMENT 'Foreign key linking to logistics.vehicle_compound. Business justification: JIT/JIS sequencing operations require inbound parts delivered to vehicle compounds adjacent to assembly plants for line-side staging before production consumption. Common in automotive for sequenced p',
    `purchase_order_id` BIGINT COMMENT 'Foreign key linking to supply.supply_purchase_order. Business justification: An inbound shipment is made against a purchase order. Linking inbound_shipment to supply_purchase_order enables PO-level goods receipt tracking, three-way matching (PO-shipment-invoice), and delivery ',
    `plant_id` BIGINT COMMENT 'Identifier of the OEM plant receiving the shipment.',
    `storage_location_id` BIGINT COMMENT 'Foreign key linking to inventory.storage_location. Business justification: Inbound shipments must specify receiving storage location for dock-to-stock process, bin allocation, and warehouse management. Enables automated goods receipt posting and inventory placement tracking.',
    `regulatory_requirement_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_requirement. Business justification: Shipment Regulatory Check links inbound shipments to the regulatory_requirement governing hazardous material or import/export rules.',
    `supplier_id` BIGINT COMMENT 'Foreign key linking to supply.supply_supplier. Business justification: Associate inbound shipment with internal supplier master',
    `supplier_plant_id` BIGINT COMMENT 'Foreign key linking to supply.supply_supplier_plant. Business justification: An inbound shipment originates from a specific supplier plant. Linking inbound_shipment to supply_supplier_plant captures the origin plant for logistics tracking, customs documentation, and plant-leve',
    `vehicle_order_id` BIGINT COMMENT 'Foreign key linking to sales.vehicle_order. Business justification: LOGISTICS & WARRANTY: Associating inbound shipments with vehicle orders allows tracking of part receipt dates for warranty and delivery performance reporting.',
    `actual_arrival_timestamp` TIMESTAMP COMMENT 'Real date and time when the shipment was received at the dock.',
    `asn_number` STRING COMMENT 'Unique identifier supplied by the supplier to announce the shipment in advance.',
    `container_count` STRING COMMENT 'Number of containers included in the shipment.',
    `currency_code` STRING COMMENT 'Three‑letter ISO currency code for the freight cost.. Valid values are `^[A-Z]{3}$`',
    `customs_declaration_number` STRING COMMENT 'Identifier assigned by customs for the import declaration.',
    `delivery_window_end` TIMESTAMP COMMENT 'End of the agreed delivery time window at the receiving dock.',
    `delivery_window_start` TIMESTAMP COMMENT 'Start of the agreed delivery time window at the receiving dock.',
    `departure_timestamp` TIMESTAMP COMMENT 'Date and time when the shipment left the suppliers dock.',
    `estimated_arrival_timestamp` TIMESTAMP COMMENT 'Planned date and time of arrival at the receiving dock (ETA).',
    `freight_cost` DECIMAL(18,2) COMMENT 'Total cost charged by the carrier for transporting the shipment.',
    `hazardous_class` STRING COMMENT 'Classification of hazardous material according to UN/ADR standards.',
    `incoterm` STRING COMMENT 'International commercial term defining responsibility and cost allocation. [ENUM-REF-CANDIDATE: EXW|FCA|CPT|CIP|DAT|DAP|DDP — 7 candidates stripped; promote to reference product]',
    `is_expedited` BOOLEAN COMMENT 'Indicates whether the shipment is expedited (true) or standard (false).',
    `is_hazardous` BOOLEAN COMMENT 'True if the shipment contains hazardous materials.',
    `last_status_update_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent change to the shipment status.',
    `material_group` STRING COMMENT 'Classification of the materials contained in the shipment.',
    `mode_of_transport` STRING COMMENT 'Primary mode used to move the shipment from supplier to plant.. Valid values are `road|rail|air|sea`',
    `pallet_count` STRING COMMENT 'Number of pallets used to load the shipment.',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when the shipment record was first created in the system.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the shipment record.',
    `remarks` STRING COMMENT 'Free‑form comments or notes entered by logistics personnel.',
    `shipment_status` STRING COMMENT 'Current processing state of the inbound shipment.. Valid values are `in_transit|arrived|cleared|received|cancelled`',
    `temperature_control_required` BOOLEAN COMMENT 'True if the shipment must be kept within a temperature range.',
    `temperature_max_c` DECIMAL(18,2) COMMENT 'Upper bound of the required temperature range for the shipment.',
    `temperature_min_c` DECIMAL(18,2) COMMENT 'Lower bound of the required temperature range for the shipment.',
    `total_volume_m3` DECIMAL(18,2) COMMENT 'Aggregate volume of the shipment, expressed in cubic meters.',
    `total_weight_kg` DECIMAL(18,2) COMMENT 'Aggregate weight of all items in the shipment, expressed in kilograms.',
    CONSTRAINT pk_inbound_shipment PRIMARY KEY(`inbound_shipment_id`)
) COMMENT 'Tracks an inbound shipment of parts from a supplier plant to an OEM receiving dock. Captures ASN (Advance Shipping Notice) number, carrier, mode of transport (road, rail, air, sea), departure date/time, estimated arrival date/time, actual arrival date/time, total weight, total volume, number of containers/pallets, customs declaration number, and shipment status (in transit, arrived, cleared, received). Integrates with SAP MM inbound delivery (VL31N).';

CREATE OR REPLACE TABLE `automotive_ecm`.`supply`.`supplier_scorecard` (
    `supplier_scorecard_id` BIGINT COMMENT 'System-generated unique identifier for each supplier scorecard record.',
    `cost_center_id` BIGINT COMMENT 'Foreign key linking to finance.cost_center. Business justification: Supplier performance management is performed by quality or procurement cost centers that need to track supplier development costs and performance monitoring activities.',
    `supplier_id` BIGINT COMMENT 'Foreign key linking to supply.supply_supplier. Business justification: Connect supplier scorecard to internal supplier master',
    `supplier_plant_id` BIGINT COMMENT 'Foreign key linking to supply.supply_supplier_plant. Business justification: Supplier scorecards in automotive are often evaluated at the plant level — a supplier may have multiple plants with different performance profiles. Linking supplier_scorecard to supply_supplier_plant ',
    `compliance_score` DECIMAL(18,2) COMMENT 'Score measuring adherence to regulatory and internal compliance requirements.',
    `corrective_action_description` STRING COMMENT 'Free‑text description of actions the supplier must take to address deficiencies.',
    `corrective_action_flag` BOOLEAN COMMENT 'True when the supplier must undertake corrective actions.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when the scorecard record was first created in the system.',
    `delivery_quantity_accuracy_pct` DECIMAL(18,2) COMMENT 'Ratio of delivered quantity to ordered quantity, expressed as a percent.',
    `evaluation_date` TIMESTAMP COMMENT 'Exact timestamp when the scorecard was completed.',
    `evaluation_period_end` DATE COMMENT 'Last calendar day of the period covered by the scorecard.',
    `evaluation_period_start` DATE COMMENT 'First calendar day of the period covered by the scorecard.',
    `evaluator_name` STRING COMMENT 'Full name of the internal evaluator responsible for the scorecard.',
    `notes` STRING COMMENT 'Additional comments or observations captured during the evaluation.',
    `otd_percentage` DECIMAL(18,2) COMMENT 'Percentage of deliveries that arrived on or before the agreed delivery date.',
    `overall_score` DECIMAL(18,2) COMMENT 'Aggregated weighted score combining all KPI values for the evaluation period.',
    `performance_tier` STRING COMMENT 'Categorical tier assigned based on the overall score.. Valid values are `preferred|approved|conditional|disqualified`',
    `ppap_on_time_completion_rate` DECIMAL(18,2) COMMENT 'Percentage of PPAP submissions completed within the agreed timeframe.',
    `ppm_defect_rate` DECIMAL(18,2) COMMENT 'Defect rate expressed in parts per million for supplied parts during the period.',
    `responsiveness_score` DECIMAL(18,2) COMMENT 'Score reflecting the suppliers responsiveness to inquiries and change requests.',
    `review_status` STRING COMMENT 'Indicates whether the scorecard is still being drafted, has been finalized, or has been reviewed by management.. Valid values are `draft|finalized|reviewed`',
    `risk_score` DECIMAL(18,2) COMMENT 'Composite risk rating derived from financial, operational, and compliance factors.',
    `scorecard_number` STRING COMMENT 'Human‑readable identifier assigned to the scorecard, used for reporting and audit trails.',
    `scoring_methodology_version` STRING COMMENT 'Identifier of the scoring model version used for this evaluation.',
    `source_system` STRING COMMENT 'Enterprise system that originated the scorecard data.. Valid values are `SAP|Windchill|Other`',
    `supplier_scorecard_status` STRING COMMENT 'Current state of the scorecard in its lifecycle.. Valid values are `pending|completed|archived`',
    `sustainability_score` DECIMAL(18,2) COMMENT 'Score reflecting the suppliers environmental and sustainability initiatives.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time of the most recent modification to the scorecard.',
    CONSTRAINT pk_supplier_scorecard PRIMARY KEY(`supplier_scorecard_id`)
) COMMENT 'Periodic (monthly/quarterly) performance evaluation record for a supplier across key KPIs including PPM (Parts Per Million defect rate), OTD (On-Time Delivery percentage), delivery quantity accuracy, PPAP on-time completion rate, responsiveness score, and overall supplier rating. Captures evaluation period, scoring methodology version, individual KPI values, weighted total score, performance tier (preferred, approved, conditional, disqualified), and corrective action flag.';

CREATE OR REPLACE TABLE `automotive_ecm`.`supply`.`corrective_action` (
    `corrective_action_id` BIGINT COMMENT 'Unique identifier for the supply_corrective_action data product (auto-inserted pre-linking).',
    `cost_center_id` BIGINT COMMENT 'Foreign key linking to finance.cost_center. Business justification: Corrective actions incur costs (containment, sorting, rework, supplier visits) that must be allocated to quality or production cost centers for defect cost tracking.',
    `gl_account_id` BIGINT COMMENT 'Foreign key linking to finance.gl_account. Business justification: Supplier quality costs (scrap, rework, premium freight, containment) must post to specific GL accounts for cost of poor quality (COPQ) reporting and supplier chargeback.',
    `inbound_inspection_id` BIGINT COMMENT 'Foreign key linking to supply.inbound_inspection. Business justification: A corrective action is often triggered by a specific incoming inspection failure. Linking supply_corrective_action to inbound_inspection provides the quality evidence that initiated the SCAR, enabling',
    `inbound_part_id` BIGINT COMMENT 'Foreign key linking to supply.inbound_part. Business justification: A corrective action is raised for a specific non-conforming part. Linking supply_corrective_action to inbound_part enables part-level SCAR history, repeat defect tracking, and part-level quality risk ',
    `inbound_shipment_id` BIGINT COMMENT 'Foreign key linking to supply.inbound_shipment. Business justification: A corrective action may be raised against a specific inbound shipment that contained defective or non-conforming parts. Linking to inbound_shipment enables shipment-level quality traceability and supp',
    `supplier_id` BIGINT COMMENT 'Foreign key linking to supply.supply_supplier. Business justification: Corrective actions are issued by a supplier; adding supply_supplier_id FK provides the necessary parent link and resolves the silo.',
    `supplier_plant_id` BIGINT COMMENT 'Foreign key linking to supply.supply_supplier_plant. Business justification: Corrective actions are directed at a specific supplier plants manufacturing process. Linking to supply_supplier_plant enables plant-level SCAR tracking and ensures the corrective action is routed to ',
    `supplier_scorecard_id` BIGINT COMMENT 'Foreign key linking to supply.supplier_scorecard. Business justification: A supplier corrective action request (SCAR) is typically triggered by a poor scorecard evaluation. Linking supply_corrective_action to supplier_scorecard establishes the causal chain from performance ',
    CONSTRAINT pk_corrective_action PRIMARY KEY(`corrective_action_id`)
) COMMENT 'Supplier corrective action request (SCAR) issued when a supplier fails to meet quality, delivery, or compliance requirements. Captures SCAR number, triggering event (PPM breach, OTD failure, audit finding), root cause category, 8D report reference, containment action, permanent corrective action, verification date, and closure status. Drives supplier development and continuous improvement programs.';

CREATE OR REPLACE TABLE `automotive_ecm`.`supply`.`inbound_inspection` (
    `inbound_inspection_id` BIGINT COMMENT 'System-generated unique identifier for each inbound inspection record.',
    `cost_center_id` BIGINT COMMENT 'Foreign key linking to finance.cost_center. Business justification: Inspection activities are performed by quality cost centers that need to track inspection labor and equipment costs for quality department budget management.',
    `inbound_part_id` BIGINT COMMENT 'Foreign key linking to supply.inbound_part. Business justification: inbound_inspection has part_number and part_revision as denormalized strings. Adding inbound_part_id normalizes this to the supply domains part master. part_number becomes redundant; part_revision ma',
    `inbound_shipment_id` BIGINT COMMENT 'Foreign key linking to supply.inbound_shipment. Business justification: An incoming quality inspection is performed on parts received in a specific inbound shipment. Linking inbound_inspection to inbound_shipment enables shipment-level quality tracking, lot traceability, ',
    `sku_master_id` BIGINT COMMENT 'Foreign key linking to inventory.sku_master. Business justification: Inspection results are recorded per SKU to update quality status and determine stock availability.',
    `supplier_id` BIGINT COMMENT 'Foreign key linking to supply.supply_supplier. Business justification: An incoming inspection is for parts from a specific supplier. Adding supply_supplier_id to inbound_inspection enables supplier-level quality analytics (PPM tracking, defect rate trends) without requir',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the inspection record was first created in the system.',
    `defect_count` STRING COMMENT 'Total number of defects identified in the inspected sample.',
    `defect_rate_ppm` DECIMAL(18,2) COMMENT 'Defects per million units calculated for the inspected lot.',
    `defect_type_codes` STRING COMMENT 'Comma‑separated list of defect classification codes (e.g., surface, dimensional, functional).',
    `disposition` STRING COMMENT 'Action taken after inspection (accept, return to supplier, sort and use, or rework).. Valid values are `accept|return_to_supplier|sort_and_use|rework`',
    `inspection_location` STRING COMMENT 'Plant or line code where the inspection was carried out.',
    `inspection_lot_number` STRING COMMENT 'External identifier assigned by the plant for the inspection lot.',
    `inspection_method` STRING COMMENT 'Method used for the inspection (AQL sampling, 100% check, or skip‑lot).. Valid values are `aql_sampling|full_inspection|skip_lot`',
    `inspection_result` STRING COMMENT 'Overall outcome of the inspection based on defect criteria.. Valid values are `pass|fail|conditional_release`',
    `inspection_status` STRING COMMENT 'Current lifecycle status of the inspection record.. Valid values are `open|in_progress|completed|released|rejected|cancelled`',
    `inspection_timestamp` TIMESTAMP COMMENT 'Date and time when the inspection was performed at the plant.',
    `sample_size` STRING COMMENT 'Number of units selected for inspection according to the sampling plan.',
    `source_system` STRING COMMENT 'Originating system of the record (e.g., SAP QM, MES).',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the inspection record.',
    CONSTRAINT pk_inbound_inspection PRIMARY KEY(`inbound_inspection_id`)
) COMMENT 'Incoming quality inspection record for parts received from a supplier at an OEM plant. Captures inspection lot number, inspection date, part number, supplier, sample size, inspection method (AQL sampling, 100% check, skip-lot), number of defects found, defect type codes, inspection result (pass, fail, conditional release), and disposition (accept, return to supplier, sort and use). Integrates with SAP QM inspection lots.';

CREATE OR REPLACE TABLE `automotive_ecm`.`supply`.`price_agreement` (
    `price_agreement_id` BIGINT COMMENT 'System-generated unique identifier for the price agreement record.',
    `commodity_group_id` BIGINT COMMENT 'Foreign key linking to supply.commodity_group. Business justification: Price agreements are negotiated within commodity groups in automotive procurement. Linking price_agreement to commodity_group enables commodity-level price benchmarking, annual price reduction trackin',
    `company_code_id` BIGINT COMMENT 'Foreign key linking to finance.company_code. Business justification: Price agreements are legal contracts that must be owned by a legal entity (company code) for contract validity and intercompany pricing compliance.',
    `organization_account_id` BIGINT COMMENT 'Foreign key linking to customer.organization_account. Business justification: Fleet and commercial contracts often include pass-through pricing or customer-negotiated supplier terms. Tracks customer-specific supplier pricing agreements, enables customer cost transparency report',
    `gl_account_id` BIGINT COMMENT 'Foreign key linking to finance.gl_account. Business justification: Price agreements tie to a GL account to record purchase price variances and contract liabilities.',
    `inbound_part_id` BIGINT COMMENT 'Foreign key linking to supply.inbound_part. Business justification: price_agreement has part_number as a denormalized string. A price agreement is for a specific purchased part. Adding inbound_part_id normalizes this to the supply domains part master, enabling part-l',
    `model_id` BIGINT COMMENT 'Foreign key linking to vehicle.model. Business justification: Price agreements in automotive are negotiated per vehicle program/model, with annual price reduction commitments tied to model lifecycle. Linking price_agreement.model_id → vehicle.model.model_id supp',
    `payment_term_id` BIGINT COMMENT 'Foreign key linking to billing.payment_term. Business justification: Price agreements in automotive supply contracts specify payment terms (net 30/60/90, early payment discounts, milestone payments). Critical for cash flow management, supplier negotiations, and total c',
    `profit_center_id` BIGINT COMMENT 'Foreign key linking to finance.profit_center. Business justification: Price agreements impact profit center margins and material cost structures. Essential for segment profitability analysis and business unit cost management.',
    `regulatory_requirement_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_requirement. Business justification: Pricing agreements for regulated commodities must reference compliance requirements that affect cost (conflict minerals reporting, REACH substance restrictions). Critical for total cost of compliance ',
    `rfq_response_id` BIGINT COMMENT 'Foreign key linking to supply.rfq_response. Business justification: A price agreement is the formal commercial outcome of an RFQ process — it is awarded based on a specific rfq_response. Linking price_agreement to rfq_response establishes the procurement audit trail f',
    `sku_master_id` BIGINT COMMENT 'Foreign key linking to inventory.sku_master. Business justification: Price agreements are negotiated per part/SKU; linking provides pricing data for inventory valuation and costing.',
    `sourcing_nomination_id` BIGINT COMMENT 'Foreign key linking to supply.sourcing_nomination. Business justification: A price agreement is the commercial outcome of a sourcing nomination process. Linking price_agreement to sourcing_nomination completes the procurement chain: nomination → RFQ → response → price agreem',
    `supplier_id` BIGINT COMMENT 'Foreign key linking to supply.supply_supplier. Business justification: Associate price agreement with internal supplier master',
    `supplier_plant_id` BIGINT COMMENT 'Foreign key linking to supply.supply_supplier_plant. Business justification: Price agreements in automotive are often plant-specific — the same supplier may have different pricing from different plants due to logistics, tooling, and labor costs. Linking to supply_supplier_plan',
    `actual_otd_percent` DECIMAL(18,2) COMMENT 'Measured on‑time delivery performance of the supplier for the current period.',
    `actual_ppm` DECIMAL(18,2) COMMENT 'Measured defect rate of supplied parts for the current period.',
    `agreement_number` STRING COMMENT 'External business identifier assigned to the price agreement by the OEM.',
    `agreement_type` STRING COMMENT 'Classification of the agreement indicating its primary purpose (e.g., price, cost, service, tooling).. Valid values are `price|cost|service|tooling`',
    `annual_price_reduction_commitment` DECIMAL(18,2) COMMENT 'Percentage reduction in price committed by the supplier each year.',
    `compliance_approval_status` STRING COMMENT 'Status of internal compliance review for the agreement.. Valid values are `approved|pending|rejected`',
    `compliance_document_ref` STRING COMMENT 'Reference identifier for the compliance documentation attached to the agreement.',
    `contract_scope` STRING COMMENT 'Narrative defining the parts, volumes, and geographic regions covered by the agreement.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when the price agreement record was first created in the system.',
    `currency_code` STRING COMMENT 'Three‑letter ISO 4217 code of the currency used for the unit price.. Valid values are `^[A-Z]{3}$`',
    `early_termination_allowed` BOOLEAN COMMENT 'Indicates whether the agreement may be terminated before the end date without penalty.',
    `effective_end_date` DATE COMMENT 'Date on which the price agreement expires or is terminated; null if open‑ended.',
    `effective_start_date` DATE COMMENT 'Date on which the price agreement becomes binding.',
    `penalty_clause` STRING COMMENT 'Text describing penalties for non‑compliance such as late delivery or quality breaches.',
    `price_adjustment_trigger` STRING COMMENT 'Condition that can trigger a price change during the agreement (material index, foreign exchange, or none).. Valid values are `material_index|foreign_exchange|none`',
    `price_agreement_description` STRING COMMENT 'Free‑form text describing the purpose, scope, and any special conditions of the agreement.',
    `price_agreement_status` STRING COMMENT 'Current lifecycle status of the price agreement.. Valid values are `active|expired|under_negotiation|draft|suspended`',
    `renewal_notice_period_days` STRING COMMENT 'Number of days notice required to exercise a renewal option.',
    `renewal_option` STRING COMMENT 'Specifies if the agreement auto‑renews, requires manual renewal, or does not renew.. Valid values are `auto|manual|none`',
    `target_otd_percent` DECIMAL(18,2) COMMENT 'Contractual target for supplier on‑time delivery performance.',
    `target_ppm` DECIMAL(18,2) COMMENT 'Maximum acceptable defect rate for supplied parts under the agreement.',
    `termination_notice_period_days` STRING COMMENT 'Number of days notice required to terminate the agreement early.',
    `tooling_amortization_terms` STRING COMMENT 'Terms describing how tooling costs are amortized over the agreement period.',
    `total_annual_volume` DECIMAL(18,2) COMMENT 'Maximum total quantity of the part that may be purchased under the agreement each year.',
    `unit_of_measure` STRING COMMENT 'Measurement unit used for the agreed price and volume (e.g., piece, kilogram).. Valid values are `piece|kg|liter|meter`',
    `unit_price` DECIMAL(18,2) COMMENT 'Negotiated price per unit of the part for the agreement period.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time of the most recent modification to the price agreement record.',
    `version_number` STRING COMMENT 'Sequential version number of the agreement reflecting amendments.',
    CONSTRAINT pk_price_agreement PRIMARY KEY(`price_agreement_id`)
) COMMENT 'Formally agreed piece price and commercial terms between the OEM and a supplier for a specific part over a defined period. Captures agreement number, part number, supplier, effective date, expiry date, agreed unit price, currency, annual price reduction commitment (APR), tooling amortization terms, price adjustment triggers (material index, FX), and agreement status (active, expired, under negotiation). Distinct from the purchase order — this is the commercial price framework.';

CREATE OR REPLACE TABLE `automotive_ecm`.`supply`.`commodity_group` (
    `commodity_group_id` BIGINT COMMENT 'Unique surrogate identifier for the commodity group. _canonical_skip_reason: Entity is a reference lookup used for classification of purchased parts.',
    `cost_center_id` BIGINT COMMENT 'Foreign key linking to finance.cost_center. Business justification: Commodity management is performed by strategic sourcing cost centers that need to track commodity strategy development costs and category management activities.',
    `parent_commodity_group_id` BIGINT COMMENT 'Identifier of the parent commodity group for hierarchical classification.',
    `regulatory_requirement_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_requirement. Business justification: Commodity categories (lithium batteries, airbag inflators, refrigerants) have specific regulatory requirements (UN 38.3, FMVSS 208, F-gas regulations). Critical for sourcing strategy and supplier qual',
    `supplier_id` BIGINT COMMENT 'Foreign key linking to supply.supply_supplier. Business justification: Associate commodity group with responsible supplier for governance',
    `applicable_regions` STRING COMMENT 'Comma‑separated list of ISO 3166‑1 alpha‑3 country codes where the commodity group is used.',
    `average_cost_usd` DECIMAL(18,2) COMMENT 'Average unit cost in US dollars for items within the commodity group.',
    `commodity_category` STRING COMMENT 'High‑level category grouping similar commodity groups.. Valid values are `metal|plastic|electronic|chemical|textile`',
    `commodity_code` STRING COMMENT 'Unique alphanumeric code identifying the commodity group as defined in SAP MM.',
    `commodity_group_code` STRING COMMENT 'Business code used to identify the commodity group in source systems.',
    `commodity_group_description` STRING COMMENT 'Detailed description of the commodity family, its typical applications and characteristics.',
    `commodity_group_name` STRING COMMENT 'Human‑readable name of the commodity family (e.g., Electronics, Castings).',
    `commodity_group_status` STRING COMMENT 'Current lifecycle status of the commodity group.. Valid values are `active|inactive|deprecated`',
    `commodity_group_type` STRING COMMENT 'Classification of the commodity group by its role in the supply chain.. Valid values are `raw_material|component|subassembly|finished_good`',
    `commodity_manager` STRING COMMENT 'Name of the internal manager responsible for the commodity group.',
    `compliance_standards` STRING COMMENT 'List of regulatory standards applicable to the commodity group. [ENUM-REF-CANDIDATE: REACH|RoHS|ISO9001|IATF16949|EPA|CARB — promote to reference product]',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when the commodity group record was first created in the source system.',
    `currency_code` STRING COMMENT 'Default currency used for cost references in this commodity group.. Valid values are `^[A-Z]{3}$`',
    `effective_end_date` DATE COMMENT 'Date when the commodity group is retired or no longer valid.',
    `effective_from` DATE COMMENT 'Date from which the commodity group definition is valid.',
    `effective_start_date` DATE COMMENT 'Date when the commodity group becomes effective for use.',
    `effective_until` DATE COMMENT 'Date after which the commodity group definition is no longer valid (null if indefinite).',
    `hazardous_material_description` STRING COMMENT 'Description of the hazardous characteristics or classifications for the commodity group.',
    `hazardous_material_flag` BOOLEAN COMMENT 'Indicates whether the commodity group contains hazardous materials.',
    `is_confidential` BOOLEAN COMMENT 'Indicates whether the commodity group contains confidential pricing or strategic information.',
    `is_global` BOOLEAN COMMENT 'Indicates whether the commodity group is applicable across all plants and regions.',
    `lead_time_max_days` STRING COMMENT 'Longest typical supplier lead time for items in this commodity group.',
    `lead_time_min_days` STRING COMMENT 'Shortest typical supplier lead time for items in this commodity group.',
    `notes` STRING COMMENT 'Free‑form comments or additional information about the commodity group.',
    `regulatory_compliance_flag` BOOLEAN COMMENT 'True if the commodity group is subject to regulatory compliance requirements (e.g., REACH, RoHS).',
    `risk_factor` STRING COMMENT 'Comma‑separated list of primary supply‑chain risks (e.g., single source, geopolitical, regulatory).',
    `risk_score` DECIMAL(18,2) COMMENT 'Numerical risk rating (0‑100) for the commodity group based on supplier performance and material hazards.',
    `source_system` STRING COMMENT 'Name of the operational system of record that supplied the commodity group data (e.g., SAP_MM, PTC_Windchill).',
    `strategic_classification` STRING COMMENT 'Kraljic matrix classification indicating the strategic importance of the commodity.. Valid values are `strategic|leverage|bottleneck|non-critical`',
    `sustainability_score` DECIMAL(18,2) COMMENT 'Score reflecting environmental impact and sustainability of the commodity group.',
    `typical_price_range_high` DECIMAL(18,2) COMMENT 'Upper bound of typical unit price for items in this commodity group.',
    `typical_price_range_low` DECIMAL(18,2) COMMENT 'Lower bound of typical unit price for items in this commodity group.',
    `unit_of_measure` STRING COMMENT 'Standard unit of measure used for the commodity group.. Valid values are `kg|piece|liter|meter`',
    `updated_by` STRING COMMENT 'User or system that performed the latest update to the commodity group record.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time of the most recent update to the commodity group record.',
    `version_number` STRING COMMENT 'Version identifier for changes to the commodity group definition.',
    `volume_per_unit_cbm` DECIMAL(18,2) COMMENT 'Typical volume of a single unit within the commodity group, expressed in cubic meters.',
    `weight_per_unit_kg` DECIMAL(18,2) COMMENT 'Typical weight of a single unit within the commodity group, expressed in kilograms.',
    `created_by` STRING COMMENT 'User or system that initially created the commodity group record.',
    CONSTRAINT pk_commodity_group PRIMARY KEY(`commodity_group_id`)
) COMMENT 'Master reference table for commodity_group. ';

-- ========= FOREIGN KEYS =========
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ADD CONSTRAINT `fk_supply_supplier_part_approval_inbound_part_id` FOREIGN KEY (`inbound_part_id`) REFERENCES `automotive_ecm`.`supply`.`inbound_part`(`inbound_part_id`);
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ADD CONSTRAINT `fk_supply_supplier_part_approval_supplier_id` FOREIGN KEY (`supplier_id`) REFERENCES `automotive_ecm`.`supply`.`supplier`(`supplier_id`);
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ADD CONSTRAINT `fk_supply_supplier_part_approval_supplier_plant_id` FOREIGN KEY (`supplier_plant_id`) REFERENCES `automotive_ecm`.`supply`.`supplier_plant`(`supplier_plant_id`);
ALTER TABLE `automotive_ecm`.`supply`.`supplier_plant` ADD CONSTRAINT `fk_supply_supplier_plant_supplier_id` FOREIGN KEY (`supplier_id`) REFERENCES `automotive_ecm`.`supply`.`supplier`(`supplier_id`);
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ADD CONSTRAINT `fk_supply_inbound_part_commodity_group_id` FOREIGN KEY (`commodity_group_id`) REFERENCES `automotive_ecm`.`supply`.`commodity_group`(`commodity_group_id`);
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ADD CONSTRAINT `fk_supply_inbound_part_supplier_id` FOREIGN KEY (`supplier_id`) REFERENCES `automotive_ecm`.`supply`.`supplier`(`supplier_id`);
ALTER TABLE `automotive_ecm`.`supply`.`sourcing_nomination` ADD CONSTRAINT `fk_supply_sourcing_nomination_commodity_group_id` FOREIGN KEY (`commodity_group_id`) REFERENCES `automotive_ecm`.`supply`.`commodity_group`(`commodity_group_id`);
ALTER TABLE `automotive_ecm`.`supply`.`sourcing_nomination` ADD CONSTRAINT `fk_supply_sourcing_nomination_inbound_part_id` FOREIGN KEY (`inbound_part_id`) REFERENCES `automotive_ecm`.`supply`.`inbound_part`(`inbound_part_id`);
ALTER TABLE `automotive_ecm`.`supply`.`sourcing_nomination` ADD CONSTRAINT `fk_supply_sourcing_nomination_supplier_id` FOREIGN KEY (`supplier_id`) REFERENCES `automotive_ecm`.`supply`.`supplier`(`supplier_id`);
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ADD CONSTRAINT `fk_supply_rfq_commodity_group_id` FOREIGN KEY (`commodity_group_id`) REFERENCES `automotive_ecm`.`supply`.`commodity_group`(`commodity_group_id`);
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ADD CONSTRAINT `fk_supply_rfq_inbound_part_id` FOREIGN KEY (`inbound_part_id`) REFERENCES `automotive_ecm`.`supply`.`inbound_part`(`inbound_part_id`);
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ADD CONSTRAINT `fk_supply_rfq_sourcing_nomination_id` FOREIGN KEY (`sourcing_nomination_id`) REFERENCES `automotive_ecm`.`supply`.`sourcing_nomination`(`sourcing_nomination_id`);
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ADD CONSTRAINT `fk_supply_rfq_supplier_id` FOREIGN KEY (`supplier_id`) REFERENCES `automotive_ecm`.`supply`.`supplier`(`supplier_id`);
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ADD CONSTRAINT `fk_supply_rfq_response_rfq_id` FOREIGN KEY (`rfq_id`) REFERENCES `automotive_ecm`.`supply`.`rfq`(`rfq_id`);
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ADD CONSTRAINT `fk_supply_rfq_response_supplier_id` FOREIGN KEY (`supplier_id`) REFERENCES `automotive_ecm`.`supply`.`supplier`(`supplier_id`);
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ADD CONSTRAINT `fk_supply_rfq_response_supplier_plant_id` FOREIGN KEY (`supplier_plant_id`) REFERENCES `automotive_ecm`.`supply`.`supplier_plant`(`supplier_plant_id`);
ALTER TABLE `automotive_ecm`.`supply`.`purchase_order` ADD CONSTRAINT `fk_supply_purchase_order_price_agreement_id` FOREIGN KEY (`price_agreement_id`) REFERENCES `automotive_ecm`.`supply`.`price_agreement`(`price_agreement_id`);
ALTER TABLE `automotive_ecm`.`supply`.`purchase_order` ADD CONSTRAINT `fk_supply_purchase_order_scheduling_agreement_id` FOREIGN KEY (`scheduling_agreement_id`) REFERENCES `automotive_ecm`.`supply`.`scheduling_agreement`(`scheduling_agreement_id`);
ALTER TABLE `automotive_ecm`.`supply`.`purchase_order` ADD CONSTRAINT `fk_supply_purchase_order_supplier_id` FOREIGN KEY (`supplier_id`) REFERENCES `automotive_ecm`.`supply`.`supplier`(`supplier_id`);
ALTER TABLE `automotive_ecm`.`supply`.`purchase_order` ADD CONSTRAINT `fk_supply_purchase_order_supplier_plant_id` FOREIGN KEY (`supplier_plant_id`) REFERENCES `automotive_ecm`.`supply`.`supplier_plant`(`supplier_plant_id`);
ALTER TABLE `automotive_ecm`.`supply`.`po_line` ADD CONSTRAINT `fk_supply_po_line_inbound_part_id` FOREIGN KEY (`inbound_part_id`) REFERENCES `automotive_ecm`.`supply`.`inbound_part`(`inbound_part_id`);
ALTER TABLE `automotive_ecm`.`supply`.`po_line` ADD CONSTRAINT `fk_supply_po_line_price_agreement_id` FOREIGN KEY (`price_agreement_id`) REFERENCES `automotive_ecm`.`supply`.`price_agreement`(`price_agreement_id`);
ALTER TABLE `automotive_ecm`.`supply`.`po_line` ADD CONSTRAINT `fk_supply_po_line_purchase_order_id` FOREIGN KEY (`purchase_order_id`) REFERENCES `automotive_ecm`.`supply`.`purchase_order`(`purchase_order_id`);
ALTER TABLE `automotive_ecm`.`supply`.`po_line` ADD CONSTRAINT `fk_supply_po_line_supplier_id` FOREIGN KEY (`supplier_id`) REFERENCES `automotive_ecm`.`supply`.`supplier`(`supplier_id`);
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ADD CONSTRAINT `fk_supply_scheduling_agreement_inbound_part_id` FOREIGN KEY (`inbound_part_id`) REFERENCES `automotive_ecm`.`supply`.`inbound_part`(`inbound_part_id`);
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ADD CONSTRAINT `fk_supply_scheduling_agreement_price_agreement_id` FOREIGN KEY (`price_agreement_id`) REFERENCES `automotive_ecm`.`supply`.`price_agreement`(`price_agreement_id`);
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ADD CONSTRAINT `fk_supply_scheduling_agreement_supplier_id` FOREIGN KEY (`supplier_id`) REFERENCES `automotive_ecm`.`supply`.`supplier`(`supplier_id`);
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ADD CONSTRAINT `fk_supply_scheduling_agreement_supplier_plant_id` FOREIGN KEY (`supplier_plant_id`) REFERENCES `automotive_ecm`.`supply`.`supplier_plant`(`supplier_plant_id`);
ALTER TABLE `automotive_ecm`.`supply`.`supply_delivery_schedule` ADD CONSTRAINT `fk_supply_supply_delivery_schedule_inbound_part_id` FOREIGN KEY (`inbound_part_id`) REFERENCES `automotive_ecm`.`supply`.`inbound_part`(`inbound_part_id`);
ALTER TABLE `automotive_ecm`.`supply`.`supply_delivery_schedule` ADD CONSTRAINT `fk_supply_supply_delivery_schedule_inbound_shipment_id` FOREIGN KEY (`inbound_shipment_id`) REFERENCES `automotive_ecm`.`supply`.`inbound_shipment`(`inbound_shipment_id`);
ALTER TABLE `automotive_ecm`.`supply`.`supply_delivery_schedule` ADD CONSTRAINT `fk_supply_supply_delivery_schedule_scheduling_agreement_id` FOREIGN KEY (`scheduling_agreement_id`) REFERENCES `automotive_ecm`.`supply`.`scheduling_agreement`(`scheduling_agreement_id`);
ALTER TABLE `automotive_ecm`.`supply`.`supply_delivery_schedule` ADD CONSTRAINT `fk_supply_supply_delivery_schedule_supplier_id` FOREIGN KEY (`supplier_id`) REFERENCES `automotive_ecm`.`supply`.`supplier`(`supplier_id`);
ALTER TABLE `automotive_ecm`.`supply`.`supply_delivery_schedule` ADD CONSTRAINT `fk_supply_supply_delivery_schedule_supplier_plant_id` FOREIGN KEY (`supplier_plant_id`) REFERENCES `automotive_ecm`.`supply`.`supplier_plant`(`supplier_plant_id`);
ALTER TABLE `automotive_ecm`.`supply`.`supply_ppap_submission` ADD CONSTRAINT `fk_supply_supply_ppap_submission_inbound_part_id` FOREIGN KEY (`inbound_part_id`) REFERENCES `automotive_ecm`.`supply`.`inbound_part`(`inbound_part_id`);
ALTER TABLE `automotive_ecm`.`supply`.`supply_ppap_submission` ADD CONSTRAINT `fk_supply_supply_ppap_submission_supplier_id` FOREIGN KEY (`supplier_id`) REFERENCES `automotive_ecm`.`supply`.`supplier`(`supplier_id`);
ALTER TABLE `automotive_ecm`.`supply`.`supply_ppap_submission` ADD CONSTRAINT `fk_supply_supply_ppap_submission_supplier_part_approval_id` FOREIGN KEY (`supplier_part_approval_id`) REFERENCES `automotive_ecm`.`supply`.`supplier_part_approval`(`supplier_part_approval_id`);
ALTER TABLE `automotive_ecm`.`supply`.`supply_ppap_submission` ADD CONSTRAINT `fk_supply_supply_ppap_submission_supplier_plant_id` FOREIGN KEY (`supplier_plant_id`) REFERENCES `automotive_ecm`.`supply`.`supplier_plant`(`supplier_plant_id`);
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` ADD CONSTRAINT `fk_supply_inbound_shipment_purchase_order_id` FOREIGN KEY (`purchase_order_id`) REFERENCES `automotive_ecm`.`supply`.`purchase_order`(`purchase_order_id`);
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` ADD CONSTRAINT `fk_supply_inbound_shipment_supplier_id` FOREIGN KEY (`supplier_id`) REFERENCES `automotive_ecm`.`supply`.`supplier`(`supplier_id`);
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` ADD CONSTRAINT `fk_supply_inbound_shipment_supplier_plant_id` FOREIGN KEY (`supplier_plant_id`) REFERENCES `automotive_ecm`.`supply`.`supplier_plant`(`supplier_plant_id`);
ALTER TABLE `automotive_ecm`.`supply`.`supplier_scorecard` ADD CONSTRAINT `fk_supply_supplier_scorecard_supplier_id` FOREIGN KEY (`supplier_id`) REFERENCES `automotive_ecm`.`supply`.`supplier`(`supplier_id`);
ALTER TABLE `automotive_ecm`.`supply`.`supplier_scorecard` ADD CONSTRAINT `fk_supply_supplier_scorecard_supplier_plant_id` FOREIGN KEY (`supplier_plant_id`) REFERENCES `automotive_ecm`.`supply`.`supplier_plant`(`supplier_plant_id`);
ALTER TABLE `automotive_ecm`.`supply`.`corrective_action` ADD CONSTRAINT `fk_supply_corrective_action_inbound_inspection_id` FOREIGN KEY (`inbound_inspection_id`) REFERENCES `automotive_ecm`.`supply`.`inbound_inspection`(`inbound_inspection_id`);
ALTER TABLE `automotive_ecm`.`supply`.`corrective_action` ADD CONSTRAINT `fk_supply_corrective_action_inbound_part_id` FOREIGN KEY (`inbound_part_id`) REFERENCES `automotive_ecm`.`supply`.`inbound_part`(`inbound_part_id`);
ALTER TABLE `automotive_ecm`.`supply`.`corrective_action` ADD CONSTRAINT `fk_supply_corrective_action_inbound_shipment_id` FOREIGN KEY (`inbound_shipment_id`) REFERENCES `automotive_ecm`.`supply`.`inbound_shipment`(`inbound_shipment_id`);
ALTER TABLE `automotive_ecm`.`supply`.`corrective_action` ADD CONSTRAINT `fk_supply_corrective_action_supplier_id` FOREIGN KEY (`supplier_id`) REFERENCES `automotive_ecm`.`supply`.`supplier`(`supplier_id`);
ALTER TABLE `automotive_ecm`.`supply`.`corrective_action` ADD CONSTRAINT `fk_supply_corrective_action_supplier_plant_id` FOREIGN KEY (`supplier_plant_id`) REFERENCES `automotive_ecm`.`supply`.`supplier_plant`(`supplier_plant_id`);
ALTER TABLE `automotive_ecm`.`supply`.`corrective_action` ADD CONSTRAINT `fk_supply_corrective_action_supplier_scorecard_id` FOREIGN KEY (`supplier_scorecard_id`) REFERENCES `automotive_ecm`.`supply`.`supplier_scorecard`(`supplier_scorecard_id`);
ALTER TABLE `automotive_ecm`.`supply`.`inbound_inspection` ADD CONSTRAINT `fk_supply_inbound_inspection_inbound_part_id` FOREIGN KEY (`inbound_part_id`) REFERENCES `automotive_ecm`.`supply`.`inbound_part`(`inbound_part_id`);
ALTER TABLE `automotive_ecm`.`supply`.`inbound_inspection` ADD CONSTRAINT `fk_supply_inbound_inspection_inbound_shipment_id` FOREIGN KEY (`inbound_shipment_id`) REFERENCES `automotive_ecm`.`supply`.`inbound_shipment`(`inbound_shipment_id`);
ALTER TABLE `automotive_ecm`.`supply`.`inbound_inspection` ADD CONSTRAINT `fk_supply_inbound_inspection_supplier_id` FOREIGN KEY (`supplier_id`) REFERENCES `automotive_ecm`.`supply`.`supplier`(`supplier_id`);
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ADD CONSTRAINT `fk_supply_price_agreement_commodity_group_id` FOREIGN KEY (`commodity_group_id`) REFERENCES `automotive_ecm`.`supply`.`commodity_group`(`commodity_group_id`);
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ADD CONSTRAINT `fk_supply_price_agreement_inbound_part_id` FOREIGN KEY (`inbound_part_id`) REFERENCES `automotive_ecm`.`supply`.`inbound_part`(`inbound_part_id`);
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ADD CONSTRAINT `fk_supply_price_agreement_rfq_response_id` FOREIGN KEY (`rfq_response_id`) REFERENCES `automotive_ecm`.`supply`.`rfq_response`(`rfq_response_id`);
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ADD CONSTRAINT `fk_supply_price_agreement_sourcing_nomination_id` FOREIGN KEY (`sourcing_nomination_id`) REFERENCES `automotive_ecm`.`supply`.`sourcing_nomination`(`sourcing_nomination_id`);
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ADD CONSTRAINT `fk_supply_price_agreement_supplier_id` FOREIGN KEY (`supplier_id`) REFERENCES `automotive_ecm`.`supply`.`supplier`(`supplier_id`);
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ADD CONSTRAINT `fk_supply_price_agreement_supplier_plant_id` FOREIGN KEY (`supplier_plant_id`) REFERENCES `automotive_ecm`.`supply`.`supplier_plant`(`supplier_plant_id`);
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ADD CONSTRAINT `fk_supply_commodity_group_parent_commodity_group_id` FOREIGN KEY (`parent_commodity_group_id`) REFERENCES `automotive_ecm`.`supply`.`commodity_group`(`commodity_group_id`);
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ADD CONSTRAINT `fk_supply_commodity_group_supplier_id` FOREIGN KEY (`supplier_id`) REFERENCES `automotive_ecm`.`supply`.`supplier`(`supplier_id`);

-- ========= TAGS =========
ALTER SCHEMA `automotive_ecm`.`supply` SET TAGS ('dbx_division' = 'operations');
ALTER SCHEMA `automotive_ecm`.`supply` SET TAGS ('dbx_domain' = 'supply');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` SET TAGS ('dbx_subdomain' = 'quality_approval');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `supplier_part_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Supplier Part Approval ID');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `apqp_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Apqp Plan Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `control_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Control Plan Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `cost_center_id` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `inbound_part_id` SET TAGS ('dbx_business_glossary_term' = 'Inbound Part Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `regulatory_requirement_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Requirement Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `supplier_id` SET TAGS ('dbx_business_glossary_term' = 'Supply Supplier Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `supplier_plant_id` SET TAGS ('dbx_business_glossary_term' = 'Supply Supplier Plant Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `approval_number` SET TAGS ('dbx_business_glossary_term' = 'Approval Number');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `approval_outcome` SET TAGS ('dbx_business_glossary_term' = 'Approval Outcome');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `approval_outcome` SET TAGS ('dbx_value_regex' = 'approved|interim_approval|rejected');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `approval_score` SET TAGS ('dbx_business_glossary_term' = 'Approval Score');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `approver_name` SET TAGS ('dbx_business_glossary_term' = 'Approver Name');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `capability_study_status` SET TAGS ('dbx_business_glossary_term' = 'Capability Study Status');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `capability_study_status` SET TAGS ('dbx_value_regex' = 'completed|pending|not_applicable');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `classification` SET TAGS ('dbx_business_glossary_term' = 'Classification');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `classification` SET TAGS ('dbx_value_regex' = 'critical|major|minor|optional');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Comments');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `control_plan_status` SET TAGS ('dbx_business_glossary_term' = 'Control Plan Status');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `control_plan_status` SET TAGS ('dbx_value_regex' = 'completed|pending|not_applicable');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `cost_usd` SET TAGS ('dbx_business_glossary_term' = 'Cost (USD)');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `design_records_status` SET TAGS ('dbx_business_glossary_term' = 'Design Records Status');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `design_records_status` SET TAGS ('dbx_value_regex' = 'completed|pending|not_applicable');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `lead_time_days` SET TAGS ('dbx_business_glossary_term' = 'Lead Time (Days)');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `lifecycle_status` SET TAGS ('dbx_business_glossary_term' = 'Lifecycle Status');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `lifecycle_status` SET TAGS ('dbx_value_regex' = 'draft|submitted|under_review|approved|rejected|expired');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `msa_status` SET TAGS ('dbx_business_glossary_term' = 'Measurement System Analysis (MSA) Status');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `msa_status` SET TAGS ('dbx_value_regex' = 'completed|pending|not_applicable');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `overall_status` SET TAGS ('dbx_business_glossary_term' = 'Overall Approval Status');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `overall_status` SET TAGS ('dbx_value_regex' = 'active|inactive|expired|revoked');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `pfmea_status` SET TAGS ('dbx_business_glossary_term' = 'PFMEA Status');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `pfmea_status` SET TAGS ('dbx_value_regex' = 'completed|pending|not_applicable');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `ppap_submission_level` SET TAGS ('dbx_business_glossary_term' = 'PPAP Submission Level');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `ppap_submission_level` SET TAGS ('dbx_value_regex' = 'level_1|level_2|level_3|level_4|level_5');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `quality_rating` SET TAGS ('dbx_business_glossary_term' = 'Quality Rating');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `quality_rating` SET TAGS ('dbx_value_regex' = 'A|B|C|D|E|F');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `record_audit_created` SET TAGS ('dbx_business_glossary_term' = 'Record Audit Created');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `record_audit_updated` SET TAGS ('dbx_business_glossary_term' = 'Record Audit Updated');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `regulatory_compliance_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Compliance Flag');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `risk_level` SET TAGS ('dbx_business_glossary_term' = 'Risk Level');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `risk_level` SET TAGS ('dbx_value_regex' = 'high|medium|low');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `sample_parts_status` SET TAGS ('dbx_business_glossary_term' = 'Sample Parts Status');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `sample_parts_status` SET TAGS ('dbx_value_regex' = 'completed|pending|not_applicable');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `submission_date` SET TAGS ('dbx_business_glossary_term' = 'Submission Date');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_part_approval` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `automotive_ecm`.`supply`.`supplier` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `automotive_ecm`.`supply`.`supplier` SET TAGS ('dbx_subdomain' = 'supplier_management');
ALTER TABLE `automotive_ecm`.`supply`.`supplier` ALTER COLUMN `supplier_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Key for supply_supplier');
ALTER TABLE `automotive_ecm`.`supply`.`supplier` ALTER COLUMN `account_id` SET TAGS ('dbx_business_glossary_term' = 'Billing Account Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`supplier` ALTER COLUMN `jurisdiction_id` SET TAGS ('dbx_business_glossary_term' = 'Jurisdiction Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_plant` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_plant` SET TAGS ('dbx_subdomain' = 'supplier_management');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_plant` ALTER COLUMN `supplier_plant_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Key for supply_supplier_plant');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_plant` ALTER COLUMN `supplier_id` SET TAGS ('dbx_business_glossary_term' = 'Supply Supplier Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` SET TAGS ('dbx_subdomain' = 'sourcing_procurement');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `inbound_part_id` SET TAGS ('dbx_business_glossary_term' = 'Inbound Part ID');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `commodity_group_id` SET TAGS ('dbx_internal' = 'true');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `control_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Control Plan Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `cost_center_id` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Customer Party Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `inspection_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Inspection Plan Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `jurisdiction_id` SET TAGS ('dbx_business_glossary_term' = 'Jurisdiction Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `part_master_id` SET TAGS ('dbx_business_glossary_term' = 'Part Master Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `platform_id` SET TAGS ('dbx_business_glossary_term' = 'Platform Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `regulatory_requirement_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Requirement Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `sku_master_id` SET TAGS ('dbx_business_glossary_term' = 'Sku Master Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `supplier_id` SET TAGS ('dbx_business_glossary_term' = 'Supply Supplier Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `tax_code_id` SET TAGS ('dbx_business_glossary_term' = 'Tax Code Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `average_cost` SET TAGS ('dbx_business_glossary_term' = 'Average Cost');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `country_of_origin` SET TAGS ('dbx_business_glossary_term' = 'Country of Origin (ISO‑3)');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `country_of_origin` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (ISO‑4217)');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `customs_tariff_code` SET TAGS ('dbx_business_glossary_term' = 'Customs Tariff Code');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `customs_tariff_code` SET TAGS ('dbx_value_regex' = '^[0-9]{8}$');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `effective_from` SET TAGS ('dbx_business_glossary_term' = 'Effective From Date');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `effective_until` SET TAGS ('dbx_business_glossary_term' = 'Effective Until Date');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `engineering_change_level` SET TAGS ('dbx_business_glossary_term' = 'Engineering Change Level');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `engineering_change_level` SET TAGS ('dbx_value_regex' = 'A|B|C|D|E');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `hazardous_material_flag` SET TAGS ('dbx_business_glossary_term' = 'Hazardous Material Flag');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `height_mm` SET TAGS ('dbx_business_glossary_term' = 'Height (mm)');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `last_received_date` SET TAGS ('dbx_business_glossary_term' = 'Last Received Date');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `last_received_quantity` SET TAGS ('dbx_business_glossary_term' = 'Last Received Quantity');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `lead_time_days` SET TAGS ('dbx_business_glossary_term' = 'Lead Time (Days)');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `length_mm` SET TAGS ('dbx_business_glossary_term' = 'Length (mm)');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `lifecycle_status` SET TAGS ('dbx_business_glossary_term' = 'Lifecycle Status');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `lifecycle_status` SET TAGS ('dbx_value_regex' = 'active|inactive|discontinued|pending');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `lot_size` SET TAGS ('dbx_business_glossary_term' = 'Lot Size');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `material_type` SET TAGS ('dbx_business_glossary_term' = 'Material Type');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `material_type` SET TAGS ('dbx_value_regex' = 'raw|sub-assembly|ckd_kit|finished|service');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `minimum_order_quantity` SET TAGS ('dbx_business_glossary_term' = 'Minimum Order Quantity (MOQ)');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `oem_part_number` SET TAGS ('dbx_business_glossary_term' = 'OEM Part Number (OPN)');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `ppap_status` SET TAGS ('dbx_business_glossary_term' = 'PPAP Approval Status');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `ppap_status` SET TAGS ('dbx_value_regex' = 'approved|rejected|pending|under_review');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `price_uom` SET TAGS ('dbx_business_glossary_term' = 'Price Unit of Measure');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `price_uom` SET TAGS ('dbx_value_regex' = 'EA|KG|L|M|SET');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `reorder_point_quantity` SET TAGS ('dbx_business_glossary_term' = 'Reorder Point Quantity');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `safety_stock_quantity` SET TAGS ('dbx_business_glossary_term' = 'Safety Stock Quantity');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `source_system` SET TAGS ('dbx_business_glossary_term' = 'Source System');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `source_system` SET TAGS ('dbx_value_regex' = 'SAP|Windchill|Other');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `supplier_part_number` SET TAGS ('dbx_business_glossary_term' = 'Supplier Part Number (SPN)');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `unit_of_measure` SET TAGS ('dbx_business_glossary_term' = 'Unit of Measure (UOM)');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `unit_of_measure` SET TAGS ('dbx_value_regex' = 'EA|KG|L|M|SET');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `weight_kg` SET TAGS ('dbx_business_glossary_term' = 'Weight (kg)');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_part` ALTER COLUMN `width_mm` SET TAGS ('dbx_business_glossary_term' = 'Width (mm)');
ALTER TABLE `automotive_ecm`.`supply`.`sourcing_nomination` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `automotive_ecm`.`supply`.`sourcing_nomination` SET TAGS ('dbx_subdomain' = 'sourcing_procurement');
ALTER TABLE `automotive_ecm`.`supply`.`sourcing_nomination` ALTER COLUMN `sourcing_nomination_id` SET TAGS ('dbx_business_glossary_term' = 'Sourcing Nomination ID');
ALTER TABLE `automotive_ecm`.`supply`.`sourcing_nomination` ALTER COLUMN `commodity_group_id` SET TAGS ('dbx_business_glossary_term' = 'Commodity Group Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`sourcing_nomination` ALTER COLUMN `organization_account_id` SET TAGS ('dbx_business_glossary_term' = 'Customer Organization Account Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`sourcing_nomination` ALTER COLUMN `fleet_contract_id` SET TAGS ('dbx_business_glossary_term' = 'Fleet Contract Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`sourcing_nomination` ALTER COLUMN `inbound_part_id` SET TAGS ('dbx_business_glossary_term' = 'Inbound Part Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`sourcing_nomination` ALTER COLUMN `model_id` SET TAGS ('dbx_business_glossary_term' = 'Model Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`sourcing_nomination` ALTER COLUMN `supplier_id` SET TAGS ('dbx_business_glossary_term' = 'Supply Supplier Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`sourcing_nomination` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Comments');
ALTER TABLE `automotive_ecm`.`supply`.`sourcing_nomination` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `automotive_ecm`.`supply`.`sourcing_nomination` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `automotive_ecm`.`supply`.`sourcing_nomination` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = 'USD|EUR|JPY|GBP|CAD|AUD');
ALTER TABLE `automotive_ecm`.`supply`.`sourcing_nomination` ALTER COLUMN `effective_end_date` SET TAGS ('dbx_business_glossary_term' = 'Effective End Date');
ALTER TABLE `automotive_ecm`.`supply`.`sourcing_nomination` ALTER COLUMN `effective_start_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Start Date');
ALTER TABLE `automotive_ecm`.`supply`.`sourcing_nomination` ALTER COLUMN `is_jis` SET TAGS ('dbx_business_glossary_term' = 'Just‑In‑Sequence Requirement Flag');
ALTER TABLE `automotive_ecm`.`supply`.`sourcing_nomination` ALTER COLUMN `is_jit` SET TAGS ('dbx_business_glossary_term' = 'Just‑In‑Time Requirement Flag');
ALTER TABLE `automotive_ecm`.`supply`.`sourcing_nomination` ALTER COLUMN `kit_type` SET TAGS ('dbx_business_glossary_term' = 'Kit Type');
ALTER TABLE `automotive_ecm`.`supply`.`sourcing_nomination` ALTER COLUMN `kit_type` SET TAGS ('dbx_value_regex' = 'CKD|SKD|none');
ALTER TABLE `automotive_ecm`.`supply`.`sourcing_nomination` ALTER COLUMN `model_year` SET TAGS ('dbx_business_glossary_term' = 'Model Year (MY)');
ALTER TABLE `automotive_ecm`.`supply`.`sourcing_nomination` ALTER COLUMN `nominated_volume` SET TAGS ('dbx_business_glossary_term' = 'Nominated Volume');
ALTER TABLE `automotive_ecm`.`supply`.`sourcing_nomination` ALTER COLUMN `nomination_date` SET TAGS ('dbx_business_glossary_term' = 'Nomination Date');
ALTER TABLE `automotive_ecm`.`supply`.`sourcing_nomination` ALTER COLUMN `nomination_number` SET TAGS ('dbx_business_glossary_term' = 'Nomination Number');
ALTER TABLE `automotive_ecm`.`supply`.`sourcing_nomination` ALTER COLUMN `nomination_status` SET TAGS ('dbx_business_glossary_term' = 'Nomination Status');
ALTER TABLE `automotive_ecm`.`supply`.`sourcing_nomination` ALTER COLUMN `nomination_status` SET TAGS ('dbx_value_regex' = 'nominated|confirmed|withdrawn|rejected');
ALTER TABLE `automotive_ecm`.`supply`.`sourcing_nomination` ALTER COLUMN `priority` SET TAGS ('dbx_business_glossary_term' = 'Nomination Priority');
ALTER TABLE `automotive_ecm`.`supply`.`sourcing_nomination` ALTER COLUMN `priority` SET TAGS ('dbx_value_regex' = 'high|medium|low');
ALTER TABLE `automotive_ecm`.`supply`.`sourcing_nomination` ALTER COLUMN `program_code` SET TAGS ('dbx_business_glossary_term' = 'Program Code');
ALTER TABLE `automotive_ecm`.`supply`.`sourcing_nomination` ALTER COLUMN `region` SET TAGS ('dbx_business_glossary_term' = 'Supply Region');
ALTER TABLE `automotive_ecm`.`supply`.`sourcing_nomination` ALTER COLUMN `region` SET TAGS ('dbx_value_regex' = 'NAM|EME|APAC|LATAM|AFR');
ALTER TABLE `automotive_ecm`.`supply`.`sourcing_nomination` ALTER COLUMN `risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Risk Rating');
ALTER TABLE `automotive_ecm`.`supply`.`sourcing_nomination` ALTER COLUMN `risk_rating` SET TAGS ('dbx_value_regex' = 'low|medium|high');
ALTER TABLE `automotive_ecm`.`supply`.`sourcing_nomination` ALTER COLUMN `sor_reference` SET TAGS ('dbx_business_glossary_term' = 'Statement of Requirements Reference');
ALTER TABLE `automotive_ecm`.`supply`.`sourcing_nomination` ALTER COLUMN `target_piece_price` SET TAGS ('dbx_business_glossary_term' = 'Target Piece Price');
ALTER TABLE `automotive_ecm`.`supply`.`sourcing_nomination` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `automotive_ecm`.`supply`.`rfq` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `automotive_ecm`.`supply`.`rfq` SET TAGS ('dbx_subdomain' = 'sourcing_procurement');
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ALTER COLUMN `rfq_id` SET TAGS ('dbx_business_glossary_term' = 'Request for Quotation ID');
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ALTER COLUMN `apqp_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Apqp Plan Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ALTER COLUMN `commodity_group_id` SET TAGS ('dbx_business_glossary_term' = 'Commodity Group Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ALTER COLUMN `cost_center_id` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ALTER COLUMN `organization_account_id` SET TAGS ('dbx_business_glossary_term' = 'Customer Organization Account Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ALTER COLUMN `inbound_part_id` SET TAGS ('dbx_business_glossary_term' = 'Inbound Part Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ALTER COLUMN `model_id` SET TAGS ('dbx_business_glossary_term' = 'Model Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ALTER COLUMN `part_master_id` SET TAGS ('dbx_business_glossary_term' = 'Part Master Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ALTER COLUMN `sourcing_nomination_id` SET TAGS ('dbx_business_glossary_term' = 'Sourcing Nomination Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ALTER COLUMN `supplier_id` SET TAGS ('dbx_business_glossary_term' = 'Supply Supplier Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'RFQ Approval Status');
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'PENDING|APPROVED|REJECTED');
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ALTER COLUMN `attachment_flag` SET TAGS ('dbx_business_glossary_term' = 'Attachment Flag');
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ALTER COLUMN `compliance_requirements` SET TAGS ('dbx_business_glossary_term' = 'Compliance Requirements');
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'RFQ Record Creation Timestamp');
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ALTER COLUMN `delivery_schedule_type` SET TAGS ('dbx_business_glossary_term' = 'Delivery Schedule Type');
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ALTER COLUMN `delivery_schedule_type` SET TAGS ('dbx_value_regex' = 'JIT|JIS|STANDARD');
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ALTER COLUMN `discount_amount` SET TAGS ('dbx_business_glossary_term' = 'Discount Amount');
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ALTER COLUMN `issue_timestamp` SET TAGS ('dbx_business_glossary_term' = 'RFQ Issue Timestamp');
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ALTER COLUMN `last_status_change_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Status Change Timestamp');
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ALTER COLUMN `net_price_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Price Amount');
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'RFQ Notes');
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ALTER COLUMN `priority` SET TAGS ('dbx_business_glossary_term' = 'RFQ Priority');
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ALTER COLUMN `priority` SET TAGS ('dbx_value_regex' = 'HIGH|MEDIUM|LOW');
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ALTER COLUMN `program_model_year` SET TAGS ('dbx_business_glossary_term' = 'Program / Model Year');
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ALTER COLUMN `quantity_estimate` SET TAGS ('dbx_business_glossary_term' = 'Estimated Quantity');
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ALTER COLUMN `regulatory_approval_required` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Required Flag');
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ALTER COLUMN `required_delivery_date` SET TAGS ('dbx_business_glossary_term' = 'Required Delivery Date');
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ALTER COLUMN `response_due_date` SET TAGS ('dbx_business_glossary_term' = 'RFQ Response Due Date');
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ALTER COLUMN `rfq_number` SET TAGS ('dbx_business_glossary_term' = 'Request for Quotation Number');
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ALTER COLUMN `rfq_status` SET TAGS ('dbx_business_glossary_term' = 'RFQ Lifecycle Status');
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ALTER COLUMN `rfq_status` SET TAGS ('dbx_value_regex' = 'draft|open|closed|awarded|cancelled|pending');
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ALTER COLUMN `rfq_type` SET TAGS ('dbx_business_glossary_term' = 'RFQ Type');
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ALTER COLUMN `rfq_type` SET TAGS ('dbx_value_regex' = 'NEW_PART|EXISTING_PART|SERVICE|MATERIAL');
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ALTER COLUMN `source_system` SET TAGS ('dbx_business_glossary_term' = 'Source System');
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ALTER COLUMN `target_price_amount` SET TAGS ('dbx_business_glossary_term' = 'Target Price Amount');
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ALTER COLUMN `target_price_currency` SET TAGS ('dbx_business_glossary_term' = 'Target Price Currency');
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ALTER COLUMN `tooling_description` SET TAGS ('dbx_business_glossary_term' = 'Tooling Description');
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ALTER COLUMN `tooling_required` SET TAGS ('dbx_business_glossary_term' = 'Tooling Required Flag');
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ALTER COLUMN `unit_of_measure` SET TAGS ('dbx_business_glossary_term' = 'Unit of Measure');
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ALTER COLUMN `unit_of_measure` SET TAGS ('dbx_value_regex' = 'EA|KG|L|M|SET|BOX');
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'RFQ Record Last Updated Timestamp');
ALTER TABLE `automotive_ecm`.`supply`.`rfq` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By User');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` SET TAGS ('dbx_subdomain' = 'sourcing_procurement');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ALTER COLUMN `rfq_response_id` SET TAGS ('dbx_business_glossary_term' = 'RFQ Response ID');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ALTER COLUMN `cost_center_id` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ALTER COLUMN `payment_term_id` SET TAGS ('dbx_business_glossary_term' = 'Payment Term Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ALTER COLUMN `rfq_id` SET TAGS ('dbx_business_glossary_term' = 'RFQ ID');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ALTER COLUMN `supplier_id` SET TAGS ('dbx_business_glossary_term' = 'Supply Supplier Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ALTER COLUMN `supplier_plant_id` SET TAGS ('dbx_business_glossary_term' = 'Supply Supplier Plant Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ALTER COLUMN `amortization_term_months` SET TAGS ('dbx_business_glossary_term' = 'Amortization Term (Months)');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ALTER COLUMN `capacity_commitment` SET TAGS ('dbx_business_glossary_term' = 'Capacity Commitment (CC)');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ALTER COLUMN `capacity_unit` SET TAGS ('dbx_business_glossary_term' = 'Capacity Unit');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ALTER COLUMN `compliance_certifications` SET TAGS ('dbx_business_glossary_term' = 'Compliance Certifications');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ALTER COLUMN `delivery_address` SET TAGS ('dbx_business_glossary_term' = 'Delivery Address');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ALTER COLUMN `delivery_address` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ALTER COLUMN `delivery_address` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ALTER COLUMN `discount_percentage` SET TAGS ('dbx_business_glossary_term' = 'Discount Percentage');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ALTER COLUMN `exceptions_to_sor` SET TAGS ('dbx_business_glossary_term' = 'Exceptions to Statement of Requirements');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ALTER COLUMN `freight_included` SET TAGS ('dbx_business_glossary_term' = 'Freight Included Flag');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ALTER COLUMN `is_preferred_supplier` SET TAGS ('dbx_business_glossary_term' = 'Preferred Supplier Flag');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ALTER COLUMN `lead_time_days` SET TAGS ('dbx_business_glossary_term' = 'Lead Time (Days)');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ALTER COLUMN `quoted_currency` SET TAGS ('dbx_business_glossary_term' = 'Quoted Currency (QC)');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ALTER COLUMN `quoted_quantity` SET TAGS ('dbx_business_glossary_term' = 'Quoted Quantity (QQ)');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ALTER COLUMN `quoted_unit_price` SET TAGS ('dbx_business_glossary_term' = 'Quoted Unit Price (QUP)');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ALTER COLUMN `regulatory_approval_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Status');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ALTER COLUMN `regulatory_approval_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ALTER COLUMN `remarks` SET TAGS ('dbx_business_glossary_term' = 'Remarks');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ALTER COLUMN `response_number` SET TAGS ('dbx_business_glossary_term' = 'RFQ Response Number (RN)');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ALTER COLUMN `response_source` SET TAGS ('dbx_business_glossary_term' = 'Response Source');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ALTER COLUMN `response_source` SET TAGS ('dbx_value_regex' = 'email|portal|api');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ALTER COLUMN `rfq_response_status` SET TAGS ('dbx_business_glossary_term' = 'Response Status');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ALTER COLUMN `rfq_response_status` SET TAGS ('dbx_value_regex' = 'submitted|under_review|accepted|rejected');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ALTER COLUMN `shipping_method` SET TAGS ('dbx_business_glossary_term' = 'Shipping Method');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ALTER COLUMN `shipping_method` SET TAGS ('dbx_value_regex' = 'air|sea|land');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ALTER COLUMN `submission_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Submission Timestamp');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ALTER COLUMN `tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Tax Amount (TA)');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ALTER COLUMN `tooling_cost` SET TAGS ('dbx_business_glossary_term' = 'Tooling Cost (TC)');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ALTER COLUMN `total_price` SET TAGS ('dbx_business_glossary_term' = 'Total Quoted Price (TQP)');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ALTER COLUMN `unit_of_measure` SET TAGS ('dbx_business_glossary_term' = 'Unit of Measure (UOM)');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ALTER COLUMN `unit_of_measure` SET TAGS ('dbx_value_regex' = 'EA|KG|L');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ALTER COLUMN `validity_end_date` SET TAGS ('dbx_business_glossary_term' = 'Validity End Date');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ALTER COLUMN `validity_start_date` SET TAGS ('dbx_business_glossary_term' = 'Validity Start Date');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ALTER COLUMN `warranty_period_months` SET TAGS ('dbx_business_glossary_term' = 'Warranty Period (Months)');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ALTER COLUMN `warranty_type` SET TAGS ('dbx_business_glossary_term' = 'Warranty Type');
ALTER TABLE `automotive_ecm`.`supply`.`rfq_response` ALTER COLUMN `warranty_type` SET TAGS ('dbx_value_regex' = 'standard|extended');
ALTER TABLE `automotive_ecm`.`supply`.`purchase_order` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `automotive_ecm`.`supply`.`purchase_order` SET TAGS ('dbx_subdomain' = 'sourcing_procurement');
ALTER TABLE `automotive_ecm`.`supply`.`purchase_order` ALTER COLUMN `purchase_order_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Key for supply_purchase_order');
ALTER TABLE `automotive_ecm`.`supply`.`purchase_order` ALTER COLUMN `company_code_id` SET TAGS ('dbx_business_glossary_term' = 'Company Code Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`purchase_order` ALTER COLUMN `cost_center_id` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`purchase_order` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Customer Party Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`purchase_order` ALTER COLUMN `price_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Price Agreement Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`purchase_order` ALTER COLUMN `profit_center_id` SET TAGS ('dbx_business_glossary_term' = 'Profit Center Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`purchase_order` ALTER COLUMN `scheduling_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Scheduling Agreement Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`purchase_order` ALTER COLUMN `supplier_id` SET TAGS ('dbx_business_glossary_term' = 'Supply Supplier Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`purchase_order` ALTER COLUMN `supplier_plant_id` SET TAGS ('dbx_business_glossary_term' = 'Supply Supplier Plant Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`purchase_order` ALTER COLUMN `vehicle_order_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Order Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`po_line` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `automotive_ecm`.`supply`.`po_line` SET TAGS ('dbx_subdomain' = 'sourcing_procurement');
ALTER TABLE `automotive_ecm`.`supply`.`po_line` ALTER COLUMN `po_line_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Key for supply_po_line');
ALTER TABLE `automotive_ecm`.`supply`.`po_line` ALTER COLUMN `gl_account_id` SET TAGS ('dbx_business_glossary_term' = 'Gl Account Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`po_line` ALTER COLUMN `inbound_part_id` SET TAGS ('dbx_business_glossary_term' = 'Inbound Part Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`po_line` ALTER COLUMN `order_line_id` SET TAGS ('dbx_business_glossary_term' = 'Order Line Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`po_line` ALTER COLUMN `price_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Price Agreement Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`po_line` ALTER COLUMN `profit_center_id` SET TAGS ('dbx_business_glossary_term' = 'Profit Center Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`po_line` ALTER COLUMN `purchase_order_id` SET TAGS ('dbx_business_glossary_term' = 'Supply Purchase Order Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`po_line` ALTER COLUMN `sku_master_id` SET TAGS ('dbx_business_glossary_term' = 'Sku Master Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`po_line` ALTER COLUMN `supplier_id` SET TAGS ('dbx_business_glossary_term' = 'Supply Supplier Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` SET TAGS ('dbx_subdomain' = 'delivery_scheduling');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `scheduling_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Scheduling Agreement ID');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `company_code_id` SET TAGS ('dbx_business_glossary_term' = 'Company Code Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `control_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Control Plan Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `cost_center_id` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `fleet_contract_id` SET TAGS ('dbx_business_glossary_term' = 'Fleet Contract Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `inbound_part_id` SET TAGS ('dbx_business_glossary_term' = 'Inbound Part Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `model_id` SET TAGS ('dbx_business_glossary_term' = 'Model Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `part_master_id` SET TAGS ('dbx_business_glossary_term' = 'Part Master Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `price_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Price Agreement Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `regulatory_requirement_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Requirement Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `supplier_id` SET TAGS ('dbx_business_glossary_term' = 'Supply Supplier Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `supplier_plant_id` SET TAGS ('dbx_business_glossary_term' = 'Supply Supplier Plant Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `actual_otd_percent` SET TAGS ('dbx_business_glossary_term' = 'Actual On‑Time Delivery (%)');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `actual_ppm` SET TAGS ('dbx_business_glossary_term' = 'Actual Parts‑Per‑Million (PPM)');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `agreement_number` SET TAGS ('dbx_business_glossary_term' = 'Agreement Number');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `agreement_type` SET TAGS ('dbx_business_glossary_term' = 'Agreement Type');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `agreement_type` SET TAGS ('dbx_value_regex' = 'framework|spot|consignment|service|lease');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `compliance_approval_status` SET TAGS ('dbx_business_glossary_term' = 'Compliance Approval Status');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `compliance_approval_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `compliance_document_ref` SET TAGS ('dbx_business_glossary_term' = 'Compliance Document Reference');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `contract_scope` SET TAGS ('dbx_business_glossary_term' = 'Contract Scope');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `contract_version` SET TAGS ('dbx_business_glossary_term' = 'Contract Version');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = 'USD|EUR|JPY|CNY|GBP');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `delivery_rhythm` SET TAGS ('dbx_business_glossary_term' = 'Delivery Rhythm');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `delivery_rhythm` SET TAGS ('dbx_value_regex' = 'daily|weekly|biweekly|monthly');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `early_termination_allowed` SET TAGS ('dbx_business_glossary_term' = 'Early Termination Allowed');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `end_date` SET TAGS ('dbx_business_glossary_term' = 'Effective End Date');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `kanban_flag` SET TAGS ('dbx_business_glossary_term' = 'Kanban Flag');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `payment_terms` SET TAGS ('dbx_business_glossary_term' = 'Payment Terms');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `payment_terms` SET TAGS ('dbx_value_regex' = 'net30|net45|net60|cash|prepaid');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `penalty_clause` SET TAGS ('dbx_business_glossary_term' = 'Penalty Clause');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `release_horizon_weeks` SET TAGS ('dbx_business_glossary_term' = 'Release Horizon (Weeks)');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `renewal_notice_period_days` SET TAGS ('dbx_business_glossary_term' = 'Renewal Notice Period (Days)');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `renewal_option` SET TAGS ('dbx_business_glossary_term' = 'Renewal Option');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `scheduling_agreement_description` SET TAGS ('dbx_business_glossary_term' = 'Agreement Description');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `scheduling_agreement_status` SET TAGS ('dbx_business_glossary_term' = 'Agreement Status');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `scheduling_agreement_status` SET TAGS ('dbx_value_regex' = 'draft|active|suspended|terminated|expired');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `start_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Start Date');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `target_otd_percent` SET TAGS ('dbx_business_glossary_term' = 'Target On‑Time Delivery (%)');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `target_ppm` SET TAGS ('dbx_business_glossary_term' = 'Target Parts‑Per‑Million (PPM)');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `termination_notice_period_days` SET TAGS ('dbx_business_glossary_term' = 'Termination Notice Period (Days)');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `total_annual_volume` SET TAGS ('dbx_business_glossary_term' = 'Total Annual Volume');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `unit_of_measure` SET TAGS ('dbx_business_glossary_term' = 'Unit of Measure');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `unit_of_measure` SET TAGS ('dbx_value_regex' = 'pcs|kg|liter|meter|unit');
ALTER TABLE `automotive_ecm`.`supply`.`scheduling_agreement` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `automotive_ecm`.`supply`.`supply_delivery_schedule` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `automotive_ecm`.`supply`.`supply_delivery_schedule` SET TAGS ('dbx_subdomain' = 'delivery_scheduling');
ALTER TABLE `automotive_ecm`.`supply`.`supply_delivery_schedule` ALTER COLUMN `supply_delivery_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Key for supply_delivery_schedule');
ALTER TABLE `automotive_ecm`.`supply`.`supply_delivery_schedule` ALTER COLUMN `build_spec_id` SET TAGS ('dbx_business_glossary_term' = 'Build Spec Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`supply_delivery_schedule` ALTER COLUMN `inbound_part_id` SET TAGS ('dbx_business_glossary_term' = 'Inbound Part Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`supply_delivery_schedule` ALTER COLUMN `inbound_shipment_id` SET TAGS ('dbx_business_glossary_term' = 'Inbound Shipment Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`supply_delivery_schedule` ALTER COLUMN `scheduling_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Scheduling Agreement Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`supply_delivery_schedule` ALTER COLUMN `supplier_id` SET TAGS ('dbx_business_glossary_term' = 'Supplier Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`supply_delivery_schedule` ALTER COLUMN `supplier_plant_id` SET TAGS ('dbx_business_glossary_term' = 'Supply Supplier Plant Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`supply_ppap_submission` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `automotive_ecm`.`supply`.`supply_ppap_submission` SET TAGS ('dbx_subdomain' = 'quality_approval');
ALTER TABLE `automotive_ecm`.`supply`.`supply_ppap_submission` ALTER COLUMN `supply_ppap_submission_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Key for supply_ppap_submission');
ALTER TABLE `automotive_ecm`.`supply`.`supply_ppap_submission` ALTER COLUMN `fmea_id` SET TAGS ('dbx_business_glossary_term' = 'Fmea Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`supply_ppap_submission` ALTER COLUMN `inbound_part_id` SET TAGS ('dbx_business_glossary_term' = 'Inbound Part Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`supply_ppap_submission` ALTER COLUMN `model_id` SET TAGS ('dbx_business_glossary_term' = 'Model Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`supply_ppap_submission` ALTER COLUMN `supplier_id` SET TAGS ('dbx_business_glossary_term' = 'Supply Supplier Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`supply_ppap_submission` ALTER COLUMN `supplier_part_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Supplier Part Approval Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`supply_ppap_submission` ALTER COLUMN `supplier_plant_id` SET TAGS ('dbx_business_glossary_term' = 'Supply Supplier Plant Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` SET TAGS ('dbx_subdomain' = 'delivery_scheduling');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` ALTER COLUMN `inbound_shipment_id` SET TAGS ('dbx_business_glossary_term' = 'Inbound Shipment ID');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` ALTER COLUMN `carrier_id` SET TAGS ('dbx_business_glossary_term' = 'Carrier Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` ALTER COLUMN `company_code_id` SET TAGS ('dbx_business_glossary_term' = 'Company Code Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` ALTER COLUMN `cost_center_id` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` ALTER COLUMN `vehicle_compound_id` SET TAGS ('dbx_business_glossary_term' = 'Destination Vehicle Compound Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` ALTER COLUMN `purchase_order_id` SET TAGS ('dbx_business_glossary_term' = 'Supply Purchase Order Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` ALTER COLUMN `plant_id` SET TAGS ('dbx_business_glossary_term' = 'Receiving Plant ID');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` ALTER COLUMN `storage_location_id` SET TAGS ('dbx_business_glossary_term' = 'Receiving Storage Location Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` ALTER COLUMN `regulatory_requirement_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Requirement Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` ALTER COLUMN `supplier_id` SET TAGS ('dbx_business_glossary_term' = 'Supply Supplier Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` ALTER COLUMN `supplier_plant_id` SET TAGS ('dbx_business_glossary_term' = 'Supply Supplier Plant Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` ALTER COLUMN `vehicle_order_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Order Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` ALTER COLUMN `actual_arrival_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Actual Arrival Timestamp');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` ALTER COLUMN `asn_number` SET TAGS ('dbx_business_glossary_term' = 'Advance Shipping Notice (ASN) Number');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` ALTER COLUMN `container_count` SET TAGS ('dbx_business_glossary_term' = 'Container Count');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` ALTER COLUMN `customs_declaration_number` SET TAGS ('dbx_business_glossary_term' = 'Customs Declaration Number');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` ALTER COLUMN `delivery_window_end` SET TAGS ('dbx_business_glossary_term' = 'Delivery Window End');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` ALTER COLUMN `delivery_window_start` SET TAGS ('dbx_business_glossary_term' = 'Delivery Window Start');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` ALTER COLUMN `departure_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Departure Timestamp');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` ALTER COLUMN `estimated_arrival_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Estimated Arrival Timestamp');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` ALTER COLUMN `freight_cost` SET TAGS ('dbx_business_glossary_term' = 'Freight Cost');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` ALTER COLUMN `hazardous_class` SET TAGS ('dbx_business_glossary_term' = 'Hazardous Class');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` ALTER COLUMN `incoterm` SET TAGS ('dbx_business_glossary_term' = 'Incoterm');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` ALTER COLUMN `is_expedited` SET TAGS ('dbx_business_glossary_term' = 'Expedited Shipment Flag');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` ALTER COLUMN `is_hazardous` SET TAGS ('dbx_business_glossary_term' = 'Hazardous Material Flag');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` ALTER COLUMN `last_status_update_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Status Update Timestamp');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` ALTER COLUMN `material_group` SET TAGS ('dbx_business_glossary_term' = 'Material Group');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` ALTER COLUMN `mode_of_transport` SET TAGS ('dbx_business_glossary_term' = 'Mode of Transport');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` ALTER COLUMN `mode_of_transport` SET TAGS ('dbx_value_regex' = 'road|rail|air|sea');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` ALTER COLUMN `pallet_count` SET TAGS ('dbx_business_glossary_term' = 'Pallet Count');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` ALTER COLUMN `record_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` ALTER COLUMN `remarks` SET TAGS ('dbx_business_glossary_term' = 'Remarks');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` ALTER COLUMN `shipment_status` SET TAGS ('dbx_business_glossary_term' = 'Shipment Status');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` ALTER COLUMN `shipment_status` SET TAGS ('dbx_value_regex' = 'in_transit|arrived|cleared|received|cancelled');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` ALTER COLUMN `temperature_control_required` SET TAGS ('dbx_business_glossary_term' = 'Temperature Control Required');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` ALTER COLUMN `temperature_max_c` SET TAGS ('dbx_business_glossary_term' = 'Maximum Temperature (°C)');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` ALTER COLUMN `temperature_min_c` SET TAGS ('dbx_business_glossary_term' = 'Minimum Temperature (°C)');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` ALTER COLUMN `total_volume_m3` SET TAGS ('dbx_business_glossary_term' = 'Total Volume (m³)');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_shipment` ALTER COLUMN `total_weight_kg` SET TAGS ('dbx_business_glossary_term' = 'Total Weight (kg)');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_scorecard` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_scorecard` SET TAGS ('dbx_subdomain' = 'supplier_management');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_scorecard` ALTER COLUMN `supplier_scorecard_id` SET TAGS ('dbx_business_glossary_term' = 'Supplier Scorecard ID');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_scorecard` ALTER COLUMN `cost_center_id` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_scorecard` ALTER COLUMN `supplier_id` SET TAGS ('dbx_business_glossary_term' = 'Supply Supplier Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_scorecard` ALTER COLUMN `supplier_plant_id` SET TAGS ('dbx_business_glossary_term' = 'Supply Supplier Plant Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_scorecard` ALTER COLUMN `compliance_score` SET TAGS ('dbx_business_glossary_term' = 'Compliance Score (CS)');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_scorecard` ALTER COLUMN `corrective_action_description` SET TAGS ('dbx_business_glossary_term' = 'Corrective Action Description');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_scorecard` ALTER COLUMN `corrective_action_flag` SET TAGS ('dbx_business_glossary_term' = 'Corrective Action Required Flag');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_scorecard` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_scorecard` ALTER COLUMN `delivery_quantity_accuracy_pct` SET TAGS ('dbx_business_glossary_term' = 'Delivery Quantity Accuracy Percentage (DQAP)');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_scorecard` ALTER COLUMN `evaluation_date` SET TAGS ('dbx_business_glossary_term' = 'Evaluation Date (Timestamp)');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_scorecard` ALTER COLUMN `evaluation_period_end` SET TAGS ('dbx_business_glossary_term' = 'Evaluation Period End Date');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_scorecard` ALTER COLUMN `evaluation_period_start` SET TAGS ('dbx_business_glossary_term' = 'Evaluation Period Start Date');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_scorecard` ALTER COLUMN `evaluator_name` SET TAGS ('dbx_business_glossary_term' = 'Evaluator Name (EN)');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_scorecard` ALTER COLUMN `evaluator_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_scorecard` ALTER COLUMN `evaluator_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_scorecard` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Evaluator Notes');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_scorecard` ALTER COLUMN `otd_percentage` SET TAGS ('dbx_business_glossary_term' = 'On‑Time Delivery Percentage (OTD)');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_scorecard` ALTER COLUMN `overall_score` SET TAGS ('dbx_business_glossary_term' = 'Overall Supplier Score (OSS)');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_scorecard` ALTER COLUMN `performance_tier` SET TAGS ('dbx_business_glossary_term' = 'Performance Tier (PT)');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_scorecard` ALTER COLUMN `performance_tier` SET TAGS ('dbx_value_regex' = 'preferred|approved|conditional|disqualified');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_scorecard` ALTER COLUMN `ppap_on_time_completion_rate` SET TAGS ('dbx_business_glossary_term' = 'PPAP On‑Time Completion Rate (PPAP‑OTC)');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_scorecard` ALTER COLUMN `ppm_defect_rate` SET TAGS ('dbx_business_glossary_term' = 'Parts‑Per‑Million Defect Rate (PPM)');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_scorecard` ALTER COLUMN `responsiveness_score` SET TAGS ('dbx_business_glossary_term' = 'Responsiveness Score (RS)');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_scorecard` ALTER COLUMN `review_status` SET TAGS ('dbx_business_glossary_term' = 'Review Status (RS)');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_scorecard` ALTER COLUMN `review_status` SET TAGS ('dbx_value_regex' = 'draft|finalized|reviewed');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_scorecard` ALTER COLUMN `risk_score` SET TAGS ('dbx_business_glossary_term' = 'Supplier Risk Score (SRS)');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_scorecard` ALTER COLUMN `scorecard_number` SET TAGS ('dbx_business_glossary_term' = 'Scorecard Number (SCN)');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_scorecard` ALTER COLUMN `scoring_methodology_version` SET TAGS ('dbx_business_glossary_term' = 'Scoring Methodology Version (SMV)');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_scorecard` ALTER COLUMN `source_system` SET TAGS ('dbx_business_glossary_term' = 'Source System (SS)');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_scorecard` ALTER COLUMN `source_system` SET TAGS ('dbx_value_regex' = 'SAP|Windchill|Other');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_scorecard` ALTER COLUMN `supplier_scorecard_status` SET TAGS ('dbx_business_glossary_term' = 'Scorecard Lifecycle Status');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_scorecard` ALTER COLUMN `supplier_scorecard_status` SET TAGS ('dbx_value_regex' = 'pending|completed|archived');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_scorecard` ALTER COLUMN `sustainability_score` SET TAGS ('dbx_business_glossary_term' = 'Sustainability Score (SS)');
ALTER TABLE `automotive_ecm`.`supply`.`supplier_scorecard` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `automotive_ecm`.`supply`.`corrective_action` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `automotive_ecm`.`supply`.`corrective_action` SET TAGS ('dbx_subdomain' = 'supplier_management');
ALTER TABLE `automotive_ecm`.`supply`.`corrective_action` ALTER COLUMN `corrective_action_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Key for supply_corrective_action');
ALTER TABLE `automotive_ecm`.`supply`.`corrective_action` ALTER COLUMN `cost_center_id` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`corrective_action` ALTER COLUMN `gl_account_id` SET TAGS ('dbx_business_glossary_term' = 'Gl Account Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`corrective_action` ALTER COLUMN `inbound_inspection_id` SET TAGS ('dbx_business_glossary_term' = 'Inbound Inspection Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`corrective_action` ALTER COLUMN `inbound_part_id` SET TAGS ('dbx_business_glossary_term' = 'Inbound Part Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`corrective_action` ALTER COLUMN `inbound_shipment_id` SET TAGS ('dbx_business_glossary_term' = 'Inbound Shipment Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`corrective_action` ALTER COLUMN `supplier_id` SET TAGS ('dbx_business_glossary_term' = 'Supply Supplier Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`corrective_action` ALTER COLUMN `supplier_plant_id` SET TAGS ('dbx_business_glossary_term' = 'Supply Supplier Plant Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`corrective_action` ALTER COLUMN `supplier_scorecard_id` SET TAGS ('dbx_business_glossary_term' = 'Supplier Scorecard Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_inspection` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_inspection` SET TAGS ('dbx_subdomain' = 'quality_approval');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_inspection` ALTER COLUMN `inbound_inspection_id` SET TAGS ('dbx_business_glossary_term' = 'Inbound Inspection ID');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_inspection` ALTER COLUMN `cost_center_id` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_inspection` ALTER COLUMN `inbound_part_id` SET TAGS ('dbx_business_glossary_term' = 'Inbound Part Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_inspection` ALTER COLUMN `inbound_shipment_id` SET TAGS ('dbx_business_glossary_term' = 'Inbound Shipment Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_inspection` ALTER COLUMN `sku_master_id` SET TAGS ('dbx_business_glossary_term' = 'Sku Master Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_inspection` ALTER COLUMN `supplier_id` SET TAGS ('dbx_business_glossary_term' = 'Supply Supplier Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_inspection` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_inspection` ALTER COLUMN `defect_count` SET TAGS ('dbx_business_glossary_term' = 'Defect Count');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_inspection` ALTER COLUMN `defect_rate_ppm` SET TAGS ('dbx_business_glossary_term' = 'Defect Rate (PPM)');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_inspection` ALTER COLUMN `defect_type_codes` SET TAGS ('dbx_business_glossary_term' = 'Defect Type Codes');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_inspection` ALTER COLUMN `disposition` SET TAGS ('dbx_business_glossary_term' = 'Inspection Disposition');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_inspection` ALTER COLUMN `disposition` SET TAGS ('dbx_value_regex' = 'accept|return_to_supplier|sort_and_use|rework');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_inspection` ALTER COLUMN `inspection_location` SET TAGS ('dbx_business_glossary_term' = 'Inspection Location (Plant Code)');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_inspection` ALTER COLUMN `inspection_lot_number` SET TAGS ('dbx_business_glossary_term' = 'Inspection Lot Number');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_inspection` ALTER COLUMN `inspection_method` SET TAGS ('dbx_business_glossary_term' = 'Inspection Method');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_inspection` ALTER COLUMN `inspection_method` SET TAGS ('dbx_value_regex' = 'aql_sampling|full_inspection|skip_lot');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_inspection` ALTER COLUMN `inspection_result` SET TAGS ('dbx_business_glossary_term' = 'Inspection Result');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_inspection` ALTER COLUMN `inspection_result` SET TAGS ('dbx_value_regex' = 'pass|fail|conditional_release');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_inspection` ALTER COLUMN `inspection_status` SET TAGS ('dbx_business_glossary_term' = 'Inspection Status');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_inspection` ALTER COLUMN `inspection_status` SET TAGS ('dbx_value_regex' = 'open|in_progress|completed|released|rejected|cancelled');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_inspection` ALTER COLUMN `inspection_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Inspection Timestamp');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_inspection` ALTER COLUMN `sample_size` SET TAGS ('dbx_business_glossary_term' = 'Sample Size');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_inspection` ALTER COLUMN `source_system` SET TAGS ('dbx_business_glossary_term' = 'Source System');
ALTER TABLE `automotive_ecm`.`supply`.`inbound_inspection` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` SET TAGS ('dbx_subdomain' = 'sourcing_procurement');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `price_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Price Agreement ID');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `commodity_group_id` SET TAGS ('dbx_business_glossary_term' = 'Commodity Group Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `company_code_id` SET TAGS ('dbx_business_glossary_term' = 'Company Code Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `organization_account_id` SET TAGS ('dbx_business_glossary_term' = 'Customer Organization Account Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `gl_account_id` SET TAGS ('dbx_business_glossary_term' = 'Gl Account Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `inbound_part_id` SET TAGS ('dbx_business_glossary_term' = 'Inbound Part Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `model_id` SET TAGS ('dbx_business_glossary_term' = 'Model Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `payment_term_id` SET TAGS ('dbx_business_glossary_term' = 'Payment Term Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `profit_center_id` SET TAGS ('dbx_business_glossary_term' = 'Profit Center Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `regulatory_requirement_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Requirement Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `rfq_response_id` SET TAGS ('dbx_business_glossary_term' = 'Rfq Response Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `sku_master_id` SET TAGS ('dbx_business_glossary_term' = 'Sku Master Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `sourcing_nomination_id` SET TAGS ('dbx_business_glossary_term' = 'Sourcing Nomination Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `supplier_id` SET TAGS ('dbx_business_glossary_term' = 'Supply Supplier Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `supplier_plant_id` SET TAGS ('dbx_business_glossary_term' = 'Supply Supplier Plant Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `actual_otd_percent` SET TAGS ('dbx_business_glossary_term' = 'Actual On‑Time Delivery Percentage');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `actual_ppm` SET TAGS ('dbx_business_glossary_term' = 'Actual Parts‑Per‑Million Defect Rate');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `agreement_number` SET TAGS ('dbx_business_glossary_term' = 'Agreement Number');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `agreement_type` SET TAGS ('dbx_business_glossary_term' = 'Agreement Type');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `agreement_type` SET TAGS ('dbx_value_regex' = 'price|cost|service|tooling');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `annual_price_reduction_commitment` SET TAGS ('dbx_business_glossary_term' = 'Annual Price Reduction Commitment (APR)');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `compliance_approval_status` SET TAGS ('dbx_business_glossary_term' = 'Compliance Approval Status');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `compliance_approval_status` SET TAGS ('dbx_value_regex' = 'approved|pending|rejected');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `compliance_document_ref` SET TAGS ('dbx_business_glossary_term' = 'Compliance Document Reference');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `contract_scope` SET TAGS ('dbx_business_glossary_term' = 'Contract Scope');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `early_termination_allowed` SET TAGS ('dbx_business_glossary_term' = 'Early Termination Allowed');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `effective_end_date` SET TAGS ('dbx_business_glossary_term' = 'Effective End Date');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `effective_start_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Start Date');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `penalty_clause` SET TAGS ('dbx_business_glossary_term' = 'Penalty Clause');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `price_adjustment_trigger` SET TAGS ('dbx_business_glossary_term' = 'Price Adjustment Trigger');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `price_adjustment_trigger` SET TAGS ('dbx_value_regex' = 'material_index|foreign_exchange|none');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `price_agreement_description` SET TAGS ('dbx_business_glossary_term' = 'Agreement Description');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `price_agreement_status` SET TAGS ('dbx_business_glossary_term' = 'Agreement Status');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `price_agreement_status` SET TAGS ('dbx_value_regex' = 'active|expired|under_negotiation|draft|suspended');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `renewal_notice_period_days` SET TAGS ('dbx_business_glossary_term' = 'Renewal Notice Period (Days)');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `renewal_option` SET TAGS ('dbx_business_glossary_term' = 'Renewal Option');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `renewal_option` SET TAGS ('dbx_value_regex' = 'auto|manual|none');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `target_otd_percent` SET TAGS ('dbx_business_glossary_term' = 'Target On‑Time Delivery Percentage');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `target_ppm` SET TAGS ('dbx_business_glossary_term' = 'Target Parts‑Per‑Million Defect Rate');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `termination_notice_period_days` SET TAGS ('dbx_business_glossary_term' = 'Termination Notice Period (Days)');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `tooling_amortization_terms` SET TAGS ('dbx_business_glossary_term' = 'Tooling Amortization Terms');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `total_annual_volume` SET TAGS ('dbx_business_glossary_term' = 'Total Annual Volume');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `unit_of_measure` SET TAGS ('dbx_business_glossary_term' = 'Unit of Measure');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `unit_of_measure` SET TAGS ('dbx_value_regex' = 'piece|kg|liter|meter');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `unit_price` SET TAGS ('dbx_business_glossary_term' = 'Agreed Unit Price');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `automotive_ecm`.`supply`.`price_agreement` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Agreement Version Number');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` SET TAGS ('dbx_subdomain' = 'sourcing_procurement');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `commodity_group_id` SET TAGS ('dbx_business_glossary_term' = 'Commodity Group ID');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `cost_center_id` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `parent_commodity_group_id` SET TAGS ('dbx_business_glossary_term' = 'Parent Commodity Group ID');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `regulatory_requirement_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Requirement Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `supplier_id` SET TAGS ('dbx_business_glossary_term' = 'Supply Supplier Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `applicable_regions` SET TAGS ('dbx_business_glossary_term' = 'Applicable Regions');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `average_cost_usd` SET TAGS ('dbx_business_glossary_term' = 'Average Cost (USD)');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `commodity_category` SET TAGS ('dbx_business_glossary_term' = 'Commodity Category');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `commodity_category` SET TAGS ('dbx_value_regex' = 'metal|plastic|electronic|chemical|textile');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `commodity_code` SET TAGS ('dbx_business_glossary_term' = 'Commodity Code');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `commodity_group_code` SET TAGS ('dbx_business_glossary_term' = 'Commodity Group Code (CGC)');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `commodity_group_description` SET TAGS ('dbx_business_glossary_term' = 'Commodity Group Description');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `commodity_group_name` SET TAGS ('dbx_business_glossary_term' = 'Commodity Group Name');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `commodity_group_status` SET TAGS ('dbx_business_glossary_term' = 'Commodity Group Status');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `commodity_group_status` SET TAGS ('dbx_value_regex' = 'active|inactive|deprecated');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `commodity_group_type` SET TAGS ('dbx_business_glossary_term' = 'Commodity Group Type (CGT)');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `commodity_group_type` SET TAGS ('dbx_value_regex' = 'raw_material|component|subassembly|finished_good');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `commodity_manager` SET TAGS ('dbx_business_glossary_term' = 'Commodity Manager');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `compliance_standards` SET TAGS ('dbx_business_glossary_term' = 'Compliance Standards');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (ISO 4217)');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `effective_end_date` SET TAGS ('dbx_business_glossary_term' = 'Effective End Date');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `effective_from` SET TAGS ('dbx_business_glossary_term' = 'Effective From Date');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `effective_start_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Start Date');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `effective_until` SET TAGS ('dbx_business_glossary_term' = 'Effective Until Date');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `hazardous_material_description` SET TAGS ('dbx_business_glossary_term' = 'Hazardous Material Description');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `hazardous_material_flag` SET TAGS ('dbx_business_glossary_term' = 'Hazardous Material Flag');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `is_confidential` SET TAGS ('dbx_business_glossary_term' = 'Confidential Flag');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `is_global` SET TAGS ('dbx_business_glossary_term' = 'Global Applicability Flag');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `lead_time_max_days` SET TAGS ('dbx_business_glossary_term' = 'Maximum Lead Time (Days)');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `lead_time_min_days` SET TAGS ('dbx_business_glossary_term' = 'Minimum Lead Time (Days)');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `regulatory_compliance_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Compliance Flag');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `risk_factor` SET TAGS ('dbx_business_glossary_term' = 'Key Risk Factors');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `risk_score` SET TAGS ('dbx_business_glossary_term' = 'Risk Score');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `source_system` SET TAGS ('dbx_business_glossary_term' = 'Source System');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `strategic_classification` SET TAGS ('dbx_business_glossary_term' = 'Strategic Classification (Kraljic Matrix)');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `strategic_classification` SET TAGS ('dbx_value_regex' = 'strategic|leverage|bottleneck|non-critical');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `sustainability_score` SET TAGS ('dbx_business_glossary_term' = 'Sustainability Score');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `typical_price_range_high` SET TAGS ('dbx_business_glossary_term' = 'Typical Price Range High');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `typical_price_range_low` SET TAGS ('dbx_business_glossary_term' = 'Typical Price Range Low');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `unit_of_measure` SET TAGS ('dbx_business_glossary_term' = 'Unit of Measure (UOM)');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `unit_of_measure` SET TAGS ('dbx_value_regex' = 'kg|piece|liter|meter');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `updated_by` SET TAGS ('dbx_business_glossary_term' = 'Record Updated By');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `volume_per_unit_cbm` SET TAGS ('dbx_business_glossary_term' = 'Volume per Unit (cubic meters)');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `weight_per_unit_kg` SET TAGS ('dbx_business_glossary_term' = 'Weight per Unit (kg)');
ALTER TABLE `automotive_ecm`.`supply`.`commodity_group` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Record Created By');
