-- Schema for Domain: fleet | Business: Transport Shipping | Version: v1_mvm
-- Generated on: 2026-05-08 22:35:06

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `transport_shipping_ecm`.`fleet` COMMENT 'Fleet and transport asset management covering the full lifecycle of owned and leased vehicles, aircraft, vessels, and containers. Owns asset master data, GPS telematics, RFID tagging, maintenance scheduling, fuel consumption, driver assignment, regulatory compliance (DOT, ICAO), CAPEX/OPEX asset tracking, and fleet utilization KPIs. Integrates with TMS for route execution and IoT sensor data for real-time visibility.';

-- ========= TABLES =========
CREATE OR REPLACE TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` (
    `transport_asset_id` BIGINT COMMENT 'Unique identifier for the transport asset. Primary key for the transport asset master record.',
    `asset_type_id` BIGINT COMMENT 'Foreign key linking to fleet.asset_type. Business justification: transport_asset currently has asset_type (STRING) and asset_subtype (STRING) storing the asset classification as free text. The asset_type reference table provides the authoritative taxonomy with asse',
    `depot_id` BIGINT COMMENT 'Identifier of the depot, hub, or facility where the transport asset is currently based or assigned for operational purposes.',
    `license_permit_id` BIGINT COMMENT 'Foreign key linking to customs.license_permit. Business justification: Transport assets operating cross-border require customs-issued permits (cabotage permits, transit permits, dangerous goods transport authorizations). Linking transport_asset to license_permit enables ',
    `supplier_id` BIGINT COMMENT 'Foreign key linking to procurement.supplier. Business justification: OEM supplier relationship: links the assets manufacturer to the procurement supplier master for warranty claims, OEM parts sourcing, and recall management. Normalizes the plain manufacturer text fi',
    `purchase_order_id` BIGINT COMMENT 'Foreign key linking to procurement.purchase_order. Business justification: Capital asset acquisition process: each transport asset is procured via a PO. Fleet managers trace assets to originating POs for warranty claims, asset accounting, and disposal decisions. A logistics ',
    `acquisition_cost` DECIMAL(18,2) COMMENT 'Capital expenditure (CAPEX) value of the transport asset at the time of acquisition. Recorded in the organizations base currency for financial reporting and depreciation calculation.',
    `acquisition_date` DATE COMMENT 'Date when the transport asset was acquired, purchased, or leased by the organization. Used for depreciation and lifecycle tracking.',
    `asset_name` STRING COMMENT 'Human-readable name or designation of the transport asset for operational identification and reporting purposes.',
    `asset_number` STRING COMMENT 'Externally-known unique asset identification number or registration code assigned to the transport asset. Used for tracking, compliance, and operational reference.. Valid values are `^[A-Z0-9]{6,20}$`',
    `co2_emission_rate_g_per_km` DECIMAL(18,2) COMMENT 'Carbon dioxide equivalent (CO2e) emission rate in grams per kilometer. Used for greenhouse gas (GHG) reporting and sustainability KPI (Key Performance Indicator) tracking.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the transport asset record was first created in the system. Used for audit trail and data lineage tracking.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the acquisition cost and financial values associated with the transport asset.. Valid values are `^[A-Z]{3}$`',
    `current_location` STRING COMMENT 'Real-time or last known location of the transport asset. Updated via GPS telematics or manual check-in for visibility and tracking.',
    `decommission_date` DATE COMMENT 'Date when the transport asset was retired from active service or decommissioned. Marks the end of the assets operational lifecycle.',
    `disposal_date` DATE COMMENT 'Date when the transport asset was sold, scrapped, or otherwise disposed of. Used for final financial accounting and asset register closure.',
    `disposal_value` DECIMAL(18,2) COMMENT 'Salvage or resale value realized when the transport asset was disposed of. Used for capital expenditure (CAPEX) recovery tracking and financial reporting.',
    `emission_standard` STRING COMMENT 'Environmental emission standard or certification that the transport asset complies with (e.g., Euro 6, EPA Tier 4). Required for regulatory compliance and sustainability reporting.',
    `engine_power_kw` DECIMAL(18,2) COMMENT 'Engine power output measured in kilowatts. Indicates performance capability and operational efficiency of the transport asset.',
    `engine_type` STRING COMMENT 'Engine model or type specification for the transport asset. Used for maintenance planning, parts sourcing, and performance tracking.',
    `fuel_capacity_liters` DECIMAL(18,2) COMMENT 'Maximum fuel tank capacity in liters. Used for range calculation and refueling planning.',
    `fuel_type` STRING COMMENT 'Primary fuel or energy source used by the transport asset. Determines refueling infrastructure requirements and greenhouse gas (GHG) emissions calculations. [ENUM-REF-CANDIDATE: diesel|gasoline|electric|hybrid|cng|lng|jet_fuel|marine_fuel — 8 candidates stripped; promote to reference product]',
    `height_meters` DECIMAL(18,2) COMMENT 'Physical height of the transport asset in meters. Critical for bridge clearance, tunnel access, and loading dock compatibility.',
    `home_location` STRING COMMENT 'Primary base location or home terminal for the transport asset. Used for route planning and operational assignment.',
    `insurance_expiry_date` DATE COMMENT 'Date when the current insurance policy for the transport asset expires. Used for compliance tracking and renewal scheduling.',
    `insurance_policy_number` STRING COMMENT 'Insurance policy number covering the transport asset for liability, damage, and loss. Required for risk management and claims processing.',
    `last_maintenance_date` DATE COMMENT 'Date when the most recent scheduled or unscheduled maintenance was performed on the transport asset. Used for maintenance interval tracking.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the transport asset record was last updated in the system. Used for audit trail and change tracking.',
    `length_meters` DECIMAL(18,2) COMMENT 'Physical length of the transport asset in meters. Used for parking allocation, route clearance, and infrastructure compatibility.',
    `model` STRING COMMENT 'Manufacturers model designation or series name for the transport asset. Identifies specific design and capability specifications.',
    `next_maintenance_due_date` DATE COMMENT 'Scheduled date for the next preventive maintenance service on the transport asset. Critical for operational planning and compliance with safety regulations.',
    `odometer_reading` DECIMAL(18,2) COMMENT 'Current odometer or mileage reading for road vehicles, or equivalent usage metric (flight hours for aircraft, engine hours for vessels). Used for maintenance scheduling and utilization tracking.',
    `operational_status` STRING COMMENT 'Current lifecycle state of the transport asset indicating availability for operations, maintenance, or retirement status.. Valid values are `active|in_maintenance|idle|decommissioned|reserved|out_of_service`',
    `ownership_type` STRING COMMENT 'Legal ownership or control arrangement for the transport asset. Determines financial treatment and operational flexibility.. Valid values are `owned|leased|chartered|rented`',
    `payload_capacity_kg` DECIMAL(18,2) COMMENT 'Maximum weight capacity in kilograms that the transport asset can carry. Critical for load planning and compliance with weight regulations.',
    `registration_country` STRING COMMENT 'Three-letter ISO country code where the transport asset is registered. Determines applicable regulatory jurisdiction and compliance requirements.. Valid values are `^[A-Z]{3}$`',
    `registration_expiry_date` DATE COMMENT 'Date when the current registration or license for the transport asset expires. Used for compliance tracking and renewal scheduling.',
    `registration_number` STRING COMMENT 'Government-issued registration or license plate number for the transport asset. Required for legal operation and regulatory compliance (DOT, ICAO, IMO).',
    `rfid_tag` STRING COMMENT 'RFID (Radio Frequency Identification) tag identifier attached to the transport asset for automated identification, access control, and yard management.. Valid values are `^[A-F0-9]{24}$`',
    `telematics_device_code` STRING COMMENT 'Unique identifier of the GPS (Global Positioning System) telematics device installed on the transport asset for real-time tracking, route monitoring, and IoT (Internet of Things) sensor data collection.. Valid values are `^[A-Z0-9]{8,20}$`',
    `teu_capacity` DECIMAL(18,2) COMMENT 'Container capacity measured in TEU (Twenty-foot Equivalent Unit) for vessels and rail units. Standard measure for container shipping capacity.',
    `utilization_rate_percent` DECIMAL(18,2) COMMENT 'Percentage of time the transport asset is actively deployed in operations versus idle or available time. Key performance indicator (KPI) for fleet efficiency and return on investment (ROI).',
    `vin_serial_number` STRING COMMENT 'Unique vehicle identification number (VIN) for road vehicles or manufacturer serial number for aircraft, vessels, and rail units. Used for registration, insurance, and theft prevention.. Valid values are `^[A-HJ-NPR-Z0-9]{17}$`',
    `volume_capacity_cbm` DECIMAL(18,2) COMMENT 'Maximum volumetric capacity in cubic meters (CBM) that the transport asset can accommodate. Used for space optimization and dimensional weight (DIM weight) calculations.',
    `width_meters` DECIMAL(18,2) COMMENT 'Physical width of the transport asset in meters. Used for route clearance and infrastructure compatibility assessment.',
    `year_of_manufacture` STRING COMMENT 'Calendar year when the transport asset was manufactured or built. Used for age-based maintenance scheduling and regulatory compliance.',
    CONSTRAINT pk_transport_asset PRIMARY KEY(`transport_asset_id`)
) COMMENT 'Master record for all owned and leased transport assets in the fleet including vehicles (trucks, vans, motorcycles), aircraft, vessels, and rail units. Captures asset identity, classification, registration, ownership type (owned/leased/chartered), acquisition date, CAPEX value, current operational status, assigned depot/hub, telematics device ID, RFID tag, DOT/ICAO registration numbers, payload capacity, dimensional specs (CBM, DIM weight), fuel type, engine specs, and full lifecycle state (active, in-maintenance, decommissioned). This is the SSOT for all fleet asset master data.';

CREATE OR REPLACE TABLE `transport_shipping_ecm`.`fleet`.`container_unit` (
    `container_unit_id` BIGINT COMMENT 'Unique identifier for the container unit. Primary key for the container_unit data product.',
    `agreement_id` BIGINT COMMENT 'Foreign key linking to contract.agreement. Business justification: Container lease management: container_unit.lease_agreement_reference is a denormalized text reference to a contract agreement. Replacing with a proper FK enables lease cost tracking, expiry management',
    `asset_type_id` BIGINT COMMENT 'Foreign key linking to fleet.asset_type. Business justification: container_unit currently has container_type (STRING) storing the container classification as free text. Containers are a category of fleet assets and should reference the asset_type taxonomy. The asse',
    `carrier_id` BIGINT COMMENT 'Foreign key linking to network.carrier. Business justification: Container repatriation, detention/demurrage billing, and carrier asset pool management require knowing which carrier owns or leases each container unit. Logistics domain experts universally expect con',
    `depot_id` BIGINT COMMENT 'Foreign key linking to fleet.depot. Business justification: Containers have a current location (current_location_type, current_location_code). When a container is at a fleet depot, this FK provides a structured link. Nullable because containers can be at ports',
    `network_node_id` BIGINT COMMENT 'Foreign key linking to route.network_node. Business justification: container_unit.current_location_code is a denormalized plain-text field. Normalizing to network_node enables container tracking, node-level inventory reporting, and repositioning optimization — core c',
    `lane_id` BIGINT COMMENT 'Foreign key linking to route.lane. Business justification: Container positioning and repositioning decisions are made at the trade-lane level. Knowing which lane a container is currently assigned to is fundamental to container fleet management and empty repos',
    `supplier_id` BIGINT COMMENT 'Foreign key linking to procurement.supplier. Business justification: Container OEM supplier linkage: normalizes the plain manufacturer text field to the procurement supplier master, enabling warranty claims, CSC certification follow-up with the OEM, and parts sourcin',
    `purchase_order_id` BIGINT COMMENT 'Foreign key linking to procurement.purchase_order. Business justification: Container acquisition procurement: containers are capital assets purchased via POs. Linking container_unit to its originating PO supports warranty tracking, CSC certification cost allocation, and asse',
    `acquisition_cost` DECIMAL(18,2) COMMENT 'Total cost paid to acquire the container, including purchase price or initial lease payment. Used for CAPEX tracking, asset valuation, and return on investment analysis.',
    `acquisition_date` DATE COMMENT 'Date the container was acquired by the company (purchase or lease commencement). Used for asset tracking, depreciation schedules, and fleet age analysis.',
    `availability_status` STRING COMMENT 'Current operational status of the container. Available for booking, in use on a shipment, in transit empty, under repair/maintenance, retired from service, or lost/missing. Critical for inventory management and booking systems.. Valid values are `available|in_use|in_transit|under_repair|retired|lost`',
    `condition_grade` STRING COMMENT 'Physical condition assessment of the container. Grade A (excellent, cargo-worthy), B (good, minor wear), C (fair, requires monitoring), D (poor, repair needed), Scrap (end of life). Determines suitability for cargo types and repair priority.. Valid values are `A|B|C|D|scrap`',
    `container_number` STRING COMMENT 'Unique container identification number following ISO 6346 standard format (4 letter owner code + 6 digit serial number + 1 check digit). This is the globally recognized identifier for the container unit.. Valid values are `^[A-Z]{4}[0-9]{7}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this container unit record was first created in the system. Used for audit trail and data lineage tracking.',
    `csc_certification_date` DATE COMMENT 'Date the current CSC safety certification was issued. Used to track certification validity and schedule re-inspection.',
    `csc_certification_number` STRING COMMENT 'Unique certification number issued under the International Convention for Safe Containers (CSC). Certifies the container meets structural safety standards for international transport.',
    `csc_expiry_date` DATE COMMENT 'Expiration date of the CSC safety certification. Containers must be re-inspected and re-certified before this date to remain in service. Non-compliance prevents international movement.',
    `current_book_value` DECIMAL(18,2) COMMENT 'Current accounting book value of the container after depreciation. Updated periodically based on depreciation schedule. Used for financial reporting and asset disposal decisions.',
    `current_location_country` STRING COMMENT 'Three-letter ISO country code of the containers current location. Used for geographic fleet distribution analysis and repositioning planning.. Valid values are `^[A-Z]{3}$`',
    `current_location_type` STRING COMMENT 'Type of facility or mode where the container is currently located. Depot (storage yard), port (marine terminal), vessel (on ship), rail yard, customer site, or in transit between locations.. Valid values are `depot|port|vessel|rail_yard|customer_site|in_transit`',
    `disposal_date` DATE COMMENT 'Date the container was disposed of (sold, scrapped, or otherwise removed from company ownership). Null if still owned. Used for asset lifecycle closure and financial reconciliation.',
    `food_grade_certified` BOOLEAN COMMENT 'Indicates whether the container is certified for transporting food products, meeting hygiene and contamination prevention standards. True if food-grade certified, false otherwise.',
    `gps_enabled` BOOLEAN COMMENT 'Indicates whether the container is equipped with GPS tracking device for real-time location monitoring. True if GPS-enabled, false otherwise.',
    `hazmat_certified` BOOLEAN COMMENT 'Indicates whether the container is certified to carry hazardous materials (dangerous goods) per IMDG Code and ICAO Technical Instructions. True if certified, false otherwise.',
    `height_ft` DECIMAL(18,2) COMMENT 'External height of the container in feet. Standard height is 8.5 feet; high-cube containers are 9.5 feet. Determines stacking compatibility and clearance requirements.',
    `internal_volume_cbm` DECIMAL(18,2) COMMENT 'Internal cargo capacity of the container in cubic meters (CBM). Used for volumetric load planning and dimensional weight calculations.',
    `last_inspection_date` DATE COMMENT 'Date of the most recent physical inspection of the container. Inspections verify structural integrity, door seals, flooring, and compliance with safety standards.',
    `last_maintenance_date` DATE COMMENT 'Date of the most recent maintenance or repair work performed on the container. Tracks maintenance history and informs future service intervals.',
    `last_movement_date` TIMESTAMP COMMENT 'Timestamp of the most recent movement or position update for the container. Used for tracking, dwell time calculation, and real-time visibility.',
    `length_ft` STRING COMMENT 'External length of the container in feet. Standard sizes are 10, 20, 40, 45, 48, or 53 feet. Critical for transport planning, stacking, and terminal slot allocation.',
    `manufacture_date` DATE COMMENT 'Date the container was manufactured. Used to calculate asset age, depreciation, and remaining useful life for maintenance and replacement planning.',
    `max_gross_weight_kg` DECIMAL(18,2) COMMENT 'Maximum permissible combined weight of the container and its cargo in kilograms. Enforced for safety, regulatory compliance (SOLAS VGM), and transport mode restrictions.',
    `max_payload_kg` DECIMAL(18,2) COMMENT 'Maximum cargo weight the container can carry, calculated as max gross weight minus tare weight. Used for load planning and customer quoting.',
    `next_inspection_due_date` DATE COMMENT 'Scheduled date for the next mandatory inspection. Used for preventive maintenance planning and compliance tracking.',
    `owner_code` STRING COMMENT 'Four-letter code identifying the container owner or operator, as registered with the Bureau International des Containers (BIC). First three letters identify the owner; fourth letter is the equipment category (U for freight container).. Valid values are `^[A-Z]{4}$`',
    `ownership_type` STRING COMMENT 'Indicates whether the container is owned by the carrier, leased from a lessor, owned by a customer (SOC - Shipper Owned Container), or part of a shared pool arrangement. Impacts cost allocation, maintenance responsibility, and repositioning strategy.. Valid values are `owned|leased|customer_owned|pool`',
    `reefer_capable` BOOLEAN COMMENT 'Indicates whether the container has refrigeration capability for temperature-controlled cargo. True for reefer containers, false for dry and other non-refrigerated types.',
    `retirement_date` DATE COMMENT 'Date the container was retired from active service. Null if the container is still in service. Used for fleet lifecycle management and disposal tracking.',
    `rfid_tag_code` STRING COMMENT 'Unique identifier of the RFID tag attached to the container for automated tracking at gates, terminals, and checkpoints. Null if container is not RFID-tagged.',
    `tare_weight_kg` DECIMAL(18,2) COMMENT 'Empty weight of the container in kilograms, excluding cargo. Used to calculate net cargo weight and verify compliance with gross weight limits.',
    `temperature_range_max_c` DECIMAL(18,2) COMMENT 'Maximum temperature the container can maintain in Celsius. Applicable only to refrigerated (reefer) containers. Null for non-reefer units.',
    `temperature_range_min_c` DECIMAL(18,2) COMMENT 'Minimum temperature the container can maintain in Celsius. Applicable only to refrigerated (reefer) containers. Null for non-reefer units.',
    `teu_size` DECIMAL(18,2) COMMENT 'Container size expressed in TEU (Twenty-foot Equivalent Unit). Standard values: 1.0 for 20ft, 2.0 for 40ft, 2.25 for 45ft. Used for capacity planning and vessel/terminal utilization calculations.',
    `total_distance_km` DECIMAL(18,2) COMMENT 'Cumulative distance the container has traveled in kilometers since acquisition. Used for wear analysis, maintenance scheduling, and asset performance evaluation.',
    `total_trips_completed` STRING COMMENT 'Cumulative count of completed shipment trips (loaded movements) the container has performed since acquisition. Used for utilization analysis and lifecycle tracking.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this container unit record was last modified. Used for audit trail, change tracking, and data freshness monitoring.',
    `width_ft` DECIMAL(18,2) COMMENT 'External width of the container in feet. Standard width is 8.0 feet; high-cube and specialized containers may be 8.5 feet.',
    CONSTRAINT pk_container_unit PRIMARY KEY(`container_unit_id`)
) COMMENT 'Master record for intermodal containers and unit load devices (ULDs) managed within the fleet. Tracks container number (ISO 6346), TEU size classification (20ft, 40ft, 45ft), container type (dry, reefer, open-top, flat-rack, tank), tare weight, max gross weight, CSC certification expiry, current location (port/depot/vessel), availability status, lease agreement reference, and last inspection date. Distinct from transport_asset as containers are cargo-carrying units with their own ISO standards and lifecycle separate from traction units.';

CREATE OR REPLACE TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` (
    `asset_assignment_id` BIGINT COMMENT 'Unique identifier for the asset assignment record. Primary key for the asset assignment transaction.',
    `agreement_id` BIGINT COMMENT 'Foreign key linking to contract.agreement. Business justification: Asset assignments execute contracted service commitments. Operations teams validate assignment compliance with customer/carrier agreements for rate validation, SLA tracking, and billing reconciliation',
    `carrier_agreement_id` BIGINT COMMENT 'Foreign key linking to contract.carrier_agreement. Business justification: Carrier performance and liability management: when assets are assigned under carrier agreements, the specific carrier agreement governs liability limits, EDI requirements, and capacity terms. This lin',
    `carrier_id` BIGINT COMMENT 'Foreign key linking to network.carrier. Business justification: Asset assignments frequently use external carriers for line-haul or last-mile segments. Carrier selection, performance tracking, cost allocation, and SLA compliance depend on this link. Essential for ',
    `carrier_payable_id` BIGINT COMMENT 'Foreign key linking to billing.carrier_payable. Business justification: Asset assignments involving third-party carriers generate carrier payables for the service leg. Linking asset_assignment to carrier_payable enables freight cost management, carrier payment reconciliat',
    `carrier_service_id` BIGINT COMMENT 'Foreign key linking to network.carrier_service. Business justification: Asset assignments fulfill specific carrier service bookings (ocean service, rail service, air service). Linking asset_assignment to carrier_service enables service-level capacity utilization reporting',
    `customer_account_id` BIGINT COMMENT 'Foreign key linking to customer.customer_account. Business justification: Dedicated fleet contracts require asset assignments to be linked to a customer account for customer-specific utilization reporting, dedicated fleet billing, and SLA performance tracking. Logistics ope',
    `declaration_id` BIGINT COMMENT 'Foreign key linking to customs.declaration. Business justification: Asset assignments (trips/jobs) involving cross-border freight require customs declarations. Links operational dispatch to regulatory compliance, supports driver briefings on customs requirements, and ',
    `depot_id` BIGINT COMMENT 'Reference to the depot, terminal, or facility where the assignment is scheduled to end. The ending location for the asset assignment. Null for open-ended assignments such as depot standby. Links to warehouse or facility master data.',
    `dispute_id` BIGINT COMMENT 'Foreign key linking to billing.billing_dispute. Business justification: Billing disputes frequently arise from specific asset assignments where charges dont match contracted rates or actual service delivered. Linking asset_assignment to billing_dispute enables dispute re',
    `driver_profile_id` BIGINT COMMENT 'Reference to the driver or crew member assigned to operate the asset during this assignment. Null for uncrewed assignments such as container assignments or depot standby. Links to workforce driver master data.',
    `freight_audit_id` BIGINT COMMENT 'Foreign key linking to billing.freight_audit. Business justification: Freight audit validates carrier charges against the actual assignment executed (contracted vs invoiced weight, distance, accessorials). Linking asset_assignment to freight_audit is essential for freig',
    `freight_order_id` BIGINT COMMENT 'Reference to the TMS freight order that this asset is assigned to execute. Null for non-route assignments such as depot standby or maintenance hold. Enables TMS-to-fleet reconciliation.',
    `lane_id` BIGINT COMMENT 'Foreign key linking to route.lane. Business justification: Lane-level asset deployment reporting (which assets run which lanes, utilization by lane) is a core fleet planning process. asset_assignment links to plan but not directly to lane; direct FK enables l',
    `origin_depot_id` BIGINT COMMENT 'Reference to the depot, terminal, or facility where the assignment originates. The starting location for the asset assignment. Links to warehouse or facility master data.',
    `facility_id` BIGINT COMMENT 'Foreign key linking to warehouse.facility. Business justification: Asset assignments for warehouse pickup/delivery operations must reference the specific warehouse facility being serviced. This enables facility-level fleet utilization reporting, dock capacity plannin',
    `plan_id` BIGINT COMMENT 'Reference to the planned route that the asset is assigned to execute. Applicable for route execution assignments. Links to route master data for origin, destination, and waypoints.',
    `rate_card_id` BIGINT COMMENT 'Foreign key linking to pricing.rate_card. Business justification: Asset assignments execute freight movements billed under a specific rate card. Logistics billing and revenue recognition require knowing which rate card governed each assignment. Dispatchers and finan',
    `rate_schedule_id` BIGINT COMMENT 'Foreign key linking to contract.rate_schedule. Business justification: Assignment cost validation: asset assignments incur costs governed by contracted rate schedules. Linking assignment to rate_schedule enables cost-per-assignment validation against contracted rates, su',
    `service_scope_id` BIGINT COMMENT 'Foreign key linking to contract.service_scope. Business justification: Contractual service compliance: asset assignments must comply with the contracted service scope (hazmat authorization, temperature control, geographic limits). This link enables real-time compliance c',
    `shipment_leg_id` BIGINT COMMENT 'Foreign key linking to shipment.shipment_leg. Business justification: An asset assignment executes a specific shipment leg. Fleet dispatchers need to know which shipment leg an asset assignment is fulfilling for SLA monitoring, cost allocation per leg, and operational r',
    `shipper_profile_id` BIGINT COMMENT 'Foreign key linking to customer.shipper_profile. Business justification: Shipper profiles contain hazmat certifications, temperature requirements, and special handling instructions that directly govern which assets can be assigned for a shippers cargo. Compliance and safe',
    `sla_commitment_id` BIGINT COMMENT 'Foreign key linking to contract.contract_sla_commitment. Business justification: Real-time SLA breach detection: each asset assignment is measured against a specific SLA commitment (OTD, OTIF, transit time). This link enables automated SLA compliance tracking at the assignment lev',
    `sla_entitlement_id` BIGINT COMMENT 'Foreign key linking to customer.sla_entitlement. Business justification: Premium logistics customers have SLA entitlements (guaranteed transit times, priority handling) that must govern asset assignment decisions. Fleet dispatchers reference the SLA entitlement to assign a',
    `transport_asset_id` BIGINT COMMENT 'Reference to the transport asset (vehicle, aircraft, vessel, container) being assigned. Links to the fleet asset master data.',
    `trip_id` BIGINT COMMENT 'Foreign key linking to fleet.trip. Business justification: Asset assignments represent the allocation of a transport asset to an operational run. Linking to trip provides the trip-level context. fleet_driver_assignment already has trip_id; asset_assignment sh',
    `actual_end_datetime` TIMESTAMP COMMENT 'Actual date and time when the asset assignment ended. Captured from GPS telematics, RFID tag reads, or manual check-out. Used for On-Time In-Full (OTIF) performance measurement and variance analysis against planned end. Null for in-progress assignments.',
    `actual_start_datetime` TIMESTAMP COMMENT 'Actual date and time when the asset assignment began. Captured from GPS telematics, RFID tag reads, or manual check-in. Used for On-Time Departure (OTD) performance measurement and variance analysis against planned start.',
    `assignment_cost_amount` DECIMAL(18,2) COMMENT 'Total operational cost incurred for this assignment including fuel, driver wages, tolls, and maintenance. Used for OPEX tracking, profitability analysis, and cost-per-kilometer KPI calculation. Captured in the companys base currency.',
    `assignment_duration_hours` DECIMAL(18,2) COMMENT 'Planned or actual duration of the assignment in hours. Used for fleet utilization KPI calculation, driver hours-of-service compliance, and asset availability forecasting. Calculated from start and end datetimes.',
    `assignment_number` STRING COMMENT 'Business-readable unique identifier for the assignment, typically generated by the Transportation Management System (TMS). Used for operational tracking and communication.',
    `assignment_status` STRING COMMENT 'Current lifecycle state of the assignment. Planned indicates scheduled but not confirmed, confirmed for approved assignments, in progress for active assignments, completed for finished assignments, cancelled for voided assignments, suspended for temporarily halted assignments, failed for assignments that could not be completed. [ENUM-REF-CANDIDATE: planned|confirmed|in_progress|completed|cancelled|suspended|failed — 7 candidates stripped; promote to reference product]',
    `assignment_type` STRING COMMENT 'Classification of the assignment purpose. Route execution indicates active transport duty, depot standby for available assets, charter for third-party rental, maintenance hold for scheduled service, repair for unscheduled fixes, inspection for regulatory checks, lease out for external rental, reserve for contingency, training for crew qualification, emergency deployment for urgent needs. [ENUM-REF-CANDIDATE: route_execution|depot_standby|charter|maintenance_hold|repair|inspection|lease_out|reserve|training|emergency_deployment — 10 candidates stripped; promote to reference product]',
    `cargo_volume_cbm` DECIMAL(18,2) COMMENT 'Total volume of cargo loaded on the asset during this assignment in cubic meters. Used for capacity utilization analysis and dimensional weight (DIM weight) calculations. Null for non-cargo assignments.',
    `cargo_weight_kg` DECIMAL(18,2) COMMENT 'Total weight of cargo loaded on the asset during this assignment in kilograms. Used for load optimization, weight compliance checks, and fuel consumption correlation analysis. Null for non-cargo assignments.',
    `co2_emissions_kg` DECIMAL(18,2) COMMENT 'Total greenhouse gas emissions in kilograms of CO2 equivalent produced during this assignment. Calculated from fuel consumption using emission factors. Used for sustainability reporting, EU Emissions Trading System (EU ETS) compliance, and Carbon Offsetting and Reduction Scheme for International Aviation (CORSIA) reporting.',
    `compliance_check_status` STRING COMMENT 'Status of regulatory compliance checks for this assignment including DOT inspections, ICAO airworthiness, IMO safety checks, and customs pre-clearance. Passed indicates all checks cleared, failed for violations, pending for in-progress checks, not required for exempt assignments, waived for authorized exceptions.. Valid values are `passed|failed|pending|not_required|waived`',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this assignment record was first created in the system. Used for audit trail, data lineage tracking, and record lifecycle management. Automatically populated by the system.',
    `cross_border_indicator` BOOLEAN COMMENT 'Boolean flag indicating whether the assignment involves crossing international borders requiring customs clearance and trade compliance. True for international assignments, false for domestic.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the assignment cost amount. Typically the companys base operating currency (e.g., USD, EUR, GBP).. Valid values are `^[A-Z]{3}$`',
    `delay_duration_minutes` STRING COMMENT 'Total duration of delays in minutes. Calculated as the difference between planned and actual completion times. Used for Service Level Agreement (SLA) compliance measurement and root cause analysis. Zero if no delay occurred.',
    `delay_reason_code` STRING COMMENT 'Standardized code indicating the primary reason for any delay in completing the assignment. Weather for adverse conditions, traffic for congestion, mechanical for breakdowns, customs for clearance delays, loading delay for shipper delays, driver unavailable for crew issues, route change for diversions, accident for incidents, other for miscellaneous, none if no delay occurred. [ENUM-REF-CANDIDATE: weather|traffic|mechanical|customs|loading_delay|driver_unavailable|route_change|accident|other|none — 10 candidates stripped; promote to reference product]',
    `distance_km` DECIMAL(18,2) COMMENT 'Planned or actual distance covered during the assignment in kilometers. Used for fuel consumption analysis, maintenance scheduling based on mileage, and route optimization. Captured from GPS telematics or route planning systems.',
    `fuel_consumed_liters` DECIMAL(18,2) COMMENT 'Actual fuel consumed during the assignment in liters. Captured from vehicle telematics, fuel card transactions, or manual fuel logs. Used for OPEX tracking, Carbon Dioxide Equivalent (CO2e) emissions calculation, and fuel efficiency KPIs.',
    `gps_tracking_enabled` BOOLEAN COMMENT 'Boolean flag indicating whether real-time GPS tracking is enabled for this assignment. True if telematics data is being captured, false otherwise. Used for real-time visibility and predictive ETA calculation.',
    `hazmat_indicator` BOOLEAN COMMENT 'Boolean flag indicating whether the assignment involves transport of hazardous materials requiring special handling, placarding, and regulatory compliance. True if hazmat cargo is present, false otherwise.',
    `incident_reported_indicator` BOOLEAN COMMENT 'Boolean flag indicating whether any incident (accident, breakdown, delay, cargo damage, security breach) was reported during this assignment. True if an incident occurred, false otherwise. Links to incident or claims management systems.',
    `last_inspection_date` DATE COMMENT 'Date of the most recent regulatory or safety inspection performed on the asset prior to or during this assignment. Used for compliance tracking and maintenance scheduling. Null if no inspection has been performed.',
    `load_utilization_percentage` DECIMAL(18,2) COMMENT 'Percentage of the assets maximum capacity utilized during this assignment. Calculated as (actual cargo weight or volume / maximum capacity) * 100. Key performance indicator for fleet efficiency and load optimization.',
    `modified_timestamp` TIMESTAMP COMMENT 'Date and time when this assignment record was last modified. Used for audit trail, change tracking, and data synchronization. Automatically updated by the system on any change.',
    `notes` STRING COMMENT 'Free-text field for operational notes, special instructions, or comments related to the assignment. Used for communication between dispatchers, drivers, and operations teams. May include handling instructions, customer requirements, or incident details.',
    `planned_end_datetime` TIMESTAMP COMMENT 'Scheduled date and time when the asset assignment is planned to end. Used for capacity planning and turnaround time calculation. Corresponds to Estimated Time of Arrival (ETA) for route assignments. Null for open-ended assignments.',
    `planned_start_datetime` TIMESTAMP COMMENT 'Scheduled date and time when the asset assignment is planned to begin. Used for capacity planning and resource scheduling. Corresponds to Estimated Time of Departure (ETD) for route assignments.',
    `priority_level` STRING COMMENT 'Business priority of the assignment. Critical for time-sensitive or high-value shipments, high for express delivery, normal for standard service, low for deferred or backhaul assignments. Influences resource allocation and scheduling decisions.. Valid values are `critical|high|normal|low`',
    `rfid_tag_code` STRING COMMENT 'Unique identifier of the RFID tag attached to the asset for automated tracking and identification. Used for gate-in/gate-out automation, asset location tracking, and inventory management. Null if RFID is not used.',
    `seal_number` STRING COMMENT 'Unique identifier of the security seal applied to the asset (container, trailer, or cargo compartment) to ensure cargo integrity and prevent tampering. Required for customs compliance and high-security shipments. Null if no seal is applied.',
    `service_level` STRING COMMENT 'Service level agreement (SLA) tier for this assignment. Express for next-day or same-day delivery, standard for 2-5 day delivery, economy for 5+ day delivery, charter for exclusive use, dedicated for contract logistics. Determines performance targets and pricing.. Valid values are `express|standard|economy|charter|dedicated`',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record that originated this assignment. SAP TM for SAP Transportation Management, ORACLE TMS for Oracle Transportation Management System, MANHATTAN WMS for warehouse-initiated assignments, FOURKITES for visibility platform assignments, MANUAL for manually created assignments, OTHER for miscellaneous sources. Used for data lineage and system integration tracking.. Valid values are `SAP_TM|ORACLE_TMS|MANHATTAN_WMS|FOURKITES|MANUAL|OTHER`',
    `temperature_controlled_indicator` BOOLEAN COMMENT 'Boolean flag indicating whether the assignment requires temperature-controlled transport (refrigerated or heated). True for cold chain or temperature-sensitive cargo, false otherwise.',
    CONSTRAINT pk_asset_assignment PRIMARY KEY(`asset_assignment_id`)
) COMMENT 'Transactional record capturing the assignment of a transport asset (vehicle, aircraft, vessel) to a specific route, freight order, driver, or operational depot for a defined period. Tracks assignment type (route execution, depot standby, charter, maintenance hold), assigned driver/crew reference, origin depot, destination, planned start/end datetime, actual start/end datetime, TMS freight order reference, and assignment status. Enables fleet utilization tracking and TMS-to-fleet reconciliation.';

CREATE OR REPLACE TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` (
    `telematics_event_id` BIGINT COMMENT 'Unique identifier for the telematics event record. Primary key for the telematics event stream.',
    `carrier_id` BIGINT COMMENT 'Foreign key linking to network.carrier. Business justification: When assets are operated by contracted carriers, telematics events must track carrier for liability determination, performance monitoring (speed, idling, route adherence), and billing reconciliation. ',
    `consignment_id` BIGINT COMMENT 'Identifier of the active shipment being transported by the asset at the time of the event. Links telemetry to freight orders for predictive ETA and exception management.',
    `driver_profile_id` BIGINT COMMENT 'Identifier of the driver assigned to the asset at the time of the event. Used for driver behavior scoring, hours-of-service compliance, and workforce analytics.',
    `facility_id` BIGINT COMMENT 'Foreign key linking to warehouse.facility. Business justification: Geofence telematics events at warehouse facilities trigger automated dock check-in, ETA notifications to receiving teams, and yard management updates. Linking telematics events to the specific facilit',
    `freight_order_id` BIGINT COMMENT 'Foreign key linking to freight.freight_order. Business justification: Telematics events (GPS position, temperature excursions, speed alerts) must be correlated to freight orders for cold-chain compliance reporting, customer shipment visibility portals, and regulatory te',
    `lane_id` BIGINT COMMENT 'Foreign key linking to route.lane. Business justification: Lane-level telematics analytics (average speed, harsh braking rate, fuel efficiency per lane) drive route optimization and driver coaching programs. telematics_event has plan_id and network_node_id bu',
    `network_node_id` BIGINT COMMENT 'Foreign key linking to route.network_node. Business justification: Telematics events capture GPS positions that map to network nodes (depots, hubs, terminals) for location-based analytics, geofence validation, and milestone tracking in real-time visibility systems.',
    `plan_id` BIGINT COMMENT 'Identifier of the planned route being executed by the asset. Used for route deviation detection and on-time delivery performance analysis.',
    `transport_asset_id` BIGINT COMMENT 'Identifier of the fleet asset (vehicle, aircraft, vessel, container) from which this telemetry event was captured.',
    `trip_id` BIGINT COMMENT 'Foreign key linking to fleet.trip. Business justification: Telematics events (GPS pings, speed readings, harsh braking flags, geofence crossings) are generated continuously by onboard devices during active trips. Linking telematics_event to trip enables trip-',
    `altitude_m` DECIMAL(18,2) COMMENT 'Altitude of the asset above sea level in meters at the time of the event. Particularly relevant for aircraft and mountainous terrain routing.',
    `battery_voltage` DECIMAL(18,2) COMMENT 'Voltage level of the asset battery in volts. Used for predictive maintenance and device health monitoring.',
    `data_quality_flag` STRING COMMENT 'Indicator of the data quality and reliability of the event. Suspect or invalid flags may indicate GPS signal loss, sensor malfunction, or data transmission errors.. Valid values are `valid|suspect|invalid|interpolated`',
    `device_code` STRING COMMENT 'Unique identifier of the onboard telematics device (GPS/IoT unit) that generated this event. May be IMEI, MAC address, or vendor-specific serial number.',
    `diagnostic_trouble_code` STRING COMMENT 'Standardized engine diagnostic trouble code reported by the onboard diagnostics system. Used for predictive maintenance and fleet health monitoring.',
    `engine_hours` DECIMAL(18,2) COMMENT 'Cumulative engine operating hours as reported by the asset. Used for maintenance scheduling based on usage rather than calendar time.',
    `engine_rpm` STRING COMMENT 'Engine speed in revolutions per minute at the time of the event. Used for fuel efficiency analysis and engine health monitoring.',
    `event_timestamp` TIMESTAMP COMMENT 'Precise date and time when the telematics event was captured by the device, in format yyyy-MM-ddTHH:mm:ss.SSSXXX. Represents the real-world observation time, distinct from ingestion time.',
    `event_type` STRING COMMENT 'Classification of the telematics event indicating the nature of the observation or trigger condition. [ENUM-REF-CANDIDATE: gps_position|ignition_on|ignition_off|harsh_braking|harsh_acceleration|geofence_entry|geofence_exit|temperature_alert|fuel_level|engine_diagnostic — 10 candidates stripped; promote to reference product]',
    `fuel_level_percent` DECIMAL(18,2) COMMENT 'Remaining fuel level as a percentage of tank capacity (0-100). Used for fuel consumption tracking, refueling planning, and OPEX analysis.',
    `geofence_event_type` STRING COMMENT 'Indicates whether the event represents entry into or exit from a geofence zone. Used for automated proof of delivery and dwell time analysis.. Valid values are `entry|exit`',
    `gps_accuracy_m` DECIMAL(18,2) COMMENT 'Estimated horizontal accuracy of the GPS position in meters. Lower values indicate higher precision.',
    `gps_satellite_count` STRING COMMENT 'Number of GPS satellites used to calculate the position fix. Higher counts indicate better position accuracy.',
    `harsh_acceleration_flag` BOOLEAN COMMENT 'Boolean indicator (True/False) that a harsh acceleration event was detected based on acceleration threshold. Used for driver behavior scoring and fuel efficiency analysis.',
    `harsh_braking_flag` BOOLEAN COMMENT 'Boolean indicator (True/False) that a harsh braking event was detected based on deceleration threshold. Used for driver behavior scoring and safety analysis.',
    `heading_degrees` DECIMAL(18,2) COMMENT 'Compass heading of the asset in degrees (0-360), where 0/360 is North, 90 is East, 180 is South, and 270 is West. Used for route deviation detection.',
    `ignition_state` STRING COMMENT 'Current state of the asset ignition system. Used to distinguish active operation from idle or parked states.. Valid values are `on|off|accessory`',
    `ingestion_timestamp` TIMESTAMP COMMENT 'Date and time when the event was received and ingested into the FourKites platform, in format yyyy-MM-ddTHH:mm:ss.SSSXXX. Used to calculate transmission latency and data freshness.',
    `latitude` DECIMAL(18,2) COMMENT 'Geographic latitude coordinate of the asset at the time of the event, in decimal degrees. Positive values represent North, negative values represent South.',
    `longitude` DECIMAL(18,2) COMMENT 'Geographic longitude coordinate of the asset at the time of the event, in decimal degrees. Positive values represent East, negative values represent West.',
    `network_type` STRING COMMENT 'Type of network connection used by the telematics device to transmit the event. Impacts data latency and coverage in remote areas.. Valid values are `cellular|satellite|wifi`',
    `odometer_km` DECIMAL(18,2) COMMENT 'Cumulative distance traveled by the asset in kilometers as reported by the onboard odometer. Used for maintenance scheduling and asset utilization tracking.',
    `payload_json` STRING COMMENT 'Raw JSON payload from the telematics device containing additional vendor-specific sensor data and metadata not parsed into structured fields. Retained for audit and advanced analytics.',
    `signal_strength` STRING COMMENT 'Network signal strength indicator (typically in dBm or percentage). Used to assess connectivity quality and predict data transmission reliability.',
    `source_system` STRING COMMENT 'Name or identifier of the source telematics platform or vendor system that originated the event (e.g., FourKites, Geotab, Samsara). Used for multi-vendor fleet integration.',
    `speed_kmh` DECIMAL(18,2) COMMENT 'Instantaneous speed of the asset in kilometers per hour at the time of the event. Used for route optimization, ETA prediction, and driver behavior scoring.',
    `temperature_c` DECIMAL(18,2) COMMENT 'Temperature reading in degrees Celsius from onboard sensor. Critical for refrigerated (reefer) units transporting temperature-sensitive cargo such as pharmaceuticals or perishables.',
    `temperature_setpoint_c` DECIMAL(18,2) COMMENT 'Target temperature setting for refrigerated units in degrees Celsius. Used to detect temperature excursions and compliance violations.',
    CONSTRAINT pk_telematics_event PRIMARY KEY(`telematics_event_id`)
) COMMENT 'High-frequency IoT/GPS telemetry event records streamed from onboard telematics devices fitted to fleet assets. Captures asset ID, device ID, event timestamp (yyyy-MM-ddTHH:mm:ss.SSSXXX), GPS coordinates (latitude, longitude, altitude), speed, heading, odometer reading, engine RPM, fuel level, ignition state, harsh braking/acceleration flags, geofence entry/exit events, temperature sensor readings (for reefer units), and raw IoT payload reference. Sourced from FourKites real-time visibility platform. Enables predictive ETA, route deviation detection, and driver behavior scoring.';

CREATE OR REPLACE TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` (
    `driver_profile_id` BIGINT COMMENT 'Unique identifier for the driver profile record. Primary key.',
    `agreement_id` BIGINT COMMENT 'Foreign key linking to contract.agreement. Business justification: Owner-operator and subcontractor agreement management: drivers with employment_type of contractor/owner-operator operate under specific contract agreements governing rates, liability, and compliance r',
    `carrier_id` BIGINT COMMENT 'Foreign key linking to network.carrier. Business justification: Owner-operator and subcontracted drivers operate under a specific carriers DOT/operating authority. Compliance reporting, carrier performance audits, and driver credentialing require linking driver_p',
    `trade_party_id` BIGINT COMMENT 'Foreign key linking to customs.trade_party. Business justification: Drivers (especially owner-operators or contractors) may be registered as customs trade parties with their own importer/exporter numbers, C-TPAT certifications, or AEO status. Supports driver-level cus',
    `depot_id` BIGINT COMMENT 'FK to fleet.fleet_depot',
    `license_permit_id` BIGINT COMMENT 'Foreign key linking to customs.license_permit. Business justification: Drivers operating cross-border require customs-issued permits (bonded carrier driver authorization, dangerous goods transport permits, trusted traveler program credentials). Linking driver_profile to ',
    `supplier_id` BIGINT COMMENT 'Contractor identifier for third-party or independent drivers not on company payroll. Null for employee drivers.',
    `assignment_status` STRING COMMENT 'Current operational status of the driver. Active: available for route assignment. Inactive: not currently assigned. On Leave: temporary absence. Suspended: compliance or disciplinary hold. Terminated: no longer employed or contracted.. Valid values are `active|inactive|on_leave|suspended|terminated`',
    `background_check_date` DATE COMMENT 'Date the most recent background check was completed for the driver. Required for C-TPAT, AEO, and other security programs.',
    `background_check_status` STRING COMMENT 'Result status of the most recent background check. Cleared: passed all checks. Pending: in progress. Failed: did not meet security criteria. Expired: check is outdated and must be renewed.. Valid values are `cleared|pending|failed|expired`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this driver profile record was first created in the system.',
    `data_source_system` STRING COMMENT 'Name of the source system from which this driver profile record originated (e.g., Workday HCM, SAP TM, internal fleet management system).',
    `disciplinary_flag` BOOLEAN COMMENT 'Indicates whether the driver has active disciplinary actions or compliance violations on record. True if disciplinary action exists, False otherwise. Used for assignment restrictions and compliance monitoring.',
    `driver_name` STRING COMMENT 'Full legal name of the driver as it appears on their commercial driver license or operating permit.',
    `drug_test_date` DATE COMMENT 'Date of the most recent drug and alcohol screening test. Required for DOT-regulated drivers in the United States.',
    `drug_test_result` STRING COMMENT 'Result of the most recent drug and alcohol screening test. Negative: passed. Positive: failed. Pending: awaiting results. Refused: driver refused to test.. Valid values are `negative|positive|pending|refused`',
    `email_address` STRING COMMENT 'Email address for driver communications, electronic proof of delivery (ePOD) notifications, and system access credentials.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `emergency_contact_name` STRING COMMENT 'Full name of the drivers designated emergency contact person.',
    `emergency_contact_phone` STRING COMMENT 'Phone number of the drivers designated emergency contact person.',
    `employment_type` STRING COMMENT 'Classification of the drivers employment relationship with Transport Shipping. Determines payroll, benefits, liability, and compliance obligations.. Valid values are `full_time_employee|part_time_employee|contractor|owner_operator|temporary`',
    `gps_device_code` STRING COMMENT 'Identifier of the GPS telematics device currently assigned to the driver for real-time location tracking and route monitoring. Null if no device assigned.',
    `hire_date` DATE COMMENT 'Date the driver was hired or contracted by Transport Shipping. Used for tenure calculation, anniversary tracking, and retention analytics.',
    `language_proficiency` STRING COMMENT 'Comma-separated list of languages the driver is proficient in, using ISO 639-1 two-letter codes (e.g., EN, ES, FR, DE). Used for customer-facing delivery roles and cross-border operations.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this driver profile record was last updated.',
    `last_performance_review_date` DATE COMMENT 'Date of the most recent formal performance review for the driver.',
    `license_categories` STRING COMMENT 'Comma-separated list of vehicle categories or endorsements the driver is authorized to operate (e.g., H-Hazmat, N-Tank, P-Passenger, T-Double/Triple Trailers for road; type ratings for aviation; vessel types for maritime).',
    `license_expiry_date` DATE COMMENT 'Date the driver license expires and must be renewed. Critical for compliance monitoring and driver assignment eligibility.',
    `license_issue_date` DATE COMMENT 'Date the current driver license was issued by the licensing authority.',
    `license_issuing_country` STRING COMMENT 'Three-letter ISO 3166-1 alpha-3 country code of the authority that issued the driver license.. Valid values are `^[A-Z]{3}$`',
    `license_issuing_state` STRING COMMENT 'State, province, or regional authority within the issuing country that issued the driver license. Applicable for federal jurisdictions like USA, Canada, Australia.',
    `license_number` STRING COMMENT 'Commercial driver license (CDL) or equivalent operating license number issued by the licensing authority. Required for all drivers operating commercial vehicles.',
    `performance_rating` STRING COMMENT 'Most recent performance evaluation rating for the driver based on on-time delivery (OTD), safety record, customer feedback, and compliance adherence.. Valid values are `excellent|good|satisfactory|needs_improvement|unsatisfactory`',
    `primary_contact_phone` STRING COMMENT 'Primary mobile or telephone number for reaching the driver for dispatch, route updates, and emergency contact.',
    `rfid_tag_code` STRING COMMENT 'Identifier of the RFID tag assigned to the driver for facility access control, time tracking, and asset assignment. Null if no tag assigned.',
    `termination_date` DATE COMMENT 'Date the drivers employment or contract was terminated. Null for active drivers.',
    `vehicle_type_authorization` STRING COMMENT 'Comma-separated list of vehicle types the driver is authorized and trained to operate (e.g., tractor_trailer, straight_truck, cargo_van, aircraft, vessel). Derived from license class, endorsements, and internal training records.',
    `years_of_experience` DECIMAL(18,2) COMMENT 'Total years of professional driving experience in commercial transport operations. Used for risk assessment, insurance rating, and assignment to high-value or complex routes.',
    CONSTRAINT pk_driver_profile PRIMARY KEY(`driver_profile_id`)
) COMMENT 'Master record for all drivers and vehicle operators employed or contracted by Transport Shipping. Captures driver identity (employee/contractor ID from Workday HCM), license number, license class and categories, license issuing country, license expiry date, DOT medical certificate expiry, hazmat endorsement flag, IATA dangerous goods certification, years of experience, current assignment status, home depot, language proficiency, and disciplinary flag. Distinct from the workforce domain employee record — this is the fleet-specific operational driver profile with licensing and compliance attributes not held in HCM.';

CREATE OR REPLACE TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` (
    `driver_assignment_id` BIGINT COMMENT 'Unique identifier for the driver assignment record. Primary key.',
    `asset_assignment_id` BIGINT COMMENT 'Foreign key linking to fleet.asset_assignment. Business justification: fleet_driver_assignment records the pairing of a driver to a transport asset for an operational run, while asset_assignment records the assignment of that transport asset to a specific freight order, ',
    `carrier_id` BIGINT COMMENT 'Foreign key linking to network.carrier. Business justification: Driver assignments often involve contracted carrier drivers (owner-operators, subcontractors). Tracking carrier affiliation is essential for compliance (HOS, licensing), insurance coverage verificatio',
    `depot_id` BIGINT COMMENT 'Reference to the ending location for this driver assignment (depot, warehouse, terminal, customer site). Links to the location master.',
    `plan_id` BIGINT COMMENT 'Reference to the planned route for this assignment. Links to the route master.',
    `transport_asset_id` BIGINT COMMENT 'Reference to the transport asset (vehicle, truck, aircraft, vessel) assigned for this run. Links to the fleet asset master.',
    `primary_fleet_depot_id` BIGINT COMMENT 'Reference to the starting location for this driver assignment (depot, warehouse, terminal). Links to the location master.',
    `driver_profile_id` BIGINT COMMENT 'Reference to the driver assigned to this transport run. Links to the driver master profile.',
    `agreement_id` BIGINT COMMENT 'Foreign key linking to contract.agreement. Business justification: Driver assignments execute service commitments under customer/carrier agreements. Operations verifies driver qualifications (certifications, endorsements, background checks) match contract requirement',
    `shipment_leg_id` BIGINT COMMENT 'Foreign key linking to shipment.shipment_leg. Business justification: A driver assignment executes a specific shipment leg (last-mile, linehaul). Linking enables driver performance per leg (OTD rate, delivery attempts), regulatory HOS compliance per delivery leg, and SL',
    `trip_id` BIGINT COMMENT 'Reference to the operational trip or run that this driver assignment supports. Links to the trip/run master record.',
    `actual_departure_datetime` TIMESTAMP COMMENT 'Actual date and time when the driver departed with the assigned asset. Captured from GPS telematics or driver check-in. Used for on-time departure KPI tracking.',
    `actual_return_datetime` TIMESTAMP COMMENT 'Actual date and time when the driver returned and completed the assignment. Captured from GPS telematics or driver check-out. Used for on-time completion KPI tracking.',
    `assignment_duration_hours` DECIMAL(18,2) COMMENT 'Total duration of the assignment in hours, calculated from actual departure to actual return. Used for driver utilization reporting and payroll.',
    `assignment_number` STRING COMMENT 'Business-readable unique identifier for the driver assignment, used for operational tracking and communication.',
    `assignment_outcome` STRING COMMENT 'Final outcome status of the driver assignment. Captures whether the assignment was completed successfully, cancelled, or suspended, and the reason. Used for driver performance evaluation and operational analytics. [ENUM-REF-CANDIDATE: completed_on_time|completed_late|cancelled_by_ops|cancelled_by_driver|suspended_hos|suspended_mechanical|no_show — 7 candidates stripped; promote to reference product]',
    `assignment_priority` STRING COMMENT 'Business priority level for this driver assignment. Critical for time-sensitive or high-value shipments, high for expedited service, normal for standard operations, low for non-urgent tasks.. Valid values are `critical|high|normal|low`',
    `assignment_status` STRING COMMENT 'Current lifecycle status of the driver assignment. Tracks progression from scheduling through completion or cancellation.. Valid values are `scheduled|dispatched|in_progress|completed|cancelled|suspended`',
    `assignment_type` STRING COMMENT 'Type of transport assignment. FTL (Full Truckload) haul, LTL (Less Than Truckload) multi-drop, last-mile delivery, linehaul long-distance, shuttle short-distance, relay driver handoff, or dedicated contract route. [ENUM-REF-CANDIDATE: FTL|LTL|last_mile|linehaul|shuttle|relay|dedicated — 7 candidates stripped; promote to reference product]',
    `cancellation_reason` STRING COMMENT 'Free-text explanation for why the assignment was cancelled or suspended. Populated when assignment_outcome indicates cancellation or suspension.',
    `co2_emissions_kg` DECIMAL(18,2) COMMENT 'Estimated carbon dioxide equivalent emissions in kilograms for this assignment, calculated from fuel consumption. Used for sustainability reporting and carbon footprint tracking.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this driver assignment record was first created in the system. Used for audit trail and data lineage tracking.',
    `customer_feedback_score` STRING COMMENT 'Customer satisfaction score for this assignment, typically on a scale of 1-5. Captured from customer surveys or delivery feedback. Used for service quality monitoring.',
    `dispatch_datetime` TIMESTAMP COMMENT 'Date and time when the assignment was dispatched to the driver by the operations team. Marks the transition from scheduled to active status.',
    `distance_actual_km` DECIMAL(18,2) COMMENT 'Actual total distance traveled during this assignment in kilometers, captured from GPS telematics. Used for fuel consumption analysis and route optimization.',
    `distance_planned_km` DECIMAL(18,2) COMMENT 'Planned total distance for this assignment in kilometers, based on route planning. Used for fuel budgeting and driver scheduling.',
    `driver_rating` STRING COMMENT 'Performance rating assigned to the driver for this assignment, typically on a scale of 1-5. Based on factors such as on-time performance, fuel efficiency, safety, and customer feedback. Used for driver performance management.',
    `driving_hours` DECIMAL(18,2) COMMENT 'Total hours spent actively driving during this assignment. Captured from GPS telematics or electronic logging device (ELD). Used for HOS compliance and driver productivity analysis.',
    `fuel_consumed_liters` DECIMAL(18,2) COMMENT 'Total fuel consumed during this assignment in liters, captured from vehicle telematics or fuel card transactions. Used for fuel efficiency KPI tracking and cost allocation.',
    `hos_counter_at_end` DECIMAL(18,2) COMMENT 'Cumulative hours of service logged by the driver at the end of this assignment. Used for DOT hours-of-service compliance tracking and fatigue management.',
    `hos_counter_at_start` DECIMAL(18,2) COMMENT 'Cumulative hours of service logged by the driver at the start of this assignment. Used for DOT hours-of-service compliance tracking and fatigue management.',
    `hos_violation_flag` BOOLEAN COMMENT 'Boolean flag indicating whether this assignment resulted in a DOT hours-of-service violation. True if violation occurred, False otherwise. Used for compliance monitoring and driver safety management.',
    `hos_violation_type` STRING COMMENT 'Description of the type of HOS violation that occurred (e.g., exceeded 11-hour driving limit, insufficient rest break, exceeded 14-hour on-duty limit). Populated when hos_violation_flag is True.',
    `modified_timestamp` TIMESTAMP COMMENT 'Date and time when this driver assignment record was last modified in the system. Used for audit trail and change tracking.',
    `planned_departure_datetime` TIMESTAMP COMMENT 'Scheduled date and time when the driver is expected to depart with the assigned asset. Used for route planning and resource scheduling.',
    `planned_return_datetime` TIMESTAMP COMMENT 'Scheduled date and time when the driver is expected to return and complete the assignment. Used for shift planning and asset availability forecasting.',
    `rest_break_hours` DECIMAL(18,2) COMMENT 'Total hours spent on mandatory rest breaks during this assignment. Used for DOT compliance verification and fatigue management.',
    `safety_incident_description` STRING COMMENT 'Free-text description of the safety incident that occurred during this assignment. Populated when safety_incident_flag is True.',
    `safety_incident_flag` BOOLEAN COMMENT 'Boolean flag indicating whether a safety incident (accident, near-miss, traffic violation) occurred during this assignment. True if incident occurred, False otherwise. Used for driver safety scoring and risk management.',
    `special_instructions` STRING COMMENT 'Free-text field for operational notes, special handling requirements, or driver-specific instructions for this assignment (e.g., hazmat handling, customer access codes, delivery restrictions).',
    CONSTRAINT pk_driver_assignment PRIMARY KEY(`driver_assignment_id`)
) COMMENT 'Transactional record linking a driver to a specific transport asset and operational run for a defined shift or trip. Captures driver profile reference, asset reference, trip/run reference, planned departure datetime, actual departure datetime, planned return datetime, actual return datetime, assignment type (FTL haul, LTL multi-drop, last-mile, linehaul), hours of service (HOS) counter at assignment start, and assignment outcome status. Supports DOT hours-of-service compliance tracking and driver utilization reporting.';

CREATE OR REPLACE TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` (
    `maintenance_order_id` BIGINT COMMENT 'Unique identifier for the maintenance order record. Primary key for the maintenance order entity.',
    `agreement_id` BIGINT COMMENT 'Foreign key linking to contract.agreement. Business justification: Maintenance work may be performed under warranty or vendor service agreements. Finance tracks which maintenance costs are recoverable under contracts vs. operational expense. Critical for cost allocat',
    `carrier_payable_id` BIGINT COMMENT 'Foreign key linking to billing.carrier_payable. Business justification: External maintenance performed by carrier-vendors is settled via carrier payables. Real business process: vendor maintenance cost settlement. Enables reconciling maintenance orders to carrier invoices',
    `depot_id` BIGINT COMMENT 'Reference to the internal workshop or facility location where the maintenance work is being performed, applicable when maintenance_provider_type is internal_workshop.',
    `facility_id` BIGINT COMMENT 'Foreign key linking to warehouse.facility. Business justification: Fleet maintenance performed at warehouse/distribution center facilities requires linking maintenance orders to the facility for compliance auditing, facility cost allocation, and AEO/CTPAT certificati',
    `maintenance_schedule_id` BIGINT COMMENT 'Foreign key linking to fleet.maintenance_schedule. Business justification: Maintenance orders can be auto-generated from maintenance schedules (maintenance_schedule has auto_generate_order_flag). This FK tracks which preventive maintenance schedule triggered the work order. ',
    `purchase_order_id` BIGINT COMMENT 'Foreign key linking to procurement.purchase_order. Business justification: Maintenance procurement three-way match: external maintenance services are procured via PO. Linking maintenance_order to purchase_order enables PO→goods receipt→invoice three-way match and cost reconc',
    `purchase_requisition_id` BIGINT COMMENT 'Foreign key linking to procurement.purchase_requisition. Business justification: Maintenance spend authorization workflow: unplanned or external maintenance triggers a purchase requisition before a PO is raised. Linking maintenance_order to purchase_requisition supports the procur',
    `supplier_id` BIGINT COMMENT 'Reference to the external vendor or service provider performing the maintenance work, applicable when maintenance_provider_type is external_vendor, oem_service_center, or authorized_dealer.',
    `transport_asset_id` BIGINT COMMENT 'Reference to the fleet asset (vehicle, aircraft, vessel, container) that is the subject of this maintenance order.',
    `actual_completion_timestamp` TIMESTAMP COMMENT 'The actual date and time when maintenance work was finished and the asset was released back to operational status, used for downtime calculation and SLA compliance.',
    `actual_start_timestamp` TIMESTAMP COMMENT 'The actual date and time when maintenance work physically commenced, used for labor tracking and performance analysis against scheduled start.',
    `cost_center_code` STRING COMMENT 'Financial cost center code to which this maintenance orders OPEX costs are allocated, used for departmental budgeting and financial reporting integration with SAP S/4HANA Finance.. Valid values are `^[A-Z0-9]{4,10}$`',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when this maintenance order record was first created in the database, used for audit trail and data lineage.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for all monetary amounts in this maintenance order (parts_cost, labor_cost, external_service_cost, total_maintenance_cost).. Valid values are `^[A-Z]{3}$`',
    `downtime_hours` DECIMAL(18,2) COMMENT 'Total number of hours the asset was out of service due to this maintenance activity, calculated from the time the asset was taken offline until it was returned to operational status, used for availability KPIs and operational impact analysis.',
    `engine_hours` DECIMAL(18,2) COMMENT 'Engine operating hours or flight hours of the asset at the time maintenance was performed, applicable to aircraft, vessels, and heavy equipment, used for time-based maintenance scheduling.',
    `external_service_cost` DECIMAL(18,2) COMMENT 'Cost charged by external vendors or service providers for maintenance work, applicable when maintenance is outsourced, representing third-party service fees in maintenance OPEX.',
    `fault_code` STRING COMMENT 'Standardized diagnostic trouble code or fault identifier from the assets onboard diagnostic system or maintenance taxonomy, used for root cause analysis and trend identification.. Valid values are `^[A-Z0-9]{4,10}$`',
    `fault_description` STRING COMMENT 'Detailed narrative description of the fault, defect, or maintenance requirement that triggered this work order, including symptoms, error codes, and operator observations.',
    `gl_account_code` STRING COMMENT 'General ledger account code for posting maintenance costs in the financial system, enabling integration with SAP S/4HANA Finance for OPEX tracking and financial statement preparation.. Valid values are `^[0-9]{4,10}$`',
    `inspection_certificate_number` STRING COMMENT 'Official certificate or approval number issued by the regulatory authority upon successful completion of a statutory inspection, used for compliance documentation and audit trail.. Valid values are `^[A-Z0-9-]{8,20}$`',
    `inspection_expiry_date` DATE COMMENT 'Date when the regulatory inspection certificate expires and the asset requires re-inspection to maintain compliance and operational authorization.',
    `labor_cost` DECIMAL(18,2) COMMENT 'Total cost of labor for this maintenance order, calculated from labor hours and applicable labor rates (internal or vendor), representing the direct labor component of maintenance OPEX.',
    `labor_hours` DECIMAL(18,2) COMMENT 'Total number of labor hours expended on this maintenance order, including technician time for diagnosis, repair, testing, and documentation, used for cost calculation and productivity analysis.',
    `maintenance_category` STRING COMMENT 'Technical category of the maintenance work, indicating the system or component area being serviced (e.g., mechanical, electrical, hydraulic, structural, avionics, engine, transmission, brakes, tires, body, interior, safety systems). [ENUM-REF-CANDIDATE: mechanical|electrical|hydraulic|structural|avionics|engine|transmission|brakes|tires|body|interior|safety_systems — 12 candidates stripped; promote to reference product]',
    `maintenance_order_status` STRING COMMENT 'Current lifecycle state of the maintenance order: draft (being prepared), scheduled (approved and planned), in_progress (work underway), on_hold (temporarily suspended), completed (work finished and asset released), cancelled (order voided).. Valid values are `draft|scheduled|in_progress|on_hold|completed|cancelled`',
    `maintenance_provider_type` STRING COMMENT 'Classification of the entity performing the maintenance work: internal_workshop (company-owned facility), external_vendor (third-party service provider), oem_service_center (original equipment manufacturer facility), authorized_dealer (franchised service location).. Valid values are `internal_workshop|external_vendor|oem_service_center|authorized_dealer`',
    `maintenance_type` STRING COMMENT 'Classification of the maintenance work order by its nature: preventive (scheduled routine maintenance), corrective (repair of known defect), statutory_inspection (regulatory compliance inspection such as DOT annual inspection or ICAO airworthiness check), or breakdown (emergency unplanned repair).. Valid values are `preventive|corrective|statutory_inspection|breakdown`',
    `modified_timestamp` TIMESTAMP COMMENT 'System timestamp when this maintenance order record was last updated, used for audit trail and change tracking.',
    `notes` STRING COMMENT 'Free-form text field for additional notes, special instructions, or observations related to the maintenance order that do not fit structured fields.',
    `odometer_reading` DECIMAL(18,2) COMMENT 'Odometer or mileage reading of the asset at the time maintenance was performed, applicable to road vehicles, used for preventive maintenance scheduling and lifecycle tracking.',
    `parts_cost` DECIMAL(18,2) COMMENT 'Total cost of parts and materials consumed in this maintenance order, representing the direct material component of maintenance OPEX.',
    `parts_replaced_list` STRING COMMENT 'Comma-separated or structured list of part numbers and descriptions for components replaced during the maintenance activity, used for inventory management and warranty tracking.',
    `post_maintenance_status` STRING COMMENT 'Operational status of the asset immediately following completion of maintenance work: operational (fully serviceable), limited_service (operational with restrictions), out_of_service (not cleared for use), pending_inspection (awaiting final certification), scrapped (asset retired).. Valid values are `operational|limited_service|out_of_service|pending_inspection|scrapped`',
    `priority` STRING COMMENT 'Business priority level assigned to the maintenance order, determining urgency and resource allocation (critical for safety or operational impact, high for near-term service impact, medium for scheduled work, low for deferred maintenance).. Valid values are `critical|high|medium|low`',
    `raised_date` DATE COMMENT 'The date when the maintenance order was first created or raised in the system, representing the business event timestamp when the need for maintenance was identified.',
    `regulatory_inspection_type` STRING COMMENT 'Type of regulatory or statutory inspection performed as part of this maintenance order: dot_annual (DOT annual vehicle inspection), icao_airworthiness (ICAO airworthiness check), maritime_survey (vessel classification survey), emissions_test (environmental compliance test), safety_certification (safety system certification), none (not a regulatory inspection).. Valid values are `dot_annual|icao_airworthiness|maritime_survey|emissions_test|safety_certification|none`',
    `scheduled_completion_date` DATE COMMENT 'The planned date when maintenance work is expected to be completed and the asset returned to service, used for operational planning and customer commitments.',
    `scheduled_start_date` DATE COMMENT 'The planned date when maintenance work is scheduled to begin, used for resource planning and asset availability forecasting.',
    `total_maintenance_cost` DECIMAL(18,2) COMMENT 'Total cost of the maintenance order including parts, labor, external services, and any other direct costs, representing the complete OPEX impact of this maintenance event for financial reporting and asset lifecycle costing.',
    `warranty_claim_flag` BOOLEAN COMMENT 'Boolean indicator whether this maintenance order is associated with a warranty claim against the asset manufacturer or component supplier, used for cost recovery tracking.',
    `warranty_claim_number` STRING COMMENT 'Reference number for the associated warranty claim submitted to the manufacturer or supplier, applicable when warranty_claim_flag is true.. Valid values are `^WC-[A-Z0-9]{8,12}$`',
    `work_order_number` STRING COMMENT 'Externally-known unique business identifier for the maintenance work order, used for tracking and reference across systems and with external vendors.. Valid values are `^WO-[A-Z0-9]{8,12}$`',
    `work_performed_description` STRING COMMENT 'Detailed narrative of the actual maintenance work performed, including procedures followed, parts replaced, adjustments made, and test results, completed upon work order closure.',
    CONSTRAINT pk_maintenance_order PRIMARY KEY(`maintenance_order_id`)
) COMMENT 'Transactional record for all planned and unplanned maintenance work orders raised against fleet assets. Captures asset reference, maintenance type (preventive, corrective, statutory inspection, DOT annual inspection, ICAO airworthiness check), work order number, raised date, scheduled date, completion date, maintenance provider (internal workshop or external vendor reference), fault description, parts replaced, labor hours, total maintenance cost (OPEX), downtime duration, and post-maintenance asset status. Integrates with SAP TM for asset availability updates and SAP S/4HANA Finance for OPEX cost posting.';

CREATE OR REPLACE TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` (
    `maintenance_schedule_id` BIGINT COMMENT 'Unique identifier for the maintenance schedule record. Primary key.',
    `agreement_id` BIGINT COMMENT 'Foreign key linking to contract.agreement. Business justification: Fleet maintenance contract governance: maintenance schedules are defined under OEM warranty agreements or fleet maintenance service contracts specifying intervals, standards, and costs. Linking schedu',
    `asset_type_id` BIGINT COMMENT 'Foreign key linking to fleet.asset_type. Business justification: maintenance_schedule currently has asset_type (STRING) storing the asset type as free text. Maintenance schedules are often defined at the asset type level (e.g., all trucks of type X need service ev',
    `facility_id` BIGINT COMMENT 'Reference to the maintenance facility, depot, or service center where this maintenance is scheduled to be performed.',
    `supplier_id` BIGINT COMMENT 'Reference to the preferred maintenance vendor or service provider for this scheduled maintenance. Null if performed in-house.',
    `transport_asset_id` BIGINT COMMENT 'Reference to the fleet asset (vehicle, aircraft, vessel, container) to which this maintenance schedule applies.',
    `auto_generate_order_flag` BOOLEAN COMMENT 'Indicates whether the system should automatically generate a maintenance work order when the schedule trigger conditions are met (True) or require manual creation (False).',
    `compliance_mandatory_flag` BOOLEAN COMMENT 'Indicates whether this maintenance schedule is mandated by regulatory compliance requirements (True) or is discretionary preventive maintenance (False).',
    `cost_currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the estimated cost (e.g., USD, EUR, GBP).. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this maintenance schedule record was first created in the system.',
    `downtime_required_flag` BOOLEAN COMMENT 'Indicates whether the asset must be taken out of service (True) or can remain operational during maintenance (False).',
    `estimated_cost` DECIMAL(18,2) COMMENT 'Estimated total cost in base currency for completing this scheduled maintenance service, including labor and parts.',
    `estimated_duration_hours` DECIMAL(18,2) COMMENT 'Estimated time in hours required to complete this maintenance service.',
    `interval_unit` STRING COMMENT 'Unit of measure for the maintenance interval value (miles, kilometers, engine hours, calendar days, operating cycles).. Valid values are `miles|kilometers|hours|days|cycles`',
    `interval_value` DECIMAL(18,2) COMMENT 'Numeric value of the maintenance interval (e.g., 5000 for 5000 miles, 100 for 100 engine hours, 365 for 365 days).',
    `last_completed_date` DATE COMMENT 'The date when this maintenance service was last completed for the asset.',
    `last_completed_hours` DECIMAL(18,2) COMMENT 'The engine hour meter reading when this maintenance service was last completed. Null if not applicable.',
    `last_completed_mileage` DECIMAL(18,2) COMMENT 'The odometer mileage reading when this maintenance service was last completed. Null if not applicable.',
    `last_modified_by` STRING COMMENT 'Username or identifier of the user who last modified this maintenance schedule record.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Date and time when this maintenance schedule record was last updated in the system.',
    `lead_time_days` STRING COMMENT 'Number of days advance notice required before the scheduled maintenance due date to allow for planning, parts procurement, and resource allocation.',
    `next_due_date` DATE COMMENT 'The calendar date by which the next scheduled maintenance service must be completed. Null if trigger basis is not calendar-based.',
    `next_due_hours` DECIMAL(18,2) COMMENT 'The engine hour meter reading at which the next scheduled maintenance service is due. Null if trigger basis is not engine hours or flight hours.',
    `next_due_mileage` DECIMAL(18,2) COMMENT 'The odometer mileage reading at which the next scheduled maintenance service is due. Null if trigger basis is not mileage.',
    `notes` STRING COMMENT 'Free-text field for additional notes, special instructions, or comments related to this maintenance schedule.',
    `parts_required_flag` BOOLEAN COMMENT 'Indicates whether replacement parts or consumables are required for this maintenance service (True) or if it is inspection/labor only (False).',
    `priority_level` STRING COMMENT 'Business priority level assigned to this maintenance schedule based on asset criticality and operational impact.. Valid values are `critical|high|medium|low`',
    `regulation_reference` STRING COMMENT 'Specific regulation, code section, or standard that mandates this maintenance schedule (e.g., 49 CFR 396.17, ICAO Annex 6 Part I, IMO SOLAS Chapter II-1).',
    `regulatory_body` STRING COMMENT 'The governing regulatory body that mandates this maintenance requirement (DOT, ICAO, IMO, FAA, FMCSA, EASA, IATA). Null if not compliance-driven. [ENUM-REF-CANDIDATE: DOT|ICAO|IMO|FAA|FMCSA|EASA|IATA — 7 candidates stripped; promote to reference product]',
    `schedule_effective_date` DATE COMMENT 'The date from which this maintenance schedule becomes active and applicable to the asset.',
    `schedule_expiry_date` DATE COMMENT 'The date on which this maintenance schedule is no longer applicable (e.g., asset retirement, schedule superseded by new regulation). Null for open-ended schedules.',
    `schedule_status` STRING COMMENT 'Current lifecycle status of the maintenance schedule (active, suspended, completed, overdue, cancelled).. Valid values are `active|suspended|completed|overdue|cancelled`',
    `service_description` STRING COMMENT 'Detailed description of the maintenance service activities and scope of work included in this schedule.',
    `service_type` STRING COMMENT 'Type of preventive maintenance service defined in this schedule (e.g., oil change, tire rotation, brake inspection, DOT annual inspection, ICAO 100-hour check, engine overhaul).. Valid values are `oil_change|tire_rotation|brake_inspection|engine_overhaul|dot_annual_inspection|icao_100_hour_check`',
    `tolerance_after_days` STRING COMMENT 'Number of days after the due date that the maintenance service may be performed late before the asset is considered non-compliant or overdue.',
    `tolerance_before_days` STRING COMMENT 'Number of days before the due date that the maintenance service may be performed early without resetting the schedule interval.',
    `trigger_basis` STRING COMMENT 'The measurement basis that triggers this maintenance service (mileage interval, engine hours, calendar days, flight hours, operating cycles).. Valid values are `mileage|engine_hours|calendar_days|flight_hours|operating_cycles`',
    CONSTRAINT pk_maintenance_schedule PRIMARY KEY(`maintenance_schedule_id`)
) COMMENT 'Master record defining the preventive maintenance schedule and service intervals for each fleet asset type. Captures asset type, service type (oil change, tyre rotation, brake inspection, DOT annual inspection, ICAO 100-hour check), trigger basis (mileage interval, engine hours, calendar days), next due mileage/hours/date, last completed date, compliance mandatory flag, regulatory body (DOT, ICAO, IMO), and schedule status. Drives automated maintenance_order generation and ensures regulatory compliance with DOT, ICAO, and IMO inspection requirements.';

CREATE OR REPLACE TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` (
    `fuel_transaction_id` BIGINT COMMENT 'Unique identifier for the fuel transaction record. Primary key.',
    `asset_assignment_id` BIGINT COMMENT 'Foreign key linking to fleet.asset_assignment. Business justification: A fuel transaction occurs during a specific operational assignment of a transport asset. Linking fuel_transaction to asset_assignment enables direct cost allocation of fuel expenses to the specific as',
    `depot_id` BIGINT COMMENT 'Foreign key linking to fleet.depot. Business justification: Fuel transactions can occur at fleet depot fuel stations (on-site fueling). Adding depot_id links fuel uplifts to the specific depot. Nullable because many fuel transactions occur at external commerci',
    `driver_profile_id` BIGINT COMMENT 'Reference to the driver or operator who authorized or performed the fuel transaction. May be null for automated or depot-based refueling.',
    `agreement_id` BIGINT COMMENT 'Foreign key linking to contract.agreement. Business justification: Fuel purchases may be governed by fuel supply agreements with negotiated rates and volume commitments. Procurement validates transaction pricing against contracted fuel rates, surcharge schedules, and',
    `fuel_index_id` BIGINT COMMENT 'Foreign key linking to pricing.fuel_index. Business justification: Fuel surcharge billing reconciliation requires linking actual fuel transactions to the published fuel index used for customer surcharge calculation. Finance teams reconcile fuel costs against index-ba',
    `lane_id` BIGINT COMMENT 'Foreign key linking to route.lane. Business justification: Fuel cost per lane is a standard logistics cost analysis used for lane profitability and carrier rate negotiation. fuel_transaction has plan_id and trip_id but no direct lane_id; direct FK enables lan',
    `partner_id` BIGINT COMMENT 'Foreign key linking to network.network_partner. Business justification: Fuel suppliers are network partners in logistics operations. While supplier_id links to procurement.supplier, network_partner is the natural logistics domain entity for partner performance tracking, s',
    `plan_id` BIGINT COMMENT 'Reference to the route or trip during which this fuel transaction occurred. Links to route execution data for cost allocation.',
    `purchase_order_id` BIGINT COMMENT 'Foreign key linking to procurement.purchase_order. Business justification: Bulk fuel procurement reconciliation: fleet operators procure fuel via POs against fuel suppliers. Individual fuel transactions are reconciled against the originating PO for spend management and budge',
    `supplier_id` BIGINT COMMENT 'Reference to the fuel supplier or energy provider. Links to supplier master data for procurement and payables.',
    `transport_asset_id` BIGINT COMMENT 'Reference to the fleet asset (vehicle, aircraft, vessel, container) that received fuel or energy. Links to the transport_asset master data.',
    `trip_id` BIGINT COMMENT 'Reference to the specific trip or journey during which this fuel transaction occurred. Used for trip-level cost analysis.',
    `authorization_code` STRING COMMENT 'Authorization or approval code issued by the fuel card provider or payment processor at the time of transaction.',
    `co2e_emission_factor` DECIMAL(18,2) COMMENT 'CO2e emission factor applied to calculate greenhouse gas emissions from this fuel consumption. Expressed in kg CO2e per unit of fuel. Used for sustainability reporting under EU ETS and CORSIA.',
    `co2e_emissions_kg` DECIMAL(18,2) COMMENT 'Total CO2e emissions generated by this fuel transaction, calculated as quantity multiplied by emission factor. Feeds sustainability domain for GHG reporting.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this fuel transaction record was first created in the system. Used for audit trail and data lineage.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the transaction amount (e.g., USD, EUR, GBP).. Valid values are `^[A-Z]{3}$`',
    `discount_amount` DECIMAL(18,2) COMMENT 'Discount or rebate amount applied to the transaction based on supplier agreements or fuel card programs.',
    `fuel_card_number` STRING COMMENT 'Fuel card or fleet card number used for the transaction. Masked or tokenized for security. Used for reconciliation with supplier invoices.',
    `fuel_card_provider` STRING COMMENT 'Name of the fuel card provider or fleet card issuer (e.g., Shell Fleet, BP Fuel Card, WEX).',
    `fuel_efficiency` DECIMAL(18,2) COMMENT 'Calculated fuel efficiency for this transaction (e.g., km per litre, miles per gallon). Derived from odometer change and fuel quantity. Used for fleet performance KPIs.',
    `fuel_grade` STRING COMMENT 'Grade or quality specification of the fuel (e.g., premium, regular, ultra-low sulfur diesel). Used for asset maintenance and performance tracking.',
    `fuel_station_code` BIGINT COMMENT 'Reference to the fuel station, depot, or charging station where the transaction occurred. Links to location or supplier facility master data.',
    `fuel_station_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code where the fuel station is located. Used for tax and regulatory compliance reporting.. Valid values are `^[A-Z]{3}$`',
    `fuel_station_location` STRING COMMENT 'Geographic location description of the fuel station (city, region, or address). Used for route analysis and cost allocation.',
    `fuel_station_name` STRING COMMENT 'Name of the fuel station, depot, or charging facility where the transaction took place.',
    `fuel_type` STRING COMMENT 'Type of fuel or energy consumed. Includes diesel, petrol (gasoline), LNG (Liquefied Natural Gas), CNG (Compressed Natural Gas), SAF (Sustainable Aviation Fuel), electric charge, hydrogen, or biodiesel. Critical for sustainability and emissions reporting. [ENUM-REF-CANDIDATE: diesel|petrol|lng|cng|saf|electric|hydrogen|biodiesel — 8 candidates stripped; promote to reference product]',
    `general_ledger_account` STRING COMMENT 'General ledger account code for fuel expense posting. Used for financial accounting and P&L reporting.',
    `is_emergency_refuel` BOOLEAN COMMENT 'Flag indicating whether this was an emergency or unplanned refueling event outside of normal depot operations. Used for exception analysis.',
    `is_reconciled` BOOLEAN COMMENT 'Flag indicating whether this transaction has been reconciled with supplier invoices and financial records.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this fuel transaction record was last modified. Used for audit trail and change tracking.',
    `notes` STRING COMMENT 'Free-text notes or comments about the fuel transaction. May include driver remarks, exception explanations, or audit notes.',
    `odometer_reading` DECIMAL(18,2) COMMENT 'Odometer or hour-meter reading of the asset at the time of fuel uplift. Used for fuel efficiency analysis and maintenance scheduling.',
    `odometer_unit` STRING COMMENT 'Unit of measure for the odometer reading (kilometers, miles, or operating hours for aircraft/vessels).. Valid values are `km|miles|hours`',
    `payment_method` STRING COMMENT 'Method of payment used for the fuel transaction (fuel card, credit card, cash, invoice, direct debit).. Valid values are `fuel_card|credit_card|cash|invoice|direct_debit`',
    `quantity` DECIMAL(18,2) COMMENT 'Quantity of fuel or energy consumed in the transaction. Measured in litres for liquid fuels or kWh for electric charging.',
    `reconciliation_date` DATE COMMENT 'Date when the transaction was reconciled with supplier invoices and approved for payment.',
    `source_system` STRING COMMENT 'Name of the source system or fuel card provider system from which this transaction was captured (e.g., SAP TM, fuel card provider API, telematics system).',
    `supplier_invoice_number` STRING COMMENT 'Invoice number issued by the fuel supplier for this transaction. Used for accounts payable reconciliation.',
    `tax_amount` DECIMAL(18,2) COMMENT 'Total tax amount applied to the fuel transaction. Includes VAT, excise duty, or other applicable fuel taxes.',
    `total_cost` DECIMAL(18,2) COMMENT 'Total cost of the fuel transaction including base fuel cost and any applicable surcharges or taxes. Represents the net amount payable.',
    `transaction_datetime` TIMESTAMP COMMENT 'The date and time when the fuel uplift or energy charge event occurred. Principal business event timestamp.',
    `transaction_number` STRING COMMENT 'Externally-known unique transaction number or receipt number issued by the fuel supplier or fuel card provider.',
    `transaction_status` STRING COMMENT 'Current lifecycle status of the fuel transaction. Indicates whether the transaction has been completed, is pending reconciliation, disputed, cancelled, or reversed.. Valid values are `completed|pending|disputed|cancelled|reversed`',
    `unit_cost` DECIMAL(18,2) COMMENT 'Cost per unit of fuel or energy (e.g., cost per litre, cost per kWh). Used for cost analysis and budgeting.',
    `unit_of_measure` STRING COMMENT 'Unit of measure for the fuel quantity. Typically litres or gallons for liquid fuels, kWh for electric, kg for hydrogen, or m3 for gas.. Valid values are `litres|gallons|kwh|kg|m3`',
    CONSTRAINT pk_fuel_transaction PRIMARY KEY(`fuel_transaction_id`)
) COMMENT 'Transactional record capturing every fuel uplift and energy consumption event for fleet assets. Tracks asset reference, driver reference, transaction datetime, fuel station/depot location, fuel type (diesel, petrol, LNG, SAF — Sustainable Aviation Fuel, electric charge), quantity (litres or kWh), unit cost, total cost, odometer reading at fill, fuel card number, supplier reference, and CO2e emission factor applied. Feeds sustainability domain for GHG reporting under EU ETS and CORSIA, and finance domain for OPEX fuel cost allocation.';

CREATE OR REPLACE TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` (
    `asset_inspection_id` BIGINT COMMENT 'Unique identifier for the asset inspection record. Primary key.',
    `compliance_program_id` BIGINT COMMENT 'Foreign key linking to customs.compliance_program. Business justification: Asset inspections (security seals, container integrity, GPS functionality) are mandatory for customs compliance programs (C-TPAT, AEO). Inspection certificates must be maintained as evidence of progra',
    `declaration_id` BIGINT COMMENT 'Foreign key linking to customs.declaration. Business justification: Customs authorities physically inspect vehicles at border crossings and record results against the governing customs declaration. This is distinct from the existing compliance_program link — it captur',
    `depot_id` BIGINT COMMENT 'Foreign key linking to fleet.depot. Business justification: Inspections are often conducted at fleet depots/workshops. Adding depot_id allows tracking which depot performed the inspection. Nullable because inspections can also occur at external regulatory auth',
    `facility_id` BIGINT COMMENT 'Foreign key linking to warehouse.facility. Business justification: Vehicle inspections conducted at warehouse/DC facilities must be linked to the facility for CTPAT/AEO compliance audits, facility safety reporting, and regulatory filing. inspection_location plain att',
    `network_node_id` BIGINT COMMENT 'Foreign key linking to route.network_node. Business justification: Inspections at border crossings, ports, and hubs are a regulatory compliance requirement (port state control, customs). Normalizing inspection_location to network_node enables node-level compliance re',
    `supplier_id` BIGINT COMMENT 'Foreign key linking to procurement.supplier. Business justification: Third-party inspection services procurement: certified inspection bodies are registered as procurement suppliers. Linking asset_inspection to the performing supplier enables supplier performance track',
    `transport_asset_id` BIGINT COMMENT 'Reference to the fleet asset (vehicle, aircraft, vessel, container) that was inspected.',
    `certificate_expiry_date` DATE COMMENT 'The date on which the issued regulatory certificate expires, triggering the need for a subsequent inspection to maintain compliance.',
    `certificate_issue_date` DATE COMMENT 'The date the regulatory certificate or compliance document was officially issued following successful inspection.',
    `certificate_number` STRING COMMENT 'Unique identifier of the regulatory certificate or compliance document issued. Used for regulatory reporting and audit verification.',
    `corrective_action_deadline` DATE COMMENT 'The date by which all required corrective actions must be completed to maintain regulatory compliance and operational status.',
    `corrective_actions_required` STRING COMMENT 'Detailed description of corrective actions, repairs, or remediation work required to address identified defects and achieve compliance.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this inspection record was first created in the system. Used for audit trail and data lineage tracking.',
    `critical_defects_count` STRING COMMENT 'Number of critical or safety-related defects that require immediate corrective action and may result in asset being placed out of service.',
    `defects_description` STRING COMMENT 'Detailed narrative description of all defects, non-conformances, and observations identified during the inspection. Includes severity classification and affected components.',
    `defects_identified_count` STRING COMMENT 'Total number of defects, non-conformances, or discrepancies identified during the inspection. Zero indicates no issues found.',
    `inspection_checklist_reference` STRING COMMENT 'Reference identifier for the standardized inspection checklist or procedure document used to conduct this inspection.',
    `inspection_cost` DECIMAL(18,2) COMMENT 'Total cost incurred for conducting the inspection, including labor, materials, third-party fees, and administrative overhead.',
    `inspection_cost_currency` STRING COMMENT 'Three-letter ISO currency code for the inspection cost amount.. Valid values are `^[A-Z]{3}$`',
    `inspection_date` DATE COMMENT 'The calendar date on which the inspection was conducted. This is the principal business event timestamp for regulatory compliance and audit purposes.',
    `inspection_document_url` STRING COMMENT 'URL or file path to the digital inspection report, certificate scan, or supporting documentation stored in the document management system.',
    `inspection_end_time` TIMESTAMP COMMENT 'Precise timestamp when the inspection was completed. Used to calculate inspection duration and resource utilization.',
    `inspection_location_country` STRING COMMENT 'Three-letter ISO country code of the jurisdiction where the inspection took place. Critical for determining applicable regulatory framework.. Valid values are `^[A-Z]{3}$`',
    `inspection_notes` STRING COMMENT 'Additional free-text notes, observations, or comments recorded by the inspector that provide context beyond structured fields.',
    `inspection_number` STRING COMMENT 'Externally-known unique identifier or reference number for this inspection event, often used for regulatory reporting and audit trails.',
    `inspection_outcome` STRING COMMENT 'Overall result of the inspection. Pass indicates full compliance; fail indicates critical defects requiring immediate action; conditional pass indicates minor defects with corrective action required within a specified timeframe.. Valid values are `pass|fail|conditional pass|not applicable`',
    `inspection_start_time` TIMESTAMP COMMENT 'Precise timestamp when the inspection commenced. Used for operational tracking and labor cost allocation.',
    `inspection_status` STRING COMMENT 'Current lifecycle state of the inspection event. Tracks progression from scheduling through completion or cancellation.. Valid values are `scheduled|in progress|completed|cancelled|deferred`',
    `inspection_type` STRING COMMENT 'Category of inspection conducted. Determines the regulatory framework, scope, and compliance requirements applicable to this inspection event.. Valid values are `DOT roadside inspection|ICAO airworthiness check|IMO vessel survey|pre-trip inspection|annual safety inspection|C-TPAT security inspection`',
    `inspector_authority` STRING COMMENT 'The organization or regulatory body under whose authority the inspection was conducted (e.g., DOT, ICAO, IMO, internal fleet safety team, third-party auditor).',
    `inspector_certification_number` STRING COMMENT 'Official certification or license number of the inspector, required for regulatory inspections to validate inspector qualifications.',
    `inspector_name` STRING COMMENT 'Full name of the individual who conducted the inspection. May be an internal employee or external regulatory authority representative.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this inspection record was last updated. Used for audit trail and change tracking.',
    `next_inspection_due_date` DATE COMMENT 'The date by which the next scheduled inspection of this type must be conducted to maintain regulatory compliance and operational certification.',
    `odometer_reading_at_inspection` DECIMAL(18,2) COMMENT 'Odometer or usage meter reading (kilometers, miles, flight hours, engine hours) recorded at the time of inspection. Used for maintenance interval tracking.',
    `out_of_service_flag` BOOLEAN COMMENT 'Indicates whether the asset was placed out of service as a result of this inspection due to critical safety defects or regulatory non-compliance.',
    `out_of_service_start_date` DATE COMMENT 'The date the asset was officially placed out of service following the inspection. Null if asset was not taken out of service.',
    `regulatory_certificate_issued` STRING COMMENT 'Name or type of regulatory certificate, permit, or compliance document issued as a result of passing this inspection (e.g., DOT Annual Inspection Certificate, ICAO Certificate of Airworthiness, IMO Safety Equipment Certificate).',
    `regulatory_filing_reference` STRING COMMENT 'Reference number or identifier for any regulatory filing, report, or submission made to authorities as a result of this inspection (e.g., DOT inspection report number, ICAO occurrence report).',
    `reinspection_due_date` DATE COMMENT 'The date by which the reinspection must be conducted to verify corrective action completion. Null if no reinspection is required.',
    `reinspection_required_flag` BOOLEAN COMMENT 'Indicates whether a follow-up reinspection is required to verify that corrective actions have been completed and defects resolved.',
    CONSTRAINT pk_asset_inspection PRIMARY KEY(`asset_inspection_id`)
) COMMENT 'Transactional record for all formal regulatory and operational inspections conducted on fleet assets. Captures asset reference, inspection type (DOT roadside inspection, ICAO airworthiness check, IMO vessel survey, pre-trip inspection, annual safety inspection, C-TPAT security inspection), inspection date, inspector name/authority, inspection outcome (pass, fail, conditional), defects identified, corrective actions required, reinspection due date, and regulatory certificate issued. Distinct from maintenance_order — inspections are compliance events that may or may not trigger maintenance work.';

CREATE OR REPLACE TABLE `transport_shipping_ecm`.`fleet`.`asset_licence` (
    `asset_licence_id` BIGINT COMMENT 'Unique identifier for the asset licence record. Primary key.',
    `asset_type_id` BIGINT COMMENT 'Foreign key linking to fleet.asset_type. Business justification: A regulatory licence or permit is typically issued for a specific asset type classification (e.g., DOT operating authority for heavy trucks, ICAO airworthiness certificate for a specific aircraft cate',
    `invoice_id` BIGINT COMMENT 'Foreign key linking to billing.invoice. Business justification: Licence renewals, registration fees, and regulatory compliance fees generate invoices tracked against specific licence records (licence_fee_amount confirms cost tracking). Linking asset_licence to inv',
    `transport_asset_id` BIGINT COMMENT 'Reference to the fleet asset (vehicle, aircraft, vessel, container) to which this licence applies.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this licence record was first created in the system. Audit trail for data lineage and compliance reporting.',
    `document_reference` STRING COMMENT 'Reference identifier or file path to the scanned or digital copy of the physical licence certificate or permit document stored in the document management system.',
    `effective_date` DATE COMMENT 'Date from which the licence becomes legally valid and enforceable. May differ from issue_date if there is a grace period or delayed activation.',
    `endorsements` STRING COMMENT 'Additional endorsements, restrictions, or special conditions attached to the licence (e.g., hazmat endorsement, night flight restriction, coastal waters only). Free-text field for regulatory notes.',
    `expiry_date` DATE COMMENT 'Date on which the licence or permit expires and is no longer valid. Null for licences with indefinite validity or those that do not expire.',
    `inspection_authority` STRING COMMENT 'Name of the agency or third-party organization authorized to conduct inspections for this licence (e.g., FAA Designated Airworthiness Representative, Port State Control Inspector).',
    `inspection_required_flag` BOOLEAN COMMENT 'Indicates whether a physical inspection or audit by the regulatory authority is required as part of the licence issuance or renewal process. True = inspection required; False = no inspection required.',
    `issue_date` DATE COMMENT 'Date on which the licence or permit was officially issued by the regulatory authority. Marks the start of the licence validity period.',
    `issuing_authority` STRING COMMENT 'Name of the regulatory body, government agency, or certification authority that issued the licence or permit (e.g., Federal Aviation Administration, Department of Motor Vehicles, Port State Control).',
    `issuing_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the jurisdiction that issued the licence (e.g., USA, GBR, DEU, CHN).. Valid values are `^[A-Z]{3}$`',
    `jurisdiction` STRING COMMENT 'Specific jurisdiction, state, province, or region within the issuing country where the licence is valid (e.g., California, Ontario, Bavaria). Null if the licence is valid nationwide.',
    `last_inspection_date` DATE COMMENT 'Date of the most recent regulatory inspection or audit conducted for this licence. Null if no inspection has been performed.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this licence record. Tracks data modification history for audit and compliance purposes.',
    `licence_category` STRING COMMENT 'Sub-classification or category code within the licence type (e.g., for vehicle registration: commercial, private, heavy goods; for airworthiness: transport category, restricted category).',
    `licence_class` STRING COMMENT 'Class designation within the licence category, defining specific operational limits or capabilities (e.g., Class 1 for heavy trucks, Class A for multi-engine aircraft).',
    `licence_fee_amount` DECIMAL(18,2) COMMENT 'Total fee paid to the issuing authority for the issuance or renewal of this licence. Excludes taxes and processing charges.',
    `licence_fee_currency` STRING COMMENT 'ISO 4217 three-letter currency code for the licence fee amount (e.g., USD, EUR, GBP).. Valid values are `^[A-Z]{3}$`',
    `licence_number` STRING COMMENT 'The official licence, permit, or certificate number issued by the regulatory authority. This is the externally-known unique identifier for the licence.',
    `licence_type` STRING COMMENT 'Classification of the licence or permit. Defines the regulatory purpose and scope of the licence (e.g., vehicle registration for road use, airworthiness certificate for aircraft operation, dangerous goods permit for hazardous cargo transport). [ENUM-REF-CANDIDATE: vehicle_registration|operating_licence|airworthiness_certificate|vessel_class_certificate|dangerous_goods_permit|oversize_overweight_permit|cross_border_transit_permit|emission_certificate|insurance_certificate|roadworthiness_certificate — 10 candidates stripped; promote to reference product]',
    `next_inspection_due_date` DATE COMMENT 'Scheduled date for the next mandatory inspection or audit required to maintain licence validity. Null if no future inspection is scheduled.',
    `notes` STRING COMMENT 'Free-text field for additional comments, special conditions, or operational notes related to this licence (e.g., pending appeal, conditional approval, temporary exemption granted).',
    `payment_reference` STRING COMMENT 'Payment transaction reference or receipt number for the licence fee payment. Used for audit and reconciliation purposes.',
    `regulatory_reference` STRING COMMENT 'Citation of the specific regulation, statute, or legal framework under which this licence is issued (e.g., 49 CFR Part 383, ICAO Annex 8, SOLAS Chapter II-1).',
    `renewal_due_date` DATE COMMENT 'Target date by which the licence renewal process must be initiated to avoid lapse. Typically set ahead of expiry_date to allow processing time.',
    `renewal_reminder_days` STRING COMMENT 'Number of days before expiry_date when automated renewal reminders should be triggered to fleet managers and compliance officers.',
    `responsible_party` STRING COMMENT 'Name or employee ID of the fleet manager, compliance officer, or department responsible for managing and renewing this licence.',
    `validity_status` STRING COMMENT 'Current validity state of the licence. Indicates whether the asset is legally compliant to operate under this licence. Valid = currently active and compliant; Expired = past expiry date; Suspended = temporarily invalid; Revoked = permanently cancelled; Pending Renewal = renewal application submitted; Pending Approval = initial application under review.. Valid values are `valid|expired|suspended|revoked|pending_renewal|pending_approval`',
    CONSTRAINT pk_asset_licence PRIMARY KEY(`asset_licence_id`)
) COMMENT 'Master record tracking all regulatory licences, permits, certificates, and registrations associated with individual fleet assets. Captures asset reference, licence/permit type (vehicle registration, operating licence, airworthiness certificate, vessel class certificate, dangerous goods transport permit, oversize/overweight permit, cross-border transit permit), issuing authority, issue date, expiry date, licence number, jurisdiction/country, renewal reminder days, and current validity status. Ensures DOT, ICAO, IMO, and national transport authority compliance across the global fleet.';

CREATE OR REPLACE TABLE `transport_shipping_ecm`.`fleet`.`incident` (
    `incident_id` BIGINT COMMENT 'Unique identifier for the fleet incident record. Primary key.',
    `asset_assignment_id` BIGINT COMMENT 'Foreign key linking to fleet.asset_assignment. Business justification: Incidents occur during specific operational assignments (asset_assignment represents a vehicle assigned to a freight order/route). Linking incident to asset_assignment provides full operational contex',
    `cargo_claim_id` BIGINT COMMENT 'Reference to the insurance claim filed for this incident (if applicable). Links to the claim domain for processing.',
    `carrier_id` BIGINT COMMENT 'Foreign key linking to network.carrier. Business justification: Incidents involving contracted carrier assets or drivers require carrier linkage for liability determination, insurance claims processing, carrier performance impact assessment, and regulatory reporti',
    `consignment_id` BIGINT COMMENT 'Reference to the shipment being transported at the time of the incident (if applicable). Links to cargo damage claims.',
    `declaration_id` BIGINT COMMENT 'Foreign key linking to customs.declaration. Business justification: Incidents during cross-border transport (accidents, cargo damage, theft) must be reported in relation to customs declarations for insurance claims, duty adjustments, and regulatory investigations. Req',
    `driver_profile_id` BIGINT COMMENT 'Reference to the driver or operator assigned to the asset at the time of the incident.',
    `facility_id` BIGINT COMMENT 'Foreign key linking to warehouse.facility. Business justification: Incidents occurring at warehouse facilities must be linked to the facility for safety reporting, insurance claim processing, and regulatory compliance (OSHA/DOT). Facility-level incident tracking is r',
    `lane_id` BIGINT COMMENT 'Foreign key linking to route.lane. Business justification: Lane-level incident rate reporting is a regulatory (DOT), insurance, and safety management requirement. Identifying high-risk lanes drives route optimization decisions. incident links to trip and asse',
    `penalty_clause_id` BIGINT COMMENT 'Foreign key linking to contract.penalty_clause. Business justification: Incident-driven penalty enforcement: incidents (cargo damage, delays, safety violations) directly trigger specific penalty clauses in contracts. This link enables automated penalty event creation from',
    `service_case_id` BIGINT COMMENT 'Foreign key linking to customer.service_case. Business justification: Fleet incidents involving cargo damage or delivery failure directly trigger customer service cases. Linking incident to service_case enables customer service teams to reference the root fleet incident',
    `transport_asset_id` BIGINT COMMENT 'Reference to the transport asset (vehicle, aircraft, vessel, container) involved in the incident.',
    `trip_id` BIGINT COMMENT 'Foreign key linking to fleet.trip. Business justification: Incidents (accidents, near-misses, cargo damage) occur during specific trips. Adding trip_id links the incident to the trip record for trip-level safety analysis and reporting. Nullable for incidents ',
    `asset_damage_currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the asset damage estimated cost (e.g., USD, EUR, GBP).. Valid values are `^[A-Z]{3}$`',
    `asset_damage_estimated_cost` DECIMAL(18,2) COMMENT 'Estimated cost of damage to the transport asset (vehicle, aircraft, vessel, container) in the incident currency. Includes repair or replacement costs.',
    `cargo_damage_currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the cargo damage estimated cost (e.g., USD, EUR, GBP).. Valid values are `^[A-Z]{3}$`',
    `cargo_damage_estimated_cost` DECIMAL(18,2) COMMENT 'Estimated cost of damage to cargo or goods in the incident currency. Used for cargo claim processing.',
    `cargo_damage_flag` BOOLEAN COMMENT 'Indicates whether cargo or goods being transported were damaged in the incident. True if cargo damaged, False otherwise.',
    `corrective_action_description` STRING COMMENT 'Detailed description of corrective actions taken or planned to prevent recurrence, including training, maintenance, policy changes, or process improvements.',
    `corrective_action_required_flag` BOOLEAN COMMENT 'Indicates whether corrective actions are required to prevent recurrence of similar incidents. True if corrective actions required, False otherwise.',
    `corrective_action_status` STRING COMMENT 'Current status of corrective actions identified for this incident. Not_required: no actions needed. Pending: actions identified but not started. In_progress: actions being implemented. Completed: all actions finished. Overdue: actions past due date.. Valid values are `not_required|pending|in_progress|completed|overdue`',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when this incident record was first created in the fleet management system.',
    `datetime` TIMESTAMP COMMENT 'The date and time when the incident occurred in the field. This is the real-world event timestamp, distinct from when the incident was reported or recorded in the system.',
    `dot_report_submitted_date` DATE COMMENT 'Date when the DOT accident report was submitted to the regulatory authority (if applicable).',
    `dot_reportable_flag` BOOLEAN COMMENT 'Indicates whether this incident meets the US Department of Transportation (DOT) criteria for mandatory accident reporting. True if DOT reportable, False otherwise.',
    `fatality_count` STRING COMMENT 'Total number of fatalities resulting from the incident.',
    `incident_number` STRING COMMENT 'Externally-visible unique incident reference number used for tracking and reporting. Format: INC-XXXXXXXXXX.. Valid values are `^INC-[0-9]{10}$`',
    `incident_status` STRING COMMENT 'Current lifecycle status of the incident record. Reported: initial notification received. Under_investigation: active investigation in progress. Pending_review: investigation complete, awaiting management review. Closed: incident resolved and closed. Reopened: closed incident reopened for additional investigation.. Valid values are `reported|under_investigation|pending_review|closed|reopened`',
    `incident_type` STRING COMMENT 'Classification of the incident: accident (collision or crash), near_miss (potential accident avoided), breakdown (mechanical failure), cargo_damage (damage to goods), security_incident (unauthorized access or threat), theft (asset or cargo stolen).. Valid values are `accident|near_miss|breakdown|cargo_damage|security_incident|theft`',
    `injuries_reported_flag` BOOLEAN COMMENT 'Indicates whether any injuries (to driver, passengers, or third parties) were reported as a result of the incident. True if injuries reported, False otherwise.',
    `injury_count` STRING COMMENT 'Total number of individuals injured in the incident, including driver, passengers, and third parties.',
    `investigation_assigned_to` STRING COMMENT 'Name or identifier of the safety officer, manager, or team assigned to investigate this incident.',
    `investigation_completed_date` DATE COMMENT 'Date when the incident investigation was completed and findings documented.',
    `location_address` STRING COMMENT 'Human-readable street address or location description where the incident occurred. May include route number, mile marker, or landmark.',
    `location_city` STRING COMMENT 'City or municipality where the incident occurred.',
    `location_country_code` STRING COMMENT 'Three-letter ISO country code where the incident occurred (e.g., USA, CAN, MEX, GBR, DEU).. Valid values are `^[A-Z]{3}$`',
    `location_latitude` DECIMAL(18,2) COMMENT 'GPS (Global Positioning System) latitude coordinate of the incident location in decimal degrees. Range: -90 to +90.',
    `location_longitude` DECIMAL(18,2) COMMENT 'GPS (Global Positioning System) longitude coordinate of the incident location in decimal degrees. Range: -180 to +180.',
    `location_postal_code` STRING COMMENT 'Postal or ZIP code of the incident location.',
    `location_state_province` STRING COMMENT 'State, province, or administrative region where the incident occurred.',
    `notes` STRING COMMENT 'Free-text field for additional notes, observations, witness statements, or supplementary information about the incident.',
    `police_department` STRING COMMENT 'Name of the law enforcement agency or police department that responded to the incident.',
    `police_report_filed_flag` BOOLEAN COMMENT 'Indicates whether a police report was filed for this incident. True if police report filed, False otherwise.',
    `police_report_number` STRING COMMENT 'Official police report or case number assigned by law enforcement agency (if applicable).',
    `reported_datetime` TIMESTAMP COMMENT 'The date and time when the incident was first reported to the fleet management system or control center.',
    `root_cause_category` STRING COMMENT 'High-level classification of the root cause of the incident. Driver_error: human error by driver. Mechanical_failure: asset malfunction. Road_conditions: poor road surface or infrastructure. Weather: adverse weather conditions. Third_party_fault: caused by external party. Cargo_shift: improper cargo loading or securing. Unknown: cause not yet determined. [ENUM-REF-CANDIDATE: driver_error|mechanical_failure|road_conditions|weather|third_party_fault|cargo_shift|unknown — 7 candidates stripped; promote to reference product]',
    `root_cause_description` STRING COMMENT 'Detailed narrative description of the root cause analysis findings and contributing factors to the incident.',
    `severity` STRING COMMENT 'Severity classification of the incident based on impact to personnel, asset, cargo, and operations. Minor: no injuries, minimal damage. Moderate: minor injuries, moderate damage. Major: serious injuries, significant damage. Critical: fatalities or catastrophic damage.. Valid values are `minor|moderate|major|critical`',
    `third_party_contact` STRING COMMENT 'Contact phone number or email address for the third party involved in the incident.',
    `third_party_insurance_provider` STRING COMMENT 'Name of the insurance company covering the third party involved in the incident.',
    `third_party_involved_flag` BOOLEAN COMMENT 'Indicates whether a third party (another vehicle, pedestrian, property owner, or external entity) was involved in the incident. True if third party involved, False otherwise.',
    `third_party_name` STRING COMMENT 'Name of the third party individual or organization involved in the incident (if applicable).',
    `third_party_policy_number` STRING COMMENT 'Insurance policy number of the third party involved in the incident.',
    `updated_timestamp` TIMESTAMP COMMENT 'System timestamp when this incident record was last modified or updated.',
    CONSTRAINT pk_incident PRIMARY KEY(`incident_id`)
) COMMENT 'Transactional record capturing all fleet-related incidents including road accidents, near-misses, cargo damage events, vehicle breakdowns, and security incidents. Tracks incident datetime, location (GPS coordinates and address), asset reference, driver reference, incident type, severity classification, third-party involvement flag, police report number, injuries reported, estimated asset damage cost, cargo damage reference, insurance claim reference, root cause classification, and corrective action status. Feeds the claim domain for cargo insurance processing and supports DOT accident reporting obligations.';

CREATE OR REPLACE TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` (
    `asset_utilisation_id` BIGINT COMMENT 'Unique identifier for the asset utilisation record. Primary key for this operational snapshot.',
    `depot_id` BIGINT COMMENT 'Reference to the depot, terminal, or home location where the asset is based during the reporting period.',
    `driver_profile_id` BIGINT COMMENT 'Reference to the primary driver or operator assigned to the asset during the reporting period. Links to workforce management for driver assignment tracking.',
    `lane_id` BIGINT COMMENT 'Foreign key linking to route.lane. Business justification: Lane-level asset utilization reporting (load factor, revenue per lane, CO2 per lane) is a standard logistics network optimization report. asset_utilisation has plan_id but no direct lane_id; direct FK',
    `plan_id` BIGINT COMMENT 'Reference to the primary route or network lane the asset operated on during the reporting period. Links to route and network domain for route execution analysis.',
    `transport_asset_id` BIGINT COMMENT 'Reference to the transport asset (vehicle, aircraft, vessel, container) for which utilisation is being tracked.',
    `volume_commitment_id` BIGINT COMMENT 'Foreign key linking to contract.contract_volume_commitment. Business justification: Volume commitment tracking: fleet utilisation records (actual TEUs, weight, trips) are the source data for measuring attainment against contracted volume commitments. This link enables automated short',
    `actual_payload_kg` DECIMAL(18,2) COMMENT 'Total actual payload weight carried by the asset during the reporting period, measured in kilograms.',
    `co2_emissions_kg` DECIMAL(18,2) COMMENT 'Total greenhouse gas (GHG) emissions produced by the asset during the reporting period, measured in kilograms of carbon dioxide equivalent (CO2e). Critical for sustainability reporting and compliance with EU Emissions Trading System (EU ETS) and Carbon Offsetting and Reduction Scheme for International Aviation (CORSIA).',
    `compliance_status` STRING COMMENT 'Regulatory compliance status of the asset during the reporting period. Indicates whether the asset met Department of Transportation (DOT), International Civil Aviation Organization (ICAO), International Maritime Organization (IMO), or other applicable regulatory requirements.. Valid values are `compliant|non_compliant|pending_inspection|exempted`',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for revenue and cost amounts (e.g., USD, EUR, GBP).. Valid values are `^[A-Z]{3}$`',
    `distance_travelled_km` DECIMAL(18,2) COMMENT 'Total distance travelled by the asset during the reporting period, measured in kilometers. Captured from GPS (Global Positioning System) telematics or odometer readings.',
    `distance_travelled_miles` DECIMAL(18,2) COMMENT 'Total distance travelled by the asset during the reporting period, measured in miles. Provided for regions using imperial units.',
    `fuel_consumed_liters` DECIMAL(18,2) COMMENT 'Total fuel consumed by the asset during the reporting period, measured in liters.',
    `fuel_efficiency_liters_per_100km` DECIMAL(18,2) COMMENT 'Fuel efficiency metric representing liters consumed per 100 kilometers travelled. Key operational expense (OPEX) and sustainability metric.',
    `fuel_efficiency_mpg` DECIMAL(18,2) COMMENT 'Fuel efficiency metric representing miles per gallon (MPG). Provided for regions using imperial units.',
    `load_factor_percent` DECIMAL(18,2) COMMENT 'Percentage representing the ratio of actual payload to maximum payload capacity. Key performance indicator (KPI) for asset efficiency.',
    `notes` STRING COMMENT 'Free-text field for operational notes, exceptions, or contextual information about the asset utilisation during the reporting period.',
    `number_of_trips` STRING COMMENT 'Total count of completed trips or delivery runs performed by the asset during the reporting period.',
    `on_time_delivery_rate_percent` DECIMAL(18,2) COMMENT 'Percentage of trips completed on time during the reporting period. Key service level agreement (SLA) metric for customer satisfaction.',
    `operating_cost` DECIMAL(18,2) COMMENT 'Total operating expenditure (OPEX) incurred by the asset during the reporting period, including fuel, maintenance, tolls, and driver costs.',
    `operational_status` STRING COMMENT 'Current operational state of the asset during the reporting period. Indicates whether the asset was actively deployed, idle, under maintenance, experiencing breakdown, retired, or reserved.. Valid values are `active|idle|maintenance|breakdown|retired|reserved`',
    `payload_capacity_kg` DECIMAL(18,2) COMMENT 'Maximum payload capacity of the asset in kilograms. Used to calculate load factor.',
    `period_type` STRING COMMENT 'The granularity of the reporting period: daily, weekly, or monthly snapshot.. Valid values are `daily|weekly|monthly`',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when this utilisation record was first created in the system. Audit trail for data lineage and compliance.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this utilisation record was last modified. Audit trail for data lineage and compliance.',
    `reporting_period_date` DATE COMMENT 'The date for which this utilisation snapshot is recorded. Represents the business event date for daily or weekly operational reporting.',
    `revenue_generated` DECIMAL(18,2) COMMENT 'Total revenue generated by the asset during the reporting period. Used for profitability and return on investment (ROI) analysis.',
    `safety_incidents_count` STRING COMMENT 'Total number of safety incidents or accidents involving the asset during the reporting period. Critical for risk management and insurance reporting.',
    `telematics_data_quality_score` DECIMAL(18,2) COMMENT 'Quality score (0-100) representing the completeness and accuracy of GPS (Global Positioning System) telematics and Internet of Things (IoT) sensor data captured during the reporting period. Used to assess data reliability for analytics.',
    `total_available_hours` DECIMAL(18,2) COMMENT 'Total number of hours the asset was available for operational use during the reporting period, excluding scheduled downtime.',
    `total_breakdown_hours` DECIMAL(18,2) COMMENT 'Total number of hours the asset was unavailable due to unplanned breakdowns or failures during the reporting period.',
    `total_downtime_hours` DECIMAL(18,2) COMMENT 'Total number of hours the asset was out of service during the reporting period, combining maintenance and breakdown hours.',
    `total_idle_hours` DECIMAL(18,2) COMMENT 'Total number of hours the asset was idle (available but not in use) during the reporting period.',
    `total_maintenance_hours` DECIMAL(18,2) COMMENT 'Total number of hours the asset was undergoing scheduled or preventive maintenance during the reporting period.',
    `total_operational_hours` DECIMAL(18,2) COMMENT 'Total number of hours the asset was actively in operation (moving, transporting cargo, or performing its primary function) during the reporting period.',
    `utilisation_rate_percent` DECIMAL(18,2) COMMENT 'Overall utilisation rate calculated as the ratio of operational hours to available hours, expressed as a percentage. Primary KPI for fleet management decisions.',
    `volume_capacity_cbm` DECIMAL(18,2) COMMENT 'Maximum volume capacity of the asset in cubic meters (CBM). Used to calculate volume utilisation rate.',
    `volume_utilised_cbm` DECIMAL(18,2) COMMENT 'Total cargo volume utilised during the reporting period, measured in cubic meters (CBM). Relevant for container and warehouse assets.',
    CONSTRAINT pk_asset_utilisation PRIMARY KEY(`asset_utilisation_id`)
) COMMENT 'Periodic operational record (daily/weekly snapshot) capturing fleet utilisation metrics for each transport asset. Tracks asset reference, reporting period (date), total available hours, total operational hours, total idle hours, total downtime hours (maintenance + breakdown), distance travelled (km/miles), load factor (actual payload vs capacity), number of trips completed, fuel efficiency (litres per 100km or MPG), and utilisation rate percentage. This is an operational Silver Layer record — NOT an analytics aggregate — representing the daily operational state of each asset for fleet management decisions.';

CREATE OR REPLACE TABLE `transport_shipping_ecm`.`fleet`.`depot` (
    `depot_id` BIGINT COMMENT 'Unique identifier for the fleet depot. Primary key for the fleet depot entity.',
    `network_node_id` BIGINT COMMENT 'Foreign key linking to route.network_node. Business justification: Depots are physical manifestations of network nodes in the route domain. Linking depot to its corresponding network_node is fundamental for route planning that references depot capacity, operating hou',
    `partner_id` BIGINT COMMENT 'Foreign key linking to network.partner. Business justification: Depots are frequently operated by, co-located with, or contractually tied to network partners (terminal operators, port authorities, intermodal hubs). Partner performance reporting by depot, partner-o',
    `address_line_1` STRING COMMENT 'Primary street address line for the depot location including street number and name.',
    `address_line_2` STRING COMMENT 'Secondary address line for additional location details such as building name, suite number, or floor.',
    `city` STRING COMMENT 'City or municipality where the depot is located.',
    `commissioning_date` DATE COMMENT 'Date when the depot was officially commissioned and began operational service for fleet management activities.',
    `contact_email` STRING COMMENT 'Primary email address for the depot used for operational communications and administrative correspondence.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `contact_phone` STRING COMMENT 'Primary contact phone number for the depot used for operational coordination and emergency communications.',
    `container_capacity_teu` STRING COMMENT 'Maximum container storage capacity expressed in TEU (Twenty-foot Equivalent Units), applicable for container yards and ICDs.',
    `country_code` STRING COMMENT 'Three-letter ISO country code identifying the country where the depot is located.. Valid values are `^[A-Z]{3}$`',
    `covered_area_sqm` DECIMAL(18,2) COMMENT 'Total covered or indoor area of the depot measured in square meters, including maintenance workshops, warehouses, and covered parking structures.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this depot record was first created in the system.',
    `customs_bonded_facility_flag` BOOLEAN COMMENT 'Indicates whether this depot is a customs-bonded facility authorized to store goods under customs supervision without immediate duty payment. Applicable for ICDs and container yards handling international freight.',
    `decommissioning_date` DATE COMMENT 'Date when the depot was or is planned to be decommissioned and removed from active operational service.',
    `depot_code` STRING COMMENT 'Unique business identifier code for the depot used across operational systems and documentation. Typically a short alphanumeric code assigned by the business.. Valid values are `^[A-Z0-9]{3,10}$`',
    `depot_name` STRING COMMENT 'Full business name of the fleet depot, vehicle yard, maintenance workshop, or staging area.',
    `depot_type` STRING COMMENT 'Classification of the depot based on its primary operational function. Vehicle depot for fleet parking and assignment, maintenance workshop for repairs and servicing, fuel station for refueling operations, container yard for container storage, inland container depot (ICD) for customs clearance and container handling, or staging area for temporary asset holding.. Valid values are `vehicle_depot|maintenance_workshop|fuel_station|container_yard|inland_container_depot|staging_area`',
    `electric_charging_stations` STRING COMMENT 'Number of electric vehicle charging stations available at this depot for electric and hybrid fleet assets.',
    `environmental_certification` STRING COMMENT 'Environmental management system certification held by the depot (e.g., ISO 14001, LEED certification) demonstrating compliance with sustainability and environmental protection standards.',
    `ftz_designation` STRING COMMENT 'Free Trade Zone designation or license number if this depot operates within or as an FTZ, allowing duty-deferred or duty-exempt storage and processing of goods.',
    `fuel_types_available` STRING COMMENT 'Comma-separated list of fuel types available at this depot for refueling operations (e.g., diesel, petrol, CNG, LNG, electric charging).',
    `hazmat_certified_flag` BOOLEAN COMMENT 'Indicates whether the depot is certified and equipped to handle, store, and process hazardous materials in compliance with IMDG, IATA Dangerous Goods, and DOT regulations.',
    `last_inspection_date` DATE COMMENT 'Date of the most recent safety, compliance, or operational inspection conducted at this depot by internal auditors or regulatory authorities.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this depot record was most recently updated or modified in the system.',
    `latitude` DECIMAL(18,2) COMMENT 'Geographic latitude coordinate of the depot location in decimal degrees format, used for GPS tracking, route planning, and geospatial analytics.',
    `lease_expiry_date` DATE COMMENT 'Date when the current lease agreement for this depot expires, applicable only for leased facilities. Used for lease renewal planning and CAPEX forecasting.',
    `longitude` DECIMAL(18,2) COMMENT 'Geographic longitude coordinate of the depot location in decimal degrees format, used for GPS tracking, route planning, and geospatial analytics.',
    `maintenance_bays` STRING COMMENT 'Number of maintenance bays or service stations available at this depot for vehicle and equipment servicing and repairs.',
    `managing_business_unit` STRING COMMENT 'Name or code of the business unit, division, or department responsible for managing and operating this depot.',
    `next_inspection_due_date` DATE COMMENT 'Scheduled date for the next mandatory safety, compliance, or operational inspection of the depot facility.',
    `notes` STRING COMMENT 'Free-text field for capturing additional operational notes, special instructions, facility constraints, or other relevant information about the depot that does not fit structured fields.',
    `operates_24_7_flag` BOOLEAN COMMENT 'Indicates whether the depot operates continuously 24 hours a day, 7 days a week. True for round-the-clock operations, False for limited operating hours.',
    `operating_hours_end` STRING COMMENT 'Daily end time of depot operations in HH:MM format (24-hour clock). Used for scheduling asset assignments and maintenance activities.. Valid values are `^([01]?[0-9]|2[0-3]):[0-5][0-9]$`',
    `operating_hours_start` STRING COMMENT 'Daily start time of depot operations in HH:MM format (24-hour clock). Used for scheduling asset assignments and maintenance activities.. Valid values are `^([01]?[0-9]|2[0-3]):[0-5][0-9]$`',
    `operational_status` STRING COMMENT 'Current operational status of the depot indicating whether it is actively serving fleet operations, temporarily unavailable, or permanently closed.. Valid values are `active|inactive|under_construction|temporarily_closed|decommissioned|planned`',
    `ownership_type` STRING COMMENT 'Legal ownership or operational arrangement for the depot facility. Owned indicates company-owned property, leased indicates rental arrangement, operated under contract indicates third-party management, joint venture indicates shared ownership.. Valid values are `owned|leased|operated_under_contract|joint_venture`',
    `postal_code` STRING COMMENT 'Postal or ZIP code for the depot address used for mail delivery and geographic sorting.',
    `region` STRING COMMENT 'Business-defined geographic region or territory to which this depot belongs for organizational reporting and management purposes.',
    `security_level` STRING COMMENT 'Classification of physical security measures and access controls implemented at the depot. Relevant for high-value asset storage and compliance with C-TPAT and AEO security requirements.. Valid values are `standard|enhanced|high_security|restricted_access`',
    `state_province` STRING COMMENT 'State, province, or administrative region where the depot is located.',
    `time_zone` STRING COMMENT 'IANA time zone identifier for the depot location used for scheduling maintenance windows, operating hours, and coordinating cross-regional operations.',
    `total_area_sqm` DECIMAL(18,2) COMMENT 'Total land area of the depot facility measured in square meters, including parking areas, buildings, maintenance bays, and storage yards.',
    `vehicle_capacity` STRING COMMENT 'Maximum number of vehicles (trucks, vans, cars) that can be parked or stored at this depot simultaneously.',
    CONSTRAINT pk_depot PRIMARY KEY(`depot_id`)
) COMMENT 'Master record for all fleet depots, vehicle yards, maintenance workshops, and staging areas that serve as home bases or operational hubs for fleet assets. Captures depot name, depot code, depot type (vehicle depot, maintenance workshop, fuel station, container yard, ICD), address, GPS coordinates, country, region, capacity (number of vehicles/containers), available maintenance bays, fuel types available, operating hours, and managing business unit. Provides the geographic and operational context for asset assignment and maintenance planning.';

CREATE OR REPLACE TABLE `transport_shipping_ecm`.`fleet`.`asset_type` (
    `asset_type_id` BIGINT COMMENT 'Unique identifier for the asset type classification record. Primary key.',
    `asset_category` STRING COMMENT 'High-level classification of the asset type: road vehicle, aircraft, vessel, rail unit, container, Unit Load Device (ULD), or handling equipment. [ENUM-REF-CANDIDATE: road_vehicle|aircraft|vessel|rail_unit|container|uld|handling_equipment — 7 candidates stripped; promote to reference product]',
    `asset_subcategory` STRING COMMENT 'Detailed subcategory within the asset category (e.g., rigid truck, articulated truck, cargo aircraft, container ship, flatcar, dry container, reefer container). [ENUM-REF-CANDIDATE: rigid_truck|articulated_truck|van|cargo_aircraft|passenger_aircraft|container_ship|bulk_carrier|tanker|flatcar|boxcar|dry_container|reefer_container|tank_container|flat_rack|open_top|pallet|igloo_uld|forklift|reach_stacker — promote to reference product]',
    `asset_type_code` STRING COMMENT 'Short alphanumeric code uniquely identifying the asset type (e.g., TRUCK-RIG, CARGO-AC, CONT-20FT). Used as business identifier across systems.. Valid values are `^[A-Z0-9]{3,10}$`',
    `asset_type_description` STRING COMMENT 'Detailed description of the asset type, including technical specifications, typical use cases, and operational characteristics.',
    `asset_type_name` STRING COMMENT 'Full descriptive name of the asset type (e.g., Rigid Truck, Cargo Aircraft, Twenty-Foot Container).',
    `asset_type_status` STRING COMMENT 'Current lifecycle status of this asset type classification: active (in use), inactive (no longer procured but existing assets remain), deprecated (phased out), or under review.. Valid values are `active|inactive|deprecated|under_review`',
    `average_acquisition_cost` DECIMAL(18,2) COMMENT 'Average acquisition cost for this asset type in the base currency, used for budgeting and Capital Expenditure (CAPEX) planning.',
    `certification_interval_months` STRING COMMENT 'Standard interval in months between required certifications for this asset type (e.g., 60 months for CSC container certification).',
    `certification_required_flag` BOOLEAN COMMENT 'Indicates whether this asset type requires periodic regulatory certification (e.g., CSC for containers, airworthiness for aircraft).',
    `cost_currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the average acquisition cost (e.g., USD, EUR, GBP).. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this asset type record was first created in the system.',
    `depreciation_method` STRING COMMENT 'Standard depreciation method applied to this asset type for financial reporting: straight-line, declining balance, units of production, or not applicable.. Valid values are `straight_line|declining_balance|units_of_production|not_applicable`',
    `dot_classification_code` STRING COMMENT 'US DOT standard classification code for road vehicles and rail units, used for regulatory compliance and safety reporting.. Valid values are `^[A-Z0-9]{2,8}$`',
    `effective_date` DATE COMMENT 'Date from which this asset type classification became effective and available for use in asset master data.',
    `emission_standard` STRING COMMENT 'Applicable emission standard for this asset type (e.g., Euro 6, EPA Tier 4, ICAO Annex 16). [ENUM-REF-CANDIDATE: euro_3|euro_4|euro_5|euro_6|epa_tier_3|epa_tier_4|icao_annex_16|imo_tier_ii|imo_tier_iii — promote to reference product]',
    `end_date` DATE COMMENT 'Date on which this asset type classification was retired or deprecated. Null for active asset types.',
    `fuel_type_standard` STRING COMMENT 'Standard fuel or energy type used by this asset type: diesel, gasoline, electric, hybrid, Liquefied Natural Gas (LNG), Compressed Natural Gas (CNG), hydrogen, or jet fuel. [ENUM-REF-CANDIDATE: diesel|gasoline|electric|hybrid|lng|cng|hydrogen|jet_fuel — 8 candidates stripped; promote to reference product]',
    `hazmat_capable_flag` BOOLEAN COMMENT 'Indicates whether this asset type is certified and equipped to transport hazardous materials under IMDG Code or ICAO Technical Instructions.',
    `iata_classification_code` STRING COMMENT 'IATA standard classification code for aircraft and ULD types, used for air freight operations and regulatory compliance.. Valid values are `^[A-Z0-9]{2,6}$`',
    `imo_classification_code` STRING COMMENT 'IMO standard classification code for vessel types, used for maritime operations and regulatory compliance.. Valid values are `^[A-Z0-9]{2,8}$`',
    `iso_container_code` STRING COMMENT 'ISO 6346 standard container type code (e.g., 22G1 for 20ft dry container, 45R1 for 40ft reefer).. Valid values are `^[A-Z0-9]{2,4}$`',
    `last_modified_by` STRING COMMENT 'User ID or system identifier of the person or process that last modified this asset type record.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this asset type record was last modified in the system.',
    `maintenance_interval_days` STRING COMMENT 'Typical scheduled maintenance interval in days for this asset type under normal operating conditions.',
    `maintenance_interval_hours` STRING COMMENT 'Typical scheduled maintenance interval in operating hours for this asset type (primarily for aircraft and vessels).',
    `maintenance_interval_km` STRING COMMENT 'Typical scheduled maintenance interval in kilometers or nautical miles for this asset type.',
    `ownership_model` STRING COMMENT 'Typical ownership model for this asset type: owned (company-owned), leased (operating or finance lease), mixed, or third-party (contracted).. Valid values are `owned|leased|mixed|third_party`',
    `regulatory_framework` STRING COMMENT 'Primary regulatory framework governing this asset type: Department of Transportation (DOT), International Civil Aviation Organization (ICAO), International Maritime Organization (IMO), ISO standards, Federal Maritime Commission (FMC), or mixed.. Valid values are `dot|icao|imo|iso|fmc|mixed`',
    `rfid_tagging_standard_flag` BOOLEAN COMMENT 'Indicates whether this asset type is standardly equipped with RFID tags for automated identification and tracking.',
    `standard_height_m` DECIMAL(18,2) COMMENT 'Standard height dimension in meters for this asset type.',
    `standard_length_m` DECIMAL(18,2) COMMENT 'Standard length dimension in meters for this asset type.',
    `standard_payload_capacity_kg` DECIMAL(18,2) COMMENT 'Standard maximum payload capacity in kilograms for this asset type under normal operating conditions.',
    `standard_temperature_range_max_c` DECIMAL(18,2) COMMENT 'Maximum temperature in Celsius that this asset type can maintain (for temperature-controlled assets).',
    `standard_temperature_range_min_c` DECIMAL(18,2) COMMENT 'Minimum temperature in Celsius that this asset type can maintain (for temperature-controlled assets).',
    `standard_teu_capacity` DECIMAL(18,2) COMMENT 'Standard capacity measured in Twenty-foot Equivalent Units (TEU), primarily used for vessels and rail units.',
    `standard_useful_life_years` STRING COMMENT 'Standard useful life in years for this asset type, used for depreciation and Capital Expenditure (CAPEX) planning.',
    `standard_volume_capacity_cbm` DECIMAL(18,2) COMMENT 'Standard internal volume capacity in cubic meters (CBM) for cargo storage.',
    `standard_width_m` DECIMAL(18,2) COMMENT 'Standard width dimension in meters for this asset type.',
    `telematics_capable_flag` BOOLEAN COMMENT 'Indicates whether this asset type is typically equipped with GPS telematics and IoT sensor capabilities for real-time tracking.',
    `temperature_controlled_flag` BOOLEAN COMMENT 'Indicates whether this asset type has built-in temperature control capabilities (reefer containers, refrigerated trucks).',
    CONSTRAINT pk_asset_type PRIMARY KEY(`asset_type_id`)
) COMMENT 'Reference data defining the classification taxonomy for all fleet asset types used by Transport Shipping. Captures asset type code, asset category (road vehicle, aircraft, vessel, rail unit, container, ULD), sub-category (rigid truck, articulated truck, cargo aircraft, container ship, flatcar), IATA/IMO/DOT classification code, standard payload capacity, standard CBM capacity, fuel type standard, applicable regulatory framework (DOT, ICAO, IMO), and typical maintenance interval. Provides standardized classification used across transport_asset, maintenance_schedule, and asset_acquisition.';

CREATE OR REPLACE TABLE `transport_shipping_ecm`.`fleet`.`trip` (
    `trip_id` BIGINT COMMENT 'Primary key for trip',
    `carrier_id` BIGINT COMMENT 'Foreign key linking to network.carrier. Business justification: Subcontracted and interline trips are executed under a specific carriers operating authority. Carrier performance tracking, freight billing reconciliation, and regulatory compliance (e.g., FMCSA) req',
    `customer_account_id` BIGINT COMMENT 'Identifier of the shipper or customer associated with the trip.',
    `facility_id` BIGINT COMMENT 'Foreign key linking to warehouse.facility. Business justification: Trip destination planning for warehouse deliveries requires linking trips to the destination warehouse facility for dock scheduling, inbound resource planning, and facility-level on-time delivery KPI ',
    `driver_profile_id` BIGINT COMMENT 'Identifier of the driver assigned to the trip.',
    `invoice_id` BIGINT COMMENT 'Foreign key linking to billing.invoice. Business justification: Completed trips generate customer invoices for freight/delivery charges. Logistics billing teams reconcile trip records against invoices for revenue recognition and dispute resolution. A logistics dom',
    `lane_id` BIGINT COMMENT 'Foreign key linking to route.lane. Business justification: Trip-level lane assignment drives SLA compliance reporting, carrier cost allocation, and lane performance benchmarking. Logistics planners track on-time delivery rates by lane; direct FK avoids traver',
    `network_node_id` BIGINT COMMENT 'Foreign key linking to route.network_node. Business justification: trip.origin_location_code is a denormalized plain-text field. Normalizing to network_node enables node-level throughput reporting, dwell-time analytics, and capacity planning — core logistics network ',
    `plan_id` BIGINT COMMENT 'Identifier of the planned route for the trip.',
    `rate_card_id` BIGINT COMMENT 'Foreign key linking to pricing.rate_card. Business justification: Trips are operational executions of freight movements; the rate card determines revenue and cost basis for each trip. Finance and operations teams reconcile trip revenue against the applicable rate ca',
    `rate_schedule_id` BIGINT COMMENT 'Foreign key linking to contract.rate_schedule. Business justification: Trip rating and freight charge calculation: every trip is priced against a contracted rate schedule to determine freight charges. This link enables revenue recognition, billing accuracy validation, an',
    `return_trip_id` BIGINT COMMENT 'Self-referencing FK on trip (return_trip_id)',
    `service_preference_id` BIGINT COMMENT 'Foreign key linking to customer.service_preference. Business justification: Customer service preferences (temperature control, hazmat handling, notification channel, label format, incoterms) must be applied during trip execution. Fleet dispatchers use service_preference to co',
    `transport_asset_id` BIGINT COMMENT 'Identifier of the vehicle (truck, van, etc.) used for the trip.',
    `actual_end_timestamp` TIMESTAMP COMMENT 'Real end time when the vehicle arrived at the destination.',
    `actual_start_timestamp` TIMESTAMP COMMENT 'Real start time when the vehicle departed.',
    `average_speed_kmh` DECIMAL(18,2) COMMENT 'Average speed of the vehicle over the trip.',
    `cargo_type` STRING COMMENT 'Classification of cargo being moved.',
    `cargo_weight_kg` DECIMAL(18,2) COMMENT 'Weight of the cargo transported on the trip.',
    `comments` STRING COMMENT 'Free‑form notes or remarks about the trip.',
    `currency_code` STRING COMMENT 'Three‑letter ISO 4217 currency code for monetary values.',
    `destination_location_code` STRING COMMENT 'Three‑letter code representing the trip destination.',
    `distance_km` DECIMAL(18,2) COMMENT 'Total planned or actual distance traveled in kilometers.',
    `emissions_kg_co2` DECIMAL(18,2) COMMENT 'Estimated carbon dioxide emissions for the trip.',
    `event_timestamp` TIMESTAMP COMMENT 'Timestamp of the primary trip event (e.g., actual departure time).',
    `fuel_consumed_liters` DECIMAL(18,2) COMMENT 'Quantity of fuel used during the trip.',
    `gross_amount` DECIMAL(18,2) COMMENT 'Total billed amount before taxes and adjustments.',
    `is_expedited` BOOLEAN COMMENT 'Indicates whether the trip was expedited (true) or standard (false).',
    `net_amount` DECIMAL(18,2) COMMENT 'Final amount after taxes and adjustments.',
    `number_of_stops` STRING COMMENT 'Count of intermediate stops made during the trip.',
    `priority_level` STRING COMMENT 'Business priority assigned to the trip.',
    `reason_code` STRING COMMENT 'Code indicating the primary reason for the trip.',
    `record_audit_created` TIMESTAMP COMMENT 'Timestamp when the trip record was first created in the system.',
    `record_audit_updated` TIMESTAMP COMMENT 'Timestamp of the most recent update to the trip record.',
    `scheduled_end_timestamp` TIMESTAMP COMMENT 'Planned end time of the trip as per the schedule.',
    `scheduled_start_timestamp` TIMESTAMP COMMENT 'Planned start time of the trip as per the schedule.',
    `tax_amount` DECIMAL(18,2) COMMENT 'Tax component applied to the trip billing.',
    `trip_number` STRING COMMENT 'Business-assigned alphanumeric identifier for the trip, used in operational systems and customer communications.',
    `trip_status` STRING COMMENT 'Current lifecycle status of the trip.',
    CONSTRAINT pk_trip PRIMARY KEY(`trip_id`)
) COMMENT 'Master reference table for trip. Referenced by trip_id.';

-- ========= FOREIGN KEYS =========
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ADD CONSTRAINT `fk_fleet_transport_asset_asset_type_id` FOREIGN KEY (`asset_type_id`) REFERENCES `transport_shipping_ecm`.`fleet`.`asset_type`(`asset_type_id`);
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ADD CONSTRAINT `fk_fleet_transport_asset_depot_id` FOREIGN KEY (`depot_id`) REFERENCES `transport_shipping_ecm`.`fleet`.`depot`(`depot_id`);
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ADD CONSTRAINT `fk_fleet_container_unit_asset_type_id` FOREIGN KEY (`asset_type_id`) REFERENCES `transport_shipping_ecm`.`fleet`.`asset_type`(`asset_type_id`);
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ADD CONSTRAINT `fk_fleet_container_unit_depot_id` FOREIGN KEY (`depot_id`) REFERENCES `transport_shipping_ecm`.`fleet`.`depot`(`depot_id`);
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ADD CONSTRAINT `fk_fleet_asset_assignment_depot_id` FOREIGN KEY (`depot_id`) REFERENCES `transport_shipping_ecm`.`fleet`.`depot`(`depot_id`);
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ADD CONSTRAINT `fk_fleet_asset_assignment_driver_profile_id` FOREIGN KEY (`driver_profile_id`) REFERENCES `transport_shipping_ecm`.`fleet`.`driver_profile`(`driver_profile_id`);
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ADD CONSTRAINT `fk_fleet_asset_assignment_origin_depot_id` FOREIGN KEY (`origin_depot_id`) REFERENCES `transport_shipping_ecm`.`fleet`.`depot`(`depot_id`);
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ADD CONSTRAINT `fk_fleet_asset_assignment_transport_asset_id` FOREIGN KEY (`transport_asset_id`) REFERENCES `transport_shipping_ecm`.`fleet`.`transport_asset`(`transport_asset_id`);
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ADD CONSTRAINT `fk_fleet_asset_assignment_trip_id` FOREIGN KEY (`trip_id`) REFERENCES `transport_shipping_ecm`.`fleet`.`trip`(`trip_id`);
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ADD CONSTRAINT `fk_fleet_telematics_event_driver_profile_id` FOREIGN KEY (`driver_profile_id`) REFERENCES `transport_shipping_ecm`.`fleet`.`driver_profile`(`driver_profile_id`);
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ADD CONSTRAINT `fk_fleet_telematics_event_transport_asset_id` FOREIGN KEY (`transport_asset_id`) REFERENCES `transport_shipping_ecm`.`fleet`.`transport_asset`(`transport_asset_id`);
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ADD CONSTRAINT `fk_fleet_telematics_event_trip_id` FOREIGN KEY (`trip_id`) REFERENCES `transport_shipping_ecm`.`fleet`.`trip`(`trip_id`);
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ADD CONSTRAINT `fk_fleet_driver_profile_depot_id` FOREIGN KEY (`depot_id`) REFERENCES `transport_shipping_ecm`.`fleet`.`depot`(`depot_id`);
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ADD CONSTRAINT `fk_fleet_driver_assignment_asset_assignment_id` FOREIGN KEY (`asset_assignment_id`) REFERENCES `transport_shipping_ecm`.`fleet`.`asset_assignment`(`asset_assignment_id`);
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ADD CONSTRAINT `fk_fleet_driver_assignment_depot_id` FOREIGN KEY (`depot_id`) REFERENCES `transport_shipping_ecm`.`fleet`.`depot`(`depot_id`);
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ADD CONSTRAINT `fk_fleet_driver_assignment_transport_asset_id` FOREIGN KEY (`transport_asset_id`) REFERENCES `transport_shipping_ecm`.`fleet`.`transport_asset`(`transport_asset_id`);
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ADD CONSTRAINT `fk_fleet_driver_assignment_primary_fleet_depot_id` FOREIGN KEY (`primary_fleet_depot_id`) REFERENCES `transport_shipping_ecm`.`fleet`.`depot`(`depot_id`);
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ADD CONSTRAINT `fk_fleet_driver_assignment_driver_profile_id` FOREIGN KEY (`driver_profile_id`) REFERENCES `transport_shipping_ecm`.`fleet`.`driver_profile`(`driver_profile_id`);
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ADD CONSTRAINT `fk_fleet_driver_assignment_trip_id` FOREIGN KEY (`trip_id`) REFERENCES `transport_shipping_ecm`.`fleet`.`trip`(`trip_id`);
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ADD CONSTRAINT `fk_fleet_maintenance_order_depot_id` FOREIGN KEY (`depot_id`) REFERENCES `transport_shipping_ecm`.`fleet`.`depot`(`depot_id`);
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ADD CONSTRAINT `fk_fleet_maintenance_order_maintenance_schedule_id` FOREIGN KEY (`maintenance_schedule_id`) REFERENCES `transport_shipping_ecm`.`fleet`.`maintenance_schedule`(`maintenance_schedule_id`);
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ADD CONSTRAINT `fk_fleet_maintenance_order_transport_asset_id` FOREIGN KEY (`transport_asset_id`) REFERENCES `transport_shipping_ecm`.`fleet`.`transport_asset`(`transport_asset_id`);
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ADD CONSTRAINT `fk_fleet_maintenance_schedule_asset_type_id` FOREIGN KEY (`asset_type_id`) REFERENCES `transport_shipping_ecm`.`fleet`.`asset_type`(`asset_type_id`);
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ADD CONSTRAINT `fk_fleet_maintenance_schedule_transport_asset_id` FOREIGN KEY (`transport_asset_id`) REFERENCES `transport_shipping_ecm`.`fleet`.`transport_asset`(`transport_asset_id`);
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ADD CONSTRAINT `fk_fleet_fuel_transaction_asset_assignment_id` FOREIGN KEY (`asset_assignment_id`) REFERENCES `transport_shipping_ecm`.`fleet`.`asset_assignment`(`asset_assignment_id`);
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ADD CONSTRAINT `fk_fleet_fuel_transaction_depot_id` FOREIGN KEY (`depot_id`) REFERENCES `transport_shipping_ecm`.`fleet`.`depot`(`depot_id`);
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ADD CONSTRAINT `fk_fleet_fuel_transaction_driver_profile_id` FOREIGN KEY (`driver_profile_id`) REFERENCES `transport_shipping_ecm`.`fleet`.`driver_profile`(`driver_profile_id`);
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ADD CONSTRAINT `fk_fleet_fuel_transaction_transport_asset_id` FOREIGN KEY (`transport_asset_id`) REFERENCES `transport_shipping_ecm`.`fleet`.`transport_asset`(`transport_asset_id`);
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ADD CONSTRAINT `fk_fleet_fuel_transaction_trip_id` FOREIGN KEY (`trip_id`) REFERENCES `transport_shipping_ecm`.`fleet`.`trip`(`trip_id`);
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ADD CONSTRAINT `fk_fleet_asset_inspection_depot_id` FOREIGN KEY (`depot_id`) REFERENCES `transport_shipping_ecm`.`fleet`.`depot`(`depot_id`);
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ADD CONSTRAINT `fk_fleet_asset_inspection_transport_asset_id` FOREIGN KEY (`transport_asset_id`) REFERENCES `transport_shipping_ecm`.`fleet`.`transport_asset`(`transport_asset_id`);
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_licence` ADD CONSTRAINT `fk_fleet_asset_licence_asset_type_id` FOREIGN KEY (`asset_type_id`) REFERENCES `transport_shipping_ecm`.`fleet`.`asset_type`(`asset_type_id`);
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_licence` ADD CONSTRAINT `fk_fleet_asset_licence_transport_asset_id` FOREIGN KEY (`transport_asset_id`) REFERENCES `transport_shipping_ecm`.`fleet`.`transport_asset`(`transport_asset_id`);
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ADD CONSTRAINT `fk_fleet_incident_asset_assignment_id` FOREIGN KEY (`asset_assignment_id`) REFERENCES `transport_shipping_ecm`.`fleet`.`asset_assignment`(`asset_assignment_id`);
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ADD CONSTRAINT `fk_fleet_incident_driver_profile_id` FOREIGN KEY (`driver_profile_id`) REFERENCES `transport_shipping_ecm`.`fleet`.`driver_profile`(`driver_profile_id`);
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ADD CONSTRAINT `fk_fleet_incident_transport_asset_id` FOREIGN KEY (`transport_asset_id`) REFERENCES `transport_shipping_ecm`.`fleet`.`transport_asset`(`transport_asset_id`);
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ADD CONSTRAINT `fk_fleet_incident_trip_id` FOREIGN KEY (`trip_id`) REFERENCES `transport_shipping_ecm`.`fleet`.`trip`(`trip_id`);
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ADD CONSTRAINT `fk_fleet_asset_utilisation_depot_id` FOREIGN KEY (`depot_id`) REFERENCES `transport_shipping_ecm`.`fleet`.`depot`(`depot_id`);
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ADD CONSTRAINT `fk_fleet_asset_utilisation_driver_profile_id` FOREIGN KEY (`driver_profile_id`) REFERENCES `transport_shipping_ecm`.`fleet`.`driver_profile`(`driver_profile_id`);
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ADD CONSTRAINT `fk_fleet_asset_utilisation_transport_asset_id` FOREIGN KEY (`transport_asset_id`) REFERENCES `transport_shipping_ecm`.`fleet`.`transport_asset`(`transport_asset_id`);
ALTER TABLE `transport_shipping_ecm`.`fleet`.`trip` ADD CONSTRAINT `fk_fleet_trip_driver_profile_id` FOREIGN KEY (`driver_profile_id`) REFERENCES `transport_shipping_ecm`.`fleet`.`driver_profile`(`driver_profile_id`);
ALTER TABLE `transport_shipping_ecm`.`fleet`.`trip` ADD CONSTRAINT `fk_fleet_trip_return_trip_id` FOREIGN KEY (`return_trip_id`) REFERENCES `transport_shipping_ecm`.`fleet`.`trip`(`trip_id`);
ALTER TABLE `transport_shipping_ecm`.`fleet`.`trip` ADD CONSTRAINT `fk_fleet_trip_transport_asset_id` FOREIGN KEY (`transport_asset_id`) REFERENCES `transport_shipping_ecm`.`fleet`.`transport_asset`(`transport_asset_id`);

-- ========= TAGS =========
ALTER SCHEMA `transport_shipping_ecm`.`fleet` SET TAGS ('dbx_division' = 'operations');
ALTER SCHEMA `transport_shipping_ecm`.`fleet` SET TAGS ('dbx_domain' = 'fleet');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` SET TAGS ('dbx_subdomain' = 'asset_management');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `transport_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Transport Asset ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `asset_type_id` SET TAGS ('dbx_business_glossary_term' = 'Asset Type Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `depot_id` SET TAGS ('dbx_business_glossary_term' = 'Assigned Depot ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `license_permit_id` SET TAGS ('dbx_business_glossary_term' = 'License Permit Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `supplier_id` SET TAGS ('dbx_business_glossary_term' = 'Manufacturer Supplier Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `purchase_order_id` SET TAGS ('dbx_business_glossary_term' = 'Purchase Order Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `acquisition_cost` SET TAGS ('dbx_business_glossary_term' = 'Acquisition Cost');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `acquisition_cost` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `acquisition_date` SET TAGS ('dbx_business_glossary_term' = 'Acquisition Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `asset_name` SET TAGS ('dbx_business_glossary_term' = 'Asset Name');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `asset_number` SET TAGS ('dbx_business_glossary_term' = 'Asset Number');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `asset_number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{6,20}$');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `co2_emission_rate_g_per_km` SET TAGS ('dbx_business_glossary_term' = 'Carbon Dioxide Equivalent (CO2e) Emission Rate (Grams per Kilometer)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `current_location` SET TAGS ('dbx_business_glossary_term' = 'Current Location');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `decommission_date` SET TAGS ('dbx_business_glossary_term' = 'Decommission Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `disposal_date` SET TAGS ('dbx_business_glossary_term' = 'Disposal Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `disposal_value` SET TAGS ('dbx_business_glossary_term' = 'Disposal Value');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `disposal_value` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `emission_standard` SET TAGS ('dbx_business_glossary_term' = 'Emission Standard');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `engine_power_kw` SET TAGS ('dbx_business_glossary_term' = 'Engine Power (Kilowatts)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `engine_type` SET TAGS ('dbx_business_glossary_term' = 'Engine Type');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `fuel_capacity_liters` SET TAGS ('dbx_business_glossary_term' = 'Fuel Capacity (Liters)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `fuel_type` SET TAGS ('dbx_business_glossary_term' = 'Fuel Type');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `height_meters` SET TAGS ('dbx_business_glossary_term' = 'Height (Meters)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `home_location` SET TAGS ('dbx_business_glossary_term' = 'Home Location');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `insurance_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Insurance Expiry Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `insurance_policy_number` SET TAGS ('dbx_business_glossary_term' = 'Insurance Policy Number');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `insurance_policy_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `last_maintenance_date` SET TAGS ('dbx_business_glossary_term' = 'Last Maintenance Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `length_meters` SET TAGS ('dbx_business_glossary_term' = 'Length (Meters)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `model` SET TAGS ('dbx_business_glossary_term' = 'Model');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `next_maintenance_due_date` SET TAGS ('dbx_business_glossary_term' = 'Next Maintenance Due Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `odometer_reading` SET TAGS ('dbx_business_glossary_term' = 'Odometer Reading');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `operational_status` SET TAGS ('dbx_business_glossary_term' = 'Operational Status');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `operational_status` SET TAGS ('dbx_value_regex' = 'active|in_maintenance|idle|decommissioned|reserved|out_of_service');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `ownership_type` SET TAGS ('dbx_business_glossary_term' = 'Ownership Type');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `ownership_type` SET TAGS ('dbx_value_regex' = 'owned|leased|chartered|rented');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `payload_capacity_kg` SET TAGS ('dbx_business_glossary_term' = 'Payload Capacity (Kilograms)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `registration_country` SET TAGS ('dbx_business_glossary_term' = 'Registration Country');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `registration_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `registration_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Registration Expiry Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `registration_number` SET TAGS ('dbx_business_glossary_term' = 'Registration Number');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `rfid_tag` SET TAGS ('dbx_business_glossary_term' = 'Radio Frequency Identification (RFID) Tag');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `rfid_tag` SET TAGS ('dbx_value_regex' = '^[A-F0-9]{24}$');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `telematics_device_code` SET TAGS ('dbx_business_glossary_term' = 'Telematics Device ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `telematics_device_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{8,20}$');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `telematics_device_code` SET TAGS ('dbx_internal' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `telematics_device_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `teu_capacity` SET TAGS ('dbx_business_glossary_term' = 'Twenty-foot Equivalent Unit (TEU) Capacity');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `utilization_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Utilization Rate (Percent)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `vin_serial_number` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Identification Number (VIN) / Serial Number');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `vin_serial_number` SET TAGS ('dbx_value_regex' = '^[A-HJ-NPR-Z0-9]{17}$');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `vin_serial_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `volume_capacity_cbm` SET TAGS ('dbx_business_glossary_term' = 'Volume Capacity (Cubic Meters / CBM)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `width_meters` SET TAGS ('dbx_business_glossary_term' = 'Width (Meters)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`transport_asset` ALTER COLUMN `year_of_manufacture` SET TAGS ('dbx_business_glossary_term' = 'Year of Manufacture');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` SET TAGS ('dbx_subdomain' = 'asset_management');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `container_unit_id` SET TAGS ('dbx_business_glossary_term' = 'Container Unit ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Agreement Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `asset_type_id` SET TAGS ('dbx_business_glossary_term' = 'Asset Type Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `carrier_id` SET TAGS ('dbx_business_glossary_term' = 'Carrier Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `depot_id` SET TAGS ('dbx_business_glossary_term' = 'Current Depot Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `network_node_id` SET TAGS ('dbx_business_glossary_term' = 'Current Location Network Node Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `lane_id` SET TAGS ('dbx_business_glossary_term' = 'Lane Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `supplier_id` SET TAGS ('dbx_business_glossary_term' = 'Manufacturer Supplier Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `purchase_order_id` SET TAGS ('dbx_business_glossary_term' = 'Purchase Order Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `acquisition_cost` SET TAGS ('dbx_business_glossary_term' = 'Acquisition Cost');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `acquisition_cost` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `acquisition_date` SET TAGS ('dbx_business_glossary_term' = 'Acquisition Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `availability_status` SET TAGS ('dbx_business_glossary_term' = 'Availability Status');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `availability_status` SET TAGS ('dbx_value_regex' = 'available|in_use|in_transit|under_repair|retired|lost');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `condition_grade` SET TAGS ('dbx_business_glossary_term' = 'Condition Grade');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `condition_grade` SET TAGS ('dbx_value_regex' = 'A|B|C|D|scrap');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `container_number` SET TAGS ('dbx_business_glossary_term' = 'Container Number (ISO 6346)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `container_number` SET TAGS ('dbx_value_regex' = '^[A-Z]{4}[0-9]{7}$');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `csc_certification_date` SET TAGS ('dbx_business_glossary_term' = 'Container Safety Convention (CSC) Certification Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `csc_certification_number` SET TAGS ('dbx_business_glossary_term' = 'Container Safety Convention (CSC) Certification Number');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `csc_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Container Safety Convention (CSC) Expiry Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `current_book_value` SET TAGS ('dbx_business_glossary_term' = 'Current Book Value');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `current_book_value` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `current_location_country` SET TAGS ('dbx_business_glossary_term' = 'Current Location Country');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `current_location_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `current_location_type` SET TAGS ('dbx_business_glossary_term' = 'Current Location Type');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `current_location_type` SET TAGS ('dbx_value_regex' = 'depot|port|vessel|rail_yard|customer_site|in_transit');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `disposal_date` SET TAGS ('dbx_business_glossary_term' = 'Disposal Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `food_grade_certified` SET TAGS ('dbx_business_glossary_term' = 'Food Grade Certified');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `gps_enabled` SET TAGS ('dbx_business_glossary_term' = 'Global Positioning System (GPS) Enabled');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `hazmat_certified` SET TAGS ('dbx_business_glossary_term' = 'Hazardous Materials (HAZMAT) Certified');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `height_ft` SET TAGS ('dbx_business_glossary_term' = 'Container Height (Feet)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `internal_volume_cbm` SET TAGS ('dbx_business_glossary_term' = 'Internal Volume (Cubic Meters - CBM)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `last_inspection_date` SET TAGS ('dbx_business_glossary_term' = 'Last Inspection Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `last_maintenance_date` SET TAGS ('dbx_business_glossary_term' = 'Last Maintenance Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `last_movement_date` SET TAGS ('dbx_business_glossary_term' = 'Last Movement Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `length_ft` SET TAGS ('dbx_business_glossary_term' = 'Container Length (Feet)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `manufacture_date` SET TAGS ('dbx_business_glossary_term' = 'Manufacture Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `max_gross_weight_kg` SET TAGS ('dbx_business_glossary_term' = 'Maximum Gross Weight (Kilograms)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `max_payload_kg` SET TAGS ('dbx_business_glossary_term' = 'Maximum Payload Capacity (Kilograms)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `next_inspection_due_date` SET TAGS ('dbx_business_glossary_term' = 'Next Inspection Due Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `owner_code` SET TAGS ('dbx_business_glossary_term' = 'Owner Code (ISO 6346)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `owner_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{4}$');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `ownership_type` SET TAGS ('dbx_business_glossary_term' = 'Ownership Type');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `ownership_type` SET TAGS ('dbx_value_regex' = 'owned|leased|customer_owned|pool');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `reefer_capable` SET TAGS ('dbx_business_glossary_term' = 'Refrigerated (Reefer) Capable');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `retirement_date` SET TAGS ('dbx_business_glossary_term' = 'Retirement Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `rfid_tag_code` SET TAGS ('dbx_business_glossary_term' = 'Radio Frequency Identification (RFID) Tag ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `tare_weight_kg` SET TAGS ('dbx_business_glossary_term' = 'Tare Weight (Kilograms)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `temperature_range_max_c` SET TAGS ('dbx_business_glossary_term' = 'Maximum Temperature Range (Celsius)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `temperature_range_min_c` SET TAGS ('dbx_business_glossary_term' = 'Minimum Temperature Range (Celsius)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `teu_size` SET TAGS ('dbx_business_glossary_term' = 'Twenty-foot Equivalent Unit (TEU) Size');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `total_distance_km` SET TAGS ('dbx_business_glossary_term' = 'Total Distance Traveled (Kilometers)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `total_trips_completed` SET TAGS ('dbx_business_glossary_term' = 'Total Trips Completed');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`container_unit` ALTER COLUMN `width_ft` SET TAGS ('dbx_business_glossary_term' = 'Container Width (Feet)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` SET TAGS ('dbx_subdomain' = 'asset_management');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `asset_assignment_id` SET TAGS ('dbx_business_glossary_term' = 'Asset Assignment Identifier (ID)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Agreement Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `carrier_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Carrier Agreement Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `carrier_id` SET TAGS ('dbx_business_glossary_term' = 'Carrier Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `carrier_payable_id` SET TAGS ('dbx_business_glossary_term' = 'Carrier Payable Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `carrier_service_id` SET TAGS ('dbx_business_glossary_term' = 'Carrier Service Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `customer_account_id` SET TAGS ('dbx_business_glossary_term' = 'Customer Account Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `declaration_id` SET TAGS ('dbx_business_glossary_term' = 'Customs Declaration Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `depot_id` SET TAGS ('dbx_business_glossary_term' = 'Destination Depot Identifier (ID)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `dispute_id` SET TAGS ('dbx_business_glossary_term' = 'Billing Dispute Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `driver_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Driver Identifier (ID)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `freight_audit_id` SET TAGS ('dbx_business_glossary_term' = 'Freight Audit Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `freight_order_id` SET TAGS ('dbx_business_glossary_term' = 'Freight Order Identifier (ID)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `lane_id` SET TAGS ('dbx_business_glossary_term' = 'Lane Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `origin_depot_id` SET TAGS ('dbx_business_glossary_term' = 'Origin Depot Identifier (ID)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `facility_id` SET TAGS ('dbx_business_glossary_term' = 'Pickup Facility Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `plan_id` SET TAGS ('dbx_business_glossary_term' = 'Route Identifier (ID)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `rate_card_id` SET TAGS ('dbx_business_glossary_term' = 'Rate Card Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `rate_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Rate Schedule Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `service_scope_id` SET TAGS ('dbx_business_glossary_term' = 'Service Scope Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `shipment_leg_id` SET TAGS ('dbx_business_glossary_term' = 'Shipment Leg Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `shipper_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Shipper Profile Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `sla_commitment_id` SET TAGS ('dbx_business_glossary_term' = 'Contract Sla Commitment Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `sla_entitlement_id` SET TAGS ('dbx_business_glossary_term' = 'Sla Entitlement Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `transport_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Asset Identifier (ID)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `trip_id` SET TAGS ('dbx_business_glossary_term' = 'Trip Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `actual_end_datetime` SET TAGS ('dbx_business_glossary_term' = 'Actual End Date and Time');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `actual_start_datetime` SET TAGS ('dbx_business_glossary_term' = 'Actual Start Date and Time');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `assignment_cost_amount` SET TAGS ('dbx_business_glossary_term' = 'Assignment Cost Amount');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `assignment_cost_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `assignment_duration_hours` SET TAGS ('dbx_business_glossary_term' = 'Assignment Duration in Hours');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `assignment_number` SET TAGS ('dbx_business_glossary_term' = 'Assignment Number');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `assignment_status` SET TAGS ('dbx_business_glossary_term' = 'Assignment Status');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `assignment_type` SET TAGS ('dbx_business_glossary_term' = 'Assignment Type');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `cargo_volume_cbm` SET TAGS ('dbx_business_glossary_term' = 'Cargo Volume in Cubic Meters (CBM)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `cargo_weight_kg` SET TAGS ('dbx_business_glossary_term' = 'Cargo Weight in Kilograms (kg)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `co2_emissions_kg` SET TAGS ('dbx_business_glossary_term' = 'Carbon Dioxide Equivalent (CO2e) Emissions in Kilograms (kg)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `compliance_check_status` SET TAGS ('dbx_business_glossary_term' = 'Compliance Check Status');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `compliance_check_status` SET TAGS ('dbx_value_regex' = 'passed|failed|pending|not_required|waived');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `cross_border_indicator` SET TAGS ('dbx_business_glossary_term' = 'Cross-Border Indicator');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `delay_duration_minutes` SET TAGS ('dbx_business_glossary_term' = 'Delay Duration in Minutes');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `delay_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Delay Reason Code');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `distance_km` SET TAGS ('dbx_business_glossary_term' = 'Distance in Kilometers (km)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `fuel_consumed_liters` SET TAGS ('dbx_business_glossary_term' = 'Fuel Consumed in Liters');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `gps_tracking_enabled` SET TAGS ('dbx_business_glossary_term' = 'Global Positioning System (GPS) Tracking Enabled');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `hazmat_indicator` SET TAGS ('dbx_business_glossary_term' = 'Hazardous Materials (HAZMAT) Indicator');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `incident_reported_indicator` SET TAGS ('dbx_business_glossary_term' = 'Incident Reported Indicator');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `last_inspection_date` SET TAGS ('dbx_business_glossary_term' = 'Last Inspection Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `load_utilization_percentage` SET TAGS ('dbx_business_glossary_term' = 'Load Utilization Percentage');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Modified Timestamp');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Assignment Notes');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `planned_end_datetime` SET TAGS ('dbx_business_glossary_term' = 'Planned End Date and Time');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `planned_start_datetime` SET TAGS ('dbx_business_glossary_term' = 'Planned Start Date and Time');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `priority_level` SET TAGS ('dbx_business_glossary_term' = 'Priority Level');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `priority_level` SET TAGS ('dbx_value_regex' = 'critical|high|normal|low');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `rfid_tag_code` SET TAGS ('dbx_business_glossary_term' = 'Radio Frequency Identification (RFID) Tag Identifier (ID)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `seal_number` SET TAGS ('dbx_business_glossary_term' = 'Seal Number');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `service_level` SET TAGS ('dbx_business_glossary_term' = 'Service Level');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `service_level` SET TAGS ('dbx_value_regex' = 'express|standard|economy|charter|dedicated');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'SAP_TM|ORACLE_TMS|MANHATTAN_WMS|FOURKITES|MANUAL|OTHER');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_assignment` ALTER COLUMN `temperature_controlled_indicator` SET TAGS ('dbx_business_glossary_term' = 'Temperature Controlled Indicator');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` SET TAGS ('dbx_subdomain' = 'operations_tracking');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `telematics_event_id` SET TAGS ('dbx_business_glossary_term' = 'Telematics Event ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `carrier_id` SET TAGS ('dbx_business_glossary_term' = 'Carrier Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `consignment_id` SET TAGS ('dbx_business_glossary_term' = 'Shipment ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `driver_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Driver ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `facility_id` SET TAGS ('dbx_business_glossary_term' = 'Facility Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `freight_order_id` SET TAGS ('dbx_business_glossary_term' = 'Freight Order Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `lane_id` SET TAGS ('dbx_business_glossary_term' = 'Lane Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `network_node_id` SET TAGS ('dbx_business_glossary_term' = 'Network Node Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `plan_id` SET TAGS ('dbx_business_glossary_term' = 'Route ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `transport_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Fleet Asset ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `trip_id` SET TAGS ('dbx_business_glossary_term' = 'Trip Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `altitude_m` SET TAGS ('dbx_business_glossary_term' = 'Altitude (Meters)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `battery_voltage` SET TAGS ('dbx_business_glossary_term' = 'Battery Voltage');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `data_quality_flag` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Flag');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `data_quality_flag` SET TAGS ('dbx_value_regex' = 'valid|suspect|invalid|interpolated');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `device_code` SET TAGS ('dbx_business_glossary_term' = 'Telematics Device ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `device_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `device_code` SET TAGS ('dbx_pii_device' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `diagnostic_trouble_code` SET TAGS ('dbx_business_glossary_term' = 'Diagnostic Trouble Code (DTC)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `engine_hours` SET TAGS ('dbx_business_glossary_term' = 'Engine Hours');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `engine_rpm` SET TAGS ('dbx_business_glossary_term' = 'Engine Revolutions Per Minute (RPM)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `event_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Event Timestamp');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `event_type` SET TAGS ('dbx_business_glossary_term' = 'Event Type');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `fuel_level_percent` SET TAGS ('dbx_business_glossary_term' = 'Fuel Level (Percent)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `geofence_event_type` SET TAGS ('dbx_business_glossary_term' = 'Geofence Event Type');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `geofence_event_type` SET TAGS ('dbx_value_regex' = 'entry|exit');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `gps_accuracy_m` SET TAGS ('dbx_business_glossary_term' = 'GPS Accuracy (Meters)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `gps_satellite_count` SET TAGS ('dbx_business_glossary_term' = 'GPS Satellite Count');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `harsh_acceleration_flag` SET TAGS ('dbx_business_glossary_term' = 'Harsh Acceleration Flag');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `harsh_braking_flag` SET TAGS ('dbx_business_glossary_term' = 'Harsh Braking Flag');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `heading_degrees` SET TAGS ('dbx_business_glossary_term' = 'Heading (Degrees)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `ignition_state` SET TAGS ('dbx_business_glossary_term' = 'Ignition State');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `ignition_state` SET TAGS ('dbx_value_regex' = 'on|off|accessory');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `ingestion_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Ingestion Timestamp');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `latitude` SET TAGS ('dbx_business_glossary_term' = 'GPS Latitude');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `latitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `latitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `longitude` SET TAGS ('dbx_business_glossary_term' = 'GPS Longitude');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `longitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `longitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `network_type` SET TAGS ('dbx_business_glossary_term' = 'Network Type');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `network_type` SET TAGS ('dbx_value_regex' = 'cellular|satellite|wifi');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `odometer_km` SET TAGS ('dbx_business_glossary_term' = 'Odometer Reading (Kilometers)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `payload_json` SET TAGS ('dbx_business_glossary_term' = 'Raw IoT Payload (JSON)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `signal_strength` SET TAGS ('dbx_business_glossary_term' = 'Signal Strength');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `source_system` SET TAGS ('dbx_business_glossary_term' = 'Source System');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `speed_kmh` SET TAGS ('dbx_business_glossary_term' = 'Speed (Kilometers per Hour)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `temperature_c` SET TAGS ('dbx_business_glossary_term' = 'Temperature (Celsius)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`telematics_event` ALTER COLUMN `temperature_setpoint_c` SET TAGS ('dbx_business_glossary_term' = 'Temperature Setpoint (Celsius)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` SET TAGS ('dbx_subdomain' = 'workforce_coordination');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `driver_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Driver Profile ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Agreement Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `carrier_id` SET TAGS ('dbx_business_glossary_term' = 'Carrier Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `trade_party_id` SET TAGS ('dbx_business_glossary_term' = 'Customs Trade Party Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `depot_id` SET TAGS ('dbx_internal' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `license_permit_id` SET TAGS ('dbx_business_glossary_term' = 'License Permit Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `supplier_id` SET TAGS ('dbx_business_glossary_term' = 'Contractor ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `assignment_status` SET TAGS ('dbx_business_glossary_term' = 'Driver Assignment Status');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `assignment_status` SET TAGS ('dbx_value_regex' = 'active|inactive|on_leave|suspended|terminated');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `background_check_date` SET TAGS ('dbx_business_glossary_term' = 'Background Check Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `background_check_status` SET TAGS ('dbx_business_glossary_term' = 'Background Check Status');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `background_check_status` SET TAGS ('dbx_value_regex' = 'cleared|pending|failed|expired');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `data_source_system` SET TAGS ('dbx_business_glossary_term' = 'Data Source System');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `disciplinary_flag` SET TAGS ('dbx_business_glossary_term' = 'Disciplinary Flag');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `driver_name` SET TAGS ('dbx_business_glossary_term' = 'Driver Full Name');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `driver_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `driver_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `drug_test_date` SET TAGS ('dbx_business_glossary_term' = 'Drug Test Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `drug_test_result` SET TAGS ('dbx_business_glossary_term' = 'Drug Test Result');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `drug_test_result` SET TAGS ('dbx_value_regex' = 'negative|positive|pending|refused');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `drug_test_result` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `email_address` SET TAGS ('dbx_business_glossary_term' = 'Driver Email Address');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `email_address` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `email_address` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `email_address` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `emergency_contact_name` SET TAGS ('dbx_business_glossary_term' = 'Emergency Contact Name');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `emergency_contact_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `emergency_contact_phone` SET TAGS ('dbx_business_glossary_term' = 'Emergency Contact Phone');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `emergency_contact_phone` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `emergency_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `employment_type` SET TAGS ('dbx_business_glossary_term' = 'Employment Type');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `employment_type` SET TAGS ('dbx_value_regex' = 'full_time_employee|part_time_employee|contractor|owner_operator|temporary');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `gps_device_code` SET TAGS ('dbx_business_glossary_term' = 'GPS Device ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `gps_device_code` SET TAGS ('dbx_internal' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `gps_device_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `hire_date` SET TAGS ('dbx_business_glossary_term' = 'Driver Hire Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `language_proficiency` SET TAGS ('dbx_business_glossary_term' = 'Language Proficiency');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `last_performance_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Performance Review Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `license_categories` SET TAGS ('dbx_business_glossary_term' = 'License Categories');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `license_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'License Expiry Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `license_issue_date` SET TAGS ('dbx_business_glossary_term' = 'License Issue Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `license_issuing_country` SET TAGS ('dbx_business_glossary_term' = 'License Issuing Country');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `license_issuing_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `license_issuing_state` SET TAGS ('dbx_business_glossary_term' = 'License Issuing State or Province');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `license_number` SET TAGS ('dbx_business_glossary_term' = 'Driver License Number');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `license_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `license_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `performance_rating` SET TAGS ('dbx_business_glossary_term' = 'Driver Performance Rating');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `performance_rating` SET TAGS ('dbx_value_regex' = 'excellent|good|satisfactory|needs_improvement|unsatisfactory');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_business_glossary_term' = 'Driver Primary Contact Phone');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `rfid_tag_code` SET TAGS ('dbx_business_glossary_term' = 'RFID Tag ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Driver Termination Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `vehicle_type_authorization` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Type Authorization');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_profile` ALTER COLUMN `years_of_experience` SET TAGS ('dbx_business_glossary_term' = 'Years of Driving Experience');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` SET TAGS ('dbx_subdomain' = 'workforce_coordination');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ALTER COLUMN `driver_assignment_id` SET TAGS ('dbx_business_glossary_term' = 'Driver Assignment ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ALTER COLUMN `asset_assignment_id` SET TAGS ('dbx_business_glossary_term' = 'Asset Assignment Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ALTER COLUMN `carrier_id` SET TAGS ('dbx_business_glossary_term' = 'Carrier Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ALTER COLUMN `depot_id` SET TAGS ('dbx_business_glossary_term' = 'Destination Location ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ALTER COLUMN `plan_id` SET TAGS ('dbx_business_glossary_term' = 'Route ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ALTER COLUMN `transport_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Asset ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ALTER COLUMN `primary_fleet_depot_id` SET TAGS ('dbx_business_glossary_term' = 'Origin Location ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ALTER COLUMN `driver_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Driver ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ALTER COLUMN `agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Service Agreement Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ALTER COLUMN `shipment_leg_id` SET TAGS ('dbx_business_glossary_term' = 'Shipment Leg Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ALTER COLUMN `trip_id` SET TAGS ('dbx_business_glossary_term' = 'Trip ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ALTER COLUMN `actual_departure_datetime` SET TAGS ('dbx_business_glossary_term' = 'Actual Departure Datetime');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ALTER COLUMN `actual_return_datetime` SET TAGS ('dbx_business_glossary_term' = 'Actual Return Datetime');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ALTER COLUMN `assignment_duration_hours` SET TAGS ('dbx_business_glossary_term' = 'Assignment Duration Hours');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ALTER COLUMN `assignment_number` SET TAGS ('dbx_business_glossary_term' = 'Assignment Number');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ALTER COLUMN `assignment_outcome` SET TAGS ('dbx_business_glossary_term' = 'Assignment Outcome');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ALTER COLUMN `assignment_priority` SET TAGS ('dbx_business_glossary_term' = 'Assignment Priority');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ALTER COLUMN `assignment_priority` SET TAGS ('dbx_value_regex' = 'critical|high|normal|low');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ALTER COLUMN `assignment_status` SET TAGS ('dbx_business_glossary_term' = 'Assignment Status');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ALTER COLUMN `assignment_status` SET TAGS ('dbx_value_regex' = 'scheduled|dispatched|in_progress|completed|cancelled|suspended');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ALTER COLUMN `assignment_type` SET TAGS ('dbx_business_glossary_term' = 'Assignment Type');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ALTER COLUMN `cancellation_reason` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Reason');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ALTER COLUMN `co2_emissions_kg` SET TAGS ('dbx_business_glossary_term' = 'Carbon Dioxide Equivalent (CO2e) Emissions Kilograms');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ALTER COLUMN `customer_feedback_score` SET TAGS ('dbx_business_glossary_term' = 'Customer Feedback Score');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ALTER COLUMN `dispatch_datetime` SET TAGS ('dbx_business_glossary_term' = 'Dispatch Datetime');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ALTER COLUMN `distance_actual_km` SET TAGS ('dbx_business_glossary_term' = 'Distance Actual Kilometers');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ALTER COLUMN `distance_planned_km` SET TAGS ('dbx_business_glossary_term' = 'Distance Planned Kilometers');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ALTER COLUMN `driver_rating` SET TAGS ('dbx_business_glossary_term' = 'Driver Rating');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ALTER COLUMN `driving_hours` SET TAGS ('dbx_business_glossary_term' = 'Driving Hours');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ALTER COLUMN `fuel_consumed_liters` SET TAGS ('dbx_business_glossary_term' = 'Fuel Consumed Liters');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ALTER COLUMN `hos_counter_at_end` SET TAGS ('dbx_business_glossary_term' = 'Hours of Service (HOS) Counter at End');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ALTER COLUMN `hos_counter_at_start` SET TAGS ('dbx_business_glossary_term' = 'Hours of Service (HOS) Counter at Start');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ALTER COLUMN `hos_violation_flag` SET TAGS ('dbx_business_glossary_term' = 'Hours of Service (HOS) Violation Flag');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ALTER COLUMN `hos_violation_type` SET TAGS ('dbx_business_glossary_term' = 'Hours of Service (HOS) Violation Type');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ALTER COLUMN `planned_departure_datetime` SET TAGS ('dbx_business_glossary_term' = 'Planned Departure Datetime');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ALTER COLUMN `planned_return_datetime` SET TAGS ('dbx_business_glossary_term' = 'Planned Return Datetime');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ALTER COLUMN `rest_break_hours` SET TAGS ('dbx_business_glossary_term' = 'Rest Break Hours');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ALTER COLUMN `safety_incident_description` SET TAGS ('dbx_business_glossary_term' = 'Safety Incident Description');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ALTER COLUMN `safety_incident_flag` SET TAGS ('dbx_business_glossary_term' = 'Safety Incident Flag');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`driver_assignment` ALTER COLUMN `special_instructions` SET TAGS ('dbx_business_glossary_term' = 'Special Instructions');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` SET TAGS ('dbx_subdomain' = 'service_maintenance');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `maintenance_order_id` SET TAGS ('dbx_business_glossary_term' = 'Maintenance Order ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Agreement Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `carrier_payable_id` SET TAGS ('dbx_business_glossary_term' = 'Carrier Payable Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `depot_id` SET TAGS ('dbx_business_glossary_term' = 'Workshop Location ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `facility_id` SET TAGS ('dbx_business_glossary_term' = 'Maintenance Facility Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `maintenance_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Maintenance Schedule Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `purchase_order_id` SET TAGS ('dbx_business_glossary_term' = 'Purchase Order Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `purchase_requisition_id` SET TAGS ('dbx_business_glossary_term' = 'Purchase Requisition Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `supplier_id` SET TAGS ('dbx_business_glossary_term' = 'Vendor ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `transport_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Asset ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `actual_completion_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Actual Completion Timestamp');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `actual_start_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Actual Start Timestamp');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `cost_center_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Code');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `cost_center_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{4,10}$');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `downtime_hours` SET TAGS ('dbx_business_glossary_term' = 'Downtime Hours');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `engine_hours` SET TAGS ('dbx_business_glossary_term' = 'Engine Hours');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `external_service_cost` SET TAGS ('dbx_business_glossary_term' = 'External Service Cost');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `fault_code` SET TAGS ('dbx_business_glossary_term' = 'Fault Code');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `fault_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{4,10}$');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `fault_description` SET TAGS ('dbx_business_glossary_term' = 'Fault Description');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_value_regex' = '^[0-9]{4,10}$');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `inspection_certificate_number` SET TAGS ('dbx_business_glossary_term' = 'Inspection Certificate Number');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `inspection_certificate_number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9-]{8,20}$');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `inspection_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Inspection Expiry Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `labor_cost` SET TAGS ('dbx_business_glossary_term' = 'Labor Cost');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `labor_hours` SET TAGS ('dbx_business_glossary_term' = 'Labor Hours');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `maintenance_category` SET TAGS ('dbx_business_glossary_term' = 'Maintenance Category');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `maintenance_order_status` SET TAGS ('dbx_business_glossary_term' = 'Maintenance Order Status');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `maintenance_order_status` SET TAGS ('dbx_value_regex' = 'draft|scheduled|in_progress|on_hold|completed|cancelled');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `maintenance_provider_type` SET TAGS ('dbx_business_glossary_term' = 'Maintenance Provider Type');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `maintenance_provider_type` SET TAGS ('dbx_value_regex' = 'internal_workshop|external_vendor|oem_service_center|authorized_dealer');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `maintenance_type` SET TAGS ('dbx_business_glossary_term' = 'Maintenance Type');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `maintenance_type` SET TAGS ('dbx_value_regex' = 'preventive|corrective|statutory_inspection|breakdown');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Modified Timestamp');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Maintenance Order Notes');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `odometer_reading` SET TAGS ('dbx_business_glossary_term' = 'Odometer Reading');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `parts_cost` SET TAGS ('dbx_business_glossary_term' = 'Parts Cost');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `parts_replaced_list` SET TAGS ('dbx_business_glossary_term' = 'Parts Replaced List');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `post_maintenance_status` SET TAGS ('dbx_business_glossary_term' = 'Post-Maintenance Asset Status');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `post_maintenance_status` SET TAGS ('dbx_value_regex' = 'operational|limited_service|out_of_service|pending_inspection|scrapped');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `priority` SET TAGS ('dbx_business_glossary_term' = 'Maintenance Priority');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `priority` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `raised_date` SET TAGS ('dbx_business_glossary_term' = 'Maintenance Order Raised Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `regulatory_inspection_type` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Inspection Type');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `regulatory_inspection_type` SET TAGS ('dbx_value_regex' = 'dot_annual|icao_airworthiness|maritime_survey|emissions_test|safety_certification|none');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `scheduled_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Completion Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `scheduled_start_date` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Start Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `total_maintenance_cost` SET TAGS ('dbx_business_glossary_term' = 'Total Maintenance Cost');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `warranty_claim_flag` SET TAGS ('dbx_business_glossary_term' = 'Warranty Claim Flag');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `warranty_claim_number` SET TAGS ('dbx_business_glossary_term' = 'Warranty Claim Number');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `warranty_claim_number` SET TAGS ('dbx_value_regex' = '^WC-[A-Z0-9]{8,12}$');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `work_order_number` SET TAGS ('dbx_business_glossary_term' = 'Work Order Number');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `work_order_number` SET TAGS ('dbx_value_regex' = '^WO-[A-Z0-9]{8,12}$');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_order` ALTER COLUMN `work_performed_description` SET TAGS ('dbx_business_glossary_term' = 'Work Performed Description');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` SET TAGS ('dbx_subdomain' = 'service_maintenance');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ALTER COLUMN `maintenance_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Maintenance Schedule ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ALTER COLUMN `agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Agreement Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ALTER COLUMN `asset_type_id` SET TAGS ('dbx_business_glossary_term' = 'Asset Type Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ALTER COLUMN `facility_id` SET TAGS ('dbx_business_glossary_term' = 'Maintenance Facility ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ALTER COLUMN `supplier_id` SET TAGS ('dbx_business_glossary_term' = 'Vendor ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ALTER COLUMN `transport_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Asset ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ALTER COLUMN `auto_generate_order_flag` SET TAGS ('dbx_business_glossary_term' = 'Auto Generate Order Flag');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ALTER COLUMN `compliance_mandatory_flag` SET TAGS ('dbx_business_glossary_term' = 'Compliance Mandatory Flag');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ALTER COLUMN `cost_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Currency Code');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ALTER COLUMN `cost_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ALTER COLUMN `downtime_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Downtime Required Flag');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ALTER COLUMN `estimated_cost` SET TAGS ('dbx_business_glossary_term' = 'Estimated Cost');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ALTER COLUMN `estimated_cost` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ALTER COLUMN `estimated_duration_hours` SET TAGS ('dbx_business_glossary_term' = 'Estimated Duration Hours');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ALTER COLUMN `interval_unit` SET TAGS ('dbx_business_glossary_term' = 'Interval Unit of Measure');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ALTER COLUMN `interval_unit` SET TAGS ('dbx_value_regex' = 'miles|kilometers|hours|days|cycles');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ALTER COLUMN `interval_value` SET TAGS ('dbx_business_glossary_term' = 'Interval Value');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ALTER COLUMN `last_completed_date` SET TAGS ('dbx_business_glossary_term' = 'Last Completed Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ALTER COLUMN `last_completed_hours` SET TAGS ('dbx_business_glossary_term' = 'Last Completed Engine Hours');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ALTER COLUMN `last_completed_mileage` SET TAGS ('dbx_business_glossary_term' = 'Last Completed Mileage');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ALTER COLUMN `last_modified_by` SET TAGS ('dbx_business_glossary_term' = 'Last Modified By User');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ALTER COLUMN `lead_time_days` SET TAGS ('dbx_business_glossary_term' = 'Lead Time Days');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ALTER COLUMN `next_due_date` SET TAGS ('dbx_business_glossary_term' = 'Next Due Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ALTER COLUMN `next_due_hours` SET TAGS ('dbx_business_glossary_term' = 'Next Due Engine Hours');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ALTER COLUMN `next_due_mileage` SET TAGS ('dbx_business_glossary_term' = 'Next Due Mileage');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Schedule Notes');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ALTER COLUMN `parts_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Parts Required Flag');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ALTER COLUMN `priority_level` SET TAGS ('dbx_business_glossary_term' = 'Priority Level');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ALTER COLUMN `priority_level` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ALTER COLUMN `regulation_reference` SET TAGS ('dbx_business_glossary_term' = 'Regulation Reference');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ALTER COLUMN `regulatory_body` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Body');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ALTER COLUMN `schedule_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Schedule Effective Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ALTER COLUMN `schedule_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Schedule Expiry Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ALTER COLUMN `schedule_status` SET TAGS ('dbx_business_glossary_term' = 'Schedule Status');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ALTER COLUMN `schedule_status` SET TAGS ('dbx_value_regex' = 'active|suspended|completed|overdue|cancelled');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ALTER COLUMN `service_description` SET TAGS ('dbx_business_glossary_term' = 'Service Description');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ALTER COLUMN `service_type` SET TAGS ('dbx_business_glossary_term' = 'Service Type');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ALTER COLUMN `service_type` SET TAGS ('dbx_value_regex' = 'oil_change|tire_rotation|brake_inspection|engine_overhaul|dot_annual_inspection|icao_100_hour_check');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ALTER COLUMN `tolerance_after_days` SET TAGS ('dbx_business_glossary_term' = 'Tolerance After Days');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ALTER COLUMN `tolerance_before_days` SET TAGS ('dbx_business_glossary_term' = 'Tolerance Before Days');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ALTER COLUMN `trigger_basis` SET TAGS ('dbx_business_glossary_term' = 'Trigger Basis');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`maintenance_schedule` ALTER COLUMN `trigger_basis` SET TAGS ('dbx_value_regex' = 'mileage|engine_hours|calendar_days|flight_hours|operating_cycles');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` SET TAGS ('dbx_subdomain' = 'service_maintenance');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `fuel_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Fuel Transaction ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `asset_assignment_id` SET TAGS ('dbx_business_glossary_term' = 'Asset Assignment Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `depot_id` SET TAGS ('dbx_business_glossary_term' = 'Depot Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `driver_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Driver ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Fuel Agreement Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `fuel_index_id` SET TAGS ('dbx_business_glossary_term' = 'Fuel Index Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `lane_id` SET TAGS ('dbx_business_glossary_term' = 'Lane Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `partner_id` SET TAGS ('dbx_business_glossary_term' = 'Network Partner Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `plan_id` SET TAGS ('dbx_business_glossary_term' = 'Route ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `purchase_order_id` SET TAGS ('dbx_business_glossary_term' = 'Purchase Order Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `supplier_id` SET TAGS ('dbx_business_glossary_term' = 'Supplier ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `transport_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Transport Asset ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `trip_id` SET TAGS ('dbx_business_glossary_term' = 'Trip ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `authorization_code` SET TAGS ('dbx_business_glossary_term' = 'Authorization Code');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `co2e_emission_factor` SET TAGS ('dbx_business_glossary_term' = 'Carbon Dioxide Equivalent (CO2e) Emission Factor');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `co2e_emissions_kg` SET TAGS ('dbx_business_glossary_term' = 'Carbon Dioxide Equivalent (CO2e) Emissions in Kilograms');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `discount_amount` SET TAGS ('dbx_business_glossary_term' = 'Discount Amount');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `fuel_card_number` SET TAGS ('dbx_business_glossary_term' = 'Fuel Card Number');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `fuel_card_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `fuel_card_provider` SET TAGS ('dbx_business_glossary_term' = 'Fuel Card Provider');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `fuel_efficiency` SET TAGS ('dbx_business_glossary_term' = 'Fuel Efficiency');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `fuel_grade` SET TAGS ('dbx_business_glossary_term' = 'Fuel Grade');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `fuel_station_code` SET TAGS ('dbx_business_glossary_term' = 'Fuel Station ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `fuel_station_country_code` SET TAGS ('dbx_business_glossary_term' = 'Fuel Station Country Code');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `fuel_station_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `fuel_station_location` SET TAGS ('dbx_business_glossary_term' = 'Fuel Station Location');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `fuel_station_name` SET TAGS ('dbx_business_glossary_term' = 'Fuel Station Name');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `fuel_type` SET TAGS ('dbx_business_glossary_term' = 'Fuel Type');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `general_ledger_account` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `is_emergency_refuel` SET TAGS ('dbx_business_glossary_term' = 'Is Emergency Refuel');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `is_reconciled` SET TAGS ('dbx_business_glossary_term' = 'Is Reconciled');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Transaction Notes');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `odometer_reading` SET TAGS ('dbx_business_glossary_term' = 'Odometer Reading');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `odometer_unit` SET TAGS ('dbx_business_glossary_term' = 'Odometer Unit');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `odometer_unit` SET TAGS ('dbx_value_regex' = 'km|miles|hours');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'fuel_card|credit_card|cash|invoice|direct_debit');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `quantity` SET TAGS ('dbx_business_glossary_term' = 'Fuel Quantity');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `reconciliation_date` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `source_system` SET TAGS ('dbx_business_glossary_term' = 'Source System');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `supplier_invoice_number` SET TAGS ('dbx_business_glossary_term' = 'Supplier Invoice Number');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Tax Amount');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `total_cost` SET TAGS ('dbx_business_glossary_term' = 'Total Cost');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `transaction_datetime` SET TAGS ('dbx_business_glossary_term' = 'Transaction Date and Time');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `transaction_number` SET TAGS ('dbx_business_glossary_term' = 'Transaction Number');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `transaction_status` SET TAGS ('dbx_business_glossary_term' = 'Transaction Status');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `transaction_status` SET TAGS ('dbx_value_regex' = 'completed|pending|disputed|cancelled|reversed');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `unit_cost` SET TAGS ('dbx_business_glossary_term' = 'Unit Cost');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `unit_of_measure` SET TAGS ('dbx_business_glossary_term' = 'Unit of Measure');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`fuel_transaction` ALTER COLUMN `unit_of_measure` SET TAGS ('dbx_value_regex' = 'litres|gallons|kwh|kg|m3');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` SET TAGS ('dbx_subdomain' = 'asset_management');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `asset_inspection_id` SET TAGS ('dbx_business_glossary_term' = 'Asset Inspection ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `compliance_program_id` SET TAGS ('dbx_business_glossary_term' = 'Customs Compliance Program Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `declaration_id` SET TAGS ('dbx_business_glossary_term' = 'Customs Declaration Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `depot_id` SET TAGS ('dbx_business_glossary_term' = 'Depot Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `facility_id` SET TAGS ('dbx_business_glossary_term' = 'Inspection Facility Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `network_node_id` SET TAGS ('dbx_business_glossary_term' = 'Inspection Network Node Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `supplier_id` SET TAGS ('dbx_business_glossary_term' = 'Supplier Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `transport_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Transport Asset ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `certificate_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Certificate Expiry Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `certificate_issue_date` SET TAGS ('dbx_business_glossary_term' = 'Certificate Issue Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `certificate_number` SET TAGS ('dbx_business_glossary_term' = 'Certificate Number');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `corrective_action_deadline` SET TAGS ('dbx_business_glossary_term' = 'Corrective Action Deadline');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `corrective_actions_required` SET TAGS ('dbx_business_glossary_term' = 'Corrective Actions Required');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `critical_defects_count` SET TAGS ('dbx_business_glossary_term' = 'Critical Defects Count');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `defects_description` SET TAGS ('dbx_business_glossary_term' = 'Defects Description');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `defects_identified_count` SET TAGS ('dbx_business_glossary_term' = 'Defects Identified Count');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `inspection_checklist_reference` SET TAGS ('dbx_business_glossary_term' = 'Inspection Checklist Reference');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `inspection_cost` SET TAGS ('dbx_business_glossary_term' = 'Inspection Cost');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `inspection_cost_currency` SET TAGS ('dbx_business_glossary_term' = 'Inspection Cost Currency');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `inspection_cost_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `inspection_date` SET TAGS ('dbx_business_glossary_term' = 'Inspection Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `inspection_document_url` SET TAGS ('dbx_business_glossary_term' = 'Inspection Document URL');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `inspection_end_time` SET TAGS ('dbx_business_glossary_term' = 'Inspection End Time');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `inspection_location_country` SET TAGS ('dbx_business_glossary_term' = 'Inspection Location Country');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `inspection_location_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `inspection_notes` SET TAGS ('dbx_business_glossary_term' = 'Inspection Notes');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `inspection_number` SET TAGS ('dbx_business_glossary_term' = 'Inspection Number');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `inspection_outcome` SET TAGS ('dbx_business_glossary_term' = 'Inspection Outcome');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `inspection_outcome` SET TAGS ('dbx_value_regex' = 'pass|fail|conditional pass|not applicable');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `inspection_start_time` SET TAGS ('dbx_business_glossary_term' = 'Inspection Start Time');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `inspection_status` SET TAGS ('dbx_business_glossary_term' = 'Inspection Status');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `inspection_status` SET TAGS ('dbx_value_regex' = 'scheduled|in progress|completed|cancelled|deferred');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `inspection_type` SET TAGS ('dbx_business_glossary_term' = 'Inspection Type');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `inspection_type` SET TAGS ('dbx_value_regex' = 'DOT roadside inspection|ICAO airworthiness check|IMO vessel survey|pre-trip inspection|annual safety inspection|C-TPAT security inspection');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `inspector_authority` SET TAGS ('dbx_business_glossary_term' = 'Inspector Authority');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `inspector_certification_number` SET TAGS ('dbx_business_glossary_term' = 'Inspector Certification Number');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `inspector_name` SET TAGS ('dbx_business_glossary_term' = 'Inspector Name');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `inspector_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `next_inspection_due_date` SET TAGS ('dbx_business_glossary_term' = 'Next Inspection Due Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `odometer_reading_at_inspection` SET TAGS ('dbx_business_glossary_term' = 'Odometer Reading at Inspection');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `out_of_service_flag` SET TAGS ('dbx_business_glossary_term' = 'Out of Service Flag');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `out_of_service_start_date` SET TAGS ('dbx_business_glossary_term' = 'Out of Service Start Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `regulatory_certificate_issued` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Certificate Issued');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `regulatory_filing_reference` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Filing Reference');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `reinspection_due_date` SET TAGS ('dbx_business_glossary_term' = 'Reinspection Due Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_inspection` ALTER COLUMN `reinspection_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Reinspection Required Flag');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_licence` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_licence` SET TAGS ('dbx_subdomain' = 'asset_management');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_licence` ALTER COLUMN `asset_licence_id` SET TAGS ('dbx_business_glossary_term' = 'Asset Licence ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_licence` ALTER COLUMN `asset_type_id` SET TAGS ('dbx_business_glossary_term' = 'Asset Type Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_licence` ALTER COLUMN `invoice_id` SET TAGS ('dbx_business_glossary_term' = 'Invoice Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_licence` ALTER COLUMN `transport_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Transport Asset ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_licence` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_licence` ALTER COLUMN `document_reference` SET TAGS ('dbx_business_glossary_term' = 'Document Reference');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_licence` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_licence` ALTER COLUMN `endorsements` SET TAGS ('dbx_business_glossary_term' = 'Endorsements');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_licence` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_licence` ALTER COLUMN `inspection_authority` SET TAGS ('dbx_business_glossary_term' = 'Inspection Authority');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_licence` ALTER COLUMN `inspection_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Inspection Required Flag');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_licence` ALTER COLUMN `issue_date` SET TAGS ('dbx_business_glossary_term' = 'Issue Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_licence` ALTER COLUMN `issuing_authority` SET TAGS ('dbx_business_glossary_term' = 'Issuing Authority');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_licence` ALTER COLUMN `issuing_country` SET TAGS ('dbx_business_glossary_term' = 'Issuing Country');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_licence` ALTER COLUMN `issuing_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_licence` ALTER COLUMN `jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Jurisdiction');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_licence` ALTER COLUMN `last_inspection_date` SET TAGS ('dbx_business_glossary_term' = 'Last Inspection Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_licence` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Updated Timestamp');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_licence` ALTER COLUMN `licence_category` SET TAGS ('dbx_business_glossary_term' = 'Licence Category');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_licence` ALTER COLUMN `licence_class` SET TAGS ('dbx_business_glossary_term' = 'Licence Class');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_licence` ALTER COLUMN `licence_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Licence Fee Amount');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_licence` ALTER COLUMN `licence_fee_currency` SET TAGS ('dbx_business_glossary_term' = 'Licence Fee Currency');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_licence` ALTER COLUMN `licence_fee_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_licence` ALTER COLUMN `licence_number` SET TAGS ('dbx_business_glossary_term' = 'Licence Number');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_licence` ALTER COLUMN `licence_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_licence` ALTER COLUMN `licence_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_licence` ALTER COLUMN `licence_type` SET TAGS ('dbx_business_glossary_term' = 'Licence Type');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_licence` ALTER COLUMN `next_inspection_due_date` SET TAGS ('dbx_business_glossary_term' = 'Next Inspection Due Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_licence` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_licence` ALTER COLUMN `payment_reference` SET TAGS ('dbx_business_glossary_term' = 'Payment Reference');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_licence` ALTER COLUMN `regulatory_reference` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reference');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_licence` ALTER COLUMN `renewal_due_date` SET TAGS ('dbx_business_glossary_term' = 'Renewal Due Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_licence` ALTER COLUMN `renewal_reminder_days` SET TAGS ('dbx_business_glossary_term' = 'Renewal Reminder Days');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_licence` ALTER COLUMN `responsible_party` SET TAGS ('dbx_business_glossary_term' = 'Responsible Party');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_licence` ALTER COLUMN `validity_status` SET TAGS ('dbx_business_glossary_term' = 'Validity Status');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_licence` ALTER COLUMN `validity_status` SET TAGS ('dbx_value_regex' = 'valid|expired|suspended|revoked|pending_renewal|pending_approval');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` SET TAGS ('dbx_subdomain' = 'service_maintenance');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `incident_id` SET TAGS ('dbx_business_glossary_term' = 'Fleet Incident ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `asset_assignment_id` SET TAGS ('dbx_business_glossary_term' = 'Asset Assignment Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `cargo_claim_id` SET TAGS ('dbx_business_glossary_term' = 'Insurance Claim ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `carrier_id` SET TAGS ('dbx_business_glossary_term' = 'Carrier Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `consignment_id` SET TAGS ('dbx_business_glossary_term' = 'Shipment ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `declaration_id` SET TAGS ('dbx_business_glossary_term' = 'Customs Declaration Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `driver_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Driver ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `facility_id` SET TAGS ('dbx_business_glossary_term' = 'Facility Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `lane_id` SET TAGS ('dbx_business_glossary_term' = 'Lane Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `penalty_clause_id` SET TAGS ('dbx_business_glossary_term' = 'Penalty Clause Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `service_case_id` SET TAGS ('dbx_business_glossary_term' = 'Service Case Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `transport_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Transport Asset ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `trip_id` SET TAGS ('dbx_business_glossary_term' = 'Trip Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `asset_damage_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Asset Damage Currency Code');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `asset_damage_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `asset_damage_estimated_cost` SET TAGS ('dbx_business_glossary_term' = 'Asset Damage Estimated Cost');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `cargo_damage_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Cargo Damage Currency Code');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `cargo_damage_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `cargo_damage_estimated_cost` SET TAGS ('dbx_business_glossary_term' = 'Cargo Damage Estimated Cost');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `cargo_damage_flag` SET TAGS ('dbx_business_glossary_term' = 'Cargo Damage Flag');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `corrective_action_description` SET TAGS ('dbx_business_glossary_term' = 'Corrective Action Description');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `corrective_action_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Corrective Action Required Flag');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `corrective_action_status` SET TAGS ('dbx_business_glossary_term' = 'Corrective Action Status');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `corrective_action_status` SET TAGS ('dbx_value_regex' = 'not_required|pending|in_progress|completed|overdue');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `datetime` SET TAGS ('dbx_business_glossary_term' = 'Incident Date and Time');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `dot_report_submitted_date` SET TAGS ('dbx_business_glossary_term' = 'DOT (Department of Transportation) Report Submitted Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `dot_reportable_flag` SET TAGS ('dbx_business_glossary_term' = 'DOT (Department of Transportation) Reportable Flag');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `fatality_count` SET TAGS ('dbx_business_glossary_term' = 'Fatality Count');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `incident_number` SET TAGS ('dbx_business_glossary_term' = 'Incident Number');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `incident_number` SET TAGS ('dbx_value_regex' = '^INC-[0-9]{10}$');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `incident_status` SET TAGS ('dbx_business_glossary_term' = 'Incident Status');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `incident_status` SET TAGS ('dbx_value_regex' = 'reported|under_investigation|pending_review|closed|reopened');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `incident_type` SET TAGS ('dbx_business_glossary_term' = 'Incident Type');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `incident_type` SET TAGS ('dbx_value_regex' = 'accident|near_miss|breakdown|cargo_damage|security_incident|theft');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `injuries_reported_flag` SET TAGS ('dbx_business_glossary_term' = 'Injuries Reported Flag');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `injury_count` SET TAGS ('dbx_business_glossary_term' = 'Injury Count');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `investigation_assigned_to` SET TAGS ('dbx_business_glossary_term' = 'Investigation Assigned To');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `investigation_completed_date` SET TAGS ('dbx_business_glossary_term' = 'Investigation Completed Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `location_address` SET TAGS ('dbx_business_glossary_term' = 'Location Address');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `location_address` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `location_address` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `location_city` SET TAGS ('dbx_business_glossary_term' = 'Location City');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `location_country_code` SET TAGS ('dbx_business_glossary_term' = 'Location Country Code');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `location_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `location_latitude` SET TAGS ('dbx_business_glossary_term' = 'Location Latitude');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `location_latitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `location_latitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `location_longitude` SET TAGS ('dbx_business_glossary_term' = 'Location Longitude');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `location_longitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `location_longitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `location_postal_code` SET TAGS ('dbx_business_glossary_term' = 'Location Postal Code');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `location_postal_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `location_postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `location_state_province` SET TAGS ('dbx_business_glossary_term' = 'Location State or Province');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Incident Notes');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `police_department` SET TAGS ('dbx_business_glossary_term' = 'Police Department');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `police_report_filed_flag` SET TAGS ('dbx_business_glossary_term' = 'Police Report Filed Flag');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `police_report_number` SET TAGS ('dbx_business_glossary_term' = 'Police Report Number');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `reported_datetime` SET TAGS ('dbx_business_glossary_term' = 'Reported Date and Time');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `root_cause_category` SET TAGS ('dbx_business_glossary_term' = 'Root Cause Category');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `root_cause_description` SET TAGS ('dbx_business_glossary_term' = 'Root Cause Description');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `severity` SET TAGS ('dbx_business_glossary_term' = 'Incident Severity');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `severity` SET TAGS ('dbx_value_regex' = 'minor|moderate|major|critical');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `third_party_contact` SET TAGS ('dbx_business_glossary_term' = 'Third Party Contact');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `third_party_contact` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `third_party_contact` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `third_party_insurance_provider` SET TAGS ('dbx_business_glossary_term' = 'Third Party Insurance Provider');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `third_party_involved_flag` SET TAGS ('dbx_business_glossary_term' = 'Third Party Involved Flag');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `third_party_name` SET TAGS ('dbx_business_glossary_term' = 'Third Party Name');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `third_party_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `third_party_policy_number` SET TAGS ('dbx_business_glossary_term' = 'Third Party Policy Number');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `third_party_policy_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`incident` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` SET TAGS ('dbx_subdomain' = 'asset_management');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ALTER COLUMN `asset_utilisation_id` SET TAGS ('dbx_business_glossary_term' = 'Asset Utilisation ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ALTER COLUMN `depot_id` SET TAGS ('dbx_business_glossary_term' = 'Assigned Depot ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ALTER COLUMN `driver_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Assigned Driver ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ALTER COLUMN `lane_id` SET TAGS ('dbx_business_glossary_term' = 'Lane Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ALTER COLUMN `plan_id` SET TAGS ('dbx_business_glossary_term' = 'Route ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ALTER COLUMN `transport_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Transport Asset ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ALTER COLUMN `volume_commitment_id` SET TAGS ('dbx_business_glossary_term' = 'Contract Volume Commitment Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ALTER COLUMN `actual_payload_kg` SET TAGS ('dbx_business_glossary_term' = 'Actual Payload (Kilograms)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ALTER COLUMN `co2_emissions_kg` SET TAGS ('dbx_business_glossary_term' = 'Carbon Dioxide Equivalent (CO2e) Emissions (Kilograms)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ALTER COLUMN `compliance_status` SET TAGS ('dbx_business_glossary_term' = 'Compliance Status');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ALTER COLUMN `compliance_status` SET TAGS ('dbx_value_regex' = 'compliant|non_compliant|pending_inspection|exempted');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ALTER COLUMN `distance_travelled_km` SET TAGS ('dbx_business_glossary_term' = 'Distance Travelled (Kilometers)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ALTER COLUMN `distance_travelled_miles` SET TAGS ('dbx_business_glossary_term' = 'Distance Travelled (Miles)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ALTER COLUMN `fuel_consumed_liters` SET TAGS ('dbx_business_glossary_term' = 'Fuel Consumed (Liters)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ALTER COLUMN `fuel_efficiency_liters_per_100km` SET TAGS ('dbx_business_glossary_term' = 'Fuel Efficiency (Liters per 100 Kilometers)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ALTER COLUMN `fuel_efficiency_mpg` SET TAGS ('dbx_business_glossary_term' = 'Fuel Efficiency (Miles Per Gallon)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ALTER COLUMN `load_factor_percent` SET TAGS ('dbx_business_glossary_term' = 'Load Factor Percentage');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Utilisation Notes');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ALTER COLUMN `number_of_trips` SET TAGS ('dbx_business_glossary_term' = 'Number of Trips');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ALTER COLUMN `on_time_delivery_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'On-Time Delivery (OTD) Rate Percentage');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ALTER COLUMN `operating_cost` SET TAGS ('dbx_business_glossary_term' = 'Operating Cost (OPEX)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ALTER COLUMN `operating_cost` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ALTER COLUMN `operational_status` SET TAGS ('dbx_business_glossary_term' = 'Operational Status');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ALTER COLUMN `operational_status` SET TAGS ('dbx_value_regex' = 'active|idle|maintenance|breakdown|retired|reserved');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ALTER COLUMN `payload_capacity_kg` SET TAGS ('dbx_business_glossary_term' = 'Payload Capacity (Kilograms)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ALTER COLUMN `period_type` SET TAGS ('dbx_business_glossary_term' = 'Period Type');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ALTER COLUMN `period_type` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ALTER COLUMN `record_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ALTER COLUMN `reporting_period_date` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ALTER COLUMN `revenue_generated` SET TAGS ('dbx_business_glossary_term' = 'Revenue Generated');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ALTER COLUMN `revenue_generated` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ALTER COLUMN `safety_incidents_count` SET TAGS ('dbx_business_glossary_term' = 'Safety Incidents Count');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ALTER COLUMN `telematics_data_quality_score` SET TAGS ('dbx_business_glossary_term' = 'Telematics Data Quality Score');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ALTER COLUMN `total_available_hours` SET TAGS ('dbx_business_glossary_term' = 'Total Available Hours');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ALTER COLUMN `total_breakdown_hours` SET TAGS ('dbx_business_glossary_term' = 'Total Breakdown Hours');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ALTER COLUMN `total_downtime_hours` SET TAGS ('dbx_business_glossary_term' = 'Total Downtime Hours');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ALTER COLUMN `total_idle_hours` SET TAGS ('dbx_business_glossary_term' = 'Total Idle Hours');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ALTER COLUMN `total_maintenance_hours` SET TAGS ('dbx_business_glossary_term' = 'Total Maintenance Hours');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ALTER COLUMN `total_operational_hours` SET TAGS ('dbx_business_glossary_term' = 'Total Operational Hours');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ALTER COLUMN `utilisation_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Utilisation Rate Percentage');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ALTER COLUMN `volume_capacity_cbm` SET TAGS ('dbx_business_glossary_term' = 'Volume Capacity (Cubic Meters)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_utilisation` ALTER COLUMN `volume_utilised_cbm` SET TAGS ('dbx_business_glossary_term' = 'Volume Utilised (Cubic Meters)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` SET TAGS ('dbx_subdomain' = 'asset_management');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `depot_id` SET TAGS ('dbx_business_glossary_term' = 'Fleet Depot Identifier');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `network_node_id` SET TAGS ('dbx_business_glossary_term' = 'Network Node Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `partner_id` SET TAGS ('dbx_business_glossary_term' = 'Partner Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `address_line_1` SET TAGS ('dbx_business_glossary_term' = 'Address Line 1');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `address_line_1` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `address_line_1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `address_line_2` SET TAGS ('dbx_business_glossary_term' = 'Address Line 2');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `address_line_2` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `address_line_2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `city` SET TAGS ('dbx_business_glossary_term' = 'City');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `commissioning_date` SET TAGS ('dbx_business_glossary_term' = 'Commissioning Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `contact_email` SET TAGS ('dbx_business_glossary_term' = 'Contact Email Address');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `contact_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `contact_phone` SET TAGS ('dbx_business_glossary_term' = 'Contact Phone Number');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `contact_phone` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `container_capacity_teu` SET TAGS ('dbx_business_glossary_term' = 'Container Capacity in Twenty-foot Equivalent Units (TEU)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Country Code');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `covered_area_sqm` SET TAGS ('dbx_business_glossary_term' = 'Covered Area in Square Meters');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `customs_bonded_facility_flag` SET TAGS ('dbx_business_glossary_term' = 'Customs Bonded Facility Flag');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `decommissioning_date` SET TAGS ('dbx_business_glossary_term' = 'Decommissioning Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `depot_code` SET TAGS ('dbx_business_glossary_term' = 'Depot Code');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `depot_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{3,10}$');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `depot_name` SET TAGS ('dbx_business_glossary_term' = 'Depot Name');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `depot_type` SET TAGS ('dbx_business_glossary_term' = 'Depot Type');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `depot_type` SET TAGS ('dbx_value_regex' = 'vehicle_depot|maintenance_workshop|fuel_station|container_yard|inland_container_depot|staging_area');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `electric_charging_stations` SET TAGS ('dbx_business_glossary_term' = 'Electric Charging Stations');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `environmental_certification` SET TAGS ('dbx_business_glossary_term' = 'Environmental Certification');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `ftz_designation` SET TAGS ('dbx_business_glossary_term' = 'Free Trade Zone (FTZ) Designation');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `fuel_types_available` SET TAGS ('dbx_business_glossary_term' = 'Fuel Types Available');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `hazmat_certified_flag` SET TAGS ('dbx_business_glossary_term' = 'Hazardous Materials (HAZMAT) Certified Flag');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `last_inspection_date` SET TAGS ('dbx_business_glossary_term' = 'Last Inspection Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `latitude` SET TAGS ('dbx_business_glossary_term' = 'Latitude Coordinate');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `latitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `latitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `lease_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Lease Expiry Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `longitude` SET TAGS ('dbx_business_glossary_term' = 'Longitude Coordinate');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `longitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `longitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `maintenance_bays` SET TAGS ('dbx_business_glossary_term' = 'Maintenance Bays');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `managing_business_unit` SET TAGS ('dbx_business_glossary_term' = 'Managing Business Unit');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `next_inspection_due_date` SET TAGS ('dbx_business_glossary_term' = 'Next Inspection Due Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Operational Notes');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `operates_24_7_flag` SET TAGS ('dbx_business_glossary_term' = 'Operates 24/7 Flag');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `operating_hours_end` SET TAGS ('dbx_business_glossary_term' = 'Operating Hours End Time');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `operating_hours_end` SET TAGS ('dbx_value_regex' = '^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `operating_hours_start` SET TAGS ('dbx_business_glossary_term' = 'Operating Hours Start Time');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `operating_hours_start` SET TAGS ('dbx_value_regex' = '^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `operational_status` SET TAGS ('dbx_business_glossary_term' = 'Operational Status');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `operational_status` SET TAGS ('dbx_value_regex' = 'active|inactive|under_construction|temporarily_closed|decommissioned|planned');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `ownership_type` SET TAGS ('dbx_business_glossary_term' = 'Ownership Type');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `ownership_type` SET TAGS ('dbx_value_regex' = 'owned|leased|operated_under_contract|joint_venture');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `postal_code` SET TAGS ('dbx_business_glossary_term' = 'Postal Code');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `postal_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `region` SET TAGS ('dbx_business_glossary_term' = 'Business Region');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `security_level` SET TAGS ('dbx_business_glossary_term' = 'Security Level');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `security_level` SET TAGS ('dbx_value_regex' = 'standard|enhanced|high_security|restricted_access');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `state_province` SET TAGS ('dbx_business_glossary_term' = 'State or Province');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `time_zone` SET TAGS ('dbx_business_glossary_term' = 'Time Zone');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `total_area_sqm` SET TAGS ('dbx_business_glossary_term' = 'Total Area in Square Meters');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`depot` ALTER COLUMN `vehicle_capacity` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Capacity');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` SET TAGS ('dbx_subdomain' = 'asset_management');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `asset_type_id` SET TAGS ('dbx_business_glossary_term' = 'Asset Type ID');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `asset_category` SET TAGS ('dbx_business_glossary_term' = 'Asset Category');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `asset_subcategory` SET TAGS ('dbx_business_glossary_term' = 'Asset Subcategory');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `asset_type_code` SET TAGS ('dbx_business_glossary_term' = 'Asset Type Code');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `asset_type_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{3,10}$');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `asset_type_description` SET TAGS ('dbx_business_glossary_term' = 'Asset Type Description');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `asset_type_name` SET TAGS ('dbx_business_glossary_term' = 'Asset Type Name');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `asset_type_status` SET TAGS ('dbx_business_glossary_term' = 'Asset Type Status');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `asset_type_status` SET TAGS ('dbx_value_regex' = 'active|inactive|deprecated|under_review');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `average_acquisition_cost` SET TAGS ('dbx_business_glossary_term' = 'Average Acquisition Cost');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `average_acquisition_cost` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `certification_interval_months` SET TAGS ('dbx_business_glossary_term' = 'Certification Interval (Months)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `certification_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Certification Required Flag');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `cost_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Currency Code');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `cost_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `depreciation_method` SET TAGS ('dbx_business_glossary_term' = 'Depreciation Method');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `depreciation_method` SET TAGS ('dbx_value_regex' = 'straight_line|declining_balance|units_of_production|not_applicable');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `dot_classification_code` SET TAGS ('dbx_business_glossary_term' = 'Department of Transportation (DOT) Classification Code');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `dot_classification_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,8}$');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `emission_standard` SET TAGS ('dbx_business_glossary_term' = 'Emission Standard');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `end_date` SET TAGS ('dbx_business_glossary_term' = 'End Date');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `fuel_type_standard` SET TAGS ('dbx_business_glossary_term' = 'Fuel Type Standard');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `hazmat_capable_flag` SET TAGS ('dbx_business_glossary_term' = 'Hazardous Materials (HAZMAT) Capable Flag');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `iata_classification_code` SET TAGS ('dbx_business_glossary_term' = 'International Air Transport Association (IATA) Classification Code');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `iata_classification_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,6}$');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `imo_classification_code` SET TAGS ('dbx_business_glossary_term' = 'International Maritime Organization (IMO) Classification Code');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `imo_classification_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,8}$');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `iso_container_code` SET TAGS ('dbx_business_glossary_term' = 'ISO Container Type Code');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `iso_container_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,4}$');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `last_modified_by` SET TAGS ('dbx_business_glossary_term' = 'Last Modified By');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `maintenance_interval_days` SET TAGS ('dbx_business_glossary_term' = 'Typical Maintenance Interval (Days)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `maintenance_interval_hours` SET TAGS ('dbx_business_glossary_term' = 'Typical Maintenance Interval (Operating Hours)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `maintenance_interval_km` SET TAGS ('dbx_business_glossary_term' = 'Typical Maintenance Interval (Kilometers)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `ownership_model` SET TAGS ('dbx_business_glossary_term' = 'Ownership Model');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `ownership_model` SET TAGS ('dbx_value_regex' = 'owned|leased|mixed|third_party');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `regulatory_framework` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Framework');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `regulatory_framework` SET TAGS ('dbx_value_regex' = 'dot|icao|imo|iso|fmc|mixed');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `rfid_tagging_standard_flag` SET TAGS ('dbx_business_glossary_term' = 'Radio Frequency Identification (RFID) Tagging Standard Flag');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `standard_height_m` SET TAGS ('dbx_business_glossary_term' = 'Standard Height (Meters)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `standard_length_m` SET TAGS ('dbx_business_glossary_term' = 'Standard Length (Meters)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `standard_payload_capacity_kg` SET TAGS ('dbx_business_glossary_term' = 'Standard Payload Capacity (Kilograms)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `standard_temperature_range_max_c` SET TAGS ('dbx_business_glossary_term' = 'Standard Temperature Range Maximum (Celsius)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `standard_temperature_range_min_c` SET TAGS ('dbx_business_glossary_term' = 'Standard Temperature Range Minimum (Celsius)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `standard_teu_capacity` SET TAGS ('dbx_business_glossary_term' = 'Standard Twenty-Foot Equivalent Unit (TEU) Capacity');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `standard_useful_life_years` SET TAGS ('dbx_business_glossary_term' = 'Standard Useful Life (Years)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `standard_volume_capacity_cbm` SET TAGS ('dbx_business_glossary_term' = 'Standard Volume Capacity (Cubic Meters / CBM)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `standard_width_m` SET TAGS ('dbx_business_glossary_term' = 'Standard Width (Meters)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `telematics_capable_flag` SET TAGS ('dbx_business_glossary_term' = 'Telematics Capable Flag');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`asset_type` ALTER COLUMN `temperature_controlled_flag` SET TAGS ('dbx_business_glossary_term' = 'Temperature Controlled Flag');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`trip` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`trip` SET TAGS ('dbx_subdomain' = 'operations_tracking');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`trip` ALTER COLUMN `trip_id` SET TAGS ('dbx_business_glossary_term' = 'Trip Identifier');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`trip` ALTER COLUMN `carrier_id` SET TAGS ('dbx_business_glossary_term' = 'Carrier Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`trip` ALTER COLUMN `facility_id` SET TAGS ('dbx_business_glossary_term' = 'Destination Facility Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`trip` ALTER COLUMN `invoice_id` SET TAGS ('dbx_business_glossary_term' = 'Invoice Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`trip` ALTER COLUMN `lane_id` SET TAGS ('dbx_business_glossary_term' = 'Lane Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`trip` ALTER COLUMN `network_node_id` SET TAGS ('dbx_business_glossary_term' = 'Origin Network Node Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`trip` ALTER COLUMN `rate_card_id` SET TAGS ('dbx_business_glossary_term' = 'Rate Card Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`trip` ALTER COLUMN `rate_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Rate Schedule Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`trip` ALTER COLUMN `return_trip_id` SET TAGS ('dbx_self_ref_fk' = 'true');
ALTER TABLE `transport_shipping_ecm`.`fleet`.`trip` ALTER COLUMN `service_preference_id` SET TAGS ('dbx_business_glossary_term' = 'Service Preference Id (Foreign Key)');
