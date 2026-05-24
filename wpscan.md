# WPScan

## A Primer on WPScan's Database

WPScan uses a local vulnerability and fingerprinting database as its primary reference when enumerating WordPress themes and plugins. Before performing scans, update the local database so WPScan can recognize current theme, plugin, and vulnerability information.

```bash
wpscan --update
```

![WPScan database update](/assets/wpscan-101.png)

## Enumerating Installed Themes on a WordPress Site

Installed WordPress themes can often be identified by reviewing the assets loaded by the browser.

- Open the browser developer tools.
- Use the **Network** tab to observe files loaded by the page.
- Look for URLs that reference the WordPress theme directory.
- Theme assets usually appear under `/wp-content/themes/<theme-name>/`.

### Manual Theme Discovery Example

The screenshot below shows multiple loaded assets. The highlighted URL contains the theme path:

```text
http://redacted/wp-content/themes/twentytwentyone/assets/
```

From this path, the active theme is likely `twentytwentyone`.

![Enumerating installed themes](/assets/wpscan-102.png)

Additional references to the theme name may also appear in the page source.

![Theme name in source code](/assets/wpscan-103.png)

### Using WPScan to Enumerate Themes

WPScan speeds up theme discovery with the `--enumerate` flag and the `t` argument:

```bash
wpscan --url http://cmnatics.playground/ --enumerate t
```

After a few minutes, WPScan begins returning theme findings.

![WPScan theme enumeration results](/assets/wpscan-104.png)

WPScan also explains how a result was confirmed. In the example, the `twentytwenty` theme was confirmed by scanning known locations. `twentytwenty` is the default WordPress theme associated with WordPress versions released around 2020.

## Enumerating Installed Plugins

WordPress plugins are usually located under the following path:

```text
/wp-content/plugins/<plugin-name>/
```

WPScan can enumerate common or known plugins by checking predictable plugin locations and other exposed metadata.

### Directory Listing

A **directory listing** occurs when a web server exposes the contents of a directory because no default file, such as `index.html` or `index.php`, is present or configured.

In URL terms, a path such as:

```text
http://cmnatics.playground/a/directory
```

corresponds to a server-side directory under the configured web root.

![Directory path example](/assets/wpscan-105.png)

If no default file exists in that directory, the web server may display the directory contents directly.

![Directory listing example](/assets/wpscan-106.png)

WPScan can use exposed plugin directories and known plugin paths to identify installed plugins.

### Plugin Version Discovery

In the example below, WPScan discovered the plugin `easy-table-of-contents`. Finding the plugin is useful, but version information is usually needed to determine whether the plugin is vulnerable.

![Discovered WordPress plugin](/assets/wpscan-107.png)

WordPress plugins commonly include a `README.txt` file. This file may expose metadata such as:

- Plugin name
- Plugin version
- Compatible WordPress versions
- Plugin description

WPScan can use this metadata to infer installed plugin versions.

![Plugin README metadata](/assets/wpscan-108.png)

### Using WPScan to Enumerate Plugins

Use the `p` argument with `--enumerate` to enumerate plugins:

```bash
wpscan --url http://cmnatics.playground/ --enumerate p
```

## Enumerating WordPress Users

WordPress sites often expose author information because posts are associated with users. These authors are a type of WordPress user, and WPScan can enumerate usernames from exposed author-related data.

Use the `u` argument with `--enumerate` to enumerate users:

```bash
wpscan --url http://cmnatics.playground/ --enumerate u
```

![WPScan user enumeration command](/assets/wpscan-109.png)

![WPScan discovered user](/assets/wpscan-110.png)

## The Vulnerable Flag

WPScan supports a `v` argument for vulnerability-focused enumeration. This is commonly combined with other enumeration targets, such as plugins.

For example, to enumerate vulnerable plugins:

```bash
wpscan --url http://cmnatics.playground/ --enumerate vp
```

This requires configuring WPScan to use the WPVulnDB API, which was out of scope for the source room.

![WPScan vulnerable plugin enumeration](/assets/wpscan-111.png)

## Performing a Password Attack

After enumerating users, WPScan can perform a password attack against a WordPress login using a supplied password list.

Example:

```bash
wpscan --url http://cmnatics.playground --passwords rockyou.txt --usernames cmnatic
```

![WPScan password attack](/assets/wpscan-112.png)

## Adjusting WPScan Aggressiveness

By default, WPScan attempts to be as quiet as possible. This matters because large numbers of requests can trigger firewalls, rate limits, or other defensive controls.

The `--plugins-detection` option controls the plugin detection aggressiveness profile.

Example:

```bash
wpscan --url http://cmnatics.playground --plugins-detection aggressive
```

Common profiles include:

- `passive`
- `aggressive`

## Summary Cheatsheet

| Flag or option | Purpose | Example |
|---|---|---|
| `p` | Enumerate plugins. | `--enumerate p` |
| `t` | Enumerate themes. | `--enumerate t` |
| `u` | Enumerate usernames. | `--enumerate u` |
| `v` | Use WPVulnDB to cross-reference vulnerabilities. Often combined with another target, such as plugins. | `--enumerate vp` |
| `aggressive` | Aggressiveness profile for plugin detection. | `--plugins-detection aggressive` |

## Review Questions

### Primer Questions

- What would be the full URL for the theme `twentynineteen` installed on the WordPress site `http://cmnatics.playground`?
- What argument would we provide to enumerate a WordPress site?
- What is the name of the other aggressiveness profile that we can use in our WPScan command?

## Practical: WPScan Deploy 2

Before scanning the target site, add the target machine IP and domain mapping to `/etc/hosts`:

```text
<MACHINE_IP> wpscan.thm
```

### Enumerate the Running Theme

Use WPScan theme enumeration:

```bash
wpscan --url http://wpscan.thm --enumerate t
```

### Enumerate Installed Plugins

Use WPScan plugin enumeration:

```bash
wpscan --url http://wpscan.thm --enumerate p
```

### Enumerate WordPress Users

Use WPScan user enumeration:

```bash
wpscan --url http://wpscan.thm --enumerate u
```

### Brute Force the Enumerated User

After identifying the username, use the username and the `rockyou.txt` wordlist to attempt a password attack.

Example from the source notes:

```bash
wpscan --url http://wpscan.thm --passwords rockyou.txt --usernames phreakazoid
```

## Operational Notes

- Always update WPScan before scanning so theme and plugin fingerprints are current.
- Treat user enumeration results as a pivot point for password testing, phishing analysis, and account-hardening recommendations.
- Use the least aggressive detection mode that satisfies the assessment objective. Escalate to `aggressive` only when passive detection is insufficient and the engagement scope allows noisier testing.
- Plugin and theme names are only the first step. Version information is usually required to determine whether an installed component is actually vulnerable.
