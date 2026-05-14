# STRIDE Framework

Microsoft threat modeling methodlogy
Help identify and categorize potnetial securiyt thrats in software developmet nad system design  

| Letter | Stands For              | Definition                                                                 | Policy Violated                     | Examples                                                                 |
|--------|-------------------------|----------------------------------------------------------------------------|-------------------------------------|--------------------------------------------------------------------------|
| **S**  | Spoofing               | Impersonating another user or system to gain unauthorized access.          | Authentication                     | 1. Phishing attack to steal credentials<br>2. IP address spoofing to bypass access controls |
| **T**  | Tampering              | Maliciously modifying data or system components.                           | Integrity                          | 1. Altering database records without authorization<br>2. Modifying data in transit (man-in-the-middle attack) |
| **R**  | Repudiation            | Denying that an action or transaction took place, with no way to prove otherwise. | Non-repudiation                    | 1. User claims they did not make a purchase, but no audit logs exist<br>2. Attacker deletes logs after unauthorized access |
| **I**  | Information Disclosure | Exposing information to unauthorized individuals.                           | Confidentiality                    | 1. Weak file permissions allowing unauthorized file reads<br>2. Verbose error messages leaking sensitive data |
| **D**  | Denial of Service      | Preventing legitimate users from accessing a resource or service.         | Availability                       | 1. Flooding a web server with requests (DDoS)<br>2. Resource exhaustion via infinite loops in application logic |
| **E**  | Elevation of Privilege | Gaining higher-level access than originally granted.                       | Authorization                      | 1. Exploiting a vulnerability to gain admin rights<br>2. Misconfigured permissions allowing role escalation |


## Threat Modeling with STRIDE

### 1. Preparation: Define the System Scope and Model 

- **Objective**: Establish a clear understanding of the system to apply STRIDE systematically.
- **Steps**:
  - Gather stakeholders (e.g., developers, architects, security experts) for a workshop.
  - Create a high-level diagram, such as a Data Flow Diagram (DFD), to map components: external entities (e.g., users), processes (e.g., authentication server), data stores (e.g., user database), and data flows (e.g., login credentials over HTTPS).
  - Decompose the system into trust boundaries (e.g., client-side vs. server-side) to highlight where threats might cross.
- **Integration with STRIDE**: Use the model as a canvas to brainstorm threats per category later.
- **Example Output**: A DFD showing user login flow, payment processing, and admin dashboard.

### 2. Threat Identification: Apply STRIDE Categories

- **Objective**: Systematically enumerate threats by mapping each STRIDE category to system elements.
- **Steps**:
  - For each DFD element, ask targeted questions based on STRIDE:
    - **Spoofing**: Can an attacker impersonate a user or component? (E.g., fake login credentials.)
    - **Tampering**: Can data be altered? (E.g., modifying transaction details in transit.)
    - **Repudiation**: Can actions be denied? (E.g., no logging for order placements.)
    - **Information Disclosure**: Can sensitive data be exposed? (E.g., unencrypted credit card info.)
    - **Denial of Service**: Can availability be disrupted? (E.g., overwhelming the server with requests.)
    - **Elevation of Privilege**: Can unauthorized access levels be gained? (E.g., exploiting a vuln to become admin.)
  - Document threats in a table or list, linking them to specific components.
- **Integration with STRIDE**: This phase directly uses the categories as a checklist to ensure comprehensive coverage.
- **Example Output**: For the login process: Spoofing threat via phishing; Tampering via SQL injection in input fields.

### 3. Threat Assessment: Prioritize Risks

- **Objective**: Evaluate the severity and likelihood of identified threats to focus efforts.
- **Steps**:
  - Use a risk scoring model like DREAD (Damage, Reproducibility, Exploitability, Affected Users, Discoverability) to assign scores (0-10) to each threat.
  - Calculate an overall risk score (e.g., average of DREAD scores) and rank threats: High (7+), Medium (4-6.9), Low (<4).
  - Consider business context, such as regulatory compliance (e.g., GDPR for data disclosure).
- **Integration with STRIDE**: Assess each STRIDE-categorized threat individually to determine priorities.
- **Example Output**: A spoofing threat in login scored 8.2 (high risk) due to easy exploitability and high damage potential.

### 4. Mitigation: Design and Implement Controls

- **Objective**: Address prioritized threats with countermeasures.
- **Steps**:
  - For each high/medium threat, map mitigations to STRIDE categories:
    - **Spoofing**: Implement multi-factor authentication (MFA) and certificate pinning.
    - **Tampering**: Use input validation, hashing, and digital signatures.
    - **Repudiation**: Enable comprehensive logging and timestamps with non-repudiable proofs (e.g., digital signatures).
    - **Information Disclosure**: Enforce encryption (e.g., TLS 1.3) and access controls (e.g., least privilege).
    - **Denial of Service**: Add rate limiting, auto-scaling, and DDoS protection.
    - **Elevation of Privilege**: Conduct role-based access control (RBAC) and regular code reviews.
  - Assign owners, timelines, and costs for implementation.
  - Update the system model to reflect mitigations.
- **Integration with STRIDE**: Tailor controls to counter specific category weaknesses.
- **Example Output**: For tampering in payments: Add HMAC integrity checks; verify in code reviews.

### 5. Validation and Iteration: Review and Refine

- **Objective**: Ensure the model remains effective over time.
- **Steps**:
  - Perform penetration testing or red team exercises to validate mitigations against STRIDE threats.
  - Review the threat model during system changes (e.g., new features) or at regular intervals (e.g., annually).
  - Document lessons learned and update the process for future models.
- **Integration with STRIDE**: Re-apply categories to new or modified elements.
- **Example Output**: Post-mitigation testing report showing reduced risk scores (e.g., spoofing threat drops from 8.2 to 2.5).