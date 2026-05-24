# Log Operations

## Introduction

Log operations focus on configuring, managing, and analyzing logs in an operational context. Effective logging supports security monitoring, troubleshooting, compliance, debugging, and long-term operational awareness.

## Learning Objectives

- Understand the logic of log management and configuration.
- Become familiar with log configuration approaches.
- Gain experience with the log configuration process.

# Log Configuration

## Log Configuration Options

Logging configuration decisions should be driven by purpose. Different organizations and systems may require different levels of detail, retention, access control, and analysis capability.

Log configuration supports several overlapping needs:

- Security monitoring and incident response.
- Operational stability and performance management.
- Regulatory, legal, and audit requirements.
- Debugging and software development improvement.

### Security Purposes

Security-focused logging helps detect and respond to anomalies, threats, and security issues.

Key focus areas include:

- Anomaly and threat detection.
- Logging user authentication activity.
- Preserving visibility into system integrity and data confidentiality.

Operational value:

- Security logs help analysts determine whether suspicious activity occurred.
- Authentication logs help reveal brute force attempts, unusual access patterns, or compromised accounts.
- Integrity-related logs help identify unauthorized file, configuration, or permission changes.

### Operational Purposes

Operational logging helps detect and respond to system errors while identifying opportunities to improve performance, continuity, and reliability.

Key focus areas include:

- Proactive reports and notifications about system or component status.
- Troubleshooting.
- Capacity planning.
- Service billing.

Operational value:

- Operations teams can identify degraded services before they become outages.
- Historical performance logs support capacity planning and trend analysis.
- Component-level logs help isolate the system, application, or service responsible for a failure.

### Legal Purposes

Legal and compliance-focused logging helps organizations align with applicable laws, regulations, contracts, and industry standards. Requirements vary based on the work being performed, data being processed, and services being provided.

Key focus areas include:

- Alignment with standards, compliance requirements, regulations, and laws.
- Examples include ISO 27001, COBIT, GDPR, PCI-DSS, HIPAA, and FISMA.

Example: A company subject to PCI logging expectations may need:

- An active centralized log management system.
- Adequate log configuration across systems and components.
- Twelve-month log retention.
- The most recent three months of log data readily searchable.
- System and component security checks.
- Annual audit checks.

### Debug Purposes

Debug-focused logging improves software reliability by revealing bugs, fault conditions, and unexpected behavior.

Key focus areas include:

- Increasing visibility for application debugging.
- Improving efficiency.
- Speeding up the development process.

Operational value:

- Debug logs support faster root cause analysis during development and testing.
- Excessive debug logging in production can create unnecessary noise, sensitive-data exposure, and performance issues, so debug-level logging should be controlled carefully.

# Where to Start After Deciding the Logging Purpose

Planning begins with questions. Each implementation is unique, but most log configuration planning sessions should answer a common set of baseline questions before selecting tools or designing monitoring workflows.

After the initial questions are answered, tailoring usually requires:

- A detailed implementation plan.
- Tool and technology selection.
- Monitoring and review processes.
- Analysis and response processes.

## Questions to Ask in a Planning Meeting

- What will you log, and why?
  - Define the asset scope and logging purpose.
- Is additional effort required to achieve that purpose?
  - Identify requirements related to compliance, security, operations, or debugging.
- How much detail are you going to log?
- How much detail do you actually need to log?
- How will logs be collected?
- How will collected logs be stored?
- Are there standards, processes, regulations, or laws that apply to the logged data?
- How will logs be protected?
- How will collected logs be analyzed?
- Do you have enough personnel and technical resources to perform logging effectively?
- Do you have enough budget to plan, implement, and maintain logging?

# Planning and Implementation

Each log configuration plan should result from analysis of the environment's scope, assets, objectives, requirements, and expectations. System administrators, legal advisors, financial advisors, and managers should be involved when possible.

The central planning dilemma is balancing:

- Requirements.
- Scope.
- Level of detail.
- Financial cost.
- Labor cost.
- Risk.
- Return on investment.

The planning objective is to meet non-negotiable operational and security requirements while also considering whether additional data and insights are feasible.

A comprehensive risk assessment helps prioritize security, compliance, and legal needs. This improves the chance of achieving secure, efficient, proactive, resilient, and sustainable log operations.

## Translating Requirements and Aspirations to the Operational Level

| Base Requirements | Aspirations for Better Insights |
|---|---|
| What happened? | Is it possible to collect more useful data? |
| When did it happen? | Can we capture more detail? |
| Can time data be captured accurately? | How confident are we that the data is true? |
| Where did it happen? | What is affected? |
| Which network, system, folder, path, or interface was involved? | What is likely to happen next? |
| Who or what caused it? | Is anything else requiring attention? |
| Which log source recorded it? | What should be done about the incident? |

These two question sets represent two dimensions of logging and analysis.

### Base Requirements: Incident Detection Mindset

The baseline questions support incident detection and response. They provide a solid logging foundation, but they are primarily reactive and most useful against known threats.

Base requirements help answer:

- What happened?
- When did it happen?
- Where did it happen?
- Who or what caused it?
- Which log source recorded it?

### Aspirations: Threat-Hunting Mindset

The aspiration questions support proactive threat hunting. They require more resources because they go beyond basic detection and seek deeper context.

Aspirational logging helps answer:

- What else might be affected?
- What will happen next?
- How confident are we in the evidence?
- What additional context would improve response?

The baseline is necessary for incident detection and response, but adding proactive threat-hunting aspirations is strongly recommended because the threat landscape continually changes.

# Principles and Difficulties

Effective logging operations require consistent principles and realistic planning. The goal is to collect useful data, preserve it securely, and make it available for meaningful analysis without overwhelming analysts or systems.

## Logging Principles

### Collection

- Define the logging purpose.
- Collect what will be needed and used.
- Do not collect irrelevant data.
- Avoid unnecessary log noise.

### Format

- Log at the correct level and detail.
- Implement a consistent log format.
- Ensure timestamps are accurate and synchronized.

### Archiving and Accessibility

- Define and implement log retention policies.
- Store log data so important information remains available for analysis.
- Create backups of stored log data and supporting systems.

### Monitoring and Alerting

- Create alerts and notifications for important and noteworthy events.
- Focus on actionable alerts.
- Avoid alert noise that overwhelms analysts.

### Security

- Protect logs with access controls.
- Implement encryption when required.
- Use a dedicated log management solution where appropriate.

### Continuous Change

- Expect logging sources, types, and messages to change over time.
- Maintain and update logging configurations.
- Train personnel to understand log changes and analysis requirements.

## Challenges

### Data Volume and Noise

Common challenges include:

- Multiple data sources.
- Different log volumes from different applications.
- Applications that generate insufficient logs.
- Large-scale applications that generate massive log volumes.
- Non-essential data that makes meaningful identification difficult.

Operational concern:

- Collecting too much data without analysis can hide important events in noise.
- Collecting too little data can leave investigators without the evidence they need.

### System Performance and Collection

Common challenges include:

- Log collection can slow system performance.
- Some systems are outdated or underpowered.
- Some sensitive or legacy systems may be difficult or impossible to modify.
- Deployment and optimization can be difficult.
- Managing system and agent version updates across large networks can be overwhelming.

Operational concern:

- Logging must not destabilize the systems it is intended to protect or monitor.

### Process and Archive

Common challenges include:

- Multiple log formats.
- Time-consuming and error-prone parsing.
- Difficult retention balancing.
- Complex compliance requirements.

Operational concern:

- Retention decisions must balance investigative value, compliance requirements, storage cost, and access speed.

### Security

Common challenge:

- Protecting log data is itself a security requirement.

Operational concern:

- Logs may contain sensitive operational details, user activity, authentication evidence, or security findings. Unauthorized log access can create additional risk.

### Analysis

Common challenges include:

- Combining and correlating data from multiple sources.
- Understanding the full context of an incident.
- Performing analysis in real time.
- Avoiding false positives and false negatives.
- Maintaining enough computing resources and expertise.

Operational concern:

- A log program that collects data but cannot analyze it does not provide meaningful security value.

### Miscellaneous Challenges

Other common issues include:

- Lack of planning and roadmap.
- Lack of financial resources or budget.
- Lack of implementation scenarios, playbooks, and exercises.
- Lack of technical skills to implement, maintain, and analyze logs.
- Overemphasis on log collection rather than analysis.
- Ignoring human factors and system errors.

# Common Mistakes and Best Practices

Logging is continuous and live. It requires maintenance and improvement. An "if it works, don't touch it" approach is not acceptable because threats, computing technologies, assets, and business needs evolve.

A good self-assessment and improvement process should include:

- Learning from mistakes and failures.
- Tracking threat trends relevant to the organization’s sector.
- Conducting regular scope and resilience testing.
- Following best practices from industry leaders and experts.

## Real-World Configuration Lesson: EternalBlue and Windows 7

Poor logging configuration can create a serious analysis gap during a compromise.

| Category | Details |
|---|---|
| Experience | Log analysis became difficult because of improper log configuration or lack of configuration maintenance. |
| Storyline | Microsoft Windows 7 default logging produced zero or insufficient logs when compromised with the EternalBlue vulnerability, CVE-2017-0144. No significant event logs were created under System, Security, or Application logs. |
| Attack Details | Damage: full access to the victim system. Impact: high. NVD CVSS v3 score: 8.1 High. |
| Notes | Windows 7 SP1 official support ended in 2020. The exploit was discovered and used in the wild in 2017. |

Operational takeaway:

- Default logging is often insufficient for incident investigation.
- Logging configurations must be tested against realistic attack scenarios.
- Systems that are unsupported or poorly maintained create both security and visibility risks.

## Common Mistakes and Recommended Practices

Tailored logging solutions require comprehensive risk assessment. Consultancy support can be useful when time is limited or when systems require specialized configuration.

| Mistakes: Don'ts | Best Practices: Do's |
|---|---|
| Logging sensitive information. | Create a suitable log configuration and plan based on the environment. |
| Creating logs manually without a proper system or process. | Test logging at scale, for functionality, and for operational stability. |
| Leaving logs uncollected. | Exclude sensitive information from logs. |
| Collecting everything but not analyzing it. | Secure logs with appropriate controls. |
| Collecting logs without proper planning and configuration. | Create meaningful alerts and notifications. |
| Allowing systems to lack required log configuration. | Focus on actionable and impactful insights. |
| Skipping scale, testing, and functionality analysis. | Train analysts and improve their investigative skills. |
| Focusing only on edge systems while ignoring internal systems. | Update and maintain operational plans, components, and assets as needed. |
| Searching only for what you expect to find instead of investigating what the data shows. | Maintain a review process that encourages analysts to follow evidence, not assumptions. |
| Forgetting that logging requires planning, management, and analysis. | Treat logging as an operational lifecycle, not a one-time configuration task. |

## Operational Reference Summary

Use this checklist when reviewing or designing log operations:

- Define the logging purpose before selecting sources or tools.
- Prioritize logs that support security, operations, compliance, and debugging needs.
- Identify required evidence before an incident occurs.
- Capture enough context to answer who, what, when, where, and from which source.
- Add higher-value context when resources support proactive threat hunting.
- Standardize formats and synchronize timestamps.
- Store logs securely and define retention requirements.
- Ensure important logs remain searchable for the required period.
- Create actionable alerts and reduce noise.
- Protect logs from unauthorized access and tampering.
- Test logging against realistic incidents and attack scenarios.
- Continuously maintain configurations as systems and threats change.
