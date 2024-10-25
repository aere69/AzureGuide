# Azure Concepts

## Core Services

- Virtual Machines
  - Windows or Linux OS
  - Can be remotely connected using Remote Desktop (RDP) or SSH
  - Looks like and acts like a real server
  - Can be placed on a virtual network, arranged in "availability sets", placed behind "load balancers"
  - Install whatever software you wish
  - A server can be created in a few minutes (<10 min)
  - Abstractions (Azure Batch, VM Scale Sets, AZ Kubernetes Service, Service Fabric)

- App Services
  - Web apps or container apps
  - Windows or Linux
  - Fully-managed servers, no ability to remote control
  - .NET, .NET Core, Java, Ruby, Node.js, PHP and Python
  - Benefits in scaling, continuous integration, deployment slots, integrates with Visual Studio (one-click publish)

- Storage
  - Create accounts up to 5PB
  - Blobs, queues, tables, files
  - levels of replication from local to global
  - Storage tiers (hot, cool, archive)
  - Managed (for VMs) or unmanaged

- Data Services 
  - SQL Server Related
    - Azure SQL Database
    - Azure SQL Managed Instance (SQL Server)
    - SQL Server on a Virtual Machine
    - Synapse Analytics (SQL Data Warehouse)
  - Other
    - CosmosDB - global scale
    - Azure Database for MySQL
    - Azure Database for PostgreSQL
    - Azure Database for MariaDB
    - Aure Cache for Redis

- Microservices
  - Services Fabric
  - Aure Functions
  - Azure Logic Apps
  - API Management
  - Azure Kupernetes Services (AKS) - containerized apps

- Networking
  - Connectivity
    - Virtual Network (VNet)
    - Virtual WAN
    - ExpressRoute
    - VPN Gateway
    - Azure DNS
    - Peering
    - Bastion
  - Security
    - Network Security Groups (NSG)
    - Azure Private Link
    - DDOS Protection
    - Azure Firewall
    - Web Application Firewall (WAF)
    - Virtual Network Endopoints
  - Delivery
    - CDN
    - Azure Front Door
    - Traffic Manager
    - Application Gateway
    - Load Balancer
  - Monitoring
    - Network Watcher
    - ExpressRoute Monitor
    - Azure Monitor
    - VNet Terminal Access Point (TAP)

- Other Services
  - Chat Bot Service
  - Machine Learning
  - Media Services
  - Cognitive Services
  - IoT
  