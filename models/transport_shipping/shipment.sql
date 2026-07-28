-- Schema for Domain: shipment | Business: Transport Shipping | Version: v1_mvm
-- Generated on: 2026-05-08 22:35:08

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `transport_shipping_ecm`.`shipment` COMMENT 'Core operational domain managing end-to-end shipment lifecycle from booking through delivery across express parcel, freight, and cross-border movements. Owns shipment identity, tracking events, POD/ePOD, ETA/ETD milestones, exception management, and AWB/BOL/HAWB/MAWB document references. Serves as the transactional backbone integrating TMS, FourKites visibility, and carrier execution data for D2D services.';

-- ========= TABLES =========
CREATE OR REPLACE TABLE `transport_shipping_ecm`.`shipment`.`consignment` (
    `consignment_id` BIGINT COMMENT 'Unique identifier for the consignment record. Primary key for the consignment entity representing a shipment booking from origin to destination.',
    `agreement_id` BIGINT COMMENT 'Foreign key linking to contract.agreement. Business justification: Consignment-level contract compliance reporting and SLA breach detection require knowing which customer agreement governs each booking. Logistics experts expect consignments to reference the governing',
    `air_waybill_id` BIGINT COMMENT 'Foreign key linking to freight.air_waybill. Business justification: For air freight, each consignment is documented under an air waybill (HAWB). Linking enables AWB-level consignment tracking, airline billing reconciliation, and customs filing. awb_number/hawb_number ',
    `bill_of_lading_id` BIGINT COMMENT 'Foreign key linking to freight.bill_of_lading. Business justification: For ocean freight, each consignment is documented under a bill of lading (HBL). Linking enables BOL-level consignment tracking, vessel billing reconciliation, and customs filing. bol_number is a docum',
    `booking_id` BIGINT COMMENT 'Foreign key linking to freight.booking. Business justification: A consignment is the operational execution of a freight booking. Linking enables booking-to-consignment fulfillment tracking, revenue recognition, and sales conversion reporting. The existing freight_',
    `cargo_id` BIGINT COMMENT 'Foreign key linking to freight.cargo. Business justification: A consignments physical cargo is described in freight.cargo (commodity, dangerous goods class, customs valuation). Linking enables commodity-level compliance checks, export licensing verification, an',
    `carrier_id` BIGINT COMMENT 'Foreign key linking to network.carrier. Business justification: Consignment booking is made with a specific carrier at the consignment level, driving rate card selection, customer-facing carrier branding, SLA commitments, and carrier performance reporting. A logis',
    `carrier_service_id` BIGINT COMMENT 'Foreign key linking to network.carrier_service. Business justification: A consignment is booked against a specific carrier service (e.g., DHL Express Worldwide). This link enables service-level validation, transit time lookup, capacity checks at booking, and revenue repor',
    `consignee_profile_id` BIGINT COMMENT 'Reference to the consignee profile entity representing the receiver of this consignment.',
    `consolidation_id` BIGINT COMMENT 'Foreign key linking to freight.consolidation. Business justification: A consignment may be part of an LCL or groupage consolidation. Linking enables consolidation-level shipment tracking, deconsolidation planning, and freight cost allocation per consignment within a con',
    `contract_rate_id` BIGINT COMMENT 'Foreign key linking to pricing.contract_rate. Business justification: Contract compliance reporting and margin analysis require linking each consignment to the specific contract rate applied. While rate_card_id exists, contract_rate provides the granular rate-line-level',
    `customer_account_id` BIGINT COMMENT 'Reference to the customer account that booked or is responsible for this consignment.',
    `route_delivery_zone_id` BIGINT COMMENT 'Foreign key linking to route.route_delivery_zone. Business justification: Destination postal code maps to a delivery zone determining surcharges, service days, OTD targets, and last-mile carrier assignment. Zone-based billing, SLA reporting, and COD restriction checks requi',
    `fulfillment_order_id` BIGINT COMMENT 'Foreign key linking to fulfillment.fulfillment_order. Business justification: A consignment is created from a fulfillment order — this is the core operational link between the two domains. Shipment operations teams need to look up the originating fulfillment order from a consig',
    `purchase_order_id` BIGINT COMMENT 'Foreign key linking to procurement.purchase_order. Business justification: Inbound consignments are created to fulfill purchase orders. Linking enables procurement-to-delivery cycle time reporting, inbound shipment tracking against POs, and on-time delivery measurement. A lo',
    `quote_id` BIGINT COMMENT 'Foreign key linking to freight.quote. Business justification: A consignment is booked against a freight quote. Linking enables quote-to-consignment revenue tracking, rate accuracy auditing, and sales conversion reporting — standard freight forwarding commercial ',
    `rate_card_id` BIGINT COMMENT 'Foreign key linking to pricing.rate_card. Business justification: Rating engine applies rate cards to consignments based on service type, origin/destination zones, weight breaks, and service level. Essential for automated pricing, quote generation, and revenue calcu',
    `service_scope_id` BIGINT COMMENT 'Foreign key linking to contract.service_scope. Business justification: Booking validation requires checking consignment attributes (COD, dangerous goods, temperature control) against the contracted service scope. Logistics experts expect this link for service eligibility',
    `shipper_profile_id` BIGINT COMMENT 'Reference to the shipper profile entity representing the sender of this consignment.',
    `sla_commitment_id` BIGINT COMMENT 'Foreign key linking to contract.contract_sla_commitment. Business justification: Consignment is the primary OTD/OTIF measurement unit. The is_otd_target and is_otif_target flags indicate SLA applicability; direct link to the governing SLA commitment enables consignment-level breac',
    `spot_quote_id` BIGINT COMMENT 'Foreign key linking to pricing.spot_quote. Business justification: Quote-to-shipment conversion tracking is a core logistics sales process. When a customer accepts a spot quote and books a shipment, the consignment must reference the originating spot_quote for sales ',
    `transit_time_standard_id` BIGINT COMMENT 'Foreign key linking to route.transit_time_standard. Business justification: At booking, the applicable transit time standard governs committed_delivery_date and SLA targets. SLA compliance reporting and customer promise accuracy analysis require knowing which transit standard',
    `awb_number` STRING COMMENT 'The unique air waybill number assigned to this consignment for air freight shipments. Format: 3-digit airline prefix followed by 8-digit serial number.. Valid values are `^[0-9]{3}-[0-9]{8}$`',
    `bol_number` STRING COMMENT 'The bill of lading number for ocean or ground freight shipments. Serves as the contract of carriage and receipt of goods.',
    `booking_channel` STRING COMMENT 'The channel through which the consignment was booked: web portal, mobile app, API integration, EDI, call center, branch office, or partner system. [ENUM-REF-CANDIDATE: web_portal|mobile_app|api|edi|call_center|branch|partner — 7 candidates stripped; promote to reference product]',
    `booking_date` DATE COMMENT 'The date when the consignment was booked by the customer or shipper.',
    `booking_timestamp` TIMESTAMP COMMENT 'The precise date and time when the consignment booking was created in the system.',
    `chargeable_weight_kg` DECIMAL(18,2) COMMENT 'The weight used for freight charge calculation, which is the greater of declared weight or volumetric weight.',
    `cod_amount` DECIMAL(18,2) COMMENT 'The amount to be collected from the consignee upon delivery if COD service is enabled.',
    `cod_currency_code` STRING COMMENT 'The three-letter ISO currency code for the COD amount.. Valid values are `^[A-Z]{3}$`',
    `committed_delivery_date` DATE COMMENT 'The date by which delivery is committed to the customer per the service level agreement.',
    `committed_delivery_time` TIMESTAMP COMMENT 'The precise date and time by which delivery is committed to the customer per the service level agreement.',
    `commodity_description` STRING COMMENT 'A textual description of the goods or commodities being shipped in this consignment.',
    `consignee_contact_phone` STRING COMMENT 'The contact phone number for the consignee or receiver.',
    `consignee_name` STRING COMMENT 'The full name of the consignee or receiver of the consignment.',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this consignment record was first created in the system.',
    `declared_value_amount` DECIMAL(18,2) COMMENT 'The declared value of the goods in the consignment for insurance and customs purposes.',
    `declared_value_currency_code` STRING COMMENT 'The three-letter ISO currency code for the declared value amount.. Valid values are `^[A-Z]{3}$`',
    `declared_weight_kg` DECIMAL(18,2) COMMENT 'The actual or declared gross weight of the consignment in kilograms as provided by the shipper.',
    `delivery_instruction_type` STRING COMMENT 'The type of special delivery instruction provided by the customer (e.g., signature required, leave at door, call before delivery, safe place).',
    `delivery_time_window_end` TIMESTAMP COMMENT 'The end of the preferred delivery time window specified by the customer or consignee.',
    `delivery_time_window_start` TIMESTAMP COMMENT 'The start of the preferred delivery time window specified by the customer or consignee.',
    `destination_address_line1` STRING COMMENT 'The first line of the delivery or destination address for the consignment.',
    `destination_city` STRING COMMENT 'The city or municipality of the consignment destination location.',
    `destination_country_code` STRING COMMENT 'The three-letter ISO country code for the consignment destination country.. Valid values are `^[A-Z]{3}$`',
    `destination_postal_code` STRING COMMENT 'The postal or ZIP code of the consignment destination location.',
    `hawb_number` STRING COMMENT 'House air waybill number issued by freight forwarders for consolidated shipments under a master air waybill.',
    `hs_code` STRING COMMENT 'The Harmonized System tariff classification code for the primary commodity in the consignment, used for customs and trade compliance.. Valid values are `^[0-9]{6,10}$`',
    `incoterms_code` STRING COMMENT 'The Incoterms code defining the responsibilities, costs, and risks between buyer and seller for this consignment (e.g., EXW, FOB, CIF, DDP, DAP). [ENUM-REF-CANDIDATE: EXW|FCA|CPT|CIP|DAP|DPU|DDP|FAS|FOB|CFR|CIF — 11 candidates stripped; promote to reference product]',
    `is_cod` BOOLEAN COMMENT 'Indicates whether this consignment requires cash on delivery payment collection from the consignee.',
    `is_dangerous_goods` BOOLEAN COMMENT 'Indicates whether the consignment contains dangerous goods or hazardous materials requiring special handling.',
    `is_otd_target` BOOLEAN COMMENT 'Indicates whether this consignment is included in on-time delivery performance measurement and reporting.',
    `is_otif_target` BOOLEAN COMMENT 'Indicates whether this consignment is included in on-time in-full performance measurement and reporting.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'The timestamp when this consignment record was last updated or modified in the system.',
    `lifecycle_status` STRING COMMENT 'Current lifecycle status of the consignment from booking through final delivery or cancellation. [ENUM-REF-CANDIDATE: booked|confirmed|in_transit|out_for_delivery|delivered|cancelled|returned|exception — 8 candidates stripped; promote to reference product]',
    `mawb_number` STRING COMMENT 'Master air waybill number issued by the airline for consolidated shipments containing multiple house air waybills.',
    `number_of_pieces` STRING COMMENT 'The total number of individual pieces, packages, or handling units in the consignment.',
    `origin_address_line1` STRING COMMENT 'The first line of the pickup or origin address for the consignment.',
    `origin_city` STRING COMMENT 'The city or municipality of the consignment origin location.',
    `origin_country_code` STRING COMMENT 'The three-letter ISO country code for the consignment origin country.. Valid values are `^[A-Z]{3}$`',
    `origin_postal_code` STRING COMMENT 'The postal or ZIP code of the consignment origin location.',
    `priority_level` STRING COMMENT 'The priority level assigned to the consignment for operational handling and resource allocation.. Valid values are `standard|high|urgent|critical`',
    `shipper_contact_phone` STRING COMMENT 'The contact phone number for the shipper or sender.',
    `shipper_name` STRING COMMENT 'The full name of the shipper or sender of the consignment.',
    `sla_source` STRING COMMENT 'The source of the service level commitment: customer contract, published rate card, spot booking, or standard terms.. Valid values are `customer_contract|rate_card|spot_booking|standard_terms`',
    `special_handling_notes` STRING COMMENT 'Free-text notes describing any special handling requirements, access instructions, or delivery preferences for the consignment.',
    `transit_time_days` STRING COMMENT 'The committed or expected transit time for the consignment from origin to destination, measured in days.',
    `un_number` STRING COMMENT 'The four-digit UN number identifying the dangerous goods classification if the consignment contains hazardous materials.. Valid values are `^UN[0-9]{4}$`',
    `volume_cbm` DECIMAL(18,2) COMMENT 'The total volume of the consignment measured in cubic meters.',
    `volumetric_weight_kg` DECIMAL(18,2) COMMENT 'The dimensional or volumetric weight calculated based on the consignment dimensions, used for pricing when it exceeds actual weight.',
    CONSTRAINT pk_consignment PRIMARY KEY(`consignment_id`)
) COMMENT 'Core master entity representing a shipment booking/consignment record — the primary business object in the shipment domain. Captures the full lifecycle identity of a shipment from booking through final delivery, including service type (express parcel, freight, cross-border), origin/destination, declared weight, volumetric/DIM weight, CBM, number of pieces, incoterms code, COD flag, DDP/DAP/FOB terms, booking channel, booking date, committed SLA type, committed delivery date, transit time commitment, SLA source (customer contract/rate card/spot booking), priority level, delivery instructions (instruction type, preferred time window, special access notes, safe place, alternative address, contact phone), current lifecycle status, and OTD/OTIF target. Serves as the anchor entity integrating SAP TM freight orders, Oracle TMS shipment execution records, and FourKites visibility events. SSOT for shipment identity and service commitment across the enterprise.';

CREATE OR REPLACE TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` (
    `shipment_leg_id` BIGINT COMMENT 'Unique identifier for the shipment leg. Primary key for this entity representing a single transport segment within a multi-leg shipment journey.',
    `ams_filing_id` BIGINT COMMENT 'Foreign key linking to customs.ams_filing. Business justification: AMS filings are submitted per carrier leg (flight or vessel voyage). shipment_leg carries flight_number and voyage_number. Compliance teams need direct leg→AMS filing linkage to verify CBP hold indica',
    `blocked_space_agreement_id` BIGINT COMMENT 'Foreign key linking to network.blocked_space_agreement. Business justification: Shipment legs booked under a blocked space agreement (BSA) must reference the governing BSA for capacity utilization tracking, minimum commitment monitoring, penalty calculation, and rate application.',
    `booking_id` BIGINT COMMENT 'Foreign key linking to freight.booking. Business justification: Each shipment leg is executed under a carrier booking that confirms space, equipment, and schedule. Booking amendment workflows, space confirmation tracking, and carrier invoice reconciliation require',
    `carrier_agreement_id` BIGINT COMMENT 'Foreign key linking to contract.carrier_agreement. Business justification: Each shipment leg is executed under a specific carrier agreement governing rates, liability caps, SLA, and capacity. Logistics experts require this link for carrier invoice reconciliation, freight aud',
    `carrier_buy_rate_id` BIGINT COMMENT 'Foreign key linking to pricing.carrier_buy_rate. Business justification: Each leg incurs carrier buy costs determined by carrier agreement, mode, lane, and weight. Critical for cost allocation, margin analysis, carrier invoice reconciliation, and profitability reporting at',
    `carrier_id` BIGINT COMMENT 'Foreign key linking to network.carrier. Business justification: Shipment legs are operated by specific carriers - fundamental to transport execution, routing decisions, performance tracking, and carrier invoice reconciliation. Normalizes carrier_scac_code/carrier_',
    `carrier_schedule_id` BIGINT COMMENT 'Foreign key linking to route.carrier_schedule. Business justification: Shipment legs are booked against specific carrier schedules. Schedule adherence KPIs, departure/arrival compliance, and capacity utilization reporting require linking the executed leg to its carrier s',
    `carrier_service_id` BIGINT COMMENT 'Foreign key linking to network.carrier_service. Business justification: Each shipment leg is executed on a specific carrier service (flight, vessel service, truck lane). This drives capacity allocation, booking cutoff enforcement, transit time SLA, and leg-level cost calc',
    `consignment_id` BIGINT COMMENT 'Reference to the parent shipment that this leg belongs to. Links this transport segment to the overall end-to-end shipment journey.',
    `container_unit_id` BIGINT COMMENT 'Foreign key linking to fleet.container_unit. Business justification: A shipment leg uses a specific container unit (ISO, reefer). Linking enables CSC certification compliance checks per leg, container utilization reporting, and damage liability attribution. shipment_le',
    `corridor_leg_id` BIGINT COMMENT 'Foreign key linking to route.corridor_leg. Business justification: A shipment_leg is the physical execution of a corridor_leg. Carrier performance measurement, SLA breach analysis, and network optimization require tracing executed legs back to the planned corridor_le',
    `declaration_id` BIGINT COMMENT 'Foreign key linking to customs.declaration. Business justification: Each shipment leg may require its own customs declaration for transit or transshipment clearance. Operations teams need leg-level declaration traceability for multi-leg international shipments. shipme',
    `agent_id` BIGINT COMMENT 'Reference to the delivery agent or driver assigned to execute this leg. Primarily used for last-mile delivery legs to track individual courier performance.',
    `driver_profile_id` BIGINT COMMENT 'Foreign key linking to fleet.driver_profile. Business justification: Road and last-mile shipment legs are executed by a specific driver. Linking leg to driver_profile enables HOS compliance per leg, driver performance KPIs (OTD rate), and incident investigation. Logist',
    `hold_id` BIGINT COMMENT 'Foreign key linking to customs.hold. Business justification: Customs holds are placed at specific port-of-entry legs, blocking that legs departure or delivery. Port operations teams need direct leg→hold linkage to manage dwell time and SLA breach reporting. Ex',
    `interline_agreement_id` BIGINT COMMENT 'Foreign key linking to network.interline_agreement. Business justification: Shipment legs involving interline carriage are governed by a specific interline agreement that determines prorate rules, liability limits, through-billing, and AWB prefix allocation. This is a fundame',
    `lane_commitment_id` BIGINT COMMENT 'Foreign key linking to contract.lane_commitment. Business justification: Lane commitments define contracted capacity obligations per lane. Each shipment leg must be traceable to the lane commitment for real-time volume utilization tracking, shortfall/surplus measurement, a',
    `lane_id` BIGINT COMMENT 'Foreign key linking to route.lane. Business justification: Each shipment leg executes on a specific network lane defining the origin-destination pair, service level, and routing. Essential for dispatcher lane assignment, lane-level performance measurement, ca',
    `facility_id` BIGINT COMMENT 'Foreign key linking to warehouse.facility. Business justification: Shipment leg departure from a warehouse facility must be linked for dock scheduling, outbound dispatch reporting, and facility-level carrier performance measurement. origin_location_code is generic (c',
    `rate_line_id` BIGINT COMMENT 'Foreign key linking to pricing.rate_line. Business justification: Carrier cost management and margin analysis require linking each shipment leg to the specific rate line used to price it. Operations finance teams track leg-level cost vs. contracted rate lines for pr',
    `rate_schedule_id` BIGINT COMMENT 'Foreign key linking to contract.rate_schedule. Business justification: Freight audit requires verifying that the cost applied to each leg matches the contracted rate schedule. Logistics experts expect leg-level traceability to the rate schedule for billing dispute resolu',
    `tpl_provider_id` BIGINT COMMENT 'Foreign key linking to network.tpl_provider. Business justification: Shipment legs are frequently executed by 3PL providers (outsourced last-mile, cross-dock, linehaul). Linking enables 3PL performance tracking, cost allocation, SLA compliance monitoring, and operation',
    `trip_id` BIGINT COMMENT 'Foreign key linking to fleet.trip. Business justification: Each shipment leg is physically executed as a fleet trip. Dispatchers link legs to trips for driver HOS compliance reporting, fuel cost allocation per leg, and operational reconciliation. A logistics ',
    `actual_arrival_timestamp` TIMESTAMP COMMENT 'Actual date and time when the shipment arrived at the destination location for this leg. Captured from carrier EDI, GPS tracking, or manual gate-in events.',
    `actual_departure_timestamp` TIMESTAMP COMMENT 'Actual date and time when the shipment departed from the origin location for this leg. Captured from carrier EDI, GPS tracking, or manual gate-out events.',
    `carbon_emissions_kg` DECIMAL(18,2) COMMENT 'Estimated carbon dioxide equivalent emissions for this leg measured in kilograms. Calculated based on transport mode, distance, and fuel type for sustainability reporting.',
    `cost_amount` DECIMAL(18,2) COMMENT 'Total cost incurred for this transport leg including carrier charges, fuel surcharges, and accessorial fees. Used for freight cost allocation and profitability analysis.',
    `cost_currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the leg cost amount. Enables multi-currency cost tracking and financial consolidation.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this leg record was first created in the system. Audit field for data lineage and compliance tracking.',
    `customs_clearance_required_flag` BOOLEAN COMMENT 'Indicates whether this leg crosses an international border requiring customs clearance. True for cross-border legs.',
    `delay_duration_minutes` STRING COMMENT 'Total delay time in minutes calculated as the difference between planned and actual timestamps. Used for SLA breach detection and performance reporting.',
    `delay_reason_code` STRING COMMENT 'Standardized code indicating the root cause of any delay on this leg (e.g., weather, traffic, mechanical failure, customs hold). Used for exception management and carrier performance analysis.',
    `delivery_attempt_number` STRING COMMENT 'Count of delivery attempts made for this leg. Increments with each failed delivery attempt. Used for last-mile legs to track delivery success rates and customer availability.',
    `destination_location_code` STRING COMMENT 'Standardized code identifying the arrival location for this leg. May be UN/LOCODE for ports/terminals, IATA code for airports, or internal facility code for warehouses.. Valid values are `^[A-Z]{3,5}$`',
    `dispatch_sequence_number` STRING COMMENT 'Order of this delivery within the drivers daily dispatch route. Used for last-mile legs to optimize delivery sequence and track route adherence.',
    `distance_km` DECIMAL(18,2) COMMENT 'Planned or actual distance traveled for this leg measured in kilometers. Used for cost calculation, carbon footprint estimation, and performance analytics.',
    `equipment_type_code` STRING COMMENT 'Code identifying the type of transport equipment used (e.g., 20ft container, 40ft reefer, flatbed truck, pallet). Follows ISO 6346 for containers or internal classification for other equipment.',
    `eta_prediction_source` STRING COMMENT 'System or method that generated the predicted ETA. Identifies whether the prediction came from FourKites AI engine, carrier EDI feed, manual operator input, TMS route calculation, GPS tracking, or IoT sensor data.. Valid values are `fourkites_ai|carrier_edi|manual_estimate|tms_calculation|gps_tracking|iot_sensor`',
    `flight_number` STRING COMMENT 'Commercial flight number for air freight legs. Combines carrier code and flight number (e.g., AA1234, LH456).. Valid values are `^[A-Z0-9]{2}[0-9]{1,4}[A-Z]?$`',
    `gps_tracking_enabled_flag` BOOLEAN COMMENT 'Indicates whether real-time GPS tracking is active for this leg. True when vehicle/container has active GPS device transmitting location data.',
    `hazmat_flag` BOOLEAN COMMENT 'Indicates whether this leg transports dangerous goods requiring special handling per IMDG Code or ICAO Technical Instructions. True for hazmat shipments.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Date and time when this leg record was last modified. Audit field for change tracking and data quality monitoring.',
    `leg_status` STRING COMMENT 'Current operational status of this transport leg. Tracks the lifecycle state from planning through completion or cancellation.. Valid values are `planned|in_transit|completed|delayed|cancelled|failed`',
    `origin_location_code` STRING COMMENT 'Standardized code identifying the departure location for this leg. May be UN/LOCODE for ports/terminals, IATA code for airports, or internal facility code for warehouses.. Valid values are `^[A-Z]{3,5}$`',
    `planned_arrival_timestamp` TIMESTAMP COMMENT 'Scheduled arrival date and time for this leg as planned at booking or route optimization. Represents the original ETA before any real-time adjustments.',
    `planned_departure_timestamp` TIMESTAMP COMMENT 'Scheduled departure date and time for this leg as planned at booking or route optimization. Represents the original ETD before any real-time adjustments.',
    `predicted_eta_confidence_score` DECIMAL(18,2) COMMENT 'Confidence level of the predicted ETA expressed as a percentage (0.00 to 100.00). Higher scores indicate greater certainty in the prediction based on data quality and model accuracy.',
    `predicted_eta_timestamp` TIMESTAMP COMMENT 'Real-time predicted arrival timestamp generated by AI/ML models or carrier systems. Updated dynamically based on current location, traffic, weather, and historical patterns.',
    `seal_number` STRING COMMENT 'Unique identifier for the security seal applied to the container or trailer. Used for cargo security verification and customs compliance.',
    `sequence_number` STRING COMMENT 'Sequential order of this leg within the shipment journey. Indicates the position in the multi-leg route (e.g., 1 for first-mile pickup, 2 for origin hub, 3 for linehaul, 4 for destination hub, 5 for last-mile delivery).',
    `source_system_code` STRING COMMENT 'Identifier of the operational system that created or last updated this leg record. Indicates data provenance from SAP TM, Oracle TMS, FourKites, carrier EDI, or manual entry.. Valid values are `sap_tm|oracle_tms|fourkites|carrier_edi|manual_entry`',
    `temperature_controlled_flag` BOOLEAN COMMENT 'Indicates whether this leg requires temperature-controlled transport (reefer container, refrigerated truck). True for cold chain shipments.',
    `tracking_number` STRING COMMENT 'Carrier-provided tracking number for real-time shipment visibility on this leg. Used for customer self-service tracking and exception alerts.',
    `transport_mode` STRING COMMENT 'Primary mode of transportation used for this leg. Indicates whether the shipment moves by air, ocean, road, rail, or a combination of modes.. Valid values are `air|ocean|road|rail|multimodal|courier`',
    `vehicle_reference_number` STRING COMMENT 'Identifier for the vehicle, vessel, aircraft, or rail car used for this leg. May be truck license plate, vessel IMO number, aircraft tail number, or rail car number.',
    `voyage_number` STRING COMMENT 'Unique identifier for the ocean vessel voyage. Used for ocean freight legs to track specific sailing schedules.',
    CONSTRAINT pk_shipment_leg PRIMARY KEY(`shipment_leg_id`)
) COMMENT 'Represents an individual transport leg within a multi-leg shipment journey, including ETA/ETD milestone predictions and last-mile dispatch details. Each consignment may traverse multiple legs (e.g., first-mile pickup → origin hub → linehaul → destination hub → last-mile delivery). Captures leg sequence number, transport mode (air/ocean/road/rail), carrier SCAC/IATA code, origin and destination location codes, planned and actual departure/arrival timestamps (ETD/ETA), predicted ETA with confidence score and prediction source (FourKites AI/carrier EDI/manual), vehicle/vessel/flight reference, leg status, distance, delivery agent ID (for last-mile legs), route code, dispatch sequence, and delivery attempt number. Enables end-to-end route visibility, SLA milestone tracking per leg, ETA prediction, and last-mile delivery performance measurement. Sourced from SAP TM route segments, Oracle TMS load plans, and FourKites predictive ETA engine.';

CREATE OR REPLACE TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` (
    `tracking_event_id` BIGINT COMMENT 'Unique identifier for the tracking event record. Primary key. Immutable once assigned.',
    `carrier_id` BIGINT COMMENT 'Foreign key linking to network.carrier. Business justification: Tracking events are reported by specific carriers; proper FK replaces denormalized carrier_code. Enables carrier-level event analysis, on-time scan compliance reporting, exception attribution by carri',
    `consignment_id` BIGINT COMMENT 'Reference to the shipment this tracking event belongs to. Links event to parent shipment entity.',
    `declaration_id` BIGINT COMMENT 'Foreign key linking to customs.declaration. Business justification: Tracking events of type CUSTOMS_CLEARED or CUSTOMS_RELEASED reference a specific declaration. Customs audit trails and customer visibility platforms require event→declaration linkage to surface declar',
    `facility_id` BIGINT COMMENT 'Foreign key linking to warehouse.facility. Business justification: Tracking events (scans, departures, arrivals) occur at warehouse facilities. Facility-level event reporting, dwell time dashboards, and exception management require structured FK to facility. facility',
    `hold_id` BIGINT COMMENT 'Foreign key linking to customs.hold. Business justification: Tracking events of type CUSTOMS_HOLD or CUSTOMS_EXAMINATION directly reference a hold record. Customer service and compliance teams need event→hold linkage to surface hold details from the tracking ti',
    `last_mile_dispatch_id` BIGINT COMMENT 'Foreign key linking to fulfillment.last_mile_dispatch. Business justification: Tracking scan events during last-mile delivery must be linked to the dispatch record for real-time customer notification triggers, SLA breach detection, and dispatch reconciliation reporting. Logistic',
    `network_node_id` BIGINT COMMENT 'Foreign key linking to route.network_node. Business justification: Tracking events are captured at network nodes (hubs, gateways, depots). Hub throughput analysis, dwell time reporting, and network performance dashboards require linking scan events to the node. facil',
    `package_id` BIGINT COMMENT 'Foreign key linking to shipment.shipment_package. Business justification: Tracking events (scans, status updates, damage reports) occur at the individual package/piece level in express and parcel operations. tracking_event currently links to consignment and shipment_leg but',
    `shipment_leg_id` BIGINT COMMENT 'Foreign key linking to shipment.shipment_leg. Business justification: Tracking events occur during specific transport legs of a shipments journey. Adding shipment_leg_id allows precise attribution of scan events to transport segments (e.g., departed origin is end of ',
    `transport_asset_id` BIGINT COMMENT 'Identifier of the vehicle, truck, aircraft, or vessel involved in the event. Used for fleet management and route optimization. Nullable for stationary hub events.',
    `actual_delivery_timestamp` TIMESTAMP COMMENT 'Actual date and time of final delivery to consignee. Only populated for DELIVERED event types. Used for OTD (On-Time Delivery) and OTIF (On-Time In-Full) KPI calculation. Format: yyyy-MM-ddTHH:mm:ss.SSSXXX.',
    `api_transaction_reference` STRING COMMENT 'Unique identifier of the API call or transaction that created this event record. Used for API audit trail and troubleshooting. Nullable for non-API events.',
    `awb_number` STRING COMMENT 'Air waybill number associated with this event, if applicable. Used for air freight shipments. May be MAWB (Master Air Waybill) or HAWB (House Air Waybill).',
    `bol_number` STRING COMMENT 'Bill of lading number associated with this event, if applicable. Used for ocean and ground freight shipments. May be MBL (Master Bill of Lading) or HBL (House Bill of Lading).',
    `container_number` STRING COMMENT 'ISO container number for ocean freight shipments. Format: 4-letter owner code + 6-digit serial number + check digit. Only populated for containerized freight events.',
    `customs_clearance_status` STRING COMMENT 'Status of customs clearance at the time of this event. Only populated for cross-border shipments and customs-related events. Cleared: customs released; Held: under inspection; Rejected: entry denied.. Valid values are `pending|cleared|held|released|rejected`',
    `damage_description` STRING COMMENT 'Free-text description of the damage observed. Only populated when damage_reported = True. Used for claims investigation and root cause analysis.',
    `damage_reported` BOOLEAN COMMENT 'Indicates whether damage to the shipment was observed and reported during this event. True if damage detected, False otherwise. Triggers claims workflow.',
    `edi_message_reference` STRING COMMENT 'Unique identifier of the EDI message that generated this event, if applicable. Used for EDI 214 carrier status messages and event reconciliation.',
    `estimated_delivery_timestamp` TIMESTAMP COMMENT 'Updated ETA (Estimated Time of Arrival) for final delivery, recalculated at the time of this event. Predictive ETA updates from FourKites or carrier systems. Format: yyyy-MM-ddTHH:mm:ss.SSSXXX.',
    `event_category` STRING COMMENT 'High-level classification of the event type. Tracking events are carrier-reported milestones; hub operations are internal facility scans; exceptions are deviations or delays; lifecycle events are status transitions.. Valid values are `tracking|hub_operation|exception|lifecycle`',
    `event_description` STRING COMMENT 'Human-readable narrative description of the event. May include raw event text from carrier or system source. Used for audit trail and customer communication.',
    `event_source` STRING COMMENT 'System or channel that generated the event. Examples: FourKites, carrier EDI feed, Manhattan WMS scan, sortation system, SAP TM, manual entry. Enables event provenance and quality assessment.',
    `event_timestamp` TIMESTAMP COMMENT 'The precise date and time when the tracking event occurred in the real world. Format: yyyy-MM-ddTHH:mm:ss.SSSXXX. This is the business event time, distinct from record creation time.',
    `event_type_code` STRING COMMENT 'Standardized code representing the specific event type. Examples: PICKUP, DEPARTED, ARRIVED, IN_TRANSIT, SORTED, LOADED_OUTBOUND, OUT_FOR_DELIVERY, DELIVERED, EXCEPTION_DELAY, EXCEPTION_DAMAGE, STATUS_CHANGE. Aligns with IATA and carrier EDI standards.',
    `exception_reason_code` STRING COMMENT 'Standardized code indicating the root cause of the exception. Examples: WEATHER_DELAY, CUSTOMS_HOLD, ADDRESS_INCORRECT, DAMAGE_IN_TRANSIT, REFUSED_BY_CONSIGNEE. Only populated for exception events.',
    `exception_resolution_notes` STRING COMMENT 'Free-text notes documenting how the exception was resolved, actions taken, and any follow-up required. Only populated for exception events.',
    `exception_resolution_status` STRING COMMENT 'Current resolution state of the exception. Only populated for exception events. Tracks whether the issue has been addressed.. Valid values are `open|in_progress|resolved|escalated`',
    `exception_resolution_timestamp` TIMESTAMP COMMENT 'Date and time when the exception was resolved. Only populated for exception events that have been closed. Format: yyyy-MM-ddTHH:mm:ss.SSSXXX.',
    `exception_severity` STRING COMMENT 'Severity level of the exception event. Only populated for event_category = exception. Low: minor delay; Medium: moderate delay or documentation issue; High: significant delay or damage; Critical: shipment at risk or lost.. Valid values are `low|medium|high|critical`',
    `gps_latitude` DECIMAL(18,2) COMMENT 'Geographic latitude coordinate of the event location in decimal degrees. Range: -90.0000000 to +90.0000000. Captured from GPS-enabled devices or FourKites real-time tracking.',
    `gps_longitude` DECIMAL(18,2) COMMENT 'Geographic longitude coordinate of the event location in decimal degrees. Range: -180.0000000 to +180.0000000. Captured from GPS-enabled devices or FourKites real-time tracking.',
    `humidity_percentage` DECIMAL(18,2) COMMENT 'Relative humidity percentage recorded at the time of the event. Used for sensitive cargo monitoring. Range: 0.00 to 100.00. Nullable for non-humidity-controlled shipments.',
    `location_city` STRING COMMENT 'City name where the tracking event occurred. Used for customer visibility and geographic analytics.',
    `location_country_code` STRING COMMENT 'Three-letter ISO country code where the event occurred. Examples: USA, CAN, GBR, DEU, CHN.. Valid values are `^[A-Z]{3}$`',
    `location_postal_code` STRING COMMENT 'Postal or ZIP code of the event location. Used for last-mile delivery precision and route optimization.',
    `location_state_province` STRING COMMENT 'State or province code where the event occurred. ISO 3166-2 subdivision code preferred.',
    `new_status` STRING COMMENT 'The shipment status after this lifecycle event. Only populated for event_category = lifecycle. Represents the state transition target.',
    `pieces_count` STRING COMMENT 'Number of pieces, packages, or handling units scanned or processed in this event. Used for piece-level tracking and inventory reconciliation.',
    `pod_image_url` STRING COMMENT 'URL or storage path to the scanned or photographed proof of delivery document. Used for audit and claims resolution.',
    `pod_recipient_name` STRING COMMENT 'Name of the person who received and signed for the shipment. Only populated for delivered events with POD. Personally identifiable information.',
    `pod_signature_captured` BOOLEAN COMMENT 'Indicates whether a physical or electronic signature was captured at delivery. True if signature obtained, False otherwise. Used for delivery verification and dispute resolution.',
    `previous_status` STRING COMMENT 'The shipment status immediately before this lifecycle event. Only populated for event_category = lifecycle. Enables status transition audit trail.',
    `record_created_timestamp` TIMESTAMP COMMENT 'System timestamp when this tracking event record was first inserted into the data platform. Immutable. Format: yyyy-MM-ddTHH:mm:ss.SSSXXX. Distinct from event_timestamp which is the business event time.',
    `record_source_system` STRING COMMENT 'Name of the operational system that originally created this event record. Examples: SAP TM, Oracle TMS, Manhattan WMS, FourKites, carrier EDI gateway. Used for data lineage and quality assessment.',
    `scan_type` STRING COMMENT 'Method used to capture the tracking event. Barcode: handheld or fixed scanner; RFID: radio frequency identification; Manual: keyboard entry; OCR: optical character recognition.. Valid values are `barcode|rfid|manual|ocr`',
    `seal_number` STRING COMMENT 'Security seal number applied to container or trailer. Used for customs compliance and tamper detection. Recorded at sealing and verified at unsealing events.',
    `temperature_celsius` DECIMAL(18,2) COMMENT 'Ambient or cargo temperature recorded at the time of the event, in degrees Celsius. Used for cold chain monitoring and compliance. Nullable for non-temperature-controlled shipments.',
    `weight_kg` DECIMAL(18,2) COMMENT 'Actual or verified weight of the shipment at the time of the event, in kilograms. May differ from booking weight. Used for weight reconciliation and billing adjustments.',
    CONSTRAINT pk_tracking_event PRIMARY KEY(`tracking_event_id`)
) COMMENT 'Immutable, append-only record of any shipment event captured throughout the shipment lifecycle — including carrier-reported tracking milestones, internal hub/sortation operational events, exception/deviation events, and business lifecycle state transitions. Each event records the event category (tracking/hub_operation/exception/lifecycle), event type code (e.g., PICKUP, DEPARTED, ARRIVED, SORTED, LOADED_OUTBOUND, EXCEPTION_DELAY, STATUS_CHANGE), event timestamp, location (facility code, city, country, GPS coordinates), event source (FourKites, carrier EDI, WMS scan, sortation system, TMS), operator ID, severity (for exceptions), resolution fields (for exceptions), previous/new status (for lifecycle transitions), and raw event description. Serves as the unified event log enabling OTD calculation, predictive ETA updates, exception detection, and full shipment audit trail. Never updated after insert.';

CREATE OR REPLACE TABLE `transport_shipping_ecm`.`shipment`.`pod` (
    `pod_id` BIGINT COMMENT 'Unique identifier for the proof of delivery record. Primary key for the POD entity.',
    `cargo_claim_id` BIGINT COMMENT 'Reference to the cargo claim record if a claim was filed related to this delivery. Links POD to claims management process.',
    `carrier_id` BIGINT COMMENT 'Foreign key linking to network.carrier. Business justification: POD is directly attributed to the carrier that performed delivery for carrier performance reporting, claims processing, and OTD measurement. In express delivery operations, carrier-level POD metrics a',
    `consignee_profile_id` BIGINT COMMENT 'Foreign key linking to customer.consignee_profile. Business justification: POD validation requires matching the delivery recipient against the consignee profile for signature verification, dispute resolution, and regulatory compliance. Logistics operations teams directly com',
    `consignment_id` BIGINT COMMENT 'Reference to the shipment for which this proof of delivery was captured. Links POD to the parent shipment transaction.',
    `agent_id` BIGINT COMMENT 'Foreign key linking to network.agent. Business justification: POD is captured by the delivery agent executing final-mile delivery. Linking enables agent-level POD compliance rates, COD collection performance, dispute attribution, and last-mile agent performance ',
    `transport_asset_id` BIGINT COMMENT 'Foreign key linking to fleet.transport_asset. Business justification: Proof of delivery must record which vehicle performed the delivery for driver accountability, vehicle performance tracking, and dispute resolution. Role-prefixed because delivery context is specific. ',
    `fulfillment_order_id` BIGINT COMMENT 'Foreign key linking to fulfillment.fulfillment_order. Business justification: POD is the definitive confirmation that a fulfillment order has been delivered. Merchants require direct POD-to-order linkage for order closure workflows, refund dispute resolution, and merchant SLA r',
    `invoice_id` BIGINT COMMENT 'Foreign key linking to billing.invoice. Business justification: POD-triggered invoicing: proof of delivery is the billing trigger for many logistics service types. Finance teams release or finalize invoices upon POD confirmation. Linking POD to invoice enables aut',
    `last_mile_dispatch_id` BIGINT COMMENT 'Foreign key linking to fulfillment.last_mile_dispatch. Business justification: POD is captured at the conclusion of a last-mile dispatch stop. Linking POD to dispatch enables dispatch reconciliation (PODs captured vs. parcels loaded), driver performance scoring, and ePOD audit t',
    `package_id` BIGINT COMMENT 'Foreign key linking to shipment.shipment_package. Business justification: In parcel and express delivery, POD can be captured at the individual package level — particularly for multi-piece consignments where packages may be delivered separately or where individual package s',
    `payment_id` BIGINT COMMENT 'Foreign key linking to billing.payment. Business justification: COD remittance reconciliation: POD records cash/card collected at delivery (cod_amount, amount_collected). This collected amount must be matched to a payment record in billing for COD remittance recon',
    `route_delivery_zone_id` BIGINT COMMENT 'Foreign key linking to route.route_delivery_zone. Business justification: POD records are captured within a specific delivery zone. Zone-level POD completion rates, COD collection performance by zone, and last-mile SLA reporting require this link. Delivery address fields ar',
    `shipment_leg_id` BIGINT COMMENT 'Foreign key linking to shipment.shipment_leg. Business justification: A POD record captures delivery evidence for a specific transport leg — the final delivery leg of the consignment journey. pod currently references consignment_id but has no shipment_leg_id, making it ',
    `trip_id` BIGINT COMMENT 'Foreign key linking to fleet.trip. Business justification: A proof of delivery is captured at the conclusion of a delivery trip. Linking POD to trip enables trip-level delivery completion reporting, COD cash collection reconciliation per trip, and driver remi',
    `amount_collected` DECIMAL(18,2) COMMENT 'The actual amount collected from the recipient at delivery. May differ from COD amount if partial payment or variance occurred.',
    `awb_number` STRING COMMENT 'Air Waybill number associated with the shipment for which this POD was captured. Links POD to air freight documentation.',
    `bol_number` STRING COMMENT 'Bill of Lading number associated with the shipment for which this POD was captured. Links POD to ocean or ground freight documentation.',
    `cod_amount` DECIMAL(18,2) COMMENT 'The total amount to be collected from the recipient at the time of delivery as per the COD terms. This is the target collection amount agreed upon at shipment booking.',
    `cod_currency` STRING COMMENT 'Three-letter ISO 4217 currency code for the COD amount to be collected.. Valid values are `^[A-Z]{3}$`',
    `collection_timestamp` TIMESTAMP COMMENT 'The exact date and time when the COD payment was collected from the recipient. May differ slightly from delivery timestamp if payment processing occurred after handover.',
    `collection_variance_amount` DECIMAL(18,2) COMMENT 'The difference between the COD amount and the amount collected. Positive value indicates over-collection, negative indicates under-collection or shortfall.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this POD record was first created in the system. Supports audit trail and data lineage tracking.',
    `delivery_address_line1` STRING COMMENT 'First line of the physical address where the delivery was completed. Captures street number and street name.',
    `delivery_address_line2` STRING COMMENT 'Second line of the delivery address. May include apartment number, suite, building name, or other secondary address details.',
    `delivery_city` STRING COMMENT 'City or municipality where the delivery was completed.',
    `delivery_country_code` STRING COMMENT 'Three-letter ISO 3166-1 alpha-3 country code of the delivery location.. Valid values are `^[A-Z]{3}$`',
    `delivery_exception_code` STRING COMMENT 'Standardized code indicating any exception or deviation from normal delivery process noted at the time of delivery (e.g., damaged package, partial delivery, refused).',
    `delivery_latitude` DECIMAL(18,2) COMMENT 'GPS latitude coordinate of the exact delivery location captured by the delivery agents device at the time of delivery.',
    `delivery_longitude` DECIMAL(18,2) COMMENT 'GPS longitude coordinate of the exact delivery location captured by the delivery agents device at the time of delivery.',
    `delivery_notes` STRING COMMENT 'Free-text notes entered by the delivery agent at the time of delivery. May include special instructions followed, access issues, or recipient comments.',
    `delivery_postal_code` STRING COMMENT 'Postal code or ZIP code of the delivery location.',
    `delivery_state_province` STRING COMMENT 'State, province, or region where the delivery was completed.',
    `delivery_timestamp` TIMESTAMP COMMENT 'The exact date and time when the shipment was delivered to the recipient. This is the principal business event timestamp for the POD transaction, distinct from audit timestamps.',
    `delivery_type` STRING COMMENT 'Classification of the delivery method used to complete the shipment handover. Indicates where and how the package was left.. Valid values are `door|reception|locker|neighbor|safe_place|collection_point`',
    `device_code` STRING COMMENT 'Unique identifier of the mobile device or handheld scanner used by the delivery agent to capture the POD. Supports audit trail and device tracking.',
    `dispute_raised_flag` BOOLEAN COMMENT 'Boolean indicator of whether the shipper or recipient has raised a dispute regarding this delivery or COD collection. True indicates an active or historical dispute.',
    `dispute_reason` STRING COMMENT 'Free-text description of the reason for the delivery or COD dispute, if one was raised. Supports claims management and customer service resolution.',
    `document_number` STRING COMMENT 'External business identifier or document number for the POD record. May be printed on physical POD forms or referenced in customer communications.',
    `epod_image_reference` STRING COMMENT 'URI or storage path reference to the digital photograph of the delivered package taken at the delivery location. Supports ePOD standards for visual delivery confirmation.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this POD record was last modified. Supports audit trail and change tracking for POD status updates or dispute resolution.',
    `payment_method` STRING COMMENT 'The payment instrument used by the recipient to settle the COD amount at delivery (e.g., cash, credit card, mobile wallet).. Valid values are `cash|card|digital_wallet|bank_transfer|cheque`',
    `pod_status` STRING COMMENT 'Current lifecycle status of the POD record. Indicates whether the delivery evidence has been accepted by the shipper, is under dispute, or is pending verification.. Valid values are `accepted|disputed|pending|verified|rejected`',
    `recipient_contact_number` STRING COMMENT 'Phone number of the recipient who accepted the delivery. Used for delivery confirmation and follow-up communication.',
    `recipient_email` STRING COMMENT 'Email address of the recipient who accepted the delivery. Used for sending electronic proof of delivery confirmation.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `recipient_id_number` STRING COMMENT 'Identification document number presented by the recipient at delivery. Captured for high-value shipments or regulatory compliance.',
    `recipient_id_type` STRING COMMENT 'Type of identification document presented by the recipient at delivery for high-value or restricted shipments.. Valid values are `national_id|passport|drivers_license|employee_badge|none`',
    `recipient_name` STRING COMMENT 'Full name of the person who received the shipment at the delivery location. This is the identity label for the receiving party.',
    `recipient_signature` STRING COMMENT 'Base64-encoded signature image or reference URI to the signature captured at delivery. Serves as biometric proof of receipt.',
    `remittance_batch_number` STRING COMMENT 'Identifier of the financial batch in which this COD collection was remitted to the shipper. Supports reconciliation and audit of COD settlements.',
    `remittance_date` DATE COMMENT 'The date on which the collected COD amount was remitted to the shipper. Used for financial settlement tracking and Service Level Agreement (SLA) compliance.',
    `remittance_status` STRING COMMENT 'Current status of the COD amount remittance back to the shipper. Tracks the financial settlement lifecycle from collection through to shipper payment.. Valid values are `pending|remitted|reconciled|disputed|failed`',
    `transaction_reference_number` STRING COMMENT 'External payment transaction reference number or receipt number for non-cash COD payments. Links POD to payment gateway or card processor transaction.',
    `variance_reason_code` STRING COMMENT 'Standardized code explaining why the collected amount differs from the COD amount (e.g., partial payment, pricing dispute, damaged goods discount).',
    `verification_timestamp` TIMESTAMP COMMENT 'Timestamp when the POD record was verified or approved by operations or quality control staff.',
    CONSTRAINT pk_pod PRIMARY KEY(`pod_id`)
) COMMENT 'Proof of Delivery (POD / ePOD) record capturing evidence of successful shipment delivery and any Cash on Delivery (COD) collection at the point of delivery. Stores delivery timestamp, recipient name, recipient signature (base64 or reference URI), delivery location coordinates (GPS), delivery type (door/reception/locker/neighbour), ePOD image reference, delivery agent employee ID, device ID used for capture, delivery notes or exceptions noted at delivery, POD status (accepted/disputed/pending), COD amount, COD currency, payment method (cash/card/digital wallet), amount collected, collection timestamp, remittance status, and any variance between COD amount and collected amount. Aligns with ePOD standards and supports COD reconciliation, remittance tracking to shippers, claims management, and financial settlement. SSOT for delivery confirmation evidence and COD collection.';

CREATE OR REPLACE TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` (
    `eta_milestone_id` BIGINT COMMENT 'Unique identifier for the ETA/ETD milestone record. Primary key for the eta_milestone product.',
    `carrier_id` BIGINT COMMENT 'Foreign key linking to network.carrier. Business justification: ETA milestones are predicted and updated by carriers; proper FK replaces denormalized carrier_code. Enables carrier-specific ETA accuracy analysis, prediction model calibration by carrier, and SLA bre',
    `consignment_id` BIGINT COMMENT 'Reference to the parent shipment for which this milestone applies. Links to the shipment product.',
    `declaration_id` BIGINT COMMENT 'Foreign key linking to customs.declaration. Business justification: ETA milestones for customs clearance checkpoints must reference the declaration whose release_date drives the milestones actual_datetime. Clearance-aware ETA prediction models require direct mileston',
    `facility_id` BIGINT COMMENT 'Foreign key linking to warehouse.facility. Business justification: ETA milestones at warehouse facilities (arrived at DC, departed sorting center) require structured facility linkage for facility-level SLA compliance reporting and milestone-based customer notificatio',
    `fulfillment_order_id` BIGINT COMMENT 'Foreign key linking to fulfillment.fulfillment_order. Business justification: ETA milestones drive fulfillment order promised delivery date updates and merchant SLA monitoring. Merchants query ETA milestones by fulfillment order for customer-facing delivery tracking portals. Di',
    `hold_id` BIGINT COMMENT 'Foreign key linking to customs.hold. Business justification: ETA prediction models must factor in active customs hold duration. eta_milestone has customs_clearance_required_flag and customs_clearance_status; when a hold is active, the milestones predicted ETA ',
    `network_node_id` BIGINT COMMENT 'Foreign key linking to route.network_node. Business justification: ETA milestones are recorded at specific network nodes (origin hub, transit hub, destination). Hub dwell analysis, milestone-based visibility reporting, and predictive ETA model training require this l',
    `shipment_leg_id` BIGINT COMMENT 'Foreign key linking to shipment.shipment_leg. Business justification: ETA milestones track predicted arrival times for transport legs. The product already has freight_leg_id (cross-domain FK to freight domain), but shipment_leg is the in-domain leg entity. Adding shipme',
    `sla_commitment_id` BIGINT COMMENT 'Foreign key linking to contract.contract_sla_commitment. Business justification: ETA milestones directly measure on-time delivery performance against specific contractual SLA commitments. This link enables automated SLA breach detection, penalty calculation, and customer performan',
    `sla_entitlement_id` BIGINT COMMENT 'Foreign key linking to customer.sla_entitlement. Business justification: ETA milestones track sla_status and sla_threshold_hours against customer-contracted transit_time_guarantee_days and otd_target_pct from sla_entitlement. Real-time visibility dashboards and OTD reporti',
    `transport_asset_id` BIGINT COMMENT 'Foreign key linking to fleet.transport_asset. Business justification: ETA milestones are predicted using the transport assets real-time telematics (location, speed). Linking enables direct telematics-driven ETA recalculation, asset-level milestone accuracy reporting, a',
    `actual_datetime` TIMESTAMP COMMENT 'The actual recorded datetime when the milestone event occurred (e.g., actual departure, actual arrival). Populated after the event has been confirmed. Null until the event is completed.',
    `created_datetime` TIMESTAMP COMMENT 'Timestamp when this milestone record was first created in the system. Audit field for record lifecycle tracking.',
    `current_predicted_datetime` TIMESTAMP COMMENT 'The most recent predicted ETA or ETD datetime based on real-time tracking, AI/ML models, or carrier updates. This value is continuously updated as new information becomes available.',
    `customs_clearance_required_flag` BOOLEAN COMMENT 'Boolean flag indicating whether customs clearance is required at this milestone location. True = customs clearance required, False = no customs clearance required.',
    `customs_clearance_status` STRING COMMENT 'Current status of customs clearance at this milestone location. NOT_REQUIRED = no customs clearance needed, PENDING = awaiting customs processing, IN_PROGRESS = customs processing underway, CLEARED = customs clearance completed, HELD = shipment held by customs, REJECTED = customs clearance rejected.. Valid values are `NOT_REQUIRED|PENDING|IN_PROGRESS|CLEARED|HELD|REJECTED`',
    `data_quality_score` DECIMAL(18,2) COMMENT 'Quality score (0.00 to 100.00) indicating the completeness and reliability of the data used to generate this milestone prediction. Higher scores indicate better data quality.',
    `delay_reason_code` STRING COMMENT 'Standardized code indicating the primary reason for delay if the milestone is at risk or delayed. WEATHER = adverse weather conditions, TRAFFIC = road/air/sea traffic congestion, CUSTOMS_DELAY = customs clearance delays, MECHANICAL = vehicle/equipment breakdown, CAPACITY = capacity constraints, PORT_CONGESTION = port or terminal congestion, DOCUMENTATION = missing or incorrect documentation, SECURITY = security screening delays, LABOR_STRIKE = labor action or strike, OTHER = other unspecified reasons. [ENUM-REF-CANDIDATE: WEATHER|TRAFFIC|CUSTOMS_DELAY|MECHANICAL|CAPACITY|PORT_CONGESTION|DOCUMENTATION|SECURITY|LABOR_STRIKE|OTHER — 10 candidates stripped; promote to reference product]',
    `delay_reason_description` STRING COMMENT 'Free-text description providing additional detail about the delay reason. Supplements the delay_reason_code with specific context.',
    `distance_remaining_km` DECIMAL(18,2) COMMENT 'Estimated distance remaining in kilometers from current position to the milestone location. Updated in real-time based on GPS tracking data.',
    `exception_flag` BOOLEAN COMMENT 'Boolean flag indicating whether an exception event has been recorded for this milestone. True = exception exists, False = no exception.',
    `exception_type` STRING COMMENT 'Type of exception event if exception_flag is true. DELAY = shipment delay, ROUTE_CHANGE = route deviation, DAMAGE = cargo damage, LOSS = cargo loss or theft, SECURITY_INCIDENT = security breach, DOCUMENTATION_ERROR = documentation issues, NONE = no exception. [ENUM-REF-CANDIDATE: DELAY|ROUTE_CHANGE|DAMAGE|LOSS|SECURITY_INCIDENT|DOCUMENTATION_ERROR|NONE — 7 candidates stripped; promote to reference product]',
    `hazmat_flag` BOOLEAN COMMENT 'Boolean flag indicating whether this shipment contains hazardous materials requiring special handling. True = hazmat shipment, False = non-hazmat shipment.',
    `last_modified_datetime` TIMESTAMP COMMENT 'Timestamp when this milestone record was last modified. Audit field for tracking changes to milestone data.',
    `location_name` STRING COMMENT 'Human-readable name of the milestone location (e.g., Los Angeles International Airport, Port of Rotterdam).',
    `milestone_sequence_number` STRING COMMENT 'Sequential order number of this milestone within the overall shipment journey. Used to track progression through the shipment lifecycle (e.g., 1 = first milestone, 2 = second milestone).',
    `milestone_type` STRING COMMENT 'Type of milestone event in the shipment lifecycle. ETD_ORIGIN = Estimated Time of Departure from origin, ETA_TRANSIT_HUB = Estimated Time of Arrival at transit hub, ETD_TRANSIT_HUB = Estimated Time of Departure from transit hub, ETA_DESTINATION = Estimated Time of Arrival at destination facility, ETA_DELIVERY = Estimated Time of Arrival for final delivery to consignee, ETD_PICKUP = Estimated Time of Departure for pickup from shipper.. Valid values are `ETD_ORIGIN|ETA_TRANSIT_HUB|ETD_TRANSIT_HUB|ETA_DESTINATION|ETA_DELIVERY|ETD_PICKUP`',
    `notification_sent_datetime` TIMESTAMP COMMENT 'Timestamp when the customer notification was sent for this milestone update. Null if no notification has been sent.',
    `notification_sent_flag` BOOLEAN COMMENT 'Boolean flag indicating whether a proactive customer notification has been sent for this milestone update. True = notification sent, False = notification not yet sent.',
    `original_committed_datetime` TIMESTAMP COMMENT 'The original committed ETA or ETD datetime provided at booking or shipment creation. This is the baseline SLA commitment against which performance is measured.',
    `prediction_confidence_score` DECIMAL(18,2) COMMENT 'Confidence score (0.00 to 100.00) indicating the reliability of the current predicted datetime. Higher scores indicate greater confidence based on data quality, historical accuracy, and real-time signal strength.',
    `prediction_last_updated_datetime` TIMESTAMP COMMENT 'Timestamp when the current predicted datetime was last updated. Used to track the freshness of prediction data and trigger re-prediction cycles.',
    `prediction_source` STRING COMMENT 'Source system or method that generated the current predicted datetime. FOURKITES_AI = FourKites predictive analytics engine, CARRIER_EDI = Electronic Data Interchange from carrier, TMS_CALCULATION = Transportation Management System route calculation, MANUAL_OVERRIDE = Manual adjustment by operations team, GPS_TRACKING = Real-time GPS device data, HISTORICAL_AVERAGE = Statistical average based on historical performance.. Valid values are `FOURKITES_AI|CARRIER_EDI|TMS_CALCULATION|MANUAL_OVERRIDE|GPS_TRACKING|HISTORICAL_AVERAGE`',
    `prediction_update_frequency_minutes` STRING COMMENT 'Frequency in minutes at which the prediction is updated for this milestone. Varies based on transport mode, priority, and data availability (e.g., 15 minutes for air, 60 minutes for ocean).',
    `priority_level` STRING COMMENT 'Priority classification for this shipment milestone. STANDARD = normal priority, EXPEDITED = faster than standard, URGENT = high priority requiring special attention, CRITICAL = highest priority requiring immediate action.. Valid values are `STANDARD|EXPEDITED|URGENT|CRITICAL`',
    `sla_status` STRING COMMENT 'Current SLA compliance status for this milestone. ON_TIME = predicted to meet commitment, AT_RISK = potential delay within threshold, DELAYED = predicted or actual breach of commitment, EARLY = predicted or actual early completion.. Valid values are `ON_TIME|AT_RISK|DELAYED|EARLY`',
    `sla_threshold_hours` DECIMAL(18,2) COMMENT 'The acceptable variance threshold in hours for this milestone as defined in the customer SLA. Variance beyond this threshold triggers SLA breach status.',
    `temperature_controlled_flag` BOOLEAN COMMENT 'Boolean flag indicating whether this shipment leg requires temperature-controlled handling. True = temperature control required, False = no temperature control required.',
    `timezone` STRING COMMENT 'IANA timezone identifier for the milestone location (e.g., America/Los_Angeles, Europe/Amsterdam). Used to ensure accurate local time representation.. Valid values are `^[A-Za-z]+/[A-Za-z_]+$`',
    `transport_mode` STRING COMMENT 'Mode of transportation for this milestone leg. AIR = air freight, OCEAN = ocean freight, ROAD = road/truck transport, RAIL = rail transport, INTERMODAL = combination of multiple modes.. Valid values are `AIR|OCEAN|ROAD|RAIL|INTERMODAL`',
    `variance_hours` DECIMAL(18,2) COMMENT 'Variance in hours between the current predicted datetime and the original committed datetime. Positive values indicate delay (late), negative values indicate early arrival/departure. Used for SLA breach prediction and OTIF measurement.',
    `weather_impact_flag` BOOLEAN COMMENT 'Boolean flag indicating whether adverse weather conditions are impacting or predicted to impact this milestone. True = weather impact detected, False = no weather impact.',
    CONSTRAINT pk_eta_milestone PRIMARY KEY(`eta_milestone_id`)
) COMMENT 'Stores planned and predicted ETA/ETD milestone records for each shipment leg and overall consignment. Captures milestone type (ETD_ORIGIN, ETA_TRANSIT_HUB, ETD_TRANSIT_HUB, ETA_DESTINATION, ETA_DELIVERY), original committed datetime, current predicted datetime, prediction source (FourKites AI, carrier EDI, manual override), prediction confidence score, variance in hours from original commitment, and last updated timestamp. Enables SLA breach prediction, proactive customer notification, and OTIF performance measurement. Sourced from FourKites predictive ETA engine.';

CREATE OR REPLACE TABLE `transport_shipping_ecm`.`shipment`.`exception_event` (
    `exception_event_id` BIGINT COMMENT 'Unique identifier for the exception event record. Primary key.',
    `agent_id` BIGINT COMMENT 'Foreign key linking to network.agent. Business justification: Exception events are caused by or assigned to agents (failed delivery attempts, customs agent delays, documentation errors). Linking enables agent-level exception rate tracking, root cause analysis, a',
    `carrier_id` BIGINT COMMENT 'Reference to the carrier responsible for the shipment leg where the exception occurred.',
    `consignment_id` BIGINT COMMENT 'Reference to the shipment that experienced this exception. Links to the shipment master record.',
    `declaration_id` BIGINT COMMENT 'Foreign key linking to customs.declaration. Business justification: Exception events caused by customs rejection, amendment, or re-examination reference a specific declaration. Exception management and root-cause analysis workflows require direct exception→declaration',
    `driver_profile_id` BIGINT COMMENT 'Foreign key linking to fleet.driver_profile. Business justification: Exceptions caused by driver behavior (wrong delivery, HOS violation, accident) must link to the driver for root cause analysis, disciplinary action, and performance management. HR and compliance teams',
    `facility_id` BIGINT COMMENT 'Foreign key linking to warehouse.facility. Business justification: Exception root cause analysis by facility is a standard logistics KPI report. Operations managers need to query all exceptions occurring at a specific warehouse facility. exception_location_code is ge',
    `fulfillment_order_id` BIGINT COMMENT 'Foreign key linking to fulfillment.fulfillment_order. Business justification: Exception events (damage, failed delivery, delay) must be linked to fulfillment orders for merchant SLA breach reporting, customer compensation workflows, and order exception dashboards. Merchants nee',
    `hold_id` BIGINT COMMENT 'Foreign key linking to customs.hold. Business justification: Customs holds are a primary cause of exception events. Exception management workflows require direct hold→exception linkage to calculate financial impact, SLA breach attribution, and resolution action',
    `last_mile_dispatch_id` BIGINT COMMENT 'Foreign key linking to fulfillment.last_mile_dispatch. Business justification: Last-mile exceptions (access denied, failed delivery, vehicle breakdown) must be linked to the specific dispatch run for driver performance management, dispatch exception rate KPIs, and root-cause ana',
    `network_event_id` BIGINT COMMENT 'Foreign key linking to network.network_event. Business justification: Shipment exceptions are causally triggered by network disruption events (port strikes, weather, carrier groundings). Linking enables bulk exception management during network events, root cause reporti',
    `network_node_id` BIGINT COMMENT 'Foreign key linking to route.network_node. Business justification: Exceptions occur at specific network nodes. Hub-level exception rate reporting, node performance scorecards, and root cause analysis by facility require this link. exception_location_code is a denorma',
    `penalty_clause_id` BIGINT COMMENT 'Foreign key linking to contract.penalty_clause. Business justification: When an exception event triggers a contractual penalty, the applicable penalty clause must be directly referenced for automated penalty calculation, dispute management, and financial impact assessment',
    `shipment_leg_id` BIGINT COMMENT 'Foreign key linking to shipment.shipment_leg. Business justification: Exceptions occur during specific transport legs (e.g., flight delayed is leg 2 air segment, customs hold is leg 3 cross-border segment). Adding shipment_leg_id enables leg-level exception analytic',
    `sla_commitment_id` BIGINT COMMENT 'Foreign key linking to contract.contract_sla_commitment. Business justification: Exception events (delays, damage, missed pickups) must be evaluated against the specific SLA commitment they breach to trigger penalty events and customer notifications. Logistics experts expect direc',
    `sla_entitlement_id` BIGINT COMMENT 'Foreign key linking to customer.sla_entitlement. Business justification: Exception events with sla_breach_flag and sla_breach_type must reference the specific SLA entitlement breached to calculate penalty_rate_pct, trigger escalation, and generate SLA breach reports. Logis',
    `transport_asset_id` BIGINT COMMENT 'Foreign key linking to fleet.transport_asset. Business justification: Exceptions (breakdowns, delays, damage) are tied to the transport asset involved. Linking enables asset reliability reporting, maintenance trigger analysis from exception patterns, and insurance claim',
    `assigned_to_team` STRING COMMENT 'Name or code of the operational team responsible for handling this exception event.',
    `claim_eligible_flag` BOOLEAN COMMENT 'Indicator of whether this exception event qualifies for a cargo claim or insurance claim filing.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this exception event record was first created in the system.',
    `customer_notification_channel` STRING COMMENT 'Communication channel used to notify the customer about the exception event.. Valid values are `EMAIL|SMS|PHONE|PORTAL|API|EDI`',
    `customer_notification_sent_flag` BOOLEAN COMMENT 'Indicator of whether the customer has been notified about this exception event.',
    `customer_notification_timestamp` TIMESTAMP COMMENT 'Date and time when the customer was notified about the exception event.',
    `delay_duration_hours` DECIMAL(18,2) COMMENT 'Total duration of delay caused by this exception, measured in hours, used for performance reporting and claims calculation.',
    `escalation_flag` BOOLEAN COMMENT 'Indicator of whether this exception has been escalated to higher management or specialized teams for resolution.',
    `escalation_tier` STRING COMMENT 'Level of escalation indicating the organizational tier handling the exception resolution.. Valid values are `TIER_1|TIER_2|TIER_3|EXECUTIVE`',
    `escalation_timestamp` TIMESTAMP COMMENT 'Date and time when the exception was escalated to a higher tier or specialized team.',
    `estimated_recovery_timestamp` TIMESTAMP COMMENT 'Projected date and time when the shipment is expected to return to normal schedule after exception resolution.',
    `exception_location_country_code` STRING COMMENT 'Three-letter ISO country code for the location where the exception occurred.. Valid values are `^[A-Z]{3}$`',
    `exception_location_name` STRING COMMENT 'Human-readable name of the location where the exception occurred.',
    `exception_notes` STRING COMMENT 'Free-text field for operational notes, observations, and additional context about the exception event and its resolution.',
    `exception_number` STRING COMMENT 'Business-facing unique identifier for the exception event, used for tracking and communication with stakeholders.',
    `exception_raised_timestamp` TIMESTAMP COMMENT 'Date and time when the exception was first detected and recorded in the system. Primary business event timestamp for this transaction.',
    `exception_status` STRING COMMENT 'Current lifecycle status of the exception event indicating whether it is active, being worked on, or resolved.. Valid values are `OPEN|IN_PROGRESS|RESOLVED|CLOSED|ESCALATED|CANCELLED`',
    `exception_type` STRING COMMENT 'Classification of the exception event indicating the nature of the deviation from planned shipment execution. [ENUM-REF-CANDIDATE: DELAY|DAMAGE|LOST|CUSTOMS_HOLD|ADDRESS_ISSUE|WEATHER|MECHANICAL|REFUSED_DELIVERY|ATTEMPTED_DELIVERY|DOCUMENTATION_ISSUE|SECURITY_HOLD — 11 candidates stripped; promote to reference product]',
    `financial_impact_amount` DECIMAL(18,2) COMMENT 'Estimated or actual financial impact of the exception in the shipment currency, including potential claims, penalties, or recovery costs.',
    `financial_impact_currency_code` STRING COMMENT 'Three-letter ISO currency code for the financial impact amount.. Valid values are `^[A-Z]{3}$`',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Date and time when this exception event record was last updated in the system.',
    `preventable_flag` BOOLEAN COMMENT 'Indicator of whether this exception could have been prevented through better planning, execution, or controls, used for continuous improvement analysis.',
    `recurrence_flag` BOOLEAN COMMENT 'Indicator of whether this exception is a repeat occurrence for the same shipment or route, signaling systemic issues.',
    `resolution_action_code` STRING COMMENT 'Standardized code identifying the corrective action taken to resolve the exception.',
    `resolution_action_description` STRING COMMENT 'Detailed narrative of the actions taken to resolve the exception and restore normal shipment flow.',
    `resolution_timestamp` TIMESTAMP COMMENT 'Date and time when the exception was successfully resolved and the shipment returned to normal execution.',
    `responsible_party` STRING COMMENT 'Entity or stakeholder determined to be responsible for the exception occurrence, used for accountability and claims processing. [ENUM-REF-CANDIDATE: CARRIER|SHIPPER|CONSIGNEE|CUSTOMS|WAREHOUSE|THIRD_PARTY|INTERNAL — 7 candidates stripped; promote to reference product]',
    `root_cause_code` STRING COMMENT 'Standardized code identifying the underlying cause of the exception, used for analytics and process improvement.',
    `root_cause_description` STRING COMMENT 'Detailed explanation of the root cause analysis findings for this exception event.',
    `severity_level` STRING COMMENT 'Business impact severity of the exception, used for prioritization and escalation decisions.. Valid values are `CRITICAL|HIGH|MEDIUM|LOW`',
    `sla_breach_flag` BOOLEAN COMMENT 'Indicator of whether this exception caused a breach of the committed service level agreement with the customer.',
    `sla_breach_type` STRING COMMENT 'Classification of the type of SLA commitment that was breached due to this exception.. Valid values are `DELIVERY_TIME|PICKUP_TIME|TRANSIT_TIME|NOTIFICATION|NONE`',
    `source_system` STRING COMMENT 'System or platform that originated the exception event record.. Valid values are `FOURKITES|ORACLE_TMS|SAP_TM|CARRIER_API|MANUAL`',
    `source_system_reference_code` STRING COMMENT 'Unique identifier of this exception event in the originating source system, used for data lineage and reconciliation.',
    CONSTRAINT pk_exception_event PRIMARY KEY(`exception_event_id`)
) COMMENT 'Operational exception record raised during shipment execution when a deviation from the planned journey occurs. Captures exception type (DELAY, DAMAGE, LOST, CUSTOMS_HOLD, ADDRESS_ISSUE, WEATHER, MECHANICAL, REFUSED_DELIVERY, ATTEMPTED_DELIVERY), severity level, exception raised timestamp, location at time of exception, root cause code, responsible party (carrier/shipper/consignee/customs), resolution action taken, resolution timestamp, and escalation flag. Sourced from FourKites exception management module and Oracle TMS exception workflows. Feeds into claims and SLA breach reporting.';

CREATE OR REPLACE TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` (
    `consignment_status_id` BIGINT COMMENT 'Unique identifier for the consignment status transition record. Primary key for the consignment status history table.',
    `carrier_id` BIGINT COMMENT 'Reference to the carrier or transportation provider responsible for the consignment at the time of this status transition. Relevant for carrier-driven status updates.',
    `consignment_id` BIGINT COMMENT 'Reference to the parent consignment whose status is being tracked. Links this status transition to the shipment consignment entity.',
    `declaration_id` BIGINT COMMENT 'Foreign key linking to customs.declaration. Business justification: Consignment status milestones for customs clearance (customs_cleared_flag, customs_reference_number) must reference the specific declaration that drove the clearance event. Operations dashboards and r',
    `driver_profile_id` BIGINT COMMENT 'Foreign key linking to fleet.driver_profile. Business justification: Status events like out for delivery and delivery attempted are driver-triggered scan events. Linking to driver_profile enables driver-level OTD KPIs, delivery attempt accountability, and performan',
    `facility_id` BIGINT COMMENT 'Reference to the warehouse, hub, or facility location where the status transition occurred. Captures the physical location context of the lifecycle event.',
    `fulfillment_order_id` BIGINT COMMENT 'Foreign key linking to fulfillment.fulfillment_order. Business justification: Consignment status transitions (out-for-delivery, delivered, failed) drive fulfillment order status updates. Merchant order management systems subscribe to consignment status events filtered by fulfil',
    `network_node_id` BIGINT COMMENT 'Foreign key linking to route.network_node. Business justification: Status scan events occur at network nodes (carrier hubs, ports, gateways) beyond warehouse facilities. Node-level throughput and dwell time reporting require this link. facility_id covers warehouse fa',
    `shipment_leg_id` BIGINT COMMENT 'Foreign key linking to shipment.shipment_leg. Business justification: Status transitions can be leg-specific (e.g., departed origin marks end of leg 1, arrived at hub marks end of leg 2) or consignment-level (e.g., booking confirmed, delivered). Adding shipment_',
    `transport_asset_id` BIGINT COMMENT 'Foreign key linking to fleet.transport_asset. Business justification: Consignment status updates (in-transit, out-for-delivery) are generated by the transport asset carrying the shipment. Linking enables asset-level status audit trails, geofence-triggered status automat',
    `customs_cleared_flag` BOOLEAN COMMENT 'Boolean indicator of whether customs clearance was completed at this status transition. Relevant for cross-border shipments and international freight.',
    `delay_duration_minutes` STRING COMMENT 'The duration in minutes by which the actual status transition was delayed compared to the planned timestamp. Positive values indicate delay, negative values indicate early arrival.',
    `device_code` STRING COMMENT 'Identifier of the mobile device, scanner, or IoT sensor that captured or triggered the status transition. Used for device tracking and audit trail purposes.',
    `dwell_time_minutes` STRING COMMENT 'The duration in minutes that the consignment remained in the previous status before this transition. Measures processing time and identifies bottlenecks in the supply chain.',
    `eta_updated_flag` BOOLEAN COMMENT 'Boolean indicator of whether the estimated time of arrival was recalculated or updated as a result of this status transition. Used to track predictive ETA accuracy.',
    `exception_flag` BOOLEAN COMMENT 'Boolean indicator of whether this status transition represents an exception or deviation from the normal consignment flow. True for exception events, false for standard lifecycle progression.',
    `external_reference_code` STRING COMMENT 'The unique identifier for this status transition in the source system or carrier system. Used for cross-system reconciliation and EDI message correlation.',
    `geolocation_latitude` DECIMAL(18,2) COMMENT 'The geographic latitude coordinate where the status transition occurred, captured from GPS or RFID tracking systems. Enables spatial analysis of consignment movements.',
    `geolocation_longitude` DECIMAL(18,2) COMMENT 'The geographic longitude coordinate where the status transition occurred, captured from GPS or RFID tracking systems. Enables spatial analysis of consignment movements.',
    `humidity_percentage` DECIMAL(18,2) COMMENT 'The relative humidity percentage recorded at the time of the status transition. Relevant for sensitive cargo requiring environmental monitoring.',
    `milestone_code` STRING COMMENT 'Standardized milestone code representing the key checkpoint in the consignment lifecycle. Used for ETA/ETD tracking and SLA milestone compliance reporting. [ENUM-REF-CANDIDATE: BOOKING|PICKUP|ORIGIN_HUB|IN_TRANSIT|DESTINATION_HUB|OUT_FOR_DELIVERY|DELIVERED|POD — 8 candidates stripped; promote to reference product]',
    `new_eta_timestamp` TIMESTAMP COMMENT 'The updated estimated time of arrival calculated at this status transition. Reflects the latest predictive delivery time based on current consignment progress.',
    `new_status_code` STRING COMMENT 'The lifecycle status code of the consignment after this transition. Represents the current state following the status change event. [ENUM-REF-CANDIDATE: BOOKED|PICKED_UP|IN_TRANSIT|AT_HUB|OUT_FOR_DELIVERY|DELIVERED|EXCEPTION|CANCELLED|RETURNED|ON_HOLD — 10 candidates stripped; promote to reference product]',
    `notification_channel` STRING COMMENT 'The communication channel used to notify the customer or stakeholder about this status transition. Null if no notification was sent.. Valid values are `EMAIL|SMS|PUSH|PORTAL|NONE`',
    `notification_sent_flag` BOOLEAN COMMENT 'Boolean indicator of whether a customer notification (email, SMS, push) was sent for this status transition. Used to track communication compliance and customer experience.',
    `photo_captured_flag` BOOLEAN COMMENT 'Boolean indicator of whether a photo was captured as proof of delivery or condition at this status transition. Used for ePOD and claims evidence.',
    `planned_timestamp` TIMESTAMP COMMENT 'The originally planned or scheduled date and time for this status transition to occur. Used to measure on-time performance by comparing against actual status_transition_timestamp.',
    `previous_status_code` STRING COMMENT 'The lifecycle status code of the consignment immediately before this transition. Represents the prior state in the consignment workflow. [ENUM-REF-CANDIDATE: BOOKED|PICKED_UP|IN_TRANSIT|AT_HUB|OUT_FOR_DELIVERY|DELIVERED|EXCEPTION|CANCELLED|RETURNED|ON_HOLD — 10 candidates stripped; promote to reference product]',
    `record_created_timestamp` TIMESTAMP COMMENT 'The date and time when this status transition record was first created in the data platform. Represents the system audit timestamp for data lineage and compliance.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'The date and time when this status transition record was last modified in the data platform. Tracks the most recent change for audit trail and data quality monitoring.',
    `route_deviation_flag` BOOLEAN COMMENT 'Boolean indicator of whether the consignment deviated from the planned route at this status transition. Used for exception management and route optimization analysis.',
    `scan_type` STRING COMMENT 'The method or technology used to capture the status transition event. Indicates whether the update was via barcode scan, RFID read, manual entry, GPS tracking, or API integration.. Valid values are `BARCODE|RFID|MANUAL|GPS|API`',
    `signature_captured_flag` BOOLEAN COMMENT 'Boolean indicator of whether an electronic proof of delivery signature was captured at this status transition. Typically true for DELIVERED status transitions.',
    `sla_breach_flag` BOOLEAN COMMENT 'Boolean indicator of whether this status transition resulted in or indicates a breach of the committed service level agreement. Used for SLA compliance tracking and dispute resolution.',
    `source_system_code` STRING COMMENT 'The operational system of record that originated this status transition record. Identifies the authoritative source for data lineage and reconciliation purposes.. Valid values are `SAP_TM|ORACLE_TMS|MANHATTAN_WMS|FOURKITES|CARRIER_EDI|MOBILE_APP`',
    `status_notes` STRING COMMENT 'Free-text notes or comments providing additional context about the status transition. May include operator remarks, exception details, or customer instructions.',
    `status_reason_code` STRING COMMENT 'Standardized code indicating the reason or cause for the status transition. Provides context for why the consignment moved to the new status, especially for exceptions. [ENUM-REF-CANDIDATE: NORMAL_FLOW|CUSTOMER_REQUEST|EXCEPTION_DELAY|WEATHER|CUSTOMS_HOLD|ADDRESS_CORRECTION|DAMAGED|REFUSED|SECURITY_HOLD — 9 candidates stripped; promote to reference product]',
    `status_transition_timestamp` TIMESTAMP COMMENT 'The precise date and time when the consignment status changed from the previous status to the new status. Represents the real-world business event time of the lifecycle transition.',
    `temperature_celsius` DECIMAL(18,2) COMMENT 'The ambient or cargo temperature in degrees Celsius recorded at the time of the status transition. Relevant for temperature-controlled shipments and cold chain compliance.',
    `triggered_by_source` STRING COMMENT 'The originating system or channel that initiated the status transition. Identifies whether the change was automated (system/EDI), manual (user), or via integration (API/WMS).. Valid values are `SYSTEM|USER|CARRIER_EDI|API|MOBILE_APP|WMS`',
    CONSTRAINT pk_consignment_status PRIMARY KEY(`consignment_status_id`)
) COMMENT 'Lifecycle status history table tracking every status transition of a consignment from booking through delivery. Each record captures the previous status, new status, transition timestamp, triggered-by source (system/user/carrier EDI), operator ID, and any status notes. Provides a complete audit trail of the consignment lifecycle enabling SLA compliance analysis, dispute resolution, and operational reporting. Distinct from tracking_event which captures carrier scan events — this table captures business-level lifecycle state transitions.';

CREATE OR REPLACE TABLE `transport_shipping_ecm`.`shipment`.`package` (
    `package_id` BIGINT COMMENT 'Unique identifier for the individual package or piece within a consignment. Primary key for the shipment package entity.',
    `cargo_id` BIGINT COMMENT 'Foreign key linking to freight.cargo. Business justification: A shipment package maps to a cargo record describing commodity, dangerous goods classification, and customs valuation. Linking enables package-level dangerous goods compliance verification, customs va',
    `consignment_id` BIGINT COMMENT 'Reference to the parent shipment or consignment that this package belongs to. Links the package to its master shipment record.',
    `container_unit_id` BIGINT COMMENT 'Foreign key linking to fleet.container_unit. Business justification: Packages are loaded into specific container units for sea/air freight legs. Linking enables container utilization reporting, dangerous goods compliance per container, temperature range validation for ',
    `dim_weight_rule_id` BIGINT COMMENT 'Foreign key linking to pricing.dim_weight_rule. Business justification: Parcel-level chargeable weight billing requires linking each package to the dim weight rule applied. Package-level billing disputes (chargeable_weight_kg vs. actual_weight_kg vs. volumetric_weight_kg)',
    `handling_unit_id` BIGINT COMMENT 'Foreign key linking to warehouse.handling_unit. Business justification: Packages are consolidated into handling units (pallets, cartons) in warehouse operations. Linking shipment_package to handling_unit enables pick-and-pack traceability, load planning, and POD verificat',
    `pack_task_id` BIGINT COMMENT 'Foreign key linking to fulfillment.pack_task. Business justification: A shipment package is the physical output of a warehouse pack task. Linking them enables quality traceability (which station packed this package), exception root-cause analysis (was damage caused at p',
    `parcel_id` BIGINT COMMENT 'Foreign key linking to fulfillment.parcel. Business justification: shipment_package (shipment domain) and parcel (fulfillment domain) represent the same physical item from different domain perspectives. Cross-domain reconciliation for billing weight discrepancies, ca',
    `shipment_leg_id` BIGINT COMMENT 'Foreign key linking to shipment.shipment_leg. Business justification: Individual packages within a consignment are loaded onto specific transport legs — particularly relevant when packages within the same consignment are split across different legs (e.g., partial loads,',
    `storage_location_id` BIGINT COMMENT 'Foreign key linking to warehouse.storage_location. Business justification: When packages are held in a warehouse, knowing the precise storage location is required for retrieval, exception resolution, and inventory reconciliation. current_location_code and last_scan_location_',
    `transport_asset_id` BIGINT COMMENT 'Foreign key linking to fleet.transport_asset. Business justification: Individual packages are scanned onto specific vehicles during sortation and last-mile dispatch. Linking enables package-level chain of custody per asset, temperature excursion tracking for reefer comp',
    `actual_delivery_timestamp` TIMESTAMP COMMENT 'Date and time when the package was successfully delivered to the consignee. Used for proof of delivery (POD) and on-time delivery (OTD) performance measurement.',
    `actual_weight_kg` DECIMAL(18,2) COMMENT 'Physical gross weight of the package measured in kilograms. Used for freight charge calculation, load planning, and carrier capacity management.',
    `barcode_number` STRING COMMENT 'Unique barcode or label number assigned to the package for scanning and tracking throughout the logistics network. Used for piece-level visibility and warehouse operations.',
    `chargeable_weight_kg` DECIMAL(18,2) COMMENT 'The greater of actual weight or volumetric weight, used as the basis for freight charge calculation. Determines the billable weight for rating and invoicing.',
    `contents_description` STRING COMMENT 'Textual description of the declared contents within the package. Used for customs declarations, dangerous goods screening, and handling instructions.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this package record was first created in the system. Used for audit trail and data lineage tracking.',
    `current_location_code` STRING COMMENT 'Code identifying the current physical location of the package (warehouse, hub, terminal, or in-transit vehicle). Updated by scan events for real-time visibility.',
    `dangerous_goods_flag` BOOLEAN COMMENT 'Indicates whether the package contains dangerous goods (DG) requiring special handling, labeling, and regulatory compliance per IMDG or IATA DG regulations.',
    `declared_value_amount` DECIMAL(18,2) COMMENT 'Monetary value declared by the shipper for the package contents. Used for insurance coverage, customs valuation, and liability limits.',
    `declared_value_currency` STRING COMMENT 'Three-letter ISO 4217 currency code for the declared value amount. Enables multi-currency valuation and customs reporting.',
    `delivery_signature_name` STRING COMMENT 'Name of the person who signed for the package upon delivery. Part of electronic proof of delivery (ePOD) record.',
    `estimated_delivery_date` DATE COMMENT 'Predicted date when the package will be delivered to the final consignee. Used for customer notifications and SLA monitoring.',
    `exception_code` STRING COMMENT 'Standardized code identifying the type of exception or delay affecting the package (e.g., address incorrect, recipient unavailable, customs hold). Used for exception management and root cause analysis.',
    `exception_description` STRING COMMENT 'Detailed textual description of the exception or issue affecting the package. Provides context for customer service and operations teams.',
    `fragile_flag` BOOLEAN COMMENT 'Indicates whether the package contains fragile items requiring special handling care. Triggers warehouse handling instructions and carrier notifications.',
    `height_cm` DECIMAL(18,2) COMMENT 'Height dimension of the package in centimeters. Used for volumetric weight calculation, load optimization, and warehouse space planning.',
    `hs_code` STRING COMMENT 'Harmonized System tariff classification code for the package contents. Used for customs clearance, duty calculation, and trade compliance reporting.',
    `insurance_amount` DECIMAL(18,2) COMMENT 'Monetary amount of insurance coverage purchased for the package. Used for claims processing and liability determination.',
    `insurance_currency` STRING COMMENT 'Three-letter ISO 4217 currency code for the insurance coverage amount.',
    `insurance_required_flag` BOOLEAN COMMENT 'Indicates whether the shipper has purchased additional insurance coverage for this package beyond standard carrier liability limits.',
    `last_scan_location_code` STRING COMMENT 'Location code where the most recent scan event occurred. Used for tracking history and route verification.',
    `last_scan_timestamp` TIMESTAMP COMMENT 'Date and time of the most recent barcode scan event for this package. Provides real-time tracking visibility and exception detection.',
    `length_cm` DECIMAL(18,2) COMMENT 'Length dimension of the package in centimeters. Used for volumetric weight calculation, load optimization, and warehouse space planning.',
    `max_stack_weight_kg` DECIMAL(18,2) COMMENT 'Maximum weight in kilograms that can be stacked on top of this package without causing damage. Used for warehouse stacking rules and load optimization.',
    `package_status` STRING COMMENT 'Current lifecycle status of the package in the logistics network. Tracks the package from booking through final delivery or exception resolution. [ENUM-REF-CANDIDATE: booked|picked_up|in_transit|at_hub|out_for_delivery|delivered|exception|returned|damaged|lost — 10 candidates stripped; promote to reference product]',
    `package_type` STRING COMMENT 'Classification of the physical packaging unit. Determines handling requirements, stacking rules, and warehouse slotting strategies. [ENUM-REF-CANDIDATE: carton|pallet|drum|envelope|crate|box|bag|bundle|container|skid — 10 candidates stripped; promote to reference product]',
    `pod_image_url` STRING COMMENT 'URL reference to the stored proof of delivery image (signature, photo, or scan). Used for delivery verification and dispute resolution.',
    `sequence_number` STRING COMMENT 'Sequential position of this package within the parent consignment (e.g., package 1 of 5). Used for piece count verification and delivery confirmation.',
    `source_system` STRING COMMENT 'Identifies the operational system of record that originated this package data (Manhattan WMS for warehouse scans, Oracle TMS for load manifests, FourKites for tracking updates). Used for data lineage and reconciliation.. Valid values are `manhattan_wms|oracle_tms|sap_tm|fourkites|manual_entry`',
    `special_handling_instructions` STRING COMMENT 'Free-text field for additional handling instructions specific to this package (e.g., This Side Up, Keep Dry, Handle with Care). Used by warehouse and delivery personnel.',
    `stackable_flag` BOOLEAN COMMENT 'Indicates whether the package can be stacked with other packages during storage and transportation. Affects warehouse slotting and load planning.',
    `temperature_controlled_flag` BOOLEAN COMMENT 'Indicates whether the package requires temperature-controlled transportation and storage (e.g., pharmaceuticals, perishables). Determines equipment assignment and routing.',
    `temperature_range_max_c` DECIMAL(18,2) COMMENT 'Maximum acceptable temperature in Celsius for temperature-sensitive packages. Used for cold chain monitoring and compliance verification.',
    `temperature_range_min_c` DECIMAL(18,2) COMMENT 'Minimum acceptable temperature in Celsius for temperature-sensitive packages. Used for cold chain monitoring and compliance verification.',
    `un_number` STRING COMMENT 'Four-digit UN identification number for dangerous goods classification. Required for DG shipments to identify hazardous materials and handling requirements.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when this package record was last modified. Used for audit trail and change tracking.',
    `volume_cbm` DECIMAL(18,2) COMMENT 'Total cubic volume of the package in cubic meters (CBM). Calculated from length × width × height. Used for container load planning and warehouse capacity management.',
    `volumetric_weight_kg` DECIMAL(18,2) COMMENT 'Dimensional weight (DIM weight) calculated from package dimensions using carrier-specific conversion factors (typically length × width × height / divisor). Used for billing reconciliation when volumetric weight exceeds actual weight.',
    `width_cm` DECIMAL(18,2) COMMENT 'Width dimension of the package in centimeters. Used for volumetric weight calculation, load optimization, and warehouse space planning.',
    CONSTRAINT pk_package PRIMARY KEY(`package_id`)
) COMMENT 'Individual package/piece-level master record within a consignment. Captures package sequence number within the consignment, barcode/label number, package type (carton, pallet, drum, envelope, crate), actual weight, volumetric weight (DIM weight), dimensions (L×W×H in cm), declared contents description, fragile flag, temperature-sensitive flag, and current package status. Enables piece-level tracking, DIM weight billing reconciliation, and warehouse handling instructions. Sourced from Manhattan WMS scan data and Oracle TMS load manifests.';

CREATE OR REPLACE TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` (
    `shipment_carrier_assignment_id` BIGINT COMMENT 'Unique identifier for the shipment carrier assignment record. Primary key.',
    `agent_id` BIGINT COMMENT 'Foreign key linking to network.agent. Business justification: Freight forwarding agents book and coordinate carrier assignments on behalf of shippers - critical for commission calculation, agent performance tracking, and multi-modal coordination in forwarding op',
    `agreement_id` BIGINT COMMENT 'Reference to the carrier contract under which this assignment was made, if applicable.',
    `booking_id` BIGINT COMMENT 'Foreign key linking to freight.booking. Business justification: A shipment carrier assignment is executed under a freight booking that provides confirmed space and contracted rates. Carrier assignment workflows reference the booking for confirmation numbers and ra',
    `carrier_agreement_id` BIGINT COMMENT 'Foreign key linking to contract.carrier_agreement. Business justification: The existing agreement_id on shipment_carrier_assignment references the customer agreement; the carrier_agreement is a distinct carrier-facing contract governing rates, liability, and SLA for this ass',
    `carrier_buy_rate_id` BIGINT COMMENT 'Foreign key linking to pricing.carrier_buy_rate. Business justification: Carrier cost validation and procurement audit require linking each carrier assignment to the contracted buy rate. The existing rate_amount plain attribute is a denormalized copy; a FK to carrier_buy_r',
    `carrier_id` BIGINT COMMENT 'Reference to the carrier (airline, ocean carrier, road haulier, rail operator) assigned to transport this shipment leg.',
    `carrier_payable_id` BIGINT COMMENT 'Foreign key linking to billing.carrier_payable. Business justification: Carrier cost allocation: when a carrier is assigned to a shipment, a payable is generated for that service. Procurement and AP teams link carrier assignments to payables to validate that contracted ra',
    `carrier_schedule_id` BIGINT COMMENT 'Foreign key linking to route.carrier_schedule. Business justification: Carrier assignments book capacity on specific carrier schedules. Schedule utilization reporting, booking compliance, and capacity vs. actual analysis require this link. flight_number and voyage_number',
    `carrier_service_id` BIGINT COMMENT 'Foreign key linking to network.carrier_service. Business justification: Carrier assignment must reference the specific carrier service for booking confirmation, capacity allocation validation, documentation cutoff compliance, and rate application. Replaces denormalized ca',
    `consignment_id` BIGINT COMMENT 'Reference to the parent shipment for which this carrier assignment is made.',
    `contract_rate_id` BIGINT COMMENT 'Foreign key linking to pricing.contract_rate. Business justification: Contract compliance verification for carrier assignments requires linking to the specific contract rate under which the carrier was engaged. The existing contract_rate_flag boolean indicates a contrac',
    `driver_profile_id` BIGINT COMMENT 'Foreign key linking to fleet.driver_profile. Business justification: For own-fleet carrier assignments, the executing driver must be recorded for HOS compliance, performance scoring, and incident investigation. Logistics compliance requires driver identification on eve',
    `rate_schedule_id` BIGINT COMMENT 'Foreign key linking to contract.rate_schedule. Business justification: The rate_amount on a carrier assignment must be auditable against the contracted rate schedule. Logistics freight audit processes require direct traceability from each carrier assignment to the rate s',
    `shipment_leg_id` BIGINT COMMENT 'Reference to the specific shipment leg (origin-destination segment) to which this carrier is assigned. Enables multi-leg shipment tracking.',
    `supplier_id` BIGINT COMMENT 'Foreign key linking to procurement.supplier. Business justification: Carrier assignments involve procurement-registered transport suppliers. Linking enables supplier spend management, contract compliance verification, and carrier invoice three-way matching. A logistics',
    `tpl_provider_id` BIGINT COMMENT 'Foreign key linking to network.tpl_provider. Business justification: Carrier assignments can be to 3PL providers for outsourced legs (distinct from asset carriers and intermediary agents). Enables 3PL assignment tracking, performance measurement, cost allocation, and c',
    `transport_asset_id` BIGINT COMMENT 'Foreign key linking to fleet.transport_asset. Business justification: Carrier assignments specify the exact vehicle/container executing the shipment. Essential for execution tracking, carrier performance measurement, and asset utilization. vehicle_number and container_n',
    `trip_id` BIGINT COMMENT 'Foreign key linking to fleet.trip. Business justification: A carrier assignment is operationally executed within a fleet trip. Linking enables trip-level carrier cost aggregation, on-time performance per trip, and operational reconciliation between carrier bo',
    `actual_arrival_timestamp` TIMESTAMP COMMENT 'Actual date and time when the carrier arrived at the destination with the shipment.',
    `actual_departure_timestamp` TIMESTAMP COMMENT 'Actual date and time when the carrier departed with the shipment.',
    `assignment_date` DATE COMMENT 'Date on which the carrier was assigned to this shipment leg.',
    `assignment_method` STRING COMMENT 'Method by which the carrier was assigned to this shipment leg. Auto-optimized indicates algorithmic carrier selection via SAP TM or Oracle TMS; manual override indicates planner intervention; contract based indicates assignment per existing carrier contract; spot market indicates ad-hoc market rate booking; tender indicates competitive bidding process; preferred carrier indicates selection from preferred carrier list.. Valid values are `auto_optimized|manual_override|contract_based|spot_market|tender|preferred_carrier`',
    `assignment_status` STRING COMMENT 'Current status of the carrier assignment. Confirmed indicates the carrier has accepted the booking; tentative indicates provisional assignment pending confirmation; cancelled indicates the assignment was revoked; pending indicates awaiting carrier response; rejected indicates carrier declined; expired indicates assignment lapsed without confirmation.. Valid values are `confirmed|tentative|cancelled|pending|rejected|expired`',
    `assignment_timestamp` TIMESTAMP COMMENT 'Precise date and time when the carrier assignment was created in the system.',
    `cancelled_timestamp` TIMESTAMP COMMENT 'Date and time when the carrier assignment was cancelled.',
    `carrier_iata_code` STRING COMMENT 'IATA two or three-character airline designator code for air carriers.. Valid values are `^[A-Z0-9]{2,3}$`',
    `carrier_performance_rating` DECIMAL(18,2) COMMENT 'Performance rating assigned to the carrier for this shipment leg, typically on a scale of 0.00 to 5.00. Used for carrier scorecard and future selection optimization.',
    `carrier_scac_code` STRING COMMENT 'Standard Carrier Alpha Code uniquely identifying the carrier in North American freight systems. 2-4 uppercase letters.. Valid values are `^[A-Z]{2,4}$`',
    `confirmed_timestamp` TIMESTAMP COMMENT 'Date and time when the carrier confirmed acceptance of the booking.',
    `contract_rate_flag` BOOLEAN COMMENT 'Indicates whether the rate applied is a contracted rate (true) or a spot market rate (false).',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this carrier assignment record was first created in the system.',
    `equipment_type` STRING COMMENT 'Type of equipment or container used by the carrier (e.g., 20ft container, 40ft container, refrigerated, flatbed, dry van, tanker).',
    `estimated_arrival_date` DATE COMMENT 'Estimated date of arrival for this carrier leg as provided by the carrier.',
    `estimated_departure_date` DATE COMMENT 'Estimated date of departure for this carrier leg as provided by the carrier.',
    `flight_number` STRING COMMENT 'Flight number assigned by the airline for air freight transport.',
    `fuel_surcharge_amount` DECIMAL(18,2) COMMENT 'Bunker Adjustment Factor (BAF) or fuel surcharge applied by the carrier to account for fuel cost fluctuations.',
    `mode_of_transport` STRING COMMENT 'Primary mode of transport for this carrier assignment (air, ocean, road, rail, multimodal, courier).. Valid values are `air|ocean|road|rail|multimodal|courier`',
    `notes` STRING COMMENT 'Free-text notes or comments regarding this carrier assignment, including special instructions, exceptions, or operational remarks.',
    `on_time_delivery_flag` BOOLEAN COMMENT 'Indicates whether the carrier delivered the shipment on time per the agreed service level agreement (true) or late (false).',
    `rate_amount` DECIMAL(18,2) COMMENT 'Agreed freight rate amount charged by the carrier for this shipment leg. Base rate before surcharges and adjustments.',
    `rate_currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the rate amount (e.g., USD, EUR, GBP).. Valid values are `^[A-Z]{3}$`',
    `rate_unit_of_measure` STRING COMMENT 'Unit of measure for the rate (e.g., per kilogram, per cubic meter, per TEU, per shipment, per pallet, per mile, per kilometer). [ENUM-REF-CANDIDATE: per_kg|per_cbm|per_teu|per_shipment|per_pallet|per_mile|per_km — 7 candidates stripped; promote to reference product]',
    `seal_number` STRING COMMENT 'Security seal number applied to the container or trailer to ensure cargo integrity.',
    `service_type` STRING COMMENT 'Type of carrier service: Full Truckload (FTL), Less Than Truckload (LTL), Full Container Load (FCL), Less Than Container Load (LCL), parcel, express, standard, or economy. [ENUM-REF-CANDIDATE: ftl|ltl|fcl|lcl|parcel|express|standard|economy — 8 candidates stripped; promote to reference product]',
    `total_carrier_charge` DECIMAL(18,2) COMMENT 'Total amount charged by the carrier for this shipment leg, including base rate, fuel surcharge, and other carrier fees.',
    `train_number` STRING COMMENT 'Train service number assigned for rail freight transport.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this carrier assignment record was last modified in the system.',
    `vessel_imo_number` STRING COMMENT 'Unique seven-digit IMO number assigned to the vessel for identification and tracking.. Valid values are `^IMO[0-9]{7}$`',
    `vessel_name` STRING COMMENT 'Name of the ocean vessel assigned for sea freight transport.',
    `voyage_number` STRING COMMENT 'Voyage or sailing number for ocean freight, identifying the specific vessel journey.',
    CONSTRAINT pk_shipment_carrier_assignment PRIMARY KEY(`shipment_carrier_assignment_id`)
) COMMENT 'Records the assignment of a carrier (airline, ocean carrier, road haulier, rail operator) to a specific shipment leg. Captures carrier SCAC/IATA code, carrier name, service product code, booking reference number with the carrier, assigned vehicle/vessel/flight number, assignment date, assignment method (auto-optimized via SAP TM carrier selection / manual override), rate agreed, and assignment status (confirmed/tentative/cancelled). Enables carrier performance tracking, freight audit, and carrier spend analysis per shipment.';

CREATE OR REPLACE TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` (
    `delivery_instruction_id` BIGINT COMMENT 'Unique identifier for the delivery instruction record. Primary key.',
    `address_book_id` BIGINT COMMENT 'Foreign key linking to customer.address_book. Business justification: Alternative delivery addresses in delivery instructions should reference validated entries in the customer address_book to ensure address accuracy, enable reuse of pre-validated addresses, and support',
    `consignment_id` BIGINT COMMENT 'Reference to the shipment or consignment to which this delivery instruction applies. Links delivery preferences to the specific shipment being transported.',
    `contact_id` BIGINT COMMENT 'Foreign key linking to customer.contact. Business justification: Delivery instructions frequently specify customer contact person for access coordination, delivery authorization, and issue resolution. Normalizes denormalized contact fields. Critical for last-mile d',
    `agent_id` BIGINT COMMENT 'Foreign key linking to network.agent. Business justification: Delivery instructions are executed by the assigned delivery agent. Linking enables agent-specific instruction compliance tracking, authority-to-leave policy enforcement by agent territory, and last-mi',
    `last_mile_dispatch_id` BIGINT COMMENT 'Foreign key linking to fulfillment.last_mile_dispatch. Business justification: Delivery instructions (safe place, signature required, access codes) must be accessible to last-mile dispatch operations. Linking delivery_instruction to last_mile_dispatch normalizes the plain-text d',
    `authority_to_leave_flag` BOOLEAN COMMENT 'Indicates whether the delivery driver has authority to leave the shipment unattended at the delivery location without obtaining a signature. True if authority is granted, False otherwise.',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this delivery instruction record was first created in the system. Used for audit trail and data lineage.',
    `delivery_notification_preference` STRING COMMENT 'Preferred method for receiving delivery notifications. Specifies whether the consignee wants to be notified via SMS, email, phone call, mobile app push notification, or no notification.. Valid values are `SMS|EMAIL|PHONE_CALL|MOBILE_APP|NONE`',
    `id_verification_required_flag` BOOLEAN COMMENT 'Indicates whether government-issued identification must be verified at delivery. Typically required for age-restricted or high-value shipments.',
    `instruction_effective_date` DATE COMMENT 'The date from which this delivery instruction becomes effective. Supports future-dated instructions and instruction scheduling.',
    `instruction_expiry_date` DATE COMMENT 'The date on which this delivery instruction expires and is no longer valid. Nullable for instructions with no expiration.',
    `instruction_priority` STRING COMMENT 'Priority level assigned to this delivery instruction. High priority instructions take precedence in case of conflicting instructions or operational constraints.. Valid values are `HIGH|MEDIUM|LOW`',
    `instruction_source` STRING COMMENT 'The origin or channel through which the delivery instruction was captured. Indicates whether the instruction came from the shipper, consignee, customer portal, call center, mobile app, or Electronic Data Interchange (EDI) system.. Valid values are `SHIPPER|CONSIGNEE|CUSTOMER_PORTAL|CALL_CENTER|MOBILE_APP|EDI`',
    `instruction_status` STRING COMMENT 'Current lifecycle status of the delivery instruction. Tracks whether the instruction is active, has been cancelled, completed, superseded by a newer instruction, or is pending activation.. Valid values are `ACTIVE|CANCELLED|COMPLETED|SUPERSEDED|PENDING`',
    `instruction_type` STRING COMMENT 'The type of delivery instruction specified by the shipper or consignee. Defines the primary delivery handling requirement for last-mile execution.. Valid values are `LEAVE_AT_DOOR|REQUIRE_SIGNATURE|DELIVER_TO_NEIGHBOUR|LOCKER_DELIVERY|APPOINTMENT_REQUIRED|CALL_BEFORE_DELIVERY`',
    `last_modified_by` STRING COMMENT 'Identifier of the user, system, or process that last modified this delivery instruction record. Supports audit and accountability.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'The date and time when this delivery instruction record was last updated. Used for audit trail and change tracking.',
    `locker_code` STRING COMMENT 'Identifier of the parcel locker or automated pickup point where the shipment should be delivered if locker delivery is selected.',
    `locker_location_code` STRING COMMENT 'Geographic or facility code identifying the location of the parcel locker. Used for routing and last-mile optimization.',
    `minimum_age_requirement` STRING COMMENT 'Minimum age of the recipient required for delivery. Used for age-restricted goods such as alcohol, tobacco, or pharmaceuticals.',
    `neighbour_delivery_allowed_flag` BOOLEAN COMMENT 'Indicates whether the shipment can be delivered to a neighbor if the consignee is not available. True if neighbor delivery is permitted, False otherwise.',
    `preferred_delivery_date` DATE COMMENT 'The date on which the consignee prefers to receive the delivery. Used for appointment scheduling and delivery planning.',
    `preferred_neighbour_address` STRING COMMENT 'Address of a preferred neighbor to whom the shipment can be delivered if the consignee is unavailable.',
    `preferred_time_window_end` TIMESTAMP COMMENT 'The end of the preferred delivery time window specified by the consignee. Defines the latest acceptable time for delivery within the preferred window.',
    `preferred_time_window_start` TIMESTAMP COMMENT 'The start of the preferred delivery time window specified by the consignee. Enables time-definite delivery services and appointment-based deliveries.',
    `return_if_absent_flag` BOOLEAN COMMENT 'Indicates whether the shipment should be returned to the depot or origin if the consignee is not present. True if return is required, False if alternative delivery options should be attempted.',
    `safe_place_description` STRING COMMENT 'Description of a safe place where the parcel can be left if the consignee is not present. Examples include porch, garage, side door, or with a specific neighbor.',
    `signature_required_flag` BOOLEAN COMMENT 'Indicates whether a signature is required upon delivery. True if signature is mandatory, False if delivery can be completed without signature.',
    `signature_type` STRING COMMENT 'The type of signature required for delivery. Specifies whether the consignee must sign, any adult can sign, an indirect signature is acceptable, or an electronic signature is permitted.. Valid values are `CONSIGNEE|ADULT|INDIRECT|ELECTRONIC`',
    `special_access_instructions` STRING COMMENT 'Free-text instructions provided by the consignee for accessing the delivery location. May include gate codes, building entry procedures, parking instructions, or security protocols.',
    `special_handling_notes` STRING COMMENT 'Additional free-text notes or special handling instructions for the delivery. May include fragile handling, temperature requirements, or other consignee-specific requests.',
    `version_number` STRING COMMENT 'Version number of this delivery instruction record. Incremented each time the instruction is modified, supporting optimistic locking and change history.',
    `created_by` STRING COMMENT 'Identifier of the user, system, or process that created this delivery instruction record. May be a user ID, system name, or API client identifier.',
    CONSTRAINT pk_delivery_instruction PRIMARY KEY(`delivery_instruction_id`)
) COMMENT 'Shipper or consignee-specified delivery instructions associated with a consignment. Captures instruction type (LEAVE_AT_DOOR, REQUIRE_SIGNATURE, DELIVER_TO_NEIGHBOUR, LOCKER_DELIVERY, APPOINTMENT_REQUIRED, CALL_BEFORE_DELIVERY, RETURN_IF_ABSENT), preferred delivery time window (start/end), special access instructions, safe place description, alternative delivery address, contact phone for delivery, and instruction source (shipper/consignee/customer portal). Enables last-mile delivery agents to execute D2D delivery per customer preferences and reduces failed delivery attempts.';

CREATE OR REPLACE TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` (
    `shipment_charge_id` BIGINT COMMENT 'Unique identifier for the shipment charge record. Primary key.',
    `accessorial_charge_id` BIGINT COMMENT 'Foreign key linking to pricing.accessorial_charge. Business justification: Accessorial charge validation (remote area, residential delivery, liftgate) requires linking applied charges to the master accessorial rate definition. Logistics billing audits and customer dispute re',
    `agreement_id` BIGINT COMMENT 'Foreign key linking to contract.agreement. Business justification: Freight charges must reference the governing contract agreement for rate validation, audit compliance, and dispute resolution. Billing systems validate charges against contracted rates. Essential for ',
    `billing_account_id` BIGINT COMMENT 'Identifier of the customer account responsible for paying this charge.',
    `cargo_claim_id` BIGINT COMMENT 'Foreign key linking to claim.cargo_claim. Business justification: When a cargo claim is settled, associated shipment charges (freight, surcharges) may be reversed, credited, or disputed. Finance teams link charges to claims for credit note issuance and revenue adjus',
    `carrier_id` BIGINT COMMENT 'Foreign key linking to network.carrier. Business justification: Shipment charges are levied by specific carriers; proper FK replaces denormalized carrier_iata_code and carrier_scac_code. Enables carrier cost analysis, invoice reconciliation, buy-rate vs. actual ch',
    `consignment_id` BIGINT COMMENT 'Reference to the parent shipment to which this charge applies.',
    `contract_surcharge_schedule_id` BIGINT COMMENT 'Foreign key linking to contract.contract_surcharge_schedule. Business justification: Surcharge line items on shipment charges (fuel, security, peak season) must be validated against the contracted surcharge schedule. Logistics billing audit and dispute resolution processes require thi',
    `credit_profile_id` BIGINT COMMENT 'Foreign key linking to customer.credit_profile. Business justification: Shipment charges are posted against a customers credit profile to update outstanding_balance, reduce available_credit, and enforce credit_hold_flag. Logistics credit control teams require this direct',
    `declaration_id` BIGINT COMMENT 'Foreign key linking to customs.declaration. Business justification: Duty and tax charges on shipment_charge are assessed against a specific customs declaration. Finance teams reconcile charges to declarations for duty drawback, DDP billing, and customs audit. customs_',
    `dim_weight_rule_id` BIGINT COMMENT 'Foreign key linking to pricing.dim_weight_rule. Business justification: Chargeable weight billing audit requires linking each shipment charge to the specific dim weight rule applied. Logistics billing teams and customers dispute chargeable weight calculations; tracing bil',
    `duty_assessment_id` BIGINT COMMENT 'Identifier linking this charge to a specific customs duty assessment record.',
    `invoice_id` BIGINT COMMENT 'Foreign key linking to billing.invoice. Business justification: Freight billing process: each shipment charge is consolidated onto a customer invoice. AP/AR teams reconcile charges to invoices for revenue recognition and dispute resolution. shipment_charge.invoice',
    `package_id` BIGINT COMMENT 'Foreign key linking to shipment.shipment_package. Business justification: Freight charges can be assessed at the individual package level — oversize surcharges, dangerous goods fees, temperature-controlled handling fees, and insurance charges are often package-specific rath',
    `penalty_clause_id` BIGINT COMMENT 'Foreign key linking to contract.penalty_clause. Business justification: Penalty-based charges (detention, demurrage, late delivery penalties) must reference the specific penalty clause that authorizes them. Logistics billing and dispute management require this link to val',
    `charge_code_id` BIGINT COMMENT 'Foreign key linking to pricing.charge_code. Business justification: Standardized charge classification and revenue reporting require linking each shipment charge to the master charge code. The existing charge_code plain attribute is a denormalized copy; replacing it w',
    `purchase_order_id` BIGINT COMMENT 'Foreign key linking to procurement.purchase_order. Business justification: Freight charges must be matched against purchase orders for three-way matching (PO → goods receipt → freight charge) and cost allocation. Logistics finance teams require this link for freight cost-to-',
    `rate_line_id` BIGINT COMMENT 'Foreign key linking to pricing.rate_line. Business justification: Freight billing audit and revenue reconciliation require tracing each shipment charge to the specific rate line used in calculation. Logistics billing teams and auditors routinely verify that applied ',
    `rate_schedule_id` BIGINT COMMENT 'Foreign key linking to contract.rate_schedule. Business justification: Revenue assurance and billing audit require each shipment charge to be traceable to the contracted rate schedule that generated it. The existing agreement_id is too coarse; rate_schedule_id enables ch',
    `shipment_leg_id` BIGINT COMMENT 'Foreign key linking to shipment.shipment_leg. Business justification: Some charges are leg-specific (e.g., air freight leg 1 LHR-JFK, ocean freight leg 2 JFK-LAX, fuel surcharge leg 3) while others are consignment-level (e.g., customs duty, insurance). Adding ',
    `supplier_invoice_id` BIGINT COMMENT 'Foreign key linking to procurement.supplier_invoice. Business justification: Freight charges on inbound supplier shipments (freight collect, DDP terms) often appear as line items on supplier invoices. Links freight charge to AP invoice for 3-way match, accrual accuracy, and la',
    `surcharge_id` BIGINT COMMENT 'Foreign key linking to pricing.surcharge. Business justification: Surcharge billing validation requires linking each applied surcharge charge to the master surcharge rule. Logistics finance teams verify that fuel, hazmat, and peak-season surcharges applied to shipme',
    `tariff_id` BIGINT COMMENT 'Foreign key linking to pricing.tariff. Business justification: Regulatory compliance and customer dispute resolution require tracing each shipment charge to the governing tariff. The existing tariff_code plain attribute is a denormalized reference; a proper FK en',
    `tax_schedule_id` BIGINT COMMENT 'Foreign key linking to billing.tax_schedule. Business justification: Tax compliance and audit: each shipment charge must reference the governing tax schedule for correct tax calculation across jurisdictions. Logistics tax auditors require traceability from individual c',
    `amount` DECIMAL(18,2) COMMENT 'Base monetary value of the charge before any adjustments, taxes, or discounts.',
    `application_level` STRING COMMENT 'The level at which this charge is applied within the shipment hierarchy.. Valid values are `shipment|leg|package|container|pallet`',
    `approval_required_flag` BOOLEAN COMMENT 'Indicates whether this charge requires managerial or financial approval before invoicing.',
    `approval_timestamp` TIMESTAMP COMMENT 'Date and time when this charge was approved.',
    `audit_timestamp` TIMESTAMP COMMENT 'Date and time when this charge record was last audited or reviewed for accuracy.',
    `basis` STRING COMMENT 'The calculation method or basis on which the charge is determined. [ENUM-REF-CANDIDATE: weight|volume|distance|time|flat_rate|percentage|per_unit — 7 candidates stripped; promote to reference product]',
    `billable_weight_kg` DECIMAL(18,2) COMMENT 'Chargeable weight used for freight calculation, which may be actual weight or dimensional (DIM) weight, whichever is greater.',
    `calculation_timestamp` TIMESTAMP COMMENT 'Date and time when this charge was calculated or rated by the system.',
    `charge_category` STRING COMMENT 'High-level classification of the charge type for reporting and analysis purposes. [ENUM-REF-CANDIDATE: freight|surcharge|accessorial|duty_tax|insurance|handling|storage|documentation|penalty|discount|other — 11 candidates stripped; promote to reference product]',
    `charge_description` STRING COMMENT 'Human-readable description of the charge, providing additional context beyond the charge code.',
    `charge_status` STRING COMMENT 'Current lifecycle status of the charge in the billing and payment workflow. [ENUM-REF-CANDIDATE: pending|approved|invoiced|paid|disputed|waived|cancelled — 7 candidates stripped; promote to reference product]',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this charge record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code in which the charge is denominated.. Valid values are `^[A-Z]{3}$`',
    `discount_amount` DECIMAL(18,2) COMMENT 'Monetary value of any discount applied to this charge, reducing the net payable amount.',
    `dispute_flag` BOOLEAN COMMENT 'Indicates whether this charge is currently under dispute by the customer or payer.',
    `dispute_reason` STRING COMMENT 'Explanation or reason provided for disputing this charge.',
    `modified_timestamp` TIMESTAMP COMMENT 'Date and time when this charge record was last modified or updated.',
    `net_charge_amount` DECIMAL(18,2) COMMENT 'Final charge amount after applying discounts and adding taxes. This is the amount invoiced to the customer.',
    `notes` STRING COMMENT 'Free-text field for additional comments, clarifications, or special instructions related to this charge.',
    `origin_system` STRING COMMENT 'Source system or process that generated or recorded this charge. [ENUM-REF-CANDIDATE: tms|wms|customs|carrier_invoice|manual|rating_engine|erp — 7 candidates stripped; promote to reference product]',
    `payment_term_code` STRING COMMENT 'Indicates who is responsible for paying this charge and when payment is due (e.g., prepaid by shipper, collect from consignee).. Valid values are `prepaid|collect|third_party|freight_collect|freight_prepaid`',
    `quantity` DECIMAL(18,2) COMMENT 'Quantity or volume on which the charge is based (e.g., weight in kg, volume in CBM, number of pallets, distance in km).',
    `rate_per_unit` DECIMAL(18,2) COMMENT 'Unit rate applied to the quantity to calculate the base charge amount.',
    `revenue_recognition_date` DATE COMMENT 'Date on which revenue from this charge is recognized in the financial statements.',
    `service_provider_name` STRING COMMENT 'Name of the carrier, vendor, or service provider who levied or is responsible for this charge.',
    `tax_amount` DECIMAL(18,2) COMMENT 'Total tax applied to this charge, including VAT, GST, sales tax, or other applicable taxes.',
    `tax_rate_percent` DECIMAL(18,2) COMMENT 'Percentage rate of tax applied to the charge amount.',
    `unit_of_measure` STRING COMMENT 'Unit in which the quantity is measured, determining the basis for charge calculation. [ENUM-REF-CANDIDATE: kg|lb|cbm|m3|pallet|piece|km|mile|teu|container|hour|day — 12 candidates stripped; promote to reference product]',
    `waived_flag` BOOLEAN COMMENT 'Indicates whether this charge has been waived and will not be billed to the customer.',
    `waiver_reason` STRING COMMENT 'Business justification or reason for waiving this charge.',
    CONSTRAINT pk_shipment_charge PRIMARY KEY(`shipment_charge_id`)
) COMMENT 'Shipment-level charge record capturing all freight charges, surcharges, accessorial fees, and customs duty references applied to a consignment. Captures charge code, amount, currency, tax, and any linked customs declaration references.';

CREATE OR REPLACE TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` (
    `freight_manifest_id` BIGINT COMMENT 'Unique identifier for the freight manifest record. Primary key.',
    `air_waybill_id` BIGINT COMMENT 'Foreign key linking to freight.air_waybill. Business justification: Air freight manifests are filed against master air waybills (MAWB). Linking enables MAWB-level manifest reconciliation for airline billing, customs filing, and IATA compliance reporting — a mandatory ',
    `ams_filing_id` BIGINT COMMENT 'Foreign key linking to customs.ams_filing. Business justification: AMS (Automated Manifest System) filings are submitted per vessel voyage or flight manifest. Carriers and freight forwarders need direct manifest→AMS filing linkage to verify CBP filing status, hold in',
    `bill_of_lading_id` BIGINT COMMENT 'Foreign key linking to freight.bill_of_lading. Business justification: Ocean freight manifests are filed against master bills of lading (MBL). Linking enables MBL-level manifest reconciliation for vessel billing, port authority reporting, and customs compliance — a manda',
    `carrier_agreement_id` BIGINT COMMENT 'Foreign key linking to contract.carrier_agreement. Business justification: A freight manifest consolidates shipments tendered to a carrier under a specific carrier agreement. Logistics experts require this link for manifest-level freight audit, carrier invoice reconciliation',
    `carrier_id` BIGINT COMMENT 'Foreign key linking to network.carrier. Business justification: Freight manifests are carrier-specific consolidations for line-haul movements - essential for carrier billing, capacity planning, and manifest transmission. Normalizes carrier_scac_code/carrier_iata_c',
    `carrier_service_id` BIGINT COMMENT 'Foreign key linking to network.carrier_service. Business justification: A freight manifest is built for a specific carrier service (flight, vessel voyage, truck service). This link drives load planning, documentation cutoff enforcement, capacity utilization reporting, and',
    `consolidation_id` BIGINT COMMENT 'Foreign key linking to freight.consolidation. Business justification: Freight manifest is the physical execution artifact (vehicle/flight/vessel load) of a commercial consolidation in NVOCC and freight forwarding operations. Links manifest to its commercial consolidatio',
    `declaration_id` BIGINT COMMENT 'Foreign key linking to customs.declaration. Business justification: Freight manifests require manifest-level customs declarations (e.g., air cargo manifest declaration, sea cargo manifest) submitted to customs authorities. Customs compliance teams need direct manifest',
    `dock_appointment_id` BIGINT COMMENT 'Foreign key linking to warehouse.dock_appointment. Business justification: A freight manifest is physically associated with a dock appointment for departure or arrival at a warehouse facility. Dock scheduling systems need to link manifests to time slots for load planning, ga',
    `driver_profile_id` BIGINT COMMENT 'Foreign key linking to fleet.driver_profile. Business justification: A freight manifest (especially road linehaul) is executed by a specific driver. Linking enables driver-level manifest reconciliation, HOS compliance per manifest run, and driver performance tracking. ',
    `freight_leg_id` BIGINT COMMENT 'Foreign key linking to freight.freight_leg. Business justification: A freight manifest covers cargo on a specific freight leg (flight, vessel voyage, truck run). Linking enables manifest-to-leg reconciliation for load planning, carrier billing verification, and regula',
    `center_id` BIGINT COMMENT 'Foreign key linking to fulfillment.center. Business justification: Freight manifests originating from or destined to fulfillment centers require this link for manifest routing, capacity planning, and cross-dock operations. Enables fulfillment center load planning and',
    `depot_id` BIGINT COMMENT 'Foreign key linking to fleet.depot. Business justification: Freight manifests originate from a fleet depot. Linking origin_depot_id enables depot throughput reporting, capacity planning, and departure scheduling. Logistics network managers track manifest volum',
    `facility_id` BIGINT COMMENT 'Foreign key linking to warehouse.facility. Business justification: Freight manifest load planning and dock scheduling requires structured linkage to the originating warehouse facility. Operations teams query all manifests departing a facility for capacity management ',
    `network_node_id` BIGINT COMMENT 'Foreign key linking to route.network_node. Business justification: A freight manifest departs from a specific origin network node. Hub departure reporting, load planning, and network throughput analysis require this link. origin_facility_code is a denormalized text r',
    `parcel_manifest_id` BIGINT COMMENT 'Foreign key linking to fulfillment.parcel_manifest. Business justification: A freight manifest (consolidated shipment) contains parcels tracked in parcel manifests. Cross-manifest reconciliation — verifying all parcels in a parcel manifest are accounted for in the freight man',
    `service_corridor_id` BIGINT COMMENT 'Foreign key linking to route.service_corridor. Business justification: A freight manifest operates on a specific service corridor. Corridor-level manifest volume, capacity utilization, CO2e reporting, and network design validation require this link. route_code is a denor',
    `transport_asset_id` BIGINT COMMENT 'Foreign key linking to fleet.transport_asset. Business justification: Freight manifests are loaded onto specific vehicles/containers for transport. Fundamental to freight operations for load planning, asset tracking, customs clearance, and manifest reconciliation. vehic',
    `trip_id` BIGINT COMMENT 'Foreign key linking to fleet.trip. Business justification: A freight manifest covers all consignments dispatched on a single vehicle trip. Linking manifest to trip enables load plan reconciliation, driver HOS compliance per manifest dispatch, and fuel cost al',
    `actual_arrival_timestamp` TIMESTAMP COMMENT 'Actual date and time when the manifest load arrived at the destination facility, captured from TMS or carrier systems.',
    `actual_departure_timestamp` TIMESTAMP COMMENT 'Actual date and time when the manifest load departed from the origin facility, captured from TMS or carrier systems.',
    `carbon_emissions_kg` DECIMAL(18,2) COMMENT 'Estimated or calculated carbon dioxide equivalent emissions (CO2e) for this manifest transport leg, supporting sustainability reporting per GHG Protocol and CORSIA.',
    `customs_clearance_required_flag` BOOLEAN COMMENT 'Indicates whether this manifest crosses international borders and requires customs clearance at origin or destination.',
    `dangerous_goods_flag` BOOLEAN COMMENT 'Indicates whether this manifest contains any dangerous goods (hazmat) requiring special handling and documentation per IMDG or IATA DGR.',
    `delay_duration_minutes` STRING COMMENT 'Total delay duration in minutes, calculated as the difference between planned and actual departure or arrival times.',
    `delay_reason_code` STRING COMMENT 'Standardized code indicating the primary reason for any departure or arrival delay (e.g., weather, customs hold, mechanical failure).',
    `destination_facility_code` STRING COMMENT 'Code identifying the warehouse, terminal, port, or distribution center where the manifest load is destined.',
    `destination_facility_name` STRING COMMENT 'Full name of the destination facility, terminal, or port where the manifest will be unloaded.',
    `equipment_type_code` STRING COMMENT 'Code identifying the type of transport equipment used (e.g., 20ft container, 40ft container, reefer, flatbed, dry van) per ISO 6346 or industry standards.',
    `flight_number` STRING COMMENT 'Airline flight number for air freight manifests, combining carrier code and flight number (e.g., AA1234).',
    `gps_tracking_enabled_flag` BOOLEAN COMMENT 'Indicates whether real-time GPS tracking is enabled for this manifest via FourKites or other visibility platforms.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Date and time when this manifest record was last updated or modified.',
    `load_plan_reference` STRING COMMENT 'Reference identifier to the load optimization plan generated by Oracle TMS or SAP TM that produced this manifest.',
    `manifest_closed_timestamp` TIMESTAMP COMMENT 'Date and time when the manifest was closed and locked for departure, preventing further additions or changes.',
    `manifest_completed_timestamp` TIMESTAMP COMMENT 'Date and time when the manifest was marked as completed after successful delivery and unloading at destination.',
    `manifest_cost_amount` DECIMAL(18,2) COMMENT 'Total transportation cost allocated to this manifest, including carrier charges, fuel surcharges, and accessorial fees.',
    `manifest_cost_currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the manifest cost amount.. Valid values are `^[A-Z]{3}$`',
    `manifest_created_timestamp` TIMESTAMP COMMENT 'Date and time when this manifest record was first created in the TMS or WMS system.',
    `manifest_number` STRING COMMENT 'Externally-known unique manifest number assigned by the carrier or TMS for this consolidated load. Used for carrier handover documentation and regulatory compliance.',
    `manifest_status` STRING COMMENT 'Current lifecycle status of the manifest indicating its operational state from creation through completion. [ENUM-REF-CANDIDATE: draft|open|closed|departed|in_transit|arrived|completed|cancelled — 8 candidates stripped; promote to reference product]',
    `planned_arrival_timestamp` TIMESTAMP COMMENT 'Scheduled date and time when the manifest load is expected to arrive at the destination facility.',
    `planned_departure_timestamp` TIMESTAMP COMMENT 'Scheduled date and time when the manifest load is planned to depart from the origin facility.',
    `predicted_eta_timestamp` TIMESTAMP COMMENT 'Real-time predicted arrival timestamp generated by visibility platforms such as FourKites based on GPS tracking and predictive analytics.',
    `seal_number` STRING COMMENT 'Unique seal number applied by the carrier to secure the container or trailer, used for tamper detection and security compliance (C-TPAT, AEO).',
    `temperature_controlled_flag` BOOLEAN COMMENT 'Indicates whether this manifest includes temperature-sensitive cargo requiring refrigerated or climate-controlled transport.',
    `total_chargeable_weight_kg` DECIMAL(18,2) COMMENT 'Total chargeable weight for billing purposes, calculated as the greater of actual weight or dimensional (DIM) weight, summed across all consignments.',
    `total_consignments` STRING COMMENT 'Total number of individual consignments (AWBs, BOLs, HAWBs) consolidated into this manifest.',
    `total_pieces` STRING COMMENT 'Total number of individual pieces, packages, or handling units loaded onto this manifest across all consignments.',
    `total_volume_cbm` DECIMAL(18,2) COMMENT 'Total volume of all consignments on this manifest, measured in cubic meters, used for load optimization and capacity planning.',
    `total_weight_kg` DECIMAL(18,2) COMMENT 'Total gross weight of all consignments on this manifest, measured in kilograms.',
    `transport_mode` STRING COMMENT 'Primary mode of transportation for this manifest (air, ocean, road, rail, multimodal, or parcel express).. Valid values are `air|ocean|road|rail|multimodal|parcel`',
    `vessel_name` STRING COMMENT 'Name of the ocean vessel or aircraft carrying this manifest for sea or air freight.',
    `voyage_number` STRING COMMENT 'Vessel voyage identifier for ocean freight manifests, assigned by the shipping line.',
    CONSTRAINT pk_freight_manifest PRIMARY KEY(`freight_manifest_id`)
) COMMENT 'Freight manifest record consolidating all consignments loaded onto a specific transport vehicle, vessel, or aircraft for a given departure. Captures manifest number, transport mode, vehicle/vessel/flight reference, origin facility, destination facility, departure date, total pieces, total weight, total CBM, number of consignments, dangerous goods indicator, temperature-controlled indicator, manifest status (open/closed/departed/arrived), and carrier seal number. Sourced from SAP TM and Oracle TMS load optimization outputs. Enables load reconciliation and carrier handover documentation.';

CREATE OR REPLACE TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` (
    `shipment_document_id` BIGINT COMMENT 'Unique identifier for the shipment document record. Primary key.',
    `agreement_id` BIGINT COMMENT 'Foreign key linking to contract.agreement. Business justification: Shipping documents (commercial invoices, certificates of origin, insurance certificates) often reference the governing trade agreement for customs compliance, preferential tariff claims, and regulator',
    `agreement_version_id` BIGINT COMMENT 'Foreign key linking to contract.agreement_version. Business justification: Shipment documents (commercial invoices, BOLs, certificates) must reference the specific agreement version in force at time of shipment for compliance audit and legal disputes. The existing agreement_',
    `air_waybill_id` BIGINT COMMENT 'Foreign key linking to freight.air_waybill. Business justification: Shipment documents (customs declarations, dangerous goods declarations, NOTOC) are filed against air waybills for IATA and customs regulatory compliance. Document completeness validation per AWB is a ',
    `bill_of_lading_id` BIGINT COMMENT 'Foreign key linking to freight.bill_of_lading. Business justification: Packing lists, certificates of origin, and phytosanitary certificates are filed against bills of lading for ocean freight regulatory compliance. Document completeness validation per BOL is mandatory f',
    `certificate_of_origin_id` BIGINT COMMENT 'Foreign key linking to customs.certificate_of_origin. Business justification: A shipment_document of type CERTIFICATE_OF_ORIGIN corresponds to a certificate_of_origin record in customs. Document management and preferential duty claim workflows require direct linkage to resolve ',
    `consignment_id` BIGINT COMMENT 'Reference to the parent consignment (shipment) to which this document is attached. Links the document to the primary shipment record.',
    `declaration_id` BIGINT COMMENT 'Reference to the customs declaration record to which this document is attached as supporting evidence. Nullable if not linked to a specific declaration.',
    `fulfillment_order_id` BIGINT COMMENT 'Foreign key linking to fulfillment.fulfillment_order. Business justification: Shipping documents (commercial invoice, packing list, certificate of origin) are generated per fulfillment order and required for customs clearance and merchant document retrieval. Compliance teams an',
    `license_permit_id` BIGINT COMMENT 'Foreign key linking to customs.license_permit. Business justification: Shipment documents of type IMPORT_LICENSE or EXPORT_PERMIT correspond to license_permit records. Compliance verification workflows require direct document→license_permit linkage to validate permit uti',
    `purchase_order_id` BIGINT COMMENT 'Foreign key linking to procurement.purchase_order. Business justification: Shipping documents (commercial invoice, packing list, bill of lading) are generated against purchase orders in international trade. Customs compliance and trade finance require tracing documents to or',
    `shipment_leg_id` BIGINT COMMENT 'Foreign key linking to shipment.shipment_leg. Business justification: Transport and trade documents are frequently leg-specific in multi-modal shipments — customs declarations, airway bills, bills of lading, and carrier-specific documents apply to individual legs rather',
    `superseded_by_document_shipment_document_id` BIGINT COMMENT 'Reference to the shipment_document_id of the newer version that supersedes this document. Nullable if this is the current version.',
    `approval_timestamp` TIMESTAMP COMMENT 'The date and time when the document was approved or accepted by the reviewing authority (customs, carrier, compliance officer). Nullable if not yet approved. Format: yyyy-MM-ddTHH:mm:ss.SSSXXX.',
    `compliance_flag` BOOLEAN COMMENT 'Boolean indicator whether the document meets all regulatory and carrier compliance requirements. True=compliant, False=non-compliant or pending review.',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this shipment document record was first created in the system. Format: yyyy-MM-ddTHH:mm:ss.SSSXXX.',
    `document_status` STRING COMMENT 'Current lifecycle status of the document in the shipment workflow. Pending=awaiting upload or review, Submitted=sent to customs or carrier, Approved=accepted by authority, Rejected=not accepted, Expired=past validity date, Cancelled=voided by shipper or system.. Valid values are `pending|submitted|approved|rejected|expired|cancelled`',
    `expiry_date` DATE COMMENT 'The date on which the document expires or is no longer valid for use in customs clearance or carrier acceptance. Nullable for documents without expiration. Format: yyyy-MM-dd.',
    `file_format` STRING COMMENT 'File format or MIME type of the stored document. PDF=Portable Document Format, JPEG/PNG/TIFF=image formats, XML=structured data, EDI=Electronic Data Interchange message.. Valid values are `PDF|JPEG|PNG|TIFF|XML|EDI`',
    `file_size_bytes` BIGINT COMMENT 'Size of the document file in bytes. Used for storage management and upload validation.',
    `file_uri` STRING COMMENT 'Uniform Resource Identifier (URI) or file path pointing to the stored digital copy of the document in the document management system or cloud storage. Confidential as it may expose internal storage architecture.',
    `hash` STRING COMMENT 'Cryptographic hash (e.g., SHA-256) of the document file content, used for integrity verification and tamper detection.',
    `issue_date` DATE COMMENT 'The date on which the document was officially issued or certified by the issuing authority. Format: yyyy-MM-dd.',
    `issuing_authority_name` STRING COMMENT 'Name of the organization, government agency, or entity that issued or certified the document (e.g., Chamber of Commerce, Ministry of Agriculture, Insurance Company).',
    `issuing_country_code` STRING COMMENT 'Three-letter ISO 3166-1 alpha-3 country code of the country where the document was issued.. Valid values are `^[A-Z]{3}$`',
    `language_code` STRING COMMENT 'Two-letter ISO 639-1 language code indicating the primary language in which the document is written (e.g., en=English, es=Spanish, zh=Chinese).. Valid values are `^[a-z]{2}$`',
    `last_modified_timestamp` TIMESTAMP COMMENT 'The date and time when this shipment document record was last updated or modified. Format: yyyy-MM-ddTHH:mm:ss.SSSXXX.',
    `mandatory_flag` BOOLEAN COMMENT 'Boolean indicator whether this document is mandatory for the shipment to proceed (e.g., commercial invoice for customs clearance). True=mandatory, False=optional or supplementary.',
    `reference_number` STRING COMMENT 'The unique reference or control number assigned to this document by the issuing authority or system. Used for tracking and retrieval.',
    `rejection_reason_code` STRING COMMENT 'Standardized code indicating the reason for document rejection. INCOMPLETE=missing required fields, EXPIRED=document past validity, INVALID=does not meet regulatory requirements, MISMATCH=data does not match shipment details, ILLEGIBLE=poor quality scan, UNAUTHORIZED=issuer not recognized.. Valid values are `INCOMPLETE|EXPIRED|INVALID|MISMATCH|ILLEGIBLE|UNAUTHORIZED`',
    `rejection_reason_description` STRING COMMENT 'Free-text explanation provided by the reviewing authority detailing why the document was rejected and what corrective action is required.',
    `rejection_timestamp` TIMESTAMP COMMENT 'The date and time when the document was rejected by the reviewing authority. Nullable if not rejected. Format: yyyy-MM-ddTHH:mm:ss.SSSXXX.',
    `retention_expiry_date` DATE COMMENT 'The date after which the document may be archived or purged according to regulatory retention policies (e.g., 7 years for customs records). Format: yyyy-MM-dd.',
    `reviewed_by_authority_name` STRING COMMENT 'Name of the customs office, carrier, or compliance authority that reviewed and approved or rejected the document.',
    `submission_timestamp` TIMESTAMP COMMENT 'The date and time when the document was officially submitted to customs, carrier, or other external authority for review. Nullable if not yet submitted. Format: yyyy-MM-ddTHH:mm:ss.SSSXXX.',
    `translation_required_flag` BOOLEAN COMMENT 'Boolean indicator whether the document requires translation into the destination country language for customs clearance or carrier acceptance. True=translation required, False=no translation needed.',
    `type_code` STRING COMMENT 'Classification code identifying the type of document. CINV=Commercial Invoice, PLIST=Packing List, COO=Certificate of Origin, PHYTO=Phytosanitary Certificate, DGM=Dangerous Goods Manifest, INSC=Insurance Certificate. [ENUM-REF-CANDIDATE: CINV|PLIST|COO|PHYTO|DGM|INSC|LOC|EXPL|IMPP|CUST|HAWB|MAWB|BOL|AWB|POD|CMR|TIR — promote to reference product]. Valid values are `CINV|PLIST|COO|PHYTO|DGM|INSC`',
    `upload_source` STRING COMMENT 'The channel or system through which the document was uploaded or received. Shipper_portal=customer web portal, EDI=Electronic Data Interchange, API=Application Programming Interface integration, Email=email attachment, Manual=manual entry by operations, Carrier_system=received from carrier system.. Valid values are `shipper_portal|edi|api|email|manual|carrier_system`',
    `upload_timestamp` TIMESTAMP COMMENT 'The date and time when the document was uploaded or received into the system. Format: yyyy-MM-ddTHH:mm:ss.SSSXXX.',
    `version_number` STRING COMMENT 'Sequential version number of the document if it has been revised or resubmitted. Starts at 1 for the original submission and increments with each revision.',
    CONSTRAINT pk_shipment_document PRIMARY KEY(`shipment_document_id`)
) COMMENT 'Registry of all transport and trade documents associated with a consignment beyond the primary AWB/BOL. Captures document type (commercial invoice, packing list, certificate of origin, phytosanitary certificate, dangerous goods manifest, insurance certificate, letter of credit, export license, import permit), document reference number, issuing authority, issue date, expiry date, document file URI, upload source, and document status (pending/submitted/approved/rejected). Provides a complete document envelope for a shipment enabling customs compliance and carrier acceptance checks.';

CREATE OR REPLACE TABLE `transport_shipping_ecm`.`shipment`.`manifest_line` (
    `manifest_line_id` BIGINT COMMENT 'Unique identifier for this manifest line record. Primary key.',
    `consignment_id` BIGINT COMMENT 'Foreign key linking to the consignment being loaded onto this manifest',
    `freight_manifest_id` BIGINT COMMENT 'Foreign key linking to the freight manifest on which this consignment is loaded',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this manifest line record was first created in the TMS.',
    `handling_unit_type` STRING COMMENT 'Type of handling unit used for this consignment on this manifest (e.g., pallet, cage, loose, container). Relevant for load planning and warehouse operations.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Date and time when this manifest line record was last updated or modified.',
    `line_sequence_number` STRING COMMENT 'Sequential line number indicating the order in which this consignment was loaded onto the manifest. Used for load planning and unload sequencing.',
    `line_status` STRING COMMENT 'Current lifecycle status of this manifest line indicating operational state: planned (scheduled for loading), loaded (physically loaded), departed (manifest departed), in_transit (en route), arrived (manifest arrived), delivered (consignment delivered from this leg), exception (issue detected).',
    `loaded_pieces` STRING COMMENT 'Number of pieces from this consignment actually loaded onto this manifest. May differ from consignment total pieces in multi-leg scenarios where a consignment is split across manifests.',
    `loaded_timestamp` TIMESTAMP COMMENT 'Date and time when this consignment was physically loaded onto the manifest. Captured from WMS or TMS scan events.',
    `loaded_volume_cbm` DECIMAL(18,2) COMMENT 'Actual volume in cubic meters (CBM) of this consignment loaded onto this manifest. Used for load optimization and capacity planning.',
    `loaded_weight_kg` DECIMAL(18,2) COMMENT 'Actual weight in kilograms of this consignment loaded onto this manifest. Used for load reconciliation and carrier billing.',
    `special_handling_code` STRING COMMENT 'Code indicating any special handling requirements for this consignment on this manifest leg (e.g., fragile, temperature-controlled, hazmat, priority).',
    `unloaded_timestamp` TIMESTAMP COMMENT 'Date and time when this consignment was unloaded from the manifest at the destination facility. Captured from WMS or TMS scan events.',
    CONSTRAINT pk_manifest_line PRIMARY KEY(`manifest_line_id`)
) COMMENT 'This association product represents the loading record between a freight manifest and a consignment. It captures the operational act of loading a specific consignment onto a specific manifest, including line-level loading details such as sequence, loaded pieces, weight, volume, and line status. Each record links one freight manifest to one consignment with attributes that exist only in the context of this loading relationship. This is a core operational entity in TMS and freight systems, enabling load reconciliation, carrier handover documentation, and multi-leg shipment tracking.. Existence Justification: In freight logistics operations, manifest consolidation is a core operational process where multiple consignments are physically loaded onto a single transport vehicle, vessel, or aircraft (the manifest). Reciprocally, a single consignment can appear on multiple manifests across its multi-leg journey (e.g., origin terminal → hub → destination terminal). The manifest line is a recognized operational entity in TMS and WMS systems, representing the loading record with line-level data such as sequence, loaded pieces, weight, volume, and status that belongs to neither the manifest nor the consignment alone, but to the specific loading relationship.';

-- ========= FOREIGN KEYS =========
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ADD CONSTRAINT `fk_shipment_shipment_leg_consignment_id` FOREIGN KEY (`consignment_id`) REFERENCES `transport_shipping_ecm`.`shipment`.`consignment`(`consignment_id`);
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ADD CONSTRAINT `fk_shipment_tracking_event_consignment_id` FOREIGN KEY (`consignment_id`) REFERENCES `transport_shipping_ecm`.`shipment`.`consignment`(`consignment_id`);
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ADD CONSTRAINT `fk_shipment_tracking_event_package_id` FOREIGN KEY (`package_id`) REFERENCES `transport_shipping_ecm`.`shipment`.`package`(`package_id`);
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ADD CONSTRAINT `fk_shipment_tracking_event_shipment_leg_id` FOREIGN KEY (`shipment_leg_id`) REFERENCES `transport_shipping_ecm`.`shipment`.`shipment_leg`(`shipment_leg_id`);
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ADD CONSTRAINT `fk_shipment_pod_consignment_id` FOREIGN KEY (`consignment_id`) REFERENCES `transport_shipping_ecm`.`shipment`.`consignment`(`consignment_id`);
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ADD CONSTRAINT `fk_shipment_pod_package_id` FOREIGN KEY (`package_id`) REFERENCES `transport_shipping_ecm`.`shipment`.`package`(`package_id`);
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ADD CONSTRAINT `fk_shipment_pod_shipment_leg_id` FOREIGN KEY (`shipment_leg_id`) REFERENCES `transport_shipping_ecm`.`shipment`.`shipment_leg`(`shipment_leg_id`);
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ADD CONSTRAINT `fk_shipment_eta_milestone_consignment_id` FOREIGN KEY (`consignment_id`) REFERENCES `transport_shipping_ecm`.`shipment`.`consignment`(`consignment_id`);
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ADD CONSTRAINT `fk_shipment_eta_milestone_shipment_leg_id` FOREIGN KEY (`shipment_leg_id`) REFERENCES `transport_shipping_ecm`.`shipment`.`shipment_leg`(`shipment_leg_id`);
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ADD CONSTRAINT `fk_shipment_exception_event_consignment_id` FOREIGN KEY (`consignment_id`) REFERENCES `transport_shipping_ecm`.`shipment`.`consignment`(`consignment_id`);
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ADD CONSTRAINT `fk_shipment_exception_event_shipment_leg_id` FOREIGN KEY (`shipment_leg_id`) REFERENCES `transport_shipping_ecm`.`shipment`.`shipment_leg`(`shipment_leg_id`);
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ADD CONSTRAINT `fk_shipment_consignment_status_consignment_id` FOREIGN KEY (`consignment_id`) REFERENCES `transport_shipping_ecm`.`shipment`.`consignment`(`consignment_id`);
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ADD CONSTRAINT `fk_shipment_consignment_status_shipment_leg_id` FOREIGN KEY (`shipment_leg_id`) REFERENCES `transport_shipping_ecm`.`shipment`.`shipment_leg`(`shipment_leg_id`);
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ADD CONSTRAINT `fk_shipment_package_consignment_id` FOREIGN KEY (`consignment_id`) REFERENCES `transport_shipping_ecm`.`shipment`.`consignment`(`consignment_id`);
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ADD CONSTRAINT `fk_shipment_package_shipment_leg_id` FOREIGN KEY (`shipment_leg_id`) REFERENCES `transport_shipping_ecm`.`shipment`.`shipment_leg`(`shipment_leg_id`);
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ADD CONSTRAINT `fk_shipment_shipment_carrier_assignment_consignment_id` FOREIGN KEY (`consignment_id`) REFERENCES `transport_shipping_ecm`.`shipment`.`consignment`(`consignment_id`);
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ADD CONSTRAINT `fk_shipment_shipment_carrier_assignment_shipment_leg_id` FOREIGN KEY (`shipment_leg_id`) REFERENCES `transport_shipping_ecm`.`shipment`.`shipment_leg`(`shipment_leg_id`);
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` ADD CONSTRAINT `fk_shipment_delivery_instruction_consignment_id` FOREIGN KEY (`consignment_id`) REFERENCES `transport_shipping_ecm`.`shipment`.`consignment`(`consignment_id`);
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ADD CONSTRAINT `fk_shipment_shipment_charge_consignment_id` FOREIGN KEY (`consignment_id`) REFERENCES `transport_shipping_ecm`.`shipment`.`consignment`(`consignment_id`);
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ADD CONSTRAINT `fk_shipment_shipment_charge_package_id` FOREIGN KEY (`package_id`) REFERENCES `transport_shipping_ecm`.`shipment`.`package`(`package_id`);
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ADD CONSTRAINT `fk_shipment_shipment_charge_shipment_leg_id` FOREIGN KEY (`shipment_leg_id`) REFERENCES `transport_shipping_ecm`.`shipment`.`shipment_leg`(`shipment_leg_id`);
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ADD CONSTRAINT `fk_shipment_shipment_document_consignment_id` FOREIGN KEY (`consignment_id`) REFERENCES `transport_shipping_ecm`.`shipment`.`consignment`(`consignment_id`);
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ADD CONSTRAINT `fk_shipment_shipment_document_shipment_leg_id` FOREIGN KEY (`shipment_leg_id`) REFERENCES `transport_shipping_ecm`.`shipment`.`shipment_leg`(`shipment_leg_id`);
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ADD CONSTRAINT `fk_shipment_shipment_document_superseded_by_document_shipment_document_id` FOREIGN KEY (`superseded_by_document_shipment_document_id`) REFERENCES `transport_shipping_ecm`.`shipment`.`shipment_document`(`shipment_document_id`);
ALTER TABLE `transport_shipping_ecm`.`shipment`.`manifest_line` ADD CONSTRAINT `fk_shipment_manifest_line_consignment_id` FOREIGN KEY (`consignment_id`) REFERENCES `transport_shipping_ecm`.`shipment`.`consignment`(`consignment_id`);
ALTER TABLE `transport_shipping_ecm`.`shipment`.`manifest_line` ADD CONSTRAINT `fk_shipment_manifest_line_freight_manifest_id` FOREIGN KEY (`freight_manifest_id`) REFERENCES `transport_shipping_ecm`.`shipment`.`freight_manifest`(`freight_manifest_id`);

-- ========= TAGS =========
ALTER SCHEMA `transport_shipping_ecm`.`shipment` SET TAGS ('dbx_division' = 'operations');
ALTER SCHEMA `transport_shipping_ecm`.`shipment` SET TAGS ('dbx_domain' = 'shipment');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` SET TAGS ('dbx_subdomain' = 'booking_management');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `consignment_id` SET TAGS ('dbx_business_glossary_term' = 'Consignment Identifier');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Agreement Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `air_waybill_id` SET TAGS ('dbx_business_glossary_term' = 'Air Waybill Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `bill_of_lading_id` SET TAGS ('dbx_business_glossary_term' = 'Bill Of Lading Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `booking_id` SET TAGS ('dbx_business_glossary_term' = 'Booking Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `cargo_id` SET TAGS ('dbx_business_glossary_term' = 'Cargo Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `carrier_id` SET TAGS ('dbx_business_glossary_term' = 'Carrier Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `carrier_service_id` SET TAGS ('dbx_business_glossary_term' = 'Carrier Service Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `consignee_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Consignee Profile Identifier');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `consolidation_id` SET TAGS ('dbx_business_glossary_term' = 'Consolidation Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `contract_rate_id` SET TAGS ('dbx_business_glossary_term' = 'Contract Rate Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `customer_account_id` SET TAGS ('dbx_business_glossary_term' = 'Customer Account Identifier');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `route_delivery_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Destination Route Delivery Zone Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `fulfillment_order_id` SET TAGS ('dbx_business_glossary_term' = 'Fulfillment Order Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `purchase_order_id` SET TAGS ('dbx_business_glossary_term' = 'Purchase Order Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `quote_id` SET TAGS ('dbx_business_glossary_term' = 'Quote Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `rate_card_id` SET TAGS ('dbx_business_glossary_term' = 'Rate Card Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `service_scope_id` SET TAGS ('dbx_business_glossary_term' = 'Service Scope Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `shipper_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Shipper Profile Identifier');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `sla_commitment_id` SET TAGS ('dbx_business_glossary_term' = 'Contract Sla Commitment Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `spot_quote_id` SET TAGS ('dbx_business_glossary_term' = 'Spot Quote Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `transit_time_standard_id` SET TAGS ('dbx_business_glossary_term' = 'Transit Time Standard Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `awb_number` SET TAGS ('dbx_business_glossary_term' = 'Air Waybill (AWB) Number');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `awb_number` SET TAGS ('dbx_value_regex' = '^[0-9]{3}-[0-9]{8}$');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `bol_number` SET TAGS ('dbx_business_glossary_term' = 'Bill of Lading (BOL) Number');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `booking_channel` SET TAGS ('dbx_business_glossary_term' = 'Booking Channel');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `booking_date` SET TAGS ('dbx_business_glossary_term' = 'Booking Date');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `booking_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Booking Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `chargeable_weight_kg` SET TAGS ('dbx_business_glossary_term' = 'Chargeable Weight in Kilograms (KG)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `cod_amount` SET TAGS ('dbx_business_glossary_term' = 'Cash on Delivery (COD) Amount');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `cod_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `cod_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `cod_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Cash on Delivery (COD) Currency Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `cod_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `committed_delivery_date` SET TAGS ('dbx_business_glossary_term' = 'Committed Delivery Date');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `committed_delivery_time` SET TAGS ('dbx_business_glossary_term' = 'Committed Delivery Time');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `commodity_description` SET TAGS ('dbx_business_glossary_term' = 'Commodity Description');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `consignee_contact_phone` SET TAGS ('dbx_business_glossary_term' = 'Consignee Contact Phone Number');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `consignee_contact_phone` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `consignee_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `consignee_name` SET TAGS ('dbx_business_glossary_term' = 'Consignee Name');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `consignee_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `consignee_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `declared_value_amount` SET TAGS ('dbx_business_glossary_term' = 'Declared Value Amount');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `declared_value_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `declared_value_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `declared_value_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Declared Value Currency Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `declared_value_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `declared_weight_kg` SET TAGS ('dbx_business_glossary_term' = 'Declared Weight in Kilograms (KG)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `delivery_instruction_type` SET TAGS ('dbx_business_glossary_term' = 'Delivery Instruction Type');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `delivery_time_window_end` SET TAGS ('dbx_business_glossary_term' = 'Delivery Time Window End');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `delivery_time_window_start` SET TAGS ('dbx_business_glossary_term' = 'Delivery Time Window Start');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `destination_address_line1` SET TAGS ('dbx_business_glossary_term' = 'Destination Address Line 1');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `destination_address_line1` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `destination_address_line1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `destination_city` SET TAGS ('dbx_business_glossary_term' = 'Destination City');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `destination_country_code` SET TAGS ('dbx_business_glossary_term' = 'Destination Country Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `destination_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `destination_postal_code` SET TAGS ('dbx_business_glossary_term' = 'Destination Postal Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `destination_postal_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `destination_postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `hawb_number` SET TAGS ('dbx_business_glossary_term' = 'House Air Waybill (HAWB) Number');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `hs_code` SET TAGS ('dbx_business_glossary_term' = 'Harmonized System (HS) Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `hs_code` SET TAGS ('dbx_value_regex' = '^[0-9]{6,10}$');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `incoterms_code` SET TAGS ('dbx_business_glossary_term' = 'International Commercial Terms (Incoterms) Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `is_cod` SET TAGS ('dbx_business_glossary_term' = 'Cash on Delivery (COD) Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `is_dangerous_goods` SET TAGS ('dbx_business_glossary_term' = 'Dangerous Goods Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `is_otd_target` SET TAGS ('dbx_business_glossary_term' = 'On-Time Delivery (OTD) Target Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `is_otif_target` SET TAGS ('dbx_business_glossary_term' = 'On-Time In-Full (OTIF) Target Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `lifecycle_status` SET TAGS ('dbx_business_glossary_term' = 'Consignment Lifecycle Status');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `mawb_number` SET TAGS ('dbx_business_glossary_term' = 'Master Air Waybill (MAWB) Number');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `number_of_pieces` SET TAGS ('dbx_business_glossary_term' = 'Number of Pieces');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `origin_address_line1` SET TAGS ('dbx_business_glossary_term' = 'Origin Address Line 1');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `origin_address_line1` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `origin_address_line1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `origin_city` SET TAGS ('dbx_business_glossary_term' = 'Origin City');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `origin_country_code` SET TAGS ('dbx_business_glossary_term' = 'Origin Country Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `origin_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `origin_postal_code` SET TAGS ('dbx_business_glossary_term' = 'Origin Postal Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `origin_postal_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `origin_postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `priority_level` SET TAGS ('dbx_business_glossary_term' = 'Priority Level');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `priority_level` SET TAGS ('dbx_value_regex' = 'standard|high|urgent|critical');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `shipper_contact_phone` SET TAGS ('dbx_business_glossary_term' = 'Shipper Contact Phone Number');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `shipper_contact_phone` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `shipper_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `shipper_name` SET TAGS ('dbx_business_glossary_term' = 'Shipper Name');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `shipper_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `shipper_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `sla_source` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) Source');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `sla_source` SET TAGS ('dbx_value_regex' = 'customer_contract|rate_card|spot_booking|standard_terms');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `special_handling_notes` SET TAGS ('dbx_business_glossary_term' = 'Special Handling Notes');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `transit_time_days` SET TAGS ('dbx_business_glossary_term' = 'Transit Time in Days');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `un_number` SET TAGS ('dbx_business_glossary_term' = 'United Nations (UN) Number');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `un_number` SET TAGS ('dbx_value_regex' = '^UN[0-9]{4}$');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `volume_cbm` SET TAGS ('dbx_business_glossary_term' = 'Volume in Cubic Meters (CBM)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment` ALTER COLUMN `volumetric_weight_kg` SET TAGS ('dbx_business_glossary_term' = 'Volumetric Weight in Kilograms (KG) / Dimensional Weight (DIM Weight)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` SET TAGS ('dbx_subdomain' = 'transport_execution');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `shipment_leg_id` SET TAGS ('dbx_business_glossary_term' = 'Shipment Leg Identifier (ID)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `ams_filing_id` SET TAGS ('dbx_business_glossary_term' = 'Ams Filing Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `blocked_space_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Blocked Space Agreement Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `booking_id` SET TAGS ('dbx_business_glossary_term' = 'Booking Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `carrier_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Carrier Agreement Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `carrier_buy_rate_id` SET TAGS ('dbx_business_glossary_term' = 'Carrier Buy Rate Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `carrier_id` SET TAGS ('dbx_business_glossary_term' = 'Carrier Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `carrier_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Carrier Schedule Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `carrier_service_id` SET TAGS ('dbx_business_glossary_term' = 'Carrier Service Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `consignment_id` SET TAGS ('dbx_business_glossary_term' = 'Shipment Identifier (ID)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `container_unit_id` SET TAGS ('dbx_business_glossary_term' = 'Container Unit Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `corridor_leg_id` SET TAGS ('dbx_business_glossary_term' = 'Corridor Leg Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `declaration_id` SET TAGS ('dbx_business_glossary_term' = 'Declaration Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `agent_id` SET TAGS ('dbx_business_glossary_term' = 'Delivery Agent Identifier (ID)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `driver_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Driver Profile Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `hold_id` SET TAGS ('dbx_business_glossary_term' = 'Hold Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `interline_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Interline Agreement Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `lane_commitment_id` SET TAGS ('dbx_business_glossary_term' = 'Lane Commitment Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `lane_id` SET TAGS ('dbx_business_glossary_term' = 'Lane Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `facility_id` SET TAGS ('dbx_business_glossary_term' = 'Origin Facility Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `rate_line_id` SET TAGS ('dbx_business_glossary_term' = 'Rate Line Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `rate_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Rate Schedule Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `tpl_provider_id` SET TAGS ('dbx_business_glossary_term' = 'Tpl Provider Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `trip_id` SET TAGS ('dbx_business_glossary_term' = 'Trip Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `actual_arrival_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Actual Arrival Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `actual_departure_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Actual Departure Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `carbon_emissions_kg` SET TAGS ('dbx_business_glossary_term' = 'Carbon Emissions in Kilograms (CO2e)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `cost_amount` SET TAGS ('dbx_business_glossary_term' = 'Leg Cost Amount');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `cost_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `cost_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Leg Cost Currency Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `cost_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `customs_clearance_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Customs Clearance Required Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `delay_duration_minutes` SET TAGS ('dbx_business_glossary_term' = 'Delay Duration in Minutes');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `delay_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Delay Reason Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `delivery_attempt_number` SET TAGS ('dbx_business_glossary_term' = 'Delivery Attempt Number');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `destination_location_code` SET TAGS ('dbx_business_glossary_term' = 'Destination Location Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `destination_location_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3,5}$');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `dispatch_sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Dispatch Sequence Number');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `distance_km` SET TAGS ('dbx_business_glossary_term' = 'Distance in Kilometers (KM)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `equipment_type_code` SET TAGS ('dbx_business_glossary_term' = 'Equipment Type Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `eta_prediction_source` SET TAGS ('dbx_business_glossary_term' = 'Estimated Time of Arrival (ETA) Prediction Source');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `eta_prediction_source` SET TAGS ('dbx_value_regex' = 'fourkites_ai|carrier_edi|manual_estimate|tms_calculation|gps_tracking|iot_sensor');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `flight_number` SET TAGS ('dbx_business_glossary_term' = 'Flight Number');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `flight_number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2}[0-9]{1,4}[A-Z]?$');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `gps_tracking_enabled_flag` SET TAGS ('dbx_business_glossary_term' = 'Global Positioning System (GPS) Tracking Enabled Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `hazmat_flag` SET TAGS ('dbx_business_glossary_term' = 'Hazardous Materials (HAZMAT) Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Updated Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `leg_status` SET TAGS ('dbx_business_glossary_term' = 'Leg Status');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `leg_status` SET TAGS ('dbx_value_regex' = 'planned|in_transit|completed|delayed|cancelled|failed');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `origin_location_code` SET TAGS ('dbx_business_glossary_term' = 'Origin Location Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `origin_location_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3,5}$');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `planned_arrival_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Planned Arrival Timestamp (Estimated Time of Arrival - ETA)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `planned_departure_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Planned Departure Timestamp (Estimated Time of Departure - ETD)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `predicted_eta_confidence_score` SET TAGS ('dbx_business_glossary_term' = 'Predicted Estimated Time of Arrival (ETA) Confidence Score');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `predicted_eta_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Predicted Estimated Time of Arrival (ETA) Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `seal_number` SET TAGS ('dbx_business_glossary_term' = 'Seal Number');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Leg Sequence Number');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'sap_tm|oracle_tms|fourkites|carrier_edi|manual_entry');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `temperature_controlled_flag` SET TAGS ('dbx_business_glossary_term' = 'Temperature Controlled Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `tracking_number` SET TAGS ('dbx_business_glossary_term' = 'Tracking Number');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `transport_mode` SET TAGS ('dbx_business_glossary_term' = 'Transport Mode');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `transport_mode` SET TAGS ('dbx_value_regex' = 'air|ocean|road|rail|multimodal|courier');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `vehicle_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Reference Number');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_leg` ALTER COLUMN `voyage_number` SET TAGS ('dbx_business_glossary_term' = 'Voyage Number');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` SET TAGS ('dbx_subdomain' = 'transport_execution');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `tracking_event_id` SET TAGS ('dbx_business_glossary_term' = 'Tracking Event ID');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `carrier_id` SET TAGS ('dbx_business_glossary_term' = 'Carrier Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `consignment_id` SET TAGS ('dbx_business_glossary_term' = 'Shipment ID');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `declaration_id` SET TAGS ('dbx_business_glossary_term' = 'Declaration Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `facility_id` SET TAGS ('dbx_business_glossary_term' = 'Facility Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `hold_id` SET TAGS ('dbx_business_glossary_term' = 'Hold Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `last_mile_dispatch_id` SET TAGS ('dbx_business_glossary_term' = 'Last Mile Dispatch Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `network_node_id` SET TAGS ('dbx_business_glossary_term' = 'Network Node Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `package_id` SET TAGS ('dbx_business_glossary_term' = 'Shipment Package Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `shipment_leg_id` SET TAGS ('dbx_business_glossary_term' = 'Shipment Leg Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `transport_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle ID');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `actual_delivery_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Actual Delivery Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `api_transaction_reference` SET TAGS ('dbx_business_glossary_term' = 'API (Application Programming Interface) Transaction ID');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `awb_number` SET TAGS ('dbx_business_glossary_term' = 'AWB (Air Waybill) Number');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `bol_number` SET TAGS ('dbx_business_glossary_term' = 'BOL (Bill of Lading) Number');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `container_number` SET TAGS ('dbx_business_glossary_term' = 'Container Number');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `customs_clearance_status` SET TAGS ('dbx_business_glossary_term' = 'Customs Clearance Status');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `customs_clearance_status` SET TAGS ('dbx_value_regex' = 'pending|cleared|held|released|rejected');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `damage_description` SET TAGS ('dbx_business_glossary_term' = 'Damage Description');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `damage_reported` SET TAGS ('dbx_business_glossary_term' = 'Damage Reported');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `edi_message_reference` SET TAGS ('dbx_business_glossary_term' = 'EDI (Electronic Data Interchange) Message ID');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `estimated_delivery_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Estimated Delivery Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `event_category` SET TAGS ('dbx_business_glossary_term' = 'Event Category');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `event_category` SET TAGS ('dbx_value_regex' = 'tracking|hub_operation|exception|lifecycle');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `event_description` SET TAGS ('dbx_business_glossary_term' = 'Event Description');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `event_source` SET TAGS ('dbx_business_glossary_term' = 'Event Source');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `event_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Event Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `event_type_code` SET TAGS ('dbx_business_glossary_term' = 'Event Type Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `exception_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Exception Reason Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `exception_resolution_notes` SET TAGS ('dbx_business_glossary_term' = 'Exception Resolution Notes');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `exception_resolution_status` SET TAGS ('dbx_business_glossary_term' = 'Exception Resolution Status');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `exception_resolution_status` SET TAGS ('dbx_value_regex' = 'open|in_progress|resolved|escalated');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `exception_resolution_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Exception Resolution Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `exception_severity` SET TAGS ('dbx_business_glossary_term' = 'Exception Severity');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `exception_severity` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `gps_latitude` SET TAGS ('dbx_business_glossary_term' = 'GPS (Global Positioning System) Latitude');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `gps_latitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `gps_latitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `gps_longitude` SET TAGS ('dbx_business_glossary_term' = 'GPS (Global Positioning System) Longitude');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `gps_longitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `gps_longitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `humidity_percentage` SET TAGS ('dbx_business_glossary_term' = 'Humidity Percentage');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `location_city` SET TAGS ('dbx_business_glossary_term' = 'Location City');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `location_country_code` SET TAGS ('dbx_business_glossary_term' = 'Location Country Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `location_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `location_postal_code` SET TAGS ('dbx_business_glossary_term' = 'Location Postal Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `location_postal_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `location_postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `location_state_province` SET TAGS ('dbx_business_glossary_term' = 'Location State or Province');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `new_status` SET TAGS ('dbx_business_glossary_term' = 'New Status');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `pieces_count` SET TAGS ('dbx_business_glossary_term' = 'Pieces Count');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `pod_image_url` SET TAGS ('dbx_business_glossary_term' = 'POD (Proof of Delivery) Image URL');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `pod_recipient_name` SET TAGS ('dbx_business_glossary_term' = 'POD (Proof of Delivery) Recipient Name');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `pod_recipient_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `pod_recipient_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `pod_signature_captured` SET TAGS ('dbx_business_glossary_term' = 'POD (Proof of Delivery) Signature Captured');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `previous_status` SET TAGS ('dbx_business_glossary_term' = 'Previous Status');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `record_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `record_source_system` SET TAGS ('dbx_business_glossary_term' = 'Record Source System');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `scan_type` SET TAGS ('dbx_business_glossary_term' = 'Scan Type');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `scan_type` SET TAGS ('dbx_value_regex' = 'barcode|rfid|manual|ocr');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `seal_number` SET TAGS ('dbx_business_glossary_term' = 'Seal Number');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `temperature_celsius` SET TAGS ('dbx_business_glossary_term' = 'Temperature in Celsius');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`tracking_event` ALTER COLUMN `weight_kg` SET TAGS ('dbx_business_glossary_term' = 'Weight in Kilograms');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` SET TAGS ('dbx_subdomain' = 'delivery_operations');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `pod_id` SET TAGS ('dbx_business_glossary_term' = 'Proof of Delivery (POD) ID');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `cargo_claim_id` SET TAGS ('dbx_business_glossary_term' = 'Claim ID');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `carrier_id` SET TAGS ('dbx_business_glossary_term' = 'Carrier Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `consignee_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Consignee Profile Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `consignment_id` SET TAGS ('dbx_business_glossary_term' = 'Shipment ID');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `agent_id` SET TAGS ('dbx_business_glossary_term' = 'Delivery Agent Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `transport_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Delivery Transport Asset Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `fulfillment_order_id` SET TAGS ('dbx_business_glossary_term' = 'Fulfillment Order Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `invoice_id` SET TAGS ('dbx_business_glossary_term' = 'Invoice Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `last_mile_dispatch_id` SET TAGS ('dbx_business_glossary_term' = 'Last Mile Dispatch Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `package_id` SET TAGS ('dbx_business_glossary_term' = 'Shipment Package Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `payment_id` SET TAGS ('dbx_business_glossary_term' = 'Payment Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `route_delivery_zone_id` SET TAGS ('dbx_business_glossary_term' = 'Route Delivery Zone Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `shipment_leg_id` SET TAGS ('dbx_business_glossary_term' = 'Shipment Leg Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `trip_id` SET TAGS ('dbx_business_glossary_term' = 'Trip Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `amount_collected` SET TAGS ('dbx_business_glossary_term' = 'Amount Collected');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `amount_collected` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `amount_collected` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `awb_number` SET TAGS ('dbx_business_glossary_term' = 'Air Waybill (AWB) Number');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `bol_number` SET TAGS ('dbx_business_glossary_term' = 'Bill of Lading (BOL) Number');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `cod_amount` SET TAGS ('dbx_business_glossary_term' = 'Cash on Delivery (COD) Amount');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `cod_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `cod_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `cod_currency` SET TAGS ('dbx_business_glossary_term' = 'Cash on Delivery (COD) Currency');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `cod_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `collection_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Collection Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `collection_variance_amount` SET TAGS ('dbx_business_glossary_term' = 'Collection Variance Amount');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `delivery_address_line1` SET TAGS ('dbx_business_glossary_term' = 'Delivery Address Line 1');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `delivery_address_line1` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `delivery_address_line1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `delivery_address_line2` SET TAGS ('dbx_business_glossary_term' = 'Delivery Address Line 2');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `delivery_address_line2` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `delivery_address_line2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `delivery_city` SET TAGS ('dbx_business_glossary_term' = 'Delivery City');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `delivery_city` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `delivery_city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `delivery_country_code` SET TAGS ('dbx_business_glossary_term' = 'Delivery Country Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `delivery_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `delivery_exception_code` SET TAGS ('dbx_business_glossary_term' = 'Delivery Exception Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `delivery_latitude` SET TAGS ('dbx_business_glossary_term' = 'Delivery Latitude');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `delivery_latitude` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `delivery_latitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `delivery_longitude` SET TAGS ('dbx_business_glossary_term' = 'Delivery Longitude');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `delivery_longitude` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `delivery_longitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `delivery_notes` SET TAGS ('dbx_business_glossary_term' = 'Delivery Notes');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `delivery_postal_code` SET TAGS ('dbx_business_glossary_term' = 'Delivery Postal Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `delivery_postal_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `delivery_postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `delivery_state_province` SET TAGS ('dbx_business_glossary_term' = 'Delivery State or Province');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `delivery_state_province` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `delivery_state_province` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `delivery_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Delivery Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `delivery_type` SET TAGS ('dbx_business_glossary_term' = 'Delivery Type');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `delivery_type` SET TAGS ('dbx_value_regex' = 'door|reception|locker|neighbor|safe_place|collection_point');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `device_code` SET TAGS ('dbx_business_glossary_term' = 'Device ID');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `device_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `device_code` SET TAGS ('dbx_pii_device' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `dispute_raised_flag` SET TAGS ('dbx_business_glossary_term' = 'Dispute Raised Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `dispute_reason` SET TAGS ('dbx_business_glossary_term' = 'Dispute Reason');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `document_number` SET TAGS ('dbx_business_glossary_term' = 'Proof of Delivery (POD) Document Number');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `epod_image_reference` SET TAGS ('dbx_business_glossary_term' = 'Electronic Proof of Delivery (ePOD) Image Reference');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'cash|card|digital_wallet|bank_transfer|cheque');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `pod_status` SET TAGS ('dbx_business_glossary_term' = 'Proof of Delivery (POD) Status');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `pod_status` SET TAGS ('dbx_value_regex' = 'accepted|disputed|pending|verified|rejected');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `recipient_contact_number` SET TAGS ('dbx_business_glossary_term' = 'Recipient Contact Number');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `recipient_contact_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `recipient_contact_number` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `recipient_email` SET TAGS ('dbx_business_glossary_term' = 'Recipient Email Address');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `recipient_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `recipient_email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `recipient_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `recipient_id_number` SET TAGS ('dbx_business_glossary_term' = 'Recipient Identification Number');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `recipient_id_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `recipient_id_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `recipient_id_type` SET TAGS ('dbx_business_glossary_term' = 'Recipient Identification Type');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `recipient_id_type` SET TAGS ('dbx_value_regex' = 'national_id|passport|drivers_license|employee_badge|none');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `recipient_name` SET TAGS ('dbx_business_glossary_term' = 'Recipient Name');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `recipient_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `recipient_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `recipient_signature` SET TAGS ('dbx_business_glossary_term' = 'Recipient Signature');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `recipient_signature` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `recipient_signature` SET TAGS ('dbx_pii_biometric' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `remittance_batch_number` SET TAGS ('dbx_business_glossary_term' = 'Remittance Batch ID');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `remittance_date` SET TAGS ('dbx_business_glossary_term' = 'Remittance Date');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `remittance_status` SET TAGS ('dbx_business_glossary_term' = 'Remittance Status');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `remittance_status` SET TAGS ('dbx_value_regex' = 'pending|remitted|reconciled|disputed|failed');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `transaction_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Transaction Reference Number');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `transaction_reference_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `transaction_reference_number` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `variance_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Variance Reason Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`pod` ALTER COLUMN `verification_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Verification Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` SET TAGS ('dbx_subdomain' = 'transport_execution');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `eta_milestone_id` SET TAGS ('dbx_business_glossary_term' = 'Estimated Time of Arrival (ETA) Milestone ID');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `carrier_id` SET TAGS ('dbx_business_glossary_term' = 'Carrier Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `consignment_id` SET TAGS ('dbx_business_glossary_term' = 'Shipment ID');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `declaration_id` SET TAGS ('dbx_business_glossary_term' = 'Declaration Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `facility_id` SET TAGS ('dbx_business_glossary_term' = 'Facility Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `fulfillment_order_id` SET TAGS ('dbx_business_glossary_term' = 'Fulfillment Order Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `hold_id` SET TAGS ('dbx_business_glossary_term' = 'Hold Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `network_node_id` SET TAGS ('dbx_business_glossary_term' = 'Network Node Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `shipment_leg_id` SET TAGS ('dbx_business_glossary_term' = 'Shipment Leg Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `sla_commitment_id` SET TAGS ('dbx_business_glossary_term' = 'Contract Sla Commitment Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `sla_entitlement_id` SET TAGS ('dbx_business_glossary_term' = 'Sla Entitlement Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `transport_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Transport Asset Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `actual_datetime` SET TAGS ('dbx_business_glossary_term' = 'Actual Date Time');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `created_datetime` SET TAGS ('dbx_business_glossary_term' = 'Created Date Time');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `current_predicted_datetime` SET TAGS ('dbx_business_glossary_term' = 'Current Predicted Date Time');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `customs_clearance_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Customs Clearance Required Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `customs_clearance_status` SET TAGS ('dbx_business_glossary_term' = 'Customs Clearance Status');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `customs_clearance_status` SET TAGS ('dbx_value_regex' = 'NOT_REQUIRED|PENDING|IN_PROGRESS|CLEARED|HELD|REJECTED');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `data_quality_score` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Score');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `delay_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Delay Reason Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `delay_reason_description` SET TAGS ('dbx_business_glossary_term' = 'Delay Reason Description');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `distance_remaining_km` SET TAGS ('dbx_business_glossary_term' = 'Distance Remaining Kilometers (KM)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `exception_flag` SET TAGS ('dbx_business_glossary_term' = 'Exception Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `exception_type` SET TAGS ('dbx_business_glossary_term' = 'Exception Type');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `hazmat_flag` SET TAGS ('dbx_business_glossary_term' = 'Hazardous Materials (HAZMAT) Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `last_modified_datetime` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Date Time');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `location_name` SET TAGS ('dbx_business_glossary_term' = 'Location Name');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `milestone_sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Milestone Sequence Number');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `milestone_type` SET TAGS ('dbx_business_glossary_term' = 'Milestone Type');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `milestone_type` SET TAGS ('dbx_value_regex' = 'ETD_ORIGIN|ETA_TRANSIT_HUB|ETD_TRANSIT_HUB|ETA_DESTINATION|ETA_DELIVERY|ETD_PICKUP');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `notification_sent_datetime` SET TAGS ('dbx_business_glossary_term' = 'Notification Sent Date Time');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `notification_sent_flag` SET TAGS ('dbx_business_glossary_term' = 'Notification Sent Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `original_committed_datetime` SET TAGS ('dbx_business_glossary_term' = 'Original Committed Date Time');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `prediction_confidence_score` SET TAGS ('dbx_business_glossary_term' = 'Prediction Confidence Score');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `prediction_last_updated_datetime` SET TAGS ('dbx_business_glossary_term' = 'Prediction Last Updated Date Time');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `prediction_source` SET TAGS ('dbx_business_glossary_term' = 'Prediction Source');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `prediction_source` SET TAGS ('dbx_value_regex' = 'FOURKITES_AI|CARRIER_EDI|TMS_CALCULATION|MANUAL_OVERRIDE|GPS_TRACKING|HISTORICAL_AVERAGE');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `prediction_update_frequency_minutes` SET TAGS ('dbx_business_glossary_term' = 'Prediction Update Frequency Minutes');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `priority_level` SET TAGS ('dbx_business_glossary_term' = 'Priority Level');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `priority_level` SET TAGS ('dbx_value_regex' = 'STANDARD|EXPEDITED|URGENT|CRITICAL');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `sla_status` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) Status');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `sla_status` SET TAGS ('dbx_value_regex' = 'ON_TIME|AT_RISK|DELAYED|EARLY');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `sla_threshold_hours` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) Threshold Hours');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `temperature_controlled_flag` SET TAGS ('dbx_business_glossary_term' = 'Temperature Controlled Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `timezone` SET TAGS ('dbx_business_glossary_term' = 'Time Zone');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `timezone` SET TAGS ('dbx_value_regex' = '^[A-Za-z]+/[A-Za-z_]+$');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `transport_mode` SET TAGS ('dbx_business_glossary_term' = 'Transport Mode');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `transport_mode` SET TAGS ('dbx_value_regex' = 'AIR|OCEAN|ROAD|RAIL|INTERMODAL');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `variance_hours` SET TAGS ('dbx_business_glossary_term' = 'Variance Hours');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`eta_milestone` ALTER COLUMN `weather_impact_flag` SET TAGS ('dbx_business_glossary_term' = 'Weather Impact Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` SET TAGS ('dbx_subdomain' = 'transport_execution');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `exception_event_id` SET TAGS ('dbx_business_glossary_term' = 'Exception Event ID');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `agent_id` SET TAGS ('dbx_business_glossary_term' = 'Agent Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `carrier_id` SET TAGS ('dbx_business_glossary_term' = 'Carrier ID');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `consignment_id` SET TAGS ('dbx_business_glossary_term' = 'Shipment ID');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `declaration_id` SET TAGS ('dbx_business_glossary_term' = 'Declaration Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `driver_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Driver Profile Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `facility_id` SET TAGS ('dbx_business_glossary_term' = 'Facility Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `fulfillment_order_id` SET TAGS ('dbx_business_glossary_term' = 'Fulfillment Order Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `hold_id` SET TAGS ('dbx_business_glossary_term' = 'Hold Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `last_mile_dispatch_id` SET TAGS ('dbx_business_glossary_term' = 'Last Mile Dispatch Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `network_event_id` SET TAGS ('dbx_business_glossary_term' = 'Network Event Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `network_node_id` SET TAGS ('dbx_business_glossary_term' = 'Network Node Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `penalty_clause_id` SET TAGS ('dbx_business_glossary_term' = 'Penalty Clause Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `shipment_leg_id` SET TAGS ('dbx_business_glossary_term' = 'Shipment Leg Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `sla_commitment_id` SET TAGS ('dbx_business_glossary_term' = 'Contract Sla Commitment Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `sla_entitlement_id` SET TAGS ('dbx_business_glossary_term' = 'Sla Entitlement Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `transport_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Transport Asset Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `assigned_to_team` SET TAGS ('dbx_business_glossary_term' = 'Assigned To Team');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `claim_eligible_flag` SET TAGS ('dbx_business_glossary_term' = 'Claim Eligible Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `customer_notification_channel` SET TAGS ('dbx_business_glossary_term' = 'Customer Notification Channel');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `customer_notification_channel` SET TAGS ('dbx_value_regex' = 'EMAIL|SMS|PHONE|PORTAL|API|EDI');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `customer_notification_sent_flag` SET TAGS ('dbx_business_glossary_term' = 'Customer Notification Sent Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `customer_notification_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Customer Notification Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `delay_duration_hours` SET TAGS ('dbx_business_glossary_term' = 'Delay Duration Hours');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `escalation_flag` SET TAGS ('dbx_business_glossary_term' = 'Escalation Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `escalation_tier` SET TAGS ('dbx_business_glossary_term' = 'Escalation Tier');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `escalation_tier` SET TAGS ('dbx_value_regex' = 'TIER_1|TIER_2|TIER_3|EXECUTIVE');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `escalation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Escalation Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `estimated_recovery_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Estimated Recovery Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `exception_location_country_code` SET TAGS ('dbx_business_glossary_term' = 'Exception Location Country Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `exception_location_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `exception_location_name` SET TAGS ('dbx_business_glossary_term' = 'Exception Location Name');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `exception_notes` SET TAGS ('dbx_business_glossary_term' = 'Exception Notes');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `exception_number` SET TAGS ('dbx_business_glossary_term' = 'Exception Number');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `exception_raised_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Exception Raised Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `exception_status` SET TAGS ('dbx_business_glossary_term' = 'Exception Status');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `exception_status` SET TAGS ('dbx_value_regex' = 'OPEN|IN_PROGRESS|RESOLVED|CLOSED|ESCALATED|CANCELLED');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `exception_type` SET TAGS ('dbx_business_glossary_term' = 'Exception Type');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `financial_impact_amount` SET TAGS ('dbx_business_glossary_term' = 'Financial Impact Amount');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `financial_impact_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `financial_impact_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Financial Impact Currency Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `financial_impact_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `preventable_flag` SET TAGS ('dbx_business_glossary_term' = 'Preventable Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `recurrence_flag` SET TAGS ('dbx_business_glossary_term' = 'Recurrence Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `resolution_action_code` SET TAGS ('dbx_business_glossary_term' = 'Resolution Action Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `resolution_action_description` SET TAGS ('dbx_business_glossary_term' = 'Resolution Action Description');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `resolution_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Resolution Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `responsible_party` SET TAGS ('dbx_business_glossary_term' = 'Responsible Party');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `root_cause_code` SET TAGS ('dbx_business_glossary_term' = 'Root Cause Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `root_cause_description` SET TAGS ('dbx_business_glossary_term' = 'Root Cause Description');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `severity_level` SET TAGS ('dbx_business_glossary_term' = 'Severity Level');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `severity_level` SET TAGS ('dbx_value_regex' = 'CRITICAL|HIGH|MEDIUM|LOW');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `sla_breach_flag` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) Breach Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `sla_breach_type` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) Breach Type');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `sla_breach_type` SET TAGS ('dbx_value_regex' = 'DELIVERY_TIME|PICKUP_TIME|TRANSIT_TIME|NOTIFICATION|NONE');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `source_system` SET TAGS ('dbx_business_glossary_term' = 'Source System');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `source_system` SET TAGS ('dbx_value_regex' = 'FOURKITES|ORACLE_TMS|SAP_TM|CARRIER_API|MANUAL');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`exception_event` ALTER COLUMN `source_system_reference_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Reference ID');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` SET TAGS ('dbx_subdomain' = 'booking_management');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `consignment_status_id` SET TAGS ('dbx_business_glossary_term' = 'Consignment Status ID');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `carrier_id` SET TAGS ('dbx_business_glossary_term' = 'Carrier ID');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `consignment_id` SET TAGS ('dbx_business_glossary_term' = 'Consignment ID');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `declaration_id` SET TAGS ('dbx_business_glossary_term' = 'Declaration Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `driver_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Driver Profile Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `facility_id` SET TAGS ('dbx_business_glossary_term' = 'Facility ID');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `fulfillment_order_id` SET TAGS ('dbx_business_glossary_term' = 'Fulfillment Order Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `network_node_id` SET TAGS ('dbx_business_glossary_term' = 'Network Node Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `shipment_leg_id` SET TAGS ('dbx_business_glossary_term' = 'Shipment Leg Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `transport_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Transport Asset Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `customs_cleared_flag` SET TAGS ('dbx_business_glossary_term' = 'Customs Cleared Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `delay_duration_minutes` SET TAGS ('dbx_business_glossary_term' = 'Delay Duration Minutes');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `device_code` SET TAGS ('dbx_business_glossary_term' = 'Device ID');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `device_code` SET TAGS ('dbx_internal' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `device_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `dwell_time_minutes` SET TAGS ('dbx_business_glossary_term' = 'Dwell Time Minutes');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `eta_updated_flag` SET TAGS ('dbx_business_glossary_term' = 'Estimated Time of Arrival (ETA) Updated Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `exception_flag` SET TAGS ('dbx_business_glossary_term' = 'Exception Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `external_reference_code` SET TAGS ('dbx_business_glossary_term' = 'External Reference ID');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `geolocation_latitude` SET TAGS ('dbx_business_glossary_term' = 'Geolocation Latitude');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `geolocation_latitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `geolocation_latitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `geolocation_longitude` SET TAGS ('dbx_business_glossary_term' = 'Geolocation Longitude');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `geolocation_longitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `geolocation_longitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `humidity_percentage` SET TAGS ('dbx_business_glossary_term' = 'Humidity Percentage');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `milestone_code` SET TAGS ('dbx_business_glossary_term' = 'Milestone Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `new_eta_timestamp` SET TAGS ('dbx_business_glossary_term' = 'New Estimated Time of Arrival (ETA) Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `new_status_code` SET TAGS ('dbx_business_glossary_term' = 'New Status Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `notification_channel` SET TAGS ('dbx_business_glossary_term' = 'Notification Channel');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `notification_channel` SET TAGS ('dbx_value_regex' = 'EMAIL|SMS|PUSH|PORTAL|NONE');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `notification_sent_flag` SET TAGS ('dbx_business_glossary_term' = 'Notification Sent Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `photo_captured_flag` SET TAGS ('dbx_business_glossary_term' = 'Photo Captured Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `planned_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Planned Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `previous_status_code` SET TAGS ('dbx_business_glossary_term' = 'Previous Status Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `record_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `route_deviation_flag` SET TAGS ('dbx_business_glossary_term' = 'Route Deviation Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `scan_type` SET TAGS ('dbx_business_glossary_term' = 'Scan Type');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `scan_type` SET TAGS ('dbx_value_regex' = 'BARCODE|RFID|MANUAL|GPS|API');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `signature_captured_flag` SET TAGS ('dbx_business_glossary_term' = 'Signature Captured Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `sla_breach_flag` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) Breach Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'SAP_TM|ORACLE_TMS|MANHATTAN_WMS|FOURKITES|CARRIER_EDI|MOBILE_APP');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `status_notes` SET TAGS ('dbx_business_glossary_term' = 'Status Notes');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `status_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Status Reason Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `status_transition_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Status Transition Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `temperature_celsius` SET TAGS ('dbx_business_glossary_term' = 'Temperature Celsius');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `triggered_by_source` SET TAGS ('dbx_business_glossary_term' = 'Triggered By Source');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`consignment_status` ALTER COLUMN `triggered_by_source` SET TAGS ('dbx_value_regex' = 'SYSTEM|USER|CARRIER_EDI|API|MOBILE_APP|WMS');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` SET TAGS ('dbx_subdomain' = 'booking_management');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `package_id` SET TAGS ('dbx_business_glossary_term' = 'Shipment Package ID');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `cargo_id` SET TAGS ('dbx_business_glossary_term' = 'Cargo Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `consignment_id` SET TAGS ('dbx_business_glossary_term' = 'Shipment ID');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `container_unit_id` SET TAGS ('dbx_business_glossary_term' = 'Container Unit Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `dim_weight_rule_id` SET TAGS ('dbx_business_glossary_term' = 'Dim Weight Rule Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `handling_unit_id` SET TAGS ('dbx_business_glossary_term' = 'Handling Unit Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `pack_task_id` SET TAGS ('dbx_business_glossary_term' = 'Pack Task Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `parcel_id` SET TAGS ('dbx_business_glossary_term' = 'Parcel Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `shipment_leg_id` SET TAGS ('dbx_business_glossary_term' = 'Shipment Leg Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `storage_location_id` SET TAGS ('dbx_business_glossary_term' = 'Storage Location Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `transport_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Transport Asset Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `actual_delivery_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Actual Delivery Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `actual_weight_kg` SET TAGS ('dbx_business_glossary_term' = 'Actual Weight (Kilograms)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `barcode_number` SET TAGS ('dbx_business_glossary_term' = 'Package Barcode Number');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `chargeable_weight_kg` SET TAGS ('dbx_business_glossary_term' = 'Chargeable Weight (Kilograms)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `contents_description` SET TAGS ('dbx_business_glossary_term' = 'Package Contents Description');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `current_location_code` SET TAGS ('dbx_business_glossary_term' = 'Current Location Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `dangerous_goods_flag` SET TAGS ('dbx_business_glossary_term' = 'Dangerous Goods (DG) Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `declared_value_amount` SET TAGS ('dbx_business_glossary_term' = 'Declared Value Amount');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `declared_value_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `declared_value_currency` SET TAGS ('dbx_business_glossary_term' = 'Declared Value Currency Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `delivery_signature_name` SET TAGS ('dbx_business_glossary_term' = 'Delivery Signature Name');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `delivery_signature_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `delivery_signature_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `estimated_delivery_date` SET TAGS ('dbx_business_glossary_term' = 'Estimated Delivery Date');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `exception_code` SET TAGS ('dbx_business_glossary_term' = 'Exception Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `exception_description` SET TAGS ('dbx_business_glossary_term' = 'Exception Description');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `fragile_flag` SET TAGS ('dbx_business_glossary_term' = 'Fragile Handling Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `height_cm` SET TAGS ('dbx_business_glossary_term' = 'Package Height (Centimeters)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `hs_code` SET TAGS ('dbx_business_glossary_term' = 'Harmonized System (HS) Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `insurance_amount` SET TAGS ('dbx_business_glossary_term' = 'Insurance Coverage Amount');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `insurance_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `insurance_currency` SET TAGS ('dbx_business_glossary_term' = 'Insurance Currency Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `insurance_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Insurance Required Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `last_scan_location_code` SET TAGS ('dbx_business_glossary_term' = 'Last Scan Location Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `last_scan_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Scan Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `length_cm` SET TAGS ('dbx_business_glossary_term' = 'Package Length (Centimeters)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `max_stack_weight_kg` SET TAGS ('dbx_business_glossary_term' = 'Maximum Stack Weight (Kilograms)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `package_status` SET TAGS ('dbx_business_glossary_term' = 'Package Status');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `package_type` SET TAGS ('dbx_business_glossary_term' = 'Package Type');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `pod_image_url` SET TAGS ('dbx_business_glossary_term' = 'Proof of Delivery (POD) Image URL');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Package Sequence Number');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `source_system` SET TAGS ('dbx_business_glossary_term' = 'Source System');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `source_system` SET TAGS ('dbx_value_regex' = 'manhattan_wms|oracle_tms|sap_tm|fourkites|manual_entry');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `special_handling_instructions` SET TAGS ('dbx_business_glossary_term' = 'Special Handling Instructions');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `stackable_flag` SET TAGS ('dbx_business_glossary_term' = 'Stackable Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `temperature_controlled_flag` SET TAGS ('dbx_business_glossary_term' = 'Temperature-Controlled Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `temperature_range_max_c` SET TAGS ('dbx_business_glossary_term' = 'Maximum Temperature Range (Celsius)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `temperature_range_min_c` SET TAGS ('dbx_business_glossary_term' = 'Minimum Temperature Range (Celsius)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `un_number` SET TAGS ('dbx_business_glossary_term' = 'United Nations (UN) Number');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `volume_cbm` SET TAGS ('dbx_business_glossary_term' = 'Package Volume (Cubic Meters) - CBM');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `volumetric_weight_kg` SET TAGS ('dbx_business_glossary_term' = 'Volumetric Weight (Kilograms) - DIM Weight');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`package` ALTER COLUMN `width_cm` SET TAGS ('dbx_business_glossary_term' = 'Package Width (Centimeters)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` SET TAGS ('dbx_subdomain' = 'transport_execution');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `shipment_carrier_assignment_id` SET TAGS ('dbx_business_glossary_term' = 'Shipment Carrier Assignment ID');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `agent_id` SET TAGS ('dbx_business_glossary_term' = 'Agent Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Contract ID');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `booking_id` SET TAGS ('dbx_business_glossary_term' = 'Booking Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `carrier_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Carrier Agreement Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `carrier_buy_rate_id` SET TAGS ('dbx_business_glossary_term' = 'Carrier Buy Rate Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `carrier_id` SET TAGS ('dbx_business_glossary_term' = 'Carrier ID');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `carrier_payable_id` SET TAGS ('dbx_business_glossary_term' = 'Carrier Payable Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `carrier_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Carrier Schedule Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `carrier_service_id` SET TAGS ('dbx_business_glossary_term' = 'Carrier Service Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `consignment_id` SET TAGS ('dbx_business_glossary_term' = 'Shipment ID');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `contract_rate_id` SET TAGS ('dbx_business_glossary_term' = 'Contract Rate Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `driver_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Driver Profile Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `rate_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Rate Schedule Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `shipment_leg_id` SET TAGS ('dbx_business_glossary_term' = 'Shipment Leg ID');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `supplier_id` SET TAGS ('dbx_business_glossary_term' = 'Supplier Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `tpl_provider_id` SET TAGS ('dbx_business_glossary_term' = 'Tpl Provider Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `transport_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Transport Asset Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `trip_id` SET TAGS ('dbx_business_glossary_term' = 'Trip Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `actual_arrival_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Actual Arrival Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `actual_departure_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Actual Departure Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `assignment_date` SET TAGS ('dbx_business_glossary_term' = 'Assignment Date');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `assignment_method` SET TAGS ('dbx_business_glossary_term' = 'Assignment Method');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `assignment_method` SET TAGS ('dbx_value_regex' = 'auto_optimized|manual_override|contract_based|spot_market|tender|preferred_carrier');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `assignment_status` SET TAGS ('dbx_business_glossary_term' = 'Assignment Status');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `assignment_status` SET TAGS ('dbx_value_regex' = 'confirmed|tentative|cancelled|pending|rejected|expired');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `assignment_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Assignment Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `cancelled_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Cancelled Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `carrier_iata_code` SET TAGS ('dbx_business_glossary_term' = 'International Air Transport Association (IATA) Carrier Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `carrier_iata_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,3}$');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `carrier_performance_rating` SET TAGS ('dbx_business_glossary_term' = 'Carrier Performance Rating');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `carrier_scac_code` SET TAGS ('dbx_business_glossary_term' = 'Standard Carrier Alpha Code (SCAC)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `carrier_scac_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2,4}$');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `confirmed_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Confirmed Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `contract_rate_flag` SET TAGS ('dbx_business_glossary_term' = 'Contract Rate Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `equipment_type` SET TAGS ('dbx_business_glossary_term' = 'Equipment Type');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `estimated_arrival_date` SET TAGS ('dbx_business_glossary_term' = 'Estimated Time of Arrival (ETA) Date');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `estimated_departure_date` SET TAGS ('dbx_business_glossary_term' = 'Estimated Time of Departure (ETD) Date');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `flight_number` SET TAGS ('dbx_business_glossary_term' = 'Flight Number');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `fuel_surcharge_amount` SET TAGS ('dbx_business_glossary_term' = 'Fuel Surcharge Amount');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `mode_of_transport` SET TAGS ('dbx_business_glossary_term' = 'Mode of Transport');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `mode_of_transport` SET TAGS ('dbx_value_regex' = 'air|ocean|road|rail|multimodal|courier');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Assignment Notes');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `on_time_delivery_flag` SET TAGS ('dbx_business_glossary_term' = 'On-Time Delivery (OTD) Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `rate_amount` SET TAGS ('dbx_business_glossary_term' = 'Rate Amount');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `rate_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Rate Currency Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `rate_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `rate_unit_of_measure` SET TAGS ('dbx_business_glossary_term' = 'Rate Unit of Measure');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `seal_number` SET TAGS ('dbx_business_glossary_term' = 'Seal Number');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `service_type` SET TAGS ('dbx_business_glossary_term' = 'Service Type');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `total_carrier_charge` SET TAGS ('dbx_business_glossary_term' = 'Total Carrier Charge');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `train_number` SET TAGS ('dbx_business_glossary_term' = 'Train Number');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `vessel_imo_number` SET TAGS ('dbx_business_glossary_term' = 'International Maritime Organization (IMO) Vessel Number');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `vessel_imo_number` SET TAGS ('dbx_value_regex' = '^IMO[0-9]{7}$');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `vessel_name` SET TAGS ('dbx_business_glossary_term' = 'Vessel Name');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_carrier_assignment` ALTER COLUMN `voyage_number` SET TAGS ('dbx_business_glossary_term' = 'Voyage Number');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` SET TAGS ('dbx_subdomain' = 'delivery_operations');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` ALTER COLUMN `delivery_instruction_id` SET TAGS ('dbx_business_glossary_term' = 'Delivery Instruction ID');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` ALTER COLUMN `address_book_id` SET TAGS ('dbx_business_glossary_term' = 'Alternative Address Book Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` ALTER COLUMN `address_book_id` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` ALTER COLUMN `address_book_id` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` ALTER COLUMN `consignment_id` SET TAGS ('dbx_business_glossary_term' = 'Shipment ID');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` ALTER COLUMN `contact_id` SET TAGS ('dbx_business_glossary_term' = 'Customer Contact Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` ALTER COLUMN `agent_id` SET TAGS ('dbx_business_glossary_term' = 'Delivery Agent Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` ALTER COLUMN `last_mile_dispatch_id` SET TAGS ('dbx_business_glossary_term' = 'Last Mile Dispatch Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` ALTER COLUMN `authority_to_leave_flag` SET TAGS ('dbx_business_glossary_term' = 'Authority To Leave Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` ALTER COLUMN `delivery_notification_preference` SET TAGS ('dbx_business_glossary_term' = 'Delivery Notification Preference');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` ALTER COLUMN `delivery_notification_preference` SET TAGS ('dbx_value_regex' = 'SMS|EMAIL|PHONE_CALL|MOBILE_APP|NONE');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` ALTER COLUMN `id_verification_required_flag` SET TAGS ('dbx_business_glossary_term' = 'ID Verification Required Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` ALTER COLUMN `instruction_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Instruction Effective Date');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` ALTER COLUMN `instruction_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Instruction Expiry Date');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` ALTER COLUMN `instruction_priority` SET TAGS ('dbx_business_glossary_term' = 'Instruction Priority');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` ALTER COLUMN `instruction_priority` SET TAGS ('dbx_value_regex' = 'HIGH|MEDIUM|LOW');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` ALTER COLUMN `instruction_source` SET TAGS ('dbx_business_glossary_term' = 'Instruction Source');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` ALTER COLUMN `instruction_source` SET TAGS ('dbx_value_regex' = 'SHIPPER|CONSIGNEE|CUSTOMER_PORTAL|CALL_CENTER|MOBILE_APP|EDI');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` ALTER COLUMN `instruction_status` SET TAGS ('dbx_business_glossary_term' = 'Instruction Status');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` ALTER COLUMN `instruction_status` SET TAGS ('dbx_value_regex' = 'ACTIVE|CANCELLED|COMPLETED|SUPERSEDED|PENDING');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` ALTER COLUMN `instruction_type` SET TAGS ('dbx_business_glossary_term' = 'Delivery Instruction Type');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` ALTER COLUMN `instruction_type` SET TAGS ('dbx_value_regex' = 'LEAVE_AT_DOOR|REQUIRE_SIGNATURE|DELIVER_TO_NEIGHBOUR|LOCKER_DELIVERY|APPOINTMENT_REQUIRED|CALL_BEFORE_DELIVERY');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` ALTER COLUMN `last_modified_by` SET TAGS ('dbx_business_glossary_term' = 'Last Modified By');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` ALTER COLUMN `locker_code` SET TAGS ('dbx_business_glossary_term' = 'Locker ID');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` ALTER COLUMN `locker_location_code` SET TAGS ('dbx_business_glossary_term' = 'Locker Location Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` ALTER COLUMN `minimum_age_requirement` SET TAGS ('dbx_business_glossary_term' = 'Minimum Age Requirement');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` ALTER COLUMN `neighbour_delivery_allowed_flag` SET TAGS ('dbx_business_glossary_term' = 'Neighbour Delivery Allowed Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` ALTER COLUMN `preferred_delivery_date` SET TAGS ('dbx_business_glossary_term' = 'Preferred Delivery Date');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` ALTER COLUMN `preferred_neighbour_address` SET TAGS ('dbx_business_glossary_term' = 'Preferred Neighbour Address');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` ALTER COLUMN `preferred_neighbour_address` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` ALTER COLUMN `preferred_neighbour_address` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` ALTER COLUMN `preferred_time_window_end` SET TAGS ('dbx_business_glossary_term' = 'Preferred Time Window End');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` ALTER COLUMN `preferred_time_window_start` SET TAGS ('dbx_business_glossary_term' = 'Preferred Time Window Start');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` ALTER COLUMN `return_if_absent_flag` SET TAGS ('dbx_business_glossary_term' = 'Return If Absent Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` ALTER COLUMN `safe_place_description` SET TAGS ('dbx_business_glossary_term' = 'Safe Place Description');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` ALTER COLUMN `signature_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Signature Required Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` ALTER COLUMN `signature_type` SET TAGS ('dbx_business_glossary_term' = 'Signature Type');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` ALTER COLUMN `signature_type` SET TAGS ('dbx_value_regex' = 'CONSIGNEE|ADULT|INDIRECT|ELECTRONIC');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` ALTER COLUMN `special_access_instructions` SET TAGS ('dbx_business_glossary_term' = 'Special Access Instructions');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` ALTER COLUMN `special_handling_notes` SET TAGS ('dbx_business_glossary_term' = 'Special Handling Notes');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`delivery_instruction` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` SET TAGS ('dbx_subdomain' = 'booking_management');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `shipment_charge_id` SET TAGS ('dbx_business_glossary_term' = 'Shipment Charge ID');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `accessorial_charge_id` SET TAGS ('dbx_business_glossary_term' = 'Accessorial Charge Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Agreement Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `billing_account_id` SET TAGS ('dbx_business_glossary_term' = 'Payer Account ID');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `cargo_claim_id` SET TAGS ('dbx_business_glossary_term' = 'Cargo Claim Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `carrier_id` SET TAGS ('dbx_business_glossary_term' = 'Carrier Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `consignment_id` SET TAGS ('dbx_business_glossary_term' = 'Shipment ID');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `contract_surcharge_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Contract Surcharge Schedule Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `credit_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Credit Profile Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `declaration_id` SET TAGS ('dbx_business_glossary_term' = 'Declaration Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `dim_weight_rule_id` SET TAGS ('dbx_business_glossary_term' = 'Dim Weight Rule Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `duty_assessment_id` SET TAGS ('dbx_business_glossary_term' = 'Duty Assessment ID');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `invoice_id` SET TAGS ('dbx_business_glossary_term' = 'Invoice Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `package_id` SET TAGS ('dbx_business_glossary_term' = 'Shipment Package Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `penalty_clause_id` SET TAGS ('dbx_business_glossary_term' = 'Penalty Clause Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `charge_code_id` SET TAGS ('dbx_business_glossary_term' = 'Pricing Charge Code Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `purchase_order_id` SET TAGS ('dbx_business_glossary_term' = 'Purchase Order Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `rate_line_id` SET TAGS ('dbx_business_glossary_term' = 'Rate Line Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `rate_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Rate Schedule Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `shipment_leg_id` SET TAGS ('dbx_business_glossary_term' = 'Shipment Leg Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `supplier_invoice_id` SET TAGS ('dbx_business_glossary_term' = 'Supplier Invoice Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `surcharge_id` SET TAGS ('dbx_business_glossary_term' = 'Surcharge Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `tariff_id` SET TAGS ('dbx_business_glossary_term' = 'Tariff Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `tax_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Tax Schedule Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `amount` SET TAGS ('dbx_business_glossary_term' = 'Charge Amount');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `application_level` SET TAGS ('dbx_business_glossary_term' = 'Charge Application Level');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `application_level` SET TAGS ('dbx_value_regex' = 'shipment|leg|package|container|pallet');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `approval_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Approval Required Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `audit_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Audit Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `basis` SET TAGS ('dbx_business_glossary_term' = 'Charge Basis');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `billable_weight_kg` SET TAGS ('dbx_business_glossary_term' = 'Billable Weight (Kilograms)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `calculation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Charge Calculation Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `charge_category` SET TAGS ('dbx_business_glossary_term' = 'Charge Category');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `charge_description` SET TAGS ('dbx_business_glossary_term' = 'Charge Description');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `charge_status` SET TAGS ('dbx_business_glossary_term' = 'Charge Status');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `discount_amount` SET TAGS ('dbx_business_glossary_term' = 'Discount Amount');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `dispute_flag` SET TAGS ('dbx_business_glossary_term' = 'Dispute Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `dispute_reason` SET TAGS ('dbx_business_glossary_term' = 'Dispute Reason');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `net_charge_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Charge Amount');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `origin_system` SET TAGS ('dbx_business_glossary_term' = 'Charge Origin System');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `payment_term_code` SET TAGS ('dbx_business_glossary_term' = 'Payment Term Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `payment_term_code` SET TAGS ('dbx_value_regex' = 'prepaid|collect|third_party|freight_collect|freight_prepaid');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `quantity` SET TAGS ('dbx_business_glossary_term' = 'Quantity');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `rate_per_unit` SET TAGS ('dbx_business_glossary_term' = 'Rate Per Unit');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `revenue_recognition_date` SET TAGS ('dbx_business_glossary_term' = 'Revenue Recognition Date');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `service_provider_name` SET TAGS ('dbx_business_glossary_term' = 'Service Provider Name');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Tax Amount');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `tax_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Tax Rate Percent');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `unit_of_measure` SET TAGS ('dbx_business_glossary_term' = 'Unit of Measure (UOM)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `waived_flag` SET TAGS ('dbx_business_glossary_term' = 'Waived Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_charge` ALTER COLUMN `waiver_reason` SET TAGS ('dbx_business_glossary_term' = 'Waiver Reason');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` SET TAGS ('dbx_subdomain' = 'transport_execution');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `freight_manifest_id` SET TAGS ('dbx_business_glossary_term' = 'Freight Manifest ID');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `air_waybill_id` SET TAGS ('dbx_business_glossary_term' = 'Air Waybill Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `ams_filing_id` SET TAGS ('dbx_business_glossary_term' = 'Ams Filing Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `bill_of_lading_id` SET TAGS ('dbx_business_glossary_term' = 'Bill Of Lading Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `carrier_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Carrier Agreement Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `carrier_id` SET TAGS ('dbx_business_glossary_term' = 'Carrier Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `carrier_service_id` SET TAGS ('dbx_business_glossary_term' = 'Carrier Service Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `consolidation_id` SET TAGS ('dbx_business_glossary_term' = 'Consolidation Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `declaration_id` SET TAGS ('dbx_business_glossary_term' = 'Declaration Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `dock_appointment_id` SET TAGS ('dbx_business_glossary_term' = 'Dock Appointment Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `driver_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Driver Profile Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `freight_leg_id` SET TAGS ('dbx_business_glossary_term' = 'Freight Leg Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `center_id` SET TAGS ('dbx_business_glossary_term' = 'Fulfillment Center Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `depot_id` SET TAGS ('dbx_business_glossary_term' = 'Origin Depot Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `facility_id` SET TAGS ('dbx_business_glossary_term' = 'Origin Facility Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `network_node_id` SET TAGS ('dbx_business_glossary_term' = 'Origin Network Node Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `parcel_manifest_id` SET TAGS ('dbx_business_glossary_term' = 'Parcel Manifest Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `service_corridor_id` SET TAGS ('dbx_business_glossary_term' = 'Service Corridor Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `transport_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Transport Asset Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `trip_id` SET TAGS ('dbx_business_glossary_term' = 'Trip Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `actual_arrival_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Actual Arrival Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `actual_departure_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Actual Departure Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `carbon_emissions_kg` SET TAGS ('dbx_business_glossary_term' = 'Carbon Emissions in Kilograms (CO2e)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `customs_clearance_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Customs Clearance Required Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `dangerous_goods_flag` SET TAGS ('dbx_business_glossary_term' = 'Dangerous Goods (DG) Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `delay_duration_minutes` SET TAGS ('dbx_business_glossary_term' = 'Delay Duration in Minutes');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `delay_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Delay Reason Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `destination_facility_code` SET TAGS ('dbx_business_glossary_term' = 'Destination Facility Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `destination_facility_name` SET TAGS ('dbx_business_glossary_term' = 'Destination Facility Name');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `equipment_type_code` SET TAGS ('dbx_business_glossary_term' = 'Equipment Type Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `flight_number` SET TAGS ('dbx_business_glossary_term' = 'Flight Number');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `gps_tracking_enabled_flag` SET TAGS ('dbx_business_glossary_term' = 'GPS Tracking Enabled Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `load_plan_reference` SET TAGS ('dbx_business_glossary_term' = 'Load Plan Reference');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `manifest_closed_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Manifest Closed Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `manifest_completed_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Manifest Completed Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `manifest_cost_amount` SET TAGS ('dbx_business_glossary_term' = 'Manifest Cost Amount');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `manifest_cost_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Manifest Cost Currency Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `manifest_cost_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `manifest_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Manifest Created Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `manifest_number` SET TAGS ('dbx_business_glossary_term' = 'Manifest Number');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `manifest_status` SET TAGS ('dbx_business_glossary_term' = 'Manifest Status');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `planned_arrival_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Planned Arrival Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `planned_departure_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Planned Departure Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `predicted_eta_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Predicted Estimated Time of Arrival (ETA) Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `seal_number` SET TAGS ('dbx_business_glossary_term' = 'Carrier Seal Number');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `temperature_controlled_flag` SET TAGS ('dbx_business_glossary_term' = 'Temperature Controlled Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `total_chargeable_weight_kg` SET TAGS ('dbx_business_glossary_term' = 'Total Chargeable Weight in Kilograms (kg)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `total_consignments` SET TAGS ('dbx_business_glossary_term' = 'Total Consignments');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `total_pieces` SET TAGS ('dbx_business_glossary_term' = 'Total Pieces');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `total_volume_cbm` SET TAGS ('dbx_business_glossary_term' = 'Total Volume in Cubic Meters (CBM)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `total_weight_kg` SET TAGS ('dbx_business_glossary_term' = 'Total Weight in Kilograms (kg)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `transport_mode` SET TAGS ('dbx_business_glossary_term' = 'Transport Mode');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `transport_mode` SET TAGS ('dbx_value_regex' = 'air|ocean|road|rail|multimodal|parcel');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `vessel_name` SET TAGS ('dbx_business_glossary_term' = 'Vessel Name');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`freight_manifest` ALTER COLUMN `voyage_number` SET TAGS ('dbx_business_glossary_term' = 'Voyage Number');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` SET TAGS ('dbx_subdomain' = 'booking_management');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `shipment_document_id` SET TAGS ('dbx_business_glossary_term' = 'Shipment Document ID');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Agreement Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `agreement_version_id` SET TAGS ('dbx_business_glossary_term' = 'Agreement Version Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `air_waybill_id` SET TAGS ('dbx_business_glossary_term' = 'Air Waybill Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `bill_of_lading_id` SET TAGS ('dbx_business_glossary_term' = 'Bill Of Lading Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `certificate_of_origin_id` SET TAGS ('dbx_business_glossary_term' = 'Certificate Of Origin Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `consignment_id` SET TAGS ('dbx_business_glossary_term' = 'Consignment ID');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `declaration_id` SET TAGS ('dbx_business_glossary_term' = 'Related Declaration ID');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `fulfillment_order_id` SET TAGS ('dbx_business_glossary_term' = 'Fulfillment Order Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `license_permit_id` SET TAGS ('dbx_business_glossary_term' = 'License Permit Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `purchase_order_id` SET TAGS ('dbx_business_glossary_term' = 'Purchase Order Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `shipment_leg_id` SET TAGS ('dbx_business_glossary_term' = 'Shipment Leg Id (Foreign Key)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `superseded_by_document_shipment_document_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Document ID');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `compliance_flag` SET TAGS ('dbx_business_glossary_term' = 'Compliance Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `document_status` SET TAGS ('dbx_business_glossary_term' = 'Document Status');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `document_status` SET TAGS ('dbx_value_regex' = 'pending|submitted|approved|rejected|expired|cancelled');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `file_format` SET TAGS ('dbx_business_glossary_term' = 'Document File Format');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `file_format` SET TAGS ('dbx_value_regex' = 'PDF|JPEG|PNG|TIFF|XML|EDI');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `file_size_bytes` SET TAGS ('dbx_business_glossary_term' = 'Document File Size in Bytes');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `file_uri` SET TAGS ('dbx_business_glossary_term' = 'Document File Uniform Resource Identifier (URI)');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `file_uri` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `hash` SET TAGS ('dbx_business_glossary_term' = 'Document Hash');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `issue_date` SET TAGS ('dbx_business_glossary_term' = 'Issue Date');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `issuing_authority_name` SET TAGS ('dbx_business_glossary_term' = 'Issuing Authority Name');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `issuing_country_code` SET TAGS ('dbx_business_glossary_term' = 'Issuing Country Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `issuing_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `language_code` SET TAGS ('dbx_business_glossary_term' = 'Language Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `language_code` SET TAGS ('dbx_value_regex' = '^[a-z]{2}$');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `mandatory_flag` SET TAGS ('dbx_business_glossary_term' = 'Mandatory Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `reference_number` SET TAGS ('dbx_business_glossary_term' = 'Document Reference Number');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `rejection_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Rejection Reason Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `rejection_reason_code` SET TAGS ('dbx_value_regex' = 'INCOMPLETE|EXPIRED|INVALID|MISMATCH|ILLEGIBLE|UNAUTHORIZED');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `rejection_reason_description` SET TAGS ('dbx_business_glossary_term' = 'Rejection Reason Description');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `rejection_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Rejection Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `retention_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Retention Expiry Date');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `reviewed_by_authority_name` SET TAGS ('dbx_business_glossary_term' = 'Reviewed By Authority Name');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `submission_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Submission Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `translation_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Translation Required Flag');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `type_code` SET TAGS ('dbx_business_glossary_term' = 'Document Type Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `type_code` SET TAGS ('dbx_value_regex' = 'CINV|PLIST|COO|PHYTO|DGM|INSC');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `upload_source` SET TAGS ('dbx_business_glossary_term' = 'Upload Source');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `upload_source` SET TAGS ('dbx_value_regex' = 'shipper_portal|edi|api|email|manual|carrier_system');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `upload_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Upload Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`shipment_document` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`manifest_line` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`manifest_line` SET TAGS ('dbx_subdomain' = 'transport_execution');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`manifest_line` SET TAGS ('dbx_association_edges' = 'shipment.freight_manifest,shipment.consignment');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`manifest_line` ALTER COLUMN `manifest_line_id` SET TAGS ('dbx_business_glossary_term' = 'Manifest Line Identifier');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`manifest_line` ALTER COLUMN `consignment_id` SET TAGS ('dbx_business_glossary_term' = 'Manifest Line - Consignment Id');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`manifest_line` ALTER COLUMN `freight_manifest_id` SET TAGS ('dbx_business_glossary_term' = 'Manifest Line - Freight Manifest Id');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`manifest_line` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`manifest_line` ALTER COLUMN `handling_unit_type` SET TAGS ('dbx_business_glossary_term' = 'Handling Unit Type');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`manifest_line` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`manifest_line` ALTER COLUMN `line_sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Manifest Line Sequence Number');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`manifest_line` ALTER COLUMN `line_status` SET TAGS ('dbx_business_glossary_term' = 'Manifest Line Status');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`manifest_line` ALTER COLUMN `loaded_pieces` SET TAGS ('dbx_business_glossary_term' = 'Loaded Pieces Count');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`manifest_line` ALTER COLUMN `loaded_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Loaded Timestamp');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`manifest_line` ALTER COLUMN `loaded_volume_cbm` SET TAGS ('dbx_business_glossary_term' = 'Loaded Volume');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`manifest_line` ALTER COLUMN `loaded_weight_kg` SET TAGS ('dbx_business_glossary_term' = 'Loaded Weight');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`manifest_line` ALTER COLUMN `special_handling_code` SET TAGS ('dbx_business_glossary_term' = 'Special Handling Code');
ALTER TABLE `transport_shipping_ecm`.`shipment`.`manifest_line` ALTER COLUMN `unloaded_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Unloaded Timestamp');
