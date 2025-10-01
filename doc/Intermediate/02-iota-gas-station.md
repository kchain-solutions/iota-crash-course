# IOTA Gas Station: Production Deployment Guide

The IOTA Gas Station is a critical infrastructure component that enables gasless transactions for users by sponsoring their transaction fees. This guide covers production deployment, configuration, monitoring, and operational best practices for running a Gas Station in enterprise environments.

## What is IOTA Gas Station?

IOTA Gas Station acts as a transaction sponsor service that:
- **Covers gas fees** for users' transactions
- **Enables seamless UX** by removing the need for users to hold IOTA tokens
- **Manages coin object pools** efficiently for concurrent transaction processing
- **Provides access control** and usage limits to prevent abuse

### Key Benefits
- **Improved User Experience**: Users don't need to acquire IOTA tokens
- **Scalable Architecture**: Handles concurrent transactions through object pooling
- **Configurable Limits**: Built-in access controls and usage tracking
- **Enterprise Ready**: Secure key management and monitoring capabilities

## Architecture Overview

The Gas Station consists of several components:

### Core Components
1. **Gas Station Server**: Main service handling transaction sponsorship
2. **Redis Storage**: Runtime state management and user tracking
3. **KMS Integration**: Secure key management for wallet operations
4. **Access Controller**: Usage limits and policy enforcement
5. **Monitoring Stack**: Prometheus metrics and transaction logging

### Transaction Flow
1. User submits transaction to Gas Station
2. Access Controller validates request against policies
3. Gas Station selects appropriate coin object from pool
4. Transaction is signed with sponsor wallet and submitted
5. Coin object is updated and returned to pool

## Configuration Guide

### Basic Configuration Structure

```yaml
# config.yaml
signer-config:
  local:
    keypair: # For development only
  # OR for production with KMS:
  # sidecar:
  #   sidecar-url: "http://localhost:3000"

rpc-host-ip: 0.0.0.0
rpc-port: 9527
metrics-port: 9184

storage-config:
  redis:
    redis_url: "redis://redis:6379"

fullnode-url: "https://api.testnet.iota.cafe"

coin-init-config:
  target-init-balance: 100000000  # 0.1 IOTA per coin object
  refresh-interval-sec: 86400     # Check every 24 hours

daily-gas-usage-cap: 1500000000000  # Global daily limit

access-controller:
  access-policy: disabled  # or "allowlist" for production
```

### Coin Initialization Configuration

The `coin-init-config` section controls the automatic coin object pool management:

#### How It Works
1. **Initialization**: At startup, Gas Station scans for large coins in the sponsor wallet
2. **Automatic Splitting**: Coins above `target-init-balance` are split into smaller objects
3. **Periodic Refresh**: System regularly checks for new coins needing to be split

#### Configuration Parameters

- **`target-init-balance`**: Target balance for each individual coin object (in nanoIOTA)
  - Example: `100000000` = 0.1 IOTA
  - Smaller values = more concurrent transactions, longer initialization
  - Larger values = faster initialization, fewer concurrent transactions

- **`refresh-interval-sec`**: How often to check for new coins to split (in seconds)
  - Example: `86400` = 24 hours
  - Recommended: Daily checks for most applications

#### Sizing Recommendations

| Use Case | Target Balance | Reasoning |
|----------|----------------|-----------|
| High Concurrency | 0.01 - 0.05 IOTA | Maximum parallel transactions |
| Medium Load | 0.1 - 0.5 IOTA | Balanced performance/initialization time |
| Low Volume | 0.5 - 1.0 IOTA | Faster setup, sufficient for low traffic |

**Important**: If set too small, initialization can take several minutes as each coin split requires a separate transaction.

### Access Controller Configuration

The Access Controller provides crucial protection against abuse:

#### Access Policies

```yaml
access-controller:
  # Option 1: Disabled (development only)
  access-policy: disabled

  # Option 2: Allowlist with usage limits (production)
  access-policy: allowlist
  allowlist:
    - address: "0x1234...abcd"
      daily_gas_limit: 10000000  # 0.01 IOTA per day
    - address: "0x5678...efgh"
      daily_gas_limit: 50000000  # 0.05 IOTA per day
```

#### Production Recommendations

Based on the official guidance:
- **Enforce daily gas limits** per account to prevent abuse
- **Restrict to specific packages** used by your application
- **Monitor usage patterns** and adjust limits as needed
- **Consider additional authentication** layers for sensitive applications

**Note**: Access Controller alone is not sufficient protection. Implement additional application-level controls based on your specific use case.

## Production Deployment

### Docker Compose Setup

Here's a complete production-ready Docker Compose configuration:

```yaml
version: '3.8'

services:
  redis:
    image: redis:latest
    container_name: gas-station-redis
    restart: unless-stopped
    volumes:
      - redis_data:/data
    networks:
      - gas_station_net
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3

  iota-gas-station:
    image: "${DOCKER_IMAGE:-iotaledger/gas-station:latest}"
    container_name: iota-gas-station
    restart: unless-stopped
    command: ["--config-path", "/app/config.yaml"]
    depends_on:
      redis:
        condition: service_healthy
    ports:
      - "9184:9184"  # Metrics port
      - "9527:9527"  # Gas Station API port
    environment:
      - CONFIG_PATH=/app/config.yaml
      - RUST_BACKTRACE=1
      - GAS_STATION_AUTH=${GAS_STATION_AUTH}
      # Optional: Enable transaction logging
      - TRANSACTIONS_LOGGING=true
    volumes:
      - ${LOCAL_CONFIG_PATH:-./config.yaml}:/app/config.yaml:ro
    networks:
      - gas_station_net
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9527/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Optional: KMS Sidecar for secure key management
  kms-sidecar:
    image: your-kms-sidecar:latest
    container_name: kms-sidecar
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      - AWS_KMS_KEY_ID=${AWS_KMS_KEY_ID}
      - AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
      - AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
      - AWS_REGION=${AWS_REGION}
    networks:
      - gas_station_net

volumes:
  redis_data:

networks:
  gas_station_net:
    driver: bridge
```

### Key Management Strategies

#### Development (Local Keypair)
```yaml
signer-config:
  local:
    keypair: "your-private-key-here"  # Never use in production!
```

#### Production (KMS Sidecar)
```yaml
signer-config:
  sidecar:
    sidecar-url: "http://kms-sidecar:3000"
```

**Production Requirements**:
1. **Run KMS sidecar** connected to your chosen KMS (AWS KMS, HashiVault, etc.)
2. **Implement proper access controls** for the KMS
3. **Backup wallet account** - the critical element for environment restoration
4. **Monitor key usage** and implement rotation policies

## Funding and Financial Management

### Hierarchical Wallet Architecture

Implement a secure multi-tier wallet structure:

```
Treasury Wallet (Multisig/MPC/Cold)
    “ (Controlled transfers)
Operational Wallet (Warm storage)
    “ (Automated top-ups)
Gas Station Wallet (Hot wallet)
```

#### Layer Descriptions

1. **Treasury Wallet**:
   - Multisig, MPC, or cold storage
   - Long-term custody with minimal exposure
   - Manual approval processes

2. **Operational Wallet**:
   - Mid-layer for controlled transfers
   - Automated but monitored operations
   - Regular funding of gas station

3. **Gas Station Wallet**:
   - Runtime hot wallet
   - Holds only necessary balance for immediate operations
   - Automated monitoring and alerting

### Funding Calculations

Based on average transaction cost of **0.005 IOTA per transaction**:

#### Transaction Volume Planning (7-day periods with 30% safety margin)

| Volume Level | Daily Txs | Weekly Txs | Base Cost | Recommended Funding |
|--------------|-----------|------------|-----------|-------------------|
| **Low** | 100 | 700 | 3.5 IOTA | **4.55 IOTA** |
| **Medium** | 1,000 | 7,000 | 35 IOTA | **45.5 IOTA** |
| **High** | 10,000 | 70,000 | 350 IOTA | **455 IOTA** |

#### Key Insights
- **1 IOTA covers ~200 transactions** at current rates
- **Include 30% safety margin** for traffic spikes
- **Monitor and adjust** based on actual usage patterns
- **Set up automated alerts** when balance drops below thresholds

### Funding Process Workflow

1. **Set Wallet Account**: Configure existing address with private key
2. **Deploy KMS Sidecar**: Secure key management through KMS
3. **Monitor Balance**: Use metrics endpoint for real-time tracking
4. **Define Thresholds**: Establish low-balance alerts and auto-replenishment
5. **Fund Wallet**: Manual or automated transfers from operational wallet

## Monitoring and Operations

### Prometheus Metrics

Gas Station exposes comprehensive metrics at `/metrics` endpoint:

```yaml
# Key metrics to monitor
gas_station_balance_total          # Current wallet balance
gas_station_transactions_total     # Transaction counters
gas_station_coin_objects_available # Available coin objects in pool
gas_station_usage_per_user        # Per-user gas consumption
```

### Monitoring Setup

#### Basic Prometheus Configuration

```yaml
# prometheus.yml
scrape_configs:
  - job_name: 'gas-station'
    static_configs:
      - targets: ['gas-station:9184']
    scrape_interval: 30s
    metrics_path: /metrics
```

#### Critical Alerts

```yaml
# alerts.yml
groups:
  - name: gas-station
    rules:
      - alert: GasStationLowBalance
        expr: gas_station_balance_total < 10000000000  # Less than 10 IOTA
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Gas Station balance is low"

      - alert: GasStationCriticalBalance
        expr: gas_station_balance_total < 1000000000   # Less than 1 IOTA
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Gas Station balance critically low - immediate action required"

      - alert: GasStationHighUsage
        expr: rate(gas_station_transactions_total[1h]) > 100
        for: 10m
        labels:
          severity: info
        annotations:
          summary: "High transaction volume detected"
```

### Transaction Logging

Enable detailed transaction logging for analytics:

```bash
# Environment variable
TRANSACTIONS_LOGGING=true
```

**Benefits of Transaction Logging**:
- Track transaction sources and usage patterns
- Analyze gas station activity over time
- Detect anomalies or suspicious activity
- Integration with external analytics tools (Elasticsearch, Splunk, Datadog)

## Backup and Recovery

### Critical Elements to Backup

#### Essential (Required for Recovery)
- **Wallet Account Private Key**: Stored in KMS - the only critical backup requirement
- **Configuration Files**: Gas station configuration and access control policies

#### Optional (Performance Recovery)
- **Redis State**: Only needed if using access controller with gas-usage tracking
- **Metrics Data**: Historical monitoring data for analysis

### Recovery Process

1. **Wallet Recovery**: Gas Station automatically scans and re-splits coin objects on startup
2. **Redis Recovery**: Only required if preserving user gas usage counters
3. **Configuration Restore**: Apply backed-up configuration files
4. **Service Restart**: Gas Station rebuilds coin object pool automatically

**Important**: The Gas Station is designed to be stateless regarding coin objects - the wallet account contains all necessary state for recovery.

## Security Best Practices

### Network Security
- **Restrict API access** to authorized clients only
- **Use TLS/SSL** for all external communications
- **Implement rate limiting** at load balancer level
- **Monitor for suspicious patterns** in transaction requests

### Access Control
- **Start with specific use case** requirements
- **Enforce daily gas limits** per account
- **Restrict to authorized packages** only
- **Implement additional authentication** layers as needed
- **Regular review and audit** of access policies

### Key Management
- **Never use local keypairs** in production
- **Implement proper KMS integration** with access controls
- **Regular key rotation** policies
- **Secure backup procedures** for wallet accounts
- **Multi-signature approvals** for treasury operations

### Operational Security
- **Separate network environments** (development/staging/production)
- **Implement proper logging** and audit trails
- **Regular security assessments** and penetration testing
- **Incident response procedures** for security events
- **Staff training** on security procedures

## Troubleshooting Common Issues

### Initialization Problems
**Symptom**: Long initialization times or failed coin splitting
**Solution**:
- Reduce `target-init-balance` if too many objects need creation
- Increase `target-init-balance` if initialization is too slow
- Check wallet balance and ensure sufficient funds

### Performance Issues
**Symptom**: High latency or transaction failures
**Solution**:
- Monitor coin object pool availability
- Adjust `target-init-balance` for optimal concurrency
- Scale Redis if experiencing storage bottlenecks
- Review access controller policies for efficiency

### Access Control Problems
**Symptom**: Legitimate users blocked or abuse not prevented
**Solution**:
- Review and adjust daily gas limits
- Implement additional application-level authentication
- Monitor usage patterns and adjust policies
- Consider allowlist vs. other access control methods

### Monitoring Gaps
**Symptom**: Insufficient visibility into system performance
**Solution**:
- Enable transaction logging for detailed analytics
- Set up comprehensive Prometheus monitoring
- Implement proper alerting thresholds
- Integrate with external monitoring tools

## Production Checklist

### Pre-Deployment
- [ ] KMS integration configured and tested
- [ ] Access controller policies defined and validated
- [ ] Monitoring and alerting system deployed
- [ ] Backup procedures implemented and tested
- [ ] Security review completed
- [ ] Load testing performed

### Go-Live
- [ ] Wallet funded with appropriate amount
- [ ] Initial coin object pool initialized
- [ ] Monitoring dashboards operational
- [ ] Alert notifications configured
- [ ] Incident response procedures documented
- [ ] Team trained on operational procedures

### Post-Deployment
- [ ] Monitor initial usage patterns
- [ ] Adjust access control policies as needed
- [ ] Validate funding calculations against actual usage
- [ ] Review and optimize configuration parameters
- [ ] Document lessons learned and operational procedures

## Additional Resources

### Official Documentation
- **[IOTA Gas Station GitHub](https://github.com/iotaledger/gas-station)** - Source code and detailed documentation
- **[Gas Station Architecture](https://docs.iota.org/operator/gas-station/architecture/)** - Technical architecture overview
- **[Access Controller Documentation](https://github.com/iotaledger/gas-station/blob/dev/docs/access-controller.md)** - Detailed access control configuration
- **[Monitoring Features](https://docs.iota.org/operator/gas-station/architecture/features#monitoring--analytics)** - Comprehensive monitoring guide

### Sample Implementations
- **[KMS Sidecar Example](https://github.com/iotaledger/gas-station/tree/dev/sample_kms_sidecar)** - Reference implementation for AWS KMS integration
- **[Docker Examples](https://github.com/iotaledger/gas-station/tree/dev/docker)** - Sample Docker and Docker Compose configurations

### Monitoring and Analytics Tools
- **Prometheus**: Metrics collection and alerting
- **Grafana**: Visualization dashboards
- **Elasticsearch/Splunk/Datadog**: Transaction log analysis
- **IOTA Explorer**: On-chain transaction verification