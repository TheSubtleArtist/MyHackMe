# Maltego

## Overview

- Maltego is an Open Source Intelligence (OSINT) tool that combines mind-mapping with relationship-based data collection.
- Typical starting points include a domain name, company name, person’s name, email address, DNS name, or other known entity.
- Maltego expands that starting point by running **transforms**, which query data sources and return related entities.
- Information collected in Maltego can support later stages of an assessment, such as:
  - Identifying company information.
  - Discovering contact names.
  - Finding email addresses.
  - Building more realistic phishing pretexts during authorized red-team or awareness work.

## Entities and Transforms

- Each block in a Maltego graph is an **entity**.
- An entity represents a data object such as a domain, DNS name, IP address, person, email address, company, or location.
- Entities can have values that describe them.
- A **transform** is code that queries an API or data source and returns information related to a selected entity.
- A transform can return zero, one, or many new entities.
- Operationally, the workflow is:
  - Start with a known entity.
  - Run a transform against that entity.
  - Review the returned entities.
  - Run additional transforms to expand the graph.

![Maltego entity and transform workflow](/images/maltego-101.png)

## Passive and Active Reconnaissance Considerations

- Some Maltego transforms may actively connect to the target system.
- Before running a transform, determine whether it is passive or active.
- This is especially important when the assessment scope limits collection to passive reconnaissance.
- A good operational practice is to understand what each transform does before executing it.

## Example Workflow: DNS Name to IP Address

- A common Maltego workflow starts with a DNS name, such as `cafe.thmredteam.com`.
- Running a transform against the DNS name can return related IP addresses.
- One example transform path is:
  1. `Standard Transforms`
  2. `Resolve to IP`
  3. `To IP Address (DNS)`

![Maltego DNS name entity before IP resolution](/images/maltego-102.png)

- After the transform runs, Maltego returns one or more IP address entities.

![Maltego DNS to IP address transform result](/images/maltego-103.png)

## Example Workflow: IP Address to DNS Names

- After discovering an IP address, additional transforms can identify related DNS names.
- One example transform path is:
  1. `DNS from IP`
  2. `To DNS Name from passive DNS (Robtex)`
- This transform can populate the graph with DNS names related to the selected IP address.
- Additional transforms can enrich the graph further with data such as IP geolocation.

![Maltego passive DNS transform results](/images/maltego-104.png)

## Visualizing WHOIS and DNS Information

- Maltego can visually organize information that would otherwise require manual queries against online databases and command-line tools.
- Example data sources include WHOIS and DNS lookup results.
- Maltego transforms can extract and arrange returned information into a graph, including:
  - Names.
  - Email addresses.
  - IP addresses.
  - DNS names.
  - Relationships between those entities.
- Some WHOIS email results may be less useful when privacy protection is enabled, but the graph still demonstrates how Maltego structures and presents OSINT data.

![Maltego WHOIS and DNS relationship graph](/images/maltego-105.png)

## Transform Hub and Additional Transforms

- Maltego’s usefulness depends heavily on available transforms.
- New transforms can extend Maltego’s capabilities by adding additional data sources or analysis paths.
- Transforms are commonly grouped by:
  - Data type.
  - Pricing model.
  - Target audience.
  - Vendor or project.
- Maltego Community Edition and free transforms provide many options, but some transforms require a paid subscription.
- Maltego requires activation, even when using Maltego Community Edition.

![Maltego Transform Hub options](/images/maltego-106.png)

## Review Questions

- What is the name of the transform that queries NIST’s National Vulnerability Database?
- What is the name of the project that offers a transform based on ATT&CK?
