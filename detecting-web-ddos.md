# Detecting Web DDoS

## Types of Denial of Service Attacks

| Attack Type                     | Description                                                                 | Example (Recent “In the Wild”)                                                                 |
|--------------------------------|-----------------------------------------------------------------------------|------------------------------------------------------------------------------------------------|
| Slowloris                 | Sending many partial requests to tie up server resources                   | Attackers open thousands of connections and slowly drip headers to Apache/Nginx, exhausting worker threads without completing requests |
| HTTP Flood                     | Sending a large number of requests to overwhelm the server                 | Botnets generating massive GET/POST request spikes against e-commerce sites during sales events, causing outages                         |
| Cache Bypass             | Bypassing CDN edge servers and forcing the origin server to respond        | Attackers append random query strings to URLs (e.g., `?cachebust=123`) to avoid CDN caching and overload origin infrastructure           |
| Oversized Query          | Forcing the server to process large, resource-intensive requests           | Sending extremely large headers, cookies, or query strings to strain backend parsing and memory usage                                     |
| Login/Form Abuse         | Overloading authentication logic with login attempts or password resets    | Credential stuffing attacks targeting login endpoints using leaked username/password pairs at high request rates                        |
| Faulty Input Validation Abuse | Exploiting poorly designed input handling                              | Attackers submit malformed JSON or unexpected parameters to trigger excessive processing or backend errors (e.g., API abuse patterns)   |

## Log Analysis

| Indicator                     | Example                                      | Description                                                                 |
|-------------------------------|----------------------------------------------|-----------------------------------------------------------------------------|
| High Request Rate            | 10.10.10.100 → 1000 GET /login               | A resource-heavy page like /login is flooded with requests to overwhelm authentication processes. Login pages are common targets since each request may trigger password checks and database queries |
| Odd User-Agents              | curl/7.6.88 → /index repeatedly              | Attackers spoof outdated or unusual User-Agents to blend in or bypass filters. Traffic using tools like curl or Python-urllib/3.x can be a red flag for automation |
| Geographic Anomalies         | IP address origins dotted around the world   | Legitimate traffic usually comes from a few regions where users are located. A globally distributed botnet often uses IPs from many countries |
| Burst Timestamps             | 50 requests in 1 second → /search            | A sudden spike of requests within the same second creates an unnatural traffic pattern indicative of automation |
| Server Errors (HTTP 5xx)     | Spike of 503 Service Unavailable errors      | A surge in server error responses (500–511) suggests resources are exhausted and the service is struggling under attack traffic |
| Logic Abuse                  | GET /products?limit=999999                   | Attackers craft queries that force the server to process excessive data, degrading performance for all users |

### Targeted Resources

- **/login**
  - Involves authentication processes

- **/search**
  - Requires complex database queries

- **/api endpoints**
  - Critical for dynamic content delivery

- **/register** or **/signup**
  - Requires database writes and validation

- **/contact** or **/feedback**
  - Requires database entries and can trigger email notifications

- **/cart** or **/checkout**
  - Requires session management, inventory checks, and payment processing

  ## Defense

  ## Denial-of-Service (DoS) Defense Overview

* Attackers exploit weaknesses to overwhelm systems.
* Defenders use layered prevention and mitigation strategies to maintain availability.
* Focus: protecting websites and web applications from DoS attacks.

---

## Application-Level Defense

### Secure Development Practices

* Secure code is the foundation of a resilient site.
* Validate all user input in search fields and forms.
* Prevent abuse from oversized or malformed requests.
* Analogy:

  * A librarian with strict rules responds efficiently.
  * Without limits, complex or excessive requests slow service for everyone.
* Goal: block malicious queries designed to overload the system.

---

### Challenges (Bot Mitigation)

* Require proof of legitimate use before granting access.

**CAPTCHA**

* Users solve simple puzzles (e.g., checkboxes, image selection).
* Minimal effort for humans, difficult for bots.

**JavaScript Challenges**

* Run silently in the background.
* Verify whether traffic is human or automated.
* Effective against botnets that fail these checks.

---

## Network and Infrastructure Defenses

### Content Delivery Network (CDN)

* Caches content on edge servers close to users.
* Reduces latency and origin server load.
* Handles most incoming traffic, limiting backend exposure.

**Key Benefits**

* Load balancing across multiple servers.
* Automatic rerouting if a server fails.
* Absorbs large volumes of malicious traffic.

**Traffic Monitoring**

* Detect anomalies (e.g., sudden spikes from normal levels to terabytes).
* Measure cached vs. origin-served traffic.
* Identify attack patterns through visual dashboards.

**Visibility**

* Analyze traffic by:

  * Geographic origin
  * Request volume
  * Behavioral patterns
* Distinguish legitimate users from malicious traffic.

---

### Web Application Firewall (WAF)

* Filters incoming traffic based on predefined rules.
* Actions: allow, block, or challenge requests.

**Capabilities**

* Detect known attack patterns using threat intelligence.
* Mitigate common DoS and DDoS techniques.
* Support custom rules for targeted protection.

**Example: Rate Limiting**

* Limit requests to `/login.php` to 5 per minute per IP.
* Exceeding limit results in:

  * Temporary block, or
  * Challenge to verify human activity.

---

## Large-Scale Mitigation

* Modern providers use global infrastructure to absorb massive attacks.
* Techniques:

  * Traffic distribution
  * Filtering at scale
* Examples:

  * Hundreds of millions of requests per second mitigated.
  * Multi-terabit attacks absorbed without service disruption.

---

## Bypassing Security Measures

### Common Attacker Techniques

* **Cache Bypass**

  * Add random query strings (e.g., `/products?a=random`).
  * Forces requests to hit the origin server instead of cached content.

* **Traffic Evasion**

  * Change user-agent strings.
  * Spoof referrer headers.
  * Distribute requests across global locations.

### Impact

* Reduces effectiveness of CDN caching and WAF filtering.
* Increases load on origin servers.

---

## Key Takeaway

* Effective DoS defense requires multiple layers:

  * Secure coding
  * Bot challenges
  * CDN distribution
  * WAF filtering
* Continuous monitoring and adaptation are essential to counter evolving attack methods.
