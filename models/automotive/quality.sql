-- Schema for Domain: quality | Business: Automotive | Version: v1_mvm
-- Generated on: 2026-05-07 02:20:10

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `automotive_ecm`.`quality` COMMENT 'End-to-end quality assurance and control across design, manufacturing, and field operations. Owns APQP plans, FMEA (Failure Mode and Effects Analysis), SPC (Statistical Process Control) data, inspection plans, quality audits, defect tracking, and PPM rates. Includes incoming material inspection, in-process quality gates, final vehicle PDI (Pre-Delivery Inspection), NCAP/WLTP test results, and corrective action (8D, 5-Why) processes. Supports IATF 16949 compliance.';

-- ========= TABLES =========
CREATE OR REPLACE TABLE `automotive_ecm`.`quality`.`apqp_plan` (
    `apqp_plan_id` BIGINT COMMENT 'System-generated unique identifier for the APQP plan record.',
    `fiscal_period_id` BIGINT COMMENT 'Foreign key linking to finance.fiscal_period. Business justification: APQP milestones and gate completions align with fiscal periods for quarterly reporting, financial planning, and program review cycles. Critical for tracking quality program progress against fiscal cal',
    `model_id` BIGINT COMMENT 'Foreign key linking to vehicle.model. Business justification: APQP planning is defined per vehicle model; linking APQP plan to model enables model‑specific quality goals and gate tracking.',
    `plant_id` BIGINT COMMENT 'Foreign key linking to manufacturing.plant. Business justification: APQP plans are plant-specific — launch quality planning is conducted per manufacturing plant. apqp_plan has no FK to manufacturing.plant. Plant-level APQP tracking is required for multi-plant program ',
    `platform_id` BIGINT COMMENT 'Foreign key linking to vehicle.platform. Business justification: APQP plans in automotive are scoped to vehicle platforms for new platform launches (IATF 16949). Platform-level APQP tracking drives gate reviews and quality milestones across all models sharing the p',
    `production_line_id` BIGINT COMMENT 'Foreign key linking to manufacturing.production_line. Business justification: APQP plans govern production line launch readiness. apqp_plan has no FK to manufacturing.production_line. Production-line-level APQP tracking is required for SOP readiness gates and IATF 16949 manufac',
    `project_id` BIGINT COMMENT 'Foreign key linking to finance.project. Business justification: APQP plans are executed as formal projects in automotive OEMs with project codes, budgets, and resource allocation. Critical for tracking APQP investment and milestone achievement within project portf',
    `sku_master_id` BIGINT COMMENT 'Foreign key linking to inventory.sku_master. Business justification: APQP plans are created for specific parts during new product introduction. PPAP submissions require part-specific APQP documentation including design records, process FMEAs, and control plans. Removes',
    `vehicle_program_id` BIGINT COMMENT 'Foreign key linking to engineering.vehicle_program. Business justification: APQP planning is executed per vehicle program; linking aligns plans with program metadata and eliminates program_name duplication.',
    `actual_ppm` DECIMAL(18,2) COMMENT 'Measured parts-per-million defect rate observed after validation.',
    `actual_release_date` DATE COMMENT 'Actual date when the product was released to production.',
    `apqp_phase` STRING COMMENT 'Current phase of the APQP process for the plan.. Valid values are `concept|design|process|validation|launch`',
    `classification_type` STRING COMMENT 'Category of the APQP plan based on product scope.. Valid values are `new_model|refresh|component|system`',
    `compliance_status` STRING COMMENT 'Current IATF 16949 compliance status of the APQP plan.. Valid values are `compliant|non_compliant|pending`',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when the APQP plan record was created in the system.',
    `documentation_link` STRING COMMENT 'URL or path to the primary APQP documentation repository.',
    `effective_from` DATE COMMENT 'Date when the APQP plan becomes effective.',
    `effective_until` DATE COMMENT 'Date when the APQP plan expires or is superseded (nullable).',
    `eop_date` DATE COMMENT 'Date when series production ended for the vehicle/program.',
    `gate_completion_date` DATE COMMENT 'Actual date when the milestone gate was completed.',
    `gate_due_date` DATE COMMENT 'Planned due date for the milestone gate.',
    `gate_status` STRING COMMENT 'Current status of the milestone gate.. Valid values are `open|closed|delayed|approved|rejected`',
    `lifecycle_status` STRING COMMENT 'Current lifecycle state of the APQP plan.. Valid values are `draft|active|suspended|completed|archived`',
    `milestone_gate` STRING COMMENT 'Specific APQP milestone gate associated with the plan.. Valid values are `gate1|gate2|gate3|gate4|gate5`',
    `mitigation_plan` STRING COMMENT 'Description of actions taken to mitigate identified risks.',
    `model_year` STRING COMMENT 'Model year (calendar year) of the vehicle model associated with the APQP plan.',
    `notes` STRING COMMENT 'Free-text field for additional comments or observations.',
    `owner_name` STRING COMMENT 'Name of the internal owner or manager of the APQP plan.',
    `plan_number` STRING COMMENT 'External business identifier assigned to the APQP plan, often used in documentation and reporting.',
    `quality_goal_ppm` DECIMAL(18,2) COMMENT 'Target parts-per-million defect rate defined for the APQP plan.',
    `responsible_team` STRING COMMENT 'Team or department accountable for executing the APQP plan.',
    `risk_assessment_date` DATE COMMENT 'Date when the risk assessment for the APQP plan was performed.',
    `risk_level` STRING COMMENT 'Overall risk classification for the APQP plan.. Valid values are `low|medium|high|critical`',
    `sop_date` DATE COMMENT 'Date when series production started for the vehicle/program.',
    `target_ppm` DECIMAL(18,2) COMMENT 'Planned PPM level to achieve during the APQP process.',
    `target_release_date` DATE COMMENT 'Planned date for the product release associated with the APQP plan.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time of the most recent update to the APQP plan record.',
    `version_number` STRING COMMENT 'Version identifier for the APQP plan record.',
    CONSTRAINT pk_apqp_plan PRIMARY KEY(`apqp_plan_id`)
) COMMENT 'Advanced Product Quality Planning master record governing the structured quality planning process for new vehicle programs and components. Tracks APQP phases (concept, design, process, validation, launch), milestone gates, responsible teams, and completion status per program/part. Aligns with IATF 16949 requirements and links to engineering change and SOP timelines.';

CREATE OR REPLACE TABLE `automotive_ecm`.`quality`.`fmea` (
    `fmea_id` BIGINT COMMENT 'System-generated unique identifier for the FMEA record.',
    `apqp_plan_id` BIGINT COMMENT 'Foreign key linking to quality.apqp_plan. Business justification: FMEA is a core APQP deliverable in IATF 16949. Every FMEA is produced within the context of an APQP plan (Design FMEA and Process FMEA are required APQP outputs). Linking fmea.apqp_plan_id → apqp_plan',
    `characteristic_id` BIGINT COMMENT 'Foreign key linking to quality.characteristic. Business justification: FMEA analyzes specific product or process characteristics (CTQ/CTC characteristics). Each FMEA record focuses on the failure modes of a specific characteristic. Linking fmea.characteristic_id → charac',
    `design_specification_id` BIGINT COMMENT 'Foreign key linking to engineering.design_specification. Business justification: FMEA is performed based on design specs; linking provides traceability for risk analysis reports.',
    `model_id` BIGINT COMMENT 'Foreign key linking to vehicle.model. Business justification: FMEAs are authored at vehicle model level per AIAG-VDA FMEA methodology and IATF 16949. Model-scoped FMEA reports are required for design reviews and regulatory submissions. No existing model_id on fm',
    `production_line_id` BIGINT COMMENT 'Foreign key linking to manufacturing.production_line. Business justification: Process FMEAs (PFMEA) are developed for specific production lines per IATF 16949 APQP requirements. fmea has no FK to manufacturing.production_line. PFMEA-to-production-line linkage is required for pr',
    `project_id` BIGINT COMMENT 'Foreign key linking to finance.project. Business justification: FMEAs (DFMEA/PFMEA) are key deliverables within product development projects. Real automotive practice: FMEA completion tied to project milestones and gate reviews for budget release and program progr',
    `regulatory_requirement_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_requirement. Business justification: FMEA must be linked to applicable regulatory requirements to verify compliance of failure modes.',
    `sku_master_id` BIGINT COMMENT 'Foreign key linking to inventory.sku_master. Business justification: FMEA analyzes failure modes for specific parts/assemblies. Risk Priority Numbers (RPN), severity ratings, and mitigation plans are part-specific and required for APQP/PPAP submissions and ongoing risk',
    `work_center_id` BIGINT COMMENT 'Foreign key linking to manufacturing.work_center. Business justification: PFMEAs are developed at the operation/work-center level in automotive — each operation has failure modes analyzed. fmea has no FK to manufacturing.work_center. Work-center-level PFMEA is the primary I',
    `actual_completion_date` DATE COMMENT 'Date the recommended action was actually completed.',
    `analysis_number` STRING COMMENT 'External reference number assigned to the FMEA analysis, used for tracking across systems.',
    `analysis_type` STRING COMMENT 'Indicates whether the FMEA is a Design FMEA (DFMEA) or Process FMEA (PFMEA).. Valid values are `design|process`',
    `approval_date` DATE COMMENT 'Date the FMEA analysis received formal approval.',
    `approved_by` STRING COMMENT 'Name of the engineer or manager who approved the FMEA analysis.',
    `cause` STRING COMMENT 'Underlying cause(s) that could lead to the failure mode.',
    `control_effectiveness_rating` STRING COMMENT 'Score (1‑10) assessing how well the current control detects or prevents the failure.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the FMEA record was first created in the system.',
    `current_control` STRING COMMENT 'Description of existing controls that mitigate the failure mode.',
    `detection_description` STRING COMMENT 'Narrative explanation of the detection rating.',
    `detection_method` STRING COMMENT 'Method or technique used by the current control to detect the failure.',
    `detection_rating` STRING COMMENT 'Score (1‑10) indicating the ability of current controls to detect the failure before it reaches the customer.',
    `effective_from` DATE COMMENT 'Date from which the FMEA analysis is considered active.',
    `effective_until` DATE COMMENT 'Date after which the FMEA analysis is retired or superseded (nullable).',
    `failure_effect` STRING COMMENT 'Impact of the failure mode on vehicle performance, safety, or compliance.',
    `failure_mode` STRING COMMENT 'Description of the way the component could potentially fail.',
    `fmea_status` STRING COMMENT 'Current lifecycle status of the FMEA record.. Valid values are `open|closed|in_progress|deferred`',
    `notes` STRING COMMENT 'Free‑form comments or observations related to the FMEA.',
    `occurrence_description` STRING COMMENT 'Narrative explanation of the occurrence rating.',
    `occurrence_rating` STRING COMMENT 'Likelihood score (1‑10) that the cause will occur.',
    `recommended_action` STRING COMMENT 'Proposed corrective or preventive action to reduce severity, occurrence, or improve detection.',
    `revision_number` STRING COMMENT 'Version of the FMEA record after each update or re‑analysis.',
    `rpn` STRING COMMENT 'Calculated risk priority number (S × O × D) used to prioritize corrective actions.',
    `severity_description` STRING COMMENT 'Narrative explanation of the severity rating.',
    `severity_rating` STRING COMMENT 'Severity score (1‑10) reflecting seriousness of the failure effect.',
    `source_system` STRING COMMENT 'Originating source system for the FMEA record (e.g., Teamcenter PLM, SAP QM).',
    `subsystem` STRING COMMENT 'Higher‑level subsystem or system grouping the component belongs to (e.g., Powertrain, Chassis).',
    `target_completion_date` DATE COMMENT 'Planned date by which the recommended action should be completed.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the FMEA record.',
    CONSTRAINT pk_fmea PRIMARY KEY(`fmea_id`)
) COMMENT 'Failure Mode and Effects Analysis master record capturing potential failure modes, their effects, causes, current controls, severity/occurrence/detection ratings, and Risk Priority Numbers (RPN) for vehicle components, subsystems, and manufacturing processes. Supports both Design FMEA (DFMEA) and Process FMEA (PFMEA) per AIAG-VDA FMEA methodology. Tracks recommended actions and revised RPN after corrective actions.';

CREATE OR REPLACE TABLE `automotive_ecm`.`quality`.`control_plan` (
    `control_plan_id` BIGINT COMMENT 'Unique system-generated identifier for the quality control plan.',
    `apqp_plan_id` BIGINT COMMENT 'Foreign key linking to quality.apqp_plan. Business justification: Control plans are mandatory APQP deliverables (APQP Phase 3/4 output). Each control plan is produced under a governing APQP plan. Linking control_plan.apqp_plan_id → apqp_plan.apqp_plan_id enables ful',
    `design_specification_id` BIGINT COMMENT 'Foreign key linking to engineering.design_specification. Business justification: Control plans are derived from design specifications; FK enables automatic extraction of spec requirements for quality control.',
    `inspection_plan_id` BIGINT COMMENT 'Link to the detailed inspection plan referenced by this control plan.',
    `production_line_id` BIGINT COMMENT 'Foreign key linking to manufacturing.production_line. Business justification: Control plans are line‑specific for process control; required for the Production Control Review report.',
    `profit_center_id` BIGINT COMMENT 'Foreign key linking to finance.profit_center. Business justification: Control plans support production lines that roll up to profit centers. Essential for allocating quality control costs by profit center for P&L reporting and operational performance analysis.',
    `regulatory_requirement_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_requirement. Business justification: Control plans document process controls that satisfy specific regulatory requirements (ISO/TS 16949, FMVSS standards). Auditors and certification bodies require traceability from control plans to regu',
    `sku_master_id` BIGINT COMMENT 'Foreign key linking to inventory.sku_master. Business justification: Control plans specify inspection and control methods for manufactured parts. Real-world automotive control plans (per IATF 16949) reference the specific SKU/part number being controlled for process va',
    `vehicle_compound_id` BIGINT COMMENT 'Foreign key linking to logistics.vehicle_compound. Business justification: Control plans for finished vehicle PDI specify the compound location where inspections are performed. Automotive PDI control plans are compound-specific for process control and traceability.',
    `wbs_element_id` BIGINT COMMENT 'Foreign key linking to finance.wbs_element. Business justification: Control plans are project‑tracked in the WBS for capital budgeting and cost control.',
    `approval_date` DATE COMMENT 'Date when the control plan received final approval.',
    `approval_status` STRING COMMENT 'Current approval state of the control plan.. Valid values are `pending|approved|rejected|revoked`',
    `approved_by` STRING COMMENT 'Employee identifier who approved the control plan.',
    `change_control_number` STRING COMMENT 'Reference number for the change control record associated with this plan.',
    `control_method` STRING COMMENT 'Statistical or inspection method used to control the characteristic.. Valid values are `spc|attribute|visual|functional|dimensional`',
    `control_plan_description` STRING COMMENT 'Free‑text description of the purpose, scope, and key characteristics of the control plan.',
    `control_plan_status` STRING COMMENT 'Current lifecycle status of the control plan per IATF 16949.. Valid values are `draft|active|suspended|retired|archived`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the control plan record was first created in the system.',
    `effective_end_date` DATE COMMENT 'Date when the control plan is retired or superseded (null if open‑ended).',
    `effective_start_date` DATE COMMENT 'Date when the control plan becomes effective for production.',
    `is_mandatory` BOOLEAN COMMENT 'Indicates whether the control plan is mandatory for the operation.',
    `lower_spec_limit` DECIMAL(18,2) COMMENT 'Minimum acceptable value for the characteristic.',
    `measurement_unit` STRING COMMENT 'Unit of measure for the control characteristic (e.g., mm, psi). [ENUM-REF-CANDIDATE: mm|cm|inch|mm2|g|kg|psi|kpa|percent — 9 candidates stripped; promote to reference product]',
    `notes` STRING COMMENT 'Free‑form field for any supplemental information or comments.',
    `plan_name` STRING COMMENT 'Human‑readable name of the control plan.',
    `plan_number` STRING COMMENT 'Business identifier or code assigned to the control plan (e.g., CP‑2024‑001).',
    `plan_type` STRING COMMENT 'Category of manufacturing operation the plan applies to.. Valid values are `assembly|paint|engine|chassis|electrical|final`',
    `reaction_plan` STRING COMMENT 'Defined corrective actions if a measurement falls outside specification limits.',
    `responsible_function` STRING COMMENT 'Organizational function accountable for the control plan.. Valid values are `assembly_line|quality_engineering|process_engineering|manufacturing|test_lab`',
    `revision_date` DATE COMMENT 'Date when the current revision was released.',
    `revision_number` STRING COMMENT 'Sequential revision number of the control plan.',
    `sample_frequency` STRING COMMENT 'Frequency at which sampling is performed.. Valid values are `per_shift|per_batch|per_hour|per_day`',
    `sample_size` STRING COMMENT 'Number of units inspected per sampling event as defined by the plan.',
    `target_value` DECIMAL(18,2) COMMENT 'Desired nominal value for the controlled characteristic.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the control plan record.',
    `upper_spec_limit` DECIMAL(18,2) COMMENT 'Maximum acceptable value for the characteristic.',
    `created_by` STRING COMMENT 'Name or identifier of the employee who authored the control plan.',
    CONSTRAINT pk_control_plan PRIMARY KEY(`control_plan_id`)
) COMMENT 'Quality control plan defining the process controls, inspection methods, measurement systems, reaction plans, and control characteristics for each manufacturing operation or assembly step. Links to PFMEA and inspection plans. Specifies sample sizes, frequencies, control methods (SPC, attribute, visual), and responsible functions per IATF 16949 requirements.';

CREATE OR REPLACE TABLE `automotive_ecm`.`quality`.`inspection_plan` (
    `inspection_plan_id` BIGINT COMMENT 'Unique identifier for the inspection plan.',
    `apqp_plan_id` BIGINT COMMENT 'Foreign key linking to quality.apqp_plan. Business justification: Inspection plans are developed as part of the APQP process for new product launches. Linking inspection_plan.apqp_plan_id → apqp_plan.apqp_plan_id provides traceability of inspection planning activiti',
    `cost_center_id` BIGINT COMMENT 'Foreign key linking to finance.cost_center. Business justification: Inspection Cost Allocation report assigns inspection plan expenses to the responsible cost center.',
    `model_id` BIGINT COMMENT 'Foreign key linking to vehicle.model. Business justification: Inspection plans are authored per vehicle model (e.g., body-in-white, final assembly inspection for Model X). IATF 16949 requires model-traceable inspection plans. The existing plain-text vehicle_mod',
    `production_line_id` BIGINT COMMENT 'Foreign key linking to manufacturing.production_line. Business justification: Inspection plans are defined per production line to meet line‑specific quality standards; used in the Line Inspection Planning process.',
    `regulatory_requirement_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_requirement. Business justification: Inspection plans enforce testing protocols mandated by regulatory requirements (crash test sampling, emissions verification). The existing regulatory_compliance text field should be replaced with pr',
    `sku_master_id` BIGINT COMMENT 'Foreign key linking to inventory.sku_master. Business justification: Inspection plans define how to inspect specific parts/SKUs. Manufacturing quality operations require linking inspection procedures to the SKU being inspected. Removes denormalized part_number in favor',
    `vehicle_compound_id` BIGINT COMMENT 'Foreign key linking to logistics.vehicle_compound. Business justification: PDI inspection plans are executed at specific vehicle compounds. Business process: compound-based quality gate planning for finished vehicles before customer delivery.',
    `acceptance_criteria` STRING COMMENT 'Textual definition of pass/fail conditions.',
    `applicable_process` STRING COMMENT 'Manufacturing process to which the inspection plan applies.. Valid values are `IQC|IPQC|PDI|Final`',
    `approval_date` DATE COMMENT 'Date when the inspection plan was approved.',
    `approved_by` STRING COMMENT 'User identifier of the approver.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the inspection plan record was first created.',
    `criticality_level` STRING COMMENT 'Risk level associated with the inspection characteristic.. Valid values are `low|medium|high|critical`',
    `department_responsible` STRING COMMENT 'Organizational department owning the inspection plan.',
    `effective_end_date` DATE COMMENT 'Date when the inspection plan expires or is superseded (nullable).',
    `effective_start_date` DATE COMMENT 'Date when the inspection plan becomes effective.',
    `frequency` STRING COMMENT 'How often the inspection is performed.. Valid values are `per_batch|per_shift|per_vehicle|per_day`',
    `gauge_type` STRING COMMENT 'Specific gauge or instrument type used.. Valid values are `dial|digital|laser|micrometer`',
    `inspection_category` STRING COMMENT 'Broad category of the inspection activity.. Valid values are `dimensional|functional|visual|electrical`',
    `inspection_plan_description` STRING COMMENT 'Detailed description of the purpose and scope of the inspection plan.',
    `inspection_plan_status` STRING COMMENT 'Current lifecycle status of the inspection plan.. Valid values are `draft|active|inactive|retired`',
    `is_automated` BOOLEAN COMMENT 'Indicates whether the inspection is performed by automated equipment.',
    `last_review_date` DATE COMMENT 'Date of the most recent plan review.',
    `measurement_method` STRING COMMENT 'Technique used to perform the measurement.. Valid values are `CMM|Gauge|Visual|Automated|Manual`',
    `measurement_unit` STRING COMMENT 'Unit of measure for tolerances and results.. Valid values are `mm|cm|inch|mm^2|psi`',
    `model_year` STRING COMMENT 'Model year (calendar year) of the vehicle.',
    `notes` STRING COMMENT 'Free‑form comments or special instructions.',
    `plan_name` STRING COMMENT 'Human‑readable name of the inspection plan.',
    `plan_number` STRING COMMENT 'Business identifier assigned to the inspection plan.',
    `plan_type` STRING COMMENT 'Classification of the plan (e.g., incoming material, in‑process, final vehicle).. Valid values are `incoming_material|in_process|final_vehicle|custom`',
    `plant_location` STRING COMMENT 'Code of the manufacturing plant where the plan is executed.',
    `requires_approval` BOOLEAN COMMENT 'True if the inspection results must be formally approved.',
    `review_cycle_days` STRING COMMENT 'Number of days between mandatory reviews.',
    `revision_number` STRING COMMENT 'Sequential revision number for change tracking.',
    `sample_size` STRING COMMENT 'Number of units to be inspected per batch.',
    `tolerance_lower` DECIMAL(18,2) COMMENT 'Minimum acceptable measurement value.',
    `tolerance_upper` DECIMAL(18,2) COMMENT 'Maximum acceptable measurement value.',
    `updated_by` STRING COMMENT 'Identifier of the user who last modified the inspection plan.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the inspection plan.',
    `version` STRING COMMENT 'Version label of the inspection plan (e.g., v1.0, v2.1).',
    `created_by` STRING COMMENT 'Identifier of the user who created the inspection plan.',
    CONSTRAINT pk_inspection_plan PRIMARY KEY(`inspection_plan_id`)
) COMMENT 'Detailed inspection plan specifying the characteristics to be measured, measurement methods, gauges/instruments, tolerances, sample sizes, and acceptance criteria for incoming material, in-process, and final vehicle inspections. Supports incoming material inspection (IQC), in-process quality gates, and PDI (Pre-Delivery Inspection). Linked to SAP QM inspection lots.';

CREATE OR REPLACE TABLE `automotive_ecm`.`quality`.`inspection_lot` (
    `inspection_lot_id` BIGINT COMMENT 'System-generated unique identifier for the inspection lot record.',
    `control_plan_id` BIGINT COMMENT 'Foreign key linking to quality.control_plan. Business justification: Inspection lots are executed in accordance with control plans. The control plan defines the inspection frequency, sample size, and acceptance criteria that govern each inspection lot. Linking inspecti',
    `gl_account_id` BIGINT COMMENT 'Foreign key linking to finance.gl_account. Business justification: Inspection costs (labor, consumables, equipment usage) post to specific GL accounts for quality cost accounting. Critical for cost of quality reporting, variance analysis, and financial statement prep',
    `inbound_part_id` BIGINT COMMENT 'Foreign key linking to supply.inbound_part. Business justification: Required for the Inbound Part Inspection Lot report that ties each inspection lot to the specific inbound part received.',
    `inspection_plan_id` BIGINT COMMENT 'Reference to the inspection plan governing this lot.',
    `plant_id` BIGINT COMMENT 'Foreign key linking to manufacturing.plant. Business justification: Inspection lots are plant-specific. Existing plant_code is a denormalized plain attribute. Proper FK to manufacturing.plant enables plant-level quality reporting and supports multi-plant quality ben',
    `shipment_id` BIGINT COMMENT 'Foreign key linking to logistics.shipment. Business justification: Traceability: inspection lot results must be linked to the specific shipment for recall, OTD and quality KPI reporting.',
    `sku_master_id` BIGINT COMMENT 'Foreign key linking to inventory.sku_master. Business justification: REQUIRED: Inspection lots are executed per part; adding sku_master_id supports the Lot Traceability Report linking lots to the specific SKU.',
    `party_id` BIGINT COMMENT 'Foreign key linking to customer.party. Business justification: Incoming inspection lots require tracking the submitting party (customer returns, supplier shipments, warranty parts) for accountability and traceability in quality management systems. Essential for r',
    `supplier_id` BIGINT COMMENT 'Foreign key linking to supply.supply_supplier. Business justification: Needed for the Supplier Inspection Summary dashboard aggregating inspection lots per supplier.',
    `vehicle_compound_id` BIGINT COMMENT 'Foreign key linking to logistics.vehicle_compound. Business justification: Inspection lots for finished vehicles are created at compounds during PDI operations. Business process: batch quality inspection and acceptance at compound storage locations.',
    `vehicle_order_id` BIGINT COMMENT 'Foreign key linking to sales.vehicle_order. Business justification: Supports the Inspection Lot Traceability report, associating each lot with its vehicle order to ensure inspection results are linked to the correct customer order.',
    `work_center_id` BIGINT COMMENT 'Foreign key linking to manufacturing.work_center. Business justification: Inspection lots are created at specific work centers (quality gates). Existing work_center is a plain denormalized field. Proper FK enables work-center-level quality performance reporting (PPM per s',
    `batch_number` STRING COMMENT 'Batch identifier associated with the material or component.',
    `corrective_action_due_date` DATE COMMENT 'Target date by which the corrective action must be completed.',
    `corrective_action_required` BOOLEAN COMMENT 'Indicates whether a corrective action must be initiated for the identified defect.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the inspection lot record was first created in the system.',
    `decision` STRING COMMENT 'Final usage decision for the lot after inspection.. Valid values are `accept|reject|conditional_release`',
    `defect_code` STRING COMMENT 'Standardized code for any defect identified during inspection.',
    `defect_description` STRING COMMENT 'Narrative description of the defect.',
    `inspection_lot_status` STRING COMMENT 'Current lifecycle status of the inspection lot.. Valid values are `open|in_progress|closed|rejected|released`',
    `inspection_method` STRING COMMENT 'Technique used to perform the inspection.. Valid values are `visual|dimensional|functional|non_destructive|automated`',
    `inspection_reason_code` STRING COMMENT 'Code indicating why the inspection was triggered (e.g., SOP, PPAP, random sampling).',
    `inspection_timestamp` TIMESTAMP COMMENT 'Timestamp when the inspection activity was performed.',
    `lot_closure_date` DATE COMMENT 'Date when the inspection lot was closed after final decision.',
    `lot_number` STRING COMMENT 'Business identifier assigned to the inspection lot, often matching the SAP lot number.',
    `lot_origin` STRING COMMENT 'Origin of the lot (e.g., goods receipt, production order).. Valid values are `goods_receipt|production_order|delivery|return`',
    `lot_type` STRING COMMENT 'Classification of the lot being inspected (e.g., incoming material, work‑in‑process assembly, finished vehicle, prototype).. Valid values are `incoming_material|wip_assembly|finished_vehicle|prototype`',
    `measurement_result_status` STRING COMMENT 'Result of the measurement against specification limits.. Valid values are `pass|fail|out_of_spec`',
    `measurement_unit` STRING COMMENT 'Unit of measure associated with the measured value (e.g., mm, V).',
    `measurement_value` DECIMAL(18,2) COMMENT 'Quantitative measurement recorded during inspection (e.g., dimension, voltage).',
    `quantity_accepted` STRING COMMENT 'Number of units/items that passed inspection criteria.',
    `quantity_inspected` STRING COMMENT 'Total number of units/items examined in this inspection lot.',
    `quantity_rejected` STRING COMMENT 'Number of units/items that failed inspection criteria.',
    `remarks` STRING COMMENT 'Free‑form comments or notes captured by the inspector.',
    `serial_number` STRING COMMENT 'Serial number of the inspected unit, if applicable.',
    `source_document_number` STRING COMMENT 'Reference number of the originating document such as goods receipt, production order, or delivery.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the inspection lot record.',
    CONSTRAINT pk_inspection_lot PRIMARY KEY(`inspection_lot_id`)
) COMMENT 'Transactional record of a quality inspection event triggered for a batch of incoming materials, WIP assemblies, or finished vehicles. Captures lot origin (goods receipt, production order, delivery), inspection type, quantity inspected, inspection start/end timestamps, assigned inspector, and overall usage decision (accept, reject, conditional release). Sourced from SAP QM inspection lot management.';

CREATE OR REPLACE TABLE `automotive_ecm`.`quality`.`inspection_result` (
    `inspection_result_id` BIGINT COMMENT 'Unique identifier for the inspection result record.',
    `characteristic_id` BIGINT COMMENT 'Identifier of the inspected characteristic or measurement point.',
    `inspection_lot_id` BIGINT COMMENT 'Identifier of the inspection lot (header) to which this result belongs.',
    `comments` STRING COMMENT 'Free-text notes or observations recorded by the inspector.',
    `cp_value` DECIMAL(18,2) COMMENT 'Cp value calculated for the characteristic.',
    `cpk_value` DECIMAL(18,2) COMMENT 'Cpk value calculated for the characteristic.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the inspection result record was created.',
    `deviation_amount` DECIMAL(18,2) COMMENT 'Numeric difference between measured value and nearest specification limit.',
    `inspection_timestamp` TIMESTAMP COMMENT 'Date and time when the measurement was taken.',
    `is_critical` BOOLEAN COMMENT 'Indicates if the characteristic is critical to vehicle safety or compliance.',
    `line_sequence` STRING COMMENT 'Sequential order of the characteristic within the inspection lot.',
    `lower_spec_limit` DECIMAL(18,2) COMMENT 'Minimum acceptable value for the characteristic.',
    `measurement_accuracy` DECIMAL(18,2) COMMENT 'Accuracy specification of the measurement instrument.',
    `measurement_condition` STRING COMMENT 'Environmental condition during measurement.. Valid values are `normal|high_temp|low_temp|vibration`',
    `measurement_humidity_percent` DECIMAL(18,2) COMMENT 'Relative humidity percentage at time of measurement.',
    `measurement_location` STRING COMMENT 'Physical location on the vehicle or part where measurement was taken.',
    `measurement_method` STRING COMMENT 'Method used to capture the measurement.. Valid values are `manual|automated|sensor`',
    `measurement_resolution` DECIMAL(18,2) COMMENT 'Resolution of the measurement instrument.',
    `measurement_source` STRING COMMENT 'Origin of the measurement data (e.g., internal sensor, external lab).. Valid values are `internal|external`',
    `measurement_temperature_c` DECIMAL(18,2) COMMENT 'Ambient temperature in Celsius at time of measurement.',
    `measurement_tool` STRING COMMENT 'Tool or equipment used for the measurement.',
    `measurement_uncertainty` DECIMAL(18,2) COMMENT 'Estimated uncertainty of the measurement.',
    `measurement_unit` STRING COMMENT 'Unit of measure for the measured value (e.g., millimeter, kilogram).. Valid values are `mm|cm|in|mmHg|psi|kg`',
    `measurement_value` DECIMAL(18,2) COMMENT 'Numeric value recorded for the characteristic.',
    `record_status` STRING COMMENT 'Current lifecycle status of the record (e.g., active, archived).. Valid values are `active|inactive|archived`',
    `result_status` STRING COMMENT 'Pass/fail outcome of the measurement.. Valid values are `pass|fail|na`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the record.',
    `upper_spec_limit` DECIMAL(18,2) COMMENT 'Maximum acceptable value for the characteristic.',
    CONSTRAINT pk_inspection_result PRIMARY KEY(`inspection_result_id`)
) COMMENT 'Individual characteristic measurement result recorded during an inspection lot. Captures the measured value or attribute outcome, tolerance limits, pass/fail status, measurement instrument used, and inspector ID for each characteristic within an inspection plan. Supports SPC data collection and statistical analysis of process capability (Cp, Cpk).';

CREATE OR REPLACE TABLE `automotive_ecm`.`quality`.`defect_record` (
    `defect_record_id` BIGINT COMMENT 'System-generated unique identifier for the defect record.',
    `apqp_plan_id` BIGINT COMMENT 'Reference to the quality plan or inspection plan associated with the defect.',
    `build_stage_id` BIGINT COMMENT 'Foreign key linking to manufacturing.build_stage. Business justification: Defects are detected at specific build stages (body shop, paint, trim, final assembly). Stage-level defect analysis is a core automotive quality KPI. Linking defect_record to build_stage enables stage',
    `carrier_id` BIGINT COMMENT 'Foreign key linking to logistics.carrier. Business justification: Transport damage defects must link to responsible carrier for freight claims, carrier performance evaluation (damage rate PPM), and corrective action requests per IATF requirements.',
    `cost_center_id` BIGINT COMMENT 'Foreign key linking to finance.cost_center. Business justification: COPQ report requires assigning each defect to the responsible cost center for financial impact analysis.',
    `dealer_repair_order_id` BIGINT COMMENT 'Foreign key linking to dealer.dealer_repair_order. Business justification: Field quality feedback loop: warranty defects discovered at dealers generate repair orders. Quality teams track field failures back to manufacturing defects for root cause analysis, continuous improve',
    `dealership_id` BIGINT COMMENT 'Foreign key linking to dealer.dealership. Business justification: Defect records are frequently generated from dealer warranty claims; linking enables root‑cause analysis and dealer‑specific defect trends.',
    `fleet_contract_id` BIGINT COMMENT 'Foreign key linking to sales.fleet_contract. Business justification: Fleet customers monitor defect rates across all vehicles delivered under contract for performance SLAs, penalty clauses, and renewal decisions. Quality teams aggregate defect patterns by fleet contrac',
    `gl_account_id` BIGINT COMMENT 'Foreign key linking to finance.gl_account. Business justification: Scrap, rework, and warranty costs from defects post to dedicated GL accounts. Essential for cost of poor quality (COPQ) tracking, financial reporting, and management decision-making on quality investm',
    `inspection_lot_id` BIGINT COMMENT 'Foreign key linking to quality.inspection_lot. Business justification: Defect records raised during incoming material inspection, WIP inspection, or final inspection are associated with a specific inspection lot. Linking defect_record.inspection_lot_id → inspection_lot.i',
    `inspection_result_id` BIGINT COMMENT 'Foreign key linking to quality.inspection_result. Business justification: Defect records are frequently raised as a result of a failed inspection result. Linking defect_record.inspection_result_id → inspection_result.inspection_result_id provides direct traceability from th',
    `part_master_id` BIGINT COMMENT 'Foreign key linking to engineering.part_master. Business justification: Defect records must reference the canonical part master for root‑cause analysis; removes redundant part_number/name.',
    `production_order_id` BIGINT COMMENT 'Foreign key linking to manufacturing.production_order. Business justification: Defect records are tied to the specific production order where the defect was detected, essential for the Defect Tracking Dashboard.',
    `profit_center_id` BIGINT COMMENT 'Foreign key linking to finance.profit_center. Business justification: Defects impact profit center P&L through scrap, rework, and warranty costs. Essential for profit center quality cost visibility, performance evaluation, and management accountability for quality metri',
    `regulatory_requirement_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_requirement. Business justification: Defects may violate regulatory requirements triggering mandatory reporting (TREAD Act early warning, safety defect investigations). Quality teams must link defect records to affected regulations for r',
    `party_id` BIGINT COMMENT 'Foreign key linking to customer.party. Business justification: Defects reported by customers (warranty claims, field issues) or attributed to supplier parties require party-level tracking for quality accountability, customer satisfaction analysis, and supplier sc',
    `shipment_id` BIGINT COMMENT 'Foreign key linking to logistics.shipment. Business justification: Supplier performance: each defect is tied to the shipment that delivered the part, enabling root‑cause and logistics KPI analysis.',
    `sku_master_id` BIGINT COMMENT 'Identifier of the part or component associated with the defect.',
    `storage_location_id` BIGINT COMMENT 'Foreign key linking to inventory.storage_location. Business justification: Defects are detected at specific physical locations (line-side, warehouse zone, inspection bay). Root cause analysis and containment actions require knowing WHERE the defect was found for pattern anal',
    `supplier_quality_event_id` BIGINT COMMENT 'Foreign key linking to quality.supplier_quality_event. Business justification: Supplier quality events are raised when supplier-delivered parts have defects. Individual defect records are the detailed evidence supporting a supplier quality event. Linking defect_record.supplier_q',
    `vehicle_build_id` BIGINT COMMENT 'Foreign key linking to manufacturing.vehicle_build. Business justification: Defects are discovered on specific vehicle builds. Direct FK enables unit-level defect traceability to build timestamps, line, shift, and stage — distinct from production_order (batch-level). Required',
    `vehicle_compound_id` BIGINT COMMENT 'Foreign key linking to logistics.vehicle_compound. Business justification: Defects found during compound operations (PDI, storage damage, handling issues) are compound-specific for root cause analysis, corrective action, and compound performance tracking.',
    `vehicle_handover_id` BIGINT COMMENT 'Foreign key linking to logistics.vehicle_handover. Business justification: Defects discovered at handover during delivery acceptance inspection must be documented for acceptance decision, warranty determination, and responsibility assignment (carrier vs. compound vs. manufac',
    `vehicle_order_id` BIGINT COMMENT 'Foreign key linking to sales.vehicle_order. Business justification: Post-delivery defects discovered during PDI, customer complaints, or warranty claims must trace to the originating vehicle order for warranty validation, recall campaigns, customer notification, and q',
    `vehicle_ownership_id` BIGINT COMMENT 'Foreign key linking to customer.vehicle_ownership. Business justification: REQUIRED: Recall & warranty management needs to associate each defect record with the owning customers vehicle record to trigger service actions.',
    `vin_registry_id` BIGINT COMMENT 'Foreign key linking to vehicle.vin_registry. Business justification: Defect records are tied to a specific VIN; FK to vin_registry allows traceability from defect to exact vehicle for warranty and recall actions.',
    `work_center_id` BIGINT COMMENT 'Foreign key linking to manufacturing.work_center. Business justification: Defects are detected at specific work centers. Work-center-level defect tracking is essential for station-level PPM reporting, process improvement prioritization, and IATF 16949 process monitoring. de',
    `containment_action` STRING COMMENT 'Immediate action taken to contain the defect and prevent further impact.',
    `corrective_action` STRING COMMENT 'Planned or executed action to eliminate the root cause of the defect.',
    `corrective_action_due_date` DATE COMMENT 'Target date by which the corrective action must be completed.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the defect record was initially created in the system.',
    `defect_category` STRING COMMENT 'Stage of the product lifecycle where the defect was detected.. Valid values are `incoming|in_process|final|field`',
    `defect_code` STRING COMMENT 'Business identifier code assigned to the defect for tracking and reporting.',
    `defect_description` STRING COMMENT 'Detailed textual description of the non‑conformance or quality issue.',
    `defect_record_status` STRING COMMENT 'Current lifecycle status of the defect record.. Valid values are `open|investigating|closed|rejected|deferred`',
    `defect_type` STRING COMMENT 'Classification of the defect by its origin or nature.. Valid values are `material|process|design|supplier|assembly|software`',
    `detected_timestamp` TIMESTAMP COMMENT 'Date and time when the defect was first observed.',
    `detection_method` STRING COMMENT 'Method or channel through which the defect was discovered.. Valid values are `inspection|test|audit|customer_complaint|sensor|automated`',
    `disposition` STRING COMMENT 'Final disposition of the defective item after evaluation.. Valid values are `rework|scrap|use_as_is|return_to_supplier|deferred`',
    `investigation_end_timestamp` TIMESTAMP COMMENT 'Timestamp when the investigation was concluded.',
    `investigation_start_timestamp` TIMESTAMP COMMENT 'Timestamp when the root‑cause investigation began.',
    `is_repeat_defect` BOOLEAN COMMENT 'Flag indicating whether this defect has been observed previously.',
    `ppm_rate` DECIMAL(18,2) COMMENT 'Defect rate expressed in parts per million for quality metrics.',
    `quantity_affected` STRING COMMENT 'Number of units or parts impacted by the defect.',
    `root_cause` STRING COMMENT 'Root cause analysis result describing why the defect occurred.',
    `severity` STRING COMMENT 'Severity level indicating impact on safety, performance, or compliance.. Valid values are `critical|major|minor|warning|info`',
    `source_system` STRING COMMENT 'Originating source system of the defect data (e.g., Apriso MES, SAP QM).',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the defect record.',
    `vin` STRING COMMENT 'VIN of the vehicle in which the defect was found.',
    CONSTRAINT pk_defect_record PRIMARY KEY(`defect_record_id`)
) COMMENT 'Operational record of a quality defect or non-conformance identified at any stage — incoming material, in-process assembly, final inspection, or field. Captures defect code, defect description, location on vehicle (zone/component), severity classification, detection method, quantity affected, containment action taken, and disposition (rework, scrap, use-as-is). Sourced from Apriso/Dassault MES quality control module.';

CREATE OR REPLACE TABLE `automotive_ecm`.`quality`.`spc_chart` (
    `spc_chart_id` BIGINT COMMENT 'System‑generated unique identifier for the SPC chart configuration record.',
    `build_stage_id` BIGINT COMMENT 'Foreign key linking to manufacturing.build_stage. Business justification: SPC charts monitor quality at specific build stages (e.g., weld SPC at body shop, torque SPC at final assembly). Stage-level SPC monitoring is required for IATF 16949 process control. spc_chart links ',
    `characteristic_id` BIGINT COMMENT 'Foreign key linking to quality.characteristic. Business justification: spc_chart.ctq_characteristic is a free-text STRING field that should be normalized to a FK reference to the characteristic master table. Each SPC chart monitors one specific CTQ characteristic. Replac',
    `control_plan_id` BIGINT COMMENT 'Foreign key linking to quality.control_plan. Business justification: SPC charts are established to monitor CTQ characteristics defined in control plans. The control plan specifies which characteristics require SPC monitoring, the control limits, and the sampling freque',
    `cost_center_id` BIGINT COMMENT 'Foreign key linking to finance.cost_center. Business justification: SPC monitoring activities incur costs (software licenses, training, statistical analysis labor) that must be allocated to cost centers. Essential for activity-based costing and quality department budg',
    `model_id` BIGINT COMMENT 'Foreign key linking to vehicle.model. Business justification: SPC charts in automotive production are authored for specific vehicle models to monitor process capability (Cpk) during model production runs. Model-scoped SPC reporting is required for IATF 16949 pro',
    `sku_master_id` BIGINT COMMENT 'Foreign key linking to inventory.sku_master. Business justification: SPC charts monitor process capability for specific parts. Control limits, capability indices (Cp/Cpk), and process stability assessments are SKU-specific measurements required for production part appr',
    `work_center_id` BIGINT COMMENT 'Foreign key linking to manufacturing.work_center. Business justification: SPC charts monitor key characteristics of each work center; required for the Work Center SPC Dashboard.',
    `approval_timestamp` TIMESTAMP COMMENT 'Date‑time when the SPC chart configuration was formally approved.',
    `center_line` DECIMAL(18,2) COMMENT 'Target center line (mean) for the SPC chart.',
    `chart_name` STRING COMMENT 'Human‑readable name identifying the SPC chart for a specific CTQ characteristic.',
    `chart_type` STRING COMMENT 'Type of SPC chart used to monitor the characteristic (e.g., X‑bar/R, p‑chart).. Valid values are `X-bar/R|X-bar/S|p-chart|c-chart|u-chart|np-chart`',
    `confidence_level` DECIMAL(18,2) COMMENT 'Statistical confidence level applied when setting control limits, expressed as a percentage.',
    `control_limit_lcl` DECIMAL(18,2) COMMENT 'Statistical lower control limit for the chart, calculated from process data.',
    `control_limit_ucl` DECIMAL(18,2) COMMENT 'Statistical upper control limit for the chart, calculated from process data.',
    `created_timestamp` TIMESTAMP COMMENT 'Date‑time when the SPC chart record was first created in the system.',
    `data_source_system` STRING COMMENT 'System of record that supplies the raw measurement data for the SPC chart.. Valid values are `SAP QM|MES|Teamcenter|Custom`',
    `effective_from` DATE COMMENT 'Date from which the SPC chart configuration becomes valid.',
    `effective_until` DATE COMMENT 'Date after which the SPC chart configuration is no longer valid (null if open‑ended).',
    `measurement_unit` STRING COMMENT 'Unit of measure for the monitored characteristic (e.g., mm, psi). [ENUM-REF-CANDIDATE: mm|cm|mmHg|psi|rpm|kg|%|mm/s — 8 candidates stripped; promote to reference product]',
    `notes` STRING COMMENT 'Optional free‑text field for any extra information or remarks.',
    `ocap` STRING COMMENT 'Defined actions to be taken when the chart signals an out‑of‑control condition.',
    `process_step` STRING COMMENT 'Descriptive name of the manufacturing process step where the SPC chart is applied.',
    `process_step_code` STRING COMMENT 'Internal code identifying the process step (e.g., ASSEMBLY_01).',
    `sample_count` STRING COMMENT 'Total number of samples used to compute the charts control limits.',
    `sampling_frequency` STRING COMMENT 'Frequency at which samples are taken for the SPC chart.. Valid values are `per_shift|per_hour|per_day|per_batch|per_lot`',
    `spc_chart_description` STRING COMMENT 'Free‑form description providing additional context for the chart.',
    `spc_chart_status` STRING COMMENT 'Current lifecycle status of the SPC chart configuration.. Valid values are `active|inactive|deprecated|pending`',
    `statistical_method` STRING COMMENT 'Statistical technique used to calculate control limits (e.g., Shewhart, EWMA).. Valid values are `Shewhart|EWMA|CUSUM|XMR`',
    `subgroup_size` STRING COMMENT 'Number of units in each sampling subgroup used for chart calculations.',
    `target_value` DECIMAL(18,2) COMMENT 'Desired target value for the characteristic (center line target).',
    `tolerance_lower` DECIMAL(18,2) COMMENT 'Lower acceptable tolerance bound for the characteristic.',
    `tolerance_upper` DECIMAL(18,2) COMMENT 'Upper acceptable tolerance bound for the characteristic.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date‑time of the most recent modification to the SPC chart record.',
    `version_number` STRING COMMENT 'Version identifier for the chart configuration, incremented on changes.',
    CONSTRAINT pk_spc_chart PRIMARY KEY(`spc_chart_id`)
) COMMENT 'Statistical Process Control chart master record defining the SPC monitoring configuration for a critical-to-quality (CTQ) characteristic at a specific process step. Specifies chart type (X-bar/R, X-bar/S, p-chart, c-chart), control limits (UCL, LCL), center line, subgroup size, sampling frequency, and out-of-control action plan (OCAP). Supports IATF 16949 SPC requirements.';

CREATE OR REPLACE TABLE `automotive_ecm`.`quality`.`quality_ppap_submission` (
    `quality_ppap_submission_id` BIGINT COMMENT 'Unique identifier for the quality_ppap_submission data product (auto-inserted pre-linking).',
    `apqp_plan_id` BIGINT COMMENT 'Foreign key linking to quality.apqp_plan. Business justification: PPAP submission belongs to an APQP plan; linking via apqp_plan_id enables reuse of part_number and plan details.',
    `control_plan_id` BIGINT COMMENT 'Foreign key linking to quality.control_plan. Business justification: PPAP (Production Part Approval Process) requires submission of the control plan as a mandatory element (PPAP Element 13). Linking quality_ppap_submission.control_plan_id → control_plan.control_plan_id',
    `fmea_id` BIGINT COMMENT 'Foreign key linking to quality.fmea. Business justification: PPAP requires submission of both Design FMEA and Process FMEA as mandatory elements (PPAP Elements 3 and 4). Linking quality_ppap_submission.fmea_id → fmea.fmea_id establishes which FMEA document was ',
    `inspection_plan_id` BIGINT COMMENT 'Foreign key linking to quality.inspection_plan. Business justification: PPAP submissions include the inspection plan (measurement system analysis and dimensional results are PPAP elements). Linking quality_ppap_submission.inspection_plan_id → inspection_plan.inspection_pl',
    `plant_id` BIGINT COMMENT 'Foreign key linking to manufacturing.plant. Business justification: PPAP submissions are plant-specific — approval is granted for production at a specific plant. quality_ppap_submission has no FK to manufacturing.plant. Plant-level PPAP tracking is required for multi-',
    `production_line_id` BIGINT COMMENT 'Foreign key linking to manufacturing.production_line. Business justification: PPAP submissions are production-line-specific — the approval covers a specific lines capability to produce the part. quality_ppap_submission has no FK to manufacturing.production_line. PPAP is a line',
    `sku_master_id` BIGINT COMMENT 'Foreign key linking to inventory.sku_master. Business justification: PPAP submissions are part-specific approval packages sent to OEM customers. Each submission covers a specific SKU with dimensional results, material certifications, process capability data, and appear',
    `supply_ppap_submission_id` BIGINT COMMENT 'Foreign key linking to supply.supply_ppap_submission. Business justification: PPAP Submission Tracking links the quality PPAP record to the original supply PPAP submission for compliance audits.',
    CONSTRAINT pk_quality_ppap_submission PRIMARY KEY(`quality_ppap_submission_id`)
) COMMENT 'Production Part Approval Process submission record for a supplier part or internally manufactured component. Tracks PPAP level (1-5), submission reason (new part, engineering change, tooling change), submission date, approval status, and the 18 PPAP elements status (design records, PFMEA, control plan, MSA, capability study, etc.). Supports IATF 16949 supplier quality management.';

CREATE OR REPLACE TABLE `automotive_ecm`.`quality`.`audit` (
    `audit_id` BIGINT COMMENT 'System-generated unique identifier for the quality audit record.',
    `plant_id` BIGINT COMMENT 'Surrogate key for the audited facility.',
    `carrier_id` BIGINT COMMENT 'Foreign key linking to logistics.carrier. Business justification: Quality system audits of carriers (IATF 16949 compliance, process audits, handling procedures) are mandatory in automotive supply chain. Business process: carrier quality certification and approval.',
    `organization_account_id` BIGINT COMMENT 'Foreign key linking to customer.organization_account. Business justification: OEMs conduct quality audits of fleet customers maintenance facilities, upfitter operations, and commercial account processes to ensure brand standards and warranty compliance. Real automotive practic',
    `vehicle_compound_id` BIGINT COMMENT 'Foreign key linking to logistics.vehicle_compound. Business justification: Compound quality audits for storage conditions, handling procedures, PDI quality, and process compliance are standard automotive practice. Business process: compound certification and continuous impro',
    `capex_request_id` BIGINT COMMENT 'Foreign key linking to finance.capex_request. Business justification: Audit findings often trigger capital investment requirements (compliance equipment, facility upgrades, safety systems). Critical for linking audit corrective actions to capital budgeting and regulator',
    `certification_id` BIGINT COMMENT 'Foreign key linking to dealer.dealer_certification. Business justification: Dealer certification compliance auditing: OEM quality audits validate dealer certifications (EV certified, ADAS certified, warranty authorized). Audit results directly determine certification status, ',
    `control_plan_id` BIGINT COMMENT 'Identifier of the audit plan that defines scope, criteria, and schedule.',
    `cost_center_id` BIGINT COMMENT 'Foreign key linking to finance.cost_center. Business justification: Audit Expense Tracking links each audit to the cost center bearing the audit cost for financial statements.',
    `dealership_id` BIGINT COMMENT 'Foreign key linking to dealer.dealership. Business justification: Dealer Quality Audit process requires linking each audit to the specific dealership for compliance reporting and corrective action tracking.',
    `fiscal_period_id` BIGINT COMMENT 'Foreign key linking to finance.fiscal_period. Business justification: Audits are scheduled, executed, and reported by fiscal period for compliance tracking, trend analysis, and quarterly management reviews. Critical for aligning audit cycles with financial reporting per',
    `model_id` BIGINT COMMENT 'Foreign key linking to vehicle.model. Business justification: IATF 16949 product audits are scoped to specific vehicle models. Model-level audit traceability is required for product audit reports, customer-specific requirements (CSR), and OEM quality scorecards.',
    `primary_auditee_location_plant_id` BIGINT COMMENT 'Surrogate key for the audited facility.',
    `production_line_id` BIGINT COMMENT 'Foreign key linking to manufacturing.production_line. Business justification: Quality audits are performed per production line; the Line Audit Summary report depends on this linkage.',
    `project_id` BIGINT COMMENT 'Foreign key linking to finance.project. Business justification: Quality audits (certification, supplier, process) are often executed as projects with dedicated budgets, timelines, and resource allocation. Real automotive practice: ISO/IATF certification audits tra',
    `regulatory_requirement_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_requirement. Business justification: Quality audits verify compliance with specific regulatory requirements (ISO 9001, IATF 16949 clauses). Audit findings must trace to exact regulatory requirements for corrective action planning and cer',
    `standard_id` BIGINT COMMENT 'Foreign key linking to quality.quality_standard. Business justification: Quality standards are referenced by audits; adding standard_id to quality_audit creates the needed lookup.',
    `vehicle_program_id` BIGINT COMMENT 'Foreign key linking to engineering.vehicle_program. Business justification: Quality audits are scheduled per vehicle program; linking provides program context for audit findings and compliance reporting.',
    `work_center_id` BIGINT COMMENT 'Foreign key linking to manufacturing.work_center. Business justification: Layered Process Audits (LPA) are conducted at specific work centers — a mandatory IATF 16949 requirement. Linking audit to work_center enables work-center-level audit frequency tracking and compliance',
    `audit_date` DATE COMMENT 'Calendar date on which the audit was performed.',
    `audit_method` STRING COMMENT 'Indicates whether the audit was performed internally, by an external party, or a third‑party provider.. Valid values are `internal|external|third_party`',
    `audit_number` STRING COMMENT 'Human‑readable audit identifier used in reports and communications.. Valid values are `^AUD-d{6}$`',
    `audit_scope` STRING COMMENT 'Narrative description of the functional or geographic scope covered by the audit.',
    `audit_status` STRING COMMENT 'Current lifecycle state of the audit.. Valid values are `planned|in_progress|completed|closed|cancelled`',
    `audit_type` STRING COMMENT 'Classification of the audit (system, process, product, or layered process audit).. Valid values are `system|process|product|layered_process`',
    `auditee_location` STRING COMMENT 'Code of the plant, facility, or site where the audit was conducted.',
    `auditor_name` STRING COMMENT 'Full name of the lead auditor responsible for the audit.',
    `closure_date` DATE COMMENT 'Date on which the audit was formally closed.',
    `closure_status` STRING COMMENT 'Current status of audit closure activities.. Valid values are `open|closed|deferred`',
    `corrective_action_due_date` DATE COMMENT 'Target date for completing all required corrective actions.',
    `corrective_action_required` BOOLEAN COMMENT 'Indicates whether any findings require corrective action.',
    `corrective_action_status` STRING COMMENT 'Current progress status of corrective actions.. Valid values are `not_started|in_progress|completed`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the audit record was first created in the system.',
    `documents_count` STRING COMMENT 'Number of supporting documents attached to the audit record.',
    `duration_minutes` STRING COMMENT 'Total time spent conducting the audit, measured in minutes.',
    `findings_major` STRING COMMENT 'Count of findings classified as major.',
    `findings_minor` STRING COMMENT 'Count of findings classified as minor.',
    `findings_severe` STRING COMMENT 'Count of findings classified as severe (high impact).',
    `findings_total` STRING COMMENT 'Total number of findings identified during the audit.',
    `non_conformance_count` STRING COMMENT 'Number of non‑conformances identified during the audit.',
    `non_conformance_severity` STRING COMMENT 'Highest severity level among identified non‑conformances.. Valid values are `critical|major|minor`',
    `notes` STRING COMMENT 'Free‑form observations, comments, or remarks recorded by the auditor.',
    `overall_score` DECIMAL(18,2) COMMENT 'Numeric score (0‑100) representing overall audit performance.',
    `risk_level` STRING COMMENT 'Overall risk rating derived from audit findings.. Valid values are `low|medium|high|critical`',
    `score_category` STRING COMMENT 'Qualitative categorisation of the overall audit score.. Valid values are `excellent|good|fair|poor`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the audit record.',
    CONSTRAINT pk_audit PRIMARY KEY(`audit_id`)
) COMMENT 'Quality system and process audit record capturing planned and unplanned audits conducted at plants, supplier facilities, or dealer service centers. Tracks audit type (system, process, product, layered process audit — LPA), audit scope, audit date, lead auditor, findings count by severity, overall audit score, and closure status. Supports IATF 16949 internal audit requirements and customer-specific requirements (CSR).';

CREATE OR REPLACE TABLE `automotive_ecm`.`quality`.`audit_finding` (
    `audit_finding_id` BIGINT COMMENT 'Unique identifier for the quality_audit_finding data product (auto-inserted pre-linking).',
    `audit_id` BIGINT COMMENT 'Foreign key linking to quality.quality_audit. Business justification: Audit finding records belong to a quality audit; adding quality_audit_id creates the required parent relationship.',
    `defect_record_id` BIGINT COMMENT 'Foreign key linking to quality.defect_record. Business justification: Audit findings (major non-conformances, minor observations) can generate defect records or be linked to existing defect records as evidence. Linking quality_audit_finding.defect_record_id → defect_rec',
    `standard_id` BIGINT COMMENT 'Foreign key linking to quality.standard. Business justification: Each audit finding references a specific clause or requirement of a quality standard (e.g., IATF 16949 clause 8.5.1, ISO 9001 clause 7.1.5). Linking quality_audit_finding.standard_id → standard.standa',
    CONSTRAINT pk_audit_finding PRIMARY KEY(`audit_finding_id`)
) COMMENT 'Individual finding or observation raised during a quality audit. Captures finding type (major non-conformance, minor non-conformance, observation, opportunity for improvement), clause reference (IATF 16949, ISO 9001, customer-specific), finding description, evidence, assigned owner, due date for corrective action, and closure verification status. Linked to the parent quality audit record.';

CREATE OR REPLACE TABLE `automotive_ecm`.`quality`.`pdi_inspection` (
    `pdi_inspection_id` BIGINT COMMENT 'Unique identifier for the quality_pdi_inspection data product (auto-inserted pre-linking).',
    `audit_id` BIGINT COMMENT 'Foreign key linking to quality.quality_audit. Business justification: PDI inspection is part of a quality audit process; linking to quality_audit provides audit context.',
    `dealer_inventory_id` BIGINT COMMENT 'Foreign key linking to dealer.dealer_inventory. Business justification: Vehicle delivery quality assurance: PDI (Pre-Delivery Inspection) is the quality gate before dealer inventory becomes retail-ready. PDI inspection records must link to specific dealer inventory units ',
    `defect_record_id` BIGINT COMMENT 'Foreign key linking to quality.defect_record. Business justification: Pre-Delivery Inspections (PDI) identify defects on finished vehicles before handover to dealer or customer. Linking quality_pdi_inspection.defect_record_id → defect_record.defect_record_id connects PD',
    `inspection_plan_id` BIGINT COMMENT 'Foreign key linking to quality.inspection_plan. Business justification: PDI inspections are conducted according to a defined inspection plan specifying which vehicle characteristics to check, acceptance criteria, and measurement methods. Linking quality_pdi_inspection.ins',
    `vehicle_build_id` BIGINT COMMENT 'Foreign key linking to manufacturing.vehicle_build. Business justification: PDI (Pre-Delivery Inspection) is performed on a specific vehicle build. quality_pdi_inspection has no FK to manufacturing.vehicle_build. This is a fundamental unit-level traceability link — PDI result',
    `vehicle_compound_id` BIGINT COMMENT 'Foreign key linking to logistics.vehicle_compound. Business justification: PDI inspections are performed at specific vehicle compounds as the final quality gate before delivery. Business process: compound-based pre-delivery inspection execution and tracking.',
    `vin_registry_id` BIGINT COMMENT 'Foreign key linking to vehicle.vin_registry. Business justification: Pre-Delivery Inspection (PDI) is performed on a specific vehicle identified by VIN. PDI-to-VIN traceability is mandatory for warranty activation, customer delivery records, and recall investigations. ',
    CONSTRAINT pk_pdi_inspection PRIMARY KEY(`pdi_inspection_id`)
) COMMENT 'Pre-Delivery Inspection (PDI) record for a finished vehicle prior to handover to dealer or customer. Captures VIN, inspection date, plant or PDI center, inspector ID, checklist version, total defects found, defect categories (cosmetic, functional, safety), rework required flag, and final pass/fail disposition. Supports dealer network quality standards and customer satisfaction targets.';

CREATE OR REPLACE TABLE `automotive_ecm`.`quality`.`supplier_quality_event` (
    `supplier_quality_event_id` BIGINT COMMENT 'Unique identifier for the supplier quality event.',
    `control_plan_id` BIGINT COMMENT 'Foreign key linking to quality.control_plan. Business justification: Supplier quality events are raised when supplier parts deviate from the requirements defined in the control plan. Linking supplier_quality_event.control_plan_id → control_plan.control_plan_id identifi',
    `inspection_lot_id` BIGINT COMMENT 'Foreign key linking to quality.inspection_lot. Business justification: Supplier quality events are typically triggered by a failed incoming inspection lot. Linking supplier_quality_event.inspection_lot_id → inspection_lot.inspection_lot_id provides direct traceability fr',
    `invoice_id` BIGINT COMMENT 'Foreign key linking to billing.invoice. Business justification: REQUIRED: Supplier quality events trigger charge‑back invoices; FK ties event to the specific invoice for audit and payment reconciliation.',
    `carrier_id` BIGINT COMMENT 'Foreign key linking to logistics.carrier. Business justification: Supplier quality events for logistics service providers (carriers) track transport damage, delays causing quality issues, and handling non-conformances. Business process: carrier quality performance m',
    `model_id` BIGINT COMMENT 'Foreign key linking to vehicle.model. Business justification: Supplier quality events (8D reports, SCARs) in automotive are tied to the affected vehicle model for production impact assessment, containment decisions, and recall risk analysis. Model-level supplier',
    `plant_id` BIGINT COMMENT 'Identifier of the manufacturing plant where defect was detected.',
    `production_order_id` BIGINT COMMENT 'Foreign key linking to manufacturing.production_order. Business justification: Supplier quality events (defective incoming parts) impact specific production orders causing line stoppages or material shortages. Linking enables production impact assessment, cost of poor quality ca',
    `regulatory_requirement_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_requirement. Business justification: Supplier quality events may violate regulatory material specifications (REACH, conflict minerals, safety standards). SQE teams must link events to affected regulations for containment actions and regu',
    `sku_master_id` BIGINT COMMENT 'Foreign key linking to inventory.sku_master. Business justification: Supplier quality issues (SQEs/8D reports) are part-specific. Corrective actions, supplier scorecards, and PPAP re-submissions require linking the quality event to the affected SKU. Removes denormalize',
    `supplier_id` BIGINT COMMENT 'Foreign key linking to supply.supply_supplier. Business justification: Supplier Quality Event Management uses the supply‑domain supplier master for root‑cause analysis and reporting.',
    `actual_resolution_time_days` STRING COMMENT 'Actual number of days taken to resolve the issue.',
    `affected_quantity` STRING COMMENT 'Total quantity of parts received in the shipment.',
    `attached_documentation` STRING COMMENT 'Reference to attached documents (e.g., photos, test reports).',
    `comments` STRING COMMENT 'Additional free-text comments or notes.',
    `containment_action` STRING COMMENT 'Immediate action taken to contain the defect.',
    `corrective_action_due_date` DATE COMMENT 'Target date for implementing corrective actions.',
    `corrective_action_plan` STRING COMMENT 'Planned corrective actions to resolve the defect.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the event record was created.',
    `defect_description` STRING COMMENT 'Narrative description of the defect observed.',
    `defect_quantity` STRING COMMENT 'Number of units affected by the defect.',
    `defect_severity` STRING COMMENT 'Severity classification of the defect.. Valid values are `critical|major|minor`',
    `delivery_note_number` STRING COMMENT 'Reference number of the delivery note associated with the part.',
    `detection_method` STRING COMMENT 'Method used to detect the defect.. Valid values are `visual|automated|test|audit`',
    `event_number` STRING COMMENT 'Business identifier assigned to the quality event.',
    `event_timestamp` TIMESTAMP COMMENT 'Date and time when the quality event was recorded.',
    `expected_resolution_time_days` STRING COMMENT 'Planned number of days to resolve the issue.',
    `is_critical` BOOLEAN COMMENT 'Flag indicating if the event is classified as critical.',
    `is_repeat_issue` BOOLEAN COMMENT 'Flag indicating if this defect has occurred previously for the same part/supplier.',
    `quality_system` STRING COMMENT 'Quality system or standard applicable (e.g., IATF 16949).',
    `regulatory_compliance_flag` BOOLEAN COMMENT 'Indicates if the defect impacts regulatory compliance (e.g., NHTSA).',
    `resolution_date` DATE COMMENT 'Date when the event was resolved.',
    `resolution_status` STRING COMMENT 'Overall status of the event resolution.. Valid values are `resolved|unresolved|closed|deferred`',
    `risk_rating` STRING COMMENT 'Overall risk rating associated with the defect.. Valid values are `high|medium|low`',
    `root_cause_analysis` STRING COMMENT 'Analysis identifying the root cause of the defect.',
    `sca_number` STRING COMMENT 'Identifier of the Supplier Corrective Action Request.',
    `sca_requested` BOOLEAN COMMENT 'Indicates whether a formal SCAR was issued to the supplier.',
    `supplier_response_due_date` DATE COMMENT 'Date by which the supplier must respond with corrective action.',
    `supplier_response_status` STRING COMMENT 'Current status of the suppliers response.. Valid values are `pending|submitted|rejected|approved`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the event record.',
    CONSTRAINT pk_supplier_quality_event PRIMARY KEY(`supplier_quality_event_id`)
) COMMENT 'Supplier quality incident or deviation event record raised when a supplier-delivered part or material fails incoming inspection or causes a production disruption. Captures supplier code, part number, delivery note reference, defect description, quantity affected, severity (critical, major, minor), containment action, supplier response due date, and resolution status. Supports supplier corrective action request (SCAR) workflow.';

CREATE OR REPLACE TABLE `automotive_ecm`.`quality`.`standard` (
    `standard_id` BIGINT COMMENT 'System-generated unique identifier for the quality standard record.',
    `company_code_id` BIGINT COMMENT 'Foreign key linking to finance.company_code. Business justification: Quality standards (ISO 9001, IATF 16949) are adopted and certified at legal entity (company code) level. Critical for multi-entity compliance tracking, certification cost allocation, and regulatory re',
    `applicability_scope` STRING COMMENT 'Geographic or plant scope where the standard applies.. Valid values are `global|regional|plant_specific`',
    `compliance_status` STRING COMMENT 'Current compliance assessment of the organization against this standard.. Valid values are `compliant|non_compliant|partial|pending`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the standard record was first created in the system.',
    `document_format` STRING COMMENT 'File format of the stored standard document.. Valid values are `pdf|docx|xlsx|html`',
    `document_url` STRING COMMENT 'Web address or repository link to the electronic version of the standard.',
    `effective_date` DATE COMMENT 'Date on which the standard becomes effective.',
    `expiry_date` DATE COMMENT 'Date on which the standard expires or is superseded (nullable if open‑ended).',
    `is_mandatory` BOOLEAN COMMENT 'Indicates whether compliance with this standard is mandatory for the organization.',
    `issuing_body` STRING COMMENT 'Organization that issued the standard (e.g., ISO, IATF, EPA, NHTSA).',
    `language` STRING COMMENT 'Language in which the standard document is written.. Valid values are `en|de|fr|es|zh|ja`',
    `lifecycle_status` STRING COMMENT 'Current lifecycle state of the standard record.. Valid values are `draft|active|inactive|retired|pending`',
    `notes` STRING COMMENT 'Free‑form comments or additional information about the standard.',
    `regulatory_body` STRING COMMENT 'Regulatory authority associated with the standard (e.g., NHTSA, EPA, UNECE).',
    `regulatory_section` STRING COMMENT 'Specific section or clause of the regulation that the standard addresses.',
    `revision_date` DATE COMMENT 'Date when the latest revision of the standard was released.',
    `revision_number` STRING COMMENT 'Internal revision identifier for updates to the standard document.',
    `standard_code` STRING COMMENT 'Official alphanumeric code assigned by the issuing body (e.g., ISO 9001, IATF 16949).',
    `standard_description` STRING COMMENT 'Detailed description of the scope, purpose and content of the standard.',
    `standard_type` STRING COMMENT 'Category of the standard (e.g., quality management, environmental, safety, emissions, regulatory, process).. Valid values are `quality|environment|safety|emissions|regulatory|process`',
    `title` STRING COMMENT 'Human‑readable title of the quality standard or specification.',
    `updated_by` STRING COMMENT 'User identifier of the person who last modified the record.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the standard record.',
    `version_number` STRING COMMENT 'Version identifier of the standard (e.g., 1.0, 2.3).',
    `created_by` STRING COMMENT 'User identifier of the person who created the record.',
    CONSTRAINT pk_standard PRIMARY KEY(`standard_id`)
) COMMENT 'Reference master for quality standards, specifications, and regulatory requirements applicable to the business. Captures standard code (IATF 16949, ISO 9001, ISO 14001, FMVSS, ECE regulations), standard title, issuing body, version, effective date, expiry date, applicability scope (global, regional, plant-specific), and compliance status. Used to link quality plans, audits, and test results to governing requirements.';

CREATE OR REPLACE TABLE `automotive_ecm`.`quality`.`characteristic` (
    `characteristic_id` BIGINT COMMENT 'Primary key for characteristic',
    `inspection_plan_id` BIGINT COMMENT 'Foreign key linking to quality.inspection_plan. Business justification: Characteristics are defined and owned within inspection plans — the inspection plan specifies which characteristics to measure, their tolerances, and measurement methods. Linking characteristic.inspec',
    `model_id` BIGINT COMMENT 'Foreign key linking to vehicle.model. Business justification: Quality characteristics (critical/significant) are defined per vehicle model in IATF 16949 characteristic libraries. Model-scoped characteristic definitions drive control plans, FMEAs, and inspection ',
    `parent_characteristic_id` BIGINT COMMENT 'Self-referencing FK on characteristic (parent_characteristic_id)',
    `sku_master_id` BIGINT COMMENT 'Foreign key linking to inventory.sku_master. Business justification: Quality characteristics (dimensions, tolerances, material properties) are defined per SKU. Inspection plans and control plans reference SKU-specific characteristics for measurement system analysis and',
    `characteristic_category` STRING COMMENT 'Broad classification of the characteristic within quality domains.',
    `characteristic_description` STRING COMMENT 'Detailed description of what the characteristic measures or represents.',
    `characteristic_name` STRING COMMENT 'Human‑readable name of the quality characteristic.',
    `characteristic_status` STRING COMMENT 'Current lifecycle status of the characteristic.',
    `created_by_user` STRING COMMENT 'User identifier who initially created the characteristic record.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the characteristic record was first created.',
    `criticality_level` STRING COMMENT 'Business impact rating of the characteristic on product quality.',
    `data_type` STRING COMMENT 'Data type of the characteristics measured value.',
    `effective_from` DATE COMMENT 'Date when the characteristic becomes valid for use.',
    `effective_until` DATE COMMENT 'Date when the characteristic is retired or superseded (nullable).',
    `frequency` STRING COMMENT 'How often the characteristic is measured or evaluated.',
    `measurement_method` STRING COMMENT 'Technique used to capture the characteristic value.',
    `measurement_unit` STRING COMMENT 'Unit of measure associated with the characteristic (e.g., mm, kg, sec).',
    `notes` STRING COMMENT 'Free‑form comments or observations about the characteristic.',
    `source_system` STRING COMMENT 'Originating IT system or application that defines the characteristic.',
    `target_value` DECIMAL(18,2) COMMENT 'Target or nominal value that the characteristic should achieve.',
    `tolerance_lower` DECIMAL(18,2) COMMENT 'Maximum acceptable deviation below the target value.',
    `tolerance_upper` DECIMAL(18,2) COMMENT 'Maximum acceptable deviation above the target value.',
    `updated_by_user` STRING COMMENT 'User identifier who last modified the characteristic record.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the characteristic record.',
    CONSTRAINT pk_characteristic PRIMARY KEY(`characteristic_id`)
) COMMENT 'Master reference table for characteristic. Referenced by characteristic_id.';

-- ========= FOREIGN KEYS =========
ALTER TABLE `automotive_ecm`.`quality`.`fmea` ADD CONSTRAINT `fk_quality_fmea_apqp_plan_id` FOREIGN KEY (`apqp_plan_id`) REFERENCES `automotive_ecm`.`quality`.`apqp_plan`(`apqp_plan_id`);
ALTER TABLE `automotive_ecm`.`quality`.`fmea` ADD CONSTRAINT `fk_quality_fmea_characteristic_id` FOREIGN KEY (`characteristic_id`) REFERENCES `automotive_ecm`.`quality`.`characteristic`(`characteristic_id`);
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` ADD CONSTRAINT `fk_quality_control_plan_apqp_plan_id` FOREIGN KEY (`apqp_plan_id`) REFERENCES `automotive_ecm`.`quality`.`apqp_plan`(`apqp_plan_id`);
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` ADD CONSTRAINT `fk_quality_control_plan_inspection_plan_id` FOREIGN KEY (`inspection_plan_id`) REFERENCES `automotive_ecm`.`quality`.`inspection_plan`(`inspection_plan_id`);
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ADD CONSTRAINT `fk_quality_inspection_plan_apqp_plan_id` FOREIGN KEY (`apqp_plan_id`) REFERENCES `automotive_ecm`.`quality`.`apqp_plan`(`apqp_plan_id`);
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ADD CONSTRAINT `fk_quality_inspection_lot_control_plan_id` FOREIGN KEY (`control_plan_id`) REFERENCES `automotive_ecm`.`quality`.`control_plan`(`control_plan_id`);
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ADD CONSTRAINT `fk_quality_inspection_lot_inspection_plan_id` FOREIGN KEY (`inspection_plan_id`) REFERENCES `automotive_ecm`.`quality`.`inspection_plan`(`inspection_plan_id`);
ALTER TABLE `automotive_ecm`.`quality`.`inspection_result` ADD CONSTRAINT `fk_quality_inspection_result_characteristic_id` FOREIGN KEY (`characteristic_id`) REFERENCES `automotive_ecm`.`quality`.`characteristic`(`characteristic_id`);
ALTER TABLE `automotive_ecm`.`quality`.`inspection_result` ADD CONSTRAINT `fk_quality_inspection_result_inspection_lot_id` FOREIGN KEY (`inspection_lot_id`) REFERENCES `automotive_ecm`.`quality`.`inspection_lot`(`inspection_lot_id`);
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ADD CONSTRAINT `fk_quality_defect_record_apqp_plan_id` FOREIGN KEY (`apqp_plan_id`) REFERENCES `automotive_ecm`.`quality`.`apqp_plan`(`apqp_plan_id`);
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ADD CONSTRAINT `fk_quality_defect_record_inspection_lot_id` FOREIGN KEY (`inspection_lot_id`) REFERENCES `automotive_ecm`.`quality`.`inspection_lot`(`inspection_lot_id`);
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ADD CONSTRAINT `fk_quality_defect_record_inspection_result_id` FOREIGN KEY (`inspection_result_id`) REFERENCES `automotive_ecm`.`quality`.`inspection_result`(`inspection_result_id`);
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ADD CONSTRAINT `fk_quality_defect_record_supplier_quality_event_id` FOREIGN KEY (`supplier_quality_event_id`) REFERENCES `automotive_ecm`.`quality`.`supplier_quality_event`(`supplier_quality_event_id`);
ALTER TABLE `automotive_ecm`.`quality`.`spc_chart` ADD CONSTRAINT `fk_quality_spc_chart_characteristic_id` FOREIGN KEY (`characteristic_id`) REFERENCES `automotive_ecm`.`quality`.`characteristic`(`characteristic_id`);
ALTER TABLE `automotive_ecm`.`quality`.`spc_chart` ADD CONSTRAINT `fk_quality_spc_chart_control_plan_id` FOREIGN KEY (`control_plan_id`) REFERENCES `automotive_ecm`.`quality`.`control_plan`(`control_plan_id`);
ALTER TABLE `automotive_ecm`.`quality`.`quality_ppap_submission` ADD CONSTRAINT `fk_quality_quality_ppap_submission_apqp_plan_id` FOREIGN KEY (`apqp_plan_id`) REFERENCES `automotive_ecm`.`quality`.`apqp_plan`(`apqp_plan_id`);
ALTER TABLE `automotive_ecm`.`quality`.`quality_ppap_submission` ADD CONSTRAINT `fk_quality_quality_ppap_submission_control_plan_id` FOREIGN KEY (`control_plan_id`) REFERENCES `automotive_ecm`.`quality`.`control_plan`(`control_plan_id`);
ALTER TABLE `automotive_ecm`.`quality`.`quality_ppap_submission` ADD CONSTRAINT `fk_quality_quality_ppap_submission_fmea_id` FOREIGN KEY (`fmea_id`) REFERENCES `automotive_ecm`.`quality`.`fmea`(`fmea_id`);
ALTER TABLE `automotive_ecm`.`quality`.`quality_ppap_submission` ADD CONSTRAINT `fk_quality_quality_ppap_submission_inspection_plan_id` FOREIGN KEY (`inspection_plan_id`) REFERENCES `automotive_ecm`.`quality`.`inspection_plan`(`inspection_plan_id`);
ALTER TABLE `automotive_ecm`.`quality`.`audit` ADD CONSTRAINT `fk_quality_audit_control_plan_id` FOREIGN KEY (`control_plan_id`) REFERENCES `automotive_ecm`.`quality`.`control_plan`(`control_plan_id`);
ALTER TABLE `automotive_ecm`.`quality`.`audit` ADD CONSTRAINT `fk_quality_audit_standard_id` FOREIGN KEY (`standard_id`) REFERENCES `automotive_ecm`.`quality`.`standard`(`standard_id`);
ALTER TABLE `automotive_ecm`.`quality`.`audit_finding` ADD CONSTRAINT `fk_quality_audit_finding_audit_id` FOREIGN KEY (`audit_id`) REFERENCES `automotive_ecm`.`quality`.`audit`(`audit_id`);
ALTER TABLE `automotive_ecm`.`quality`.`audit_finding` ADD CONSTRAINT `fk_quality_audit_finding_defect_record_id` FOREIGN KEY (`defect_record_id`) REFERENCES `automotive_ecm`.`quality`.`defect_record`(`defect_record_id`);
ALTER TABLE `automotive_ecm`.`quality`.`audit_finding` ADD CONSTRAINT `fk_quality_audit_finding_standard_id` FOREIGN KEY (`standard_id`) REFERENCES `automotive_ecm`.`quality`.`standard`(`standard_id`);
ALTER TABLE `automotive_ecm`.`quality`.`pdi_inspection` ADD CONSTRAINT `fk_quality_pdi_inspection_audit_id` FOREIGN KEY (`audit_id`) REFERENCES `automotive_ecm`.`quality`.`audit`(`audit_id`);
ALTER TABLE `automotive_ecm`.`quality`.`pdi_inspection` ADD CONSTRAINT `fk_quality_pdi_inspection_defect_record_id` FOREIGN KEY (`defect_record_id`) REFERENCES `automotive_ecm`.`quality`.`defect_record`(`defect_record_id`);
ALTER TABLE `automotive_ecm`.`quality`.`pdi_inspection` ADD CONSTRAINT `fk_quality_pdi_inspection_inspection_plan_id` FOREIGN KEY (`inspection_plan_id`) REFERENCES `automotive_ecm`.`quality`.`inspection_plan`(`inspection_plan_id`);
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ADD CONSTRAINT `fk_quality_supplier_quality_event_control_plan_id` FOREIGN KEY (`control_plan_id`) REFERENCES `automotive_ecm`.`quality`.`control_plan`(`control_plan_id`);
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ADD CONSTRAINT `fk_quality_supplier_quality_event_inspection_lot_id` FOREIGN KEY (`inspection_lot_id`) REFERENCES `automotive_ecm`.`quality`.`inspection_lot`(`inspection_lot_id`);
ALTER TABLE `automotive_ecm`.`quality`.`characteristic` ADD CONSTRAINT `fk_quality_characteristic_inspection_plan_id` FOREIGN KEY (`inspection_plan_id`) REFERENCES `automotive_ecm`.`quality`.`inspection_plan`(`inspection_plan_id`);
ALTER TABLE `automotive_ecm`.`quality`.`characteristic` ADD CONSTRAINT `fk_quality_characteristic_parent_characteristic_id` FOREIGN KEY (`parent_characteristic_id`) REFERENCES `automotive_ecm`.`quality`.`characteristic`(`characteristic_id`);

-- ========= TAGS =========
ALTER SCHEMA `automotive_ecm`.`quality` SET TAGS ('dbx_division' = 'operations');
ALTER SCHEMA `automotive_ecm`.`quality` SET TAGS ('dbx_domain' = 'quality');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` SET TAGS ('dbx_subdomain' = 'planning_framework');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` ALTER COLUMN `apqp_plan_id` SET TAGS ('dbx_business_glossary_term' = 'APQP Plan ID');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` ALTER COLUMN `fiscal_period_id` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Period Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` ALTER COLUMN `model_id` SET TAGS ('dbx_business_glossary_term' = 'Model Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` ALTER COLUMN `plant_id` SET TAGS ('dbx_business_glossary_term' = 'Plant Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` ALTER COLUMN `platform_id` SET TAGS ('dbx_business_glossary_term' = 'Platform Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` ALTER COLUMN `production_line_id` SET TAGS ('dbx_business_glossary_term' = 'Production Line Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` ALTER COLUMN `project_id` SET TAGS ('dbx_business_glossary_term' = 'Project Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` ALTER COLUMN `sku_master_id` SET TAGS ('dbx_business_glossary_term' = 'Sku Master Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` ALTER COLUMN `vehicle_program_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Program Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` ALTER COLUMN `actual_ppm` SET TAGS ('dbx_business_glossary_term' = 'Actual PPM');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` ALTER COLUMN `actual_release_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Release Date');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` ALTER COLUMN `apqp_phase` SET TAGS ('dbx_business_glossary_term' = 'APQP Phase');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` ALTER COLUMN `apqp_phase` SET TAGS ('dbx_value_regex' = 'concept|design|process|validation|launch');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` ALTER COLUMN `classification_type` SET TAGS ('dbx_business_glossary_term' = 'Classification Type');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` ALTER COLUMN `classification_type` SET TAGS ('dbx_value_regex' = 'new_model|refresh|component|system');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` ALTER COLUMN `compliance_status` SET TAGS ('dbx_business_glossary_term' = 'Compliance Status');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` ALTER COLUMN `compliance_status` SET TAGS ('dbx_value_regex' = 'compliant|non_compliant|pending');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` ALTER COLUMN `documentation_link` SET TAGS ('dbx_business_glossary_term' = 'Documentation Link');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` ALTER COLUMN `effective_from` SET TAGS ('dbx_business_glossary_term' = 'Effective From');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` ALTER COLUMN `effective_until` SET TAGS ('dbx_business_glossary_term' = 'Effective Until');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` ALTER COLUMN `eop_date` SET TAGS ('dbx_business_glossary_term' = 'End of Production (EOP) Date');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` ALTER COLUMN `gate_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Gate Completion Date');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` ALTER COLUMN `gate_due_date` SET TAGS ('dbx_business_glossary_term' = 'Gate Due Date');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` ALTER COLUMN `gate_status` SET TAGS ('dbx_business_glossary_term' = 'Gate Status');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` ALTER COLUMN `gate_status` SET TAGS ('dbx_value_regex' = 'open|closed|delayed|approved|rejected');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` ALTER COLUMN `lifecycle_status` SET TAGS ('dbx_business_glossary_term' = 'Lifecycle Status');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` ALTER COLUMN `lifecycle_status` SET TAGS ('dbx_value_regex' = 'draft|active|suspended|completed|archived');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` ALTER COLUMN `milestone_gate` SET TAGS ('dbx_business_glossary_term' = 'Milestone Gate');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` ALTER COLUMN `milestone_gate` SET TAGS ('dbx_value_regex' = 'gate1|gate2|gate3|gate4|gate5');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` ALTER COLUMN `mitigation_plan` SET TAGS ('dbx_business_glossary_term' = 'Mitigation Plan');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` ALTER COLUMN `model_year` SET TAGS ('dbx_business_glossary_term' = 'Model Year');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` ALTER COLUMN `owner_name` SET TAGS ('dbx_business_glossary_term' = 'Plan Owner Name');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` ALTER COLUMN `plan_number` SET TAGS ('dbx_business_glossary_term' = 'APQP Plan Number');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` ALTER COLUMN `quality_goal_ppm` SET TAGS ('dbx_business_glossary_term' = 'Quality Goal (PPM)');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` ALTER COLUMN `responsible_team` SET TAGS ('dbx_business_glossary_term' = 'Responsible Team');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` ALTER COLUMN `risk_assessment_date` SET TAGS ('dbx_business_glossary_term' = 'Risk Assessment Date');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` ALTER COLUMN `risk_level` SET TAGS ('dbx_business_glossary_term' = 'Risk Level');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` ALTER COLUMN `risk_level` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` ALTER COLUMN `sop_date` SET TAGS ('dbx_business_glossary_term' = 'Start of Production (SOP) Date');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` ALTER COLUMN `target_ppm` SET TAGS ('dbx_business_glossary_term' = 'Target PPM');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` ALTER COLUMN `target_release_date` SET TAGS ('dbx_business_glossary_term' = 'Target Release Date');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `automotive_ecm`.`quality`.`apqp_plan` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `automotive_ecm`.`quality`.`fmea` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `automotive_ecm`.`quality`.`fmea` SET TAGS ('dbx_subdomain' = 'planning_framework');
ALTER TABLE `automotive_ecm`.`quality`.`fmea` ALTER COLUMN `fmea_id` SET TAGS ('dbx_business_glossary_term' = 'FMEA ID');
ALTER TABLE `automotive_ecm`.`quality`.`fmea` ALTER COLUMN `apqp_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Apqp Plan Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`fmea` ALTER COLUMN `characteristic_id` SET TAGS ('dbx_business_glossary_term' = 'Characteristic Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`fmea` ALTER COLUMN `design_specification_id` SET TAGS ('dbx_business_glossary_term' = 'Design Specification Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`fmea` ALTER COLUMN `model_id` SET TAGS ('dbx_business_glossary_term' = 'Model Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`fmea` ALTER COLUMN `production_line_id` SET TAGS ('dbx_business_glossary_term' = 'Production Line Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`fmea` ALTER COLUMN `project_id` SET TAGS ('dbx_business_glossary_term' = 'Project Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`fmea` ALTER COLUMN `regulatory_requirement_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Requirement Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`fmea` ALTER COLUMN `sku_master_id` SET TAGS ('dbx_business_glossary_term' = 'Sku Master Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`fmea` ALTER COLUMN `work_center_id` SET TAGS ('dbx_business_glossary_term' = 'Work Center Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`fmea` ALTER COLUMN `actual_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Completion Date');
ALTER TABLE `automotive_ecm`.`quality`.`fmea` ALTER COLUMN `analysis_number` SET TAGS ('dbx_business_glossary_term' = 'Analysis Number (AN)');
ALTER TABLE `automotive_ecm`.`quality`.`fmea` ALTER COLUMN `analysis_type` SET TAGS ('dbx_business_glossary_term' = 'Analysis Type');
ALTER TABLE `automotive_ecm`.`quality`.`fmea` ALTER COLUMN `analysis_type` SET TAGS ('dbx_value_regex' = 'design|process');
ALTER TABLE `automotive_ecm`.`quality`.`fmea` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `automotive_ecm`.`quality`.`fmea` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `automotive_ecm`.`quality`.`fmea` ALTER COLUMN `cause` SET TAGS ('dbx_business_glossary_term' = 'Root Cause');
ALTER TABLE `automotive_ecm`.`quality`.`fmea` ALTER COLUMN `control_effectiveness_rating` SET TAGS ('dbx_business_glossary_term' = 'Control Effectiveness Rating');
ALTER TABLE `automotive_ecm`.`quality`.`fmea` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `automotive_ecm`.`quality`.`fmea` ALTER COLUMN `current_control` SET TAGS ('dbx_business_glossary_term' = 'Current Control');
ALTER TABLE `automotive_ecm`.`quality`.`fmea` ALTER COLUMN `detection_description` SET TAGS ('dbx_business_glossary_term' = 'Detection Description');
ALTER TABLE `automotive_ecm`.`quality`.`fmea` ALTER COLUMN `detection_method` SET TAGS ('dbx_business_glossary_term' = 'Detection Method');
ALTER TABLE `automotive_ecm`.`quality`.`fmea` ALTER COLUMN `detection_rating` SET TAGS ('dbx_business_glossary_term' = 'Detection Rating (D)');
ALTER TABLE `automotive_ecm`.`quality`.`fmea` ALTER COLUMN `effective_from` SET TAGS ('dbx_business_glossary_term' = 'Effective From Date');
ALTER TABLE `automotive_ecm`.`quality`.`fmea` ALTER COLUMN `effective_until` SET TAGS ('dbx_business_glossary_term' = 'Effective Until Date');
ALTER TABLE `automotive_ecm`.`quality`.`fmea` ALTER COLUMN `failure_effect` SET TAGS ('dbx_business_glossary_term' = 'Failure Effect');
ALTER TABLE `automotive_ecm`.`quality`.`fmea` ALTER COLUMN `failure_mode` SET TAGS ('dbx_business_glossary_term' = 'Failure Mode');
ALTER TABLE `automotive_ecm`.`quality`.`fmea` ALTER COLUMN `fmea_status` SET TAGS ('dbx_business_glossary_term' = 'FMEA Status');
ALTER TABLE `automotive_ecm`.`quality`.`fmea` ALTER COLUMN `fmea_status` SET TAGS ('dbx_value_regex' = 'open|closed|in_progress|deferred');
ALTER TABLE `automotive_ecm`.`quality`.`fmea` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Additional Notes');
ALTER TABLE `automotive_ecm`.`quality`.`fmea` ALTER COLUMN `occurrence_description` SET TAGS ('dbx_business_glossary_term' = 'Occurrence Description');
ALTER TABLE `automotive_ecm`.`quality`.`fmea` ALTER COLUMN `occurrence_rating` SET TAGS ('dbx_business_glossary_term' = 'Occurrence Rating (O)');
ALTER TABLE `automotive_ecm`.`quality`.`fmea` ALTER COLUMN `recommended_action` SET TAGS ('dbx_business_glossary_term' = 'Recommended Action');
ALTER TABLE `automotive_ecm`.`quality`.`fmea` ALTER COLUMN `revision_number` SET TAGS ('dbx_business_glossary_term' = 'Revision Number');
ALTER TABLE `automotive_ecm`.`quality`.`fmea` ALTER COLUMN `rpn` SET TAGS ('dbx_business_glossary_term' = 'Risk Priority Number (RPN)');
ALTER TABLE `automotive_ecm`.`quality`.`fmea` ALTER COLUMN `severity_description` SET TAGS ('dbx_business_glossary_term' = 'Severity Description');
ALTER TABLE `automotive_ecm`.`quality`.`fmea` ALTER COLUMN `severity_rating` SET TAGS ('dbx_business_glossary_term' = 'Severity Rating (S)');
ALTER TABLE `automotive_ecm`.`quality`.`fmea` ALTER COLUMN `source_system` SET TAGS ('dbx_business_glossary_term' = 'Source System');
ALTER TABLE `automotive_ecm`.`quality`.`fmea` ALTER COLUMN `subsystem` SET TAGS ('dbx_business_glossary_term' = 'Subsystem');
ALTER TABLE `automotive_ecm`.`quality`.`fmea` ALTER COLUMN `target_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Target Completion Date');
ALTER TABLE `automotive_ecm`.`quality`.`fmea` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` SET TAGS ('dbx_subdomain' = 'planning_framework');
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` ALTER COLUMN `control_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Control Plan ID');
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` ALTER COLUMN `apqp_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Apqp Plan Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` ALTER COLUMN `design_specification_id` SET TAGS ('dbx_business_glossary_term' = 'Design Specification Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` ALTER COLUMN `inspection_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Associated Inspection Plan ID');
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` ALTER COLUMN `production_line_id` SET TAGS ('dbx_business_glossary_term' = 'Production Line Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` ALTER COLUMN `profit_center_id` SET TAGS ('dbx_business_glossary_term' = 'Profit Center Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` ALTER COLUMN `regulatory_requirement_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Requirement Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` ALTER COLUMN `sku_master_id` SET TAGS ('dbx_business_glossary_term' = 'Sku Master Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` ALTER COLUMN `vehicle_compound_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Compound Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` ALTER COLUMN `wbs_element_id` SET TAGS ('dbx_business_glossary_term' = 'Wbs Element Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Approval Status');
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected|revoked');
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` ALTER COLUMN `change_control_number` SET TAGS ('dbx_business_glossary_term' = 'Change Control Number');
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` ALTER COLUMN `control_method` SET TAGS ('dbx_business_glossary_term' = 'Control Method');
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` ALTER COLUMN `control_method` SET TAGS ('dbx_value_regex' = 'spc|attribute|visual|functional|dimensional');
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` ALTER COLUMN `control_plan_description` SET TAGS ('dbx_business_glossary_term' = 'Control Plan Description');
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` ALTER COLUMN `control_plan_status` SET TAGS ('dbx_business_glossary_term' = 'Control Plan Status');
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` ALTER COLUMN `control_plan_status` SET TAGS ('dbx_value_regex' = 'draft|active|suspended|retired|archived');
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` ALTER COLUMN `effective_end_date` SET TAGS ('dbx_business_glossary_term' = 'Effective End Date');
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` ALTER COLUMN `effective_start_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Start Date');
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` ALTER COLUMN `is_mandatory` SET TAGS ('dbx_business_glossary_term' = 'Is Mandatory');
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` ALTER COLUMN `lower_spec_limit` SET TAGS ('dbx_business_glossary_term' = 'Lower Specification Limit');
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` ALTER COLUMN `measurement_unit` SET TAGS ('dbx_business_glossary_term' = 'Measurement Unit');
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Additional Notes');
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` ALTER COLUMN `plan_name` SET TAGS ('dbx_business_glossary_term' = 'Control Plan Name');
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` ALTER COLUMN `plan_number` SET TAGS ('dbx_business_glossary_term' = 'Control Plan Number');
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` ALTER COLUMN `plan_type` SET TAGS ('dbx_business_glossary_term' = 'Control Plan Type');
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` ALTER COLUMN `plan_type` SET TAGS ('dbx_value_regex' = 'assembly|paint|engine|chassis|electrical|final');
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` ALTER COLUMN `reaction_plan` SET TAGS ('dbx_business_glossary_term' = 'Reaction Plan');
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` ALTER COLUMN `responsible_function` SET TAGS ('dbx_business_glossary_term' = 'Responsible Function');
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` ALTER COLUMN `responsible_function` SET TAGS ('dbx_value_regex' = 'assembly_line|quality_engineering|process_engineering|manufacturing|test_lab');
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` ALTER COLUMN `revision_date` SET TAGS ('dbx_business_glossary_term' = 'Revision Date');
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` ALTER COLUMN `revision_number` SET TAGS ('dbx_business_glossary_term' = 'Revision Number');
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` ALTER COLUMN `sample_frequency` SET TAGS ('dbx_business_glossary_term' = 'Sample Frequency');
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` ALTER COLUMN `sample_frequency` SET TAGS ('dbx_value_regex' = 'per_shift|per_batch|per_hour|per_day');
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` ALTER COLUMN `sample_size` SET TAGS ('dbx_business_glossary_term' = 'Sample Size');
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` ALTER COLUMN `target_value` SET TAGS ('dbx_business_glossary_term' = 'Target Value');
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` ALTER COLUMN `upper_spec_limit` SET TAGS ('dbx_business_glossary_term' = 'Upper Specification Limit');
ALTER TABLE `automotive_ecm`.`quality`.`control_plan` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` SET TAGS ('dbx_subdomain' = 'planning_framework');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `inspection_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Inspection Plan Identifier (ID)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `apqp_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Apqp Plan Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `cost_center_id` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `model_id` SET TAGS ('dbx_business_glossary_term' = 'Model Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `production_line_id` SET TAGS ('dbx_business_glossary_term' = 'Production Line Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `regulatory_requirement_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Requirement Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `sku_master_id` SET TAGS ('dbx_business_glossary_term' = 'Sku Master Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `vehicle_compound_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Compound Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `acceptance_criteria` SET TAGS ('dbx_business_glossary_term' = 'Acceptance Criteria Description (ACC_CRIT)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `applicable_process` SET TAGS ('dbx_business_glossary_term' = 'Applicable Process for Inspection (PROCESS)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `applicable_process` SET TAGS ('dbx_value_regex' = 'IQC|IPQC|PDI|Final');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date (APPROVAL_DATE)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By User Identifier (APPROVED_BY)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp (CREATED_TS)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `criticality_level` SET TAGS ('dbx_business_glossary_term' = 'Criticality Level (CRIT_LEVEL)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `criticality_level` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `department_responsible` SET TAGS ('dbx_business_glossary_term' = 'Responsible Department (DEPT_RESP)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `effective_end_date` SET TAGS ('dbx_business_glossary_term' = 'Effective End Date (EFFECTIVE_UNTIL)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `effective_start_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Start Date (EFFECTIVE_FROM)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `frequency` SET TAGS ('dbx_business_glossary_term' = 'Inspection Frequency (FREQ)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `frequency` SET TAGS ('dbx_value_regex' = 'per_batch|per_shift|per_vehicle|per_day');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `gauge_type` SET TAGS ('dbx_business_glossary_term' = 'Gauge Type (GAUGE_TYPE)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `gauge_type` SET TAGS ('dbx_value_regex' = 'dial|digital|laser|micrometer');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `inspection_category` SET TAGS ('dbx_business_glossary_term' = 'Inspection Category (INS_CAT)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `inspection_category` SET TAGS ('dbx_value_regex' = 'dimensional|functional|visual|electrical');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `inspection_plan_description` SET TAGS ('dbx_business_glossary_term' = 'Inspection Plan Description (DESC)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `inspection_plan_status` SET TAGS ('dbx_business_glossary_term' = 'Inspection Plan Status (STATUS)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `inspection_plan_status` SET TAGS ('dbx_value_regex' = 'draft|active|inactive|retired');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `is_automated` SET TAGS ('dbx_business_glossary_term' = 'Is Inspection Automated (IS_AUTOMATED)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date (LAST_REVIEW_DATE)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `measurement_method` SET TAGS ('dbx_business_glossary_term' = 'Measurement Method (MEAS_METHOD)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `measurement_method` SET TAGS ('dbx_value_regex' = 'CMM|Gauge|Visual|Automated|Manual');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `measurement_unit` SET TAGS ('dbx_business_glossary_term' = 'Measurement Unit (MEAS_UNIT)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `measurement_unit` SET TAGS ('dbx_value_regex' = 'mm|cm|inch|mm^2|psi');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `model_year` SET TAGS ('dbx_business_glossary_term' = 'Model Year (MY)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Additional Notes (NOTES)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `plan_name` SET TAGS ('dbx_business_glossary_term' = 'Inspection Plan Name (PLAN_NAME)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `plan_number` SET TAGS ('dbx_business_glossary_term' = 'Inspection Plan Number (PLAN_NO)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `plan_type` SET TAGS ('dbx_business_glossary_term' = 'Inspection Plan Type (TYPE)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `plan_type` SET TAGS ('dbx_value_regex' = 'incoming_material|in_process|final_vehicle|custom');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `plant_location` SET TAGS ('dbx_business_glossary_term' = 'Plant Location Code (PLANT_LOC)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `requires_approval` SET TAGS ('dbx_business_glossary_term' = 'Requires Approval Flag (REQ_APPROVAL)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `review_cycle_days` SET TAGS ('dbx_business_glossary_term' = 'Review Cycle in Days (REVIEW_CYCLE_DAYS)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `revision_number` SET TAGS ('dbx_business_glossary_term' = 'Revision Number (REV_NO)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `sample_size` SET TAGS ('dbx_business_glossary_term' = 'Sample Size (SAMPLE_SZ)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `tolerance_lower` SET TAGS ('dbx_business_glossary_term' = 'Lower Tolerance Limit (TOL_LOWER)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `tolerance_upper` SET TAGS ('dbx_business_glossary_term' = 'Upper Tolerance Limit (TOL_UPPER)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `updated_by` SET TAGS ('dbx_business_glossary_term' = 'Updated By User Identifier (UPDATED_BY)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Update Timestamp (UPDATED_TS)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `version` SET TAGS ('dbx_business_glossary_term' = 'Inspection Plan Version (VER)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_plan` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By User Identifier (CREATED_BY)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` SET TAGS ('dbx_subdomain' = 'defect_management');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ALTER COLUMN `inspection_lot_id` SET TAGS ('dbx_business_glossary_term' = 'Inspection Lot ID');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ALTER COLUMN `control_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Control Plan Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ALTER COLUMN `gl_account_id` SET TAGS ('dbx_business_glossary_term' = 'Gl Account Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ALTER COLUMN `inbound_part_id` SET TAGS ('dbx_business_glossary_term' = 'Inbound Part Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ALTER COLUMN `inspection_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Inspection Plan Identifier');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ALTER COLUMN `plant_id` SET TAGS ('dbx_business_glossary_term' = 'Plant Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ALTER COLUMN `shipment_id` SET TAGS ('dbx_business_glossary_term' = 'Shipment Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ALTER COLUMN `sku_master_id` SET TAGS ('dbx_business_glossary_term' = 'Sku Master Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Submitting Party Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ALTER COLUMN `supplier_id` SET TAGS ('dbx_business_glossary_term' = 'Supply Supplier Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ALTER COLUMN `vehicle_compound_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Compound Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ALTER COLUMN `vehicle_order_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Order Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ALTER COLUMN `work_center_id` SET TAGS ('dbx_business_glossary_term' = 'Work Center Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ALTER COLUMN `batch_number` SET TAGS ('dbx_business_glossary_term' = 'Batch Number');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ALTER COLUMN `corrective_action_due_date` SET TAGS ('dbx_business_glossary_term' = 'Corrective Action Due Date');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ALTER COLUMN `corrective_action_required` SET TAGS ('dbx_business_glossary_term' = 'Corrective Action Required Flag');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ALTER COLUMN `decision` SET TAGS ('dbx_business_glossary_term' = 'Overall Inspection Decision');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ALTER COLUMN `decision` SET TAGS ('dbx_value_regex' = 'accept|reject|conditional_release');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ALTER COLUMN `defect_code` SET TAGS ('dbx_business_glossary_term' = 'Defect Code (Quality Defect Identifier)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ALTER COLUMN `defect_description` SET TAGS ('dbx_business_glossary_term' = 'Defect Description');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ALTER COLUMN `inspection_lot_status` SET TAGS ('dbx_business_glossary_term' = 'Inspection Lot Status');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ALTER COLUMN `inspection_lot_status` SET TAGS ('dbx_value_regex' = 'open|in_progress|closed|rejected|released');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ALTER COLUMN `inspection_method` SET TAGS ('dbx_business_glossary_term' = 'Inspection Method');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ALTER COLUMN `inspection_method` SET TAGS ('dbx_value_regex' = 'visual|dimensional|functional|non_destructive|automated');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ALTER COLUMN `inspection_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Inspection Reason Code');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ALTER COLUMN `inspection_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Inspection Event Timestamp');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ALTER COLUMN `lot_closure_date` SET TAGS ('dbx_business_glossary_term' = 'Lot Closure Date');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ALTER COLUMN `lot_number` SET TAGS ('dbx_business_glossary_term' = 'Inspection Lot Number (LOT_NO)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ALTER COLUMN `lot_origin` SET TAGS ('dbx_business_glossary_term' = 'Lot Origin Source');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ALTER COLUMN `lot_origin` SET TAGS ('dbx_value_regex' = 'goods_receipt|production_order|delivery|return');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ALTER COLUMN `lot_type` SET TAGS ('dbx_business_glossary_term' = 'Inspection Lot Type');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ALTER COLUMN `lot_type` SET TAGS ('dbx_value_regex' = 'incoming_material|wip_assembly|finished_vehicle|prototype');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ALTER COLUMN `measurement_result_status` SET TAGS ('dbx_business_glossary_term' = 'Measurement Result Status');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ALTER COLUMN `measurement_result_status` SET TAGS ('dbx_value_regex' = 'pass|fail|out_of_spec');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ALTER COLUMN `measurement_unit` SET TAGS ('dbx_business_glossary_term' = 'Measurement Unit');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ALTER COLUMN `measurement_value` SET TAGS ('dbx_business_glossary_term' = 'Measured Value');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ALTER COLUMN `quantity_accepted` SET TAGS ('dbx_business_glossary_term' = 'Quantity Accepted');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ALTER COLUMN `quantity_inspected` SET TAGS ('dbx_business_glossary_term' = 'Quantity Inspected');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ALTER COLUMN `quantity_rejected` SET TAGS ('dbx_business_glossary_term' = 'Quantity Rejected');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ALTER COLUMN `remarks` SET TAGS ('dbx_business_glossary_term' = 'Remarks / Comments');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ALTER COLUMN `serial_number` SET TAGS ('dbx_business_glossary_term' = 'Serial Number');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ALTER COLUMN `source_document_number` SET TAGS ('dbx_business_glossary_term' = 'Source Document Number');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_lot` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_result` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_result` SET TAGS ('dbx_subdomain' = 'defect_management');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_result` ALTER COLUMN `inspection_result_id` SET TAGS ('dbx_business_glossary_term' = 'Inspection Result ID');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_result` ALTER COLUMN `characteristic_id` SET TAGS ('dbx_business_glossary_term' = 'Inspection Characteristic ID');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_result` ALTER COLUMN `inspection_lot_id` SET TAGS ('dbx_business_glossary_term' = 'Inspection Lot ID');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_result` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Comments');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_result` ALTER COLUMN `cp_value` SET TAGS ('dbx_business_glossary_term' = 'Process Capability (Cp)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_result` ALTER COLUMN `cpk_value` SET TAGS ('dbx_business_glossary_term' = 'Process Capability Index (Cpk)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_result` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_result` ALTER COLUMN `deviation_amount` SET TAGS ('dbx_business_glossary_term' = 'Deviation Amount');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_result` ALTER COLUMN `inspection_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Inspection Timestamp');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_result` ALTER COLUMN `is_critical` SET TAGS ('dbx_business_glossary_term' = 'Critical Flag');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_result` ALTER COLUMN `line_sequence` SET TAGS ('dbx_business_glossary_term' = 'Line Sequence');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_result` ALTER COLUMN `lower_spec_limit` SET TAGS ('dbx_business_glossary_term' = 'Lower Specification Limit');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_result` ALTER COLUMN `measurement_accuracy` SET TAGS ('dbx_business_glossary_term' = 'Measurement Accuracy');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_result` ALTER COLUMN `measurement_condition` SET TAGS ('dbx_business_glossary_term' = 'Measurement Condition');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_result` ALTER COLUMN `measurement_condition` SET TAGS ('dbx_value_regex' = 'normal|high_temp|low_temp|vibration');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_result` ALTER COLUMN `measurement_humidity_percent` SET TAGS ('dbx_business_glossary_term' = 'Measurement Humidity (%)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_result` ALTER COLUMN `measurement_location` SET TAGS ('dbx_business_glossary_term' = 'Measurement Location');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_result` ALTER COLUMN `measurement_method` SET TAGS ('dbx_business_glossary_term' = 'Measurement Method');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_result` ALTER COLUMN `measurement_method` SET TAGS ('dbx_value_regex' = 'manual|automated|sensor');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_result` ALTER COLUMN `measurement_resolution` SET TAGS ('dbx_business_glossary_term' = 'Measurement Resolution');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_result` ALTER COLUMN `measurement_source` SET TAGS ('dbx_business_glossary_term' = 'Measurement Source');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_result` ALTER COLUMN `measurement_source` SET TAGS ('dbx_value_regex' = 'internal|external');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_result` ALTER COLUMN `measurement_temperature_c` SET TAGS ('dbx_business_glossary_term' = 'Measurement Temperature (°C)');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_result` ALTER COLUMN `measurement_tool` SET TAGS ('dbx_business_glossary_term' = 'Measurement Tool');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_result` ALTER COLUMN `measurement_uncertainty` SET TAGS ('dbx_business_glossary_term' = 'Measurement Uncertainty');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_result` ALTER COLUMN `measurement_unit` SET TAGS ('dbx_business_glossary_term' = 'Measurement Unit');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_result` ALTER COLUMN `measurement_unit` SET TAGS ('dbx_value_regex' = 'mm|cm|in|mmHg|psi|kg');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_result` ALTER COLUMN `measurement_value` SET TAGS ('dbx_business_glossary_term' = 'Measured Value');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_result` ALTER COLUMN `record_status` SET TAGS ('dbx_business_glossary_term' = 'Record Status');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_result` ALTER COLUMN `record_status` SET TAGS ('dbx_value_regex' = 'active|inactive|archived');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_result` ALTER COLUMN `result_status` SET TAGS ('dbx_business_glossary_term' = 'Result Status');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_result` ALTER COLUMN `result_status` SET TAGS ('dbx_value_regex' = 'pass|fail|na');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_result` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `automotive_ecm`.`quality`.`inspection_result` ALTER COLUMN `upper_spec_limit` SET TAGS ('dbx_business_glossary_term' = 'Upper Specification Limit');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` SET TAGS ('dbx_subdomain' = 'defect_management');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `defect_record_id` SET TAGS ('dbx_business_glossary_term' = 'Defect Record Identifier');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `apqp_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Quality Plan Identifier');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `build_stage_id` SET TAGS ('dbx_business_glossary_term' = 'Build Stage Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `carrier_id` SET TAGS ('dbx_business_glossary_term' = 'Carrier Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `cost_center_id` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `dealer_repair_order_id` SET TAGS ('dbx_business_glossary_term' = 'Dealer Repair Order Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `dealership_id` SET TAGS ('dbx_business_glossary_term' = 'Dealership Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `fleet_contract_id` SET TAGS ('dbx_business_glossary_term' = 'Fleet Contract Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `gl_account_id` SET TAGS ('dbx_business_glossary_term' = 'Gl Account Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `inspection_lot_id` SET TAGS ('dbx_business_glossary_term' = 'Inspection Lot Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `inspection_result_id` SET TAGS ('dbx_business_glossary_term' = 'Inspection Result Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `part_master_id` SET TAGS ('dbx_business_glossary_term' = 'Part Master Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `production_order_id` SET TAGS ('dbx_business_glossary_term' = 'Production Order Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `profit_center_id` SET TAGS ('dbx_business_glossary_term' = 'Profit Center Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `regulatory_requirement_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Requirement Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `party_id` SET TAGS ('dbx_business_glossary_term' = 'Reporting Party Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `shipment_id` SET TAGS ('dbx_business_glossary_term' = 'Shipment Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `sku_master_id` SET TAGS ('dbx_business_glossary_term' = 'Component Identifier (COMPONENT_ID)');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `storage_location_id` SET TAGS ('dbx_business_glossary_term' = 'Storage Location Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `supplier_quality_event_id` SET TAGS ('dbx_business_glossary_term' = 'Supplier Quality Event Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `vehicle_build_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Build Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `vehicle_compound_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Compound Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `vehicle_handover_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Handover Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `vehicle_order_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Order Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `vehicle_ownership_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Ownership Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `vin_registry_id` SET TAGS ('dbx_business_glossary_term' = 'Vin Registry Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `work_center_id` SET TAGS ('dbx_business_glossary_term' = 'Work Center Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `containment_action` SET TAGS ('dbx_business_glossary_term' = 'Containment Action');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `corrective_action` SET TAGS ('dbx_business_glossary_term' = 'Corrective Action');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `corrective_action_due_date` SET TAGS ('dbx_business_glossary_term' = 'Corrective Action Due Date');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `defect_category` SET TAGS ('dbx_business_glossary_term' = 'Defect Category (CATEGORY)');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `defect_category` SET TAGS ('dbx_value_regex' = 'incoming|in_process|final|field');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `defect_code` SET TAGS ('dbx_business_glossary_term' = 'Defect Code (DEFECT_CODE)');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `defect_description` SET TAGS ('dbx_business_glossary_term' = 'Defect Description');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `defect_record_status` SET TAGS ('dbx_business_glossary_term' = 'Defect Status (STATUS)');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `defect_record_status` SET TAGS ('dbx_value_regex' = 'open|investigating|closed|rejected|deferred');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `defect_type` SET TAGS ('dbx_business_glossary_term' = 'Defect Type (DEFECT_TYPE)');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `defect_type` SET TAGS ('dbx_value_regex' = 'material|process|design|supplier|assembly|software');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `detected_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Defect Detection Timestamp');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `detection_method` SET TAGS ('dbx_business_glossary_term' = 'Detection Method (DETECTION_METHOD)');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `detection_method` SET TAGS ('dbx_value_regex' = 'inspection|test|audit|customer_complaint|sensor|automated');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `disposition` SET TAGS ('dbx_business_glossary_term' = 'Defect Disposition (DISPOSITION)');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `disposition` SET TAGS ('dbx_value_regex' = 'rework|scrap|use_as_is|return_to_supplier|deferred');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `investigation_end_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Investigation End Timestamp');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `investigation_start_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Investigation Start Timestamp');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `is_repeat_defect` SET TAGS ('dbx_business_glossary_term' = 'Repeat Defect Indicator');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `ppm_rate` SET TAGS ('dbx_business_glossary_term' = 'Parts Per Million Rate (PPM)');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `quantity_affected` SET TAGS ('dbx_business_glossary_term' = 'Quantity Affected');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `root_cause` SET TAGS ('dbx_business_glossary_term' = 'Root Cause');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `severity` SET TAGS ('dbx_business_glossary_term' = 'Defect Severity (SEVERITY)');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `severity` SET TAGS ('dbx_value_regex' = 'critical|major|minor|warning|info');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `source_system` SET TAGS ('dbx_business_glossary_term' = 'Source System');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `automotive_ecm`.`quality`.`defect_record` ALTER COLUMN `vin` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Identification Number (VIN)');
ALTER TABLE `automotive_ecm`.`quality`.`spc_chart` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `automotive_ecm`.`quality`.`spc_chart` SET TAGS ('dbx_subdomain' = 'planning_framework');
ALTER TABLE `automotive_ecm`.`quality`.`spc_chart` ALTER COLUMN `spc_chart_id` SET TAGS ('dbx_business_glossary_term' = 'Statistical Process Control Chart ID');
ALTER TABLE `automotive_ecm`.`quality`.`spc_chart` ALTER COLUMN `build_stage_id` SET TAGS ('dbx_business_glossary_term' = 'Build Stage Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`spc_chart` ALTER COLUMN `characteristic_id` SET TAGS ('dbx_business_glossary_term' = 'Characteristic Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`spc_chart` ALTER COLUMN `control_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Control Plan Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`spc_chart` ALTER COLUMN `cost_center_id` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`spc_chart` ALTER COLUMN `model_id` SET TAGS ('dbx_business_glossary_term' = 'Model Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`spc_chart` ALTER COLUMN `sku_master_id` SET TAGS ('dbx_business_glossary_term' = 'Sku Master Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`spc_chart` ALTER COLUMN `work_center_id` SET TAGS ('dbx_business_glossary_term' = 'Work Center Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`spc_chart` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');
ALTER TABLE `automotive_ecm`.`quality`.`spc_chart` ALTER COLUMN `center_line` SET TAGS ('dbx_business_glossary_term' = 'Center Line');
ALTER TABLE `automotive_ecm`.`quality`.`spc_chart` ALTER COLUMN `chart_name` SET TAGS ('dbx_business_glossary_term' = 'Statistical Process Control Chart Name');
ALTER TABLE `automotive_ecm`.`quality`.`spc_chart` ALTER COLUMN `chart_type` SET TAGS ('dbx_business_glossary_term' = 'Statistical Process Control Chart Type');
ALTER TABLE `automotive_ecm`.`quality`.`spc_chart` ALTER COLUMN `chart_type` SET TAGS ('dbx_value_regex' = 'X-bar/R|X-bar/S|p-chart|c-chart|u-chart|np-chart');
ALTER TABLE `automotive_ecm`.`quality`.`spc_chart` ALTER COLUMN `confidence_level` SET TAGS ('dbx_business_glossary_term' = 'Confidence Level (%)');
ALTER TABLE `automotive_ecm`.`quality`.`spc_chart` ALTER COLUMN `control_limit_lcl` SET TAGS ('dbx_business_glossary_term' = 'Lower Control Limit (LCL)');
ALTER TABLE `automotive_ecm`.`quality`.`spc_chart` ALTER COLUMN `control_limit_ucl` SET TAGS ('dbx_business_glossary_term' = 'Upper Control Limit (UCL)');
ALTER TABLE `automotive_ecm`.`quality`.`spc_chart` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `automotive_ecm`.`quality`.`spc_chart` ALTER COLUMN `data_source_system` SET TAGS ('dbx_business_glossary_term' = 'Source System for SPC Data');
ALTER TABLE `automotive_ecm`.`quality`.`spc_chart` ALTER COLUMN `data_source_system` SET TAGS ('dbx_value_regex' = 'SAP QM|MES|Teamcenter|Custom');
ALTER TABLE `automotive_ecm`.`quality`.`spc_chart` ALTER COLUMN `effective_from` SET TAGS ('dbx_business_glossary_term' = 'Effective From Date');
ALTER TABLE `automotive_ecm`.`quality`.`spc_chart` ALTER COLUMN `effective_until` SET TAGS ('dbx_business_glossary_term' = 'Effective Until Date');
ALTER TABLE `automotive_ecm`.`quality`.`spc_chart` ALTER COLUMN `measurement_unit` SET TAGS ('dbx_business_glossary_term' = 'Measurement Unit');
ALTER TABLE `automotive_ecm`.`quality`.`spc_chart` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Additional Notes');
ALTER TABLE `automotive_ecm`.`quality`.`spc_chart` ALTER COLUMN `ocap` SET TAGS ('dbx_business_glossary_term' = 'Out‑of‑Control Action Plan');
ALTER TABLE `automotive_ecm`.`quality`.`spc_chart` ALTER COLUMN `process_step` SET TAGS ('dbx_business_glossary_term' = 'Manufacturing Process Step');
ALTER TABLE `automotive_ecm`.`quality`.`spc_chart` ALTER COLUMN `process_step_code` SET TAGS ('dbx_business_glossary_term' = 'Process Step Code');
ALTER TABLE `automotive_ecm`.`quality`.`spc_chart` ALTER COLUMN `sample_count` SET TAGS ('dbx_business_glossary_term' = 'Sample Count');
ALTER TABLE `automotive_ecm`.`quality`.`spc_chart` ALTER COLUMN `sampling_frequency` SET TAGS ('dbx_business_glossary_term' = 'Sampling Frequency');
ALTER TABLE `automotive_ecm`.`quality`.`spc_chart` ALTER COLUMN `sampling_frequency` SET TAGS ('dbx_value_regex' = 'per_shift|per_hour|per_day|per_batch|per_lot');
ALTER TABLE `automotive_ecm`.`quality`.`spc_chart` ALTER COLUMN `spc_chart_description` SET TAGS ('dbx_business_glossary_term' = 'SPC Chart Description');
ALTER TABLE `automotive_ecm`.`quality`.`spc_chart` ALTER COLUMN `spc_chart_status` SET TAGS ('dbx_business_glossary_term' = 'SPC Chart Status');
ALTER TABLE `automotive_ecm`.`quality`.`spc_chart` ALTER COLUMN `spc_chart_status` SET TAGS ('dbx_value_regex' = 'active|inactive|deprecated|pending');
ALTER TABLE `automotive_ecm`.`quality`.`spc_chart` ALTER COLUMN `statistical_method` SET TAGS ('dbx_business_glossary_term' = 'Statistical Method');
ALTER TABLE `automotive_ecm`.`quality`.`spc_chart` ALTER COLUMN `statistical_method` SET TAGS ('dbx_value_regex' = 'Shewhart|EWMA|CUSUM|XMR');
ALTER TABLE `automotive_ecm`.`quality`.`spc_chart` ALTER COLUMN `subgroup_size` SET TAGS ('dbx_business_glossary_term' = 'Subgroup Size');
ALTER TABLE `automotive_ecm`.`quality`.`spc_chart` ALTER COLUMN `target_value` SET TAGS ('dbx_business_glossary_term' = 'Target Value');
ALTER TABLE `automotive_ecm`.`quality`.`spc_chart` ALTER COLUMN `tolerance_lower` SET TAGS ('dbx_business_glossary_term' = 'Lower Tolerance Limit');
ALTER TABLE `automotive_ecm`.`quality`.`spc_chart` ALTER COLUMN `tolerance_upper` SET TAGS ('dbx_business_glossary_term' = 'Upper Tolerance Limit');
ALTER TABLE `automotive_ecm`.`quality`.`spc_chart` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `automotive_ecm`.`quality`.`spc_chart` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'SPC Chart Version Number');
ALTER TABLE `automotive_ecm`.`quality`.`quality_ppap_submission` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `automotive_ecm`.`quality`.`quality_ppap_submission` SET TAGS ('dbx_subdomain' = 'supplier_compliance');
ALTER TABLE `automotive_ecm`.`quality`.`quality_ppap_submission` ALTER COLUMN `quality_ppap_submission_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Key for quality_ppap_submission');
ALTER TABLE `automotive_ecm`.`quality`.`quality_ppap_submission` ALTER COLUMN `apqp_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Apqp Plan Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`quality_ppap_submission` ALTER COLUMN `control_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Control Plan Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`quality_ppap_submission` ALTER COLUMN `fmea_id` SET TAGS ('dbx_business_glossary_term' = 'Fmea Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`quality_ppap_submission` ALTER COLUMN `inspection_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Inspection Plan Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`quality_ppap_submission` ALTER COLUMN `plant_id` SET TAGS ('dbx_business_glossary_term' = 'Plant Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`quality_ppap_submission` ALTER COLUMN `production_line_id` SET TAGS ('dbx_business_glossary_term' = 'Production Line Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`quality_ppap_submission` ALTER COLUMN `sku_master_id` SET TAGS ('dbx_business_glossary_term' = 'Sku Master Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`quality_ppap_submission` ALTER COLUMN `supply_ppap_submission_id` SET TAGS ('dbx_business_glossary_term' = 'Supply Ppap Submission Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`audit` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `automotive_ecm`.`quality`.`audit` SET TAGS ('dbx_subdomain' = 'supplier_compliance');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `audit_id` SET TAGS ('dbx_business_glossary_term' = 'Quality Audit ID');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `plant_id` SET TAGS ('dbx_business_glossary_term' = 'Auditee Location ID');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `carrier_id` SET TAGS ('dbx_business_glossary_term' = 'Audited Carrier Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `organization_account_id` SET TAGS ('dbx_business_glossary_term' = 'Audited Organization Account Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `vehicle_compound_id` SET TAGS ('dbx_business_glossary_term' = 'Audited Vehicle Compound Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `capex_request_id` SET TAGS ('dbx_business_glossary_term' = 'Capex Request Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `certification_id` SET TAGS ('dbx_business_glossary_term' = 'Dealer Certification Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `control_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Audit Plan ID');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `cost_center_id` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `dealership_id` SET TAGS ('dbx_business_glossary_term' = 'Dealership Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `fiscal_period_id` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Period Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `model_id` SET TAGS ('dbx_business_glossary_term' = 'Model Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `primary_auditee_location_plant_id` SET TAGS ('dbx_business_glossary_term' = 'Auditee Location ID');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `production_line_id` SET TAGS ('dbx_business_glossary_term' = 'Production Line Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `project_id` SET TAGS ('dbx_business_glossary_term' = 'Project Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `regulatory_requirement_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Requirement Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `standard_id` SET TAGS ('dbx_business_glossary_term' = 'Standard Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `vehicle_program_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Program Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `work_center_id` SET TAGS ('dbx_business_glossary_term' = 'Work Center Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `audit_date` SET TAGS ('dbx_business_glossary_term' = 'Audit Date');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `audit_method` SET TAGS ('dbx_business_glossary_term' = 'Audit Method');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `audit_method` SET TAGS ('dbx_value_regex' = 'internal|external|third_party');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `audit_number` SET TAGS ('dbx_business_glossary_term' = 'Audit Number');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `audit_number` SET TAGS ('dbx_value_regex' = '^AUD-d{6}$');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `audit_scope` SET TAGS ('dbx_business_glossary_term' = 'Audit Scope');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `audit_status` SET TAGS ('dbx_business_glossary_term' = 'Audit Status');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `audit_status` SET TAGS ('dbx_value_regex' = 'planned|in_progress|completed|closed|cancelled');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `audit_type` SET TAGS ('dbx_business_glossary_term' = 'Audit Type');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `audit_type` SET TAGS ('dbx_value_regex' = 'system|process|product|layered_process');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `auditee_location` SET TAGS ('dbx_business_glossary_term' = 'Auditee Location');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `auditor_name` SET TAGS ('dbx_business_glossary_term' = 'Auditor Name');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `auditor_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `auditor_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `closure_date` SET TAGS ('dbx_business_glossary_term' = 'Closure Date');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `closure_status` SET TAGS ('dbx_business_glossary_term' = 'Closure Status');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `closure_status` SET TAGS ('dbx_value_regex' = 'open|closed|deferred');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `corrective_action_due_date` SET TAGS ('dbx_business_glossary_term' = 'Corrective Action Due Date');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `corrective_action_required` SET TAGS ('dbx_business_glossary_term' = 'Corrective Action Required');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `corrective_action_status` SET TAGS ('dbx_business_glossary_term' = 'Corrective Action Status');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `corrective_action_status` SET TAGS ('dbx_value_regex' = 'not_started|in_progress|completed');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `documents_count` SET TAGS ('dbx_business_glossary_term' = 'Audit Documents Count');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `duration_minutes` SET TAGS ('dbx_business_glossary_term' = 'Audit Duration (Minutes)');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `findings_major` SET TAGS ('dbx_business_glossary_term' = 'Major Findings Count');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `findings_minor` SET TAGS ('dbx_business_glossary_term' = 'Minor Findings Count');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `findings_severe` SET TAGS ('dbx_business_glossary_term' = 'Severe Findings Count');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `findings_total` SET TAGS ('dbx_business_glossary_term' = 'Total Findings Count');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `non_conformance_count` SET TAGS ('dbx_business_glossary_term' = 'Non‑Conformance Count');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `non_conformance_severity` SET TAGS ('dbx_business_glossary_term' = 'Non‑Conformance Severity');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `non_conformance_severity` SET TAGS ('dbx_value_regex' = 'critical|major|minor');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Audit Notes');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `overall_score` SET TAGS ('dbx_business_glossary_term' = 'Overall Audit Score');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `risk_level` SET TAGS ('dbx_business_glossary_term' = 'Risk Level');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `risk_level` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `score_category` SET TAGS ('dbx_business_glossary_term' = 'Audit Score Category');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `score_category` SET TAGS ('dbx_value_regex' = 'excellent|good|fair|poor');
ALTER TABLE `automotive_ecm`.`quality`.`audit` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `automotive_ecm`.`quality`.`audit_finding` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `automotive_ecm`.`quality`.`audit_finding` SET TAGS ('dbx_subdomain' = 'supplier_compliance');
ALTER TABLE `automotive_ecm`.`quality`.`audit_finding` ALTER COLUMN `audit_finding_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Key for quality_audit_finding');
ALTER TABLE `automotive_ecm`.`quality`.`audit_finding` ALTER COLUMN `audit_id` SET TAGS ('dbx_business_glossary_term' = 'Quality Audit Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`audit_finding` ALTER COLUMN `defect_record_id` SET TAGS ('dbx_business_glossary_term' = 'Defect Record Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`audit_finding` ALTER COLUMN `standard_id` SET TAGS ('dbx_business_glossary_term' = 'Standard Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`pdi_inspection` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `automotive_ecm`.`quality`.`pdi_inspection` SET TAGS ('dbx_subdomain' = 'supplier_compliance');
ALTER TABLE `automotive_ecm`.`quality`.`pdi_inspection` ALTER COLUMN `pdi_inspection_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Key for quality_pdi_inspection');
ALTER TABLE `automotive_ecm`.`quality`.`pdi_inspection` ALTER COLUMN `audit_id` SET TAGS ('dbx_business_glossary_term' = 'Quality Audit Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`pdi_inspection` ALTER COLUMN `dealer_inventory_id` SET TAGS ('dbx_business_glossary_term' = 'Dealer Inventory Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`pdi_inspection` ALTER COLUMN `defect_record_id` SET TAGS ('dbx_business_glossary_term' = 'Defect Record Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`pdi_inspection` ALTER COLUMN `inspection_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Inspection Plan Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`pdi_inspection` ALTER COLUMN `vehicle_build_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Build Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`pdi_inspection` ALTER COLUMN `vehicle_compound_id` SET TAGS ('dbx_business_glossary_term' = 'Vehicle Compound Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`pdi_inspection` ALTER COLUMN `vin_registry_id` SET TAGS ('dbx_business_glossary_term' = 'Vin Registry Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` SET TAGS ('dbx_subdomain' = 'supplier_compliance');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ALTER COLUMN `supplier_quality_event_id` SET TAGS ('dbx_business_glossary_term' = 'Supplier Quality Event ID');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ALTER COLUMN `control_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Control Plan Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ALTER COLUMN `inspection_lot_id` SET TAGS ('dbx_business_glossary_term' = 'Inspection Lot Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ALTER COLUMN `invoice_id` SET TAGS ('dbx_business_glossary_term' = 'Invoice Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ALTER COLUMN `carrier_id` SET TAGS ('dbx_business_glossary_term' = 'Logistics Carrier Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ALTER COLUMN `model_id` SET TAGS ('dbx_business_glossary_term' = 'Model Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ALTER COLUMN `plant_id` SET TAGS ('dbx_business_glossary_term' = 'Plant ID');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ALTER COLUMN `production_order_id` SET TAGS ('dbx_business_glossary_term' = 'Production Order Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ALTER COLUMN `regulatory_requirement_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Requirement Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ALTER COLUMN `sku_master_id` SET TAGS ('dbx_business_glossary_term' = 'Sku Master Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ALTER COLUMN `supplier_id` SET TAGS ('dbx_business_glossary_term' = 'Supply Supplier Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ALTER COLUMN `actual_resolution_time_days` SET TAGS ('dbx_business_glossary_term' = 'Actual Resolution Time (Days)');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ALTER COLUMN `affected_quantity` SET TAGS ('dbx_business_glossary_term' = 'Affected Quantity');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ALTER COLUMN `attached_documentation` SET TAGS ('dbx_business_glossary_term' = 'Attached Documentation Reference');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Comments');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ALTER COLUMN `containment_action` SET TAGS ('dbx_business_glossary_term' = 'Containment Action');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ALTER COLUMN `corrective_action_due_date` SET TAGS ('dbx_business_glossary_term' = 'Corrective Action Due Date');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ALTER COLUMN `corrective_action_plan` SET TAGS ('dbx_business_glossary_term' = 'Corrective Action Plan');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ALTER COLUMN `defect_description` SET TAGS ('dbx_business_glossary_term' = 'Defect Description');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ALTER COLUMN `defect_quantity` SET TAGS ('dbx_business_glossary_term' = 'Defect Quantity');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ALTER COLUMN `defect_severity` SET TAGS ('dbx_business_glossary_term' = 'Defect Severity');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ALTER COLUMN `defect_severity` SET TAGS ('dbx_value_regex' = 'critical|major|minor');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ALTER COLUMN `delivery_note_number` SET TAGS ('dbx_business_glossary_term' = 'Delivery Note Number');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ALTER COLUMN `detection_method` SET TAGS ('dbx_business_glossary_term' = 'Detection Method');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ALTER COLUMN `detection_method` SET TAGS ('dbx_value_regex' = 'visual|automated|test|audit');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ALTER COLUMN `event_number` SET TAGS ('dbx_business_glossary_term' = 'Supplier Quality Event Number');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ALTER COLUMN `event_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Event Timestamp');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ALTER COLUMN `expected_resolution_time_days` SET TAGS ('dbx_business_glossary_term' = 'Expected Resolution Time (Days)');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ALTER COLUMN `is_critical` SET TAGS ('dbx_business_glossary_term' = 'Is Critical');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ALTER COLUMN `is_repeat_issue` SET TAGS ('dbx_business_glossary_term' = 'Is Repeat Issue');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ALTER COLUMN `quality_system` SET TAGS ('dbx_business_glossary_term' = 'Quality Management System');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ALTER COLUMN `regulatory_compliance_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Compliance Flag');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ALTER COLUMN `resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Resolution Date');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ALTER COLUMN `resolution_status` SET TAGS ('dbx_business_glossary_term' = 'Resolution Status');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ALTER COLUMN `resolution_status` SET TAGS ('dbx_value_regex' = 'resolved|unresolved|closed|deferred');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ALTER COLUMN `risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Risk Rating');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ALTER COLUMN `risk_rating` SET TAGS ('dbx_value_regex' = 'high|medium|low');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ALTER COLUMN `root_cause_analysis` SET TAGS ('dbx_business_glossary_term' = 'Root Cause Analysis');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ALTER COLUMN `sca_number` SET TAGS ('dbx_business_glossary_term' = 'SCAR Number');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ALTER COLUMN `sca_requested` SET TAGS ('dbx_business_glossary_term' = 'Supplier Corrective Action Request Issued');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ALTER COLUMN `supplier_response_due_date` SET TAGS ('dbx_business_glossary_term' = 'Supplier Response Due Date');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ALTER COLUMN `supplier_response_status` SET TAGS ('dbx_business_glossary_term' = 'Supplier Response Status');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ALTER COLUMN `supplier_response_status` SET TAGS ('dbx_value_regex' = 'pending|submitted|rejected|approved');
ALTER TABLE `automotive_ecm`.`quality`.`supplier_quality_event` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `automotive_ecm`.`quality`.`standard` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `automotive_ecm`.`quality`.`standard` SET TAGS ('dbx_subdomain' = 'planning_framework');
ALTER TABLE `automotive_ecm`.`quality`.`standard` ALTER COLUMN `standard_id` SET TAGS ('dbx_business_glossary_term' = 'Quality Standard Identifier');
ALTER TABLE `automotive_ecm`.`quality`.`standard` ALTER COLUMN `company_code_id` SET TAGS ('dbx_business_glossary_term' = 'Company Code Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`standard` ALTER COLUMN `applicability_scope` SET TAGS ('dbx_business_glossary_term' = 'Applicability Scope (SCOPE)');
ALTER TABLE `automotive_ecm`.`quality`.`standard` ALTER COLUMN `applicability_scope` SET TAGS ('dbx_value_regex' = 'global|regional|plant_specific');
ALTER TABLE `automotive_ecm`.`quality`.`standard` ALTER COLUMN `compliance_status` SET TAGS ('dbx_business_glossary_term' = 'Compliance Status (COMP_STATUS)');
ALTER TABLE `automotive_ecm`.`quality`.`standard` ALTER COLUMN `compliance_status` SET TAGS ('dbx_value_regex' = 'compliant|non_compliant|partial|pending');
ALTER TABLE `automotive_ecm`.`quality`.`standard` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp (CRE_TSTMP)');
ALTER TABLE `automotive_ecm`.`quality`.`standard` ALTER COLUMN `document_format` SET TAGS ('dbx_business_glossary_term' = 'Document Format (DOC_FMT)');
ALTER TABLE `automotive_ecm`.`quality`.`standard` ALTER COLUMN `document_format` SET TAGS ('dbx_value_regex' = 'pdf|docx|xlsx|html');
ALTER TABLE `automotive_ecm`.`quality`.`standard` ALTER COLUMN `document_url` SET TAGS ('dbx_business_glossary_term' = 'Document URL (DOC_URL)');
ALTER TABLE `automotive_ecm`.`quality`.`standard` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date (EFF_DT)');
ALTER TABLE `automotive_ecm`.`quality`.`standard` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date (EXP_DT)');
ALTER TABLE `automotive_ecm`.`quality`.`standard` ALTER COLUMN `is_mandatory` SET TAGS ('dbx_business_glossary_term' = 'Is Mandatory (MANDATORY)');
ALTER TABLE `automotive_ecm`.`quality`.`standard` ALTER COLUMN `issuing_body` SET TAGS ('dbx_business_glossary_term' = 'Issuing Body (ISSUER)');
ALTER TABLE `automotive_ecm`.`quality`.`standard` ALTER COLUMN `language` SET TAGS ('dbx_business_glossary_term' = 'Document Language (LANG)');
ALTER TABLE `automotive_ecm`.`quality`.`standard` ALTER COLUMN `language` SET TAGS ('dbx_value_regex' = 'en|de|fr|es|zh|ja');
ALTER TABLE `automotive_ecm`.`quality`.`standard` ALTER COLUMN `lifecycle_status` SET TAGS ('dbx_business_glossary_term' = 'Lifecycle Status (STATUS)');
ALTER TABLE `automotive_ecm`.`quality`.`standard` ALTER COLUMN `lifecycle_status` SET TAGS ('dbx_value_regex' = 'draft|active|inactive|retired|pending');
ALTER TABLE `automotive_ecm`.`quality`.`standard` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes (NOTES)');
ALTER TABLE `automotive_ecm`.`quality`.`standard` ALTER COLUMN `regulatory_body` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Body (REG_BODY)');
ALTER TABLE `automotive_ecm`.`quality`.`standard` ALTER COLUMN `regulatory_section` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Section (REG_SEC)');
ALTER TABLE `automotive_ecm`.`quality`.`standard` ALTER COLUMN `revision_date` SET TAGS ('dbx_business_glossary_term' = 'Revision Date (REV_DT)');
ALTER TABLE `automotive_ecm`.`quality`.`standard` ALTER COLUMN `revision_number` SET TAGS ('dbx_business_glossary_term' = 'Revision Number (REV_NO)');
ALTER TABLE `automotive_ecm`.`quality`.`standard` ALTER COLUMN `standard_code` SET TAGS ('dbx_business_glossary_term' = 'Standard Code (CODE)');
ALTER TABLE `automotive_ecm`.`quality`.`standard` ALTER COLUMN `standard_description` SET TAGS ('dbx_business_glossary_term' = 'Standard Description (DESC)');
ALTER TABLE `automotive_ecm`.`quality`.`standard` ALTER COLUMN `standard_type` SET TAGS ('dbx_business_glossary_term' = 'Standard Type (TYPE)');
ALTER TABLE `automotive_ecm`.`quality`.`standard` ALTER COLUMN `standard_type` SET TAGS ('dbx_value_regex' = 'quality|environment|safety|emissions|regulatory|process');
ALTER TABLE `automotive_ecm`.`quality`.`standard` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'Standard Title (TITLE)');
ALTER TABLE `automotive_ecm`.`quality`.`standard` ALTER COLUMN `updated_by` SET TAGS ('dbx_business_glossary_term' = 'Updated By (UPD_BY)');
ALTER TABLE `automotive_ecm`.`quality`.`standard` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp (UPD_TSTMP)');
ALTER TABLE `automotive_ecm`.`quality`.`standard` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number (VER)');
ALTER TABLE `automotive_ecm`.`quality`.`standard` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By (CRE_BY)');
ALTER TABLE `automotive_ecm`.`quality`.`characteristic` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `automotive_ecm`.`quality`.`characteristic` SET TAGS ('dbx_subdomain' = 'planning_framework');
ALTER TABLE `automotive_ecm`.`quality`.`characteristic` ALTER COLUMN `characteristic_id` SET TAGS ('dbx_business_glossary_term' = 'Characteristic Identifier');
ALTER TABLE `automotive_ecm`.`quality`.`characteristic` ALTER COLUMN `inspection_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Inspection Plan Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`characteristic` ALTER COLUMN `model_id` SET TAGS ('dbx_business_glossary_term' = 'Model Id (Foreign Key)');
ALTER TABLE `automotive_ecm`.`quality`.`characteristic` ALTER COLUMN `parent_characteristic_id` SET TAGS ('dbx_self_ref_fk' = 'true');
ALTER TABLE `automotive_ecm`.`quality`.`characteristic` ALTER COLUMN `sku_master_id` SET TAGS ('dbx_business_glossary_term' = 'Sku Master Id (Foreign Key)');
