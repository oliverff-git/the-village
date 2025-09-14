# Diagnostic Report - Observability & Monitoring

## Component
Observability Infrastructure - Logging, Metrics, Tracing, and Error Tracking

## Purpose
Enable proactive monitoring, quick incident response, and data-driven performance optimization through comprehensive observability.

## Boundaries/Dependencies
- **Current**: Basic Prometheus metrics, JSON structured logs
- **Logging**: structlog with request IDs
- **Metrics**: prometheus-fastapi-instrumentator
- **Missing**: Distributed tracing, error tracking, custom metrics

## Issue Summary
- Limited metrics beyond basic HTTP statistics
- No distributed tracing for request flow
- Missing error tracking and alerting
- No custom business metrics
- Insufficient log aggregation strategy

## Evidence
### Issue 1: Basic Metrics Only
- **File(s)**: `apps/api/main.py`
- **Current Implementation**: Line 58
  ```python
  Instrumentator().instrument(app).expose(app, include_in_schema=False)
  ```
- **Provides**: HTTP request count, duration, size
- **Missing**: 
  - Database query metrics
  - Cache hit rates
  - Business metrics (ideas created, invites sent)
  - Queue depth and job processing time

### Issue 2: No Distributed Tracing
- **Current**: Request ID in headers/logs
- **Missing**:
  - OpenTelemetry or similar tracing
  - Cross-service request correlation
  - Performance bottleneck identification
  - Dependency mapping

### Issue 3: No Error Tracking
- **Current**: Errors logged to stdout
- **Missing**:
  - Sentry or similar error aggregation
  - Error rate monitoring
  - Stack trace grouping
  - User impact analysis

### Issue 4: Limited Audit Logging
- **File(s)**: `apps/api/models/audit.py`
- **Model Exists**: AuditEvent table
- **Usage**: Minimal - not tracking critical operations
- **Missing Events**:
  - Failed login attempts
  - Permission changes
  - Data exports
  - Admin actions

### Issue 5: No Log Aggregation Strategy
- **Current**: Container stdout/stderr
- **Missing**:
  - Centralized log collection
  - Log parsing and indexing
  - Search and analysis capabilities
  - Retention policies

## Reproduction Steps
```bash
# Check available metrics
curl http://localhost:8000/metrics | grep -v "^#" | grep -E "ideas|users|invites"

# Verify logging output
docker compose logs api | grep -E "ERROR|WARNING" | wc -l

# Look for custom metrics
grep -r "prometheus" apps/api/ | grep -v "instrumentator"

# Check audit usage
grep -r "AuditEvent" apps/api/api/
```

## Hypothesis
1. **MVP Minimalism**: Basic observability sufficient for initial launch
2. **Cost Considerations**: Advanced monitoring requires additional infrastructure
3. **Complexity Avoidance**: Distributed systems observability adds complexity
4. **Future Planning**: Observability planned for post-launch phase

## Severity/Blast Radius
- **Severity**: Medium (becomes High in production)
- **Affected Components**: 
  - All services lack deep observability
  - Incident response time increased
  - Performance optimization difficult
- **User Impact**: 
  - Slow issue resolution
  - Undetected performance degradation
  - Poor visibility into user experience

## Readiness for Ticketisation
- [x] Issue clearly defined
- [x] Evidence documented
- [x] Reproduction steps verified
- [x] Root cause hypothesized
- [x] Impact assessed

**Status**: [x] Ready for ticket / [ ] Needs more information
